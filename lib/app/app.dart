import 'package:flutter/material.dart';
import 'package:kot_tok/app/routes.dart';
import 'package:kot_tok/app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/home/providers/navigation_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isAuthenticated = Supabase.instance.client.auth.currentSession != null;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: isAuthenticated ? AppRoutes.main : AppRoutes.login,
        routes: AppRoutes.routes,
      ),
    );
  }
}
