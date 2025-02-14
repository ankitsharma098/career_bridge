import 'package:android/data/models/story/story_model.dart';
import 'package:android/features/Stories/bloc/story_bloc.dart';
import 'package:android/features/Stories/data/story_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'story_stats_event.dart';
part 'story_stats_state.dart';

class StoryStatsBloc extends Bloc<StoryStatsEvent, StoryStatsState> {
  StoryApiService apiService = StoryApiService();
  StoryStatsBloc() : super(StoryStatsInitial()) {
    on<FetchStoryStats>(_onFetchStoryStats);
    on<FetchStoryEvent>(_onFetchStoryEvent);
    on<LoadMoreStoriesEvent>(_onLoadMoreStoriesEvent);
    on<DeleteStory>(_onDeleteStory);
    on<ToggleStoryLikeEvent>(_onToggleStoryLikeEvent);
    on<ToggleSavedStoryEvent>(_onToggleSavedStoryEvent);

  }

  Future<void> _onFetchStoryStats(FetchStoryStats event, Emitter<StoryStatsState> emit) async {


    try{
      emit(StoryStatsLoading());

     Map<String,dynamic> stats= await apiService.fetchStoriesStats();

      emit(StoryStatsLoaded(stats: stats));

    }catch(e){

      emit(StoryStatsError(error: e.toString()));
    }

}

  Future<void> _onFetchStoryEvent(FetchStoryEvent event, Emitter<StoryStatsState> emit) async {


    try{
      emit(StoryStatsLoading());
      List<StoryModel> stories;
      if(event.isMyStory){
       stories= await apiService.fetchMyStories(1);

      }else{
        stories=await apiService.fetchSavedStories(1);
      }
      final int pageSize = 10; // Adjust this to match your API's page size
      bool hasReachedMax = stories.length < pageSize;
      emit(StoryLoaded(stories: stories, hasReachedMax: hasReachedMax, currentPage: 1));

    }catch(e){

      emit(StoryStatsError(error: e.toString()));
    }

}

  Future<void> _onLoadMoreStoriesEvent(LoadMoreStoriesEvent events, Emitter<StoryStatsState> emit) async {
    final currentState = state;
    if (currentState is StoryLoaded) {

      if (!currentState.hasReachedMax) {
        try {
          List<StoryModel> newStories;
          final nextPage = currentState.currentPage + 1;
          if(events.isMyStory){
            newStories= await apiService.fetchMyStories(nextPage);
          }else {
            newStories= await apiService.fetchSavedStories(nextPage);
          }


          if (newStories.isEmpty) {
            emit(StoryLoaded(
                stories: currentState.stories,
                hasReachedMax: true,
                currentPage: currentState.currentPage
            ));
          } else {
            emit(StoryLoaded(
                stories: [...currentState.stories, ...newStories],
                hasReachedMax: false,
                currentPage: nextPage
            ));
          }
        } catch (e) {
          emit(StoryStatsError(error: e.toString()));
        }
      }
    }



}

  Future<void> _onDeleteStory(DeleteStory event , Emitter<StoryStatsState> emit) async {

    try{
      emit(StoryStatsLoading());


      bool success= await apiService.deleteStory(event.storyId);

      if(success) {
        emit(StorySuccess(message: 'Story deleted successfully'));
      }else{
        emit(StoryStatsError(error: "Failed to delete story"));
      }
      add(FetchStoryEvent(isMyStory: true));

    }catch(e){

      emit(StoryStatsError(error: e.toString()));
    }

  }

  Future<void> _onToggleStoryLikeEvent(ToggleStoryLikeEvent event, Emitter<StoryStatsState> emit) async {
    if (state is StoryLoaded) {
      final currentState = state as StoryLoaded;
      try {
        // Get the current story
        final currentStory = currentState.stories.firstWhere((story) => story.id == event.storyId);
        final wasLiked = currentStory.isLiked;

        // Create optimistic update
        final optimisticStories = currentState.stories.map((story) {
          if (story.id == event.storyId) {
            return story.copyWith(
              isLiked: !wasLiked,
              likesCount: wasLiked ? story.likesCount - 1 : story.likesCount + 1,
            );
          }
          return story;
        }).toList();

        // Emit optimistic state immediately
        emit(StoryLoaded(
            stories: optimisticStories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));

        // Make API call
        final success = await apiService.likedStory(event.storyId);

        // If API call fails, revert to original state
        if (!success) {
          // Create reversion state with original values
          final revertedStories = currentState.stories.map((story) {
            if (story.id == event.storyId) {
              return story.copyWith(
                isLiked: wasLiked,
                likesCount: currentStory.likesCount, // Use original like count
              );
            }
            return story;
          }).toList();

          // Emit the reverted state
          emit(StoryLoaded(
              stories: revertedStories,
              hasReachedMax: currentState.hasReachedMax,
              currentPage: currentState.currentPage
          ));

          // Emit error state without reverting the UI again
       //   emit(StoryStatsError(error: "Failed to update like status"));
        }
      } catch (e) {
        // On error, revert to original state and show error
        emit(StoryLoaded(
            stories: currentState.stories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));
        emit(StoryStatsError(error: e.toString()));
      }
    }
  }

  Future<void> _onToggleSavedStoryEvent(ToggleSavedStoryEvent event, Emitter<StoryStatsState> emit) async {
    print("Event occured");
    if (state is StoryLoaded) {
      final currentState = state as StoryLoaded;
      try {

        final optimisticStories = currentState.stories.map((story) {
          if (story.id == event.storyId) {
            return story.copyWith(
              isSaved: !story.isSaved,
            );
          }
          return story;
        }).toList();

        emit(StoryLoaded(
            stories: optimisticStories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));


        final success = await apiService.savedStory(event.storyId);

        if (success) {
          emit(StorySuccess( message:"Story Saved Successfully"));
          emit(StoryLoaded(
              stories: optimisticStories,
              hasReachedMax: currentState.hasReachedMax,
              currentPage: currentState.currentPage
          ));
        }else {
          emit(StorySuccess( message:"Story Unsaved Successfully"));
          emit(StoryLoaded(
              stories: currentState.stories,
              hasReachedMax: currentState.hasReachedMax,
              currentPage: currentState.currentPage
          ));
        }
      } catch (e) {

        emit(StoryStatsError(error: e.toString()));
        emit(StoryLoaded(
            stories: currentState.stories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));
      }
    }
  }
}
