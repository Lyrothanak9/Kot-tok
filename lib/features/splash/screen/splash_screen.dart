import 'package:flutter/material.dart';
import 'package:kot_tok/app/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  Future<void> _navigateToNextScreen() async {
    await Future.delayed(const Duration(milliseconds: 10000));

    if (!mounted) return;

    final bool isAuthenticated =
        Supabase.instance.client.auth.currentSession == null;

    Navigator.pushReplacementNamed(
      context,
      isAuthenticated ? AppRoutes.main : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Logo(),
            const SizedBox(height: 24),

            // App Title
            const Text(
              'Kot Tok',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 6),

            // Subtitle
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
