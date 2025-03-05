import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/features/Dashboard/bloc/employer_dashboard_bloc.dart';
import 'package:android/features/Dashboard/ui/employer_dashboard.dart';
import 'package:android/features/auth/bloc/auth_bloc.dart';
import 'package:android/features/auth/data/auth_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'core/constants/colors.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/ui/login.dart';
import 'features/auth/ui/onboading_Screen.dart';
import 'features/auth/ui/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  void toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  bool isLoggedIn = false;
  bool isLoading =false;
  String? userType;

  void checkLoginStatus() async {
    try {
      isLoading = true;
      isLoggedIn = await HiveUtils.getLoggedIn();

      if (isLoggedIn) {
        userType = await HiveUtils.getUserType();
      } else {
        print('User is not logged in.');
      }
    } catch(e) {
      // Handle error
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkMode ? AppTheme.darkTheme(context) :  AppTheme.lightTheme(context),

      home: isLoading ?  Scaffold(body: Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20),)):
        isLoggedIn
    ? (userType == "employer"
    ? EmployerDashboardScreen(isDarkMode: _isDarkMode, onThemeToggle: toggleTheme)
        : userType == "candidate"
    ? SizedBox()
        : OnboardingScreen(isDarkMode: _isDarkMode, toggleTheme: toggleTheme))
        : OnboardingScreen(isDarkMode: _isDarkMode, toggleTheme: toggleTheme),
    );
  }
}

