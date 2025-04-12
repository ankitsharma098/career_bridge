part of 'candidate_registration_bloc.dart';

@immutable
abstract class CandidateRegistrationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UploadDocumentEvent extends CandidateRegistrationEvent {
  final PlatformFile file;
  final String docType;

  UploadDocumentEvent({required this.file, required this.docType});

  @override
  List<Object?> get props => [file, docType];
}

class SendOtpEvent extends CandidateRegistrationEvent {
  final String email;

  SendOtpEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyOtpEvent extends CandidateRegistrationEvent {
  final String email;
  final String otp;

  VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class RegisterCandidateEvent extends CandidateRegistrationEvent {
  final Map<String, dynamic> personalInfo;
  final Map<String, dynamic> disabilityDetails;
  final List<String> skills;
  final Map<String, dynamic> jobPreferences;
  final Map<String, dynamic> auth;

  RegisterCandidateEvent(this.personalInfo, this.disabilityDetails, this.skills,
      this.jobPreferences, this.auth);

  @override
  List<Object?> get props =>
      [personalInfo, disabilityDetails, skills, jobPreferences, auth];
}
