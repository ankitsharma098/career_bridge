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
  final String socketUrl = "http://192.168.1.6:8000";
  final String _baseUrl = "http://192.168.1.6:8000";

  final _newMessageController = StreamController<Message>.broadcast();
  final _readReceiptController = StreamController<ReadReceipt>.broadcast();
  Stream<Message> get newMessageStream => _newMessageController.stream;
  Stream<ReadReceipt> get readReceiptStream => _readReceiptController.stream;
  final Map<String, Message> _pendingMessages = {};
  final Map<String, bool> _pendingDeletions = {}; // t
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

        // _socket!.on('new_message', (data) {
        //   try {
        //     print('Raw new_message data: $data');
        //     Map<String, dynamic> rawMessage = Map<String, dynamic>.from(data);
        //     final mappedMessage = {
        //       '_id': rawMessage['messageId']?.toString() ?? '',
        //       'sender': rawMessage['senderId']?.toString() ?? '',
        //       'senderType': rawMessage['senderType'] ?? '',
        //       'receiver': rawMessage['receiverId']?.toString() ?? '',
        //       'receiverType': rawMessage['receiverType'] ?? '',
        //       'content': rawMessage['content'] ?? '',
        //       'mediaUrl': rawMessage['mediaUrl'],
        //       'publicId': rawMessage['publicId'] ?? '',
        //       'status': rawMessage['status'] ?? 'sent',
        //       'timestamp': rawMessage['timestamp'] ?? DateTime.now().toIso8601String(),
        //       'deliveredAt': rawMessage['deliveredAt'],
        //       'readAt': rawMessage['readAt'],
        //     };
        //     Message message = Message.fromJson(mappedMessage);
        //     _newMessageController.add(message);
        //   } catch (e) {
        //     print('Error parsing new message: $e');
        //   }
        // });

        _socket!.on('read_receipt', (data) {
          try {
            final messageId = data['messageId'].toString();
            final readAt = DateTime.parse(data['readAt'].toString());
            _readReceiptController.add(ReadReceipt(messageId, readAt));
          } catch (e) {
            print('Error handling read receipt: $e');
          }
        });
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
            final tempId = _pendingMessages.keys.firstWhere(
                  (id) => _pendingMessages[id]!.content == message.content &&
                  _pendingMessages[id]!.receiverId == message.receiverId,
              orElse: () => '',
            );
            if (tempId.isNotEmpty) {
              _pendingMessages.remove(tempId);
              if (_pendingDeletions[tempId] != true) {
                _newMessageController.add(message);
              } else {
                deleteMessage(message.id); // Delete if marked
                _pendingDeletions.remove(tempId);
              }
            } else {
              _newMessageController.add(message); // Incoming message from others
            }
          } catch (e) {
            print('Error parsing new message: $e');
          }
        });

        _socket!.on('message_sent', (data) {
          try {
            final messageId = data['messageId'].toString();
            print('Message sent confirmed with ID: $messageId');
            // Do nothing here; wait for new_message to provide full details
          } catch (e) {
            print('Error handling message_sent: $e');
          }
        });

        // _socket!.on('message_sent', (data) async {
        //   try {
        //     final messageId = data['messageId'].toString();
        //     print('Message sent confirmed with ID: $messageId');
        //     final tempId = _pendingMessages.keys.firstWhere(
        //           (id) => _pendingMessages[id] != null,
        //       orElse: () => '',
        //     );
        //     if (tempId.isNotEmpty) {
        //       final message = _pendingMessages[tempId]!.copyWith(id: messageId);
        //       _pendingMessages.remove(tempId);
        //       if (_pendingDeletions[tempId] == true) {
        //         await deleteMessage(messageId); // Delete on server if marked for deletion
        //         _pendingDeletions.remove(tempId);
        //       } else {
        //         _newMessageController.add(message); // Only add if not deleted
        //       }
        //     }
        //   } catch (e) {
        //     print('Error handling message_sent: $e');
        //   }
        // });
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

  // Function(Message)? _newMessageCallback;
  // Function(String, DateTime)? _readReceiptCallback;
  //
  // void onNewMessage(Function(Message) callback) {
  //   _newMessageCallback = callback;
  // }
  //
  // void onReadReceipt(Function(String, DateTime) callback) {
  //   _readReceiptCallback = callback;
  // }

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

  Future<void> sendMessage(String receiverId,String currentUserId,String currentUserType, String receiverType, String content, {Map<String, String>? media}) async {
    if (_socket == null || !_socket!.connected) {
      print('Socket not connected, attempting reconnect...');
      _socket?.connect();
      throw Exception("Socket not connected");
    }
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final message = Message(
      id: tempId,
      senderId: currentUserId, // Assume this is available or passed in
      senderType: currentUserType, // Assume this is available or passed in
      receiverId: receiverId,
      receiverType: receiverType,
      content: content,
      mediaUrl: media?['url'],
      publicId: media?['publicId'] ?? "",
      status: 'sent',
      timestamp: DateTime.now().toIso8601String(),
    );
    _pendingMessages[tempId] = message;
    _socket!.emit('send_message', {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      if (media != null) 'mediaUrl': media,
    });
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
        '$_baseUrl/$messageId',
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
    _socket?.disconnect();
    _socket?.dispose();
    _newMessageController.close();
    _readReceiptController.close();
    _pendingMessages.clear();
    _pendingDeletions.clear();
  }
}