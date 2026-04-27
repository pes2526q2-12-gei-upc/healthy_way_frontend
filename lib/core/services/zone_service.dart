import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;

class ZoneService {
  static final ZoneService _instance = ZoneService._internal();
  factory ZoneService() => _instance;
  ZoneService._internal();

  final String baseUrl = 'http://localhost:8080/api/v1';

  Future<List<Polygon>> getZonesCapturades({
    required LatLngBounds bounds,
    required String sport,
    required String team,
  }) async {
    // 1. Extraemos los puntos superior (NorthEast) e inferior (SouthWest)
    final topPoint = bounds.northEast;
    final bottomPoint = bounds.southWest;

    // 2. Aquí harías tu llamada HTTP real al backend
    // final response = await http.get('.../?topLat=${topPoint.latitude}&...');

    // 3. Transformarías el JSON a una lista de Polígonos de flutter_map
    return [];
  }
}