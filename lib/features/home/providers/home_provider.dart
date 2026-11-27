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
  bool _isDisposed = false;
  String? _errorMessage;

  int _totalNotes = 0;
  int _totalCategories = 0;
  List<NoteModel> _pinnedNotes = [];
  List<NoteModel> _recentNotes = [];

  // Filter State
  String? activeCategoryId;
  String activeCategoryName = 'Notes';
  String _searchQuery = '';

  // 2. Public Getters (Read-only access for the UI)
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get totalNotes => _totalNotes;
  int get totalCategories => _totalCategories;
  String get searchQuery => _searchQuery;
  List<NoteModel> get pinnedNotes => _filterNotes(_pinnedNotes);
  List<NoteModel> get recentNotes => _filterNotes(_recentNotes);

  List<NoteModel> _filterNotes(List<NoteModel> notes) {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return notes;
    return notes.where((note) {
      final titleMatch = note.title.toLowerCase().contains(query);
      final contentMatch = (note.content ?? '').toLowerCase().contains(query);
      return titleMatch || contentMatch;
    }).toList();
  }

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

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
        activeCategoryId = null;
        activeCategoryName = 'Notes';
        _searchQuery = '';
        _notify();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      loadHomeData();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  // 3. Core Data Loading Logic
  Future<void> loadHomeData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _isLoading = false;
      _errorMessage = null;
      _notify();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      _notify();

      // Run all three Supabase queries concurrently.
      // Pass the activeCategoryId to filter the notes if a label is selected.
      final results = await Future.wait([
        _homeService.getSummaryStats(),
        _homeService.getPinnedNotes(categoryId: activeCategoryId),
        _homeService.getRecentNotes(categoryId: activeCategoryId),
      ]);

      final stats = results[0] as Map<String, int>;
      _totalNotes = stats['notes_count'] ?? 0;
      _totalCategories = stats['categories_count'] ?? 0;

      _pinnedNotes = results[1] as List<NoteModel>;
      _recentNotes = results[2] as List<NoteModel>;

    } catch (e) {
      _errorMessage = 'Failed to load data: ${e.toString()}';
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      _notify();
    }
  }

  // 4. Triggered by Drawer to filter notes
  void filterByCategory(String? categoryId, String categoryName) {
    activeCategoryId = categoryId;
    activeCategoryName = categoryName;
    loadHomeData();
  }

  void setSearchQuery(String query) {
    if (_searchQuery == query) return;
    _searchQuery = query;
    _notify();
  }

  // 5. Helper method for Pull-to-Refresh functionality
  Future<void> refresh() async {
    await loadHomeData();
  }
}