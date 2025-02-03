import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/story/story_model.dart';
import '../bloc/story_bloc.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  @override
  void initState() {
    BlocProvider.of<StoryBloc>(context).add(FetchStoriesEvent());
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: BlocBuilder<StoryBloc, StoryState>(
        builder: (context, state) {
          if (state is StoryLoadingState) {
            return Center(child: CircularProgressIndicator());
          }

          if (state is StoryErrorState) {
            return Center(child: Text(state.error));
          }

          if (state is StoryLoadedState) {
            return ListView.builder(
              itemCount: state.stories.length,
              itemBuilder: (context, index) {
                final story = state.stories[index];
                return StoryCard(story: story);
              },
            );
          }

          return SizedBox();
        },
      ),
    );
  }
}

// lib/features/stories/widgets/story_card.dart
class StoryCard extends StatelessWidget {
  final StoryModel story;

  const StoryCard({Key? key, required this.story}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final date = DateTime.parse(story.createdAt);
    return Card(
      margin: EdgeInsets.all(screenSize.width * 0.03),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(story.hostDetails.profilePic),
            ),
            title: Text(story.hostDetails.name),
            subtitle: Text(
              DateFormat('MMM dd, yyyy').format(date),
              style: TextStyle(color: Colors.grey),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.04,
              vertical: screenSize.height * 0.01,
            ),
            child: Text(
              story.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Media (if available)
          if (story.mediaUrls.isNotEmpty)
            Container(
              height: screenSize.height * 0.25,
              width: double.infinity,
              child: Image.network(
                story.mediaUrls.first.url,
                fit: BoxFit.cover,
              ),
            ),

          // Content Preview
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Text(
              story.content,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Tags
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.04),
            child: Row(
              children: story.tags.map((tag) =>
                  Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('#$tag'),
                      backgroundColor: AppColors.lightDeepPurple.withOpacity(0.1),
                    ),
                  ),
              ).toList(),
            ),
          ),

          // Interaction Buttons
          Padding(
            padding: EdgeInsets.all(screenSize.width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _InteractionButton(
                  icon: story.isLiked ? Icons.favorite : Icons.favorite_border,
                  count: story.likesCount,
                  color: story.isLiked ? Colors.red : null,
                  onTap: () {
                   // => context.read<StoriesBloc>().add(LikeStory(story.id))
                  },
                ),
                _InteractionButton(
                  icon: Icons.comment_outlined,
                  count: story.commentsCount,
                ),
                _InteractionButton(
                  icon: Icons.remove_red_eye_outlined,
                  count: story.views,
                ),
                _InteractionButton(
                  icon: Icons.share_outlined,
                  count: story.sharesCount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Widget for Interaction Buttons
class _InteractionButton extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color? color;
  final VoidCallback? onTap;

  const _InteractionButton({
    required this.icon,
    required this.count,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          SizedBox(width: 4),
          Text('$count'),
        ],
      ),
    );
  }
}