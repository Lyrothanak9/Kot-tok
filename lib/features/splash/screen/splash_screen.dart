import 'package:flutter/material.dart';
import 'package:kot_tok/app/routes.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/logo.dart';
import '../provider/splash_provider.dart';

/// The initial screen shown when the application launches.
///
/// [SplashScreen] handles the startup routing logic. It displays the app branding
/// (Logo and Title) for a brief duration before navigating the user to either
/// the Main Screen or the Login Screen based on their authentication status.
class SplashScreen extends StatefulWidget {
  /// Creates a [SplashScreen].
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Initiates the startup timer and navigation check as soon as the screen loads.
    _navigateToNextScreen();
  }

  /// Delays for a set duration, checks authentication status, and routes accordingly.
  Future<void> _navigateToNextScreen() async {
    // Artificial delay to allow the user to see the splash branding (1 second).
    await Future.delayed(const Duration(milliseconds: 1000));

    // Ensure the widget is still in the tree before using the BuildContext.
    if (!mounted) return;

    // Check the user's authentication status from the SplashProvider.
    final bool isAuthenticated =
        context.read<SplashProvider>().isAuthenticated;

    // Replace the splash screen in the navigation stack so the user cannot navigate
    // back to it using the device's back button.
    Navigator.pushReplacementNamed(
      context,
      isAuthenticated ? AppRoutes.main : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // A soft, light background color for the splash screen.
      backgroundColor: const Color(0xFFFBFBFF),
      body: Center(
        child: Column(
          // Center all branding elements vertically on the screen.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo Widget
            const Logo(height: 112),
            const SizedBox(height: 16),
            
            // App Title
            const Text(
              'Kot Tok',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),

            // Small vertical gap between the title and the subtitle.
            const SizedBox(height: 6),

            // App Subtitle / Catchphrase
            const Text(
              'Notes and lists',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
