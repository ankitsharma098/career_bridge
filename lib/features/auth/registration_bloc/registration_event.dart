part of 'registration_bloc.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class CheckCompanyEvent extends RegistrationEvent {
  final String email;
  final String companyName;

  const CheckCompanyEvent({required this.email, required this.companyName});

  @override
  List<Object> get props => [email, companyName];
}

class UploadDocumentEvent extends RegistrationEvent {
  final String filePath;

  const UploadDocumentEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class SendOtpEvent extends RegistrationEvent {
  final String email;

  const SendOtpEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyOtpEvent extends RegistrationEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

class SubmitRegistrationEvent extends RegistrationEvent {
  final Map<String, dynamic> companyData;
  final Map<String, dynamic> employerData;
  final Map<String, Map<String, String>> documentUrls;
  final String verificationToken;

  const SubmitRegistrationEvent({
    required this.companyData,
    required this.employerData,
    required this.documentUrls,
    required this.verificationToken,
  });

  @override
  List<Object> get props => [companyData, employerData, documentUrls, verificationToken];
}