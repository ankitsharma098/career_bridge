import 'package:android/features/voice_system/models/voice_command.dart';

enum CommandStatus { success, failure, partialMatch, needsMoreInfo }

class CommandResult {
  final CommandStatus status;
  final String message;
  final Map<String, dynamic> data;
  final VoiceCommand? matchedCommand;
  final String? missingParameter;

  CommandResult({
    required this.status,
    this.message = '',
    this.data = const {},
    this.matchedCommand,
    this.missingParameter,
  });
  bool get isSuccessful => status == CommandStatus.success;
  bool get needsMoreInformation => status == CommandStatus.needsMoreInfo;
}
