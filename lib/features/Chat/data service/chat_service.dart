// chat_repository.dart
import 'dart:async';
import 'dart:io';
import 'package:android/core/constants/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../../../core/utils/hiveUtils.dart';
import '../../../data/models/chat model/chat_model.dart';

class ReadReceipt {
  final String messageId;
  final DateTime readAt;
  ReadReceipt(this.messageId, this.readAt);
}

class ChatRepository {
  final dio = Dio();
  IO.Socket? _socket; // Make nullable instead of late
  final String socketUrl = AppConstants.baseUrl;
  // final String _baseUrl = "http://192.168.1.6:8000";


  final List<Function(Message)> _newMessageCallbacks = [];
  final List<Function(ReadReceipt)> _readReceiptCallbacks = [];
  final Map<String, Message> _pendingMessages = {};
  final Map<String, bool> _pendingDeletions = {};

  ChatRepository() {
    _initializeSocket();
  }

  void addNewMessageListener(Function(Message) callback) {
    print('Adding new message listener');
    _newMessageCallbacks.add(callback);
  }

  void removeNewMessageListener(Function(Message) callback) {
    print('Removing new message listener');
    _newMessageCallbacks.remove(callback);
  }

  void addReadReceiptListener(Function(ReadReceipt) callback) {
    print('Adding read receipt listener');
    _readReceiptCallbacks.add(callback);
  }

  void removeReadReceiptListener(Function(ReadReceipt) callback) {
    print('Removing read receipt listener');
    _readReceiptCallbacks.remove(callback);
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
      });

      _socket!.on('read_receipt', (data) {
        try {
          final messageId = data['messageId'].toString();
          final readAt = DateTime.parse(data['readAt'].toString());
          final readReceipt = ReadReceipt(messageId, readAt);
          print('Received read_receipt: $readReceipt');
          for (var callback in _readReceiptCallbacks) {
            callback(readReceipt);
          }
        } catch (e) {
          print('Error handling read receipt: $e');
        }
      });

      _socket!.on('new_message', (data) {
        print('Received new_message event with data: $data');
        try {
          if (data is Map) {
            print('Processing new_message: $data');
            final mappedMessage = {
              '_id': data['messageId']?.toString() ?? '',
              'sender': data['senderId']?.toString() ?? '',
              'senderType': data['senderType'] ?? '',
              'receiver': data['receiverId']?.toString() ?? '',
              'receiverType': data['receiverType'] ?? '',
              'content': data['content'] ?? '',
              'mediaUrl': data['mediaUrl'],
              'publicId': data['publicId'] ?? '',
              'status': data['status'] ?? 'sent',
              'timestamp': data['timestamp'] ?? DateTime.now().toIso8601String(),
              'deliveredAt': data['deliveredAt'],
              'readAt': data['readAt'],
            };
            Message message = Message.fromJson(mappedMessage);
            print('Invoking ${_newMessageCallbacks.length} newMessageCallbacks with: $message');
            for (var callback in _newMessageCallbacks) {
              callback(message);
            }
          } else {
            print('Unexpected data format for new_message: $data');
          }
        } catch (e) {
          print('Error parsing new_message: $e');
        }
      });

      _socket!.onReconnect((_) => print('Socket reconnected with ID: ${_socket!.id}'));
      _socket!.onConnectError((data) => print('Connect error: $data'));
      _socket!.onError((data) => print('Socket error: $data'));
      _socket!.onDisconnect((_) => print('Socket disconnected'));

      _socket!.connect();
      print('Attempting socket connection...');
    } catch (e) {
      print('Socket initialization error: $e');
    }
  }

  Future<List<Conversation>> getConversations() async {
    try {
      final token = await HiveUtils.getAccessToken();

      final response = await dio.get(
        '${AppConstants.baseUrl}/conversations',
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
        '${AppConstants.baseUrl}/$receiverId/$receiverType', // Make sure this matches your backend route
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

// chat_repository.dart

  Future<DateTime?> getLastSeen(String userId, String userType) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final response = await dio.get(
        '${AppConstants.baseUrl}/last-seen/$userId/$userType',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200) {
        return DateTime.parse(response.data['lastSeen']);
      } else if (response.statusCode == 404) {
        return null; // No last seen recorded yet
      } else {
        throw Exception('Failed to fetch last seen');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An error occurred");
      } else {
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    } catch (e) {
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

      final response = await dio.post('${AppConstants.baseUrl}/upload',
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

  Future<void> initiateChat(String receiverId, String receiverType,String currentUserId,String currentUserType,  String initialMessage,
      {Map<String, String>? media}) async {
    try {
      print("Initiating chat...");
      await sendMessage(receiverId,currentUserId, currentUserType,receiverType, initialMessage, media: media);
      print("Message sent successfully");
    } catch (e) {
      print('Error initiating chat: $e');
      throw Exception('Failed to initiate chat: ${e.toString()}');
    }
  }

  Future<Message> sendMessage(
      String receiverId,
      String receiverType,
      String currentUserId,
      String currentUserType,
      String content,
      {Map<String, String>? media}
      ) async {
    if (_socket == null || !_socket!.connected) {
      print('Socket not connected, attempting reconnect...');
      _socket?.connect();
      throw Exception("Socket not connected");
    }

    final messageData = {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      if (media != null) 'mediaUrl': media['url'],
      if (media != null) 'publicId': media['publicId'],
    };

    Completer<Message> completer = Completer();

    _socket!.emitWithAck('send_message', messageData, ack: (data) {
      try {
        final messageId = data['messageId'].toString();
        final message = Message(
          id: messageId,
          senderId: currentUserId,
          senderType: currentUserType,
          receiverId: receiverId,
          receiverType: receiverType,
          content: content,
          mediaUrl: media?['url'],
          publicId: media?['publicId'] ?? "",
          status: 'sent',
          timestamp: DateTime.now().toIso8601String(),
        );
        completer.complete(message);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  Future<bool> deleteMessage(String messageId) async {
    try {
      print("Message delete $messageId");
      if (messageId.startsWith('temp_')) {
        _pendingDeletions[messageId] = true; // Mark for deletion when real ID arrives
        return true;
      }
      final token = await HiveUtils.getAccessToken();
      final response = await dio.delete(
        '${AppConstants.baseUrl}/$messageId',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      if (response.statusCode == 200) {
        bool success = response.data["success"] ?? false;
        return success;
      } else {
        throw Exception('Failed to delete message');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        print("Error message ${e.response?.data["message"]}");
        throw Exception(e.response?.data['message'] ?? "An Error occurred");
      } else {
        print("Error sending request: ${e.message}");
        throw Exception('Network error occurred');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('An unexpected error occurred');
    }
  }
  void markAsRead(String messageId) {
    if (_socket == null || !_socket!.connected) {
      print("Socket not connected.");
      return;
    }
    _socket!.emit('read_receipt', {'messageId': messageId});
  }

  void updateUserActivity() {
    if (_socket != null && _socket!.connected) {
      _socket!.emit('user_activity');
    }
  }

  void dispose() {
    print('Disposing ChatRepository');
    _socket?.disconnect();
    _socket?.dispose();
    _newMessageCallbacks.clear();
    _readReceiptCallbacks.clear();
    _pendingMessages.clear();
    _pendingDeletions.clear();
  }
}