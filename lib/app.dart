// import 'package:android/core/utils/hiveUtils.dart';
// import 'package:android/features/About%20Us/ui/about_us.dart';
// import 'package:android/features/Candidate%20Profile/ui/candidate_profile.dart';
// import 'package:android/voice/voice_navigation_manager.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:loading_animation_widget/loading_animation_widget.dart';
// import 'package:provider/provider.dart';
// import 'core/constants/colors.dart';
// import 'core/theme/app_theme.dart';
// import 'core/theme/theme_provider.dart';
// import 'data/models/candidate/candidate_model.dart';
// import 'data/models/employer/employer_model.dart';
// import 'features/Candidate Dashboard/ui/candidate_dashboard.dart';
// import 'features/Candidate Job Stats/Candidate Job Stats Bloc/candidate_job_stats_bloc.dart';
// import 'features/Candidate Job Stats/ui/candidate_job_stats.dart';
// import 'features/Candidate Job Stats/ui/enrolled_jobs_screen.dart';
// import 'features/Candidate Job Stats/ui/saved_job_screen.dart';
// import 'features/Candidate Job/Job Bloc/candidate_job_bloc.dart';
// import 'features/Candidate Job/ui/jobs_fetch.dart';
// import 'features/Candidate Profile/bloc/candidate_profile_bloc.dart';
// import 'features/Chat/converstation bloc/conversations_bloc.dart';
// import 'features/Chat/data service/chat_service.dart';
// import 'features/Chat/ui/chat.dart';
// import 'features/Employer Dashboard/ui/employer_dashboard.dart';
// import 'features/Stories/bloc/story_bloc.dart';
// import 'features/Stories/ui/all_story.dart';
// import 'features/Stories/ui/create_story.dart';
// import 'features/Stories/ui/my_stories.dart';
// import 'features/Stories/ui/saved_stories.dart';
// import 'features/auth/ui/onboading_Screen.dart';
//
// class MyApp extends StatefulWidget {
//   const MyApp({super.key});
//
//   @override
//   State<MyApp> createState() => _MyAppState();
// }
//
// class _MyAppState extends State<MyApp> {
//   bool isLoggedIn = false;
//   bool isLoading = false;
//   String? userType;
//   String? userId;
//   final VoiceNavigationManager _voiceManager = VoiceNavigationManager();
//   final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
//       GlobalKey<ScaffoldMessengerState>();
//
//   bool _voiceInitialized = false;
//   Future<void> _initializeApp() async {
//     try {
//       isLoading = true;
//       isLoggedIn = await HiveUtils.getLoggedIn();
//
//       if (isLoggedIn) {
//         userType = await HiveUtils.getUserType();
//         Map<String, dynamic> dataMap = userType == "candidate"
//             ? await HiveUtils.getCandidateData()
//             : await HiveUtils.getEmployerData();
//         userId = dataMap["_id"] ?? "";
//       }
//     } catch (e) {
//       if (kDebugMode) {
//         print('Error initializing app: $e');
//       }
//     } finally {
//       isLoading = false;
//     }
//   }
//
//   Future<void> _initializeVoiceNavigation() async {
//     if (!_voiceInitialized) {
//       await _voiceManager.initialize(context);
//       _voiceInitialized = true;
//       if (mounted) {
//         _voiceManager.startVoiceNavigation(onHotwordDetected: () {
//           debugPrint("Hotword callback executing in app");
//
//           // Create a more persistent way to show the SnackBar
//           if (mounted) {
//             // Use a GlobalKey to access the ScaffoldMessenger more reliably
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _scaffoldMessengerKey.currentState?.showSnackBar(
//                 const SnackBar(
//                   content: Text("Hi, I'm listening!"),
//                   duration: Duration(seconds: 2),
//                   behavior: SnackBarBehavior.floating,
//                 ),
//               );
//             });
//           }
//         });
//       }
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeApp().then((_) {
//       _initializeVoiceNavigation();
//     });
//   }
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//   }
//
//   @override
//   void dispose() {
//     _voiceManager.stopVoiceNavigation();
//     super.dispose();
//   }
//
//   Map<String, WidgetBuilder> _buildEmployerRoutes() {
//     return {
//       '/home': (context) => const EmployerDashboardScreen(),
//     };
//   }
//
//   Map<String, WidgetBuilder> _buildCandidateRoutes() {
//     return {
//       '/home': (context) => const CandidateDashboardScreen(),
//       '/profile': (context) => BlocProvider(
//             create: (context) => CandidateProfileBloc(),
//             child: const CandidateProfile(),
//           ),
//       '/about_us': (context) => const AboutUsScreen(),
//       '/jobs': (context) => BlocProvider(
//             create: (context) => CandidateJobBloc(),
//             child: const CandidateTabJobs(),
//           ),
//       '/job_stats': (context) => BlocProvider(
//             create: (context) => CandidateJobStatsBloc(),
//             child: const CandidateJobStatsScreen(),
//           ),
//       '/enrolled_jobs': (context) => BlocProvider(
//             create: (context) => CandidateJobStatsBloc(),
//             child: const EnrolledJobListScreen(),
//           ),
//     };
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final themeProvider = Provider.of<ThemeProvider>(context);
//     return FutureBuilder(
//       future: _initializeApp(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return MaterialApp(
//             navigatorKey: _voiceManager.navigatorKey,
//             scaffoldMessengerKey: _voiceManager.scaffoldMessengerKey,
//             debugShowCheckedModeBanner: false,
//             theme: themeProvider.isDarkMode
//                 ? AppTheme.darkTheme(context)
//                 : AppTheme.lightTheme(context),
//             home: Scaffold(
//               body: Center(
//                 child: LoadingAnimationWidget.hexagonDots(
//                   color: AppColors.lightPrimary,
//                   size: 20,
//                 ),
//               ),
//             ),
//           );
//         }
//
//         return MaterialApp(
//           debugShowCheckedModeBanner: false,
//           routes: isLoggedIn
//               ? (userType == "candidate"
//                   ? _buildCandidateRoutes()
//                   : _buildEmployerRoutes())
//               : {},
//           theme: themeProvider.isDarkMode
//               ? AppTheme.darkTheme(context)
//               : AppTheme.lightTheme(context),
//           home: isLoading
//               ? Scaffold(
//                   body: Center(
//                     child: LoadingAnimationWidget.hexagonDots(
//                       color: AppColors.lightPrimary,
//                       size: 20,
//                     ),
//                   ),
//                 )
//               : isLoggedIn
//                   ? userType == "employer"
//                       ? const EmployerDashboardScreen()
//                       : const CandidateDashboardScreen()
//                   : const OnboardingScreen(),
//         );
//       },
//     );
//   }
// }
// lib/app.dart

import 'package:android/features/Candidate%20Job%20Stats/ui/saved_job_screen.dart';
import 'package:audiofileplayer/audiofileplayer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/hiveUtils.dart';
import 'features/About%20Us/ui/about_us.dart';
import 'features/Candidate%20Dashboard/ui/candidate_dashboard.dart';
import 'features/Candidate%20Job%20Stats/Candidate%20Job%20Stats%20Bloc/candidate_job_stats_bloc.dart';
import 'features/Candidate%20Job%20Stats/ui/candidate_job_stats.dart';
import 'features/Candidate%20Job%20Stats/ui/enrolled_jobs_screen.dart';
import 'features/Candidate%20Job/Job%20Bloc/candidate_job_bloc.dart';
import 'features/Candidate%20Job/ui/jobs_fetch.dart';
import 'features/Candidate%20Profile/bloc/candidate_profile_bloc.dart';
import 'features/Candidate%20Profile/ui/candidate_profile.dart';
import 'features/Employer Profile/bloc/profile_bloc.dart';
import 'features/Employer Profile/ui/employer_profile.dart';
import 'features/Employer%20Dashboard/ui/employer_dashboard.dart';
import 'features/Jobs/ui/jobs.dart';
import 'features/auth/ui/onboading_Screen.dart';
import 'voice/voice_navigation_manager.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isLoading = true;
  String? userType;
  String? userId;
  final VoiceNavigationManager _voiceManager = VoiceNavigationManager();

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  @override
  void dispose() {
    _voiceManager.stopVoiceNavigation();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize app data
      isLoggedIn = await HiveUtils.getLoggedIn();

      if (isLoggedIn) {
        userType = await HiveUtils.getUserType();
        Map<String, dynamic> dataMap = userType == "candidate"
            ? await HiveUtils.getCandidateData()
            : await HiveUtils.getEmployerData();
        userId = dataMap["_id"] ?? "";
      }

      // Initialize voice manager
      await _voiceManager.initialize();

      // Start voice navigation with a delay to ensure app is fully initialized
      if (mounted) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          _startVoiceNavigation();
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing app: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _startVoiceNavigation() {
    _voiceManager.startVoiceNavigation(
      onHotwordDetected: () {
        debugPrint("Hotword detected in app");
        //   Audio.load('assets/audio/chime.mp3')
        //     ..play()
        //     ..dispose();
      },
    );
  }

  Map<String, WidgetBuilder> _buildEmployerRoutes() {
    return {
      '/home': (context) => const EmployerDashboardScreen(),
      '/profile': (context) => BlocProvider(
            create: (context) => ProfileBloc(),
            child: EmployerProfileScreen(),
          ),
      '/about_us': (context) => const AboutUsScreen(),
      '/jobs': (context) => const JobStatsScreen(),
    };
  }

  Map<String, WidgetBuilder> _buildCandidateRoutes() {
    return {
      '/home': (context) => const CandidateDashboardScreen(),
      '/profile': (context) => BlocProvider(
            create: (context) => CandidateProfileBloc(),
            child: const CandidateProfile(),
          ),
      '/about_us': (context) => const AboutUsScreen(),
      '/jobs': (context) => const CandidateTabJobs(),
      '/job_stats': (context) => BlocProvider(
            create: (context) => CandidateJobStatsBloc(),
            child: const CandidateJobStatsScreen(),
          ),
      '/enrolled_jobs': (context) => BlocProvider(
            create: (context) => CandidateJobStatsBloc(),
            child: const EnrolledJobListScreen(),
          ),
      '/saved_jobs': (context) => BlocProvider(
            create: (context) => CandidateJobStatsBloc(),
            child: const SavedJobScreen(),
          ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Use the global keys from voice manager
      navigatorKey: _voiceManager.navigatorKey,
      scaffoldMessengerKey: _voiceManager.scaffoldMessengerKey,

      routes: isLoggedIn
          ? (userType == "candidate"
              ? _buildCandidateRoutes()
              : _buildEmployerRoutes())
          : {},

      theme: themeProvider.isDarkMode
          ? AppTheme.darkTheme(context)
          : AppTheme.lightTheme(context),

      home: isLoading
          ? Scaffold(
              body: Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.lightPrimary,
                  size: 20,
                ),
              ),
            )
          : isLoggedIn
              ? userType == "employer"
                  ? const EmployerDashboardScreen()
                  : const CandidateDashboardScreen()
              : const OnboardingScreen(),
    );
  }
}
