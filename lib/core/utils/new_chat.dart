// You can put this in a utility file or create a widget
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/Chat/bloc/chat_bloc.dart';
import '../../features/Chat/ui/chat.dart';
import '../../features/Chat/ui/chat_screen.dart';

void startNewChat(BuildContext context, {
  required String receiverId,
  required String receiverType,
  required String receiverName,
  String? initialMessage,
}) {

  if (initialMessage != null && initialMessage.isNotEmpty) {
    print("initiate event");
    // If there's an initial message, send it first
    BlocProvider.of<ChatBloc>(context).add(
      InitiateChat(
        receiverId,
        receiverType,
        receiverName,
        initialMessage,
      ),
    );
  }else{
    print("somethin emply");
  }

  // Navigate to chat screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChatScreen(
        receiverId: receiverId,
        receiverType: receiverType,
        receiverName: receiverName,
      ),
    ),
  );
}