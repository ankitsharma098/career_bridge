import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/application/application_model.dart';
import '../../auth/data/auth_api_service.dart';
import '../data/api_service.dart';

part 'apply_job_event.dart';
part 'apply_job_state.dart';

class ApplyJobBloc extends Bloc<ApplyJobEvent, ApplyJobState> {
  CandidateJobServices apiService = CandidateJobServices();
  ApplyJobBloc() : super(ApplyJobInitial()) {
    on<SubmitApplication>(_onSubmitApplication);
    on<FetchApplicationStatus>(_onFetchApplicationStatus);
    on<UploadDocumentEvent>(_onUploadDocumentEvent);
  }

  Future<void>_onSubmitApplication(SubmitApplication event , Emitter<ApplyJobState> emit) async {
    emit(ApplicationsLoading());
    try {

      final response = await apiService.submitApplicationToBackend(
        jobId: event.jobId,
        isFresher: event.isFresher,
        experiences: event.experiences,
        contactInfo: event.contactInfo,
        resumeUrl: event.resumeUrl,
      );

      emit(ApplicationsSuccess('Application submitted successfully'));
    } catch (e) {
      emit(ApplicationsError(e.toString()));
    }

  }

  Future<void>_onUploadDocumentEvent(UploadDocumentEvent event , Emitter<ApplyJobState> emit) async {
    emit(ApplicationsLoading());
    try {
      AuthApiServices mediaService =AuthApiServices();
      final result = await mediaService.uploadMedia(File(event.filePath));
      emit(DocumentUploaded(result['url'].toString()));
    } catch (e) {
      emit(ApplicationsError('Failed to upload resume: $e'));
    }
  }

  Future<void>_onFetchApplicationStatus(FetchApplicationStatus event , Emitter<ApplyJobState> emit) async {
    emit(ApplicationsLoading());
    try {

      Application applicationStatus= await apiService.fetchApplicationStatus( jobId: event.jobId);

      print("Parsing done ------");

      emit(ApplicationStatusLoaded(applicationStatus: applicationStatus));


    } catch (e) {
      emit(ApplicationsError('Failed to upload resume: $e'));
    }
  }
}
