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
          _ttsService?.speak("Microphone permission denied");
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
          _ttsService?.speak("Speech recognition ready");
          return true;
        }

        debugPrint('Initialization attempt $attempt failed');
        await Future.delayed(Duration(milliseconds: 500 * attempt));
      }

      debugPrint(
          'Speech recognition initialization failed after $_maxRetries attempts');
      _ttsService?.speak("Failed to initialize speech recognition");
      return false;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      _ttsService?.speak("Error setting up speech recognition");
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
      _ttsService?.speak("Listening for your command");

      // Start listening with optimized durations
      await _speech.listen(
        onResult: _handleCommandResult,
        listenFor: const Duration(seconds: 120), // Extended to 2 minutes
        pauseFor: const Duration(
            seconds: 3), // Slightly reduced for more responsiveness
        listenMode: stt.ListenMode
            .dictation, // Use dictation mode for better continuous speech
        partialResults: true,
        localeId: 'en-US',
        cancelOnError: false, // Prevent cancellation on minor errors
      );

      // Verify listening state
      _isListening = _speech.isListening;
      _listeningStateController.add(_isListening);
      debugPrint('Listening started: $_isListening');

      if (!_isListening) {
        _textStreamController.add("Couldn't start listening");
        _ttsService?.speak("Couldn't start listening");
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error starting listening: $e');
      _textStreamController.add("Error starting listening: $e");
      _ttsService?.speak("Error starting to listen");
      _isListening = false;
      _listeningStateController.add(false);
      return false;
    }
  }

  String _partialTextBuffer = '';
  Timer? _completionTimer;
  final Duration _completionDelay = Duration(milliseconds: 1500);

  void _handleCommandResult(stt.SpeechRecognitionResult result) {
    // Always update the partial text buffer
    _partialTextBuffer = result.recognizedWords;

    // Update UI with current recognition
    if (!result.finalResult) {
      _textStreamController.add('Heard: ${result.recognizedWords}');
    }

    debugPrint('Command recognition result: ${result.recognizedWords}');

    // If we get a final result, process it immediately
    if (result.finalResult && result.recognizedWords.isNotEmpty) {
      _processCommand(result.recognizedWords);
    }
    // Otherwise, set a timer to process after a pause in speech
    else if (!result.finalResult && result.recognizedWords.isNotEmpty) {
      // Cancel any existing timer
      _completionTimer?.cancel();

      // Set a new timer for processing after delay
      _completionTimer = Timer(_completionDelay, () {
        if (_partialTextBuffer.isNotEmpty) {
          _processCommand(_partialTextBuffer);
        }
      });
    }
  }

  void _processCommand(String command) {
    _commandStreamController.add(command);
    _textStreamController.add('Processing: "$command"');
    _ttsService?.speak("Processing command: $command");
    _partialTextBuffer = ''; // Clear the buffer
    _awaitingFinalResult = false;
    _restartListeningIfNeeded();
  }

  void _handleSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    if (status == 'done' || status == 'notListening') {
      _isListening = false;
      _listeningStateController.add(false);
      _ttsService?.speak("Stopped listening");
      _restartListeningIfNeeded();
    }
  }

  void _restartListeningIfNeeded() async {
    if (_awaitingFinalResult && _retryCount < _maxRetries) {
      debugPrint('No final result received, restarting listening...');
      _ttsService?.speak("Retrying to listen");
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
    _ttsService?.speak("Speech error: ${error.errorMsg}");
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
      _ttsService?.speak("Speech recognition not available");
    } else {
      _ttsService?.speak("Speech recognition is available");
    }
    return available;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      await _speech.stop();
      _isListening = false;
      _listeningStateController.add(false);
      _textStreamController.add('Voice assistant stopped');
      _ttsService?.speak("Voice assistant stopped");
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
