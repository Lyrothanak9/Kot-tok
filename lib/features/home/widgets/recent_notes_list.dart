import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Navigation/provider/bottom_app_bar_provider.dart';
import '../providers/home_provider.dart';
import '../screens/note_editor_screen.dart';
import 'note_card.dart';

class RecentNotesList extends StatelessWidget {
  const RecentNotesList({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HomeProvider>();
    final isGridView = context.watch<BottomAppBarProvider>().isGridView;

    if (provider.isLoading) {
      return const SizedBox.shrink();
    }

    if (provider.recentNotes.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "No recent notes found. Create your first note!",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'OTHERS',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        if (isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: provider.recentNotes.length,
            itemBuilder: (context, index) {
              final note = provider.recentNotes[index];
              return RecentNoteCard(
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
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.recentNotes.length,
            itemBuilder: (context, index) {
              final note = provider.recentNotes[index];
              return RecentNoteCard(
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
      ],
    );
  }
}