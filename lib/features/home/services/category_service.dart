import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category_model.dart';

class CategoryService {
  final SupabaseClient _supabase = Supabase.instance.client;

  String get _currentUserId {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User is not logged in');
    return user.id;
  }

  // Fetch all categories for the current user
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await _supabase
          .from('categories')
          .select()
          .eq('user_id', _currentUserId)
          .order('created_at', ascending: true);

      return response.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
  Future<CategoryModel> createCategory(String name) async {
    try {
      final response = await _supabase.from('categories').insert({
        'user_id': _currentUserId,
        'name': name,
      }).select().single();

      return CategoryModel.fromJson(response);
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }
}