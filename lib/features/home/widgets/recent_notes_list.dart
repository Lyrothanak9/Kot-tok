import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Navigation/provider/bottom_app_bar_provider.dart';
import '../models/note_model.dart';
import '../providers/home_provider.dart';
import '../screens/note_editor_screen.dart';

class RecentNotesList extends StatelessWidget {
  const RecentNotesList({super.key});

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

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
              return _buildNoteItem(context, note);
            },
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.recentNotes.length,
            itemBuilder: (context, index) {
              final note = provider.recentNotes[index];
              return _buildNoteItem(context, note);
            },
          ),
      ],
    );
  }

  Widget _buildNoteItem(BuildContext context, NoteModel note) {
    final displayDate = note.updatedAt ?? note.createdAt;
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
      child: _buildListCard(
        title: note.title,
        content: note.content ?? '',
        date: _formatDate(displayDate),
        imageUrls: note.imageUrls,
      ),
    );
  }

  Widget _buildListCard({
    required String title,
    required String content,
    required String date,
    List<String> imageUrls = const [],
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrls.isNotEmpty)
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(imageUrls.first),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? 'Untitled' : title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  content.isEmpty ? 'Empty note' : content,
                  style: TextStyle(
                    fontSize: 14,
                    color: content.isEmpty ? Colors.grey : Colors.black54,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated: $date',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}