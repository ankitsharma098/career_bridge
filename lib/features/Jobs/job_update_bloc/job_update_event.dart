part of 'job_update_bloc.dart';

@immutable
sealed class JobUpdateEvent {}

class UpdateJobEvent extends JobUpdateEvent {

  final Map<String,dynamic> job;
  final String jobId;

  UpdateJobEvent({required this.job, required this.jobId});

}