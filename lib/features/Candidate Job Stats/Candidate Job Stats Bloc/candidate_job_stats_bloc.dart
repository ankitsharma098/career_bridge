import 'package:android/features/Candidate%20Job/model/candidate_job_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/Candidate_job_stats.dart';

part 'candidate_job_stats_event.dart';
part 'candidate_job_stats_state.dart';

class CandidateJobStatsBloc extends Bloc<CandidateJobStatsEvent, CandidateJobStatsState> {
  CandidateJobStatsApi apiService = CandidateJobStatsApi();
  CandidateJobStatsBloc() : super(CandidateJobStatsInitial()) {
    on<FetchJobStats>(_onFetchJobStats);
    on<FetchJobEvent>(_onFetchJobEvent);
    on<LoadMoreJobs>(_onLoadMoreJobs);
    on<ToggleSavedJobEvent>(_onToggleSavedJobEvent);
  }


  Future<void> _onFetchJobStats(FetchJobStats event, Emitter<CandidateJobStatsState> emit) async {


    try{
      emit(JobStatsLoading());

      Map<String,dynamic> stats= await apiService.fetchJobStats();

      emit(JobStatsLoaded(stats: stats));

    }catch(e){

      emit(JobStatsError(error: e.toString()));
    }

  }

  Future<void> _onFetchJobEvent(FetchJobEvent event, Emitter<CandidateJobStatsState> emit) async {

    try {
      emit(JobsLoading());
      List<CandidateJobModel> jobs;
      const int pageSize = 10;

      if (event.isSaved) {
        jobs = await apiService.fetchSavedJobs(1);
      } else {
        jobs = await apiService.fetchEnrolledJobs(1);
      }

      bool hasReachedMax = jobs.length < pageSize;
      emit(JobLoaded(jobs: jobs, hasReachedMax: hasReachedMax, currentPage: 1));
    } catch (error) {
      emit(JobStatsError(error: error.toString()));
    }

  }
  Future<void> _onLoadMoreJobs(LoadMoreJobs event, Emitter<CandidateJobStatsState> emit) async {
    final currentState = state;
    if (currentState is JobLoaded && !currentState.hasReachedMax) {
      try {
        List<CandidateJobModel> newJobs;
        final nextPage = currentState.currentPage + 1;

        if (event.isSaved) {
          newJobs = await apiService.fetchSavedJobs(nextPage);
        } else {
          newJobs = await apiService.fetchEnrolledJobs(nextPage);
        }

        if (newJobs.isEmpty) {
          emit(JobLoaded(
            jobs: currentState.jobs,
            hasReachedMax: true,
            currentPage: currentState.currentPage,
          ));
        } else {
          emit(JobLoaded(
            jobs: [...currentState.jobs, ...newJobs],
            hasReachedMax: newJobs.length < 10,
            currentPage: nextPage,
          ));
        }
      } catch (error) {
        emit(JobStatsError(error: error.toString()));
      }
    }
  }

  Future<void> _onToggleSavedJobEvent(ToggleSavedJobEvent event, Emitter<CandidateJobStatsState> emit) async {
    if (state is JobLoaded) {
      final currentState = state as JobLoaded;

      final currentJob = currentState.jobs.firstWhere((job) => job.id == event.jobId);
      final wasSaved= currentJob.isSaved;

      final optimisticJobs = currentState.jobs.map((job) {
        if (job.id == event.jobId) {
          return job.copyWith(
            isSaved: !wasSaved,
          );
        }
        return job;
      }).toList();

      emit(JobLoaded(jobs: optimisticJobs, hasReachedMax: currentState.hasReachedMax, currentPage: currentState.currentPage));

      try {
        bool success = await apiService.toggleSavedJob(event.jobId);
        print("Toggle save for ${event.jobId}: ${success ? 'Saved' : 'Save'}");
      } catch (e) {
        emit(JobStatsError(error: e.toString()));
        emit(JobLoaded(jobs: currentState.jobs, hasReachedMax: currentState.hasReachedMax, currentPage: currentState.currentPage));


      }
    }
  }
}
