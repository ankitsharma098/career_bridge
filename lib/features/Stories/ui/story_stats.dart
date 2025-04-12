import 'package:android/core/utils/customErrorUtils.dart';
import 'package:android/data/models/story/story_model.dart';
import 'package:android/features/Stories/stats_bloc/story_stats_bloc.dart';
import 'package:android/features/Stories/ui/saved_stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/image_viewer.dart';
import '../../See profile/bloc/see_profile_bloc.dart';
import '../../See profile/ui/see_profile.dart';
import '../create_story_bloc/create_story_bloc.dart';
import '../reaction_bloc/story_reaction_bloc.dart';
import 'edit_story.dart';
import 'my_stories.dart';
import 'reaction_screen.dart';
import 'shimmers/mystory_shimmer.dart';

class StoryStatsTab extends StatefulWidget {
  final String currentUserId;
  const StoryStatsTab({
    super.key,
    required this.currentUserId,
  });

  @override
  State<StoryStatsTab> createState() => _StoryStatsTabState();
}

class _StoryStatsTabState extends State<StoryStatsTab> {
  final Map<String, bool> _expandedStories = {};

  @override
  void initState() {
    BlocProvider.of<StoryStatsBloc>(context).add(FetchStoryStats());
    super.initState();
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Not provided';
    }
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy • h:mm a').format(date);
    } catch (e) {
      return 'Invalid date';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("My Stories"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<StoryStatsBloc, StoryStatsState>(
        builder: (context, state) {
          if (state is StoryStatsLoading) {
            return StoryStatsShimmer();
          }
          if (state is StoryStatsError) {
            return CustomErrorScreen(
              message: state.error.toString(),
              onRetry: () {
                BlocProvider.of<StoryStatsBloc>(context).add(FetchStoryStats());
              },
            );
          }

          if (state is StoryStatsLoaded) {
            final totalStories = state.stats['totalStories'] ?? 0;
            final savedStories = state.stats['savedStories'] ?? 0;
            StoryModel? mostViewedStory = state.stats['mostViewedStory'] != null
                ? StoryModel.fromJson(state.stats['mostViewedStory'])
                : null;
            StoryModel? mostLikedStory = state.stats['mostLikedStory'] != null
                ? StoryModel.fromJson(state.stats['mostLikedStory'])
                : null;
            StoryModel? latestStory = state.stats['latestStory'] != null
                ? StoryModel.fromJson(state.stats['latestStory'])
                : null;
            final totalViews = state.stats['totalViews'] ?? 0;
            final totalLikes = state.stats['totalLikes'] ?? 0;

            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<StoryStatsBloc>(context).add(FetchStoryStats());
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(screenSize.width * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, screenSize),
                    SizedBox(height: screenSize.height * 0.02),
                    _buildOverviewCards(
                      context,
                      screenSize,
                      {
                        'totalStories': totalStories,
                        'savedStories': savedStories,
                        'totalViews': totalViews,
                        'totalLikes': totalLikes,
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.03),
                    if (mostViewedStory != null ||
                        mostLikedStory != null ||
                        latestStory != null)
                      _buildTopStories(
                        context,
                        screenSize,
                        mostViewedStory,
                        mostLikedStory,
                        latestStory,
                      )
                    else
                      _buildNoStoriesMessage(context, screenSize),
                  ],
                ),
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
      ),
    );
  }

  Widget _buildNoStoriesMessage(BuildContext context, Size screenSize) {
    return Card(
      margin: EdgeInsets.all(screenSize.width * 0.03),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'No Stories Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first story to see stats here',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Size screenSize) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Story Insights',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const Icon(Icons.auto_stories),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(
    BuildContext context,
    Size screenSize,
    Map<String, dynamic> metrics,
  ) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: screenSize.width * 0.03,
      crossAxisSpacing: screenSize.width * 0.03,
      childAspectRatio: 1.5,
      children: [
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => StoryStatsBloc(),
                  child: MyStoriesScreen(currentUserId: widget.currentUserId),
                ),
              ),
            );
          },
          child: _statsCard(
            'Total Stories',
            metrics['totalStories'].toString(),
            Icons.auto_stories,
            Colors.blue,
            screenSize,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => StoryStatsBloc(),
                  child:
                      SavedStoriesScreen(currentUserId: widget.currentUserId),
                ),
              ),
            );
          },
          child: _statsCard(
            'Saved Stories',
            metrics['savedStories'].toString(),
            Icons.bookmark,
            Colors.green,
            screenSize,
          ),
        ),
        _statsCard(
          'Total Views',
          metrics['totalViews'].toString(),
          Icons.visibility,
          Colors.orange,
          screenSize,
        ),
        _statsCard(
          'Total Likes',
          metrics['totalLikes'].toString(),
          Icons.favorite,
          Colors.red,
          screenSize,
        ),
      ],
    );
  }

  Widget _buildTopStories(
    BuildContext context,
    Size screenSize,
    StoryModel? mostViewed,
    StoryModel? mostLiked,
    StoryModel? latest,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Stories',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        SizedBox(height: screenSize.height * 0.02),
        if (mostViewed != null)
          _buildStoryCard(
              'Most Viewed Story', mostViewed, Icons.visibility, Colors.blue),
        SizedBox(height: mostViewed != null ? screenSize.height * 0.02 : 0),
        if (mostLiked != null)
          _buildStoryCard(
              'Most Liked Story', mostLiked, Icons.favorite, Colors.red),
        SizedBox(height: mostLiked != null ? screenSize.height * 0.02 : 0),
        if (latest != null)
          _buildStoryCard(
              'Latest Story', latest, Icons.access_time, Colors.green),
        SizedBox(height: latest != null ? screenSize.height * 0.02 : 0),
      ],
    );
  }

  Widget _buildStoryCard(
      String title, StoryModel story, IconData icon, Color color) {
    final screenSize = MediaQuery.of(context).size;
    final isExpanded = _expandedStories[story.id] ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
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
            _buildStoryHeader(story, screenSize, title, icon, color),
            if (story.mediaUrls.isNotEmpty)
              _buildEnhancedMediaCarousel(story, screenSize),
            _buildStoryContent(story, isExpanded, screenSize),
            _buildTags(story, screenSize),
            const Divider(height: 1, thickness: 0.5),
            _buildReactionsCountBar(story),
            const Divider(height: 1, thickness: 0.5),
            _buildBottomBar(story),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryHeader(StoryModel story, Size screenSize, String title,
      IconData icon, Color color) {
    final date = formatDate(story.createdAt);
    final isOwner = story.hostDetails.id == widget.currentUserId;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      currentUserType:
                          'employer', // Adjust based on your app logic
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
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: color),
                    const SizedBox(width: 4),
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: screenSize.width * 0.04,
                        color: color,
                      ),
                    ),
                  ],
                ),
                Text(
                  date,
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
      padding: const EdgeInsets.all(16),
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
          const SizedBox(height: 12),
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
                  padding: const EdgeInsets.only(top: 10),
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
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
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
                            const SizedBox(width: 4),
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
    return Stack(
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
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ),
          ),
      ],
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: story.tags
              .map((tag) => Container(
                    margin: const EdgeInsets.only(right: 8),
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
                      padding: const EdgeInsets.symmetric(horizontal: 4),
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
                    style: const TextStyle(
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                    const SizedBox(width: 4),
                    Text(
                      '${story.views}',
                      style: const TextStyle(
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
                  const SizedBox(width: 4),
                  Text(
                    '${story.commentsCount}',
                    style: const TextStyle(
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
        borderRadius: const BorderRadius.only(
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
              context
                  .read<StoryStatsBloc>()
                  .add(ToggleStoryLikeEvent(story.id));
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
              context
                  .read<StoryStatsBloc>()
                  .add(ToggleSavedStoryEvent(story.id));
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

  Widget _statsCard(
      String title, String count, IconData icon, Color color, Size screenSize) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: screenSize.height * 0.01),
          Text(
            count,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontSize: screenSize.width * 0.04,
                ),
          ),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w200,
                  color: color,
                  fontSize: screenSize.width * 0.035,
                ),
          ),
        ],
      ),
    );
  }
}
