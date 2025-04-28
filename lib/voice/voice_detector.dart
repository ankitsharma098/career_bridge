import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_snowboy/flutter_snowboy.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

const kSampleRate = 16000;
const kNumChannels = 1;

class VoiceDetector {
  static final VoiceDetector _instance = VoiceDetector._internal();
  factory VoiceDetector() => _instance;
  VoiceDetector._internal();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isRunning = false;
  bool get isRunning => _isRunning;

  late Snowboy _detector;
  FlutterSoundRecorder? _micRecorder;
  StreamController<Uint8List>? _recordingDataController;
  StreamSubscription? _recordingDataSubscription;

  Function? _onHotwordDetected;
  Function(String)? _onCommandRecognized;

  Future<void> initialize() async {
    final String modelPath = await _copyModelToFilesystem("hey_assistant.pmdl");
    _detector = Snowboy();
    await _detector.prepare(modelPath);
    _detector.hotwordHandler = _hotwordHandler;
    await _configureAudioSession();

    // Initialize speech recognition only once
    await _speech.initialize(
      options: [stt.SpeechToText.androidIntentLookup],
      finalTimeout: const Duration(milliseconds: 2000),
    );
  }

  Future<void> _configureAudioSession() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.defaultToSpeaker |
              AVAudioSessionCategoryOptions.allowBluetooth,
      avAudioSessionMode: AVAudioSessionMode.defaultMode,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));
    await session.setActive(true);
  }

  Future<String> _copyModelToFilesystem(String filename) async {
    final String dir = (await getTemporaryDirectory()).path;
    final String finalPath = "$dir/$filename";
    if (await File(finalPath).exists() == true) {
      return finalPath;
    }
    ByteData bytes = await rootBundle.load("assets/models/$filename");
    final buffer = bytes.buffer;
    await File(finalPath).writeAsBytes(
        buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return finalPath;
  }

  void _hotwordHandler() {
    debugPrint("Hotword detected!");
    if (_onHotwordDetected != null) {
      debugPrint("Calling hotword callback");
      _onHotwordDetected!();
    } else {
      debugPrint("No hotword callback registered");
    }

    // Start listening for commands
    debugPrint("Processing command after hotword detection");
    _processCommand();
  }

  Future<void> _processCommand() async {
    debugPrint("Processing command after hotword detection");

    // Completely stop the detector instead of pausing
    await stopDetection();

    try {
      debugPrint("Starting speech recognition");
      bool available = await _speech.initialize(
        options: [stt.SpeechToText.androidIntentLookup],
        finalTimeout: const Duration(milliseconds: 3000),
      );

      if (available) {
        await _speech.listen(
          onResult: (result) {
            if (result.finalResult && result.recognizedWords.isNotEmpty) {
              debugPrint("Speech recognized: ${result.recognizedWords}");
              if (_onCommandRecognized != null) {
                _onCommandRecognized!(result.recognizedWords);
              }
            }
          },
          listenFor: const Duration(seconds: 8),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: "en_US",
          cancelOnError: false,
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        debugPrint("Speech recognition not available");
      }
    } catch (e) {
      debugPrint("Error in speech recognition: $e");
    } finally {
      // After speech recognition completes, restart hotword detection
      if (_onHotwordDetected != null) {
        // Add a short delay before restarting
        await Future.delayed(const Duration(milliseconds: 800));
        startDetection(
          onHotwordDetected: _onHotwordDetected,
          onCommandRecognized: _onCommandRecognized,
        );
      }
    }
  }

  Future<void> startDetection({
    Function? onHotwordDetected,
    Function(String)? onCommandRecognized,
  }) async {
    if (_isRunning) {
      debugPrint("Detection already running, stopping first");
      await stopDetection();
    }

    _onHotwordDetected = onHotwordDetected;
    _onCommandRecognized = onCommandRecognized;

    try {
      // Create a new recorder each time
      _micRecorder = FlutterSoundRecorder();
      await _micRecorder!.openRecorder();

      // Create recording stream
      _recordingDataController = StreamController<Uint8List>.broadcast();
      _recordingDataSubscription =
          _recordingDataController!.stream.listen((buffer) {
        // Feed data to Snowboy detector
        _detector.detect(buffer);
      });

      // Start recording
      await _micRecorder!.startRecorder(
        toStream: _recordingDataController!.sink as StreamSink<Uint8List>,
        codec: Codec.pcm16,
        numChannels: kNumChannels,
        sampleRate: kSampleRate,
      );

      _isRunning = true;
      debugPrint("Hotword detection started successfully");
    } catch (e) {
      debugPrint("Error starting detection: $e");
      // Clean up any resources if startup failed
      await _cleanupResources();
    }
  }

  Future<void> stopDetection() async {
    if (!_isRunning) return;

    await _cleanupResources();
    _isRunning = false;
    debugPrint("Hotword detection stopped");
  }

  Future<void> _cleanupResources() async {
    try {
      // Clean up recorder
      if (_micRecorder != null) {
        if (_micRecorder!.isRecording) {
          await _micRecorder!.stopRecorder();
        }
        await _micRecorder!.closeRecorder();
        _micRecorder = null;
      }

      // Clean up subscriptions and controllers
      await _recordingDataSubscription?.cancel();
      _recordingDataSubscription = null;

      await _recordingDataController?.close();
      _recordingDataController = null;
    } catch (e) {
      debugPrint("Error cleaning up resources: $e");
    }
  }
}
