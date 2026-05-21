import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../shared/models/ranking_models.dart';
import 'token_service.dart';

class RankingService {
  final http.Client client;
  static final RankingService _instance = RankingService._internal();
  factory RankingService({http.Client? client}) {
    if (client != null) {
      return RankingService._internal(client: client);
    }
    return _instance;
  }
  RankingService._internal({http.Client? client}) : client = client ?? http.Client();

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  Future<List<dynamic>> getIndividualRanking(String orderedBy, String modality, String scope) async {
    String URI = orderedBy == 'points' ? '$baseUrl/users/ranked/points' : '$baseUrl/users/ranked/distance';

    // modality = running o cycling
    // scope = current o total
    var uri = Uri.parse(URI).replace(queryParameters: {
      'modality': modality,
      'scope': scope,
    });

    try {
      final response = await client.get(
        uri,
        headers: {
          'Authorization': 'Bearer ${await SecureStorageService().getToken()}'
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonRanking = jsonDecode(response.body);
        return jsonRanking.map((json) => IndividualRanking.fromJson(json)).toList();
      }
      else {
        debugPrint('Error al obtener ranking individual: ${response.statusCode}');
        return [];
      }
    }
    catch (e) {
      debugPrint('Error de conexión en ranking individual: $e');
      return [];
    }
  }

  Future<List<TeamRanking>> getTeamRanking(String modality, String zona, String orderBy) async {

    var uri = Uri.parse('$baseUrl/teams/ranking/$modality');

    if (zona != 'All') {
      uri = uri.replace(queryParameters: {
        'zone': zona, 'rankingBy': orderBy,
      });
    }

    try {
      final response = await client.get(
        uri,
        headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonRanking = jsonDecode(response.body);
        return jsonRanking.map((json) => TeamRanking.fromJson(json)).toList();
      } else {
        debugPrint('Error al obtener ranking de equipos: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error de conexión en ranking de equipos: $e');
      return [];
    }
  }
}