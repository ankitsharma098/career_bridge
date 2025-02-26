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
  StreamSubscription<Message>? _newMessageSubscription;
  StreamSubscription<ReadReceipt>? _readReceiptSubscription;

  ChatBloc(this._repository, this.receiverId, this.receiverType, this.currentUserId, this.currentUserType)
      : super(ChatInitial()) {
    on<LoadMessages>(_onLoadMessages);
    on<SendMessage>(_onSendMessage);
    on<UploadMedia>(_onUploadMedia);
    on<DeleteMessage>(_onDeleteMessage);
    on<MarkAsRead>(_onMarkAsRead);
    on<NewMessageReceived>(_onNewMessageReceived);
    on<ReadReceiptReceived>(_onReadReceiptReceived);
    on<MessageSentConfirmed>(_onMessageSentConfirmed);
    // Listen to new messages for this conversation
    _newMessageSubscription = _repository.newMessageStream.listen((message) {
      if ((message.senderId == currentUserId && message.receiverId == receiverId) ||
          (message.senderId == receiverId && message.receiverId == currentUserId)) {
        add(NewMessageReceived(message));
      }
    });

    // Listen to read receipts for this conversation
    _readReceiptSubscription = _repository.readReceiptStream.listen((readReceipt) {
      add(ReadReceiptReceived(readReceipt));
    });
  }

  Future<void> _onLoadMessages(LoadMessages event, Emitter<ChatState> emit) async {
    emit(ChatLoading());
    try {
      final messages = await _repository.getMessages(receiverId, receiverType);
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
    List<Message> currentMessages = [];
    if (state is MessagesLoaded) {
      currentMessages = (state as MessagesLoaded).messages;
    } else {
      emit(ChatLoading());
      currentMessages = await _repository.getMessages(receiverId, receiverType);
      emit(MessagesLoaded(currentMessages));
    }

    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final newMessage = Message(
      id: tempId,
      senderId: currentUserId,
      senderType: currentUserType,
      receiverId: receiverId,
      receiverType: receiverType,
      content: event.content,
      mediaUrl: event.mediaUrl?['url'] ?? "",
      publicId: event.mediaUrl?['publicId'] ?? "",
      status: 'sent',
      timestamp: DateTime.now().toIso8601String(),
    );

    emit(MessagesLoaded([...currentMessages, newMessage]));

    try {
      await _repository.sendMessage(receiverId, receiverType,currentUserId,currentUserType, event.content, media: event.mediaUrl);
    } catch (e) {
      emit(ChatError('Failed to send message: $e'));
      emit(MessagesLoaded(currentMessages));
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
    emit(MediaUploading());
    try {
      final mediaData = await _repository.uploadMedia(event.file);
      emit(MediaUploaded(mediaData['url']!, mediaData['publicId']!));
      if (state is MessagesLoaded) {
        final currentMessages = (state as MessagesLoaded).messages;
        emit(MessagesLoaded(currentMessages));
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
      if (event.messageId.startsWith('temp_')) {
        // Remove locally and mark for server deletion
        final updatedMessages = currentMessages.where((msg) => msg.id != event.messageId).toList();
        emit(MessagesLoaded(updatedMessages));
        await _repository.deleteMessage(event.messageId); // Mark for deletion
      } else {
        await _repository.deleteMessage(event.messageId);
        final updatedMessages = currentMessages.where((msg) => msg.id != event.messageId).toList();
        emit(MessagesLoaded(updatedMessages));
      }
    }
  }

  Future<void> _onMarkAsRead(MarkAsRead event, Emitter<ChatState> emit) async {
    _repository.markAsRead(event.messageId);
  }

  void _onNewMessageReceived(NewMessageReceived event, Emitter<ChatState> emit) {
    if (state is MessagesLoaded) {
      final currentMessages = (state as MessagesLoaded).messages;
      final message = event.message;

      final tempIndex = currentMessages.indexWhere((m) => m.id.startsWith('temp_') && m.content == message.content);
      if (tempIndex != -1) {
        final updatedMessages = List<Message>.from(currentMessages);
        updatedMessages[tempIndex] = message; // Replace with full message details
        emit(MessagesLoaded(updatedMessages));
      } else {
        emit(MessagesLoaded([...currentMessages, message]));
      }

      if (message.receiverId == currentUserId && message.status != 'read') {
        _repository.markAsRead(message.id);
      }
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
    _newMessageSubscription?.cancel();
    _readReceiptSubscription?.cancel();
    return super.close();
  }
}