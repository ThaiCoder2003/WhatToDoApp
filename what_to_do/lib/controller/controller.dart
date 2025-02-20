import 'package:what_to_do/database/node_data.dart';
import 'package:flutter/material.dart';

class NoteController extends ChangeNotifier {
  final NoteDatabase _database = NoteDatabase.instance;

  List<Note> _todos = [];

  List<Note> get todos => _todos;

  Future<void> fetchToDos() async {
     _todos = await _database.readAll();
     notifyListeners();
  }

  Future<void> createToDo(Note note) async {
    await _database.create(note);
    await fetchToDos();
  }

  Future<void> updateToDo(Note note) async {
    await _database.update(note);
    await fetchToDos();
  }

  Future<void> deleteToDo(Note note) async {
    await _database.delete(note.id!);
    await fetchToDos();
  }

  Future<void> searchToDos(String query) async {
    final allNotes = await _database.readAll();
    _todos = allNotes.where((note) {
      return note.title.contains(query) || note.description.contains(query);
    }).toList();
    notifyListeners();
  }
}