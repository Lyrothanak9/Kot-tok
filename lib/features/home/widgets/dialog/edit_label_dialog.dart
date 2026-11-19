import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class EditLabelDialog extends StatefulWidget {
  final CategoryProvider categoryProvider;
  final CategoryModel category; // Passes the existing category to edit
  final ValueChanged<CategoryModel>? onCategoryUpdated;

  const EditLabelDialog({
    super.key,
    required this.categoryProvider,
    required this.category,
    this.onCategoryUpdated,
  });

  static Future<CategoryModel?> show(
      BuildContext context, {
        required CategoryProvider categoryProvider,
        required CategoryModel category,
        ValueChanged<CategoryModel>? onCategoryUpdated,
      }) {
    return showDialog<CategoryModel>(
      context: context,
      builder: (dialogContext) => EditLabelDialog(
        categoryProvider: categoryProvider,
        category: category,
        onCategoryUpdated: onCategoryUpdated,
      ),
    );
  }

  @override
  State<EditLabelDialog> createState() => _EditLabelDialogState();
}

class _EditLabelDialogState extends State<EditLabelDialog> {
  late final TextEditingController _labelController;

  @override
  void initState() {
    super.initState();
    // Pre-fill the text field with the current category name
    _labelController = TextEditingController(text: widget.category.name);
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    final newName = _labelController.text.trim();

    // If the name is empty or hasn't changed, just close the dialog without saving
    if (newName.isEmpty || newName == widget.category.name) {
      Navigator.pop(context);
      return;
    }

    Navigator.pop(context); // Close dialog immediately for a snappy UI

    // Calls the update method on your provider
    final updatedCategory = await widget.categoryProvider.updateCategory(widget.category.id, newName);

    if (updatedCategory != null && widget.onCategoryUpdated != null) {
      widget.onCategoryUpdated!(updatedCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Edit Label',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: TextField(
        controller: _labelController,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        decoration: const InputDecoration(
          hintText: 'Enter label name',
          hintStyle: TextStyle(color: Colors.grey),
          filled: false,
          border: UnderlineInputBorder(),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
        ),
        onSubmitted: (_) => _handleUpdate(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: _handleUpdate,
          child: const Text('Save'),
        ),
      ],
    );
  }
}