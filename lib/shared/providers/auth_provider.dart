import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../core/services/token_service.dart';
import '../../core/services/user_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser;

  // Para leer el usuario desde cualquier pantalla
  User? get currentUser => _currentUser;

  // Para saber si hay alguien logueado
  bool get isAuthenticated => _currentUser != null;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '845230063372-i1g1bf9o8jr62idmnekgtsa1n34d0o4d.apps.googleusercontent.com',
  );

  // Se llama cuando el login es correcto
  Future<void> login(User user) async {
    _currentUser = user;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final userJsonString = jsonEncode(user.toJson());
    await prefs.setString('saved_user', userJsonString);
    await prefs.setString('login_timestamp', DateTime.now().toIso8601String());
  }

  Future<bool> enterWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return false;
      }
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? tokenParaElBackend = googleAuth.idToken;
      if (tokenParaElBackend != null) {
        debugPrint("¡Token obtenido con éxito! Enviando al backend...");
        final User? user = await UserService().enterWithGoogle(tokenParaElBackend);
        if (user != null) {
          await login(user);
          return true;
        }
        else {
          debugPrint("Error: El backend no devolvió un usuario válido.");
        }
      }
      else {
        debugPrint("Error: No se pudo obtener el idToken de Google.");
      }
    }
    catch (error) {
      debugPrint("Error durante el Google Sign-In: $error");
    }
    return false;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_user');
    await prefs.remove('login_timestamp');
    _currentUser = null;
    SecureStorageService().deleteToken();
    notifyListeners();
  }

  Future<void> loadSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final loginTimestamp = prefs.getString('login_timestamp');
    if (loginTimestamp != null) {
      final loginDate = DateTime.parse(loginTimestamp);
      final daysSinceLogin = DateTime.now().difference(loginDate).inDays;

      if (daysSinceLogin >= 30) {
        await logout();
        return;
      }
    }

    final userJsonString = prefs.getString('saved_user');
    if (userJsonString != null) {
      final Map<String, dynamic> userMap = jsonDecode(userJsonString);
      _currentUser = User.fromJson(userMap);
      notifyListeners();
    }
  }

  Future<void> updateTeam(String? teamName) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(team: teamName);
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final userJsonString = jsonEncode(_currentUser!.toJson());
      await prefs.setString('saved_user', userJsonString);
    }
  }
}