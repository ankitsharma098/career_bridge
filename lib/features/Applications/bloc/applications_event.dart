part of 'applications_bloc.dart';

@immutable
sealed class ApplicationsEvent {}

class FetchApplications extends ApplicationsEvent {

  final String jobId;

  FetchApplications({required this.jobId});

}

class UpdateApplicationStatus extends ApplicationsEvent {
  final String applicationId;
  final String jobId;
  final String newStatus;

  UpdateApplicationStatus(this.applicationId, this.newStatus, this.jobId);

}

class RemoveApplication extends ApplicationsEvent {
  final String applicationId;
  final String jobId;
  RemoveApplication(this.applicationId, this.jobId);

}
