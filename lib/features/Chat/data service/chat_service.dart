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

  bool get isSocketConnected => _socket?.connected ?? false;


  static final ChatRepository _instance = ChatRepository._internal();

  factory ChatRepository() => _instance;

  ChatRepository._internal() {
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

      _setupSocketListeners();
    } catch (e) {
      print('Socket initialization error: $e');
      // Retry connection after delay
      Future.delayed(Duration(seconds: 5), _initializeSocket);
    }
  }
  void _setupSocketListeners() {
    if (_socket == null) {
      print("Cannot setup listeners - socket is null");
      return;
    }

    _socket!.onConnect((_) {
      print('Socket connected');
      _socket!.emit('user_connect');
    });

    _socket!.onConnectError((data) {
      print('Connect error: $data');
      // Retry connection after error
      Future.delayed(Duration(seconds: 5), () {
        if (_socket != null) _socket!.connect();
      });
    });

    _socket!.onError((data) => print('Socket error: $data'));

    _socket!.onDisconnect((_) {
      print('Socket disconnected');
      Future.delayed(Duration(seconds: 2), () {
        if (_socket != null) _socket!.connect();
      });
    });
  }

  Future<List<Conversation>> getConversations() async {
    try {
      print("Getting access token...");
      final token = await HiveUtils.getAccessToken();
      print("Token obtained, making API request to $_baseUrl/conversations");

      final response = await dio.get(
        '$_baseUrl/conversations',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      print("API response status: ${response.statusCode}");
      print("API response data: ${response.data}");

      if (response.data is! List) {
        print("Warning: API response is not a list. Type: ${response.data.runtimeType}");
        // Return empty list if response is not as expected
        return [];
      }

      final conversations = (response.data as List)
          .map((json) => Conversation.fromJson(json))
          .toList();

      print("Parsed ${conversations.length} conversations");
      return conversations;
    } catch (e) {
      print('Error fetching conversations: $e');
      if (e is DioException) {
        print('DioError details: ${e.response?.statusCode}, ${e.response?.data}');
      }
      throw Exception('Failed to load conversations: ${e.toString()}');
    }
  }

  Future<List<Message>> getMessages(String receiverId,
      String receiverType,
      {String? before, int? limit = 50}) async {
    try {
      final token = await HiveUtils.getAccessToken();
      final response = await dio.get(
        '$_baseUrl/messages/$receiverId/$receiverType',
        queryParameters: {
          if (before != null) 'before': before,
          if (limit != null) 'limit': limit,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      return (response.data as List)
          .map((json) => Message.fromJson(json))
          .toList();
    } catch (e) {
      print('Error fetching messages: $e');
      throw Exception('Failed to load messages: ${e.toString()}');
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

  void sendMessage(String receiverId, String receiverType, String content,
      {String? mediaUrl}) {
    if (_socket == null || !_socket!.connected) {
      print("Socket not connected. Unable to send message.");
      return;
    }

    print(
        "Sending message via socket to $receiverId ($receiverType): $content");
    _socket!.emit('send_message', {
      'receiverId': receiverId,
      'receiverType': receiverType,
      'content': content,
      if (mediaUrl != null) 'mediaUrl': mediaUrl,
    });
  }

  Future<void> initiateChat(String receiverId,
      String receiverType,
      String initialMessage,
      {String? mediaUrl}) async {
    try {
      // First send message through socket
      sendMessage(receiverId, receiverType, initialMessage, mediaUrl: mediaUrl);
      print("Conversation initiated");
    } catch (e) {
      print('Error initiating chat: $e');
      throw Exception('Failed to initiate chat: ${e.toString()}');
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

  void onNewMessage(Function(Message) callback) {
    // Check if socket is initialized
    if (_socket == null) {
      print(
          "Socket not initialized yet, will set listener after initialization");
      // Set up a delayed check to add the listener once socket is ready
      Future.delayed(Duration(seconds: 2), () => onNewMessage(callback));
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
      print(
          "Socket not initialized yet, will set read receipt listener after initialization");
      Future.delayed(Duration(seconds: 2), () => onReadReceipt(callback));
      return;
    }

    _socket!.on('read_receipt', (data) {
      try {
        callback(
            data['messageId'],
            DateTime.parse(data['readAt'])
        );
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