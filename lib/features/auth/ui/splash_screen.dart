import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../bloc/auth_bloc.dart';
import 'login.dart';

class AuthenticationScreen extends StatefulWidget {
   final bool isDarkMode;
  final VoidCallback toggleTheme;

  const AuthenticationScreen({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {  //  TickerProviderStateMixin for animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;  // Get screen width

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 10,
              right: 10,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: IconButton(
                  key: ValueKey<bool>(widget.isDarkMode),
                  icon: FaIcon(
                    widget.isDarkMode
                        ? FontAwesomeIcons.solidMoon
                        : FontAwesomeIcons.solidSun,
                    size: 30,
                    color: Theme.of(context).primaryColor,
                  ),
                  onPressed:(){
                 //   widget.isDarkMode=!widget.isDarkMode;
                    widget.toggleTheme;
                  },
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // App Logo (Enhanced)
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).primaryColor,
                                Theme.of(context).primaryColor.withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: FaIcon(
                            FontAwesomeIcons.handsHelping,
                            size: screenWidth * 0.18, // Responsive size
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // App Title
                        Text(
                          'Inclusive Jobs',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                            letterSpacing: 1.2,  // Slight letter spacing
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Subtitle
                        Text(
                          'Empowering Professionals, Transforming Workplaces',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[600],  // Muted color
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 40),

                        // User Type Selection Title
                        Text(
                          'Choose Your Role',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).primaryColor,  // A darker primary color
                          ),
                        ),
                        const SizedBox(height: 20),

                        // User Type Buttons (Refactored for better UI)
                        Wrap( // Use Wrap for responsiveness
                          alignment: WrapAlignment.center,
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildRoleButton(
                              context: context,
                              icon: FontAwesomeIcons.buildingUser,
                              label: 'Employer',
                              userType: 'employer',
                            ),
                            _buildRoleButton(
                              context: context,
                              icon: FontAwesomeIcons.userTie,
                              label: 'Candidate',
                              userType: 'candidate',
                            ),
                          ],
                        ),

                        // Theme Toggle
                        const SizedBox(height: 30),

                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String userType,
  }) {
    return ElevatedButton(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => LoginBloc(), // Make sure you are using AuthBloc here not LoginBloc
              child: LoginScreen(
                isDarkMode: widget.isDarkMode,
                onThemeToggle: widget.toggleTheme,
                userType: userType,
              ),
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        backgroundColor: Theme.of(context).colorScheme.secondary,  // Use secondary color
        foregroundColor: Theme.of(context).colorScheme.onSecondary, // Text color
        textStyle: const TextStyle(fontSize: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(icon, size: 20),
          const SizedBox(width: 12),
          Text(label),
        ],
      ),
    );
  }
}