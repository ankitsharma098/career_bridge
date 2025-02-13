import 'package:android/features/Stories/data/story_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../data/models/story/story_model.dart';

part 'story_event.dart';
part 'story_state.dart';

class StoryBloc extends Bloc<StoryEvent, StoryState> {

  StoryApiService apiService = StoryApiService();
   StoryBloc() : super(StoryInitialState()) {
    on<FetchStoriesEvent>(_onFetchStories);
    on<LoadMoreStories>(_onLoadMoreStories);
    on<ToggleStoryLikeEvent>(_onToggleStoryLikeEvent);
    on<ToggleSavedStoryEvent>(_onToggleSavedStoryEvent);

  }

  Future<void> _onFetchStories(
      FetchStoriesEvent event,
      Emitter<StoryState> emit
      ) async {
    emit(StoryLoadingState());
    try {

      List<StoryModel> stories =await apiService.fetchStories(1);
      final int pageSize = 10; // Adjust this to match your API's page size
      final bool hasReachedMax = stories.isEmpty || stories.length < pageSize; // assuming pageSize is 10
      emit(StoryLoadedState(stories: stories, hasReachedMax: hasReachedMax, currentPage: 1));
      print("Initial fetch - Stories count: ${stories.length}, hasReachedMax: $hasReachedMax");
    } catch (e) {
      emit(StoryErrorState(e.toString()));
    }
  }

  Future<void> _onLoadMoreStories(LoadMoreStories events, Emitter<StoryState> emit) async {
    final currentState = state;
    if (currentState is StoryLoadedState) {
      if (currentState.hasReachedMax) {
        print("Already reached max, skipping load more");
        return;
      }
        try {
          final nextPage = currentState.currentPage + 1;
          List<StoryModel> newStories = await apiService.fetchStories(nextPage);

          bool hasReachedMax=newStories.isEmpty || newStories.length < 10 ;
          final updatedStories = [...currentState.stories, ...newStories];
          print("Load more - New stories count: ${newStories.length}, hasReachedMax: $hasReachedMax");


          emit(StoryLoadedState(
              stories: updatedStories,
              hasReachedMax: hasReachedMax,
              currentPage: nextPage
          ));

        } catch (e) {
        print("error $e");
          emit(StoryErrorState(e.toString()));
        }

    }
  }

  Future<void> _onToggleStoryLikeEvent(ToggleStoryLikeEvent event, Emitter<StoryState> emit) async {
    if (state is StoryLoadedState) {
      final currentState = state as StoryLoadedState;
      try {
        // First update the UI optimistically
        final optimisticStories = currentState.stories.map((story) {
          if (story.id == event.storyId) {
            return story.copyWith(
              isLiked: !story.isLiked,
              likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
            );
          }
          return story;
        }).toList();

        emit(StoryLoadedState(
            stories: optimisticStories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));

        // Then make the API call
        final success = await apiService.likedStory(event.storyId);

        if (!success) {
          // If the API call fails, revert the optimistic update
          emit(StoryLoadedState(
              stories: currentState.stories,
              hasReachedMax: currentState.hasReachedMax,
              currentPage: currentState.currentPage
          ));
        }
      } catch (e) {
        // If there's an error, revert to the original state
        emit(StoryLoadedState(
            stories: currentState.stories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));
        emit(StoryErrorState(e.toString()));
      }
    }
  }

  Future<void> _onToggleSavedStoryEvent(ToggleSavedStoryEvent event, Emitter<StoryState> emit) async {
    if (state is StoryLoadedState) {
      final currentState = state as StoryLoadedState;
      try {
        // First update the UI optimistically
        // final optimisticStories = currentState.stories.map((story) {
        //   if (story.id == event.storyId) {
        //     return story.copyWith(
        //       isLiked: !story.isLiked,
        //       likesCount: story.isLiked ? story.likesCount - 1 : story.likesCount + 1,
        //     );
        //   }
        //   return story;
        // }).toList();

        // emit(StoryLoadedState(
        //     stories: optimisticStories,
        //     hasReachedMax: currentState.hasReachedMax,
        //     currentPage: currentState.currentPage
        // ));

        // Then make the API call
        final success = await apiService.savedStory(event.storyId);

        if (!success) {
          emit(StorySuccessState("Story Saved Successfully"));
        }else {
          emit(StorySuccessState("Story Unsaved Successfully"));
        }
      } catch (e) {

        emit(StoryErrorState(e.toString()));
      }
    }
  }
}