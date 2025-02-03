part of 'applications_bloc.dart';

@immutable
sealed class ApplicationsState {}

final class ApplicationsInitial extends ApplicationsState {}

class ApplicationLoading extends ApplicationsState {}

class ApplicationLoaded extends ApplicationsState {

  final JobApplicationResponse applications;

  ApplicationLoaded({required this.applications});


}

class ApplicationStatusChangedSuccess extends ApplicationsState {

  final String message;

  ApplicationStatusChangedSuccess(this.message);
}
class ApplicationError extends ApplicationsState {

  final String error;

  ApplicationError({required this.error});
}