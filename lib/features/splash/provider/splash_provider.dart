import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashProvider extends ChangeNotifier {
  bool get isAuthenticated => Supabase.instance.client.auth.currentSession != null;
}
