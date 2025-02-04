import 'package:android/features/Stories/data/story_api_service.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'story_stats_event.dart';
part 'story_stats_state.dart';

class StoryStatsBloc extends Bloc<StoryStatsEvent, StoryStatsState> {
  StoryApiService apiService = StoryApiService();
  StoryStatsBloc() : super(StoryStatsInitial()) {
    on<FetchStoryStats>(_onFetchStoryStats);
  }

  Future<void> _onFetchStoryStats(FetchStoryStats event, Emitter<StoryStatsState> emit) async {


    try{
      emit(StoryStatsLoading());

     Map<String,dynamic> stats= await apiService.fetchStoriesStats();

      emit(StoryStatsLoaded(stats: stats));

    }catch(e){

      emit(StoryStatsError(error: e.toString()));
    }

}


}
