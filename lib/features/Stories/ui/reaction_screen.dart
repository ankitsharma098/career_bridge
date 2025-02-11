import 'package:android/core/utils/snackBarUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/image_viewer.dart';
import '../../../data/models/story/story_model.dart';
import '../bloc/story_bloc.dart';
import '../create_story_bloc/create_story_bloc.dart';
import '../reaction_bloc/story_reaction_bloc.dart';
import 'edit_story.dart';

class StoryReactionsScreen extends StatefulWidget {
  final StoryModel story;
  final String employerId;

  const StoryReactionsScreen({
    super.key,
    required this.story,
    required this.employerId
  });

  @override
  State<StoryReactionsScreen> createState() => _StoryReactionsScreenState();
}

class _StoryReactionsScreenState extends State<StoryReactionsScreen> {
  final TextEditingController _commentController = TextEditingController();
  String? _editingCommentId;

  void _cancelEditing() {
    setState(() {
      _editingCommentId = null;
      _commentController.clear();
    });
  }
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    print("Reloading");
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar:  AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Story"),
        actions: [
          if (widget.story.hostDetails.id == widget.employerId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _navigateToEdit(),
            ),
        ],
      ),
      body: BlocConsumer<StoryReactionBloc, StoryReactionState>(
        listener: (context, state) {
          if (state is ReactionError) {
          SnackBarUtils.showRedSnackBar(state.message, context);
          if (_editingCommentId != null) {
            _cancelEditing();
          }
          }
        },
        builder: (context, state) {
          if (state is ReactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ReactionLoaded) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildStoryCard(),
                        _buildInteractionBar(state),
                        _buildLikesSection(state.likes),
                        _buildCommentsSection(state.comments,screenSize),
                      ],
                    ),
                  ),
                ),
                _buildCommentInput(),
              ],
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
    );
  }


  Widget _buildStoryCard() {
    final date = DateTime.parse(widget.story.createdAt);
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(widget.story.hostDetails.profilePic),
            ),
            title: Text(
              widget.story.hostDetails.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          if (widget.story.mediaUrls.isNotEmpty)
            _buildMediaSection(),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.story.title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.story.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          _buildTags(),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: PageView.builder(
        itemCount: widget.story.mediaUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _showFullScreenImage(index),
            child: Image.network(
              widget.story.mediaUrls[index].url,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: widget.story.tags.map((tag) =>
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                label: Text('#$tag'),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                labelStyle: TextStyle(color: Theme.of(context).primaryColor),
              ),
            )
        ).toList(),
      ),
    );
  }

  // Update these specific widget methods in your _StoryReactionsScreenState class

  Widget _buildInteractionBar(ReactionLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.likes.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(width: 24),
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 4),
              Text(
                '${state.comments.length}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              widget.story.isLiked ? Icons.favorite : Icons.favorite_border,
              color: widget.story.isLiked ? Theme.of(context).primaryColor : null,
            ),
            onPressed: () {
              context.read<StoryBloc>().add(ToggleStoryLikeEvent(widget.story.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLikesSection(List<Map<String, dynamic>> likes) {
    if (likes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.favorite,
                size: 16,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Liked by',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: likes.length,
              itemBuilder: (context, index) {
                final like = likes[index];
                return Container(
                  width: 65,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(like['user']['profilePic']),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        like['user']['name'],
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(List<Map<String, dynamic>> comments,Size screenSize) {
    if (comments.isEmpty) return const SizedBox.shrink();

    return Container(
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 16,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'Comments',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: comments.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 72,
            ),
            itemBuilder: (context, index) {
              final comment = comments[index];
              final timestamp = DateTime.parse(comment['timestamp']);
              final isEditing = _editingCommentId == comment['_id'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(comment['user']['profilePic']),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                comment['user']['name'] ?? "Name",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: screenSize.width*0.32,
                                child: Text(
                                  DateFormat.yMMMd().add_jm().format(timestamp),
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          if (isEditing)
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _commentController,
                                    decoration: InputDecoration(
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    _submitComment();
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: _cancelEditing,
                                ),
                              ],
                            )
                          else
                            Text(
                              comment['text'] ?? "text",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                        ],
                      ),
                    ),
                    if (!isEditing && comment["user"]["_id"] == widget.employerId)
                     Row(
                       children: [
                         SizedBox(
                           width: screenSize.width*0.1,
                           child: IconButton(
                             icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                             onPressed: () {

                              setState(() {
                                    _commentController.text = comment['text'];
                                    _editingCommentId = comment['_id'];
                                  });

                             },
                           ),
                         ),
                         SizedBox(
                           width: screenSize.width*0.1,
                           child: IconButton(
                             icon: Icon(Icons.delete, color: Colors.red),
                             onPressed: () {
                               context.read<StoryReactionBloc>().add(
                                 CommentDelete(
                                   storyId: widget.story.id,
                                   commentId: comment["_id"],
                                 ),
                               );
                             },
                           ),
                         ),

                       ],
                     )
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

// Remove or hide the bottom input field when editing
  Widget _buildCommentInput() {
    if (_editingCommentId != null) return SizedBox.shrink();

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(
        color: Theme.of(context).dividerColor,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add comment...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: border,
                enabledBorder: border,
                focusedBorder: border.copyWith(
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                filled: true,
                fillColor: Theme.of(context).scaffoldBackgroundColor,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.send_rounded,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: _submitComment,
          ),
        ],
      ),
    );
  }
  void _submitComment() {
    if (_commentController.text.isEmpty) return;

    if (_editingCommentId != null) {
      context.read<StoryReactionBloc>().add(
        PostCommentUpdate(
          storyId: widget.story.id,
          commentId: _editingCommentId!,
          comment: _commentController.text,
        ),
      );
      // Clear editing state
      setState(() {
        _editingCommentId = null;
        _commentController.clear();
      });
    } else {
      context.read<StoryReactionBloc>().add(
        PostCommentEvent(
          widget.story.id,
          _commentController.text,
        ),
      );
      _commentController.clear();
    }
  }




  void _navigateToEdit() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => StoryCreationBloc(),
          child: EditStoryScreen(
            story: widget.story,
            onStoryEdited: (StoryModel story) {
              // Handle story edit
            },
          ),
        ),
      ),
    );
  }

  void _showFullScreenImage(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          imageUrls: widget.story.mediaUrls.map((m) => m.url).toList(),
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}