part of 'job_create_bloc.dart';

@immutable
sealed class JobCreateEvent {}

class SubmitJobEvent extends JobCreateEvent {
  final Map<String,dynamic> job;

  SubmitJobEvent({required this.job});

}
