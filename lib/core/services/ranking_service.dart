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

  Future<List<dynamic>> getIndividualRanking(String orderedBy) async {
    String URI = orderedBy == 'points' ? '$baseUrl/users/ranked/points' : '$baseUrl/users/ranked/distance';
    final response = await client.get(
      Uri.parse(URI),
      headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonRanking = jsonDecode(response.body);
      final List<IndividualRanking> ranking = jsonRanking.map((json) => IndividualRanking.fromJson(json)).toList();
      return ranking;
    }
    else {
      debugPrint('Error al obtener ranking individual: ${response.statusCode}');
      debugPrint('Mensaje: ${response.body}');
      return [];
    }
  }
}