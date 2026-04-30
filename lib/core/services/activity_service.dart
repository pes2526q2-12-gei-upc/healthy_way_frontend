import 'package:healthy_way_frontend/shared/models/RouteModel.dart';
import 'package:healthy_way_frontend/shared/models/Activity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:healthy_way_frontend/core/services/token_service.dart';

class ActivityService {

  static final ActivityService _instance = ActivityService._internal();
  factory ActivityService() => _instance;
  ActivityService._internal();

  final String baseUrl = 'http://nattech.fib.upc.edu:40540/api/v1';

  Future<dynamic> createActivity(Activity activityData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/activities/upload'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${await SecureStorageService().getToken()}'},
      body: json.encode(activityData.toJson()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      print('--- DEBUG INFO ---');
      print('URL: ${response.request?.url}'); // Verifica la URL final (por si hubo redirecciones)
      print('METODO: ${response.request?.method}'); // Confirma que fue un POST
      print('STATUS CODE: ${response.statusCode}'); // El número clave (404, 405, 500...)
      print('BODY DEL ERROR: ${response.body}'); // Aquí el backend suele decir qué campo falla
      print('HEADERS RESPUESTA: ${response.headers}'); // Ver qué tipo de contenido dice el servidor que envía
      print('HEADERS ENVIADOS: ${response.request?.headers}'); // ¿Mandaste el Content-Type: application/json?
      print('JSON ENVIADO: ${jsonEncode(activityData)}'); // Revisa qué estás mandando
      print('------------------');
      throw Exception('Error al crear la actividad');
    }
  }

}
