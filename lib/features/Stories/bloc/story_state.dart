part of 'story_bloc.dart';

// States
abstract class StoryState extends Equatable {
  const StoryState();

  @override
  List<Object> get props => [];
}

class StoryInitialState extends StoryState {}

class StoryLoadingState extends StoryState {}

class StoryLoadedState extends StoryState {
  final List<StoryModel> stories;

  const StoryLoadedState(this.stories);

  @override
  List<Object> get props => [stories];
}

class StoryErrorState extends StoryState {
  final String error;

  const StoryErrorState(this.error);

  @override
  List<Object> get props => [error];
}
