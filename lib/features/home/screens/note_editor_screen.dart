import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/theme/app_colors.dart';
import '../providers/category_provider.dart';
import '../providers/note_editor_provider.dart';
import '../models/note_model.dart';

class NoteEditorScreen extends StatelessWidget {
  final NoteModel? note; // Pass a note to edit, or null to create a new one

  const NoteEditorScreen({super.key, this.note});

  @override
  Widget build(BuildContext context) {
    // Wrap the screen in ChangeNotifierProvider to provide the state locally
    return ChangeNotifierProvider(
      create: (_) => NoteEditorProvider()..init(note),
      child: const _NoteEditorContent(),
    );
  }
}

class _NoteEditorContent extends StatelessWidget {
  const _NoteEditorContent();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NoteEditorProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
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
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black54),
            onPressed: () async {
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
            },
          ),
          actions: [
            // Pin Button
            IconButton(
              icon: Icon(
                provider.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
                // color: provider.isPinned ? C olors.blueAccent: Colors.black54,
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
            // Title Input[cite: 5]
            TextField(
              controller: provider.titleController,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
              decoration: const InputDecoration(
                hintText: 'Title',
                hintStyle: TextStyle(color: Colors.black38),
                filled: false, // Ensures there is no background color
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
            ),
            // Note Content Input[cite: 5]
            Expanded(
              child: TextField(
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
                            : const Icon(Icons.label_outline, size: 14, color: AppColors.onSurfaceVariant),
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
      // Bottom Action Bar[cite: 5]
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(icon: const Icon(Icons.add_box_outlined, color: Colors.black54), onPressed: () {}),
                IconButton(icon: const Icon(Icons.palette_outlined, color: Colors.black54), onPressed: () {}),
                IconButton(
                  tooltip: 'Add label',
                  icon: const Icon(Icons.label_outline, color: Colors.black54),
                  onPressed: () => _showAddLabelDialog(context, categoryProvider, provider),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black54),
              onPressed: () => _showMoreOptions(context, provider),
            ),
          ],
        ),
      ),
    ),
  );
}

  // Displays the bottom sheet when the "More" (3 dots) button is tapped
  void _showMoreOptions(BuildContext context, NoteEditorProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(context, provider); // Triggers the Delete Dialog[cite: 4]
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // The custom Delete Confirmation Dialog[cite: 4]
  void _showDeleteDialog(BuildContext context, NoteEditorProvider provider) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text(
            'Delete Note?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'This action cannot be undone. The note "${provider.titleController.text.isEmpty ? 'Untitled' : provider.titleController.text}" will be permanently deleted.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          actions: [
            Column(
              children: [
                // Cancel Button[cite: 4]
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
                // Deep Blue Delete Button[cite: 4]
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E0B99), // Deep blue from your design
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    ),
                    onPressed: () async {
                      Navigator.pop(dialogContext); // Close dialog
                      final success = await provider.deleteNote();
                      if (context.mounted) {
                        if (!success && provider.errorMessage != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage!),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else if (success) {
                          Navigator.pop(context); // Go back to Home Screen
                        }
                      }
                    },
                    child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  void _showAddLabelDialog(BuildContext context, CategoryProvider categoryProvider, NoteEditorProvider provider) {
    final TextEditingController labelController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Create New Label', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: labelController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Enter label name',
              hintStyle: TextStyle(color: Colors.grey),
              filled: false,
              border: UnderlineInputBorder(),
              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.primary, width: 2)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () async {
                final name = labelController.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(dialogContext); // Close dialog immediately for a snappy UI

                  // Call the provider to save to Supabase
                  final newCategory = await categoryProvider.addCategory(name);

                  // Automatically select the newly created label for this note
                  if (newCategory != null) {
                    provider.setCategory(newCategory.id);
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}