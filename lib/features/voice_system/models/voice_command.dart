class VoiceCommand {
  final String id;
  final List<String> triggerPhrases;
  final String description;
  final Map<String, String>? parameters;

  VoiceCommand({
    required this.id,
    required this.triggerPhrases,
    required this.description,
    this.parameters,
  });

  factory VoiceCommand.fromJson(Map<String, dynamic> json) {
    return VoiceCommand(
      id: json['id'],
      triggerPhrases: List<String>.from(json['triggerPhrases']),
      description: json['description'],
      parameters: json['parameters'] != null
          ? Map<String, String>.from(json['parameters'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'triggerPhrases': triggerPhrases,
      'description': description,
      'parameters': parameters,
    };
  }
}
