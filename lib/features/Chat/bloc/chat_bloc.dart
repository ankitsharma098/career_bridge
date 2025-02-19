import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/models/chat model/chat_model.dart';
import '../data service/chat_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository = ChatRepository();
  String? currentUserType;
  String? currentUserId;

  ChatBloc() : super(ChatInitial()) {

    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<UploadMedia>(_onUploadMedia);
    on<InitiateChat>(_onInitiateChat);
    on<MarkAsRead>(_onMarkAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);

    // Safe setup of message listeners
    Future.delayed(Duration(milliseconds: 500), () {
      _setupMessageListeners();
    });
  }
    // Setup message listener

  void _setupMessageListeners() {
  // Setup message listener
  _repository.onNewMessage(_handleNewMessage);

  // Setup read receipt listener
  _repository.onReadReceipt((messageId, readAt) {
    // Update message status if needed
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final updatedMessages = currentMessages.map((msg) {
        if (msg.id == messageId) {
          return Message(
            id: msg.id,
            senderId: msg.senderId,
            senderType: msg.senderType,
            receiverId: msg.receiverId,
            receiverType: msg.receiverType,
            content: msg.content,
            mediaUrl: msg.mediaUrl,
            status: 'read',
            timestamp: msg.timestamp,
            readAt: readAt,
            deliveredAt: msg.deliveredAt,
          );
        }
        return msg;
      }).toList();

      emit(MessagesLoaded(updatedMessages));
    }
  });
}

  void _handleNewMessage(Message message) {
    add(NewMessageReceived(message));
  }

  Future<void> _onLoadConversations(LoadConversations event, Emitter<ChatState> emit) async {
    print("Loading conversations...");
    emit(ChatLoading());
    try {
      print("Fetching conversations from repository...");
      final conversations = await _repository.getConversations();
      print("Fetched ${conversations.length} conversations");
      emit(ConversationsLoaded(conversations));
      print("Emitted ConversationsLoaded state");
    } catch (e) {
      print("Error loading conversations: $e");
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onInitiateChat(InitiateChat event, Emitter<ChatState> emit) async {
    try {
      print("initate occured");
      await _repository.initiateChat(
        event.receiverId,
        event.receiverType,
        event.initialMessage,
        mediaUrl: event.mediaUrl,
      );

      emit(ChatInitiated(event.receiverId, event.receiverType, event.receiverName));

      // After initiating, load messages
      add(LoadMessages(event.receiverId, event.receiverType));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getMessages(
        event.receiverId,
        event.receiverType,
      );

      // Mark unread messages as read
      for (var message in messages) {
        if (message.status != 'read' &&
            message.receiverId == currentUserId &&
            message.receiverType == currentUserType) {
          _repository.markAsRead(message.id);
        }
      }

      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;

      // Optimistically update UI with sent message
      final newMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
        senderId: currentUserId ?? '',
        senderType: currentUserType ?? '',
        receiverId: event.receiverId,
        receiverType: event.receiverType,
        content: event.content,
        mediaUrl: event.mediaUrl,
        status: 'sent',
        timestamp: DateTime.now(),
      );

      emit(MessagesLoaded([...currentMessages, newMessage]));

      // Send actual message
      _repository.sendMessage(
        event.receiverId,
        event.receiverType,
        event.content,
        mediaUrl: event.mediaUrl,
      );
    }
  }

  Future<void> _onUploadMedia(UploadMedia event, Emitter<ChatState> emit) async {
    emit(MediaUploading());
    try {
      final mediaUrl = await _repository.uploadMedia(event.file);
      emit(MediaUploaded(mediaUrl));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    _repository.markAsRead(event.messageId);
  }

  Future<void> _onNewMessageReceived(NewMessageReceived event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;

      // Avoid duplicate messages
      if (!currentMessages.any((msg) => msg.id == event.message.id)) {
        final updatedMessages = [...currentMessages, event.message];
        emit(MessagesLoaded(updatedMessages));

        // Mark message as read if we're the receiver
        if (event.message.receiverId == currentUserId &&
            event.message.receiverType == currentUserType) {
          _repository.markAsRead(event.message.id);
        }
      }
    }
  }

  void setCurrentUser(String userId, String userType) {
    currentUserId = userId;
    currentUserType = userType;
  }

  @override
  Future<void> close() {
    _repository.dispose();
    return super.close();
  }
}