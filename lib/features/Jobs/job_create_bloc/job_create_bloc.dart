import 'package:android/data/models/Job/job_model.dart';
import 'package:android/features/Jobs/data_services/jobs_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'job_create_event.dart';
part 'job_create_state.dart';

class JobCreateBloc extends Bloc<JobCreateEvent, JobCreateState> {
  JobApiService apiService = JobApiService();
  JobCreateBloc() : super(JobCreateInitial()) {
    on<SubmitJobEvent>(_onSubmitJobEvent);
  }

  Future<void>_onSubmitJobEvent(SubmitJobEvent event, Emitter<JobCreateState> emit)async {
    try {
      emit(JobCreationLoading());

      JobModel job = await apiService.createJob(event.job);
      // await Future.delayed(Duration(seconds: 2)); // Simulated API call
      emit(JobCreationSuccess(job: job));
    } catch (e) {
      emit(JobCreationError( error: e.toString()));
    }

  }
}
