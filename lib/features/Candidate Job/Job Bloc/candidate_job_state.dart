part of 'candidate_job_bloc.dart';

@immutable
sealed class CandidateJobState {}

final class CandidateJobInitial extends CandidateJobState {}

class JobLoading extends CandidateJobState {}

class JobLoaded extends CandidateJobState {

  final List<CandidateJobModel> jobs;
  final bool hasReachedMax;
  final int currentPage;

  JobLoaded({required this.jobs, required this.hasReachedMax, required this.currentPage});

}

class JobSuccess extends CandidateJobState {
  final String message ;

  JobSuccess({required this.message});
}
class JobError extends CandidateJobState {
  final String error;

  JobError({required this.error});

}
