import 'package:flutter/material.dart';

import '../views/auth/sign_in_screen.dart';
import '../views/auth/sign_up_screen.dart';
import '../views/main/main_navigation_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String main = '/main';

  static Map<String, WidgetBuilder> get routes => {
        login: (context) => const SignInScreen(),
        signUp: (context) => const SignUpScreen(),
        main: (context) => const MainNavigationScreen(),
      };
}
