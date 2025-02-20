// message_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'chat_model.g.dart';

@JsonSerializable()
class Message {
  @JsonKey(name: '_id', defaultValue: '')
  final String id;

  @JsonKey(name: 'sender', defaultValue: '')
  final String senderId;

  @JsonKey(defaultValue: '')
  final String senderType;

  @JsonKey(name: 'receiver', defaultValue: '')
  final String receiverId;

  @JsonKey(defaultValue: '')
  final String receiverType;

  @JsonKey(defaultValue: '')
  final String content;

  final String? mediaUrl;

  @JsonKey(defaultValue: 'sent')
  final String status;

  @JsonKey(defaultValue: '')
  final String timestamp;

  @JsonKey(defaultValue: '')
  final String deliveredAt;

  @JsonKey(defaultValue: '')
  final String readAt;

  const Message({
    this.id = '',
    this.senderId = '',
    this.senderType = '',
    this.receiverId = '',
    this.receiverType = '',
    this.content = '',
    this.mediaUrl,
    this.status = 'sent',
    this.timestamp='',
    this.deliveredAt='',
    this.readAt='',
  });

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);
}

@JsonSerializable()
class Conversation {

  final User user;

  @JsonKey(name:"lastMessage")
  final Message lastMessage;

  Conversation({
    this.user = const User(),
    this.lastMessage = const Message(),
  });

  factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationToJson(this);
}

@JsonSerializable()
class User {
  @JsonKey(name: 'id', defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String type;

  @JsonKey(defaultValue: 'Unknown User')
  final String name;

  @JsonKey(defaultValue: '')
  final String? profilePic;

  const User({
    this.id = '',
    this.type = '',
    this.name = 'Unknown User',
    this.profilePic = 'default-profile-pic-url',
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}