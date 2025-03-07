part of 'employer_dashboard_bloc.dart';

@immutable
abstract class EmployerDashboardState {}

 class EmployerDashboardInitial extends EmployerDashboardState {}

class EmployerDashboardLoading extends EmployerDashboardState {}

class EmployerDashboardLoaded extends EmployerDashboardState {

  final Map<String,dynamic> data;

  EmployerDashboardLoaded(this.data);

}

class  EmployerDashboardError extends EmployerDashboardState {

  final String error;

  EmployerDashboardError(this.error);
}
