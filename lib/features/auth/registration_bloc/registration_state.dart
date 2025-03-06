part of 'registration_bloc.dart';

abstract class RegistrationState extends Equatable {
  const RegistrationState();

  @override
  List<Object> get props => [];
}

class RegistrationInitial extends RegistrationState {}

class RegistrationLoading extends RegistrationState {}

class CompanyNotFound extends RegistrationState {}

class CompanyExists extends RegistrationState {
  final String message;

  const CompanyExists({required this.message});

  @override
  List<Object> get props => [message];
}

class DocumentUploaded extends RegistrationState {
  final String url;
  final String publicId;

  const DocumentUploaded({required this.url, required this.publicId});

  @override
  List<Object> get props => [url, publicId];
}

class OtpSent extends RegistrationState {}

class OtpVerified extends RegistrationState {
  final String token;

  const OtpVerified({required this.token});

  @override
  List<Object> get props => [token];
}

class RegistrationSuccess extends RegistrationState {}

class RegistrationFailure extends RegistrationState {
  final String error;

  const RegistrationFailure({required this.error});

  @override
  List<Object> get props => [error];
}