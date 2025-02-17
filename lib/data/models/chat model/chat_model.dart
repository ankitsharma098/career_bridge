// message_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class Message {
  final String id;
  final String senderId;
  final String senderType;
  final String receiverId;
  final String receiverType;
  final String content;
  final String? mediaUrl;
  final String status;
  final DateTime timestamp;
  final DateTime? deliveredAt;
  final DateTime? readAt;

  Message({
    required this.id,
    required this.senderId,
    required this.senderType,
    required this.receiverId,
    required this.receiverType,
    required this.content,
    this.mediaUrl,
    required this.status,
    required this.timestamp,
    this.deliveredAt,
    this.readAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Conversation {
  final User user;
  final Message lastMessage;

  Conversation({
    required this.user,
    required this.lastMessage,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class User {
  final String id;
  final String type;
  final String name;
  final String? profilePic;

  User({
    required this.id,
    required this.type,
    required this.name,
    this.profilePic,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}