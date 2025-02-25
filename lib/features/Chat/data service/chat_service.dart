// chat_repository.dart
import 'dart:io';
import 'package:android/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
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
            .setAuth({'token': token})
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(1000)
            .build(),
      );

      _socket!.onConnect((_) {
        print('Socket connected with ID: ${_socket!.id}');
        _socket!.emit('user_connect');

        _socket!.on('new_message', (data) {
          try {
            print('Raw new_message data: $data');
            Map<String, dynamic> rawMessage = Map<String, dynamic>.from(data);
            final mappedMessage = {
              '_id': rawMessage['messageId']?.toString() ?? '',
              'sender': rawMessage['senderId']?.toString() ?? '',
              'senderType': rawMessage['senderType'] ?? '',
              'receiver': rawMessage['receiverId']?.toString() ?? '',
              'receiverType': rawMessage['receiverType'] ?? '',
              'content': rawMessage['content'] ?? '',
              'mediaUrl': rawMessage['mediaUrl'],
              'publicId': rawMessage['publicId'] ?? '',
              'status': rawMessage['status'] ?? 'sent',
              'timestamp': rawMessage['timestamp'] ?? DateTime.now().toIso8601String(),
              'deliveredAt': rawMessage['deliveredAt'],
              'readAt': rawMessage['readAt'],
            };
            Message message = Message.fromJson(mappedMessage);
            print('Parsed message: ${message.toJson()}');
            _newMessageCallback?.call(message);
          } catch (e) {
            print('Error parsing new message: $e');
          }
        });

        _socket!.on('read_receipt', (data) {
          try {
            final messageId = data['messageId'].toString();
            final readAt = DateTime.parse(data['readAt'].toString());
            _readReceiptCallback?.call(messageId, readAt);
          } catch (e) {
            print('Error handling read receipt: $e');
          }
        });
      });

      _socket!.onReconnect((_) => print('Socket reconnected with ID: ${_socket!.id}'));
      _socket!.onConnectError((data) => print('Connect error: $data'));
      _socket!.onError((data) => print('Socket error: $data'));
      _socket!.onDisconnect((_) => print('Socket disconnected'));
      _socket!.onAny((event, data) => print('Socket event received: $event, data: $data'));

      _socket!.connect();
      print('Attempting socket connection...');
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  Function(Message)? _newMessageCallback;
  Function(String, DateTime)? _readReceiptCallback;

  void onNewMessage(Function(Message) callback) {
    _newMessageCallback = callback;
  }

  void onReadReceipt(Function(String, DateTime) callback) {
    _readReceiptCallback = callback;
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



  Future<Map<String, String>> uploadMedia(File file) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      print('Uploading file: ${file.path}, MIME type: $mimeType');

      const allowedMimes = [
        'image/jpeg',
        'image/png',
        'image/gif',
        'application/pdf',
        'application/msword',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      ];
      if (!allowedMimes.contains(mimeType)) {
        throw Exception('Unsupported file type: $mimeType. Allowed types: jpg, png, gif, pdf, doc, docx');
      }

      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          file.path,
          contentType: MediaType.parse(mimeType), // Explicitly set MIME type
        ),
      });

      final response = await dio.post('$_baseUrl/upload',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      print("Url ====${ response.data['url']}");

      return {
        'url': response.data['url'],
        'publicId': response.data['publicId'],
      };
    } on DioException catch (e) {
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

  Future<void> initiateChat(String receiverId, String receiverType, String initialMessage,
      {Map<String, String>? media}) async {
    try {
      print("Initiating chat...");
      await sendMessage(receiverId, receiverType, initialMessage, media: media);
      print("Message sent successfully");
    } catch (e) {
      print('Error initiating chat: $e');
      throw Exception('Failed to initiate chat: ${e.toString()}');
    }
  }

  Future<void> sendMessage(String receiverId, String receiverType, String content, {Map<String, String>? media}) async {

      if (_socket == null || !_socket!.connected) {
        print('Socket not connected, attempting reconnect...');
        _socket?.connect();
        throw Exception("Socket not connected");
      }


    print("Sending message via socket to $receiverId ($receiverType): $content");
      _socket!.emit('send_message', {
        'receiverId': receiverId,
        'receiverType': receiverType,
        'content': content,
        if (media != null) 'mediaUrl': media, // Pass both url and publicId
      });
  }


  Future<bool> deleteMessage(String messageId) async {
    try {
      print("Message delete $messageId");
      final token = await HiveUtils.getAccessToken();
      final response = await dio.delete(
        '$_baseUrl/$messageId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {

        bool success = response.data["success"] ?? false;
        return success;
        throw Exception('Failed to delete message');
      }else{
        throw Exception('Failed to delete message');
      }
    } on DioException catch (e) {
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


  void markAsRead(String messageId) {
    if (_socket == null || !_socket!.connected) {
      print("Socket not connected. Unable to mark message as read.");
      return;
    }

    _socket!.emit('read_receipt', {
      'messageId': messageId,
    });
  }

  // void onNewMessage(Function(Message) callback) {
  //   if (_socket == null) return;
  //   _socket!.on('new_message', (data) {
  //     try {
  //       print('Raw new_message data: $data');
  //       final message = Message.fromJson({
  //         'id': data['messageId'].toString(),
  //         'senderId': data['senderId'],
  //         'senderType': data['senderType'],
  //         'receiverId': data['receiverId'],
  //         'receiverType': data['receiverType'],
  //         'content': data['content'],
  //         'mediaUrl': data['mediaUrl'],
  //         'status': data['status'],
  //         'timestamp': data['timestamp'],
  //       });
  //       callback(message);
  //     } catch (e) {
  //       print('Error parsing new message: $e');
  //     }
  //   });
  // }

  // void onReadReceipt(Function(String, DateTime) callback) {
  //   if (_socket == null) {
  //     return;
  //   }
  //
  //   _socket!.on('read_receipt', (data) {
  //     try {
  //       final messageId = data['messageId'].toString();
  //       final readAt = DateTime.parse(data['readAt'].toString());
  //       callback(messageId, readAt);
  //     } catch (e) {
  //       print('Error handling read receipt: $e');
  //     }
  //   });
  // }

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