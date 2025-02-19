import 'package:android/core/utils/customErrorUtils.dart';
import 'package:android/data/models/story/story_model.dart';
import 'package:android/features/Stories/stats_bloc/story_stats_bloc.dart';
import 'package:android/features/Stories/ui/saved_stories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../../core/utils/image_viewer.dart';
import '../../Jobs/ui/shimmer/Job_stats_shimmer.dart';
import '../create_story_bloc/create_story_bloc.dart';
import 'edit_story.dart';
import 'my_stories.dart';
import 'shimmers/mystory_shimmer.dart';


class StoryStatsTab extends StatefulWidget {

  final String employerId;
  const StoryStatsTab({
    super.key, required this.employerId,
  });

  @override
  State<StoryStatsTab> createState() => _StoryStatsTabState();
}

class _StoryStatsTabState extends State<StoryStatsTab> {

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
      return DateFormat('dd/MM/yyyy').format(date);
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
          title: Text("My Stories"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new),
            onPressed: () => Navigator.pop(context),
          ),),
      body: BlocBuilder<StoryStatsBloc, StoryStatsState>(

        builder: (context, state) {
          if (state is StoryStatsLoading) {
            return  StoryStatsShimmer();
          }
          if(state is StoryStatsError){
            return CustomErrorScreen(message: state.error.toString(),onRetry: (){
                BlocProvider.of<StoryStatsBloc>(context).add(FetchStoryStats());

            },);
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
              onRefresh: ()async{
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
                    if (mostViewedStory != null  || mostLikedStory != null || latestStory != null)
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
        }
      ),

    );
  }
  Widget _buildNoStoriesMessage(BuildContext context, Size screenSize) {
    return Card(
      margin: EdgeInsets.all(screenSize.width * 0.03),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 48,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Stories Yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
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
            Icon(Icons.auto_stories),
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
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(
              create: (context) => StoryStatsBloc(),
              child: MyStoriesScreen(employerId: widget.employerId,),
            ),));
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
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => BlocProvider(
              create: (context) => StoryStatsBloc(),
              child: SavedStoriesScreen(employerId: widget.employerId,),
            ),));
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
          mostViewed != null ? _buildStoryCard('Most Viewed Story', mostViewed, Icons.visibility, Colors.blue):SizedBox(height: screenSize.height * 0),
        SizedBox(height: screenSize.height * 0.02),
        mostLiked != null ? _buildStoryCard('Most Liked Story', mostLiked, Icons.favorite, Colors.red):SizedBox(height: screenSize.height * 0),
        SizedBox(height: screenSize.height * 0.02),
        latest != null ?_buildStoryCard('Latest Story', latest, Icons.access_time, Colors.green):SizedBox(height: screenSize.height * 0.02),
      ],
    );
  }

  Widget _buildStoryCard(String title, StoryModel story, IconData icon, Color color) {
    final screenSize = MediaQuery.of(context).size;
    final date = formatDate(story.createdAt);
    return Card(
      margin: EdgeInsets.all(screenSize.width * 0.03),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User Info
          ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundImage: NetworkImage(story.hostDetails.profilePic),
            ),
            title: Text(story.hostDetails.name),
            subtitle: Text(
              date,
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: _buildEditButton(story, context),
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
          // Content Preview
          _buildTags(story, screenSize),
          Divider(height: 1),
          _buildInteractionBar(story, screenSize),
        ],
      ),
    );
  }

  Widget _statsCard(String title, String count, IconData icon, Color color, Size screenSize) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
