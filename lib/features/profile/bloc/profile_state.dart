part of 'profile_bloc.dart';

@immutable
sealed class ProfileState {}

final class ProfileInitial extends ProfileState {}

// class PersonalInfoChanged extends ProfileState {}
//
// class SocialMediaChanged extends ProfileState {}

class EmployerProfileUpdateSuccess extends ProfileState {
  final String message;

  EmployerProfileUpdateSuccess(this.message);

}

class EmployerProfileError extends ProfileState {
  final String error;

   EmployerProfileError(this.error);
}