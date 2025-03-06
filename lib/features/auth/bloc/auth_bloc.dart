import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:bloc/bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {


   final AuthApiServices _loginApiService =AuthApiServices();

  LoginBloc()
  :super(LoginInitial()){

    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    on<TogglePasswordVisibility>(_onTogglePasswordVisibility);

  }
   void _onTogglePasswordVisibility(
       TogglePasswordVisibility event,
       Emitter<LoginState> emit
       ) {
     if (state is LoginFormState) {
       final currentState = state as LoginFormState;
       emit(currentState.copyWith(
           isPasswordVisible: event.isVisible
       ));
     }
   }


   void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
     if (state is LoginFormState) {
       final currentState = state as LoginFormState;
       emit(LoginFormState(
         email: event.email,
         password: currentState.password,
         isEmailValid: EmailValidator.validate(event.email),
         isPasswordValid: currentState.isPasswordValid,
         isPasswordVisible: currentState.isPasswordVisible,
       ));
     } else {
       emit(LoginFormState(
         email: event.email,
         isEmailValid: EmailValidator.validate(event.email),
       ));
     }
   }

   void _onPasswordChanged(
       LoginPasswordChanged event,
       Emitter<LoginState> emit,
       ) {
     if (state is LoginFormState) {
       final currentState = state as LoginFormState;
       emit(LoginFormState(
         email: currentState.email,
         password: event.password,
         isEmailValid: currentState.isEmailValid,
         isPasswordValid: _isPasswordValid(event.password),
         isPasswordVisible: currentState.isPasswordVisible,
       ));
     } else {
       emit(LoginFormState(
         password: event.password,
         isPasswordValid: _isPasswordValid(event.password),
       ));
     }
   }

   Future<void> _onSubmitted(
       LoginSubmitted event,
       Emitter<LoginState> emit,
       ) async {
     final isEmailValid = EmailValidator.validate(event.email);
     final isPasswordValid = _isPasswordValid(event.password);

     if (!isEmailValid || !isPasswordValid) {
       emit(LoginFailure(error: "Invalid email or Password"));
       emit(LoginFormState(
         email: event.email,
         password: event.password,
         isEmailValid: isEmailValid,
         isPasswordValid: isPasswordValid,
       ));
       return;
     }

     emit(LoginLoading());
     try {
       if(event.userType == "employer") {
         await _loginApiService.login(event.email, event.password);
       }else if(event.userType=="candidate"){

         //candidate api call
       }

       print("login success----------------------------------------------------------");
       String? fcmToken = await FirebaseMessaging.instance.getToken();
       fcmToken != null ? await _loginApiService.saveToken(fcmToken) : null;
       emit(LoginSuccess());
     } catch (e) {
       emit(LoginFailure(error: e.toString()));
       emit(LoginFormState(
         email: event.email,
         password: event.password,
         isEmailValid: isEmailValid,
         isPasswordValid: isPasswordValid,
       ));
     }
   }



  bool _isPasswordValid(String password){

    return password.length>=4;
  }





  // LoginBloc() : super(AuthInitial()) {
  //   on<LoginEmailChanged>
  //
  // }
}


