import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/api_service.dart';

part 'candidate_dashboard_event.dart';
part 'candidate_dashboard_state.dart';

class CandidateDashboardBloc extends Bloc<CandidateDashboardEvent, CandidateDashboardState> {

  final CandidateDashboardService apiService= CandidateDashboardService();

  CandidateDashboardBloc() : super(CandidateDashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }
  Future<void> _onFetchDashboardData (FetchDashboardData event, Emitter<CandidateDashboardState> emit) async{

    emit(CandidateDashboardLoading());
    try{
      Map<String,dynamic> data =await apiService.dashboardStats();
      print("Candidate Dashboard Data $data");
      emit(CandidateDashboardLoaded(data));


    }catch(e){
      emit(CandidateDashboardError(e.toString()));

    }
  }
}
