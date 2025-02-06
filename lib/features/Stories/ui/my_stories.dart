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
import '../create_story_bloc/create_story_bloc.dart';
import '../stats_bloc/story_stats_bloc.dart';
import 'create_story.dart';
import 'edit_story.dart';

class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});


  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    BlocProvider.of<StoryStatsBloc>(context).add(FetchStoryEvent(isMyStory: true));
    scrollController.addListener(_onScroll);
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = context.read<StoryStatsBloc>().state;
    if (_isBottom && state is StoryLoaded && !state.hasReachedMax) {
      BlocProvider.of<StoryStatsBloc>(context).add(LoadMoreStoriesEvent(isMyStory: true));
    }
  }

  bool get _isBottom {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text("My Stories"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenSize.width * 0.04,
          horizontal: screenSize.width * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildStoryList(screenSize)),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryList(Size screenSize) {
    return BlocConsumer<StoryStatsBloc, StoryStatsState>(
      listener: (context, state) {
        if (state is StoryStatsError) {
          return SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
      },
      builder: (context, state) {
        if (state is StoryStatsLoading) {
          return StoriesShimmerScreen();
        }

        if (state is StoryLoaded) {
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
              BlocProvider.of<StoryStatsBloc>(context).add(FetchStoryEvent(isMyStory: true));
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

  Widget _buildStoryCard(StoryModel story, Size screenSize, BuildContext context) {
    final date = DateTime.parse(story.createdAt);


    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
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
            trailing:_buildEditButton(story, context),
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
                Text(
                  story.content,
                  // maxLines: 6,
                  // overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: screenSize.width * 0.035,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          _buildTags(story, screenSize),
          Divider(height: 1),
          _buildInteractionBar(story, screenSize),
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

  Widget _buildInteractionBar(StoryModel story, Size screenSize) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInteractionButton(
            icon: story.isLiked ? Icons.favorite : Icons.favorite_border,
            count: story.likesCount,
            color: story.isLiked ? Colors.red : null,
            onTap: () {},
          ),
          _buildInteractionButton(
            icon: Icons.comment_outlined,
            count: story.commentsCount,
            onTap: () {},
          ),
          _buildInteractionButton(
            icon: Icons.remove_red_eye_outlined,
            count: story.views,
          ),
          _buildInteractionButton(
            icon: Icons.share_outlined,
            count: story.sharesCount,
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required int count,
    Color? color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey[600]),
            SizedBox(width: 4),
            Text(
              '$count',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}