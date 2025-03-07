part of 'candidate_dashboard_bloc.dart';

@immutable
sealed class CandidateDashboardState {}

final class CandidateDashboardInitial extends CandidateDashboardState {}

class CandidateDashboardLoading extends CandidateDashboardState {}

class CandidateDashboardLoaded extends CandidateDashboardState {

  final Map<String,dynamic> data;

  CandidateDashboardLoaded(this.data);

}

class  CandidateDashboardError extends CandidateDashboardState {

  final String error;

  CandidateDashboardError(this.error);
}