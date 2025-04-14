// lib/features/voice_system/core/voice_controller.dart
import 'package:flutter/material.dart';
import '../services/nlp_services.dart';
import '../services/speech_recognition_services.dart';
import '../services/tts_services.dart';
import './command_registry.dart';

class VoiceController extends ChangeNotifier {
  final SpeechRecognitionService speechService;
  final NLPService nlpService;
  final TTSService ttsService;
  final CommandRegistry commandRegistry;

  bool _isActive = false;
  String _statusMessage = "Voice Assistant Inactive";
  String _lastCommand = "";
  bool _isProcessingCommand = false;

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
    if (_isProcessingCommand || ttsService.isSpeaking) {
      debugPrint('Ignoring command during processing or TTS: "$command"');
      return;
    }

    try {
      _isProcessingCommand = true;
      notifyListeners();

      // Step 1: Use NLP service to identify intent
      final intentResponse = await nlpService.processText(command);
      final intent = intentResponse.intent;
      debugPrint('Identified intent: $intent for command: "$command"');

      if (intent.isEmpty) {
        debugPrint('No intent found for: "$command"');
        await ttsService.speak("I didn't understand that command");
        return;
      }

      // Step 2: Find matching command
      final commandResult = commandRegistry.findMatchingCommand(command);

      if (!commandResult.isSuccessful || commandResult.matchedCommand == null) {
        debugPrint('No matching command found for intent: $intent');
        await ttsService.speak("I'm not sure how to handle that request");
        return;
      }

      // Step 3: Execute the command
      final Map<String, dynamic> parameters = intentResponse.parameters;
      final result = await commandRegistry.executeCommand(
          commandResult.matchedCommand!.id, parameters);

      // Step 4: Provide feedback
      if (result.isSuccessful) {
        await ttsService.speak("Done");
      } else {
        await ttsService.speak("I couldn't complete that action");
      }
    } catch (e) {
      debugPrint('Error processing command: $e');
      await ttsService.speak("Sorry, something went wrong");
    } finally {
      _isProcessingCommand = false;
      notifyListeners();
    }
  }

  Future<bool> startListening() async {
    final success = await speechService.startListening();
    if (success) {
      await ttsService.speak("I'm listening");
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return success;
  }

  Future<void> stopListening() async {
    await speechService.stopListening();
    _isActive = false;
    _statusMessage = "Voice Assistant Inactive";
    notifyListeners();
  }

  @override
  void dispose() {
    speechService.dispose();
    ttsService.dispose();
    super.dispose();
  }
}
