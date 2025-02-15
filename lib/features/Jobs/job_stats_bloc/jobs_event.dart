part of 'jobs_bloc.dart';

@immutable
sealed class JobsStatsEvent {}

class FetchJobStats extends JobsStatsEvent {}

