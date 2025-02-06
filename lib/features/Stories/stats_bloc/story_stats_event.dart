part of 'story_stats_bloc.dart';

@immutable
sealed class StoryStatsEvent {}

class FetchStoryStats extends StoryStatsEvent{}
class FetchStoryEvent extends StoryStatsEvent{

  final bool isMyStory;

  FetchStoryEvent({required this.isMyStory});
}
class LoadMoreStoriesEvent extends StoryStatsEvent {

  final bool isMyStory;

  LoadMoreStoriesEvent({required this.isMyStory});
}
