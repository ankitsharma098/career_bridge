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

  ChatBloc() : super(ChatInitial()) {

    on<LoadConversations>(_onLoadConversations);
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);

    on<UploadMedia>(_onUploadMedia);
    on<InitiateChat>(_onInitiateChat);

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


  }
    // Setup message listener

//   void _setupMessageListeners() {
//   // Setup message listener
//   _repository.onNewMessage(_handleNewMessage);
//
//   // Setup read receipt listener
//   _repository.onReadReceipt((messageId, readAt) {
//     // Update message status if needed
//     if (state is MessagesLoaded) {
//       final currentMessages = (state as MessagesLoaded).messages;
//       final updatedMessages = currentMessages.map((msg) {
//         if (msg.id == messageId) {
//           return Message(
//             id: msg.id,
//             senderId: msg.senderId,
//             senderType: msg.senderType,
//             receiverId: msg.receiverId,
//             receiverType: msg.receiverType,
//             content: msg.content,
//             mediaUrl: msg.mediaUrl,
//             status: 'read',
//             timestamp: msg.timestamp,
//             readAt: readAt.toIso8601String(),
//             deliveredAt: msg.deliveredAt,
//           );
//         }
//         return msg;
//       }).toList();
//
//       emit(MessagesLoaded(updatedMessages));
//     }
//   });
// }

  // void _handleNewMessage(Message message) {
  //   add(NewMessageReceived(message));
  // }


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
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;

      // Optimistically update UI with a temporary message
      final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}'; // Unique temp ID
      final newMessage = Message(
        id: tempId, // Mark as temporary
        senderId: currentUserId ?? '',
        senderType: currentUserType ?? '',
        receiverId: event.receiverId,
        receiverType: event.receiverType,
        content: event.content,
        mediaUrl: event.mediaUrl,
        status: 'sent',
        timestamp: DateTime.now().toIso8601String(),
      );

      emit(MessagesLoaded([...currentMessages, newMessage]));
      print('Added temporary message with ID: $tempId');

      // Send actual message
      await _repository.sendMessage(
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
          updatedMessages.add(message);
        }
        print('Emitting MessagesLoaded with ${updatedMessages.length} messages');
        emit(MessagesLoaded(updatedMessages));
        if (message.receiverId == currentUserId && message.status != 'read') {
          _repository.markAsRead(message.id);
        }else {
          print('Message not for current chat: sender $currentUserId, receiver $currentReceiverId');
        }
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
    _repository.dispose();
    return super.close();
  }
}