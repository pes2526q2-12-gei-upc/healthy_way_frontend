import 'package:flutter/foundation.dart';
// Servei per fer crides a la API d'equips
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/models/team_model.dart';
import 'token_service.dart';

class TeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  /// Obté la informació d'un equip pel seu nom/id
  /// GET /api/v1/teams/{id}
  Future<TeamModel?> getTeamByName(String teamName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamName)}'),
      headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return TeamModel.fromJson(json);
    } else {
      debugPrint('Error al obtenir equip: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return null;
    }
  }

  /// Crea un nou equip
  /// POST /api/v1/teams
  Future<TeamModel?> createTeam(TeamModel team) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
      body: jsonEncode(team.toJson()),
    );

    if (response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return TeamModel.fromJson(json);
    } else {
      debugPrint('Error al crear equip: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return null;
    }
  }

  /// Unir-se a un equip existent
  /// POST /api/v1/teams/{id}/join
  Future<bool> joinTeam(String teamId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamId)}/join'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint('Error en unir-se a l\'equip: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return false;
    }
  }

  /// Sol·licitar unir-se a un equip privat pel seu nom
  /// POST /api/v1/teams/{teamName}/requests
  Future<bool> requestJoinPrivateTeam(String teamName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamName)}/requests'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      debugPrint('Error al sol·licitar unir-se: ${response.statusCode}');
      return false; 
    }
  }

  /// Obtenir les sol·licituds d'unió a l'equip
  /// GET /api/v1/teams/{id}/requests
  Future<List<Map<String, dynamic>>> getJoinRequests(String teamName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamName)}/requests'),
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => e as Map<String, dynamic>).toList();
    } else {
      debugPrint('Error al obtenir sol·licituds: ${response.statusCode}');
      return [];
    }
  }

  /// Acceptar una sol·licitud d'unió
  /// POST /api/v1/teams/{id}/requests/{userId}/accept
  Future<bool> acceptJoinRequest(String teamName, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamName)}/requests/${Uri.encodeComponent(userId)}/accept'),
    );
    return response.statusCode == 200 || response.statusCode == 201;
  }

  /// Denegar una sol·licitud d'unió (de moment s'elimina de forma temporal, no fa trucada a l'API)
  Future<bool> denyJoinRequest(String teamName, String userId) async {
    // ⚠️ Endpoint no implementat realment al backend encara
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // Retorna true per eliminar de la llista localment
  }

  /// Obtenir tots els equips públics
  /// GET /api/v1/teams
  Future<List<TeamModel>> getAllTeams() async {
    final response = await http.get(
      Uri.parse('$baseUrl/teams'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => TeamModel.fromJson(json)).toList();
    } else {
      debugPrint('Error al obtenir equips públics: ${response.statusCode}');
      return [];
    }
  }

  /// Actualitzar un equip existent
  /// PUT /api/v1/teams/{name}
  Future<TeamModel?> updateTeam(String teamName, TeamModel team) async {
    final response = await http.put(
      Uri.parse('$baseUrl/teams/${Uri.encodeComponent(teamName)}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(team.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      // 204 typically means success but no body, if 200 we might get the team back.
      if (response.body.isNotEmpty) {
        return TeamModel.fromJson(jsonDecode(response.body));
      }
      return team;
    } else {
      debugPrint('Error al actualitzar equip: ${response.statusCode}');
      debugPrint('Missatge: ${response.body}');
      return null;
    }
  }
}
