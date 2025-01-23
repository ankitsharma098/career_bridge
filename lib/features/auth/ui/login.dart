import 'package:android/core/utils/snackBarUtils.dart';
import 'package:android/features/Dashboard/bloc/employer_dashboard_bloc.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Dashboard/ui/employer_dashboard.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
  listener: (context, state) {

    if(state is LoginFailure){
      print("error${state.error}");
      SnackBarUtils.showRedSnackBar(state.error.toString(), context);
    }
    if(state is LoginSuccess){
      print("SUccess ${state.data}");

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BlocProvider(
  create: (context) => EmployerDashboardBloc(),
  child: EmployerDashboardScreen (),
),));
    }
  },
  child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80),
                  // Logo or Image
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Welcome Text
                  Text(
                    'Welcome Back',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 40),
                  // Email Field
                  BlocBuilder<LoginBloc , LoginState>(
                   builder: (context, state) {
                     return TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: (state is LoginFormState && state.isEmailValid) ?BorderSide(color: Colors.blue):BorderSide(color: Colors.red),
                      ),
                    ),
                    controller: emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      return null;
                    },
                    onChanged: (val){
                      BlocProvider.of<LoginBloc>(context).add(LoginEmailChanged(email: emailController.text));
                    },
                  );
  },
),
                  SizedBox(height: 20),
                  // Password Field
                  BlocBuilder<LoginBloc , LoginState>(
  builder: (context, state) {
    return TextFormField(
                    obscureText: _isObscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isObscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            _isObscure = !_isObscure;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: (state is LoginFormState && state.isPasswordValid) ? BorderSide(color: Colors.blue):BorderSide(color: Colors.red),
                      ),

                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    controller: passwordController,
                    onChanged: (val){
                      BlocProvider.of<LoginBloc>(context).add(LoginPasswordChanged(password: passwordController.text));
                    },
                  );
  },
),
                  SizedBox(height: 12),
                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text('Forgot Password?'),
                    ),
                  ),
                  SizedBox(height: 24),
                  // Login Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: BlocBuilder<LoginBloc,LoginState>(
                      builder: (context, state) {
                        if(state is LoginLoading){
                          return Center(child: CircularProgressIndicator());
                        }

                        return ElevatedButton(
                          onPressed:  state  is LoginFormState && (state).isFormValid ? (){
                            if (_formKey.currentState!.validate()) {
                              // Perform login
                              print("//// Login Valid state");
                              BlocProvider.of<LoginBloc>(context).add(LoginSubmitted(email: emailController.text, password: passwordController.text));
                                                          
                            } }: null,
                          
                          style: ElevatedButton.styleFrom(
                            backgroundColor:state is LoginFormState && (state).isFormValid ? Colors.blue:Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 24),
                  // Sign Up Option
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'Sign Up',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
);
  }
}