import 'package:android/features/Team%20Member/bloc/team_member_event.dart';
import 'package:android/features/Team%20Member/bloc/team_member_state.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:android/data/models/employer/employer_model.dart';

import '../data/service.dart';


class TeamMembersBloc extends Bloc<TeamMembersEvent, TeamMembersState> {
  final TeamMembersService _service = TeamMembersService();

  TeamMembersBloc() : super(TeamMembersInitial()) {
    on<FetchTeamMembersEvent>(_onFetchTeamMembers);
    on<AddTeamMemberEvent>(_onAddTeamMember);
    on<DeleteTeamMemberEvent>(_onDeleteTeamMember);
  }

  Future<void> _onFetchTeamMembers(FetchTeamMembersEvent event, Emitter<TeamMembersState> emit) async {
    emit(TeamMembersLoading());
    try {
      final teamMembers = await _service.fetchTeamMembers(event.companyId);
      emit(TeamMembersLoaded(teamMembers: teamMembers));
    } catch (e) {
      emit(TeamMembersFailure(error: e.toString()));
    }
  }

  Future<void> _onAddTeamMember(AddTeamMemberEvent event, Emitter<TeamMembersState> emit) async {
    emit(TeamMembersLoading());
    try {
      await _service.addTeamMember(event.companyId, event.employerData);
      final teamMembers = await _service.fetchTeamMembers(event.companyId);
      emit(TeamMembersLoaded(teamMembers: teamMembers));
    } catch (e) {
      emit(TeamMembersFailure(error: e.toString()));
    }
  }

  Future<void> _onDeleteTeamMember(DeleteTeamMemberEvent event, Emitter<TeamMembersState> emit) async {
    emit(TeamMembersLoading());
    try {
      await _service.deleteTeamMember(event.employerId);
      final teamMembers = await _service.fetchTeamMembers(event.companyId);
      emit(TeamMembersLoaded(teamMembers: teamMembers));
    } catch (e) {
      emit(TeamMembersFailure(error: e.toString()));
    }
  }
}