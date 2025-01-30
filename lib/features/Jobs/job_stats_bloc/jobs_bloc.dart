import 'package:android/features/Jobs/data_services/jobs_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'jobs_event.dart';
part 'jobs_state.dart';

class JobStatsBloc extends Bloc<JobsStatsEvent, JobStatsState> {

  JobApiService apiService = JobApiService();
  JobStatsBloc() : super(JobStatsInitial()) {
    on<FetchJobStats>(_onFetchJobStats);
  }
  Future<void> _onFetchJobStats(
      FetchJobStats event,
      Emitter<JobStatsState> emit,
      ) async {
    emit(JobStatsLoading());
    try {

      Map<String,dynamic>stats= await apiService.fetchJobStats();

     // await Future.delayed(Duration(seconds: 1));
      emit(JobStatsLoaded(stats));
    } catch (e) {
      emit(JobStatsError(e.toString()));
    }
  }
}
