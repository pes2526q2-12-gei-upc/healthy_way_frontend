// Servei per fer crides a la API d'equips
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/models/TeamModel.dart';

class TeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  final String baseUrl = 'http://localhost:8080/api/v1';

  /// Obté la informació d'un equip pel seu nom/id
  /// GET /api/v1/teams/{id}
  Future<TeamModel?> getTeamByName(String teamName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamName)}'),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TeamModel.fromJson(json);
    } else {
      print('Error al obtenir equip: ${response.statusCode}');
      print('Missatge: ${response.body}');
      return null;
    }
  }

  /// Crea un nou equip
  /// POST /api/v1/teams
  Future<TeamModel?> createTeam(TeamModel team) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(team.toJson()),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return TeamModel.fromJson(json);
    } else {
      print('Error al crear equip: ${response.statusCode}');
      print('Missatge: ${response.body}');
      return null;
    }
  }

  /// Unir-se a un equip existent
  /// POST /api/v1/teams/{id}/join
  Future<bool> joinTeam(String teamId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamId)}/join'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Error en unir-se a l\'equip: ${response.statusCode}');
      print('Missatge: ${response.body}');
      return false;
    }
  }

  /// Sol·licitar unir-se a un equip privat mitjançant un codi
  /// POST /api/v1/teams/join-private
  Future<bool> requestJoinPrivateTeam(String code) async {
    // ⚠️ Endpoint no implementat realment al backend encara
    final response = await http.post(
      Uri.parse('$baseUrl/teams/join-private'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code}),
    );

    // Mock response for now
    if (response.statusCode == 200 || true) { // Forced true for mock
      return true;
    } else {
      print('Error al sol·licitar unir-se: ${response.statusCode}');
      return false;
    }
  }

  /// Obtenir les sol·licituds d'unió a l'equip
  /// GET /api/v1/teams/{id}/requests
  Future<List<Map<String, dynamic>>> getJoinRequests(String teamId) async {
    // ⚠️ Endpoint no implementat realment al backend encara
    /*
    final response = await http.get(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamId)}/requests'),
    );
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    }
    */
    
    // Retornem dades simulades
    await Future.delayed(const Duration(seconds: 1));
    return [
      {'userId': 'u1', 'userName': 'Marc Riera', 'requestDate': 'Avui, 10:30'},
      {'userId': 'u2', 'userName': 'Laura Gómez', 'requestDate': 'Ahir, 18:45'},
    ];
  }

  /// Acceptar una sol·licitud d'unió
  /// POST /api/v1/teams/{id}/requests/{userId}/accept
  Future<bool> acceptJoinRequest(String teamId, String userId) async {
    // ⚠️ Endpoint no implementat realment al backend encara
    /*
    final response = await http.post(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamId)}/requests/${Uri.encodeComponent(userId)}/accept'),
    );
    return response.statusCode == 200;
    */
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock success
  }

  /// Denegar una sol·licitud d'unió
  /// POST /api/v1/teams/{id}/requests/{userId}/deny
  Future<bool> denyJoinRequest(String teamId, String userId) async {
    // ⚠️ Endpoint no implementat realment al backend encara
    /*
    final response = await http.post(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamId)}/requests/${Uri.encodeComponent(userId)}/deny'),
    );
    return response.statusCode == 200;
    */
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // Mock success
  }
}
