import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../providers/category_provider.dart';

class CreateLabelDialog extends StatefulWidget {
  final CategoryProvider categoryProvider;
  final ValueChanged<CategoryModel>? onCategoryCreated;

  const CreateLabelDialog({
    super.key,
    required this.categoryProvider,
    this.onCategoryCreated,
  });

  static Future<CategoryModel?> show(
    BuildContext context, {
    required CategoryProvider categoryProvider,
    ValueChanged<CategoryModel>? onCategoryCreated,
  }) {
    return showDialog<CategoryModel>(
      context: context,
      builder: (dialogContext) => CreateLabelDialog(
        categoryProvider: categoryProvider,
        onCategoryCreated: onCategoryCreated,
      ),
    );
  }

  @override
  State<CreateLabelDialog> createState() => _CreateLabelDialogState();
}

class _CreateLabelDialogState extends State<CreateLabelDialog> {
  final TextEditingController _labelController = TextEditingController();

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final name = _labelController.text.trim();
    if (name.isEmpty) return;

    Navigator.pop(context); // Close dialog

    final newCategory = await widget.categoryProvider.addCategory(name);
    if (newCategory != null && widget.onCategoryCreated != null) {
      widget.onCategoryCreated!(newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Create New Label',
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
        onSubmitted: (_) => _handleCreate(),
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
          onPressed: _handleCreate,
          child: const Text('Create'),
        ),
      ],
    );
  }
}
