import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/note_editor_provider.dart';
import '../models/note_model.dart';
import '../widgets/dialog/create_label_dialog.dart';
import '../widgets/dialog/attachment_bottom_sheet.dart';
import '../widgets/dialog/more_options_bottom_sheet.dart';
import '../widgets/image_tile.dart';

class NoteEditorScreen extends StatelessWidget {
  final NoteModel? note; // Pass a note to edit, or null to create a new one
  final bool isChecklist;

  const NoteEditorScreen({super.key, this.note, this.isChecklist = false});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NoteEditorProvider()..init(note, isChecklistMode: isChecklist),
      child: const _NoteEditorContent(),
    );
  }
}

class _NoteEditorContent extends StatelessWidget {
  const _NoteEditorContent();

  Future<void> _saveAndExit(BuildContext context, NoteEditorProvider provider) async {
    final success = await provider.saveNote();
    if (context.mounted) {
      if (!success && provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteEditorProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || provider.isSaving) return;
        await _saveAndExit(context, provider);
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
            onPressed: provider.isSaving
                ? null
                : () => _saveAndExit(context, provider),
          ),
          actions: [
            // Pin Button
            IconButton(
              icon: Icon(
                provider.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              ),
              onPressed: provider.isSaving ? null : () => provider.togglePin(),
            ),
            // Archive / Save Button
            IconButton(
              icon: provider.isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.archive_outlined, color: Colors.black54),
              onPressed: provider.isSaving
                  ? null
                  : () async {
                final success = await provider.saveNote();
                if (context.mounted) {
                  if (!success && provider.errorMessage != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage!),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (success) {
                    Navigator.pop(context);
                  }
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Multi-Image Gallery Header
              if (provider.remoteImageUrls.isNotEmpty || provider.localImages.isNotEmpty)
                Container(
                  height: 180,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // Remote saved images from Supabase
                      ...provider.remoteImageUrls.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final url = entry.value;
                        return ImageTile(
                          image: Image.network(
                            url,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                color: Colors.grey.shade100,
                                child: const Center(
                                  child: SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          onRemove: () => provider.removeRemoteImage(idx),
                        );
                      }),
                      // Local pending images before upload
                      ...provider.localImages.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final file = entry.value;
                        return ImageTile(
                          image: kIsWeb 
                              ? Image.network(file.path, fit: BoxFit.cover) 
                              : Image.file(
                                  File(file.path),
                                  fit: BoxFit.cover,
                                ),
                          onRemove: () => provider.removeLocalImage(idx),
                        );
                      }),
                    ],
                  ),
                ),

              // Title Input
              TextField(
                controller: provider.titleController,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                decoration: const InputDecoration(
                  hintText: 'Title',
                  hintStyle: TextStyle(color: Colors.black38),
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
              ),

              // Dynamic Content Area (Text or Checklist)
              Expanded(
                child: provider.isChecklistMode
                    ? ListView.builder(
                  itemCount: provider.checklistItems.length + 1,
                  itemBuilder: (context, index) {
                    if (index == provider.checklistItems.length) {
                      return InkWell(
                        onTap: () => provider.addChecklistItem(),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 48,
                                height: 40,
                                child: Icon(Icons.add, color: Colors.grey, size: 24),
                              ),
                              Text(
                                'List item',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final item = provider.checklistItems[index];
                    return Padding(
                      key: ObjectKey(item),
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: item.isChecked,
                            onChanged: (val) => provider.toggleChecklistItem(index, val),
                            activeColor: AppColors.primary,
                          ),
                          Expanded(
                            child: TextField(
                              controller: item.controller,
                              focusNode: item.focusNode,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              textInputAction: TextInputAction.next,
                              style: TextStyle(
                                fontSize: 16,
                                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                color: item.isChecked ? Colors.grey : Colors.black87,
                              ),
                              decoration: const InputDecoration(
                                hintText: 'List item',
                                hintStyle: TextStyle(color: Colors.black26),
                                filled: false,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 8),
                              ),
                              onEditingComplete: () {
                                provider.handleItemSubmitted(index);
                              },
                              onChanged: (val) {
                                if (val.contains('\n')) {
                                  provider.handlePasteOrMultiline(index, val);
                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                            splashRadius: 18,
                            onPressed: () => provider.removeChecklistItem(index),
                          ),
                        ],
                      ),
                    );
                  },
                )
                    : TextField(
                  controller: provider.contentController,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                  decoration: const InputDecoration(
                    hintText: 'Note',
                    hintStyle: TextStyle(color: Colors.black38),
                    filled: false,
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),

              // Labels Section
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                width: double.infinity,
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (categoryProvider.isLoading)
                      const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      ...categoryProvider.categories.map((category) {
                        final isSelected = provider.categoryId == category.id;

                        return FilterChip(
                          avatar: isSelected
                              ? null
                              : const Icon(
                            Icons.label_outline,
                            size: 14,
                            color: AppColors.onSurfaceVariant,
                          ),
                          label: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                              color: isSelected ? Colors.white : AppColors.onSurface,
                            ),
                          ),
                          selected: isSelected,
                          showCheckmark: false,
                          backgroundColor: Colors.grey.shade100,
                          selectedColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isSelected ? AppColors.secondary : Colors.grey.shade300,
                            ),
                          ),
                          onSelected: (bool selected) {
                            provider.setCategory(selected ? category.id : null);
                          },
                        );
                      }),
                    ActionChip(
                      avatar: const Icon(Icons.add, size: 14, color: AppColors.primary),
                      label: const Text(
                        'Add label',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      onPressed: () {
                        _showAddLabelDialog(context, categoryProvider, provider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Bottom Action Bar
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          elevation: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.add_box_outlined, color: Colors.black54),
                    onPressed: () => AttachmentBottomSheet.show(context, provider),
                  ),
                  IconButton(
                    icon: const Icon(Icons.palette_outlined, color: Colors.black54),
                    onPressed: () {},
                  ),
                  IconButton(
                    tooltip: 'Add label',
                    icon: const Icon(Icons.label_outline, color: Colors.black54),
                    onPressed: () => _showAddLabelDialog(context, categoryProvider, provider),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.black54),
                onPressed: () => MoreOptionsBottomSheet.show(context, provider),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddLabelDialog(
      BuildContext context,
      CategoryProvider categoryProvider,
      NoteEditorProvider provider,
      ) {
    CreateLabelDialog.show(
      context,
      categoryProvider: categoryProvider,
      onCategoryCreated: (newCategory) {
        provider.setCategory(newCategory.id);
      },
    );
  }
}