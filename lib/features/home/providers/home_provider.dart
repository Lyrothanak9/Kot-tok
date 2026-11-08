import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/home_service.dart';
import '../models/note_model.dart';

class HomeProvider extends ChangeNotifier {
  final HomeService _homeService = HomeService();
  StreamSubscription<AuthState>? _authSubscription;

  // 1. Private State Variables
  bool _isLoading = false;
  String? _errorMessage;

  int _totalNotes = 0;
  int _totalCategories = 0;
  List<NoteModel> _pinnedNotes = [];
  List<NoteModel> _recentNotes = [];

  // 2. Public Getters (Read-only access for the UI)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalNotes => _totalNotes;
  int get totalCategories => _totalCategories;
  List<NoteModel> get pinnedNotes => _pinnedNotes;
  List<NoteModel> get recentNotes => _recentNotes;

  // Initialize data and listen for auth state changes
  HomeProvider() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        loadHomeData();
      } else {
        _totalNotes = 0;
        _totalCategories = 0;
        _pinnedNotes = [];
        _recentNotes = [];
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      loadHomeData();
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // 3. Core Data Loading Logic
  Future<void> loadHomeData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners(); // Tell UI to show loading indicators

      // Future.wait runs all three Supabase queries at the same time,
      // making your app load significantly faster than awaiting them one by one.
      final results = await Future.wait([
        _homeService.getSummaryStats(),
        _homeService.getPinnedNotes(),
        _homeService.getRecentNotes(),
      ]);

      // Parse the results from the Future.wait array
      final stats = results[0] as Map<String, int>;
      _totalNotes = stats['notes_count'] ?? 0;
      _totalCategories = stats['categories_count'] ?? 0;

      _pinnedNotes = results[1] as List<NoteModel>;
      _recentNotes = results[2] as List<NoteModel>;

    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      debugPrint(_errorMessage); // Helpful for console debugging
    } finally {
      _isLoading = false;
      notifyListeners(); // Tell UI to rebuild with the new data or error message
    }
  }

  // 4. Helper method for Pull-to-Refresh functionality
  Future<void> refresh() async {
    await loadHomeData();
  }
}