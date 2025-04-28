// In voice_navigation_manager.dart
import 'package:android/voice/voice_sommand_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceNavigationManager {
  static final VoiceNavigationManager _instance =
      VoiceNavigationManager._internal();
  factory VoiceNavigationManager() => _instance;
  VoiceNavigationManager._internal();

  final VoiceCommandService _service = VoiceCommandService();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isInitialized = false;
  bool _isListening = false;

  // Global keys for navigation and UI
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _service.initialize();
    await _initTts();
    _registerNavigationCommands();
    _isInitialized = true;
    debugPrint("Voice navigation manager initialized");
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    // Set completion handler to know when TTS is done
    _flutterTts.setCompletionHandler(() {
      debugPrint("TTS completed");
    });

    // Handle errors
    _flutterTts.setErrorHandler((msg) {
      debugPrint("TTS error: $msg");
    });
  }

  void _registerNavigationCommands() {
    _service.registerCommand("dashboard", () {
      navigatorKey.currentState
          ?.pushNamedAndRemoveUntil('/home', (route) => false);
      _speak("Opening dashboard");
    });

    _service.registerCommand("profile", () {
      navigatorKey.currentState?.pushNamed('/profile');
      _speak("Opening profile");
    });

    _service.registerCommand("jobs", () {
      navigatorKey.currentState?.pushNamed('/jobs');
      _speak("Opening jobs");
    });

    _service.registerCommand("job stats", () {
      navigatorKey.currentState?.pushNamed('/job_stats');
      _speak("Opening job statistics");
    });
    _service.registerCommand("saved jobs", () {
      navigatorKey.currentState?.pushNamed('/saved_jobs');
      _speak("Opening Saved jobs");
    });
    _service.registerCommand("enrolled jobs", () {
      navigatorKey.currentState?.pushNamed('/enrolled_jobs');
      _speak("Opening enrolled jobs");
    });
    _service.registerCommand("about", () {
      navigatorKey.currentState?.pushNamed('/about_us');
      _speak("Opening about us");
    });
  }

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error with TTS: $e");
    }
  }

  Future<void> startVoiceNavigation({Function? onHotwordDetected}) async {
    if (!_isInitialized) {
      debugPrint("Voice navigation not initialized");
      await initialize();
    }

    if (_isListening) {
      debugPrint("Voice navigation already active");
      return;
    }

    _isListening = true;
    await _service.startListening(
      onHotwordDetected: () async {
        // First call the passed callback if any
        if (onHotwordDetected != null) {
          onHotwordDetected();
        }

        // Then provide audio and visual feedback
        showListeningUI();
        await _speak("Hi, I'm listening");
      },
      onCommandProcessed: (bool success, String command) {
        if (!success) {
          _speak("Sorry, I didn't understand that command");
        }
      },
    );

    debugPrint("Voice navigation started");
  }

  void showListeningUI() {
    scaffoldMessengerKey.currentState?.clearSnackBars();
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mic, color: Colors.white),
            const SizedBox(width: 12),
            const Text("I'm listening..."),
          ],
        ),
        duration: const Duration(seconds: 8),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }

  Future<void> stopVoiceNavigation() async {
    if (!_isListening) return;

    await _service.stopListening();
    _isListening = false;
    debugPrint("Voice navigation stopped");
  }
}
