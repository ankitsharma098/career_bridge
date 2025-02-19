import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../data/models/chat model/chat_model.dart';
import '../bloc/chat_bloc.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final String userId;
  final String userType="employer";
  const ConversationsScreen({super.key, required this.userId});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
        context.read<ChatBloc>().setCurrentUser(
          widget.userId,
          widget.userType,
        );

    context.read<ChatBloc>().add(LoadConversations());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ChatBloc>().add(LoadConversations()),
          ),
        ],
      ),
      body: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          if (state is ChatLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ConversationsLoaded) {
            if (state.conversations.isEmpty) {
              return const Center(child: Text('No conversations yet'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChatBloc>().add(LoadConversations());
              },
              child: ListView.separated(
                itemCount: state.conversations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final conversation = state.conversations[index];
                  return _buildConversationTile(conversation);
                },
              ),
            );
          }

          if (state is ChatError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${state.message}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ChatBloc>().add(LoadConversations()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('No conversations yet'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        child: const Icon(Icons.message),
        tooltip: 'New message',
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final hasUnreadMessages = conversation.lastMessage.status != 'read' &&
        conversation.lastMessage.receiverId == context.read<ChatBloc>().currentUserId;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: conversation.user.profilePic != null && conversation.user.profilePic!.isNotEmpty
            ? NetworkImage(conversation.user.profilePic!)
            : null,
        child: conversation.user.profilePic == null || conversation.user.profilePic!.isEmpty
            ? Text(conversation.user.name[0].toUpperCase())
            : null,
      ),
      title: Text(
        conversation.user.name,
        style: TextStyle(
          fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            timeago.format(conversation.lastMessage.timestamp),
            style: TextStyle(
              fontSize: 12,
              color: hasUnreadMessages ? Theme.of(context).primaryColor : Colors.grey,
              fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
      trailing: hasUnreadMessages
          ? Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      )
          : null,
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
        ).then((_) => _loadData()); // Refresh the list when returning
      },
    );
  }

  void _showNewChatDialog(BuildContext context) {
    final TextEditingController recipientIdController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    String selectedRecipientType = 'candidate'; // Default value

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Start New Chat'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Recipient Type:'),
              DropdownButton<String>(
                value: selectedRecipientType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'candidate', child: Text('Candidate')),
                  DropdownMenuItem(value: 'employer', child: Text('Employer')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedRecipientType = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: recipientIdController,
                decoration: const InputDecoration(
                  labelText: 'Recipient ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Initial Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              print("button hit");
              final recipientId = recipientIdController.text.trim();
              final message = messageController.text.trim();


                context.read<ChatBloc>().add(
                  InitiateChat(
                    "67b311aaec4aff87784bc966",
                    "employer",
                    'Ankit sharma',
                    message,
                  ),
                );

                Navigator.pop(dialogContext);

                // Navigate to chat screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                   create: (context) => ChatBloc(),
                    child: ChatScreen(
                      receiverId: recipientId,
                      receiverType: selectedRecipientType,
                      receiverName: 'New Contact',
                    ),
                      ),
                  ),
                ).then((_) => _loadData());
              },
            
            child: const Text('Start Chat'),
          ),
        ],
      ),
    );
  }
}