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

  Future<List<NoteModel>> getPinnedNotes({String? categoryId}) async {
    try {
      var query = _supabase.from('notes').select()
          .eq('user_id', _currentUserId)
          .eq('is_pinned', true);

      // If a label is selected, filter by it
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('created_at', ascending: false);
      return response.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load pinned notes: $e');
    }
  }

  // ==========================================
  // FEATURE 3: RECENTLY UPDATED NOTES
  // ==========================================

  Future<List<NoteModel>> getRecentNotes({String? categoryId, int limit = 10}) async {
    try {
      var query = _supabase.from('notes').select()
          .eq('user_id', _currentUserId)
          .eq('is_pinned', false);

      // If a label is selected, filter by it
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('updated_at', ascending: false, nullsFirst: false).limit(limit);
      return response.map((json) => NoteModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load recent notes: $e');
    }
  }
}