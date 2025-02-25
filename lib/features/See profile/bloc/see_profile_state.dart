part of 'see_profile_bloc.dart';

@immutable
sealed class SeeProfileState  extends Equatable{
  const SeeProfileState();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

final class SeeProfileInitial extends SeeProfileState {}

class UserProfileLoading extends SeeProfileState {}

class UserProfileLoadedEmployer extends SeeProfileState {
  final Employer employer;
  final CompanyDetails companyDetails;

  const UserProfileLoadedEmployer(this.employer, this.companyDetails);

  @override
  List<Object?> get props => [employer, companyDetails];
}

class UserProfileLoadedCandidate extends SeeProfileState {
  final Candidate candidate;

  const UserProfileLoadedCandidate(this.candidate);

  @override
  List<Object?> get props => [candidate];
}

class UserProfileError extends SeeProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}