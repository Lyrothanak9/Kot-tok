import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';
import 'edit_label_dialog.dart';

class ManageLabelsDialog extends StatefulWidget {
  final CategoryProvider categoryProvider;
  final ValueChanged<CategoryModel>? onCategoryUpdated;
  final ValueChanged<String>? onCategoryDeleted;

  const ManageLabelsDialog({
    super.key,
    required this.categoryProvider,
    this.onCategoryUpdated,
    this.onCategoryDeleted,
  });

  static Future<void> show(
    BuildContext context, {
    required CategoryProvider categoryProvider,
    ValueChanged<CategoryModel>? onCategoryUpdated,
    ValueChanged<String>? onCategoryDeleted,
  }) {
    return showDialog(
      context: context,
      builder: (dialogContext) => ChangeNotifierProvider.value(
        value: categoryProvider,
        child: ManageLabelsDialog(
          categoryProvider: categoryProvider,
          onCategoryUpdated: onCategoryUpdated,
          onCategoryDeleted: onCategoryDeleted,
        ),
      ),
    );
  }

  @override
  State<ManageLabelsDialog> createState() => _ManageLabelsDialogState();
}

class _ManageLabelsDialogState extends State<ManageLabelsDialog> {
  final TextEditingController _createController = TextEditingController();
  bool _isCreating = false;

  @override
  void dispose() {
    _createController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _createController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isCreating = true);
    final newCat = await widget.categoryProvider.addCategory(name);
    if (mounted) {
      setState(() => _isCreating = false);
      if (newCat != null) {
        _createController.clear();
      }
    }
  }

  Future<void> _confirmDelete(CategoryModel category) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Label?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'We’ll delete the label "${category.name}". Your notes won’t be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final success = await widget.categoryProvider.deleteCategory(category.id);
      if (success && widget.onCategoryDeleted != null) {
        widget.onCategoryDeleted!(category.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch CategoryProvider so this dialog rebuilds whenever a label is created, updated, or deleted
    final provider = context.watch<CategoryProvider>();
    final categories = provider.categories;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 520),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Edit Labels',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.black54),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Create New Label Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.add, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _createController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: const InputDecoration(
                          hintText: 'Create new label',
                          hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onSubmitted: (_) => _handleCreate(),
                      ),
                    ),
                    if (_isCreating)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.check, color: AppColors.primary),
                        tooltip: 'Create label',
                        onPressed: _handleCreate,
                      ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Label List
              Expanded(
                child: categories.isEmpty
                    ? const Center(
                        child: Text(
                          'No labels created yet',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: categories.length,
                        separatorBuilder: (_, _) => const Divider(height: 1, indent: 48),
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.label_outline, size: 20),
                            title: Text(
                              category.name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  tooltip: 'Rename',
                                  onPressed: () {
                                    EditLabelDialog.show(
                                      context,
                                      categoryProvider: widget.categoryProvider,
                                      category: category,
                                      onCategoryUpdated: widget.onCategoryUpdated,
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18),
                                  tooltip: 'Delete',
                                  onPressed: () => _confirmDelete(category),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
