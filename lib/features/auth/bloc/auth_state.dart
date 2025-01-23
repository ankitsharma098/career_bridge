part of 'auth_bloc.dart';

@immutable
abstract class LoginState {}

 class LoginInitial extends LoginState {}

class LoginLoading extends LoginState{}

class LoginSuccess extends LoginState {

  final Map<String,dynamic> data;

  LoginSuccess({required this.data});

}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});


}


class LoginFormState extends LoginState {
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;

  LoginFormState({this.email='', this.password='', this.isEmailValid=false, this.isPasswordValid=false});

  bool get isFormValid=>isEmailValid && isPasswordValid;


}

// class LoginInvalidState extends LoginState{}


