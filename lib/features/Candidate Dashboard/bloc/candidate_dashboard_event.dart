part of 'candidate_dashboard_bloc.dart';

@immutable
sealed class CandidateDashboardEvent {}

class FetchDashboardData extends CandidateDashboardEvent {}