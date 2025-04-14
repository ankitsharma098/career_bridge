import 'package:flutter/material.dart';

import '../core/command_registry.dart';
import '../core/voice_controller.dart';
import '../models/voice_command.dart';

class VoiceNavigator {
  final VoiceController _voiceController;
  final CommandRegistry _commandRegistry;
  final GlobalKey<NavigatorState> navigatorKey;

  VoiceNavigator({
    required VoiceController voiceController,
    required CommandRegistry commandRegistry,
    required this.navigatorKey,
  })  : _voiceController = voiceController,
        _commandRegistry = commandRegistry {
    _registerNavigationCommands();
  }

  void _registerNavigationCommands() {
    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goBack',
        triggerPhrases: ['go back', 'return', 'previous screen', 'back'],
        description: 'Go back to previous screen',
      ),
      (_) => _goBack(),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goHome',
        triggerPhrases: ['go home', 'home screen', 'main screen', 'dashboard'],
        description: 'Go to home screen',
      ),
      (_) => _goToRoute('/home'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToProfile',
        triggerPhrases: [
          'go to profile',
          'open profile',
          'show my profile',
          'profile page'
        ],
        description: 'Go to profile screen',
      ),
      (_) => _goToRoute('/profile'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToAboutUs',
        triggerPhrases: ['go to about us', 'about us', 'about us screen'],
        description: 'Go to about us screen',
      ),
      (_) => _goToRoute('/about_us'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToJobs',
        triggerPhrases: ['go to jobs', 'jobs page', 'jobs section'],
        description: 'Go to jobs screen',
      ),
      (_) => _goToRoute('/jobs'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToJobStats',
        triggerPhrases: [
          'go to job stats',
          'job stats page',
          'job stats section'
        ],
        description: 'Go to job stats screen',
      ),
      (_) => _goToRoute('/job_stats'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToEnrolledJobs',
        triggerPhrases: [
          'go to enrolled jobs',
          'enrolled jobs page',
          'enrolled jobs section'
        ],
        description: 'Go to enrolled jobs screen',
      ),
      (_) => _goToRoute('/enrolled_jobs'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToSavedJobs',
        triggerPhrases: [
          'go to saved jobs',
          'saved jobs page',
          'saved jobs section'
        ],
        description: 'Go to saved jobs screen',
      ),
      (_) => _goToRoute('/saved_jobs'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToChat',
        triggerPhrases: ['go to chat', 'chat page', 'chat section'],
        description: 'Go to chat screen',
      ),
      (_) => _goToRoute('/chat'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToStories',
        triggerPhrases: ['go to stories', 'stories page', 'stories section'],
        description: 'Go to stories screen',
      ),
      (_) => _goToRoute('/stories'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToCreateStory',
        triggerPhrases: [
          'go to create story',
          'create story',
          'create story page'
        ],
        description: 'Go to create story screen',
      ),
      (_) => _goToRoute('/create_story'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToMyStories',
        triggerPhrases: ['go to my stories', 'my stories', 'my stories page'],
        description: 'Go to my stories screen',
      ),
      (_) => _goToRoute('/my_stories'),
    );

    _commandRegistry.registerCommand(
      VoiceCommand(
        id: 'navigation.goToSavedStories',
        triggerPhrases: [
          'go to saved stories',
          'saved stories',
          'saved stories page'
        ],
        description: 'Go to saved stories screen',
      ),
      (_) => _goToRoute('/saved_stories'),
    );
  }

  bool _goBack() {
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null && navigator.canPop()) {
      navigator.pop();
      return true;
    }
    return false;
  }

  bool _goToRoute(String route) {
    debugPrint('Navigating to route: $route');
    final NavigatorState? navigator = navigatorKey.currentState;
    if (navigator != null) {
      debugPrint('Navigator state found, pushing route: $route');
      navigator.pushNamed(route);
      return true;
    }
    debugPrint('Navigator state is null, cannot navigate to: $route');
    return false;
  }
}
