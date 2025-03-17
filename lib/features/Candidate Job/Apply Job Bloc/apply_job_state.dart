part of 'apply_job_bloc.dart';

@immutable
sealed class ApplyJobState {}

final class ApplyJobInitial extends ApplyJobState {}

class ApplicationsLoading extends ApplyJobState {}

class ApplicationStatusLoaded extends ApplyJobState{

  final Application applicationStatus;

  ApplicationStatusLoaded({required this.applicationStatus});

}

class ApplicationsSuccess extends ApplyJobState {
  final String message;
  ApplicationsSuccess(this.message);
}
class DocumentUploaded extends ApplyJobState {
  final String url;
  DocumentUploaded(this.url);
}
class ApplicationsError extends ApplyJobState {
  final String error;
  ApplicationsError(this.error);
}