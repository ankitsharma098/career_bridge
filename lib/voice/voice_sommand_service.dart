// In voice_command_service.dart
import 'package:flutter/material.dart';
import 'voice_detector.dart';

class VoiceCommand {
  final String command;
  final Function action;

  VoiceCommand({required this.command, required this.action});
}

class VoiceCommandService {
  static final VoiceCommandService _instance = VoiceCommandService._internal();
  factory VoiceCommandService() => _instance;
  VoiceCommandService._internal();

  final VoiceDetector _detector = VoiceDetector();
  final List<VoiceCommand> _commands = [];
  bool _isInitialized = false;
  Function(bool, String)? _onCommandProcessed;

  // Add commands that the voice system can recognize
  void registerCommand(String command, Function action) {
    _commands.add(VoiceCommand(command: command, action: action));
    debugPrint("Registered command: $command");
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    await _detector.initialize();
    _isInitialized = true;
    debugPrint("Voice command service initialized");
  }

  Future<void> startListening({
    Function? onHotwordDetected,
    Function(bool, String)? onCommandProcessed,
  }) async {
    if (!_isInitialized) {
      debugPrint("Voice command service not initialized");
      await initialize();
    }

    _onCommandProcessed = onCommandProcessed;

    debugPrint("Starting voice command listening");
    await _detector.startDetection(
      onHotwordDetected: onHotwordDetected,
      onCommandRecognized: _handleCommand,
    );
  }

  void _handleCommand(String command) {
    debugPrint("Command received: $command");
    bool commandExecuted = false;

    // Find matching command
    for (var cmd in _commands) {
      if (command.toLowerCase().contains(cmd.command.toLowerCase())) {
        try {
          cmd.action();
          debugPrint("Command executed: ${cmd.command}");
          commandExecuted = true;
          break;
        } catch (e) {
          debugPrint("Error executing command '${cmd.command}': $e");
        }
      }
    }

    if (_onCommandProcessed != null) {
      _onCommandProcessed!(commandExecuted, command);
    }

    if (!commandExecuted) {
      debugPrint("Command not recognized: $command");
    }
  }

  Future<void> stopListening() async {
    await _detector.stopDetection();
    debugPrint("Voice command listening stopped");
  }
}
