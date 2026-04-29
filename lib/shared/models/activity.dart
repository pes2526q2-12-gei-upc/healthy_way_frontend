import 'package:flutter/foundation.dart';
//Modelo activity con los atributos distance: number,start_time: Date,end_time: Date,modality: string,pace: number,route_id: number;

import 'package:latlong2/latlong.dart';

import 'route_model.dart';

class Activity {
  final double distance;
  final DateTime startTime;
  final DateTime endTime;
  final String modality;
  final double pace;
  final int userId;
  final String userTeam;
  final bool createRoute;
  final RouteModel route;

  Activity({
    required this.distance,
    required this.startTime,
    required this.endTime,
    required this.modality,
    required this.pace,
    required this.userId,
    required this.userTeam,
    required this.createRoute,
    required this.route,
  });

  factory Activity.fromJson(Map<String, dynamic> json) {
    debugPrint('DATOS REALES DE LA RUTA: ${json['route']}');
    return Activity(
      distance: json['distance']?.toDouble() ?? 1,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      modality: json['modality'] ?? 'Running',
      pace: json['pace']?.toDouble() ?? 1,
      userId: json['user_id'] ?? 99,
      userTeam: json['user_team'] ?? '',
      createRoute: json['create_route'] ?? false,
      route: json['route'] != null ? RouteModel.fromJson(json['route']) : RouteModel(
        id: '',
        name: 'Activitat Predeterminada',
        distance: 0.0,
        isPrivate: false,
        createdBy: 99,
        createdAt: DateTime.now(),
        trajectory: [],
        startPoint: const LatLng(0, 0),
        endPoint: const LatLng(0, 0),
        location: 'Ubicaió desconeguda',
        altitude: 'Altitud desconeguda',
        elevationGain: 'Elevació desconeguda',
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'distance': distance,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'modality': modality,
      'pace': pace,
      'user_id': userId,
      'create_route': createRoute,
      'route': route.toJson(modality),
    };
  }
}

