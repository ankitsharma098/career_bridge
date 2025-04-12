import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/story_api_service.dart';

part 'story_reaction_event.dart';
part 'story_reaction_state.dart';

class StoryReactionBloc extends Bloc<StoryReactionEvent, StoryReactionState> {
  final StoryApiService apiService = StoryApiService();

  StoryReactionBloc() : super(ReactionInitial()) {
    on<FetchReactionsEvent>(_onFetchReactions);
    on<PostCommentEvent>(_onPostComment);
    on<PostCommentUpdate>(_onPostCommentUpdate);
    on<CommentDelete>(_onCommentDelete);
  }

  Future<void> _onFetchReactions(
    FetchReactionsEvent event,
    Emitter<StoryReactionState> emit,
  ) async {
    emit(ReactionLoading());
    try {
      Map<String, dynamic> likesData =
          await apiService.fetchLikes(event.storyId);
      Map<String, dynamic> commentsData =
          await apiService.fetchComments(event.storyId);

      List<Map<String, dynamic>> likes =
          List<Map<String, dynamic>>.from(likesData["likes"]).toList();
      List<Map<String, dynamic>> comments =
          List<Map<String, dynamic>>.from(commentsData["comments"]).toList();
      Map<String, dynamic> pagination =
          Map<String, dynamic>.from(commentsData["pagination"]);

      emit(ReactionLoaded(
        likes: likes,
        comments: comments,
        pagination: pagination,
      ));
    } catch (e) {
      if (kDebugMode) {
        print("error${e.toString()}");
      }
      emit(ReactionError(e.toString()));
    }
  }

  Future<void> _onPostComment(
    PostCommentEvent event,
    Emitter<StoryReactionState> emit,
  ) async {
    if (state is ReactionLoaded) {
      final currentState = state as ReactionLoaded;

      try {
        Map<String, dynamic> newComment =
            await apiService.postComment(event.storyId, event.comment);
        List<Map<String, dynamic>> updatedComments = [
          newComment,
          ...currentState.comments
        ];

        emit(ReactionLoaded(
            likes: currentState.likes,
            comments: updatedComments,
            pagination: currentState.pagination));

        //  add(FetchReactionsEvent(event.storyId)); // Refresh the reactions
      } catch (e) {
        emit(ReactionLoaded(
            likes: currentState.likes,
            comments: currentState.comments,
            pagination: currentState.pagination));

        emit(ReactionError(e.toString()));
      }
    }
  }

  Future<void> _onPostCommentUpdate(
      PostCommentUpdate event, Emitter<StoryReactionState> emit) async {
    if (state is ReactionLoaded) {
      final currentState = state as ReactionLoaded;

      try {
        if (kDebugMode) {
          print(("comment update ---------- new comment ---${event.comment}"));
        }

        Map<String, dynamic> updatedComment = await apiService.updateComment(
            event.storyId, event.commentId, event.comment);

        if (kDebugMode) {
          print("new comment $updatedComment");
        }
        List<Map<String, dynamic>> updatedComments =
            currentState.comments.map((comment) {
          if (comment["_id"] == event.commentId) {
            return {
              ...comment,
              ...updatedComment
            }; // Merge the updated comment data
          }
          return comment;
        }).toList();

        emit(ReactionLoaded(
            likes: currentState.likes,
            comments: updatedComments,
            pagination: currentState.pagination));

        //  add(FetchReactionsEvent(event.storyId)); // Refresh the reactions
      } catch (e) {
        emit(ReactionLoaded(
            likes: currentState.likes,
            comments: currentState.comments,
            pagination: currentState.pagination));

        emit(ReactionError(e.toString()));
      }
    }
  }

  Future<void> _onCommentDelete(
      CommentDelete event, Emitter<StoryReactionState> emit) async {
    if (state is ReactionLoaded) {
      final currentState = state as ReactionLoaded;

      try {
        bool success =
            await apiService.deleteComment(event.storyId, event.commentId);

        if (kDebugMode) {
          print("new comment $success");
        }
        if (success) {
          List<Map<String, dynamic>> updatedComments = currentState.comments
              .where((comment) => comment["_id"] != event.commentId)
              .toList();

          emit(ReactionLoaded(
              likes: currentState.likes,
              comments: updatedComments,
              pagination: currentState.pagination));
        } else {
          emit(ReactionLoaded(
              likes: currentState.likes,
              comments: currentState.comments,
              pagination: currentState.pagination));
        }
      } catch (e) {
        emit(ReactionLoaded(
            likes: currentState.likes,
            comments: currentState.comments,
            pagination: currentState.pagination));

        emit(ReactionError(e.toString()));
      }
    }
  }
}
