import 'package:android/core/theme/app_theme.dart';
import 'package:android/core/utils/snackBarUtils.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:android/features/auth/registration_bloc/registration_bloc.dart';
import 'package:android/features/auth/ui/registration_screen.dart';
import 'package:android/features/auth/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../Candidate Dashboard/ui/candidate_dashboard.dart';
import '../../Employer Dashboard/bloc/employer_dashboard_bloc.dart';
import '../../Employer Dashboard/ui/employer_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String userType;
  const LoginScreen({super.key, required this.userType});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    Size screenSize = MediaQuery.of(context).size;
    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFailure) {
          print("error${state.error}");
          SnackBarUtils.showRedSnackBar(state.error.toString(), context);
        }
        if (state is LoginSuccess) {
          if (widget.userType == "candidate") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => EmployerDashboardBloc(),
                  child: CandidateDashboardScreen(),
                ),
              ),
              (Route<dynamic> route) => false,
            );
          } else if (widget.userType == "employer") {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => EmployerDashboardBloc(),
                  child: EmployerDashboardScreen(),
                ),
              ),
              (Route<dynamic> route) => false,
            );
          }
        }
      },
      child: Scaffold(
        //  backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: screenSize.width * 0.06),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenSize.height * 0.1),
                    // Logo or Image
                    Center(
                      child: Container(
                        height: screenSize.width * 0.25,
                        width: screenSize.width * 0.25,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: screenSize.width * 0.125,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.05),
                    // Welcome Text
                    Text(
                      'Welcome Back',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: screenSize.width * 0.07,
                          fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sign in to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                            fontSize: screenSize.width * 0.04,
                          ),
                    ),
                    SizedBox(height: screenSize.height * 0.04),
                    // Email Field
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        return TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle:
                                _getLabelStyle(context, state, isEmail: true),
                            hintText: 'Enter your email',
                            prefixIcon: Icon(Icons.email_outlined),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.02,
                              horizontal: screenSize.width * 0.04,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: _getBorderSide(state, isEmail: true),
                            ),
                          ),
                          controller: emailController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            return null;
                          },
                          onChanged: (val) {
                            BlocProvider.of<LoginBloc>(context).add(
                                LoginEmailChanged(email: emailController.text));
                          },
                        );
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    // Password Field
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        bool isPasswordVisible = state is LoginFormState
                            ? state.isPasswordVisible
                            : false;
                        return TextFormField(
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle:
                                _getLabelStyle(context, state, isEmail: false),
                            hintText: 'Enter your password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                BlocProvider.of<LoginBloc>(context).add(
                                    TogglePasswordVisibility(
                                        !isPasswordVisible));
                              },
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: screenSize.height * 0.02,
                              horizontal: screenSize.width * 0.04,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                                  BorderSide(color: Colors.grey.shade300),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: _getBorderSide(state, isEmail: false),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                          controller: passwordController,
                          onChanged: (val) {
                            BlocProvider.of<LoginBloc>(context).add(
                                LoginPasswordChanged(
                                    password: passwordController.text));
                          },
                        );
                      },
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot Password?',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: screenSize.width * 0.035,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: screenSize.height * 0.07,
                      child: BlocBuilder<LoginBloc, LoginState>(
                        builder: (context, state) {
                          if (state is LoginLoading) {
                            return Center(
                              child: LoadingAnimationWidget.hexagonDots(
                                  color: AppColors.lightPrimary, size: 20),
                            );
                          }

                          return ElevatedButton(
                            onPressed: state is LoginFormState &&
                                    (state).isFormValid
                                ? () {
                                    if (_formKey.currentState!.validate()) {
                                      // Perform login
                                      print("//// Login Valid state");
                                      BlocProvider.of<LoginBloc>(context).add(
                                          LoginSubmitted(
                                              email: emailController.text,
                                              password: passwordController.text,
                                              userType: widget.userType));
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  state is LoginFormState && (state).isFormValid
                                      ? Colors.blue
                                      : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Login',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      fontSize: screenSize.width * 0.045,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    // Sign Up Option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontSize: screenSize.width * 0.045,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => RegistrationBloc(),
                                    child: RegistrationScreen(),
                                  ),
                                ));
                          },
                          child: Text(
                            'Sign Up',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    fontSize: screenSize.width * 0.035,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor),
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

  TextStyle? _getLabelStyle(BuildContext context, LoginState state,
      {required bool isEmail}) {
    if (state is LoginInitial) {
      return Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.grey,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          );
    }

    if (state is LoginFormState) {
      String inputText = isEmail ? state.email : state.password;
      bool isValid = isEmail ? state.isEmailValid : state.isPasswordValid;

      // If no input, stay grey
      if (inputText.isEmpty) {
        return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            );
      }

      // If input is invalid, turn red
      if (!isValid) {
        return Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.red,
              fontSize: MediaQuery.of(context).size.width * 0.04,
            );
      }

      // If input is valid, turn primary color
      return Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).primaryColor,
            fontSize: MediaQuery.of(context).size.width * 0.04,
          );
    }

    return Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Colors.grey,
          fontSize: MediaQuery.of(context).size.width * 0.04,
        );
  }

  BorderSide _getBorderSide(LoginState state, {required bool isEmail}) {
    if (state is LoginFormState) {
      String inputText = isEmail ? state.email : state.password;
      bool isValid = isEmail ? state.isEmailValid : state.isPasswordValid;

      // If no input, stay grey
      if (inputText.isEmpty) {
        return BorderSide(color: Colors.grey.shade300);
      }

      // If input is invalid, turn red
      if (!isValid) {
        return BorderSide(color: Colors.red);
      }

      // If input is valid, turn primary color
      return BorderSide(color: Theme.of(context).primaryColor);
    }

    return BorderSide(color: Colors.grey.shade300);
  }

  @override
  void dispose() {
    // Clean up controllers
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
