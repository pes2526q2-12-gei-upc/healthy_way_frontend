import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Resultado devuelto por el servicio de seguridad
class SecurityResult {
  final double safetyIndex;
  final String? safetyLevel;

  SecurityResult({required this.safetyIndex, this.safetyLevel});

  factory SecurityResult.fromJson(dynamic data) {
    // Si la respuesta es sólo un número
    if (data is num) {
      return SecurityResult(safetyIndex: data.toDouble(), safetyLevel: null);
    }

    if (data is Map) {
      double index = 0.0;
      String? level;

      if (data.containsKey('safetyIndex') && data['safetyIndex'] != null) {
        index = (data['safetyIndex'] as num).toDouble();
      } else if (data.containsKey('score') && data['score'] != null) {
        index = (data['score'] as num).toDouble();
      } else if (data.containsKey('securityScore') && data['securityScore'] != null) {
        index = (data['securityScore'] as num).toDouble();
      }

      if (data.containsKey('safetyLevel')) {
        final val = data['safetyLevel'];
        if (val != null) level = val.toString();
      } else if (data.containsKey('securityLevel')) {
        final val = data['securityLevel'];
        if (val != null) level = val.toString();
      }

      return SecurityResult(safetyIndex: index, safetyLevel: level);
    }

    // Fallback
    return SecurityResult(safetyIndex: 0.0, safetyLevel: null);
  }
}

class SecurityService {
  final String _baseUrl = 'http://nattech.fib.upc.edu:40381/api/v1';
  final String _apiKey = 'swgCHeFF51YoEBbiidZVh3SZjX2bVU0YVU0W4hy068Tjhsu0cBgfSGcqXAJSfUwd';

  /// Evalúa la ruta y devuelve un [SecurityResult] que contiene el índice y
  /// el nivel de seguridad (si estuviera presente en la respuesta).
  Future<SecurityResult> evaluateRouteSecurity(List<LatLng> points) async {
    final url = Uri.parse('$_baseUrl/evaluate-route-security');

    final body = jsonEncode({
      'routePoints': points.map((p) => {
        'lat': p.latitude,
        'lon': p.longitude,
      }).toList(),
    });

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-API-KEY': _apiKey,
        },
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return SecurityResult.fromJson(data);
      } else {
        throw Exception('Failed to evaluate security: ${response.statusCode}');
      }
    } catch (e) {
      // Mantener el print para fácil debugging en desarrollo
      debugPrint('Error evaluating security: $e');
      rethrow;
    }
  }
}
