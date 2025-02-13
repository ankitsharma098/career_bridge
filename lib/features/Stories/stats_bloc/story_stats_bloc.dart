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

        emit(StoryLoaded(
            stories: optimisticStories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));

        // Then make the API call
        final success = await apiService.likedStory(event.storyId);

        if (!success) {
          // If the API call fails, revert the optimistic update
          emit(StoryLoaded(
              stories: currentState.stories,
              hasReachedMax: currentState.hasReachedMax,
              currentPage: currentState.currentPage
          ));
        }
      } catch (e) {
        // If there's an error, revert to the original state
        emit(StoryLoaded(
            stories: currentState.stories,
            hasReachedMax: currentState.hasReachedMax,
            currentPage: currentState.currentPage
        ));
        emit(StoryStatsError( error: e.toString(),));
      }
    }
  }
}
