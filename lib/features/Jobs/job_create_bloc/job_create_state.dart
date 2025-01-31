part of 'job_create_bloc.dart';

@immutable
sealed class JobCreateState {}

final class JobCreateInitial extends JobCreateState {}

class JobCreationLoading extends JobCreateState {}
class JobCreationSuccess extends JobCreateState {

  final JobModel job;

  JobCreationSuccess({required this.job});
}
class JobCreationError extends JobCreateState {

  final String error;

  JobCreationError({required this.error});
}
