import 'package:flutter/material.dart';
import 'package:kot_tok/app/theme/app_theme.dart';
import 'package:kot_tok/features/auth/view/screens/sign_up.dart';
import 'package:provider/provider.dart';

import '../features/auth/view/screens/login.dart';
import '../providers/auth_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SignUpScreen(),
      ),
    );
  }
}
