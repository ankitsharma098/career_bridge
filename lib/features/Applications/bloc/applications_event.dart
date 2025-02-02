part of 'applications_bloc.dart';

@immutable
sealed class ApplicationsEvent {}

class FetchApplications extends ApplicationsEvent {

  final String jobId;

  FetchApplications({required this.jobId});

}

class UpdateApplicationStatus extends ApplicationsEvent {
  final String applicationId;
  final String newStatus;

  UpdateApplicationStatus(this.applicationId, this.newStatus);

}

class RemoveApplication extends ApplicationsEvent {
  final String applicationId;

  RemoveApplication(this.applicationId);

}
