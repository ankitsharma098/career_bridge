part of 'story_reaction_bloc.dart';

@immutable
sealed class StoryReactionState extends Equatable{
  @override
  List<Object?> get props => [];
}

class ReactionInitial extends StoryReactionState {}

class ReactionLoading extends StoryReactionState {}

class ReactionLoaded extends StoryReactionState {
  final List<Map<String, dynamic>> likes;
  final List<Map<String, dynamic>> comments;
  final Map<String, dynamic> pagination;

  ReactionLoaded({
    required this.likes,
    required this.comments,
    required this.pagination,
  });

  @override
  List<Object?> get props => [likes, comments, pagination];
}

class ReactionError extends StoryReactionState {
  final String message;
  ReactionError(this.message);

  @override
  List<Object?> get props => [message];
}
