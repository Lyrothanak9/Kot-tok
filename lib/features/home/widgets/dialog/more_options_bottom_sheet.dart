import 'package:flutter/material.dart';
import '../../providers/note_editor_provider.dart';
import 'delete_note_dialog.dart';

class MoreOptionsBottomSheet {
  static void show(BuildContext context, NoteEditorProvider provider) {
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
                  DeleteNoteDialog.show(context, provider);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
