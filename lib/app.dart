import 'package:android/core/utils/hiveUtils.dart';
import 'package:android/features/About%20Us/ui/about_us.dart';
import 'package:android/features/Candidate%20Profile/ui/candidate_profile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'core/constants/colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'data/models/candidate/candidate_model.dart';
import 'data/models/employer/employer_model.dart';
import 'features/Candidate Dashboard/ui/candidate_dashboard.dart';
import 'features/Candidate Job Stats/Candidate Job Stats Bloc/candidate_job_stats_bloc.dart';
import 'features/Candidate Job Stats/ui/candidate_job_stats.dart';
import 'features/Candidate Job Stats/ui/enrolled_jobs_screen.dart';
import 'features/Candidate Job Stats/ui/saved_job_screen.dart';
import 'features/Candidate Job/Job Bloc/candidate_job_bloc.dart';
import 'features/Candidate Job/ui/jobs_fetch.dart';
import 'features/Candidate Profile/bloc/candidate_profile_bloc.dart';
import 'features/Chat/converstation bloc/conversations_bloc.dart';
import 'features/Chat/data service/chat_service.dart';
import 'features/Chat/ui/chat.dart';
import 'features/Employer Dashboard/ui/employer_dashboard.dart';
import 'features/Stories/bloc/story_bloc.dart';
import 'features/Stories/ui/all_story.dart';
import 'features/Stories/ui/create_story.dart';
import 'features/Stories/ui/my_stories.dart';
import 'features/Stories/ui/saved_stories.dart';
import 'features/auth/ui/onboading_Screen.dart';
import 'features/voice_system/core/voice_controller.dart';
import 'features/voice_system/core/voice_controller_buttons.dart';
import 'features/voice_system/ui/voice_overlay.dart';

class MyApp extends StatefulWidget {
  final VoiceController voiceController;
  final GlobalKey<NavigatorState> navigatorKey;
  const MyApp(
      {super.key, required this.voiceController, required this.navigatorKey});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;
  bool isLoading = false;
  String? userType;
  String? userId;

  Future<void> _initializeApp() async {
    try {
      isLoading = true;
      isLoggedIn = await HiveUtils.getLoggedIn();

      if (isLoggedIn) {
        userType = await HiveUtils.getUserType();
        Map<String, dynamic> dataMap = userType == "candidate"
            ? await HiveUtils.getCandidateData()
            : await HiveUtils.getEmployerData();
        userId = dataMap["_id"] ?? "";
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing app: $e');
      }
    } finally {
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Map<String, WidgetBuilder> _buildCandidateRoutes() {
    return {
      '/home': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: CandidateDashboardScreen(),
          ),
      '/profile': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => CandidateProfileBloc(),
              child: CandidateProfile(),
            ),
          ),
      '/about_us': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: AboutUsScreen(),
          ),
      '/jobs': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => CandidateJobBloc(),
              child: CandidateTabJobs(),
            ),
          ),
      '/job_stats': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => CandidateJobStatsBloc(),
              child: CandidateJobStatsScreen(),
            ),
          ),
      '/enrolled_jobs': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => CandidateJobStatsBloc(),
              child: EnrolledJobListScreen(),
            ),
          ),
      '/saved_jobs': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => CandidateJobStatsBloc(),
              child: SavedJobScreen(),
            ),
          ),
      '/chat': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => ConversationsBloc(
                  ChatRepository(), userId ?? "", "candidate"),
              child: ConversationsScreen(
                userId: userId ?? "",
                userType: userType ?? "",
              ),
            ),
          ),
      '/stories': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: BlocProvider(
              create: (context) => StoryBloc(),
              child: StoriesScreen(
                currentUserId: userId ?? "",
                currentUserType: userType ?? "",
              ),
            ),
          ),
      '/create_story': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: CreateStoryScreen(),
          ),
      '/my_stories': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: MyStoriesScreen(
              currentUserId: userId ?? "",
            ),
          ),
      '/saved_stories': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: SavedStoriesScreen(
              currentUserId: userId ?? "",
            ),
          ),
    };
  }

  Map<String, WidgetBuilder> _buildEmployerRoutes() {
    return {
      '/home': (context) => VoiceOverlay(
            voiceController: widget.voiceController,
            child: EmployerDashboardScreen(),
          ),
      // Add more employer-specific routes as needed
    };
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.isDarkMode
                ? AppTheme.darkTheme(context)
                : AppTheme.lightTheme(context),
            home: Scaffold(
              body: Center(
                child: LoadingAnimationWidget.hexagonDots(
                  color: AppColors.lightPrimary,
                  size: 20,
                ),
              ),
            ),
          );
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          navigatorKey: widget.navigatorKey,
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
                  ? VoiceOverlay(
                      voiceController: widget.voiceController,
                      child: userType == "employer"
                          ? EmployerDashboardScreen()
                          : CandidateDashboardScreen(),
                    )
                  : OnboardingScreen(),
        );
      },
    );
  }
}
