import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../data/models/chat model/chat_model.dart';
import '../bloc/chat_bloc.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverType;
  final String receiverName;
  final String? profilePic;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverType,
    required this.receiverName,
    required this.profilePic,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _uploadedMediaUrl;
  String? _uploadedPublicId;

  @override
  void initState() {
    super.initState();
    context.read<ChatBloc>().add(LoadMessages());
    context.read<ChatBloc>().add(FetchLastSeen());

  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: widget.profilePic != null &&widget.profilePic!.isNotEmpty
                    ? NetworkImage(widget.profilePic!)
                    : null,
                child: widget.profilePic == null || widget.profilePic!.isEmpty
                    ? Text(widget.receiverName[0].toUpperCase())
                    : null,
              ),
              SizedBox(width: size.width*0.05,),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.receiverName),
                  BlocBuilder<ChatBloc, ChatState>(
                    builder: (context, state) {
                      if (state is MessagesLoaded && state.lastSeen != null) {
                        return Text(
                          'Last seen: ${timeago.format(state.lastSeen!)}',

                          style: const TextStyle(fontSize: 12),
                        );
                      }
                      return const Text('Last seen: TBD', style: TextStyle(fontSize: 12));
                    },
                  ),
                ],
              ),
            ],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<ChatBloc>().add(LoadMessages()),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_uploadedMediaUrl != null) _buildMediaPreview(), // Show preview if media is uploaded
            Expanded(
              child: BlocConsumer<ChatBloc, ChatState>(
                listener: (context, state) {
                  print('Bloc state changed: $state');
                  if (state is MessagesLoaded) {
                    print('Messages loaded, scrolling to bottom: ${state.messages}');
                    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
                  } else if (state is ChatError) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${state.message}')));
                  } else if (state is MediaUploaded) {
                    setState(() {
                      _uploadedMediaUrl = state.mediaUrl;
                      _uploadedPublicId = state.publicId;
                    });
                  }
                },
                builder: (context, state) {
                  print('Building UI with state: $state');
                  if (state is ChatLoading || state is MediaUploading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is MessagesLoaded) {
                    return state.messages.isEmpty
                        ? const Center(child: Text('No messages yet'))
                        : _buildMessageList(state.messages);
                  }
                  if (state is ChatError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Error: ${state.message}'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => context.read<ChatBloc>().add(LoadMessages()),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const Center(child: Text('Start a conversation'));
                },
              ),
            ),
            _buildMessageComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _uploadedMediaUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.image, size: 48),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => setState(() {
              _uploadedMediaUrl = null;
              _uploadedPublicId = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    final currentUserId = context.read<ChatBloc>().currentUserId;

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        final isMe = message.senderId == currentUserId;
        return GestureDetector(
          onLongPress: isMe
              ? () {
            showDialog(
              context: context,
              builder: (dialogContext) => AlertDialog(
                title: const Text('Delete Message'),
                content: const Text('Are you sure you want to delete this message?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ChatBloc>().add(DeleteMessage(message.id));
                      Navigator.pop(dialogContext);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            );
          }
              : null,
          child: Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isMe ? Colors.blue : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (message.mediaUrl != null && message.mediaUrl!.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.mediaUrl!,
                        fit: BoxFit.cover,
                        width: 200,
                        errorBuilder: (_, __, ___) => Container(
                          width: 200,
                          height: 150,
                          color: Colors.grey,
                          child: const Icon(Icons.image, size: 48),
                        ),
                      ),
                    ),
                  if (message.content.isNotEmpty)
                    Text(
                      message.content,
                      style: TextStyle(color: isMe ? Colors.white : Colors.black),
                    ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeago.format(DateTime.parse(message.timestamp)),
                        style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                      ),
                      if (isMe && message.status == 'read') ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done_all, size: 14, color: Colors.white70),
                      ] else if (isMe) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.done, size: 14, color: Colors.white70),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(offset: const Offset(0, -2), blurRadius: 4, color: Colors.black.withOpacity(0.1))],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: () async {
              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'],
              );
              if (result != null) {
                final file = File(result.files.single.path!);
                context.read<ChatBloc>().add(UploadMedia(file));
              }
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(hintText: 'Type a message', border: InputBorder.none),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_textController.text.trim().isNotEmpty || _uploadedMediaUrl != null) {
                context.read<ChatBloc>().add(
                  SendMessage(
                    _textController.text.trim(),
                    mediaUrl: _uploadedMediaUrl != null
                        ? {'url': _uploadedMediaUrl!, 'publicId': _uploadedPublicId!}
                        : null,
                  ),
                );
                _textController.clear();
                setState(() {
                  _uploadedMediaUrl = null;
                  _uploadedPublicId = null;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}