
// Modelo para identificar una ruta, con su nombre, distancia, privacidad, credor, fecha de creacion , trayectoria con el tipo de ruta y sus puntos, punto inicial y finaly su localizacion
import 'package:latlong2/latlong.dart';

class RouteModel {
  final String id;
  final String name;
  final double distance;
  final bool isPrivate;
  final String creatorName;
  final DateTime createdAt;
  final List<LatLng> trajectory;
  final LatLng startPoint;
  final LatLng endPoint;
  final String location;

  RouteModel({
    required this.id,
    required this.name,
    required this.distance,
    required this.isPrivate,
    required this.creatorName,
    required this.createdAt,
    required this.trajectory,
    required this.startPoint,
    required this.endPoint,
    required this.location,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['id'],
      name: json['name'],
      distance: json['distance'].toDouble(),
      isPrivate: json['private'],
      creatorName: json['created_by'],
      createdAt: json['created_at'],
      trajectory: (json['trajectory'] as List)
          .map((point) => LatLng(point['latitude'], point['longitude']))
          .toList(),
      startPoint: LatLng(json['start_point']['latitude'], json['startPoint']['longitude']),
      endPoint: LatLng(json['end_point']['latitude'], json['endPoint']['longitude']),
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'distance': distance,
      'private': isPrivate,
      'created_by': creatorName,
      'created_at': createdAt,
      'trajectory': trajectory.map((point) => {'latitude': point.latitude, 'longitude': point.longitude}).toList(),
      'start_point': {'latitude': startPoint.latitude, 'longitude': startPoint.longitude},
      'end_point': {'latitude': endPoint.latitude, 'longitude': endPoint.longitude},
      'location': location,
    };
  }
}