// Servei per fer crides a la API d'equips
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../shared/models/TeamModel.dart';

class TeamService {
  static final TeamService _instance = TeamService._internal();
  factory TeamService() => _instance;
  TeamService._internal();

  final String baseUrl = 'http://localhost:3000/api/v1';

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
}
