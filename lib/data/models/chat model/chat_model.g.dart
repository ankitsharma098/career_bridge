// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['_id'] as String? ?? '',
      senderId: json['sender'] as String? ?? '',
      senderType: json['senderType'] as String? ?? '',
      receiverId: json['receiver'] as String? ?? '',
      receiverType: json['receiverType'] as String? ?? '',
      content: json['content'] as String? ?? '',
      mediaUrl: Message._mediaUrlFromJson(json['mediaUrl']),
      publicId: json['publicId'] as String? ?? '',
      status: json['status'] as String? ?? 'sent',
      timestamp: json['timestamp'] as String? ?? '',
      deliveredAt: json['deliveredAt'] as String? ?? '',
      readAt: json['readAt'] as String? ?? '',
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      '_id': instance.id,
      'sender': instance.senderId,
      'senderType': instance.senderType,
      'receiver': instance.receiverId,
      'receiverType': instance.receiverType,
      'content': instance.content,
      'mediaUrl': instance.mediaUrl,
      'publicId': instance.publicId,
      'status': instance.status,
      'timestamp': instance.timestamp,
      'deliveredAt': instance.deliveredAt,
      'readAt': instance.readAt,
    };

Conversation _$ConversationFromJson(Map<String, dynamic> json) => Conversation(
      user: json['user'] == null
          ? const User()
          : User.fromJson(json['user'] as Map<String, dynamic>),
      lastMessage: json['lastMessage'] == null
          ? const Message()
          : Message.fromJson(json['lastMessage'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ConversationToJson(Conversation instance) =>
    <String, dynamic>{
      'user': instance.user,
      'lastMessage': instance.lastMessage,
    };

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown User',
      profilePic: json['profilePic'] as String? ?? '',
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'name': instance.name,
      'profilePic': instance.profilePic,
    };
