import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../models/category_model.dart';

class CategoryProvider extends ChangeNotifier {
  final CategoryService _categoryService = CategoryService();

  List<CategoryModel> categories = [];
  bool isLoading = true;

  CategoryProvider() {
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading = true;
    notifyListeners();

    try {
      categories = await _categoryService.getCategories();
    } catch (e) {
      debugPrint("Error loading categories: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<CategoryModel?> addCategory(String name) async {
    try {
      final newCategory = await _categoryService.createCategory(name);

      // Add the new category to the local list and update UI
      categories.add(newCategory);
      notifyListeners();

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
        notifyListeners();
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
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Error deleting category: $e");
      return false;
    }
  }
}