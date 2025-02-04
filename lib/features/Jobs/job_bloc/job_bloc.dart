import 'package:android/features/Jobs/data_services/jobs_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/models/Job/job_model.dart';

part 'job_event.dart';
part 'job_state.dart';

class JobBloc extends Bloc<JobEvent, JobState> {

  JobApiService apiService = JobApiService();
  JobBloc() : super(JobInitial()) {
    on<FetchJobs>(_onFetchJobs);
    on<LoadMoreJobs>(_onLoadMoreJobs);
  }

  Future<void> _onFetchJobs(FetchJobs event,Emitter<JobState> emit) async{


    try{

      emit(JobLoading());
      List<JobModel> jobs = await apiService.fetchPostedJobs(1);


      emit(JobLoaded(jobs: jobs, hasReachedMax: false, currentPage: 1));


    }catch(e){
      emit(JobError(e.toString()));
    }


  }

  Future<void> _onLoadMoreJobs(LoadMoreJobs event,Emitter<JobState> emit) async {

    final currentState=state;
    if(currentState is JobLoaded){

      if(!currentState.hasReachedMax) {
        try{
          final nextPage = currentState.currentPage+1;
          List<JobModel> newJobs= await apiService.fetchPostedJobs(nextPage);
          if (newJobs.isEmpty) {
            emit(JobLoaded(
              jobs: currentState.jobs,
              hasReachedMax: true,
              currentPage: currentState.currentPage,
            ));

        }else {
            emit(JobLoaded(
              jobs: [...currentState.jobs, ...newJobs],
              hasReachedMax: false, currentPage: nextPage,
            ));
          }
        }catch(e){
          emit(JobError(e.toString()));
        }
      }
    }


  }
}
