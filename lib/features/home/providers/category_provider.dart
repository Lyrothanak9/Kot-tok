import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();
  StreamSubscription<AuthState>? _authSubscription;

  List<CategoryModel> categories = [];
  bool isLoading = false;
  bool _isDisposed = false;

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  CategoryProvider() {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (data.session != null) {
        loadCategories();
      } else {
        categories = [];
        isLoading = false;
        _notify();
      }
    });

    if (Supabase.instance.client.auth.currentUser != null) {
      loadCategories();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _authSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadCategories() async {
    if (Supabase.instance.client.auth.currentUser == null) {
      categories = [];
      isLoading = false;
      _notify();
      return;
    }

    isLoading = true;
    _notify();

    try {
      categories = await _categoryService.getCategories();
    } catch (e) {
      debugPrint("Error loading categories: $e");
    } finally {
      isLoading = false;
      _notify();
    }
  }

  Future<CategoryModel?> addCategory(String name) async {
    try {
      final newCategory = await _categoryService.createCategory(name);

      // Add the new category to the local list and update UI
      categories.add(newCategory);
      _notify();

      return newCategory;
    } catch (e) {
      debugPrint("Error creating category: $e");
      return null;
    }
  }

  Future<CategoryModel?> updateCategory(String id, String newName) async {
    try {
      final updatedCategory = await _categoryService.updateCategory(id, newName);

      // Update the local list to reflect the change immediately
      final index = categories.indexWhere((c) => c.id == id);
      if (index != -1) {
        categories[index] = updatedCategory;
        _notify();
      }
      return updatedCategory;
    } catch (e) {
      debugPrint("Error updating category: $e");
      return null;
    }
  }

  Future<bool> deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      categories.removeWhere((c) => c.id == id);
      _notify();
      return true;
    } catch (e) {
      debugPrint("Error deleting category: $e");
      return false;
    }
  }
}