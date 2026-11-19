import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Required for ImagePicker
import '../services/note_service.dart';
import '../models/note_model.dart';

class ChecklistItem {
  bool isChecked;
  final TextEditingController controller;
  final FocusNode focusNode;

  ChecklistItem({this.isChecked = false, String text = ''})
      : controller = TextEditingController(text: text),
        focusNode = FocusNode();

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class NoteEditorProvider extends ChangeNotifier {
  final NoteService _noteService = NoteService();

  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  bool isPinned = false;
  bool isSaving = false;
  String? errorMessage;
  String? categoryId;
  NoteModel? existingNote;

  // --- Multi-Image & Checklist State ---
  List<XFile> localImages = [];
  List<String> remoteImageUrls = [];

  bool isChecklistMode = false;
  List<ChecklistItem> checklistItems = [];
  final ImagePicker _picker = ImagePicker();

  void init(NoteModel? note, {bool isChecklistMode = false}) {
    existingNote = note;
    if (note != null) {
      titleController.text = note.title;
      contentController.text = note.content ?? '';
      isPinned = note.isPinned;
      categoryId = note.categoryId;
      remoteImageUrls = List<String>.from(note.imageUrls);
      localImages.clear();

      // Automatically detect if this note was saved as a checklist
      if (contentController.text.contains('☐ ') || contentController.text.contains('☑ ')) {
        _parseChecklistFromText();
      }
    } else if (isChecklistMode) {
      _parseChecklistFromText();
    }
  }

  // ==========================================
  // IMAGE METHODS
  // ==========================================

  Future<void> pickImage() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty) {
        localImages.addAll(images);
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error picking multiple images: $e");
      // Fallback to single image pick if multi-pick encounters issues on certain platforms
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        localImages.add(image);
        notifyListeners();
      }
    }
  }

  void removeLocalImage(int index) {
    if (index >= 0 && index < localImages.length) {
      localImages.removeAt(index);
      notifyListeners();
    }
  }

  void removeRemoteImage(int index) {
    if (index >= 0 && index < remoteImageUrls.length) {
      remoteImageUrls.removeAt(index);
      notifyListeners();
    }
  }

  // ==========================================
  // CHECKLIST METHODS
  // ==========================================

  void _disposeChecklistItems() {
    for (var item in checklistItems) {
      item.dispose();
    }
    checklistItems.clear();
  }

  void toggleChecklistMode() {
    isChecklistMode = !isChecklistMode;
    if (isChecklistMode) {
      _parseChecklistFromText();
    } else {
      _syncChecklistToText();
      _disposeChecklistItems();
    }
    notifyListeners();
  }

  void _parseChecklistFromText() {
    isChecklistMode = true;
    _disposeChecklistItems();
    final rawText = contentController.text.trim();
    if (rawText.isEmpty) {
      checklistItems = [ChecklistItem()];
      return;
    }

    final lines = rawText.split('\n');
    checklistItems = lines.map((line) {
      final cleanLine = line.replaceAll('\r', '').trimRight();
      if (cleanLine.startsWith('☑ ')) return ChecklistItem(isChecked: true, text: cleanLine.substring(2));
      if (cleanLine.startsWith('☐ ')) return ChecklistItem(isChecked: false, text: cleanLine.substring(2));
      return ChecklistItem(isChecked: false, text: cleanLine);
    }).toList();

    if (checklistItems.isEmpty) {
      checklistItems = [ChecklistItem()];
    }
  }

  void _syncChecklistToText() {
    contentController.text = checklistItems
        .where((item) => item.controller.text.trim().isNotEmpty) // Ignore empty items
        .map((item) => '${item.isChecked ? '☑ ' : '☐ '}${item.controller.text.trim()}')
        .join('\n');
  }

  DateTime _lastSubmittedTime = DateTime.fromMillisecondsSinceEpoch(0);

  void handleItemSubmitted(int index) {
    final now = DateTime.now();
    if (now.difference(_lastSubmittedTime).inMilliseconds < 150) {
      return; // Debounce rapid triggers between onEditingComplete and onSubmitted
    }
    _lastSubmittedTime = now;

    if (index < 0 || index >= checklistItems.length) return;

    final currentItem = checklistItems[index];
    final text = currentItem.controller.text;
    final selection = currentItem.controller.selection;

    String remainingText = text;
    String newText = '';

    if (selection.isValid && selection.baseOffset >= 0 && selection.baseOffset < text.length) {
      // Split text at cursor position if cursor is in middle of string
      remainingText = text.substring(0, selection.baseOffset);
      newText = text.substring(selection.baseOffset);
      currentItem.controller.text = remainingText;
    }

    final newItem = ChecklistItem(text: newText);
    checklistItems.insert(index + 1, newItem);
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newItem.focusNode.requestFocus();
      if (newText.isNotEmpty) {
        newItem.controller.selection = const TextSelection.collapsed(offset: 0);
      }
    });
  }

  void handlePasteOrMultiline(int index, String rawText) {
    if (index < 0 || index >= checklistItems.length) return;

    final lines = rawText.split(RegExp(r'\r?\n')).map((l) => l.trimRight()).toList();
    if (lines.length <= 1) return;

    // The first line replaces current item's text
    checklistItems[index].controller.text = lines.first;

    int insertIdx = index + 1;
    ChecklistItem? lastAdded;
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];
      if (line.isEmpty && i == lines.length - 1) continue;

      String cleanLine = line;
      bool isChecked = false;
      if (cleanLine.startsWith('☑ ')) {
        isChecked = true;
        cleanLine = cleanLine.substring(2);
      } else if (cleanLine.startsWith('☐ ')) {
        isChecked = false;
        cleanLine = cleanLine.substring(2);
      }

      final newItem = ChecklistItem(isChecked: isChecked, text: cleanLine);
      checklistItems.insert(insertIdx, newItem);
      lastAdded = newItem;
      insertIdx++;
    }

    notifyListeners();

    if (lastAdded != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        lastAdded!.focusNode.requestFocus();
      });
    }
  }

  void addChecklistItem({int? afterIndex, String text = ''}) {
    final newItem = ChecklistItem(text: text);
    if (afterIndex != null && afterIndex >= 0 && afterIndex < checklistItems.length) {
      checklistItems.insert(afterIndex + 1, newItem);
    } else {
      checklistItems.add(newItem);
    }
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newItem.focusNode.requestFocus();
    });
  }

  void removeChecklistItem(int index) {
    if (index >= 0 && index < checklistItems.length) {
      checklistItems[index].dispose();
      checklistItems.removeAt(index);
      if (checklistItems.isEmpty) {
        checklistItems.add(ChecklistItem());
      }
      notifyListeners();
    }
  }

  void removeChecklistItemWithFocus(int index) {
    if (index >= 0 && index < checklistItems.length) {
      final prevIndex = index > 0 ? index - 1 : null;
      checklistItems[index].dispose();
      checklistItems.removeAt(index);
      if (checklistItems.isEmpty) {
        checklistItems.add(ChecklistItem());
      }
      notifyListeners();

      if (prevIndex != null && prevIndex < checklistItems.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final prev = checklistItems[prevIndex];
          prev.focusNode.requestFocus();
          prev.controller.selection = TextSelection.collapsed(offset: prev.controller.text.length);
        });
      }
    }
  }

  void toggleChecklistItem(int index, bool? value) {
    if (index >= 0 && index < checklistItems.length) {
      checklistItems[index].isChecked = value ?? false;
      notifyListeners();
    }
  }

  // ==========================================
  // STANDARD NOTE METHODS
  // ==========================================

  void togglePin() {
    isPinned = !isPinned;
    notifyListeners();
  }

  void setCategory(String? newCategoryId) {
    categoryId = newCategoryId;
    notifyListeners();
  }

  Future<bool> saveNote() async {
    // If we are currently looking at the checklist UI, sync it to contentController
    if (isChecklistMode) {
      _syncChecklistToText();
    }

    // Don't save if everything is empty
    if (titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty &&
        localImages.isEmpty &&
        remoteImageUrls.isEmpty) {
      return false;
    }

    isSaving = true;
    errorMessage = null;
    notifyListeners();

    try {
      // 1. Upload any newly picked local images to Supabase storage
      final List<String> updatedImageUrls = List<String>.from(remoteImageUrls);
      String? uploadFailure;
      for (final localFile in List<XFile>.from(localImages)) {
        try {
          final uploadedUrl = await _noteService.uploadImage(localFile);
          updatedImageUrls.add(uploadedUrl);
          localImages.remove(localFile);
        } catch (uploadError) {
          debugPrint("Failed to upload image ${localFile.name}: $uploadError");
          uploadFailure = uploadError.toString();
        }
      }
      remoteImageUrls = updatedImageUrls;
      if (uploadFailure != null && localImages.isNotEmpty) {
        errorMessage = 'Some images could not be uploaded: $uploadFailure';
      }

      // 2. Persist note with updated image URLs
      if (existingNote == null) {
        final created = await _noteService.createNote(
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          isPinned: isPinned,
          categoryId: categoryId,
          imageUrls: remoteImageUrls,
        );
        existingNote = created;
      } else {
        final updated = await _noteService.updateNote(
          id: existingNote!.id,
          title: titleController.text.trim(),
          content: contentController.text.trim(),
          isPinned: isPinned,
          categoryId: categoryId,
          imageUrls: remoteImageUrls,
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
    _disposeChecklistItems();
    super.dispose();
  }
}