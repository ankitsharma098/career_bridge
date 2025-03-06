

import 'package:equatable/equatable.dart';
import '../../../data/models/employer/employer_model.dart';


abstract class TeamMembersState extends Equatable {
  const TeamMembersState();

  @override
  List<Object> get props => [];
}

class TeamMembersInitial extends TeamMembersState {}

class TeamMembersLoading extends TeamMembersState {}

class TeamMembersLoaded extends TeamMembersState {
  final List<Employer> teamMembers;
  const TeamMembersLoaded({required this.teamMembers});
  @override
  List<Object> get props => [teamMembers];
}

class TeamMembersFailure extends TeamMembersState {
  final String error;
  const TeamMembersFailure({required this.error});
  @override
  List<Object> get props => [error];
}