import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/colors.dart';
import '../../../data/models/chat model/chat_model.dart';
import '../bloc/chat_bloc.dart';
import '../converstation bloc/conversations_bloc.dart';
import '../data service/chat_service.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final String userId;
  final String userType;
  const ConversationsScreen({super.key, required this.userId, required this.userType});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ConversationsBloc(ChatRepository(), widget.userId, widget.userType)..add(LoadConversations()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Messages'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => context.read<ConversationsBloc>().add(LoadConversations()),
            ),
          ],
        ),
        body: BlocBuilder<ConversationsBloc, ConversationsState>(
          builder: (context, state) {
            if (state is ConversationsLoading) {
              return Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20));
            }
            if (state is ConversationsLoaded) {
              if (state.conversations.isEmpty) {
                return const Center(child: Text('No conversations yet'));
              }
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ConversationsBloc>().add(LoadConversations());
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
            if (state is ConversationsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${state.message}', textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.read<ConversationsBloc>().add(LoadConversations()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return const Center(child: Text('No conversations yet'));
          },
        ),
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => _showNewChatDialog(context),
        //   child: const Icon(Icons.message),
        //   tooltip: 'New message',
        // ),
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final hasUnreadMessages = conversation.lastMessage.status != 'read' && conversation.lastMessage.receiverId == widget.userId;

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
        style: TextStyle(fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              conversation.lastMessage.content,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            timeago.format(DateTime.parse(conversation.lastMessage.timestamp)),
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
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, shape: BoxShape.circle),
      )
          : null,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => ChatBloc(ChatRepository(), conversation.user.id, conversation.user.type, widget.userId, widget.userType),
              child: ChatScreen(
                receiverId: conversation.user.id,
                receiverType: conversation.user.type,
                receiverName: conversation.user.name,
                profilePic: conversation.user.profilePic,
              ),
            ),
          ),
        );
      },
    );
  }

  // void _showNewChatDialog(BuildContext context) {
  //   final recipientIdController = TextEditingController();
  //   final messageController = TextEditingController();
  //   String selectedRecipientType = 'employer';
  //
  //   showDialog(
  //     context: context,
  //     builder: (dialogContext) => AlertDialog(
  //       title: const Text('Start New Chat'),
  //       content: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           DropdownButton<String>(
  //             value: selectedRecipientType,
  //             items: const [
  //               DropdownMenuItem(value: 'candidate', child: Text('Candidate')),
  //               DropdownMenuItem(value: 'employer', child: Text('Employer')),
  //             ],
  //             onChanged: (value) => setState(() => selectedRecipientType = value ?? 'employer'),
  //           ),
  //           TextField(controller: recipientIdController, decoration: const InputDecoration(labelText: 'Recipient ID')),
  //           TextField(controller: messageController, decoration: const InputDecoration(labelText: 'Message')),
  //         ],
  //       ),
  //       actions: [
  //         TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
  //         ElevatedButton(
  //           onPressed: () {
  //             Navigator.pop(dialogContext);
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(
  //                 builder: (context) => BlocProvider(
  //                   create: (context) => ChatBloc(
  //                     ChatRepository(),
  //                     recipientIdController.text,
  //                     selectedRecipientType,
  //                     widget.userId,
  //                     widget.userType,
  //                   )..add(SendMessage(messageController.text)),
  //                   child: ChatScreen(
  //                     receiverId: recipientIdController.text,
  //                     receiverType: selectedRecipientType,
  //                     receiverName: 'Unknown User',
  //                   ),
  //                 ),
  //               ),
  //             );
  //           },
  //           child: const Text('Start'),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}