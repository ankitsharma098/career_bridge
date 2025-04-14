import '../models/voice_command.dart';
import '../models/command_result.dart';

class CommandRegistry {
  final Map<String, VoiceCommand> _commands = {};
  final Map<String, Function(Map<String, dynamic>)> _commandHandlers = {};

  void registerCommand(
    VoiceCommand command,
    Function(Map<String, dynamic>) handler,
  ) {
    _commands[command.id] = command;
    _commandHandlers[command.id] = handler;
  }

  List<VoiceCommand> get allCommands => _commands.values.toList();

  VoiceCommand? getCommandById(String id) => _commands[id];

  CommandResult findMatchingCommand(String input) {
    final String normalizedInput = input.toLowerCase().trim();

    for (final command in _commands.values) {
      for (final phrase in command.triggerPhrases) {
        if (normalizedInput.contains(phrase.toLowerCase())) {
          return CommandResult(
            status: CommandStatus.success,
            matchedCommand: command,
          );
        }
      }
    }

    return CommandResult(
      status: CommandStatus.failure,
      message: 'No matching command found.',
    );
  }

  Future<CommandResult> executeCommand(
      String commandId, Map<String, dynamic> parameters) async {
    final command = _commands[commandId];
    final handler = _commandHandlers[commandId];

    if (command == null || handler == null) {
      return CommandResult(
        status: CommandStatus.failure,
        message: 'Command not found.',
      );
    }

    try {
      final result = await handler(parameters);
      return CommandResult(
        status: CommandStatus.success,
        message: 'Command executed successfully.',
        data: {'result': result},
        matchedCommand: command,
      );
    } catch (e) {
      return CommandResult(
        status: CommandStatus.failure,
        message: 'Failed to execute command: $e',
        matchedCommand: command,
      );
    }
  }
}
