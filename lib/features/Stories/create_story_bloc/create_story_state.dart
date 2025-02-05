part of 'create_story_bloc.dart';

abstract class StoryCreationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoryCreationInitial extends StoryCreationState {}

class StoryCreationLoading extends StoryCreationState {}

class StoryCreationSuccess extends StoryCreationState {

  final StoryModel story;

  StoryCreationSuccess({required this.story});
  @override
  // TODO: implement props
  List<Object?> get props => [story];

}

class StoryCreationError extends StoryCreationState {
  final String error;

  StoryCreationError(this.error);

  @override
  List<Object> get props => [error];
}

class StoryCreationEditing extends StoryCreationState {
  final StoryModel story;

  StoryCreationEditing(
    this.story
  );

  @override
  List<Object?> get props => [story];
}
