import 'package:flutter/material.dart';
import '../../providers/note_editor_provider.dart';

class AttachmentBottomSheet {
  static void show(BuildContext context, NoteEditorProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.check_box_outlined),
                title: Text(provider.isChecklistMode ? 'Hide tick boxes' : 'Tick boxes'),
                onTap: () {
                  Navigator.pop(context);
                  provider.toggleChecklistMode();
                },
              ),
              ListTile(
                leading: const Icon(Icons.image_outlined),
                title: const Text('Add image'),
                onTap: () {
                  Navigator.pop(context);
                  provider.pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
