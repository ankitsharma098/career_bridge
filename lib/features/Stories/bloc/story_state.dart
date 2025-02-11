part of 'story_bloc.dart';

// States
sealed class StoryState {}

class StoryInitialState extends StoryState {}

class StoryLoadingState extends StoryState {}

class StoryLoadedState extends StoryState {
  final List<StoryModel> stories;
  final bool hasReachedMax;
  final int currentPage;

  StoryLoadedState({required this.stories, required this.hasReachedMax, required this.currentPage});


}

class StoryErrorState extends StoryState {
  final String error;

   StoryErrorState(this.error);

}
