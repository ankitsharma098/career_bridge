part of 'chat_bloc.dart';

@immutable
abstract class  ChatState extends Equatable {
  @override
  List<Object?> get props=>[];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}
// In chat_state.dart
class ChatInitiated extends ChatState {
  final String receiverId;
  final String receiverType;
  final String receiverName;

  ChatInitiated(this.receiverId, this.receiverType, this.receiverName);

  @override
  List<Object?> get props => [receiverId, receiverType, receiverName];
}
class ConversationsLoaded extends ChatState {
  final List<Conversation> conversations;

  ConversationsLoaded(this.conversations);

  @override
  List<Object?> get props => [conversations];
}

class MessagesLoaded extends ChatState {
  final List<Message> messages;

  MessagesLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

// class MessageSent extends ChatState {
//   final Message message;
//
//   MessageSent(this.message);
//
//   @override
//   List<Object?> get props => [message];
// }
class MediaUploading extends ChatState {}

class MediaUploaded extends ChatState {
  final String mediaUrl;

  MediaUploaded(this.mediaUrl);

  @override
  List<Object?> get props => [mediaUrl];
}

class ChatError extends ChatState {
  final String message;

  ChatError(this.message);

  @override
  List<Object?> get props => [message];
}
