import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/models/chat model/chat_model.dart';
import '../data service/chat_service.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatRepository _repository;
  final String receiverId;
  final String receiverType;
  final String currentUserId;
  final String currentUserType;
  Timer? _activityTimer;

  ChatBloc(this._repository, this.receiverId, this.receiverType, this.currentUserId, this.currentUserType)
      : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<UploadMedia>(_onUploadMedia);
    on<DeleteMessage>(_onDeleteMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<ReadReceiptReceived>(_onReadReceiptReceived);
    //on<MessageSentConfirmed>(_onMessageSentConfirmed);
    on<FetchLastSeen>(_onFetchLastSeen);

    _repository.addNewMessageListener(_handleNewMessage);
    _repository.addReadReceiptListener(_handleReadReceipt);
    _activityTimer = Timer.periodic(const Duration(minutes: 1), (_) => _repository.updateUserActivity());
  }

  void _handleNewMessage(Message message) {
    print('ChatBloc - New message callback: $message');
    bool isRelevant = (message.senderId == currentUserId && message.receiverId == receiverId) ||
        (message.senderId == receiverId && message.receiverId == currentUserId);
    if (isRelevant) {
      print('ChatBloc - Adding NewMessageReceived event for: $message');

      add(NewMessageReceived(message));
    } else {
      print('ChatBloc - Message ignored (not for this chat): $message');
    }
  }
  void _handleReadReceipt(ReadReceipt readReceipt) {
    print('ChatBloc - Read receipt callback: $readReceipt');
    add(ReadReceiptReceived(readReceipt));
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getMessages(receiverId, receiverType);

      print("Message $messages");
      final lastSeen = await _repository.getLastSeen(receiverId, receiverType); //
      for (var message in messages) {
        if (message.status != 'read' && message.receiverId == currentUserId) {
          _repository.markAsRead(message.id);
        }
      }
      emit(MessagesLoaded(messages, lastSeen: lastSeen));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onFetchLastSeen(FetchLastSeen event, Emitter<ChatState> emit) async {
    try {
      final lastSeen = await _repository.getLastSeen(receiverId, receiverType);

      print("last seen $lastSeen");
      if (state is MessagesLoaded) {
        final currentState = state as MessagesLoaded;
        emit(MessagesLoaded(currentState.messages, lastSeen: lastSeen));
      } else {
        emit(MessagesLoaded([], lastSeen: lastSeen));
      }
    } catch (e) {
      emit(ChatError('Failed to fetch last seen: $e'));
    }
  }
  Future<void> _onSendMessage(SendMessage event, Emitter<ChatState> emit) async {
    List<Message> currentMessages = [];
    if (state is MessagesLoaded) {
      currentMessages = (state as MessagesLoaded).messages;
    } else {
      emit(ChatLoading());
      currentMessages = await _repository.getMessages(receiverId, receiverType);
      emit(MessagesLoaded(currentMessages));
    }

    final newMessage = Message(
      id: '', // Placeholder ID, will be replaced by server
      senderId: currentUserId,
      senderType: currentUserType,
      receiverId: receiverId,
      receiverType: receiverType,
      content: event.content,
      mediaUrl: event.mediaUrl?['url'] ?? '',
      publicId: event.mediaUrl?['publicId'] ?? '',
      status: 'sending',
      timestamp: DateTime.now().toIso8601String(),
    );

    // Optimistically add the message
    final updatedMessages = [...currentMessages, newMessage];
    emit(MessagesLoaded(updatedMessages));

    try {
      final sentMessage = await _repository.sendMessage(
        receiverId,
        receiverType,
        currentUserId,
        currentUserType,
        event.content,
        media: event.mediaUrl,
      );

      // Replace the placeholder with the server-confirmed message
      final finalMessages = updatedMessages.map((msg) {
        if (msg.timestamp == newMessage.timestamp && msg.content == newMessage.content) {
          return sentMessage;
        }
        return msg;
      }).toList();
      emit(MessagesLoaded(finalMessages));
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
      emit(MessagesLoaded(currentMessages));
    }
  }

  Future<void> _onDeleteMessage(DeleteMessage event, Emitter<ChatState> emit) async {
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final updatedMessages = currentMessages.where((msg) => msg.id != event.messageId).toList();
      emit(MessagesLoaded(updatedMessages)); // Optimistic deletion
      try {
        await _repository.deleteMessage(event.messageId);
      } catch (e) {
        emit(ChatError('Failed to delete message: $e'));
        emit(MessagesLoaded(currentMessages)); // Revert on failure
      }
    }
  }
  void _onMessageSentConfirmed(MessageSentConfirmed event, Emitter<ChatState> emit) {
    print("messave sent confirmed");
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final tempMessageIndex = currentMessages.indexWhere((m) => m.id.startsWith('temp_'));
      if (tempMessageIndex != -1) {
        final updatedMessages = List<Message>.from(currentMessages);
        updatedMessages[tempMessageIndex] = updatedMessages[tempMessageIndex].copyWith(id: event.message.id);
        emit(MessagesLoaded(updatedMessages));
      }
    }
  }

  Future<void> _onUploadMedia(UploadMedia event, Emitter<ChatState> emit) async {
    List<Message> currentMessages = [];
    if (state is MessagesLoaded) {
      currentMessages = (state as MessagesLoaded).messages;
    } else {
      emit(ChatLoading());
      currentMessages = await _repository.getMessages(receiverId, receiverType);
      emit(MessagesLoaded(currentMessages));
    }

    emit(MediaUploading());
    try {
      final mediaData = await _repository.uploadMedia(event.file);
      emit(MediaUploaded(mediaData['url']!, mediaData['publicId']!));
      // Do not send the message here; just keep the current messages
      emit(MessagesLoaded(currentMessages));
    } catch (e) {
      emit(ChatError('Failed to upload media: $e'));
      emit(MessagesLoaded(currentMessages));
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    _repository.markAsRead(event.messageId);
  }

  void _onNewMessageReceived(NewMessageReceived event, Emitter<ChatState> emit) {
    print('ChatBloc - Handling NewMessageReceived: ${event.message}');
    List<Message> currentMessages = state is MessagesLoaded ? (state as MessagesLoaded).messages : [];
    final message = event.message;
    final updatedMessages = [...currentMessages, message];
    print('ChatBloc - Adding new message: $message, Updated messages: $updatedMessages');
    emit(MessagesLoaded(updatedMessages));

    if (message.receiverId == currentUserId && message.status != 'read') {
      print('ChatBloc - Marking message as read: ${message.id}');
      _repository.markAsRead(message.id);
    }
  }
  void _onReadReceiptReceived(ReadReceiptReceived event, Emitter<ChatState> emit) {
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final updatedMessages = currentMessages.map((msg) {
        if (msg.id == event.readReceipt.messageId) {
          return msg.copyWith(status: 'read', readAt: event.readReceipt.readAt.toIso8601String());
        }
        return msg;
      }).toList();
      emit(MessagesLoaded(updatedMessages));
    }
  }

  @override
  Future<void> close() {
    _activityTimer?.cancel(); // Clean up timer
    _repository.removeNewMessageListener(_handleNewMessage);
    _repository.removeReadReceiptListener(_handleReadReceipt);
    return super.close();
  }
}