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
}