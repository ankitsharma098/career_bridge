import 'package:android/features/Jobs/data_services/jobs_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/Job/job_model.dart';

part 'job_update_event.dart';
part 'job_update_state.dart';

class JobUpdateBloc extends Bloc<JobUpdateEvent, JobUpdateState> {
  JobApiService apiService = JobApiService();
  JobUpdateBloc() : super(JobUpdateInitial()) {
    on<UpdateJobEvent>(_onUpdateJobEvent);
  }

  Future<void> _onUpdateJobEvent(UpdateJobEvent event, Emitter<JobUpdateState> emit) async {

    try{
      print("Event update");
      emit(JobUpdateLoading());

     bool success= await apiService.updateJob(event.job, event.jobId);

     if(success){

       emit(JobUpdateSuccess(job: JobModel.fromJson(event.job)));
     }else{
       emit (JobUpdateError(error: "Failed to Update a job"));
     }

    }catch(e){
      emit (JobUpdateError(error: e.toString()));
    }

  }

}
