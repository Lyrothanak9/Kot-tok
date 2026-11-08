import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

class HomeService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Helper getter to strictly enforce queries for the logged-in user
  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User is not logged in');
    return user.id;
  }

  // ==========================================
  // FEATURE 1: SUMMARY STATISTICS
  // ==========================================

  /// Fetches exact counts without downloading all table rows
  Future<Map<String, int>> getSummaryStats() async {
    try {
      // Use count(CountOption.exact) to execute a lightweight SELECT COUNT(*)
      final notesCount = await _supabase
          .from('notes')
          .count(CountOption.exact)
          .eq('user_id', _currentUserId);

      final categoriesCount = await _supabase
          .from('categories')
          .count(CountOption.exact)
          .eq('user_id', _currentUserId);

      return {
        'notes_count': notesCount,
        'categories_count': categoriesCount,
      };
    } catch (e) {
      throw Exception('Failed to load summary statistics: $e');
    }
  }

  // ==========================================
  // FEATURE 2: PINNED NOTES
  // ==========================================

  Future<List<NoteModel>> getPinnedNotes() async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .eq('user_id', _currentUserId)
          .eq('is_pinned', true)
          .order('created_at', ascending: false);

      return response.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load pinned notes: $e');
    }
  }

  // ==========================================
  // FEATURE 3: RECENTLY UPDATED NOTES
  // ==========================================

  Future<List<NoteModel>> getRecentNotes({int limit = 10}) async {
    try {
      final response = await _supabase
          .from('notes')
          .select()
          .eq('user_id', _currentUserId)
          .eq('is_pinned', false) // Exclude pinned notes to avoid duplicate UI cards
      // Order by updated_at, falling back to created_at if null
          .order('updated_at', ascending: false, nullsFirst: false)
          .limit(limit);

      return response.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load recent notes: $e');
    }
  }
}