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
      //await repository.updateStatus(event.applicationId, event.newStatus);
      //add(FetchApplications());
    } catch (e) {
      emit(ApplicationError( error: e.toString()));
    }
  }

  Future<void> _onRemoveApplication(
      RemoveApplication event,
      Emitter<ApplicationsState> emit,
      ) async {
    try {
      //await repository.removeApplication(event.applicationId);
    //  add(FetchApplications());
    } catch (e) {
      emit(ApplicationError( error: e.toString()));
    }
  }
}
