import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';

import '../../shared/models/UserModel.dart';
import '../../shared/providers/Auth_provider.dart';

class UserService {

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String baseUrl = 'http://localhost:3000/api/v1';

  Future<bool> crearUsuari(String name, String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nom': name,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 201) {
      print('Error al crear usuario: ${response.statusCode}');
      print('Mensaje: ${response.body}');
      return false;
    }

    return true;
  }

  Future<User?> login(String identifier, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': identifier,
        'password': password,
      }),
    );
    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final loggedUser = User.fromJson(responseBody['user']);
      return loggedUser;
    }
    else {
      print('Error al iniciar sesión: ${response.statusCode}');
      print('Mensaje: ${response.body}');
      return null;
    }
  }
}