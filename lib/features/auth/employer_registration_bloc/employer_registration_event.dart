part of 'employer_registration_bloc.dart';

abstract class EmployerRegistrationEvent extends Equatable {
  const EmployerRegistrationEvent();

  @override
  List<Object> get props => [];
}

class CheckCompanyEvent extends EmployerRegistrationEvent {
  final String email;
  final String companyName;

  const CheckCompanyEvent({required this.email, required this.companyName});

  @override
  List<Object> get props => [email, companyName];
}

class UploadDocumentEvent extends EmployerRegistrationEvent {
  final String filePath;

  const UploadDocumentEvent({required this.filePath});

  @override
  List<Object> get props => [filePath];
}

class SendOtpEvent extends EmployerRegistrationEvent {
  final String email;

  const SendOtpEvent({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyOtpEvent extends EmployerRegistrationEvent {
  final String email;
  final String otp;

  const VerifyOtpEvent({required this.email, required this.otp});

  @override
  List<Object> get props => [email, otp];
}

class SubmitRegistrationEvent extends EmployerRegistrationEvent {
  final Map<String, dynamic> companyData;
  final Map<String, dynamic> employerData;
  final Map<String, Map<String, String>> documentUrls;

  const SubmitRegistrationEvent({
    required this.companyData,
    required this.employerData,
    required this.documentUrls,
  });

  @override
  List<Object> get props => [companyData, employerData, documentUrls];
}
