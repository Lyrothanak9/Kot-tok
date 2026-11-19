import 'dart:convert';

class NoteModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String? content;
  final List<String> imageUrls;
  final bool isPinned;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime? updatedAt;

  NoteModel({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.title,
    this.content,
    this.imageUrls = const [],
    required this.isPinned,
    required this.isFavorite,
    required this.createdAt,
    this.updatedAt,
  });

  // Create an object from Supabase JSON response
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedImageUrls = [];
    if (json['image_urls'] != null) {
      if (json['image_urls'] is List) {
        parsedImageUrls = (json['image_urls'] as List).map((e) => e.toString()).toList();
      } else if (json['image_urls'] is String) {
        final val = json['image_urls'] as String;
        if (val.trim().startsWith('[')) {
          // Attempt to parse JSON array if it was stored as stringified JSON
          try {
            final List<dynamic> decoded = jsonDecode(val);
            parsedImageUrls = decoded.map((e) => e.toString()).toList();
          } catch (_) {
            parsedImageUrls = [val]; // fallback if not valid JSON
          }
        } else {
          // Single string, maybe comma separated or just a single URL
          parsedImageUrls = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        }
      }
    } else if (json['image_url'] != null) {
      parsedImageUrls = [json['image_url'].toString()];
    }

    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String?,
      imageUrls: parsedImageUrls,
      isPinned: json['is_pinned'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  // Convert object to JSON for Supabase inserts/updates
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'title': title,
      'content': content,
      'image_urls': imageUrls,
      'is_pinned': isPinned,
      'is_favorite': isFavorite,
      // id, created_at, and updated_at are usually handled by Supabase automatically
    };
  }
}