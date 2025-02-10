import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../data/story_api_service.dart';

part 'story_reaction_event.dart';
part 'story_reaction_state.dart';

class StoryReactionBloc extends Bloc<StoryReactionEvent, StoryReactionState> {
  final StoryApiService apiService=StoryApiService();

  StoryReactionBloc() : super(ReactionInitial()) {
    on<FetchReactionsEvent>(_onFetchReactions);
    on<PostCommentEvent>(_onPostComment);
  }

  Future<void> _onFetchReactions(
      FetchReactionsEvent event,
      Emitter<StoryReactionState> emit,
      ) async {
    emit(ReactionLoading());
    try {
     Map<String,dynamic> likesData = await apiService.fetchLikes(event.storyId);
     Map<String,dynamic> commentsData = await apiService.fetchComments(event.storyId);

     List<Map<String, dynamic>> likes =List<Map<String, dynamic>>.from(likesData["likes"]).toList();
     List<Map<String, dynamic>> comments =List<Map<String, dynamic>>.from(commentsData["comments"]).toList();
     Map<String, dynamic> pagination =Map<String, dynamic>.from(commentsData["pagination"]);


     print("likes $likes");
     print("comments $comments");

      emit(ReactionLoaded(
        likes: likes,
        comments: comments,
        pagination: pagination,
      ));
    } catch (e) {
      print("error${e.toString()}");
      emit(ReactionError(e.toString()));
    }
  }

  Future<void> _onPostComment(
      PostCommentEvent event,
      Emitter<StoryReactionState> emit,
      ) async {
    if(state is ReactionLoaded){
      final currentState = state as ReactionLoaded;

      try {

        Map<String,dynamic> newComment = await apiService.postComment(event.storyId, event.comment);
        List<Map<String, dynamic>> updatedComments =[
          newComment,
          ...currentState.comments
        ];

        emit(ReactionLoaded(likes: currentState.likes, comments: updatedComments, pagination: currentState.pagination

        ));

      //  add(FetchReactionsEvent(event.storyId)); // Refresh the reactions
      } catch (e) {
        emit(ReactionLoaded(likes: currentState.likes, comments: currentState.comments, pagination: currentState.pagination));

            emit(ReactionError(e.toString()));
      }
    }
  }
}
