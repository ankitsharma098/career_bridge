part of 'auth_bloc.dart';

@immutable
abstract class LoginState {}

 class LoginInitial extends LoginState {}

class LoginLoading extends LoginState{}

class LoginSuccess extends LoginState {

  // final Map<String,dynamic> data;
  //
  // LoginSuccess(required this.data}{);

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
  final bool isPasswordVisible;

  LoginFormState({this.email='', this.password='', this.isEmailValid=false, this.isPasswordValid=false,this.isPasswordVisible = false,});

  bool get isFormValid=>isEmailValid && isPasswordValid;
  LoginFormState copyWith({
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isPasswordVisible,
  }) {
    return LoginFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isPasswordVisible: isPasswordVisible ?? this.isPasswordVisible,
    );
  }

}

// class LoginInvalidState extends LoginState{}


