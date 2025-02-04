import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CustomErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData? icon;

  const CustomErrorScreen({
    Key? key,
    this.title = 'Oops! Something Went Wrong',
    required this.message,
    this.buttonText = 'Retry',
    this.onRetry,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Lottie Animation (requires lottie package)
                Lottie.asset(
                  'assets/animations/error.json', // You'll need to add this
                  width: 250,
                  height: 250,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 24),

                // Error Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Error Message
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Retry Button
                if (onRetry != null)
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: Icon(icon ?? Icons.refresh),
                    label: Text(buttonText ?? 'Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Factory methods for common error scenarios
  factory CustomErrorScreen.network({
    required String message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorScreen(
      title: 'Network Error',
      message: message,
      icon: Icons.wifi_off_rounded,
      onRetry: onRetry,
    );
  }

  factory CustomErrorScreen.serverError({
    required String message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorScreen(
      title: 'Server Error',
      message: message,
      icon: Icons.cloud_off_rounded,
      onRetry: onRetry,
    );
  }

  factory CustomErrorScreen.unauthorized({
    required String message,
    VoidCallback? onRetry,
  }) {
    return CustomErrorScreen(
      title: 'Access Denied',
      message: message,
      icon: Icons.lock_outline,
      onRetry: onRetry,
    );
  }
}

// Example usage in a Bloc
// class ErrorHandlingExample extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<YourBloc, YourState>(
//       builder: (context, state) {
//         if (state is ErrorState) {
//           return CustomErrorScreen.network(
//             message: state.errorMessage,
//             onRetry: () {
//               context.read<YourBloc>().add(RetryEvent());
//             },
//           );
//         }
//         // Other state handling
//         return Container();
//       },
//     );
//   }
// }