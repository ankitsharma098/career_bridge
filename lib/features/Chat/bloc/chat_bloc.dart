import 'dart:async';
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
  String? currentReceiverId;
  Timer? _activityTimer;

  ChatBloc() : super(ChatInitial()) {

    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);

    on<UploadMedia>(_onUploadMedia);
    on<InitiateChat>(_onInitiateChat);
    on<DeleteMessage>(_onDeleteMessage);

    _repository.onNewMessage((message) {
      print('New message received: ${message.toJson()}');
      add(NewMessageReceived(message));
    });
    _repository.onReadReceipt((messageId, readAt) {
      if (state is MessagesLoaded) {
        print('Read receipt for messageId: $messageId at $readAt');
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
              status: 'read',
              timestamp: msg.timestamp,
              readAt: readAt.toIso8601String(),
            );
          }
          return msg;
        }).toList();
        emit(MessagesLoaded(updatedMessages));
      }
    });

    _activityTimer = Timer.periodic(Duration(minutes: 1), (_) => _repository.updateUserActivity());
  }


  Future<void> _onLoadConversations(LoadConversations event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final conversations = await _repository.getConversations();
      print("Fetched ${conversations.length} conversations");
      emit(ConversationsLoaded(conversations));
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
        media: event.mediaUrl,
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
      currentReceiverId = event.receiverId;
      final messages = await _repository.getMessages(event.receiverId, event.receiverType);

      for (var message in messages) {
        if (message.status != 'read' && message.receiverId == currentUserId) {
          _repository.markAsRead(message.id);
        }
      }

      emit(MessagesLoaded(messages));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    print('Handling SendMessage for receiver: ${event.receiverId}');
    List<Message> currentMessages = [];
    if (state is MessagesLoaded) {
      currentMessages = (state as MessagesLoaded).messages;
    } else {
      // Load messages if state isn’t MessagesLoaded
      emit(ChatLoading());
      currentMessages = await _repository.getMessages(event.receiverId, event.receiverType);
      emit(MessagesLoaded(currentMessages));
    }

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newMessage = Message(
      id: tempId,
      senderId: currentUserId ?? '',
      senderType: currentUserType ?? '',
      receiverId: event.receiverId,
      receiverType: event.receiverType,
      content: event.content,
      mediaUrl: event.mediaUrl?['url'],
      publicId: event.mediaUrl?['publicId'] ?? '',
      status: 'sent',
      timestamp: DateTime.now().toIso8601String(),
    );
    print('Adding temporary message: ${newMessage.toJson()}');
    emit(MessagesLoaded([...currentMessages, newMessage]));

    try {
      await _repository.sendMessage(
        event.receiverId,
        event.receiverType,
        event.content,
        media: event.mediaUrl,
      );
      print('Message sent to server successfully');
    } catch (e) {
      print('Error sending message: $e');
      emit(ChatError('Failed to send message: $e'));
      emit(MessagesLoaded(currentMessages)); // Restore on error
    }
  }

  Future<void> _onUploadMedia(UploadMedia event, Emitter<ChatState> emit) async {
    emit(MediaUploading());
    try {
      final mediaData = await _repository.uploadMedia(event.file);
      emit(MediaUploaded(mediaData['url']!, mediaData['publicId']!));
      // Restore MessagesLoaded state immediately
      if (state is MessagesLoaded) {
        final currentMessages = (state as MessagesLoaded).messages;
        emit(MessagesLoaded(currentMessages));
      } else {
        // Load messages if not already loaded
        print("State -----------$state");
        final messages = await _repository.getMessages(currentReceiverId ?? '', currentUserType ?? '');
        emit(MessagesLoaded(messages));
      }
    } catch (e) {
      emit(ChatError(e.toString()));
      if (state is MessagesLoaded) {
        final currentMessages = (state as MessagesLoaded).messages;
        emit(MessagesLoaded(currentMessages));
      }
    }
  }
  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      await _repository.deleteMessage(event.messageId);
      final updatedMessages = currentMessages.where((msg) => msg.id != event.messageId).toList();
      emit(MessagesLoaded(updatedMessages));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    _repository.markAsRead(event.messageId);
  }

  Future<void> _onNewMessageReceived(NewMessageReceived event, Emitter<ChatState> emit) async {
    final message = event.message;
    print('Processing new message: ${message.id}, sender: ${message.senderId}, receiver: ${message.receiverId}');
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      if ((message.senderId == currentUserId && message.receiverId == currentReceiverId) ||
          (message.receiverId == currentUserId && message.senderId == currentReceiverId)) {

        final updatedMessages = currentMessages.map((msg) {
          // Check if this is a temp message for the same content and sender/receiver
          if (msg.id.startsWith('temp_') &&
              msg.content == message.content &&
              msg.senderId == message.senderId &&
              msg.receiverId == message.receiverId) {
            print('Replacing temporary message ${msg.id} with server message ${message.id}');
            return message;
          }
          return msg;
        }).toList();

        if (!updatedMessages.any((msg) => msg.id == message.id)) {
          print('Adding new message from server: ${message.id}');
          updatedMessages.add(message);
        }
        print('Emitting MessagesLoaded with ${updatedMessages.length} messages');
        emit(MessagesLoaded(updatedMessages));
        if (message.receiverId == currentUserId && message.status != 'read') {
          _repository.markAsRead(message.id);
        }else {
          print('Message not for current chat: sender $currentUserId, receiver $currentReceiverId');
        }
      }else{
        print('Received new message but state is not MessagesLoaded');
      }
      if (state is ConversationsLoaded) {
        final currentConversations = (state as ConversationsLoaded).conversations;
        final updatedConversations = currentConversations.map((conv) {
          if (conv.user.id == (message.senderId == currentUserId ? message.receiverId : message.senderId)) {
            return Conversation(user: conv.user, lastMessage: message);
          }
          return conv;
        }).toList();
        print('Emitting ConversationsLoaded with updated last message');
        emit(ConversationsLoaded(updatedConversations));
      }

    }
  }

  void setCurrentUser(String userId, String userType) {
    currentUserId = userId;
    currentUserType = userType;
  }

  @override
  Future<void> close() {
    _activityTimer?.cancel();
    _repository.dispose();
    return super.close();
  }
}