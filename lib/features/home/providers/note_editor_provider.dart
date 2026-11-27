import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  bool showCheckedItems = true;
  bool _isDisposed = false;
  List<ChecklistItem> checklistItems = [];
  final ImagePicker _picker = ImagePicker();

  void _notify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // --- Checklist Computed Getters ---
  List<ChecklistItem> get uncheckedItems =>
      checklistItems.where((item) => !item.isChecked).toList();

  List<ChecklistItem> get checkedItems =>
      checklistItems.where((item) => item.isChecked).toList();

  int get completedCount =>
      checklistItems.where((item) => item.isChecked).length;

  int get totalCount => checklistItems.length;

  double get checklistProgress =>
      checklistItems.isEmpty ? 0.0 : completedCount / checklistItems.length;

  bool get allItemsChecked =>
      checklistItems.isNotEmpty && completedCount == checklistItems.length;

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
      if (contentController.text.contains('☐ ') ||
          contentController.text.contains('☑ ')) {
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

  void _disposeChecklistItems({bool defer = false}) {
    final itemsToDispose = List<ChecklistItem>.from(checklistItems);
    checklistItems.clear();
    if (defer) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        for (final item in itemsToDispose) {
          item.dispose();
        }
      });
    } else {
      for (final item in itemsToDispose) {
        item.dispose();
      }
    }
  }

  void _disposeSingleItemSafely(ChecklistItem item) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      item.dispose();
    });
  }

  void _partitionChecklistItems() {
    final unchecked = checklistItems.where((i) => !i.isChecked).toList();
    final checked = checklistItems.where((i) => i.isChecked).toList();
    checklistItems = [...unchecked, ...checked];
  }

  void toggleChecklistMode() {
    isChecklistMode = !isChecklistMode;
    if (isChecklistMode) {
      _parseChecklistFromText();
    } else {
      // Convert cleanly to plain text lines without ☐ / ☑ prefixes
      _syncChecklistToPlainText();
      _disposeChecklistItems(defer: true);
    }
    notifyListeners();
  }

  void toggleShowCheckedItems() {
    showCheckedItems = !showCheckedItems;
    notifyListeners();
  }

  void _parseChecklistFromText() {
    isChecklistMode = true;
    _disposeChecklistItems(defer: true);
    final rawText = contentController.text.trim();
    if (rawText.isEmpty) {
      checklistItems = [ChecklistItem()];
      return;
    }

    final lines = rawText.split(RegExp(r'\r?\n'));
    checklistItems = lines
        .map((line) => line.replaceAll('\r', '').trimRight())
        .where((line) => line.isNotEmpty)
        .map((cleanLine) {
      if (cleanLine.startsWith('☑ ')) {
        return ChecklistItem(isChecked: true, text: cleanLine.substring(2));
      }
      if (cleanLine == '☑') {
        return ChecklistItem(isChecked: true);
      }
      if (cleanLine.startsWith('☐ ')) {
        return ChecklistItem(isChecked: false, text: cleanLine.substring(2));
      }
      if (cleanLine == '☐') {
        return ChecklistItem(isChecked: false);
      }
      return ChecklistItem(isChecked: false, text: cleanLine);
    }).toList();

    if (checklistItems.isEmpty) {
      checklistItems = [ChecklistItem()];
    } else {
      _partitionChecklistItems();
    }
  }

  void _syncChecklistToText() {
    contentController.text = checklistItems
        .where((item) => item.controller.text.trim().isNotEmpty)
        .map((item) =>
    '${item.isChecked ? '☑ ' : '☐ '}${item.controller.text.trim()}')
        .join('\n');
  }

  void _syncChecklistToPlainText() {
    contentController.text = checklistItems
        .where((item) => item.controller.text.trim().isNotEmpty)
        .map((item) => item.controller.text.trim())
        .join('\n');
  }

  DateTime _lastSubmittedTime = DateTime.fromMillisecondsSinceEpoch(0);

  void handleItemSubmitted(int index) {
    final now = DateTime.now();
    if (now.difference(_lastSubmittedTime).inMilliseconds < 150) {
      return; // Debounce rapid triggers between onEditingComplete and onChanged
    }
    _lastSubmittedTime = now;

    if (index < 0 || index >= checklistItems.length) return;

    final currentItem = checklistItems[index];
    final text = currentItem.controller.text;
    final selection = currentItem.controller.selection;

    String remainingText = text;
    String newText = '';

    if (selection.isValid &&
        selection.baseOffset >= 0 &&
        selection.baseOffset < text.length) {
      remainingText = text.substring(0, selection.baseOffset);
      newText = text.substring(selection.baseOffset);
      currentItem.controller.text = remainingText;
      currentItem.controller.selection =
          TextSelection.collapsed(offset: remainingText.length);
    }

    final newItem = ChecklistItem(
      isChecked: currentItem.isChecked,
      text: newText,
    );
    checklistItems.insert(index + 1, newItem);
    notifyListeners();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      newItem.focusNode.requestFocus();
      newItem.controller.selection = const TextSelection.collapsed(offset: 0);
    });
  }

  void handlePasteOrMultiline(int index, String rawText) {
    if (index < 0 || index >= checklistItems.length) return;

    final lines =
    rawText.split(RegExp(r'\r?\n')).map((l) => l.trimRight()).toList();
    if (lines.length <= 1) return;

    _lastSubmittedTime = DateTime.now();

    // Parse first line (strip checkbox symbol if pasted)
    String firstLine = lines.first;
    if (firstLine.startsWith('☑ ')) {
      checklistItems[index].isChecked = true;
      firstLine = firstLine.substring(2);
    } else if (firstLine.startsWith('☐ ')) {
      checklistItems[index].isChecked = false;
      firstLine = firstLine.substring(2);
    }

    checklistItems[index].controller.text = firstLine;
    checklistItems[index].controller.selection =
        TextSelection.collapsed(offset: firstLine.length);

    final bool isSingleNewlineSplit = lines.length == 2;
    int insertIdx = index + 1;
    ChecklistItem? lastAdded;

    for (int i = 1; i < lines.length; i++) {
      final line = lines[i];

      // Only skip trailing empty line when pasting multiple lines (> 2)
      if (!isSingleNewlineSplit && line.isEmpty && i == lines.length - 1) {
        continue;
      }

      String cleanLine = line;
      bool isChecked = checklistItems[index].isChecked;
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

    _partitionChecklistItems();
    notifyListeners();

    if (lastAdded != null) {
      final target = lastAdded;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        target.focusNode.requestFocus();
        // If user hit Enter in middle of text, put cursor at start of split text
        final offset = isSingleNewlineSplit ? 0 : target.controller.text.length;
        target.controller.selection = TextSelection.collapsed(offset: offset);
      });
    }
  }

  void addChecklistItem({int? afterIndex, String text = ''}) {
    final newItem = ChecklistItem(text: text);
    if (afterIndex != null &&
        afterIndex >= 0 &&
        afterIndex < checklistItems.length) {
      checklistItems.insert(afterIndex + 1, newItem);
    } else {
      // Insert right after the last unchecked item
      final uncheckedCount = uncheckedItems.length;
      checklistItems.insert(uncheckedCount, newItem);
    }
    notifyListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      newItem.focusNode.requestFocus();
    });
  }

  void removeChecklistItem(int index) {
    if (index >= 0 && index < checklistItems.length) {
      final removed = checklistItems.removeAt(index);
      _disposeSingleItemSafely(removed);
      if (checklistItems.isEmpty) {
        checklistItems.add(ChecklistItem());
      }
      notifyListeners();
    }
  }

  void removeChecklistItemWithFocus(int index) {
    if (index >= 0 && index < checklistItems.length) {
      final prevIndex = index > 0 ? index - 1 : null;
      final removed = checklistItems.removeAt(index);
      _disposeSingleItemSafely(removed);

      if (checklistItems.isEmpty) {
        final fresh = ChecklistItem();
        checklistItems.add(fresh);
        notifyListeners();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          fresh.focusNode.requestFocus();
        });
        return;
      }

      notifyListeners();

      if (prevIndex != null && prevIndex < checklistItems.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (prevIndex < checklistItems.length) {
            final prev = checklistItems[prevIndex];
            prev.focusNode.requestFocus();
            prev.controller.selection =
                TextSelection.collapsed(offset: prev.controller.text.length);
          }
        });
      }
    }
  }

  /// Handles pressing Backspace when cursor is at offset 0 of a checklist item.
  /// - If empty, deletes the item and focuses the previous one.
  /// - If non-empty and a previous item in the same checked-state group exists,
  ///   merges its text into the previous item.
  void handleBackspaceAtStart(int index) {
    if (index < 0 || index >= checklistItems.length) return;

    final current = checklistItems[index];
    final currentText = current.controller.text;

    if (currentText.isEmpty) {
      if (checklistItems.length > 1) {
        removeChecklistItemWithFocus(index);
      }
      return;
    }

    if (index > 0 && checklistItems[index - 1].isChecked == current.isChecked) {
      final prev = checklistItems[index - 1];
      final mergeOffset = prev.controller.text.length;
      prev.controller.text = '${prev.controller.text}$currentText';

      final removed = checklistItems.removeAt(index);
      _disposeSingleItemSafely(removed);
      notifyListeners();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        prev.focusNode.requestFocus();
        prev.controller.selection =
            TextSelection.collapsed(offset: mergeOffset);
      });
    }
  }

  void toggleChecklistItem(int index, bool? value) {
    if (index >= 0 && index < checklistItems.length) {
      checklistItems[index].isChecked = value ?? false;
      _partitionChecklistItems();
      notifyListeners();
    }
  }

  void reorderUncheckedItem(int oldIndex, int newIndex) {
    final unchecked = uncheckedItems;
    if (oldIndex < 0 ||
        oldIndex >= unchecked.length ||
        newIndex < 0 ||
        newIndex >= unchecked.length) {
      return;
    }

    final moved = unchecked.removeAt(oldIndex);
    unchecked.insert(newIndex, moved);
    checklistItems = [...unchecked, ...checkedItems];
    _notify();
  }

  void toggleAllChecklistItems() {
    if (checklistItems.isEmpty) return;
    final targetState = !allItemsChecked;
    for (final item in checklistItems) {
      item.isChecked = targetState;
    }
    _partitionChecklistItems();
    _notify();
  }

  void uncheckAllItems() {
    for (final item in checklistItems) {
      item.isChecked = false;
    }
    _partitionChecklistItems();
    _notify();
  }

  void deleteCheckedItems() {
    final toRemove = checklistItems.where((item) => item.isChecked).toList();
    if (toRemove.isEmpty) return;

    checklistItems.removeWhere((item) => item.isChecked);
    for (final item in toRemove) {
      _disposeSingleItemSafely(item);
    }

    if (checklistItems.isEmpty) {
      checklistItems.add(ChecklistItem());
    }
    notifyListeners();
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

    // Don't save a brand new note if everything is empty
    if (existingNote == null &&
        titleController.text.trim().isEmpty &&
        contentController.text.trim().isEmpty &&
        localImages.isEmpty &&
        remoteImageUrls.isEmpty) {
      return false;
    }

    isSaving = true;
    errorMessage = null;
    _notify();

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
      _notify();
    }
  }

  Future<bool> deleteNote() async {
    if (existingNote == null) return true;

    isSaving = true;
    errorMessage = null;
    _notify();

    try {
      await _noteService.deleteNote(existingNote!.id);
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete note: $e';
      debugPrint("Error deleting note: $e");
      return false;
    } finally {
      isSaving = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    titleController.dispose();
    contentController.dispose();
    _disposeChecklistItems(defer: false);
    super.dispose();
  }
}