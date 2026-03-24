//Servicio para hacer llamadas a la API de rutas
import 'package:healthy_way_frontend/shared/models/RouteModel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RouteService {

  static final RouteService _instance = RouteService._internal();
  factory RouteService() => _instance;
  RouteService._internal();

  final String baseUrl = 'http://localhost:3000/api/v1';

  // 1. OBTENER TODAS LAS RUTAS PUBLICAS
  Future<List<RouteModel>> getRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/routes'));

    if (response.statusCode == 200) {
      List<dynamic> routesJson = json.decode(response.body);
      if(routesJson is String) {
        routesJson = json.decode(response.body);
      }
      final List<RouteModel> routes = routesJson.map((json) => RouteModel.fromJson(json)).toList();
      return routes;
    } else {
      throw Exception('Error al cargar las rutas');
    }
  }

  // 1.2 OBTENER TODAS LAS RUTAS RECOMENDADAS
  Future<List<RouteModel>> getRecommendedRoutes() async {
    final response = await http.get(Uri.parse('$baseUrl/routes/recommendations'));

    if (response.statusCode == 200) {
      final List<dynamic> routesJson = json.decode(response.body);
      final List<RouteModel> routes = routesJson.map((json) => RouteModel.fromJson(json)).toList();
      return routes;
    } else {
      throw Exception('Error al cargar las rutas recomendadas');
    }
  }

  // 2. OBTENER DETALLES DE UNA RUTA POR ID
  Future<RouteModel> getRouteByID(String routeId) async {
    final response = await http.get(Uri.parse('$baseUrl/routes/$routeId'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> routeJson = json.decode(response.body);
      return RouteModel.fromJson(routeJson);
    } else {
      throw Exception('Error al cargar los detalles de la ruta');
    }
  }

  // 3. CREAR UNA NUEVA RUTA. Devuelve la ruta creada con su ID asignado por el backend
  Future<dynamic> createRoute(RouteModel routeData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(routeData.toJson()),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al crear la ruta');
    }
  }

  // 4. ACTUALIZAR UNA RUTA EXISTENTE
  Future<dynamic> updateRoute(String routeId, RouteModel routeData) async {
    final response = await http.put(
      Uri.parse('$baseUrl/routes/$routeId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(routeData.toJson()),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Error al actualizar la ruta');
    }
  }

  // 5. ELIMINAR UNA RUTA
  Future<void> deleteRoute(String routeId) async {
    final response = await http.delete(Uri.parse('$baseUrl/routes/$routeId'));

    if (response.statusCode != 204) {
      throw Exception('Error al eliminar la ruta');
    }
  }
}