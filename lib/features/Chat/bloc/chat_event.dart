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

class UploadMedia extends ChatEvent {
  final File file;

  UploadMedia(this.file);

  @override
  List<Object?> get props => [file];

}