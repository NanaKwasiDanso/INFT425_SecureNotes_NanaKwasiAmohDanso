import 'package:flutter/material.dart';
import '../models/note.dart';
import '../services/notes_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note; // null for new note, existing note for editing

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _notesService = NotesService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // If editing an existing note, populate the fields
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title or content')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (widget.note == null) {
        // Creating a new note
        final newNote = Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          content: content,
          lastEdited: DateTime.now(),
        );
        await _notesService.addNote(newNote);
      } else {
        // Updating existing note
        final updatedNote = Note(
          id: widget.note!.id,
          title: title,
          content: content,
          lastEdited: DateTime.now(),
        );
        await _notesService.updateNote(updatedNote);
      }

      if (mounted) {
        Navigator.of(
          context,
        ).pop(true); // Return true so the notes list refreshes
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving note: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Save Note',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Title Text Field
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title...',
                border: OutlineInputBorder(),
              ),
              maxLines: 1,
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 16),

            // Content Text Field
            Expanded(
              child: TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  hintText: 'Enter note content...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: null, // Allows unlimited lines
                expands: true, // Takes all available space
                textCapitalization: TextCapitalization.sentences,
                enabled: !_isLoading,
              ),
            ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveNote,
                  child: Text(isEditing ? 'Update' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
