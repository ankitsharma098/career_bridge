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
    on<LikeStoryEvent>(_onLikeStory);
  }

  Future<void> _onFetchStories(
      FetchStoriesEvent event,
      Emitter<StoryState> emit
      ) async {
    emit(StoryLoadingState());
    try {

      List<StoryModel> stories =await apiService.fetchStories();

      emit(StoryLoadedState(stories));
    } catch (e) {
      emit(StoryErrorState(e.toString()));
    }
  }

  Future<void> _onLikeStory(
      LikeStoryEvent event,
      Emitter<StoryState> emit
      ) async {
    if (state is StoryLoadedState) {
      try {
        //await repository.likeStory(event.storyId);
        // Refresh stories after like
        add(FetchStoriesEvent());
      } catch (e) {
        emit(StoryErrorState(e.toString()));
      }
    }
  }
}