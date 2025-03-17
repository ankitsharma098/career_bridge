import 'package:android/core/utils/hiveUtils.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'core/constants/colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/Candidate Dashboard/ui/candidate_dashboard.dart';
import 'features/Employer Dashboard/ui/employer_dashboard.dart';
import 'features/auth/ui/onboading_Screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

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
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? AppTheme.darkTheme(context) :  AppTheme.lightTheme(context),

      home: isLoading ?  Scaffold(body: Center(child: LoadingAnimationWidget.hexagonDots(color: AppColors.lightPrimary, size: 20),)):
        isLoggedIn
    ? (userType == "employer"
    ? EmployerDashboardScreen()
        : userType == "candidate"
    ? CandidateDashboardScreen()
        : OnboardingScreen())
        : OnboardingScreen(),
    );
  }
}

