import 'package:android/core/utils/customErrorUtils.dart';
import 'package:android/data/models/story/story_model.dart';
import 'package:android/features/Stories/stats_bloc/story_stats_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/colors.dart';
import '../../Jobs/ui/shimmer/Job_stats_shimmer.dart';
import 'mystory_shimmer.dart';


class StoryStatsTab extends StatefulWidget {

  const StoryStatsTab({
    super.key,
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
            final totalStories = state.stats['totalStories'];
            final savedStories = state.stats['savedStories'];
            StoryModel mostViewedStory = StoryModel.fromJson(state.stats['mostViewedStory']);
            StoryModel mostLikedStory = StoryModel.fromJson(state.stats['mostLikedStory']);
            StoryModel latestStory =StoryModel.fromJson( state.stats['latestStory']);
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
                    _buildTopStories(
                      context,
                      screenSize,
                      mostViewedStory,
                      mostLikedStory,
                      latestStory,
                    ),
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
        _statsCard(
          'Total Stories',
          metrics['totalStories'].toString(),
          Icons.auto_stories,
          Colors.blue,
          screenSize,
        ),
        _statsCard(
          'Saved Stories',
          metrics['savedStories'].toString(),
          Icons.bookmark,
          Colors.green,
          screenSize,
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
      StoryModel mostViewed,
      StoryModel mostLiked,
      StoryModel latest,
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
        _buildStoryCard('Most Viewed Story', mostViewed, Icons.visibility, Colors.blue),
        SizedBox(height: screenSize.height * 0.02),
        _buildStoryCard('Most Liked Story', mostLiked, Icons.favorite, Colors.red),
        SizedBox(height: screenSize.height * 0.02),
        _buildStoryCard('Latest Story', latest, Icons.access_time, Colors.green),
      ],
    );
  }

  Widget _buildStoryCard(String title, StoryModel story, IconData icon, Color color) {
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
}

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