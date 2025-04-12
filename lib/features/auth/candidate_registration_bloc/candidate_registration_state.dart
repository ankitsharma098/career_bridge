part of 'candidate_registration_bloc.dart';

@immutable
abstract class CandidateRegistrationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class CandidateRegistrationInitial extends CandidateRegistrationState {}

class RegistrationLoading extends CandidateRegistrationState {}

class DocumentUploading extends CandidateRegistrationState {}

class DocumentUploaded extends CandidateRegistrationState {
  final String url;
  final String publicId;

  DocumentUploaded({required this.url, required this.publicId});

  @override
  List<Object?> get props => [url, publicId];
}

class OtpSending extends CandidateRegistrationState {}

class OtpSent extends CandidateRegistrationState {}

class OtpVerifying extends CandidateRegistrationState {}

class OtpVerified extends CandidateRegistrationState {
  final String token;

  OtpVerified({required this.token});

  @override
  List<Object?> get props => [token];
}

class RegistrationSuccess extends CandidateRegistrationState {}

class EmailExists extends CandidateRegistrationState {}

class RegistrationFailure extends CandidateRegistrationState {
  final String error;

  RegistrationFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
