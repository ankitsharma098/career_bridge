import 'package:android/features/Candidate%20Job/model/candidate_job_model.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/api_service.dart';

part 'candidate_job_event.dart';
part 'candidate_job_state.dart';
class CandidateJobBloc extends Bloc<CandidateJobEvent, CandidateJobState> {
  final CandidateJobServices apiService = CandidateJobServices();

  CandidateJobBloc() : super(CandidateJobInitial()) {
    on<FetchJobs>(_onFetchJobs);
    on<LoadMoreJobs>(_onLoadMoreJobs);
    on<ToggleSavedJobsEvent>(_onToggleSavedJobsEvent);
  }

  Future<void> _onFetchJobs(FetchJobs event, Emitter<CandidateJobState> emit) async {
    try {
      emit(JobLoading());
      List<CandidateJobModel> jobs;
      const int pageSize = 10;

      if (event.isRecommended) {
        jobs = await apiService.fetchRecommendedJobs(1);
      } else {

        print(event.search);
        jobs = await apiService.fetchSearchedJobs(
          page: 1,
          search: event.search, // Pass search term to API
        );
      }

      bool hasReachedMax = jobs.length < pageSize;
      emit(JobLoaded(jobs: jobs, hasReachedMax: hasReachedMax, currentPage: 1));
    } catch (error) {
      emit(JobError(error: error.toString()));
    }
  }

  Future<void> _onLoadMoreJobs(LoadMoreJobs event, Emitter<CandidateJobState> emit) async {
    final currentState = state;
    if (currentState is JobLoaded && !currentState.hasReachedMax) {
      try {
        List<CandidateJobModel> newJobs;
        final nextPage = currentState.currentPage + 1;

        if (event.isRecommended) {
          newJobs = await apiService.fetchRecommendedJobs(nextPage);
        } else {
          newJobs = await apiService.fetchSearchedJobs(
            page: nextPage,
            search: event.search, // Pass search term to API
          );
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
        emit(JobError(error: error.toString()));
      }
    }
  }

  Future<void> _onToggleSavedJobsEvent(ToggleSavedJobsEvent event, Emitter<CandidateJobState> emit) async {
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
        emit(JobError(error: e.toString()));
        emit(JobLoaded(jobs: currentState.jobs, hasReachedMax: currentState.hasReachedMax, currentPage: currentState.currentPage));


      }
    }
  }
}