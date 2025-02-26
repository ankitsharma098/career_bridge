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

  @JsonKey(fromJson: _mediaUrlFromJson)
  final String? mediaUrl;

  @JsonKey(defaultValue: '')
  final String publicId;

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
    this.publicId='' ,
    this.status = 'sent',
    this.timestamp='',
    this.deliveredAt='',
    this.readAt='',
  });

   Message copyWith({
    String? id ,
     String? senderId,
     String? senderType,
     String? receiverId,
     String? receiverType,
     String? content,
     String? mediaUrl,
     String? publicId,
     String? status ,
     String? timestamp,
     String? delivered,
     String? readAt,
  }){
     return Message(
       id: id ?? this.id,
       senderId: senderId ?? this.senderId,
       senderType: senderType ?? this.senderType,
       receiverId: receiverId ?? this.receiverId,
       receiverType: receiverType ?? this.receiverType,
       content: content ?? this.content,
       mediaUrl: mediaUrl ?? this.mediaUrl,
       publicId: publicId ?? this.publicId,
       status: status ?? this.status,
       timestamp: timestamp ?? this.timestamp,
       deliveredAt: deliveredAt ?? this.deliveredAt,
       readAt: readAt ?? this.readAt,
     );
   }
  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
  Map<String, dynamic> toJson() => _$MessageToJson(this);

  static String? _mediaUrlFromJson(dynamic value) {
    if (value == null || value == '') return null;
    return value.toString();
  }
}

@JsonSerializable()
class Conversation {

  final User user;

  @JsonKey(name:"lastMessage")
  final Message lastMessage;

  Conversation({
    this.user = const User(),
    this.lastMessage =  const Message(),
  });
  Conversation copyWith({
    User? user,
    Message? lastMessage,
  }) {
    return Conversation(
      user: user ?? this.user,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
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
  User copyWith({
    String? id,
    String? type,
    String? name,
    String? profilePic,
  }) {
    return User(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      profilePic: profilePic ?? this.profilePic,
    );
  }
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}