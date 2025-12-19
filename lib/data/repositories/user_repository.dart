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
    final exists = await _db.rawQuery(
      'SELECT COUNT(*) as c FROM users WHERE email = ?',
      [email],
    );
    final count = (exists.first['c'] as int?) ?? 0;
    if (count > 0) {
      throw Exception('Email déjà utilisé');
    }
    final id = await _db.insert('users', {
      'first_name': firstName,
      'last_name': lastName,
      'phone': phone,
      'email': email,
      'password_hash': _hashPassword(password),
      'created_at': DateTime.now().toIso8601String(),
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

  Future<Map<String, Object?>?> getByEmail(String email) async {
    final rows = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  Future<int> updateByEmail({
    required String email,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final data = <String, Object?>{};
    if (firstName != null) data['first_name'] = firstName;
    if (lastName != null) data['last_name'] = lastName;
    if (phone != null) data['phone'] = phone;
    if (data.isEmpty) return 0;
    return _db.update('users', data, where: 'email = ?', whereArgs: [email]);
  }
}
