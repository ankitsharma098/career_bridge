// lib/features/voice_system/services/speech_recognition_services.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_error.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'tts_services.dart';

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  TTSService? _ttsService; // Optional TTS service for coordination

  void setTTSService(TTSService ttsService) {
    _ttsService = ttsService;
  }

  bool _isInitialized = false;
  bool _isListening = false;
  bool _awaitingFinalResult = false;
  int _retryCount = 0;
  final int _maxRetries = 3;

  final StreamController<String> _textStreamController =
      StreamController<String>.broadcast();
  final StreamController<bool> _listeningStateController =
      StreamController<bool>.broadcast();
  final StreamController<String> _commandStreamController =
      StreamController<String>.broadcast();

  Stream<String> get textStream => _textStreamController.stream;
  Stream<bool> get listeningStateStream => _listeningStateController.stream;
  Stream<String> get commandStream => _commandStreamController.stream;
  bool get isListening => _isListening;

  Future<bool> initialize() async {
    try {
      debugPrint('Initializing speech recognition...');

      // Check microphone permission
      final micStatus = await Permission.microphone.status;
      if (!micStatus.isGranted) {
        final result = await Permission.microphone.request();
        if (!result.isGranted) {
          debugPrint('Microphone permission denied');
          return false;
        }
      }

      // Attempt initialization with retries
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        _isInitialized = await _speech.initialize(
          onError: _handleSpeechError,
          onStatus: _handleSpeechStatus,
        );

        if (_isInitialized) {
          debugPrint('Speech recognition initialized successfully');
          return true;
        }

        debugPrint('Initialization attempt $attempt failed');
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }

      debugPrint(
          'Speech recognition initialization failed after $_maxRetries attempts');
      return false;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      return false;
    }
  }

  Future<bool> startListening() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        debugPrint('Failed to initialize speech recognition');
        _textStreamController.add("Speech recognition unavailable");
        return false;
      }
    }

    // Stop if already listening
    if (_isListening) {
      await _speech.stop();
      await Future.delayed(const Duration(milliseconds: 300));
    }

    try {
      debugPrint('Starting command listening mode...');
      _textStreamController.add('Listening for commands...');

      // Start listening with extended durations
      await _speech.listen(
        onResult: _handleCommandResult,
        listenFor: const Duration(seconds: 60), // Increased to 60 seconds
        pauseFor: const Duration(seconds: 5), // Increased to 5 seconds
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        localeId: 'en-US',
      );

      // Verify listening state
      _isListening = _speech.isListening;
      _listeningStateController.add(_isListening);
      debugPrint('Listening started: $_isListening');

      if (!_isListening) {
        _textStreamController.add("Couldn't start listening");
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error starting listening: $e');
      _textStreamController.add("Error starting listening: $e");
      _isListening = false;
      _listeningStateController.add(false);
      return false;
    }
  }

  void _handleCommandResult(stt.SpeechRecognitionResult result) {
    if (!result.finalResult) {
      _textStreamController.add('Heard: ${result.recognizedWords}');
    }

    debugPrint('Command recognition result: ${result.recognizedWords}');

    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      final command = result.recognizedWords;
      _commandStreamController.add(command);
      _textStreamController.add('Processing: "$command"');
      _awaitingFinalResult = false; // Got a final result
      _restartListeningIfNeeded();
    }
  }

  void _handleSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _listeningStateController.add(false);
      _restartListeningIfNeeded();
    }
  }

  void _restartListeningIfNeeded() async {
    if (_awaitingFinalResult && _retryCount < _maxRetries) {
      debugPrint('No final result received, restarting listening...');
      _retryCount++;
      await Future.delayed(const Duration(milliseconds: 500));
      await startListening();
    } else {
      _retryCount = 0; // Reset for next session
      _awaitingFinalResult = false;
    }
  }

  void _handleSpeechError(stt.SpeechRecognitionError error) {
    debugPrint(
        'Speech error: ${error.errorMsg}, permanent: ${error.permanent}');
    _textStreamController.add('Error: ${error.errorMsg}');
    _isListening = false;
    _listeningStateController.add(false);
    if (error.permanent) {
      _awaitingFinalResult = false;
      _retryCount = 0;
    } else {
      _restartListeningIfNeeded();
    }
  }

  Future<bool> checkAvailability() async {
    bool available = await _speech.initialize();
    if (!available) {
      debugPrint('Speech recognition not available on this device');
    }
    return available;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      _listeningStateController.add(false);
      _textStreamController.add('Voice assistant stopped');
    }
  }

  void dispose() {
    stopListening();
    _textStreamController.close();
    _listeningStateController.close();
    _commandStreamController.close();
    _ttsService?.dispose();
  }
}
