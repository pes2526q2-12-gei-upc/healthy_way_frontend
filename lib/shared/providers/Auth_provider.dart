import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserModel.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  // Para leer el usuario desde cualquier pantalla
  User? get currentUser => _currentUser;

  // Para saber si hay alguien logueado
  bool get isAuthenticated => _currentUser != null;

  // Se llama cuando el login es correcto
  Future<void> login(User user) async {
    _currentUser = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = jsonEncode(user.toJson());
    await prefs.setString('saved_user', userJsonString);
  }

  // Se llama al cerrar sesión
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
  }

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = prefs.getString('saved_user');

    if (userJsonString != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJsonString);
      _currentUser = User.fromJson(userMap);
      notifyListeners();
    }
  }
}