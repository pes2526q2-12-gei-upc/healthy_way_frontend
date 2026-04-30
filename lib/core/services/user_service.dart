import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

import '../../shared/models/activity.dart';
import '../../shared/models/user_model.dart';
import '../../shared/providers/auth_provider.dart';
import 'token_service.dart';

class UserService {

  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

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
      debugPrint('Error al crear usuario: ${response.statusCode}');
      debugPrint('Mensaje: ${response.body}');
      return false;
    }

    else if (response.statusCode == 201) {
      final responseBody = json.decode(response.body);
      final token = responseBody['authToken'];
      await SecureStorageService().saveToken(token);
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
      final token = responseBody['authToken'];
      await SecureStorageService().saveToken(token);
      final loggedUser = User.fromJson(responseBody['user']);
      return loggedUser;
    }
    else {
      debugPrint('Error al iniciar sesión: ${response.statusCode}');
      debugPrint('Mensaje: ${response.body}');
      return null;
    }
  }

  Future<User?> getUserProfile(int userId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'});

    if (response.statusCode == 200) {
      final userJson = json.decode(response.body);
      return User.fromJson(userJson);
    } else {
      debugPrint('Error al obtener perfil del usuario: ${response.statusCode}');
      return null;
    }
  }

  Future<List<Activity>> getUserActivities(int userId) async {
    final response = await http.get(
        Uri.parse('$baseUrl/users/$userId/activities'),
        headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'});

    if (response.statusCode == 200) {
      final List<dynamic> activitiesJson = json.decode(response.body);
      return activitiesJson.map((json) => Activity.fromJson(json)).toList();
    } else {
      debugPrint('Error al obtener actividades del usuario: ${response.statusCode}');
      return [];
    }
  }

  //Trucada a Strava per importar les rutes de l'usuari
  Future<String> importStravaRoutes(int userId) async {
    final url = Uri.https('www.strava.com', '/oauth/mobile/authorize', {
      'client_id': '209168',
      'redirect_uri': 'http://localhost:55342/auth.html',
      'response_type': 'code',
      'scope': 'activity:read,activity:read_all',
    });

    final result = await FlutterWebAuth2.authenticate(
      url: url.toString(),
      callbackUrlScheme: "http",
    );

    print('Resultat de l\'autenticació amb Strava: $result');

    final scope = Uri.parse(result).queryParameters['scope'] ?? '';
    if (!scope.contains('activity:read') || !scope.contains('activity:read_all')) {
      return 'Error: No se han otorgat els permissos necessaris per importar les rutas de Strava.';
    }

    final code = Uri
        .parse(result)
        .queryParameters['code'];

    if (code != null) {
      final newResponse = await http.post(
        Uri.parse('$baseUrl/import/strava'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
        body: json.encode({
          'code': code,
          'user_id': userId,
        }),
      );
      if(newResponse.statusCode == 200) {
        return 'Rutes importades correctament des de Strava.';
      }
      else {
        return 'Error al importar les rutes de Strava: ${newResponse.statusCode}';
      }
    }
    else {
      return 'Error: Problema amb Strava.';
    }
  }

  Future<bool> eliminarUsuari(int userId) async {
    final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'}
    );

    if (response.statusCode == 200) {
      debugPrint('Usuari eliminat correctament');
      return true;
    }
    else if (response.statusCode == 404) {
      debugPrint('Usuari no trobat');
    }
    else {
      debugPrint('Error al eliminar usuari: ${response.statusCode}');
    }
    return false;
  }
}