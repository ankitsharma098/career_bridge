part of 'story_bloc.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object> get props => [];
}

class FetchStoriesEvent extends StoryEvent {}

class LoadMoreStories extends StoryEvent {}

class ToggleStoryLikeEvent extends StoryEvent {
  final String storyId;
  const ToggleStoryLikeEvent(this.storyId);

  @override
  List<Object> get props => [storyId];
}
class ToggleSavedStoryEvent extends StoryEvent {
  final String storyId;
  const ToggleSavedStoryEvent(this.storyId);

  @override
  List<Object> get props => [storyId];
}