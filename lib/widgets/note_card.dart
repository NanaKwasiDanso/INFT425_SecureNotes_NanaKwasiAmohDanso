import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final contentPreview = note.content.isNotEmpty
        ? note.content.length > 75
              ? '${note.content.substring(0, 75)}...'
              : note.content
        : 'No content yet';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        title: Text(note.title.isNotEmpty ? note.title : 'Untitled note'),
        subtitle: Text(contentPreview),
        trailing: Text(_formatDate(note.lastEdited)),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
