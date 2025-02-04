part of 'story_stats_bloc.dart';

@immutable
sealed class StoryStatsEvent {}

class FetchStoryStats extends StoryStatsEvent{}
