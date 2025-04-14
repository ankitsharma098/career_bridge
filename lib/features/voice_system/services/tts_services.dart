import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isSpeaking = false;

  bool get isSpeaking => _isSpeaking;

  Future<void> initialize() async {
    try {
      debugPrint('Initializing TTS service...');
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      await _flutterTts
          .awaitSpeakCompletion(true); // Ensure completion is awaited
      _flutterTts.setCompletionHandler(() {
        debugPrint('TTS speech completed');
        _isSpeaking = false;
      });
      _flutterTts.setErrorHandler((msg) {
        debugPrint('TTS error: $msg');
        _isSpeaking = false;
      });
      _isInitialized = true;
      debugPrint('TTS service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing TTS: $e');
      _isInitialized = false;
    }
  }

  Future<void> speak(String text) async {
    debugPrint('TTS requested to speak: "$text"');
    if (!_isInitialized) {
      await initialize();
    }
    if (_isInitialized) {
      try {
        if (_isSpeaking) {
          debugPrint('TTS is already speaking, stopping previous speech');
          await _flutterTts.stop();
          _isSpeaking = false;
        }
        _isSpeaking = true;
        debugPrint('Starting TTS for: "$text"');
        await _flutterTts.speak(text);
      } catch (e) {
        debugPrint('Error in TTS speak: $e');
        _isSpeaking = false;
      }
    } else {
      debugPrint('TTS not initialized, cannot speak: "$text"');
    }
  }

  Future<void> stop() async {
    debugPrint('Stopping TTS');
    await _flutterTts.stop();
    _isSpeaking = false;
  }

  void dispose() {
    debugPrint('Disposing TTS service');
    _flutterTts.stop();
    _isSpeaking = false;
  }
}
