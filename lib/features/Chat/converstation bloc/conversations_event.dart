part of 'conversations_bloc.dart';

abstract class ConversationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadConversations extends ConversationsEvent {}

class NewMessageReceived extends ConversationsEvent {
  final Message message;
  NewMessageReceived(this.message);
  @override
  List<Object?> get props => [message];
}
class ReadReceiptReceived extends ConversationsEvent {
  final ReadReceipt readReceipt;
   ReadReceiptReceived(this.readReceipt);

  @override
  List<Object?> get props => [readReceipt];
}