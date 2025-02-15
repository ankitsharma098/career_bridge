part of 'jobs_bloc.dart';

@immutable
sealed class JobStatsState {}

final class JobStatsInitial extends JobStatsState {}

class JobStatsLoading extends JobStatsState {}

class JobStatsLoaded extends JobStatsState {
  final Map<String,dynamic> stats;

  JobStatsLoaded(this.stats);

}


class  JobStatsError extends JobStatsState {

  final String error;

  JobStatsError(this.error);

}


