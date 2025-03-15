part of 'candidate_job_bloc.dart';

@immutable
sealed class CandidateJobEvent {}

class FetchJobs extends CandidateJobEvent {
  final bool isRecommended;
  final String? search; // Add search parameter

  FetchJobs({required this.isRecommended, this.search});
}

class LoadMoreJobs extends CandidateJobEvent {
  final bool isRecommended;
  final String? search; // Add search parameter

  LoadMoreJobs({required this.isRecommended, this.search});
}

class ToggleSavedJobsEvent extends CandidateJobEvent{

  final String jobId;

  ToggleSavedJobsEvent({required this.jobId});
}