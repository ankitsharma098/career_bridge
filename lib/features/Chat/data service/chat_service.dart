// chat_repository.dart
import 'dart:io';
import 'package:android/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/chat model/chat_model.dart';

class ChatRepository {
  final dio = Dio();
  IO.Socket? _socket; // Make nullable instead of late
  final String socketUrl = "http://192.168.1.6:8000";
  final String _baseUrl = "http://192.168.1.6:8000";


  ChatRepository() {
    _initializeSocket();
  }

  void _initializeSocket() async {
    try {
      final token = await HiveUtils.getAccessToken();
      _socket = IO.io(
        socketUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableForceNew()
            .setAuth({'token': token})
            .build(),
      );

      _socket!.onConnect((_) => print('Socket connected'));
      _socket!.onConnectError((data) => print('Connect error: $data'));
      _socket!.onError((data) => print('Socket error: $data'));
      _socket!.onDisconnect((_) => print('Socket disconnected'));
      _socket?.on("message_sent",(data) {
        print("message sent ${data}");
      }, );
    } catch (e) {
      print('Socket initialization error: $e');
      Future.delayed(Duration(seconds: 5), _initializeSocket);
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final token = await HiveUtils.getAccessToken();

      final response = await dio.get(
        '$_baseUrl/conversations',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      if(response.statusCode==200){
        final conversations = (response.data as List)
            .map((json) => Conversation.fromJson(json))
            .toList();
        return conversations;
      }else {
        return [];
      }
    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }

  Future<List<Message>> getMessages(String receiverId, String receiverType,
      {String? before, int? limit = 50}) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final response = await dio.get(
        '$_baseUrl/$receiverId/$receiverType', // Make sure this matches your backend route
        queryParameters: {
          if (before != null) 'before': before,
          if (limit != null) 'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {

        List<Message> messages=(response.data as List)
            .map((json) => Message.fromJson(json))
            .toList();
        return messages;
      }else {
        return []; //
      }
    }on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      }
      else{
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    }
    catch(e){
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }



  Future<String> uploadMedia(File file) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(file.path),
      });

      final response = await dio.post(
        '$_baseUrl/messages/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return response.data['url'];
    } catch (e) {
      print('Error uploading media: $e');
      throw Exception('Failed to upload media: ${e.toString()}');
    }
  }

  Future<void> initiateChat(String receiverId, String receiverType, String initialMessage,
      {String? mediaUrl}) async {
    try {
      print("Initiating chat...");
      await sendMessage(receiverId, receiverType, initialMessage, mediaUrl: mediaUrl);
      print("Message sent successfully");
    } catch (e) {
      print('Error initiating chat: $e');
      throw Exception('Failed to initiate chat: ${e.toString()}');
    }
  }

  Future<void> sendMessage(String receiverId, String receiverType, String content, {String? mediaUrl}) async {

      if (_socket == null || !_socket!.connected) {
        throw Exception("Failed to establish socket connection");
      }


    print("Sending message via socket to $receiverId ($receiverType): $content");
    _socket!.emit('send_message', {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
  }



  void markAsRead(String messageId) {
    if (_socket == null || !_socket!.connected) {
      print("Socket not connected. Unable to mark message as read.");
      return;
    }

    _socket!.emit('read_receipt', {
      'messageId': messageId,
    });
  }

  void onNewMessage(Function(Message) callback) {
    // Check if socket is initialized
    if (_socket == null) {
      return;
    }

    _socket!.on('new_message', (data) {
      print("New message received: $data");
      try {
        final message = Message.fromJson(data);
        callback(message);
      } catch (e) {
        print('Error parsing message: $e');
      }
    });
  }

  void onReadReceipt(Function(String, DateTime) callback) {
    if (_socket == null) {
      return;
    }

    _socket!.on('read_receipt', (data) {
      try {
        final messageId = data['messageId'].toString();
        final readAt = DateTime.parse(data['readAt'].toString());
        callback(messageId, readAt);
      } catch (e) {
        print('Error handling read receipt: $e');
      }
    });
  }

  // User activity update
  void updateUserActivity() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('user_activity');
    }
  }


  void dispose() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket!.dispose();
    }
  }
}