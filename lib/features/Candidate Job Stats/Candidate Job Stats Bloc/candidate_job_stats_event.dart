part of 'candidate_job_stats_bloc.dart';

@immutable
sealed class CandidateJobStatsEvent {}

class FetchJobStats extends CandidateJobStatsEvent {

}

class FetchJobEvent extends CandidateJobStatsEvent {

  final bool isSaved;

  FetchJobEvent({required this.isSaved});
}

class LoadMoreJobs extends CandidateJobStatsEvent {

  final bool isSaved;

  LoadMoreJobs({required this.isSaved});

}

class ToggleSavedJobEvent extends CandidateJobStatsEvent {
  final String jobId;
  ToggleSavedJobEvent(this.jobId);
}