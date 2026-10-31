import 'package:flutter/material.dart';

import '../features/auth/screens/sign_in_screen.dart';
import '../features/auth/screens/sign_up_screen.dart';
import '../features/home/screens/main_navigation_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String main = '/main';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const SignInScreen(),
        signUp: (context) => const SignUpScreen(),
        main: (context) => const MainNavigationScreen(),
      };
}
