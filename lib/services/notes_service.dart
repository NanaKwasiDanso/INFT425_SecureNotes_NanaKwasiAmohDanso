import 'dart:convert';
import '../models/note.dart';
import '../utils/encryption_helper.dart';
import 'secure_storage_service.dart';

class NotesService {
  List<Note> _notes = [];

  List<Note> get notes => _notes;

  Future<void> loadNotes() async {
    final encryptedJson = await SecureStorageService.loadNotes();
    if (encryptedJson == null) {
      _notes = [];
      return;
    }
    final decryptedJson = EncryptionHelper.decrypt(encryptedJson);
    final List<dynamic> decoded = jsonDecode(decryptedJson);
    _notes = decoded.map((item) => Note.fromJson(item)).toList();
  }

  Future<void> _saveNotes() async {
    final jsonString = jsonEncode(_notes.map((n) => n.toJson()).toList());
    final encrypted = EncryptionHelper.encrypt(jsonString);
    await SecureStorageService.saveNotes(encrypted);
  }

  Future<void> addNote(Note note) async {
    _notes.insert(0, note);
    await _saveNotes();
  }

  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _saveNotes();
    }
  }

  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }
}
