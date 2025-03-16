part of 'candidate_job_stats_bloc.dart';

@immutable
sealed class CandidateJobStatsState {}

final class CandidateJobStatsInitial extends CandidateJobStatsState {}

class JobStatsLoading extends CandidateJobStatsState {}

class JobsLoading extends CandidateJobStatsState {}

class JobStatsLoaded extends CandidateJobStatsState {
  final Map<String,dynamic> stats;

  JobStatsLoaded({required this.stats});

}


class JobLoaded extends CandidateJobStatsState {

  final List<CandidateJobModel> jobs;
  final bool hasReachedMax;
  final int currentPage;

  JobLoaded({required this.jobs, required this.hasReachedMax, required this.currentPage});

}

class JobStatsSuccess extends CandidateJobStatsState {
  final String message;

  JobStatsSuccess({required this.message});
}

class JobStatsError extends CandidateJobStatsState {
  final String error ;

  JobStatsError({required this.error});
}