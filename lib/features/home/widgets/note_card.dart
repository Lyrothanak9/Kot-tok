import 'package:flutter/material.dart';
import '../models/note_model.dart';

class RecentNoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const RecentNoteCard({super.key, required this.note, required this.onTap});

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    final displayDate = note.updatedAt ?? note.createdAt;
    final title = note.title;
    final content = note.content ?? '';
    final imageUrls = note.imageUrls;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
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
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content.isEmpty ? 'Empty note' : content,
                    style: TextStyle(
                      fontSize: 14,
                      color: content.isEmpty ? theme.colorScheme.onSurface.withOpacity(0.4) : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Updated: ${_formatDate(displayDate)}',
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PinnedNoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const PinnedNoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final title = note.title;
    final content = note.content ?? '';
    final imageUrls = note.imageUrls;
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrls.isNotEmpty)
              Container(
                height: 70,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(imageUrls.first),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title.isEmpty ? 'Untitled' : title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold, 
                            fontSize: 15,
                            color: theme.colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.push_pin, size: 16, color: theme.colorScheme.onSurface),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content.isEmpty ? 'Empty note' : content,
                    style: TextStyle(
                      fontSize: 13,
                      color: content.isEmpty ? theme.colorScheme.onSurface.withOpacity(0.4) : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: imageUrls.isNotEmpty ? 2 : 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
