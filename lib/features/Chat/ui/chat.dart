// conversations_screen.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/models/chat model/chat_model.dart';
import '../bloc/chat_bloc.dart';

class ConversationsScreen extends StatelessWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is ConversationsLoaded) {
            return ListView.builder(
              itemCount: state.conversations.length,
              itemBuilder: (context, index) {
                final conversation = state.conversations[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: conversation.user.profilePic != null
                        ? NetworkImage(conversation.user.profilePic!)
                        : null,
                    child: conversation.user.profilePic == null
                        ? Text(conversation.user.name[0])
                        : null,
                  ),
                  title: Text(conversation.user.name),
                  subtitle: Text(
                    conversation.lastMessage.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    timeago.format(conversation.lastMessage.timestamp),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          receiverId: conversation.user.id,
                          receiverType: conversation.user.type,
                          receiverName: conversation.user.name,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }

          if (state is ChatError) {
            return Center(child: Text(state.message));
          }

          return Center(child: Text('No conversations yet'));
        },
      ),
    );
  }
}

// chat_screen.dart
class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverType;
  final String receiverName;

  ChatScreen({
    required this.receiverId,
    required this.receiverType,
    required this.receiverName,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(
      LoadMessages(widget.receiverId, widget.receiverType),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocBuilder<ChatBloc, ChatState>(
              builder: (context, state) {
                if (state is ChatLoading) {
                  return Center(child: CircularProgressIndicator());
                }

                if (state is MessagesLoaded) {
                  return ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    itemCount: state.messages.length,
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMe = message.senderId == 'current_user_id'; // Replace with actual user ID

                      return MessageBubble(
                        message: message,
                        isMe: isMe,
                      );
                    },
                  );
                }

                return Center(child: Text('No messages yet'));
              },
            ),
          ),
          MessageComposer(
            onSend: (content) {
              context.read<ChatBloc>().add(
                SendMessage(
                  widget.receiverId,
                  widget.receiverType,
                  content,
                ),
              );
              _textController.clear();
            },
            onAttach: () async {
              final file = await FilePicker.platform.pickFiles(
                type: FileType.image,
              );

              if (file != null) {
                context.read<ChatBloc>().add(
                  UploadMedia(File(file.files.single.path!)),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  MessageBubble({
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.mediaUrl != null)
              Image.network(
                message.mediaUrl!,
                height: 200,
                width: 200,
                fit: BoxFit.cover,
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            Text(
              timeago.format(message.timestamp),
              style: TextStyle(
                fontSize: 12,
                color: isMe ? Colors.white70 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageComposer extends StatelessWidget {
  final Function(String) onSend;
  final VoidCallback onAttach;
  final TextEditingController _textController = TextEditingController();

  MessageComposer({
    super.key,
    required this.onSend,
    required this.onAttach,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -2),
            blurRadius: 4,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: onAttach,
              color: Colors.grey[600],
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                final message = _textController.text.trim();
                if (message.isNotEmpty) {
                  onSend(message);
                  _textController.clear();
                }
              },
              color: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}