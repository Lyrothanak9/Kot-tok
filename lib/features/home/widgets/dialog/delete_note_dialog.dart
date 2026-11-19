import 'package:flutter/material.dart';
import '../../../../app/theme/app_colors.dart';
import '../../providers/note_editor_provider.dart';

class DeleteNoteDialog extends StatelessWidget {
  final NoteEditorProvider provider;

  const DeleteNoteDialog({
    super.key,
    required this.provider,
  });

  static Future<void> show(BuildContext context, NoteEditorProvider provider) {
    return showDialog(
      context: context,
      builder: (dialogContext) => DeleteNoteDialog(provider: provider),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteTitle = provider.titleController.text.trim().isEmpty
        ? 'Untitled'
        : provider.titleController.text.trim();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text(
        'Delete Note?',
        textAlign: TextAlign.center,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Text(
        'This action cannot be undone. The note "$noteTitle" will be permanently deleted.',
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.black54),
      ),
      actions: [
        Column(
          children: [
            // Cancel Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Delete Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () async {
                  // 1. Capture the Navigator and Messenger instances BEFORE popping the dialog
                  final navigator = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);

                  // 2. Close the dialog immediately for a snappy UI
                  navigator.pop();

                  // 3. Perform the delete operation
                  final success = await provider.deleteNote();

                  // 4. Use the captured instances to handle UI updates safely
                  if (!success && provider.errorMessage != null) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(provider.errorMessage!),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  } else if (success) {
                    // Close the NoteEditorScreen to return to Home
                    if (navigator.canPop()) {
                      navigator.pop();
                    }
                  }
                },
                child: const Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}