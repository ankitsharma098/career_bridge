part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

class ProfileDataLoading extends ProfileState{}

class ProfileDataLoaded extends ProfileState{
  final Employer employer;
  final CompanyDetails companyDetails;

  ProfileDataLoaded(this.employer, this.companyDetails);



}

class ProfileUpdateSuccess extends ProfileState {
  final String message;
  ProfileUpdateSuccess(this.message);
}
class ProfileError extends ProfileState {
  final String error;
  ProfileError(this.error);
}

