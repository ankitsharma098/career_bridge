part of 'candidate_profile_bloc.dart';

@immutable
sealed class CandidateProfileState {}

final class CandidateProfileInitial extends CandidateProfileState {}

class ProfileDataLoading extends CandidateProfileState{}

class ProfileDataLoaded extends CandidateProfileState{
  final Candidate candidate;

  ProfileDataLoaded(this.candidate,);
}

class ProfileUpdateSuccess extends CandidateProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}
class ProfileError extends CandidateProfileState {
  final String error;
  ProfileError(this.error);
}