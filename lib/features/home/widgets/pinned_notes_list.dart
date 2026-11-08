import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../screens/note_editor_screen.dart';

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
            return InkWell(
              borderRadius: BorderRadius.circular(12),
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
              child: _buildKeepStyleCard(
                title: note.title,
                content: note.content ?? '',
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKeepStyleCard({required String title, required String content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.push_pin, size: 16, ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content.isEmpty ? 'Empty note' : content,
            style: TextStyle(
              fontSize: 14,
              color: content.isEmpty ? Colors.grey : Colors.black87,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}