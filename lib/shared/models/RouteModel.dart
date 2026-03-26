
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
  final String altitude;
  final String elevation_gain;

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
    required this.altitude,
    required this.elevation_gain,
  });

  factory RouteModel.fromJson(Map<String, dynamic> json) {
    return RouteModel(
      id: json['route_id'].toString(),
      name: json['name'],
      distance: json['distance'].toDouble(),
      isPrivate: json['private'],
      creatorName: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      trajectory: json['trajectory'] != null
          ? (json['trajectory'] as List).map((coord) {
        return LatLng(
            (coord[1] as num).toDouble(), // Latitud
            (coord[0] as num).toDouble()  // Longitud
        );
      }).toList()
          : [],

      startPoint: json['start_point'] != null
          ? LatLng(
          (json['start_point'][1] as num).toDouble(), // Latitud
          (json['start_point'][0] as num).toDouble()  // Longitud
      )
          : const LatLng(0, 0), // O null si tu variable no es requerida

      endPoint: json['end_point'] != null
          ? LatLng(
          (json['end_point'][1] as num).toDouble(), // Latitud
          (json['end_point'][0] as num).toDouble()  // Longitud
      )
          : const LatLng(0, 0), // O pon un LatLng(0,0) como arriba si lo prefieres
      location: json['location'],
      altitude: json['altitude'].toString(),
      elevation_gain: json['elevation_gain'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'distance': distance,
      'private': isPrivate,
      'created_by': creatorName,
      'created_at': createdAt.toIso8601String(),
      'trajectory': {
        'type': 'LineString',
        'coordinates' : trajectory.map((point) => [point.latitude, point.longitude]).toList()
      },
      'start_point': {
        'type': 'Point',
        'coordinates': [startPoint.latitude, startPoint.longitude]
      },
      'end_point': {
        'type': 'Point',
        'coordinates': [endPoint.latitude, endPoint.longitude]
      },
      'location': location,
      'altitude': double.tryParse(altitude),
      'elevation_gain': double.tryParse(elevation_gain),
    };
  }
}