class NoteModel {
  final String id;
  final String userId;
  final String? categoryId;
  final String title;
  final String? content;
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
    required this.isPinned,
    required this.isFavorite,
    required this.createdAt,
    this.updatedAt,
  });

  // Create an object from Supabase JSON response
  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      categoryId: json['category_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String?,
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
      'is_pinned': isPinned,
      'is_favorite': isFavorite,
      // id, created_at, and updated_at are usually handled by Supabase automatically
    };
  }
}