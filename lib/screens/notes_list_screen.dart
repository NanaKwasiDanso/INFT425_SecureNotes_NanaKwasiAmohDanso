import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';
import '../widgets/note_card.dart';
import 'add_edit_note_screen.dart';

enum BackgroundStyle { sunrise, ocean, forest }

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  bool _isLoading = true;
  BackgroundStyle _backgroundStyle = BackgroundStyle.sunrise;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    await _notesService.loadNotes();
    setState(() => _isLoading = false);
  }

  LinearGradient _backgroundGradient() {
    switch (_backgroundStyle) {
      case BackgroundStyle.ocean:
        return const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF2C5364), Color(0xFF0F9B8E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case BackgroundStyle.forest:
        return const LinearGradient(
          colors: [Color(0xFF1E3C34), Color(0xFF2C786C), Color(0xFF7AD0B0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
      case BackgroundStyle.sunrise:
        return const LinearGradient(
          colors: [Color(0xFFFF8A65), Color(0xFFFFD54F), Color(0xFFFF5252)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        );
    }
  }

  List<Color> _cardColors() {
    switch (_backgroundStyle) {
      case BackgroundStyle.ocean:
        return const [Color(0xFF0D4F5C), Color(0xFF107A81)];
      case BackgroundStyle.forest:
        return const [Color(0xFF2F5D4F), Color(0xFF74C69D)];
      case BackgroundStyle.sunrise:
        return const [Color(0xFF8E24AA), Color(0xFFFF7043)];
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = _backgroundGradient();
    final cardColors = _cardColors();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Notes'),
        actions: [
          PopupMenuButton<BackgroundStyle>(
            onSelected: (style) => setState(() => _backgroundStyle = style),
            icon: const Icon(Icons.palette),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: BackgroundStyle.sunrise,
                child: Text('Sunrise theme'),
              ),
              const PopupMenuItem(
                value: BackgroundStyle.ocean,
                child: Text('Ocean theme'),
              ),
              const PopupMenuItem(
                value: BackgroundStyle.forest,
                child: Text('Forest theme'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: background),
        child: Stack(
          children: [
            Positioned(
              right: -70,
              top: -80,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.10),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              left: -40,
              bottom: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 20,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Notes',
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Tap a note to edit, or long press to delete.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 255, 255, 0.16),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            _backgroundStyle.name.toUpperCase(),
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _notesService.notes.isEmpty
                        ? Center(
                            child: Text(
                              'No notes yet. Tap + to add one!',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            itemCount: _notesService.notes.length,
                            itemBuilder: (context, index) {
                              final note = _notesService.notes[index];
                              return NoteCard(
                                note: note,
                                cardColors: cardColors,
                                onTap: () => _editNote(note),
                                onLongPress: () => _deleteNote(note.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Colors.white,
        child: const Icon(Icons.add, color: Colors.deepPurple),
      ),
    );
  }

  void _addNote() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen()),
    );
    if (result == true) {
      setState(() {}); // refresh list (or use provider)
    }
  }

  void _editNote(Note note) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)),
    );
    if (result == true) {
      setState(() {});
    }
  }

  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _notesService.deleteNote(id);
      setState(() {});
    }
  }
}
