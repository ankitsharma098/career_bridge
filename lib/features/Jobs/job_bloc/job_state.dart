part of 'job_bloc.dart';

@immutable
sealed class JobState {}

final class JobInitial extends JobState {}

class JobLoading extends JobState {}

class JobLoaded extends JobState {

  final List<JobModel> jobs;
  final bool hasReachedMax;
  final int currentPage;

  JobLoaded({required this.jobs, required this.hasReachedMax, required this.currentPage});

}

class JobError extends JobState {

  final String error;

  JobError(this.error);

}