

import 'package:equatable/equatable.dart';

abstract class TeamMembersEvent extends Equatable {
  const TeamMembersEvent();

  @override
  List<Object> get props => [];
}

class FetchTeamMembersEvent extends TeamMembersEvent {
  final String companyId;
  const FetchTeamMembersEvent(this.companyId);
  @override
  List<Object> get props => [companyId];
}

class AddTeamMemberEvent extends TeamMembersEvent {
  final String companyId;
  final Map<String, dynamic> employerData;
  const AddTeamMemberEvent({required this.companyId, required this.employerData});
  @override
  List<Object> get props => [companyId, employerData];
}

class DeleteTeamMemberEvent extends TeamMembersEvent {
  final String employerId;
  final String companyId;
  const DeleteTeamMemberEvent({required this.employerId, required this.companyId});
  @override
  List<Object> get props => [employerId, companyId];
}