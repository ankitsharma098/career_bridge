import 'dart:io';
import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'employer_registration_event.dart';
part 'employer_registration_state.dart';

class EmployerRegistrationBloc
    extends Bloc<EmployerRegistrationEvent, EmployerRegistrationState> {
  final AuthApiServices _apiService = AuthApiServices();

  EmployerRegistrationBloc() : super(RegistrationInitial()) {
    on<CheckCompanyEvent>(_onCheckCompany);
    on<UploadDocumentEvent>(_onUploadDocument);
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<SubmitRegistrationEvent>(_onSubmitRegistration);
  }

  Future<void> _onCheckCompany(
      CheckCompanyEvent event, Emitter<EmployerRegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      final result =
          await _apiService.checkCompany(event.email, event.companyName);
      if (result['exists']) {
        print("company exist");
        emit(CompanyExists(message: result['message']));
      } else {
        print("not exits");
        emit(CompanyNotFound());
        print("Emitted CompanyNotFound"); // Add this
      }
    } catch (e) {
      emit(RegistrationFailure(error: e.toString()));
    }
  }

  Future<void> _onUploadDocument(UploadDocumentEvent event,
      Emitter<EmployerRegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      final result = await _apiService.uploadMedia(File(event.filePath));
      print("upload document ----------------$result");
      emit(DocumentUploaded(
          url: result['url'].toString(),
          publicId: result['publicId'].toString()));
    } catch (e) {
      emit(RegistrationFailure(error: e.toString()));
    }
  }

  Future<void> _onSendOtp(
      SendOtpEvent event, Emitter<EmployerRegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      await _apiService.sendOtp(event.email);
      emit(OtpSent());
    } catch (e) {
      emit(RegistrationFailure(error: e.toString()));
    }
  }

  Future<void> _onVerifyOtp(
      VerifyOtpEvent event, Emitter<EmployerRegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      final token = await _apiService.verifyOtp(event.email, event.otp);
      emit(OtpVerified(token: token));
    } catch (e) {
      emit(RegistrationFailure(error: e.toString()));
    }
  }

  Future<void> _onSubmitRegistration(SubmitRegistrationEvent event,
      Emitter<EmployerRegistrationState> emit) async {
    emit(RegistrationLoading());
    try {
      await _apiService.employerCompleteRegistration(
        companyData: event.companyData,
        employerData: event.employerData,
        documentUrls: event.documentUrls,
      );
      emit(RegistrationSuccess());
    } catch (e) {
      emit(RegistrationFailure(error: e.toString()));
    }
  }
}
