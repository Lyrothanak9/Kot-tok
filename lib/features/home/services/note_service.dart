import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/note_model.dart';

class NoteService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User is not logged in');
    return user.id;
  }

  /// Ensures a record exists in `profiles` for the logged-in user before writing to `notes`.
  Future<void> _ensureProfileExists() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      await _supabase.from('profiles').upsert({
        'id': user.id,
        'full_name': user.userMetadata?['name'] ?? user.email?.split('@').first ?? 'User',
      }, onConflict: 'id');
    } catch (e) {
      debugPrint('Profile auto-ensure notice: $e');
    }
  }

  // Create a new note
  Future<NoteModel> createNote(String title, String content, bool isPinned, String? categoryId) async {
    await _ensureProfileExists();

    final response = await _supabase.from('notes').insert({
      'user_id': _currentUserId,
      'category_id': categoryId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_favorite': false,
    }).select().single();

    debugPrint("userId $_currentUserId");
    debugPrint("categoryId $categoryId");
    debugPrint("title $title");
    debugPrint("content $content");
    debugPrint("Is Pinned $isPinned");
    debugPrint("Response data $response");

    return NoteModel.fromJson(response);
  }

  // Update an existing note
  Future<NoteModel> updateNote(String id, String title, String content, bool isPinned, String? categoryId) async {
    final response = await _supabase.from('notes').update({
      'category_id': categoryId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id).eq('user_id', _currentUserId).select().single();

    return NoteModel.fromJson(response);
  }

  // Delete a note
  Future<void> deleteNote(String id) async {
    await _supabase
        .from('notes')
        .delete()
        .eq('id', id)
        .eq('user_id', _currentUserId);
  }
}