import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  static Database? _db;

  static Future<void> init() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, 'vestigo.db');
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            first_name TEXT NOT NULL,
            last_name TEXT NOT NULL,
            phone TEXT,
            email TEXT NOT NULL UNIQUE,
            password_hash TEXT NOT NULL,
            created_at TEXT DEFAULT (datetime('now'))
          );
        ''');
        await db.execute('''
          CREATE TABLE favorites (
            product_id TEXT PRIMARY KEY
          );
        ''');
        await db.execute('''
          CREATE TABLE cart (
            product_id TEXT PRIMARY KEY,
            quantity INTEGER NOT NULL
          );
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS favorites (
              product_id TEXT PRIMARY KEY
            );
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS cart (
              product_id TEXT PRIMARY KEY,
              quantity INTEGER NOT NULL
            );
          ''');
        }
        if (oldVersion < 3) {
          try {
            await db.execute("ALTER TABLE users ADD COLUMN created_at TEXT");
          } catch (_) {}
        }
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
