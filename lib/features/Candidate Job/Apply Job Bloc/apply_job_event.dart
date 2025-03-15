part of 'apply_job_bloc.dart';

@immutable
sealed class ApplyJobEvent {}

class SubmitApplication extends ApplyJobEvent {
  final String jobId;
  final bool isFresher;
  final List<Map<String, String>> experiences;
  final Map<String, String> contactInfo;
  final String resumeUrl;
  SubmitApplication({
    required this.jobId,
    required this.isFresher,
    required this.experiences,
    required this.contactInfo,
    required this.resumeUrl,
  });
}

class UploadDocumentEvent extends ApplyJobEvent {
  final String filePath;
  UploadDocumentEvent({required this.filePath});
}