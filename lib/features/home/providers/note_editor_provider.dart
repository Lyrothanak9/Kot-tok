import 'package:flutter/material.dart';
import '../services/note_service.dart';
import '../models/note_model.dart';

class NoteEditorProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  bool isPinned = false;
  bool isSaving = false;
  String? errorMessage;
  String? categoryId;
  NoteModel? existingNote;

  void init(NoteModel? note) {
    existingNote = note;
    if (note != null) {
      titleController.text = note.title;
      contentController.text = note.content ?? '';
      isPinned = note.isPinned;
      categoryId = note.categoryId;
    }
  }

  void togglePin() {
    isPinned = !isPinned;
    notifyListeners();
  }

  void setCategory(String? newCategoryId) {
    categoryId = newCategoryId;
    notifyListeners();
  }

  Future<bool> saveNote() async {
    if (titleController.text.trim().isEmpty && contentController.text.trim().isEmpty) {
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      if (existingNote == null) {
        final created = await _noteService.createNote(
          titleController.text.trim(),
          contentController.text.trim(),
          isPinned,
          categoryId,
        );
        existingNote = created;
      } else {
        final updated = await _noteService.updateNote(
          existingNote!.id,
          titleController.text.trim(),
          contentController.text.trim(),
          isPinned,
          categoryId,
        );
        existingNote = updated;
      }
      return true;
    } catch (e) {
      errorMessage = 'Failed to save note: $e';
      debugPrint("Error saving note: $e");
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deleteNote() async {
    if (existingNote == null) return true;

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _noteService.deleteNote(existingNote!.id);
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete note: $e';
      debugPrint("Error deleting note: $e");
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}