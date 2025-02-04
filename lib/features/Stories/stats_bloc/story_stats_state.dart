part of 'story_stats_bloc.dart';

@immutable
sealed class StoryStatsState {}

final class StoryStatsInitial extends StoryStatsState {}

class StoryStatsLoading extends StoryStatsState {}

class StoryStatsLoaded extends StoryStatsState {

  final Map<String,dynamic> stats;

  StoryStatsLoaded({required this.stats});



}

class StoryStatsError extends StoryStatsState {

  final String error;

  StoryStatsError({required this.error});

}