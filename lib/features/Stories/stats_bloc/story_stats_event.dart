part of 'story_stats_bloc.dart';

@immutable
sealed class StoryStatsEvent {}

class FetchStoryStats extends StoryStatsEvent{}
class FetchStoryEvent extends StoryStatsEvent{

  final bool isMyStory;

  FetchStoryEvent({required this.isMyStory});
}

class DeleteStory extends StoryStatsEvent{

  final String storyId;

  DeleteStory({required this.storyId});


}

class LoadMoreStoriesEvent extends StoryStatsEvent {

  final bool isMyStory;

  LoadMoreStoriesEvent({required this.isMyStory});
}
class ToggleStoryLikeEvent extends StoryStatsEvent {
  final String storyId;
   ToggleStoryLikeEvent(this.storyId);
}
class ToggleSavedStoryEvent extends StoryStatsEvent {
  final String storyId;
  ToggleSavedStoryEvent(this.storyId);
}
