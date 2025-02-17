// chat_repository.dart
import 'dart:io';
import 'package:android/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../data/models/chat model/chat_model.dart';

class ChatRepository {
  final dio= Dio();
  final IO.Socket socket = IO.io('http://192.168.31.128:8000');
  String baseUrl="http://192.168.31.128:8000";

  Future<List<Conversation>> getConversations() async {
    try {
      final response = await dio.get('${baseUrl}/conversations');
      return (response.data as List)
          .map((json) => Conversation.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Message>> getMessages(String receiverId, String receiverType, {String? before, int? limit}) async {
    try {
      final response = await dio.get('${baseUrl}/messages/$receiverId/$receiverType',
        queryParameters: {
          if (before != null) 'before': before,
          if (limit != null) 'limit': limit,
        },
      );
      return (response.data as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to load messages');
    }
  }

  Future<String> uploadMedia(File file) async {
    try {
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(file.path),
      });

      final response = await dio.post('${baseUrl}/messages/upload', data: formData);
      return response.data['url'];
    } catch (e) {
      throw Exception('Failed to upload media');
    }
  }

  void sendMessage(String receiverId, String receiverType, String content, {String? mediaUrl}) {
    socket.emit('send_message', {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
  }

  void markAsRead(String messageId) {
    socket.emit('read_receipt', {
      'messageId': messageId,
    });
  }

  void onNewMessage(Function(Message) callback) {
    socket.on('new_message', (data) {
      callback(Message.fromJson(data));
    });
  }

  void onReadReceipt(Function(String, DateTime) callback) {
    socket.on('read_receipt', (data) {
      callback(data['messageId'], DateTime.parse(data['readAt']));
    });
  }

  void dispose() {
    socket.disconnect();
  }
}