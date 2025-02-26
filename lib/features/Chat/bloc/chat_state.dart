part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class MessagesLoaded extends ChatState {
  final List<Message> messages;
  MessagesLoaded(this.messages);
  @override
  List<Object?> get props => [messages];
}

class MediaUploading extends ChatState {}

class MediaUploaded extends ChatState {
  final String mediaUrl;
  final String publicId;
  MediaUploaded(this.mediaUrl, this.publicId);
  @override
  List<Object?> get props => [mediaUrl, publicId];
}

class ChatError extends ChatState {
  final String message;
  ChatError(this.message);
  @override
  List<Object?> get props => [message];
}