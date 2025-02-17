// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderType: json['senderType'] as String,
      receiverId: json['receiverId'] as String,
      receiverType: json['receiverType'] as String,
      content: json['content'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      status: json['status'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      deliveredAt: json['deliveredAt'] == null
          ? null
          : DateTime.parse(json['deliveredAt'] as String),
      readAt: json['readAt'] == null
          ? null
          : DateTime.parse(json['readAt'] as String),
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderType': instance.senderType,
      'receiverId': instance.receiverId,
      'receiverType': instance.receiverType,
      'content': instance.content,
      'mediaUrl': instance.mediaUrl,
      'status': instance.status,
      'timestamp': instance.timestamp.toIso8601String(),
      'deliveredAt': instance.deliveredAt?.toIso8601String(),
      'readAt': instance.readAt?.toIso8601String(),
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      lastMessage:
          Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'user': instance.user,
      'lastMessage': instance.lastMessage,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      profilePic: json['profilePic'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'profilePic': instance.profilePic,
    };
