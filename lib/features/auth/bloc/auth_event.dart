part of 'auth_bloc.dart';

@immutable
abstract class LoginEvent  {}

class LoginSubmitted extends LoginEvent{

  final String email;
  final String password;
  final String userType;

  LoginSubmitted({required this.email, required this.password, required this.userType});


}

class LoginEmailChanged extends LoginEvent {

  final String email;
  LoginEmailChanged({required this.email});
}

class LoginPasswordChanged extends LoginEvent {

    final String password;

  LoginPasswordChanged({required this.password});


}

class TogglePasswordVisibility extends LoginEvent {
  final bool isVisible;

  TogglePasswordVisibility(this.isVisible);
}

