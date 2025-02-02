part of 'job_update_bloc.dart';

@immutable
sealed class JobUpdateState {}

final class JobUpdateInitial extends JobUpdateState {}

class JobUpdateLoading extends JobUpdateState {}

class JobUpdateSuccess extends JobUpdateState {

  final JobModel job;

  JobUpdateSuccess({required this.job});
}

class JobUpdateError extends JobUpdateState {

  final String error;

  JobUpdateError({required this.error});

}
