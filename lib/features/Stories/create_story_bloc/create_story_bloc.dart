import 'dart:io';

import 'package:android/data/models/story/story_model.dart';
import 'package:android/features/Stories/data/story_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'create_story_event.dart';
part 'create_story_state.dart';

class StoryCreationBloc extends Bloc<StoryCreationEvent, StoryCreationState> {
  
  StoryApiService apiService = StoryApiService();
  StoryCreationBloc() : super(StoryCreationInitial()) {
    on<SubmitStoryEvent>(_onSubmitStory);

  }

  Future<void> _onSubmitStory(
      SubmitStoryEvent event,
      Emitter<StoryCreationState> emit,
      ) async {
    emit(StoryCreationLoading());
    try {
     StoryModel story;
     if(event.isEditing){
       story = await apiService.updateStory(event.story,event.storyId);
     }else {
        story = await apiService.createStory(event.story);
     }
      emit(StoryCreationSuccess(story: story));
    } catch (e) {
      emit(StoryCreationError(e.toString()));
    }
  }

}


