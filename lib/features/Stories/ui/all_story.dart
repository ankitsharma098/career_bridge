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
  const StoriesScreen({super.key, required this.currentUserId, required this.currentUserType});


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
    if (_isLoadingMore) return;  // Skip if already loading

    final state = context.read<StoryBloc>().state;
    if (_isBottom && state is StoryLoadedState && !state.hasReachedMax) {
      _isLoadingMore = true;  // Set flag before loading
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
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: screenSize.width * 0.04,
        horizontal: screenSize.width * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, screenSize),
          SizedBox(height: screenSize.height * 0.02),
          Expanded(child: _buildStoryList(screenSize)),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Posted Stories',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: screenSize.width * 0.06,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => StoryCreationBloc(),
                      child: CreateStoryScreen(
                        onStoryCreated: (StoryModel story) {
                          final state = context.read<StoryBloc>().state;
                          if (state is StoryLoadedState) {
                            setState(() {
                              state.stories.insert(0, story);
                            });
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
              iconSize: screenSize.width * 0.08,
            ),
          ),
        ],
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
        if(state is StorySuccessState){
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
                            color: Theme.of(context).brightness == Brightness.dark
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

  Widget _buildStoryCard(StoryModel story, Size screenSize, BuildContext context) {
    final date = DateTime.parse(story.createdAt);
    final isOwner = story.hostDetails.id == widget.currentUserId;
    final isExpanded = _expandedStories[story.id] ?? false;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                                      userType: story.userType, currentUserId: widget.currentUserId, currentUserType:widget.currentUserType , // Ensure StoryModel has type
                                    ),
                  ),
                ),
              );
            },
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                radius: screenSize.width * 0.05,
                backgroundImage: NetworkImage(story.hostDetails.profilePic),
              ),
              title: Text(
                story.hostDetails.name,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM dd, yyyy').format(date),
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: isOwner ? _buildEditButton(story, context) : null,
            ),
          ),
          if (story.mediaUrls.isNotEmpty) _buildEnhancedMediaCarousel(story, screenSize),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  story.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: screenSize.width * 0.045,
                  ),
                ),
                SizedBox(height: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      story.content,
                      maxLines: isExpanded ? null : 3,
                      overflow: isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: screenSize.width * 0.035,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                    if (story.content.length > 150)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _expandedStories[story.id] = !isExpanded;
                              });
                            },
                            borderRadius: BorderRadius.circular(4),
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
                                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                                  size: screenSize.width * 0.04,
                                  color: Theme.of(context).primaryColor,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _buildTags(story, screenSize),
          Divider(height: 1),
          _buildReactionsCountBar(story),
          const Divider(height: 1),
          _buildBottomBar(story),
        ],
      ),
    );
  }

  Widget _buildEditButton(StoryModel story, BuildContext context) {
    return IconButton(
      icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => StoryCreationBloc(),
              child: EditStoryScreen(
                onStoryEdited: (StoryModel story) {
                  // final state = context.read<StoryBloc>().state;
                  // if (state is StoryLoadedState) {
                  //   setState(() {
                  //     state.stories.insert(0, story);
                  //   });
                  // }
                }, story: story,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedMediaCarousel(StoryModel story, Size screenSize) {
    return Container(
      height: screenSize.height * 0.25,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
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
    );
  }

  Widget _buildMediaItem(String url, List<String> allUrls, int index, Size screenSize) {
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
          color: Colors.grey[200],
        ),
        child: Image.network(
          url,
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
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        ),
      ),
    );
  }

  Widget _buildTags(StoryModel story, Size screenSize) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: story.tags.map((tag) => Padding(
          padding: EdgeInsets.only(right: 8),
          child: Chip(
            label: Text('#$tag'),
            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
          ),
        )).toList(),
      ),
    );
  }


  Widget _buildReactionsCountBar(StoryModel story) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => StoryReactionBloc()..add(FetchReactionsEvent(story.id)),
              child: StoryReactionsScreen(
                story: story,
                employerId: widget.currentUserId,
              ),
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    story.isLiked ? Icons.favorite : Icons.thumb_up,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text('${story.likesCount} likes'),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Icon(Icons.remove_red_eye_outlined, size: 20,),
                  SizedBox(width: 4),
                  Text(
                    '${story.views}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Text('${story.commentsCount} comments'),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomBar(StoryModel story) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [

          _buildInteractionButton(
            icon: story.isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Like',
            color: story.isLiked ? Theme.of(context).primaryColor : null,
            onTap: () => context.read<StoryBloc>().add(
              ToggleStoryLikeEvent(story.id),
            ),
          ),
          _buildInteractionButton(
            icon: Icons.comment_outlined,
            label: 'Comment',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => StoryReactionBloc()..add(FetchReactionsEvent(story.id)),
                    child: StoryReactionsScreen(
                      story: story,
                      employerId: widget.currentUserId,
                    ),
                  ),
                ),
              );
            },
          ),
          _buildInteractionButton(
            icon: story.isSaved ? Icons.save:Icons.save_outlined,
            label:story.isSaved ?"Save":'Saved',
            onTap: () {
              context.read<StoryBloc>().add(
                ToggleSavedStoryEvent(story.id,),
              );
            },
          ),
          // ... other buttons
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
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(label),
          ],
        ),
      ),
    );
  }
}