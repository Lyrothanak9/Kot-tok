import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../screens/note_editor_screen.dart';
import 'note_card.dart';

class PinnedNotesList extends StatelessWidget {
  const PinnedNotesList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();

    if (provider.isLoading || provider.pinnedNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PINNED',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: provider.pinnedNotes.length,
          itemBuilder: (context, index) {
            final note = provider.pinnedNotes[index];
            return PinnedNoteCard(
              note: note,
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NoteEditorScreen(note: note),
                  ),
                );
                if (context.mounted) {
                  context.read<HomeProvider>().refresh();
                }
              },
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}