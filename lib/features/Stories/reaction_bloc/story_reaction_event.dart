part of 'story_reaction_bloc.dart';

@immutable
sealed class StoryReactionEvent  extends Equatable{
  @override
  List<Object?> get props => [];
}

class FetchReactionsEvent extends StoryReactionEvent {
  final String storyId;
  FetchReactionsEvent(this.storyId);

  @override
  List<Object?> get props => [storyId];
}

class PostCommentEvent extends StoryReactionEvent {
  final String storyId;
  final String comment;

  PostCommentEvent(this.storyId, this.comment);

  @override
  List<Object?> get props => [storyId, comment];
}

class CommentDelete extends StoryReactionEvent{
  final String storyId;
  final String commentId;

  CommentDelete({required this.storyId, required this.commentId});
  @override
  // TODO: implement props
  List<Object?> get props => [storyId,commentId];

}

class PostCommentUpdate extends StoryReactionEvent{
  final String storyId;
  final String comment;
  final String commentId;

  PostCommentUpdate({required this.storyId, required this.comment, required this.commentId});
  @override
  // TODO: implement props
  List<Object?> get props => [storyId,comment,commentId];

}