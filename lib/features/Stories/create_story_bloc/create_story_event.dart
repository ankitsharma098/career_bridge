part of 'create_story_bloc.dart';

abstract class StoryCreationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmitStoryEvent extends StoryCreationEvent {
  // final String title;
  // final String content;
  // final File? mediaFile;
  // final List<String> tags;
  // final String category;
  final Map<String,dynamic> story;
  final bool isEditing; // Add this
  final String storyId;

  SubmitStoryEvent( {required this.storyId, required this.isEditing, required this.story});
  @override
  List<Object?> get props => [story];
}


