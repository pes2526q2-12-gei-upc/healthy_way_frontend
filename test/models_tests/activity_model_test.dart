import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:healthy_way_frontend/shared/models/activity.dart';
import 'package:healthy_way_frontend/shared/models/route_model.dart';

void main() {
  group('Activity Model Tests', () {
    test('fromJson() parsea correctamente con una ruta incluida', () {
      final json = {
        'distance': 15.5,
        'start_time': '2024-04-30T10:00:00.000Z',
        'end_time': '2024-04-30T11:00:00.000Z',
        'modality': 'Cycling',
        'pace': 3.5,
        'user_id': 1,
        'user_team': 'Dream Team',
        'create_route': true,
        'route': {
          'route_id': 10,
          'name': 'Ruta de prueba',
          'distance': 15.5,
          'private': false,
          'created_by': 1,
          'created_at': '2024-04-30T10:00:00.000Z',
          'location': 'Barcelona',
          'altitude': '10',
          'elevationGain': '20',
          'modality': 'Cycling'
        }
      };

      final activity = Activity.fromJson(json);

      expect(activity.distance, 15.5);
      expect(activity.modality, 'Cycling');
      expect(activity.userId, 1);
      expect(activity.route.id, '10');
      expect(activity.route.name, 'Ruta de prueba');
    });

    test('fromJson() genera la ruta por defecto si el backend manda null', () {
      final json = {
        'distance': 5.0,
        'start_time': '2024-04-30T10:00:00.000Z',
        'end_time': '2024-04-30T10:30:00.000Z',
        // No mandamos 'route' intencionalmente
      };

      final activity = Activity.fromJson(json);

      expect(activity.distance, 5.0);
      expect(activity.modality, 'Running'); // Tu valor por defecto
      expect(activity.userId, 99); // Tu valor por defecto
      // Comprobamos la ruta autogenerada
      expect(activity.route.name, 'Activitat Predeterminada');
      expect(activity.route.distance, 0.0);
    });

    test('toJson() serializa correctamente los datos', () {
      final activity = Activity(
          distance: 10.0,
          startTime: DateTime.utc(2024, 4, 30, 10),
          endTime: DateTime.utc(2024, 4, 30, 11),
          modality: 'Running',
          pace: 5.0,
          userId: 2,
          createRoute: false,
          route: RouteModel(
              id: '1', name: 'Test', distance: 0, isPrivate: false,
              createdBy: 1, createdAt: DateTime.now(), trajectory: [],
              startPoint: const LatLng(0,0), endPoint: const LatLng(0,0),
              location: '', altitude: '0', elevationGain: '0'
          )
      );

      final json = activity.toJson();

      expect(json['distance'], 10.0);
      expect(json['modality'], 'Running');
      expect(json['user_id'], 2);
      expect(json['start_time'], '2024-04-30T10:00:00.000Z');
      expect(json['route'], isNotNull);
    });
  });
}