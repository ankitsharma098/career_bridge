import 'dart:io';

import 'package:android/data/models/application/application_model.dart';
import 'package:android/features/Applications/data/application_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'applications_event.dart';
part 'applications_state.dart';

class ApplicationsBloc extends Bloc<ApplicationsEvent, ApplicationsState> {
  ApplicationApiService apiService =ApplicationApiService();
  ApplicationsBloc() : super(ApplicationsInitial()) {
    on<FetchApplications>(_onFetchApplications);
    on<UpdateApplicationStatus>(_onUpdateStatus);
    on<RemoveApplication>(_onRemoveApplication);
  }

  Future<void> _onFetchApplications(FetchApplications event,Emitter<ApplicationsState> emit) async{
    emit(ApplicationLoading());
    try{
      print("fetch event");

      JobApplicationResponse application = await apiService.fetchApplication(event.jobId);

      emit(ApplicationLoaded( applications: application));

    }catch(e){
      emit(ApplicationError(error: e.toString()));
    }

  }

  Future<void> _onUpdateStatus(
      UpdateApplicationStatus event,
      Emitter<ApplicationsState> emit,
      ) async {
    try {

      bool success = await apiService.updateApplicationStatus(event.applicationId, event.newStatus);
      if(success){

        emit(ApplicationStatusChangedSuccess("Status ${event.newStatus} Changed Successfully"));
        add(FetchApplications(jobId: event.jobId));
      }else{
        emit(ApplicationError( error:"Failed to change the Status"));
      }
    } catch (e) {
      emit(ApplicationError( error: e.toString()));
    }
  }

  Future<void> _onRemoveApplication(
      RemoveApplication event,
      Emitter<ApplicationsState> emit,
      ) async {
    try {
      bool success = await apiService.removeApplicants(event.applicationId);
      if(success){

        emit(ApplicationStatusChangedSuccess("Application Removed Successfully"));
        add(FetchApplications(jobId: event.jobId));
      }else{
        emit(ApplicationError( error:"Failed to change the Status"));
      }
    } catch (e) {
      emit(ApplicationError( error: e.toString()));
    }
  }
}
