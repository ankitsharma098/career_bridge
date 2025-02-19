part of 'chat_bloc.dart';

@immutable
abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props=>[];
}
class LoadConversations extends ChatEvent {}

class LoadMessages extends ChatEvent {
  final String receiverId;
  final String receiverType;
  // final String? before;
  // final int? limit;

  LoadMessages(this.receiverId, this.receiverType);

  @override
  List<Object?> get props => [receiverId, receiverType];
}

class SendMessage extends ChatEvent {
  final String receiverId;
  final String receiverType;
  final String content;
  final String? mediaUrl;

  SendMessage(this.receiverId, this.receiverType, this.content, {this.mediaUrl});

  @override
  List<Object?> get props => [receiverId, receiverType, content, mediaUrl];
}

// In chat_event.dart
class InitiateChat extends ChatEvent {
  final String receiverId;
  final String receiverType;
  final String receiverName;
  final String initialMessage;
  final String? mediaUrl;

  InitiateChat(
      this.receiverId,
      this.receiverType,
      this.receiverName,
      this.initialMessage,
      {this.mediaUrl}
      );

  @override
  List<Object?> get props => [receiverId, receiverType, receiverName, initialMessage, mediaUrl];
}
class UploadMedia extends ChatEvent {
  final File file;

  UploadMedia(this.file);

  @override
  List<Object?> get props => [file];

}

class MarkAsRead extends ChatEvent {
  final String messageId;

  MarkAsRead(this.messageId);
}

class NewMessageReceived extends ChatEvent {
  final Message message;

  NewMessageReceived(this.message);
}