part of 'create_story_bloc.dart';

abstract class StoryCreationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitStoryEvent extends StoryCreationEvent {
  final String title;
  final String content;
  final File? mediaFile;
  final List<String> tags;
  final String category;

  SubmitStoryEvent({
    required this.title,
    required this.content,
    this.mediaFile,
    required this.tags,
    required this.category,
  });

  @override
  List<Object?> get props => [title, content, mediaFile, tags, category];
}

class UpdateMediaEvent extends StoryCreationEvent {
  final File mediaFile;

  UpdateMediaEvent(this.mediaFile);

  @override
  List<Object> get props => [mediaFile];
}

class UpdateTagsEvent extends StoryCreationEvent {
  final List<String> tags;

  UpdateTagsEvent(this.tags);

  @override
  List<Object> get props => [tags];
}