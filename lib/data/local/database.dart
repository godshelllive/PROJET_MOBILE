import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  static Database? _db;

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'vestigo.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            phone TEXT,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL
          );
        ''');
      },
    );
  }

  static Database get db {
    final database = _db;
    if (database == null) {
      throw StateError('Database not initialized');
    }
    return database;
  }
}
