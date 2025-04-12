part of 'employer_registration_bloc.dart';

abstract class EmployerRegistrationState extends Equatable {
  const EmployerRegistrationState();

  @override
  List<Object> get props => [];
}

class RegistrationInitial extends EmployerRegistrationState {}

class RegistrationLoading extends EmployerRegistrationState {}

class CompanyNotFound extends EmployerRegistrationState {}

class CompanyExists extends EmployerRegistrationState {
  final String message;

  const CompanyExists({required this.message});

  @override
  List<Object> get props => [message];
}

class DocumentUploaded extends EmployerRegistrationState {
  final String url;
  final String publicId;

  const DocumentUploaded({required this.url, required this.publicId});

  @override
  List<Object> get props => [url, publicId];
}

class OtpSent extends EmployerRegistrationState {}

class OtpVerified extends EmployerRegistrationState {
  final String token;

  const OtpVerified({required this.token});

  @override
  List<Object> get props => [token];
}

class RegistrationSuccess extends EmployerRegistrationState {}

class RegistrationFailure extends EmployerRegistrationState {
  final String error;

  const RegistrationFailure({required this.error});

  @override
  List<Object> get props => [error];
}
