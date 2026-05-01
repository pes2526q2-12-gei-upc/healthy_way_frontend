import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:healthy_way_frontend/core/services/token_service.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class ZoneService {
  final http.Client client;
  static final ZoneService _instance = ZoneService._internal();
  factory ZoneService({http.Client? client}) {
    if (client != null) {
      return ZoneService._internal(client: client);
    }
    return _instance;
  }
  ZoneService._internal({http.Client? client}) : client = client ?? http.Client();

  Color _getColorForTeam(String? teamId) {
    if (teamId == null || teamId.isEmpty) {
      return Colors.grey.withValues(alpha: 0.3);
    }
    int hash = teamId.hashCode;
    double hue = (hash.abs() * 137.508) % 360.0;
    return HSLColor.fromAHSL(0.5, hue, 0.8, 0.5).toColor();
  }

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  Future<List<Polygon>> getZonesCapturades({required String modality, String? team}) async {
    http.Response response;
    if(team != null) {
      response = await client.get(
        Uri.parse('$baseUrl/zones/quadrants?modality=${Uri.encodeComponent(modality)}&team=${Uri.encodeComponent(team)}'),
        headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
      );
    }
    else {
      response = await client.get(
        Uri.parse('$baseUrl/zones/map?modality=${Uri.encodeComponent(modality)}'),
        headers: {'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
      );
    }

    final zonesJson = json.decode(response.body);
    final List<dynamic> quadrantsList = zonesJson['quadrants'] ?? [];
    List<Polygon> polygons = [];

    if (response.statusCode == 200) {
      for (var quadrant in quadrantsList) {
        final List<dynamic> boundaryList = quadrant['boundary'] ?? [];
        List<LatLng> polygonPoints = boundaryList.map((point) {
          return LatLng(
              point['latitude'].toDouble(),
              point['longitude'].toDouble()
          );
        }).toList();
        final Color teamColor;
        if(modality == 'running') {
          teamColor = _getColorForTeam(quadrant['run_id']);
        }
        else {
          teamColor = _getColorForTeam(quadrant['cycling_id']);
        }
        polygons.add(Polygon(points: polygonPoints, color: teamColor, borderColor: teamColor.withValues(alpha: 0.8), borderStrokeWidth: 2));
      }
    }
    else if(response.statusCode == 400) {
      throw Exception('Parámetros inválidos para obtener las zonas capturadas');
    }
    else if(response.statusCode == 404) {
      throw Exception('No se ha encontrado el equipo.');
    }
    else {
      throw Exception('Error al cargar las zonas capturadas');
    }
    return polygons;
  }
}