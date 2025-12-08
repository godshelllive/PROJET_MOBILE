import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite/sqflite.dart';
import 'package:code_initial/data/local/database.dart';

class UserRepository {
  Database get _db => AppDatabase.db;

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<int> signUp({
    required String firstName,
    required String lastName,
    String? phone,
    required String email,
    required String password,
  }) async {
    final id = await _db.insert('users', {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password_hash': _hashPassword(password),
    }, conflictAlgorithm: ConflictAlgorithm.abort);
    return id;
  }

  Future<Map<String, Object?>?> login({
    required String email,
    required String password,
  }) async {
    final hashed = _hashPassword(password);
    final rows = await _db.query(
      'users',
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email, hashed],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }
}
