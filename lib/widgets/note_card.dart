import 'package:flutter/material.dart';
import '../models/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final List<Color> cardColors;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onLongPress,
    this.cardColors = const [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
  });

  @override
  Widget build(BuildContext context) {
    final contentPreview = note.content.isNotEmpty
        ? note.content.length > 75
              ? '${note.content.substring(0, 75)}...'
              : note.content
        : 'No content yet';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromRGBO(0, 0, 0, 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        title: Text(
          note.title.isNotEmpty ? note.title : 'Untitled note',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          contentPreview,
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: Chip(
          backgroundColor: Colors.white24,
          label: Text(
            _formatDate(note.lastEdited),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
