import 'dart:async';

import 'package:flutter/material.dart';
import '../services/nlp_services.dart';
import '../services/speech_recognition_services.dart';
import '../services/tts_services.dart';
import './command_registry.dart';
import '../models/command_result.dart';

class VoiceController extends ChangeNotifier {
  final SpeechRecognitionService speechService;
  final NLPService nlpService;
  final TTSService ttsService;
  final CommandRegistry commandRegistry;

  bool _isActive = false;
  String _statusMessage = "Voice Assistant Inactive";
  String _lastCommand = "";
  bool _isProcessingCommand = false;

  bool _processingCommand = false;
  final Duration _processingTimeout = Duration(seconds: 5);
  Timer? _processingTimer;

  VoiceController({
    required this.speechService,
    required this.nlpService,
    required this.ttsService,
    required this.commandRegistry,
  }) {
    _initializeListeners();
  }

  bool get isActive => _isActive;
  String get statusMessage => _statusMessage;
  String get lastCommand => _lastCommand;
  Stream<String> get textStream => speechService.textStream;
  Stream<bool> get listeningStateStream => speechService.listeningStateStream;
  bool get isProcessingCommand => _isProcessingCommand;

  void _initializeListeners() {
    // Listen for speech recognition state changes
    speechService.listeningStateStream.listen((isListening) {
      _isActive = isListening;
      notifyListeners();
    });

    // Listen for text updates
    speechService.textStream.listen((text) {
      _statusMessage = text;
      notifyListeners();
    });

    // Listen for commands and process them
    speechService.commandStream.listen((command) async {
      _lastCommand = command;
      notifyListeners();

      await processCommand(command);
    });
  }

  Future<void> processCommand(String command) async {
    if (_processingCommand) {
      debugPrint('Already processing a command, ignoring: $command');
      return;
    }

    _processingCommand = true;
    _isProcessingCommand = true;
    notifyListeners();

    try {
      // Stop listening while processing to avoid interference
      await stopListening();

      // Create timeout to prevent hanging
      _processingTimer = Timer(_processingTimeout, () {
        _processingCommand = false;
        _isProcessingCommand = false;
        notifyListeners();
        debugPrint('Command processing timed out');
        ttsService.speak("Sorry, command processing took too long");
      });

      // Process the command with NLP
      debugPrint('Detecting intent for command: $command');
      final nlpResponse = await nlpService.detectIntent(command);
      final intent = nlpResponse.intent;

      // Clear the timeout since we successfully processed
      _processingTimer?.cancel();

      if (intent.isNotEmpty && nlpResponse.confidence > 0.6) {
        debugPrint('Executing command with intent: $intent');
        // Execute command via registry
        CommandResult result = await commandRegistry.executeCommand(
            intent, nlpResponse.parameters);

        if (result.status == CommandStatus.success) {
          debugPrint('Command executed successfully: $intent');
          ttsService.speak("Command executed");
        } else {
          debugPrint('Command failed: $intent, reason: ${result.message}');
          ttsService.speak("Command not found or failed");
        }
      } else {
        debugPrint(
            'No intent detected or low confidence: ${nlpResponse.confidence}');
        ttsService.speak("I didn't understand that command");
      }
    } catch (e) {
      debugPrint('Error processing command: $e');
      ttsService.speak("Error processing your command");
    } finally {
      _processingCommand = false;
      _isProcessingCommand = false;
      notifyListeners();
      // Restart listening after command processing
      debugPrint('Restarting listening after command processing');
      await Future.delayed(Duration(milliseconds: 1000));
      await startListening();
    }
  }

  Future<bool> startListening() async {
    debugPrint('Starting listening via VoiceController');
    final success = await speechService.startListening();
    if (success) {
      debugPrint('Listening started successfully');
      // TTS feedback is handled in SpeechRecognitionService
    } else {
      debugPrint('Failed to start listening');
      ttsService.speak("Failed to start listening");
    }
    return success;
  }

  Future<void> stopListening() async {
    debugPrint('Stopping listening via VoiceController');
    await speechService.stopListening();
    _isActive = false;
    _statusMessage = "Voice Assistant Inactive";
    notifyListeners();
  }

  @override
  void dispose() {
    debugPrint('Disposing VoiceController');
    speechService.dispose();
    ttsService.dispose();
    super.dispose();
  }
}
