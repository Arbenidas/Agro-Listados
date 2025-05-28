import 'package:logitruck_app/model/user.dart';

import 'database_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseService _databaseService = DatabaseService();
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<bool> login(String email, String password) async {
    try {
      final hashedPassword = _hashPassword(password);

      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'users',
        where: 'email = ? AND password = ?',
        whereArgs: [email, hashedPassword],
      );

      if (maps.isNotEmpty) {
        _currentUser = User.fromMap(maps.first);
        return true;
      }

      return false;
    } catch (e) {
      print('Error during login: $e');
      return false;
    }
  }

  Future<bool> register(String email, String password, String name, String role) async {
    try {
      final user = User(
        email: email,
        password: password,
        name: name,
        role: role,
        createdAt: DateTime.now(),
      );

      await _databaseService.insertUser(user);
      return true;
    } catch (e) {
      print('Error en registro: $e');
      return false;
    }
  }

  void logout() {
    _currentUser = null;
  }

  // Método para verificar si un email ya existe
  Future<bool> emailExists(String email) async {
    try {
      final users = await _databaseService.getAllUsers();
      return users.any((user) => user.email.toLowerCase() == email.toLowerCase());
    } catch (e) {
      print('Error verificando email: $e');
      return false;
    }
  }

  // Método para obtener información del usuario actual
  String get currentUserName => _currentUser?.name ?? 'Usuario';
  String get currentUserRole => _currentUser?.role ?? 'unknown';
  int? get currentUserId => _currentUser?.id;
}
