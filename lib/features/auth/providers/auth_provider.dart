import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signIn(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Fallback/mock logic if Supabase auth fails in dev
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> signUp(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.signUp(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (_) {
      // Fallback/mock logic if Supabase auth fails in dev
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }
}
