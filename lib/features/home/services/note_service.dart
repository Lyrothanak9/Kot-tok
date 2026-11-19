import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
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

  // Upload an image file to Supabase storage bucket 'image_input'
  Future<String> uploadImage(XFile imageFile) async {
    final rawName = imageFile.name;
    final sanitizedName = rawName.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$sanitizedName';
    final filePath = '$_currentUserId/$fileName';

    final bytes = await imageFile.readAsBytes();

    final ext = sanitizedName.split('.').last.toLowerCase();
    String contentType;
    switch (ext) {
      case 'png':
        contentType = 'image/png';
        break;
      case 'webp':
        contentType = 'image/webp';
        break;
      case 'gif':
        contentType = 'image/gif';
        break;
      case 'jpg':
      case 'jpeg':
      default:
        contentType = 'image/jpeg';
        break;
    }


    await _supabase.storage.from('image_input').uploadBinary(
      filePath,
      bytes,
      fileOptions: FileOptions(
        contentType: contentType,
        upsert: true,
      ),
    );

    final publicUrl = _supabase.storage.from('image_input').getPublicUrl(filePath);
    return publicUrl;
  }

  // Create a new note
  Future<NoteModel> createNote({
    required String title,
    required String content,
    required bool isPinned,
    String? categoryId,
    List<String> imageUrls = const [],
  }) async {
    await _ensureProfileExists();

    final data = <String, dynamic>{
      'user_id': _currentUserId,
      'category_id': categoryId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'is_favorite': false,
      'image_urls': imageUrls,
    };

    Map<String, dynamic> response;
    try {
      response = await _supabase.from('notes').insert(data).select().single();
    } catch (e) {
      debugPrint('Insert with image_urls List failed ($e), retrying as encoded JSON string...');
      try {
        data['image_urls'] = jsonEncode(imageUrls);
        response = await _supabase.from('notes').insert(data).select().single();
      } catch (e2) {
        debugPrint('Insert with image_urls string failed ($e2), retrying with image_url column...');
        data.remove('image_urls');
        if (imageUrls.isNotEmpty) {
          data['image_url'] = imageUrls.first;
        }
        try {
          response = await _supabase.from('notes').insert(data).select().single();
        } catch (e3) {
          debugPrint('Insert with image_url also failed ($e3), retrying without image columns...');
          data.remove('image_url');
          response = await _supabase.from('notes').insert(data).select().single();
        }
      }
    }

    return NoteModel.fromJson(response);
  }

  // Update an existing note
  Future<NoteModel> updateNote({
    required String id,
    required String title,
    required String content,
    required bool isPinned,
    String? categoryId,
    List<String> imageUrls = const [],
  }) async {
    final data = <String, dynamic>{
      'category_id': categoryId,
      'title': title,
      'content': content,
      'is_pinned': isPinned,
      'image_urls': imageUrls,
      'updated_at': DateTime.now().toIso8601String(),
    };

    Map<String, dynamic> response;
    try {
      response = await _supabase.from('notes').update(data).eq('id', id).eq('user_id', _currentUserId).select().single();
    } catch (e) {
      debugPrint('Update with image_urls List failed ($e), retrying as encoded JSON string...');
      try {
        data['image_urls'] = jsonEncode(imageUrls);
        response = await _supabase.from('notes').update(data).eq('id', id).eq('user_id', _currentUserId).select().single();
      } catch (e2) {
        debugPrint('Update with image_urls string failed ($e2), retrying with image_url column...');
        data.remove('image_urls');
        if (imageUrls.isNotEmpty) {
          data['image_url'] = imageUrls.first;
        } else {
          data['image_url'] = null;
        }
        try {
          response = await _supabase.from('notes').update(data).eq('id', id).eq('user_id', _currentUserId).select().single();
        } catch (e3) {
          debugPrint('Update with image_url also failed ($e3), retrying without image columns...');
          data.remove('image_url');
          response = await _supabase.from('notes').update(data).eq('id', id).eq('user_id', _currentUserId).select().single();
        }
      }
    }

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