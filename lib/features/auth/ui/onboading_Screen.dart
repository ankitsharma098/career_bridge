import 'package:android/features/auth/ui/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const OnboardingScreen({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme
  }) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> onboardingData = [
    {
      'icon': FontAwesomeIcons.wheelchair,
      'title': 'Inclusive Workplace',
      'description': 'Breaking barriers and creating equal employment opportunities for individuals with disabilities.'
    },
    {
      'icon': FontAwesomeIcons.handHoldingHeart,
      'title': 'Empowerment Through Work',
      'description': 'Connecting talented individuals with employers who value diversity and unique perspectives.'
    },
    {
      'icon': FontAwesomeIcons.solidStar,
      'title': 'Celebrating Abilities',
      'description': 'A platform dedicated to showcasing the incredible talents and potential of disabled professionals.',
      'quote': '"Disability is not a hindrance to success, but an opportunity for extraordinary achievement."'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Mission Statement
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                'Bridging Talents, Breaking Barriers',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(onboardingData[index]);
                },
              ),
            ),

            // Page Indicator
            SmoothPageIndicator(
              controller: _pageController,
              count: onboardingData.length,
              effect: WormEffect(
                activeDotColor: Theme.of(context).primaryColor,
                dotColor: Colors.grey.shade300,
              ),
            ),

            // Navigation Buttons
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  _currentPage != onboardingData.length - 1
                      ? TextButton(
                    onPressed: () {
                      _pageController.animateToPage(
                        onboardingData.length - 1,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Skip'),
                  )
                      : const SizedBox(),

                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == onboardingData.length - 1) {
                        // Navigate to Authentication Screen
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => AuthenticationScreen(
                              isDarkMode: widget.isDarkMode,
                              toggleTheme: widget.toggleTheme,
                            ),
                          ),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(_currentPage == onboardingData.length - 1
                        ? 'Get Started'
                        : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(Map<String, dynamic> page) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Font Awesome Icon
          FaIcon(
            page['icon'],
            size: 120,
            color: Theme.of(context).primaryColor,
          ),
          const SizedBox(height: 30),

          // Title
          Text(
            page['title'],
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 15),

          // Description
          Text(
            page['description'],
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),

          // Optional Quote
          if (page['quote'] != null) ...[
            const SizedBox(height: 15),
            Text(
              page['quote'],
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
          ]
        ],
      ),
    );
  }
}