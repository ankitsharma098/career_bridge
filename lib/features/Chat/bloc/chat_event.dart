part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadMessages extends ChatEvent {}

class SendMessage extends ChatEvent {
  final String content;
  final Map<String, String>? mediaUrl;
  SendMessage(this.content, {this.mediaUrl});
  @override
  List<Object?> get props => [content, mediaUrl];
}
class MessageSentConfirmed extends ChatEvent {
  final Message message;
   MessageSentConfirmed(this.message);

  @override
  List<Object?> get props => [message];
}
class UploadMedia extends ChatEvent {
  final File file;
  UploadMedia(this.file);
  @override
  List<Object?> get props => [file];
}

class DeleteMessage extends ChatEvent {
  final String messageId;
  DeleteMessage(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

class MarkAsRead extends ChatEvent {
  final String messageId;
  MarkAsRead(this.messageId);
  @override
  List<Object?> get props => [messageId];
}

class NewMessageReceived extends ChatEvent {
  final Message message;
  NewMessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}

class ReadReceiptReceived extends ChatEvent {
  final ReadReceipt readReceipt;
  ReadReceiptReceived(this.readReceipt);
  @override
  List<Object?> get props => [readReceipt];
}