import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:android/features/auth/ui/login.dart';
import 'package:bloc/bloc.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {


   final LoginApiService _loginApiService =LoginApiService();

  LoginBloc()
  :super(LoginFormState()){

    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onSubmitted);
    //on<LoginFailure>(_reLoginFormState);

  }

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit){

    if(state is LoginFormState){
      final currentState=state as LoginFormState;
        emit(LoginFormState(email: event.email,password: currentState.password,isEmailValid: EmailValidator.validate(event.email),isPasswordValid: currentState.isPasswordValid));


      }


  }

  void _onPasswordChanged (
      LoginPasswordChanged event,
      Emitter<LoginState> emit,
      ){

    if(state is LoginFormState){
      final currentState=state as LoginFormState;


        emit(LoginFormState(email: currentState.email,
            password: event.password,
            isEmailValid: currentState.isEmailValid,
            isPasswordValid: _isPasswordValid(event.password)));
      }

    // if(!_isPasswordValid(event.password)){
    //   emit(LoginInvalidState());
    // }else{
    //   emit(LoginValidState());
    // }



  }

  Future<void> _onSubmitted(
      LoginSubmitted event,
      Emitter<LoginState> emit,
      ) async {

    print("email ${event.email}");
    print("password ${event.password}");
    if(EmailValidator.validate(event.email)==false || !_isPasswordValid(event.password)){
      print("Login Failure Event");
      emit(LoginFailure(error: "Invalid email or Password"));
      // Emit LoginFormState with current values to maintain form state
      emit(LoginFormState(
          email: event.email,
          password: event.password,
          isEmailValid: EmailValidator.validate(event.email),
          isPasswordValid: _isPasswordValid(event.password)
      ));
      return;
    }
    print("Login Loading Event");
    emit(LoginLoading());
    try{

      final data = await _loginApiService.login(event.email, event.password);
      emit(LoginSuccess(data: data));



    }catch(e){

      emit(LoginFailure(error: e.toString()));
      // Remove the LoginFormState emission
      emit(LoginFormState(
          email: event.email,
          password: event.password,
          isEmailValid: EmailValidator.validate(event.email),
          isPasswordValid: _isPasswordValid(event.password)
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


