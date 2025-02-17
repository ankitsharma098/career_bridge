import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/models/chat model/chat_model.dart';
import '../data service/chat_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository=ChatRepository();
  ChatBloc() : super(ChatInitial()) {
    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<UploadMedia>(_onUploadMedia);
    _repository.onNewMessage((message) {
      if (state is MessagesLoaded) {
        final currentMessages = (state as MessagesLoaded).messages;
        emit(MessagesLoaded([...currentMessages, message]));
      }
    });
  }

  Future<void> _onLoadConversations(LoadConversations event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final conversations = await _repository.getConversations();
      emit(ConversationsLoaded(conversations));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getMessages(event.receiverId, event.receiverType);
      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    try {
      _repository.sendMessage(
        event.receiverId,
        event.receiverType,
        event.content,
        mediaUrl: event.mediaUrl,
      );
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onUploadMedia(UploadMedia event, Emitter<ChatState> emit) async {
    try {
      final mediaUrl = await _repository.uploadMedia(event.file);
      // You might want to handle the uploaded media URL here
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }


}
