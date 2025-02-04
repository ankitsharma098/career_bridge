part of 'story_bloc.dart';

abstract class StoryEvent extends Equatable {
  const StoryEvent();

  @override
  List<Object> get props => [];
}

class FetchStoriesEvent extends StoryEvent {}
class LoadMoreStories extends StoryEvent {}

class LikeStoryEvent extends StoryEvent {
  final String storyId;

  const LikeStoryEvent(this.storyId);

  @override
  List<Object> get props => [storyId];
}