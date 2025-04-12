import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/auth_api_service.dart';

part 'candidate_registration_event.dart';
part 'candidate_registration_state.dart';

class CandidateRegistrationBloc
    extends Bloc<CandidateRegistrationEvent, CandidateRegistrationState> {
  final AuthApiServices _apiService = AuthApiServices();

  CandidateRegistrationBloc() : super(CandidateRegistrationInitial()) {
    on<UploadDocumentEvent>(_onUploadDocument);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<RegisterCandidateEvent>(_onRegisterCandidate);
  }
  Future<void> _onUploadDocument(UploadDocumentEvent event,
      Emitter<CandidateRegistrationState> emit) async {
    try {
      emit(DocumentUploading());

      final result = await _apiService.uploadMedia(File(event.file.path!));

      emit(DocumentUploaded(
          url: result['url'].toString(),
          publicId: result['publicId'].toString()));
    } catch (e) {
      emit(RegistrationFailure(
          error: 'Failed to upload document: ${e.toString()}'));
    }
  }

  Future<void> _onSendOtp(
      SendOtpEvent event, Emitter<CandidateRegistrationState> emit) async {
    try {
      emit(OtpSending());

      // Check if email already exists
      //   final emailExists = await _apiService.checkEmailExists(event.email);
      // final emailExists = true;
      // if (emailExists) {
      //   emit(EmailExists());
      //   return;
      // }

      // Send OTP
      await _apiService.sendOtp(event.email);
      emit(OtpSent());
    } catch (e) {
      emit(RegistrationFailure(error: 'Failed to send OTP: ${e.toString()}'));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<CandidateRegistrationState> emit) async {
    try {
      emit(OtpVerifying());

      final token = await _apiService.verifyOtp(event.email, event.otp);
      emit(OtpVerified(token: token));
    } catch (e) {
      emit(RegistrationFailure(
          error: 'Invalid OTP or verification failed: ${e.toString()}'));
    }
  }

  Future<void> _onRegisterCandidate(RegisterCandidateEvent event,
      Emitter<CandidateRegistrationState> emit) async {
    try {
      emit(RegistrationLoading());

      // Register candidate
      await _apiService.candidateCompleteRegistration(
        personalInfo: event.personalInfo,
        disabilityDetails: event.disabilityDetails,
        skills: event.skills,
        jobPreferences: event.jobPreferences,
        auth: event.auth,
      );
      emit(RegistrationSuccess());
    } catch (e) {
      emit(RegistrationFailure(error: 'Registration failed: ${e.toString()}'));
    }
  }
}
