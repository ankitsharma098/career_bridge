part of 'conversations_bloc.dart';

abstract class ConversationsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConversationsInitial extends ConversationsState {}

class ConversationsLoading extends ConversationsState {}

class ConversationsLoaded extends ConversationsState {
  final List<Conversation> conversations;
  ConversationsLoaded(this.conversations);
  @override
  List<Object?> get props => [conversations];
}

class ConversationsError extends ConversationsState {
  final String message;
  ConversationsError(this.message);
  @override
  List<Object?> get props => [message];
}