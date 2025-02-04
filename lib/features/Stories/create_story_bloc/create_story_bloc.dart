import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'create_story_event.dart';
part 'create_story_state.dart';

class StoryCreationBloc extends Bloc<StoryCreationEvent, StoryCreationState> {
  //final StoryApiService apiService;

  StoryCreationBloc() : super(StoryCreationInitial()) {
    on<SubmitStoryEvent>(_onSubmitStory);
    on<UpdateMediaEvent>(_onUpdateMedia);
    on<UpdateTagsEvent>(_onUpdateTags);
  }

  Future<void> _onSubmitStory(
      SubmitStoryEvent event,
      Emitter<StoryCreationState> emit,
      ) async {
    emit(StoryCreationLoading());
    try {
      // await apiService.createStory(
      //   title: event.title,
      //   content: event.content,
      //   mediaFile: event.mediaFile,
      //   tags: event.tags,
      //   category: event.category,
      // );
      emit(StoryCreationSuccess());
    } catch (e) {
      emit(StoryCreationError(e.toString()));
    }
  }

  void _onUpdateMedia(UpdateMediaEvent event, Emitter<StoryCreationState> emit) {
    if (state is StoryCreationInitial || state is StoryCreationEditing) {
      emit(StoryCreationEditing(
        title: state is StoryCreationEditing ? (state as StoryCreationEditing).title : '',
        content: state is StoryCreationEditing ? (state as StoryCreationEditing).content : '',
        mediaFile: event.mediaFile,
        tags: state is StoryCreationEditing ? (state as StoryCreationEditing).tags : [],
        category: state is StoryCreationEditing ? (state as StoryCreationEditing).category : 'success-story',
      ));
    }
  }

  void _onUpdateTags(UpdateTagsEvent event, Emitter<StoryCreationState> emit) {
    if (state is StoryCreationInitial || state is StoryCreationEditing) {
      emit(StoryCreationEditing(
        title: state is StoryCreationEditing ? (state as StoryCreationEditing).title : '',
        content: state is StoryCreationEditing ? (state as StoryCreationEditing).content : '',
        mediaFile: state is StoryCreationEditing ? (state as StoryCreationEditing).mediaFile : null,
        tags: event.tags,
        category: state is StoryCreationEditing ? (state as StoryCreationEditing).category : 'success-story',
      ));
    }
  }
}


