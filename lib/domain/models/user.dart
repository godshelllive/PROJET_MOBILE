import 'package:flutter/material.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String avatar;
  final bool isOnline;
  final String lastSeen;
  final Color? avatarColor;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.avatar,
    this.isOnline = false,
    required this.lastSeen,
    this.avatarColor,
  });
}
