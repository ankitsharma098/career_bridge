// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'Firebase/firebase_config.dart';
import 'Firebase/notification_services.dart';
import 'app.dart';
import 'core/theme/theme_provider.dart';
import 'core/utils/hiveUtils.dart';
import 'core/utils/config.dart';
import 'features/voice_system/core/command_registry.dart';
import 'features/voice_system/core/voice_controller.dart';
import 'features/voice_system/navigation/voice_navigator.dart';
import 'features/voice_system/services/nlp_services.dart';
import 'features/voice_system/services/speech_recognition_services.dart';
import 'features/voice_system/services/tts_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  await NotificationService.initialize();

  // Load app configuration (including API keys)
  await AppConfig.load();

  //Request necessary permissions
  await _requestPermissions();

  await Hive.initFlutter();
  await HiveUtils.initHive();

  // Initialize voice services
  final services = await initializeVoiceServices();

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(
        voiceController: services.controller,
        navigatorKey: services.navigatorKey,
      ),
    ),
  );
}

Future<void> _requestPermissions() async {
  await Permission.camera.request();
  await Permission.photos.request();
  final micStatus = await Permission.microphone.request();
  debugPrint("Microphone permission status: $micStatus");
}

Future<VoiceServices> initializeVoiceServices() async {
  // Initialize speech service
  final speechService = SpeechRecognitionService();
  final initialized = await speechService.initialize();
  debugPrint("Speech recognition initialized: $initialized");

  // Initialize NLP service for intent recognition
  final nlpService = NLPService(
    apiEndpoint: AppConfig.nlpApiEndpoint,
    apiKey: AppConfig.nlpApiKey,
  );

  // Register navigation intents
  _registerNavigationIntents(nlpService);

  // Initialize TTS service
  final ttsService = TTSService();
  await ttsService.initialize();

  // Initialize command registry
  final commandRegistry = CommandRegistry();

  // Create navigator key for routing
  final navigatorKey = GlobalKey<NavigatorState>();

  // Initialize voice controller
  final voiceController = VoiceController(
    speechService: speechService,
    nlpService: nlpService,
    ttsService: ttsService,
    commandRegistry: commandRegistry,
  );

  // Initialize voice navigator
  final voiceNavigator = VoiceNavigator(
    voiceController: voiceController,
    commandRegistry: commandRegistry,
    navigatorKey: navigatorKey,
  );

  return VoiceServices(
    controller: voiceController,
    navigatorKey: navigatorKey,
  );
}

void _registerNavigationIntents(NLPService nlpService) {
  nlpService.registerIntent(
      'navigation.goBack', ['go back', 'return', 'previous screen', 'back']);

  nlpService.registerIntent('navigation.goHome',
      ['go home', 'home screen', 'main screen', 'dashboard']);

  nlpService.registerIntent('navigation.goToProfile',
      ['go to profile', 'open profile', 'show my profile', 'profile page']);

  nlpService.registerIntent('navigation.goToAboutUs',
      ['go to about us', 'about us', 'about us screen']);

  nlpService.registerIntent(
      'navigation.goToJobs', ['go to jobs', 'jobs page', 'jobs section']);

  nlpService.registerIntent('navigation.goToJobStats',
      ['go to job stats', 'job stats page', 'job stats section']);

  nlpService.registerIntent('navigation.goToEnrolledJobs',
      ['go to enrolled jobs', 'enrolled jobs page', 'enrolled jobs section']);

  nlpService.registerIntent('navigation.goToSavedJobs',
      ['go to saved jobs', 'saved jobs page', 'saved jobs section']);

  nlpService.registerIntent(
      'navigation.goToChat', ['go to chat', 'chat page', 'chat section']);

  nlpService.registerIntent('navigation.goToStories',
      ['go to stories', 'stories page', 'stories section']);

  nlpService.registerIntent('navigation.goToCreateStory',
      ['go to create story', 'create story', 'create story page']);

  nlpService.registerIntent('navigation.goToMyStories',
      ['go to my stories', 'my stories', 'my stories page']);

  nlpService.registerIntent('navigation.goToSavedStories',
      ['go to saved stories', 'saved stories', 'saved stories page']);
}

class VoiceServices {
  final VoiceController controller;
  final GlobalKey<NavigatorState> navigatorKey;

  VoiceServices({required this.controller, required this.navigatorKey});
}
