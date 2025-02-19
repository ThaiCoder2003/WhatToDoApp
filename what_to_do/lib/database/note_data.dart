import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Note {
    int? id;
    String title;
    String description;
    DateTime date;
    String category;
    Bool isDone;

    Note({
        this.id,
        required this.title,
        required this.description,
        required this.date,
    });

    Map<String, dynamic> toMap() {
        return {
            'id': id,
            'title': title,
            'description': description,
            'date': date.toIso8601String(),
        };
    }

    factory Note.fromMap(Map<String, dynamic> map) {
        return Note(
            id: map['id'],
            title: map['title'],
            description: map['description'],
            date: DateTime.parse(map['date']),
            category: map['category'],
            isDone: map['isDone'],
        );
    }
}

class NoteDatabase {
    static final NoteDatabase instance = NoteDatabase._init();
    static Database? _database;

    NoteDatabase._init();

    Future<Database> get database async {
        if (_database != null) return _database!;
        _database = await _initDB('notes.db');
        return _database!;
    }

    Future<Database> _initDB(String filePath) async {
        final dbPath = await getDatabasesPath();
        final path = join(dbPath, filePath);

        return await openDatabase(
            path,
            version: 1,
            onCreate: _createDB,
        );
    }

    Future _createDB(Database db, int version) async {
        await db.execute('''
        CREATE TABLE notes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            date TEXT NOT NULL
            category TEXT NOT NULL
            isDone BOOL NOT NULL
        )
        ''');
    }

    Future<Note> create(Note note) async {
        final db = await instance.database;
        final id = await db.insert('notes', note.toMap());
        return note.copy(id: id);
    }

    Future<Note?> read(int id) async {
        final db = await instance.database;

        final maps = await db.query(
            'notes',
            columns: ['id', 'title', 'description', 'date', 'category', 'isDone'],
            where: 'id = ?',
            whereArgs: [id],
        );

        if (maps.isNotEmpty) {
            return Note.fromMap(maps.first);
        } else {
            return null;
        }
    }

    Future<List<Note>> readAll() async {
        final db = await instance.database;

        final result = await db.query('notes');

        return result.map((map) => Note.fromMap(map)).toList();
    }

    Future<int> update(Note note) async {
        final db = await instance.database;

        return db.update(
            'notes',
            note.toMap(),
            where: 'id = ?',
            whereArgs: [note.id],
        );
    }

    Future<int> delete(int id) async {
        final db = await instance.database;

        return await db.delete(
            'notes',
            where: 'id = ?',
            whereArgs: [id],
        );
    }

    Future close() async {
        final db = await instance.database;

        db.close();
    }
}