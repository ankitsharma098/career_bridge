import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/chat model/chat_model.dart';
import '../data service/chat_service.dart';

part 'conversations_event.dart';
part 'conversations_state.dart';

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  final ChatRepository _repository;
  StreamSubscription<Message>? _newMessageSubscription;
  String? currentUserId;
  String? currentUserType;
  Timer? _activityTimer;

  ConversationsBloc(this._repository, this.currentUserId, this.currentUserType) : super(ConversationsInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<NewMessageReceived>(_onNewMessageReceived);

    _repository.addNewMessageListener(_handleNewMessage);
    _activityTimer = Timer.periodic(const Duration(minutes: 1), (_) => _repository.updateUserActivity());
  }
  void _handleNewMessage(Message message) {
    print('ConversationsBloc - New message callback: $message');
    add(NewMessageReceived(message));
  }
  Future<void> _onLoadConversations(LoadConversations event, Emitter<ConversationsState> emit) async {
    emit(ConversationsLoading());
    try {
      final conversations = await _repository.getConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ConversationsError(e.toString()));
    }
  }

  void _onNewMessageReceived(NewMessageReceived event, Emitter<ConversationsState> emit) {
    if (state is ConversationsLoaded) {
      final currentConversations = (state as ConversationsLoaded).conversations;
      final message = event.message;
      final otherUserId = message.senderId == currentUserId ? message.receiverId : message.senderId;

      final index = currentConversations.indexWhere((conv) => conv.user.id == otherUserId);
      if (index != -1) {
        final updatedConversation = currentConversations[index].copyWith(lastMessage: message);
        final updatedList = List<Conversation>.from(currentConversations)
          ..[index] = updatedConversation
          ..sort((a, b) => DateTime.parse(b.lastMessage.timestamp).compareTo(DateTime.parse(a.lastMessage.timestamp)));
        emit(ConversationsLoaded(updatedList));
      }
    }
  }

  @override
  Future<void> close() {
    _newMessageSubscription?.cancel();
    _activityTimer?.cancel();
    return super.close();
  }
}