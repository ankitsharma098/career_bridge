import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../data/dashboard_api_service.dart';

part 'employer_dashboard_event.dart';
part 'employer_dashboard_state.dart';

class EmployerDashboardBloc extends Bloc<EmployerDashboardEvent, EmployerDashboardState> {
  final EmployerDashboardService apiService= EmployerDashboardService();
  EmployerDashboardBloc() : super(EmployerDashboardInitial()) {
    on<FetchDashboardData>(_onFetchDashboardData);
  }

  Future<void> _onFetchDashboardData (FetchDashboardData event, Emitter<EmployerDashboardState> emit) async{

   emit(EmployerDashboardLoading());
    try{
     Map<String,dynamic> data =await apiService.dashboardStats();
      print("Dashboard Data $data");
      emit(EmployerDashboardLoaded(data));


    }catch(e){
      emit(EmployerDashboardError(e.toString()));

    }
  }

}
