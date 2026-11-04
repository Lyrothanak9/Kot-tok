import 'package:flutter/material.dart';

import '../features/auth/screens/forget_password_screen.dart';
import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/Navigation/screen/main_navigation_screen.dart';
import '../features/splash/screen/splash_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String main = '/main';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const SignInScreen(),
        signUp: (context) => const SignUpScreen(),
        main: (context) => const MainNavigationScreen(),
        forgotPassword: (context) => const ForgotPasswordScreen(),
      };
}
