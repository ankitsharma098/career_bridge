import 'package:android/core/utils/customErrorUtils.dart';
import 'package:android/features/Stories/create_story_bloc/create_story_bloc.dart';
import 'package:android/features/Stories/ui/shimmers/all_story_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/image_viewer.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../../data/models/story/story_model.dart';
import '../bloc/story_bloc.dart';
import 'create_story.dart';

class StoriesScreen extends StatefulWidget {
  const StoriesScreen({super.key});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    BlocProvider.of<StoryBloc>(context).add(FetchStoriesEvent());
    scrollController.addListener(_onScroll);
    super.initState();
  }
  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll(){
    final state =context.read<StoryBloc>().state;
    if(_isBottom && state is StoryLoadedState && !state.hasReachedMax){
      BlocProvider.of<StoryBloc>(context).add(LoadMoreStories());
    }

  }
  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    // Load more when user has scrolled 80% of the list
    return currentScroll >= (maxScroll * 0.8);
  }
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery
        .of(context)
        .size;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenSize.width * 0.04,
          horizontal: screenSize.width * 0.02),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, screenSize),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(
            child: _buildStoryList(screenSize),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Posted Story',
          style: Theme
              .of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(
            fontSize: screenSize.width * 0.06,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add_circle),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(
              create: (context) => StoryCreationBloc(),
              child: CreateStoryScreen(onStoryCreated: (StoryModel ) {  },),
            ),));
          },
          iconSize: screenSize.width * 0.08,
        ),
      ],
    );
  }

  Widget _buildStoryList(Size screenSize) {
    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state is StoryErrorState) {
          return SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
      },
      builder: (context, state) {
        if (state is StoryLoadingState) {
          return StoriesShimmerScreen();
        }

        if (state is StoryLoadedState) {
          if (state.stories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_off_outlined,
                    size: screenSize.width * 0.15,
                    color: Colors.grey,
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    'No Stories found',
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    'Click the + button above to post your first Story',
                    style: Theme
                        .of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              BlocProvider.of<StoryBloc>(context).add(FetchStoriesEvent());
            },
            child: ListView.builder(
              controller: scrollController,
              itemCount: state.stories.length + (state.hasReachedMax ? 0 : 1),
              itemBuilder: (context, index) {
                if (index >= state.stories.length) {
                  if (!state.hasReachedMax && state.stories.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: LoadingAnimationWidget.progressiveDots(
                            color: Theme
                                .of(context)
                                .brightness == Brightness.dark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                            size: 20
                        ),
                      ),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }
                final story = state.stories[index];
                return _buildStoryCard(story, screenSize, context);
              },
            ),
          );
        }

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: screenSize.width * 0.15,
                color: Colors.grey,
              ),
              SizedBox(height: screenSize.height * 0.02),
              Text(
                'Something went wrong',
                style: Theme
                    .of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                'Please try again later',
                style: Theme
                    .of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoryCard(StoryModel story, Size screenSize,
      BuildContext context) {
    Widget _buildMediaCarousel() {
      if (story.mediaUrls.isEmpty) return SizedBox.shrink();

      // Extract URLs for full-screen viewer
      final mediaUrls = story.mediaUrls.map((media) => media.url).toList();

      return story.mediaUrls.length > 1
          ? SizedBox(
              height: screenSize.height * 0.25,
              child: PageView.builder(
                itemCount: story.mediaUrls.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => FullScreenImageViewer(
                            imageUrls: mediaUrls,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                    child: Image.network(
                      story.mediaUrls[index].url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error);
                      },
                    ),
                  );
                },
              ),
            )
          : GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FullScreenImageViewer(
                      imageUrls: mediaUrls,
                    ),
                  ),
                );
              },
              child: SizedBox(
                height: screenSize.height * 0.25,
                width: double.infinity,
                child: Image.network(
                  story.mediaUrls.first.url,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                ),
              ),
      );
    }
    final date = DateTime.parse(story.createdAt);
    return Card(
     // margin: EdgeInsets.all(screenSize.width * 0.03),
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
              style: Theme
                  .of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Media (if available)
          if (story.mediaUrls.isNotEmpty)
            _buildMediaCarousel(),

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
                      backgroundColor: AppColors.lightDeepPurple.withOpacity(
                          0.1),
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
                interactionButton(
                  icon: story.isLiked ? Icons.favorite : Icons.favorite_border,
                  count: story.likesCount,
                  color: story.isLiked ? Colors.red : null,
                  onTap: () {
                    // => context.read<StoriesBloc>().add(LikeStory(story.id))
                  },
                ),
                interactionButton(
                  icon: Icons.comment_outlined,
                  count: story.commentsCount, onTap: () {},
                ),
                interactionButton(
                  icon: Icons.remove_red_eye_outlined,
                  count: story.views,
                ),
                interactionButton(
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

  Widget interactionButton({
    required IconData icon,
    required int count,
    Color? color,
    VoidCallback? onTap,
  }) {
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


