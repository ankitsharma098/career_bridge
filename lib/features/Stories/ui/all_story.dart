import 'package:android/features/Stories/ui/reaction_screen.dart';
import 'package:android/features/Stories/ui/shimmers/all_story_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/image_viewer.dart';
import '../../../core/utils/snackBarUtils.dart';
import '../../../data/models/story/story_model.dart';
import '../../See profile/bloc/see_profile_bloc.dart';
import '../../See profile/ui/see_profile.dart';
import '../bloc/story_bloc.dart';
import '../create_story_bloc/create_story_bloc.dart';
import '../data/story_api_service.dart';
import '../reaction_bloc/story_reaction_bloc.dart';
import 'create_story.dart';
import 'edit_story.dart';

class StoriesScreen extends StatefulWidget {
  final String currentUserType;
  final String currentUserId;
  const StoriesScreen(
      {super.key, required this.currentUserId, required this.currentUserType});

  @override
  State<StoriesScreen> createState() => _StoriesScreenState();
}

class _StoriesScreenState extends State<StoriesScreen> {
  final ScrollController scrollController = ScrollController();
  bool _isLoadingMore = false;
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

  void _onScroll() {
    if (_isLoadingMore) return; // Skip if already loading

    final state = context.read<StoryBloc>().state;
    if (_isBottom && state is StoryLoadedState && !state.hasReachedMax) {
      _isLoadingMore = true; // Set flag before loading
      BlocProvider.of<StoryBloc>(context).add(LoadMoreStories());
    }
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  final Map<String, bool> _expandedStories = {};

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.width * 0.04,
          horizontal: screenSize.width * 0.03,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, screenSize),
            SizedBox(height: screenSize.height * 0.02),
            Expanded(child: _buildStoryList(screenSize)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryList(Size screenSize) {
    return BlocConsumer<StoryBloc, StoryState>(
      listener: (context, state) {
        if (state is StoryErrorState) {
          _isLoadingMore = false;
          return SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
        if (state is StorySuccessState) {
          return SnackBarUtils.showGreenSnackBar(state.message, context);
        }
      },
      builder: (context, state) {
        if (state is StoryLoadingState) {
          return StoriesShimmerScreen();
        }

        if (state is StoryLoadedState) {
          print("has readed ${state.hasReachedMax}");
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
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  SizedBox(height: screenSize.height * 0.01),
                  Text(
                    'Click the + button above to post your first Story',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                            size: 20),
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
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
              ),
              SizedBox(height: screenSize.height * 0.01),
              Text(
                'Please try again later',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[500],
                    ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black12
            : Colors.white.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_stories,
                color: Theme.of(context).primaryColor,
                size: screenSize.width * 0.06,
              ),
              SizedBox(width: 10),
              Text(
                'Stories',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: screenSize.width * 0.055,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
              ),
            ],
          ),
          _buildCreateStoryButton(screenSize),
        ],
      ),
    );
  }

  Widget _buildCreateStoryButton(Size screenSize) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () {
            // In all_story.dart
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => StoryCreationBloc(),
                  child: CreateStoryScreen(
                      // Not needed anymore
                      ),
                ),
              ),
            ).then((newStory) {
              // Check if a story was returned
              if (newStory != null && newStory is StoryModel) {
                print("update list ");
                final state = context.read<StoryBloc>().state;
                if (state is StoryLoadedState) {
                  setState(() {
                    state.stories.insert(0, newStory);
                  });
                }
              }
            });
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.width * 0.03,
              vertical: screenSize.width * 0.02,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.add_circle,
                  color: Colors.white,
                  size: screenSize.width * 0.05,
                ),
                SizedBox(width: 5),
                Text(
                  'Create',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.035,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStoryCard(
      StoryModel story, Size screenSize, BuildContext context) {
    final date = DateTime.parse(story.createdAt);
    final isOwner = story.hostDetails.id == widget.currentUserId;
    final isExpanded = _expandedStories[story.id] ?? false;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).cardColor,
            Theme.of(context).cardColor.withOpacity(0.95),
          ],
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoryHeader(story, isOwner, screenSize),
            if (story.mediaUrls.isNotEmpty)
              _buildEnhancedMediaCarousel(story, screenSize),
            _buildStoryContent(story, isExpanded, screenSize),
            _buildTags(story, screenSize),
            Divider(height: 1, thickness: 0.5),
            _buildReactionsCountBar(story),
            Divider(height: 1, thickness: 0.5),
            _buildBottomBar(story),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryHeader(StoryModel story, bool isOwner, Size screenSize) {
    final date = DateTime.parse(story.createdAt);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => SeeProfileBloc(),
                    child: UserProfileScreen(
                      userId: story.hostDetails.id,
                      userType: story.userType,
                      currentUserId: widget.currentUserId,
                      currentUserType: widget.currentUserType,
                    ),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: screenSize.width * 0.055,
                backgroundImage: NetworkImage(story.hostDetails.profilePic),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.hostDetails.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.04,
                  ),
                ),
                Text(
                  DateFormat('MMM dd, yyyy • h:mm a').format(date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: screenSize.width * 0.03,
                  ),
                ),
              ],
            ),
          ),
          if (isOwner)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.edit_outlined,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider(
                        create: (context) => StoryCreationBloc(),
                        child: EditStoryScreen(
                          onStoryEdited: (StoryModel story) {},
                          story: story,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStoryContent(
      StoryModel story, bool isExpanded, Size screenSize) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            story.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: screenSize.width * 0.048,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                story.content,
                maxLines: isExpanded ? null : 3,
                overflow:
                    isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: screenSize.width * 0.037,
                  color: Colors.grey[700],
                  height: 1.5,
                  letterSpacing: 0.1,
                ),
              ),
              if (story.content.length > 150)
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _expandedStories[story.id] = !isExpanded;
                        });
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isExpanded ? 'View less' : 'View more',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: screenSize.width * 0.035,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              isExpanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: screenSize.width * 0.04,
                              color: Theme.of(context).primaryColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedMediaCarousel(StoryModel story, Size screenSize) {
    return Container(
      //   height: screenSize.height * 0.28,
      // decoration: BoxDecoration(
      //   boxShadow: [
      //     BoxShadow(
      //       color: Colors.black.withOpacity(0.2),
      //       blurRadius: 8,
      //       offset: Offset(0, 4),
      //     ),
      //   ],
      // ),
      child: Stack(
        children: [
          ClipRRect(
            child: story.mediaUrls.length > 1
                ? PageView.builder(
                    itemCount: story.mediaUrls.length,
                    itemBuilder: (context, index) => _buildMediaItem(
                      story.mediaUrls[index].url,
                      story.mediaUrls.map((m) => m.url).toList(),
                      index,
                      screenSize,
                    ),
                  )
                : _buildMediaItem(
                    story.mediaUrls.first.url,
                    story.mediaUrls.map((m) => m.url).toList(),
                    0,
                    screenSize,
                  ),
          ),
          if (story.mediaUrls.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  story.mediaUrls.length,
                  (index) => Container(
                    width: 8,
                    height: 8,
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaItem(
      String url, List<String> allUrls, int index, Size screenSize) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenImageViewer(
            imageUrls: allUrls,
            initialIndex: index,
          ),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
        ),
        child: Image.network(
          url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, size: 50, color: Colors.grey[500]),
          ),
        ),
      ),
    );
  }

  Widget _buildTags(StoryModel story, Size screenSize) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: story.tags
              .map((tag) => Container(
                    margin: EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('#$tag'),
                      labelStyle: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: screenSize.width * 0.033,
                      ),
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color:
                              Theme.of(context).primaryColor.withOpacity(0.3),
                          width: 0.5,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 4),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildReactionsCountBar(StoryModel story) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) =>
                    StoryReactionBloc()..add(FetchReactionsEvent(story.id)),
                child: StoryReactionsScreen(
                  story: story,
                  employerId: widget.currentUserId,
                ),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).primaryColor,
                          Theme.of(context).primaryColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      story.isLiked ? Icons.favorite : Icons.thumb_up,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${story.likesCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    ' likes',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '${story.views}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  SizedBox(width: 4),
                  Text(
                    '${story.commentsCount}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    ' comments',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar(StoryModel story) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.black12
            : Colors.grey[50],
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInteractionButton(
            icon: story.isLiked ? Icons.favorite : Icons.favorite_border,
            label: story.isLiked ? 'Liked' : 'Like',
            color: story.isLiked ? Theme.of(context).primaryColor : null,
            onTap: () {
              context.read<StoryBloc>().add(ToggleStoryLikeEvent(story.id));
            },
          ),
          Container(
            height: 24,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildInteractionButton(
            icon: Icons.comment_outlined,
            label: 'Comment',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) =>
                        StoryReactionBloc()..add(FetchReactionsEvent(story.id)),
                    child: StoryReactionsScreen(
                      story: story,
                      employerId: widget.currentUserId,
                    ),
                  ),
                ),
              );
            },
          ),
          Container(
            height: 24,
            width: 1,
            color: Theme.of(context).dividerColor,
          ),
          _buildInteractionButton(
            icon: story.isSaved ? Icons.bookmark : Icons.bookmark_border,
            label: story.isSaved ? 'Saved' : 'Save',
            color: story.isSaved ? Theme.of(context).primaryColor : null,
            onTap: () {
              context.read<StoryBloc>().add(ToggleSavedStoryEvent(story.id));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: color ?? Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
