part of 'create_story_bloc.dart';

abstract class StoryCreationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StoryCreationInitial extends StoryCreationState {}

class StoryCreationLoading extends StoryCreationState {}

class StoryCreationSuccess extends StoryCreationState {}

class StoryCreationError extends StoryCreationState {
  final String error;

  StoryCreationError(this.error);

  @override
  List<Object> get props => [error];
}

class StoryCreationEditing extends StoryCreationState {
  final String title;
  final String content;
  final File? mediaFile;
  final List<String> tags;
  final String category;

  StoryCreationEditing({
    required this.title,
    required this.content,
    this.mediaFile,
    required this.tags,
    required this.category,
  });

  @override
  List<Object?> get props => [title, content, mediaFile, tags, category];
}