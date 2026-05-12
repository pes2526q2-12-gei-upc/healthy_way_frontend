import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class SecurityService {
  final String _baseUrl = 'http://nattech.fib.upc.edu:40381/api/v1';
  final String _apiKey = 'swgCHeFF51YoEBbiidZVh3SZjX2bVU0YVU0W4hy068Tjhsu0cBgfSGcqXAJSfUwd';

  Future<double> evaluateRouteSecurity(List<LatLng> points) async {
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
        // Assuming the response is either a direct number or a map with a score field
        // Adjust based on actual API response if possible. 
        // Common patterns: {"score": 8.5} or just 8.5
        if (data is num) {
          return data.toDouble();
        } else if (data is Map && data.containsKey('score')) {
          return (data['score'] as num).toDouble();
        } else if (data is Map && data.containsKey('securityScore')) {
          return (data['securityScore'] as num).toDouble();
        }
        return 0.0;
      } else {
        throw Exception('Failed to evaluate security: ${response.statusCode}');
      }
    } catch (e) {
      print('Error evaluating security: $e');
      rethrow;
    }
  }
}
