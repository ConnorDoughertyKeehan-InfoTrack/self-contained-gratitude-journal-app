import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final Completer<void> _dbReady = Completer<void>();

  DatabaseHelper._init() {
    _initialize();
  }

  void _initialize() async {
    _database = await _initDB('gratitude_journal.db');
    _dbReady.complete(); // Mark as ready when finished
  }

  Future<void> waitForDbReady() => _dbReady.future;

  Future<Database> get database async {
    if (_database != null) return _database!;
    await waitForDbReady(); // Wait for DB if it's not ready yet
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE journal_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date_created TEXT NOT NULL,
        last_date_shown TEXT NULL,
        body_text TEXT NOT NULL
      )
    ''');
  }
}
