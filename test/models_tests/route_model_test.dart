import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

// ¡En minúsculas!
import 'package:healthy_way_frontend/shared/models/route_model.dart';

void main() {
  group('Route Model Tests', () {
    test('fromJson() procesa correctamente coordenadas GeoJSON invertidas', () {
      final json = {
        'route_id': 101, // Aseguramos que el .toString() funciona
        'name': 'Ruta por Collserola',
        'distance': 25.5,
        'private': false,
        'created_by': 1,
        'created_at': '2024-04-30T10:00:00.000Z',
        'location': 'Barcelona',
        'altitude': 150.5,
        'elevationGain': 300,
        'modality': 'Cycling',
        'trajectory': [
          [2.1934, 41.3851],
          [2.1940, 41.3860]
        ],
        'start_point': [2.1934, 41.3851],
        'end_point': [2.1940, 41.3860],
      };

      final route = RouteModel.fromJson(json);

      expect(route.id, '101');
      expect(route.name, 'Ruta por Collserola');
      expect(route.distance, 25.5);

      expect(route.trajectory.first.latitude, 41.3851);
      expect(route.trajectory.first.longitude, 2.1934);

      expect(route.startPoint.latitude, 41.3851);
      expect(route.startPoint.longitude, 2.1934);
    });

    test('toJson() genera formato GeoJSON correctamente', () {
      final route = RouteModel(
        id: '202',
        name: 'Ruta Montaña',
        distance: 20.0,
        isPrivate: true,
        createdBy: 2,
        createdAt: DateTime.utc(2024, 1, 1),
        trajectory: [const LatLng(42.0, 3.0)],
        startPoint: const LatLng(42.0, 3.0),
        endPoint: const LatLng(42.1, 3.1),
        location: 'Pirineos',
        altitude: '1500.5',
        elevationGain: '500.0',
      );

      final json = route.toJson('running');

      expect(json['name'], 'Ruta Montaña');
      expect(json['trajectory']['type'], 'LineString');

      // El toJson debe generar arrays de [Longitud, Latitud] para el backend
      expect(json['trajectory']['coordinates'][0][0], 3.0);
      expect(json['trajectory']['coordinates'][0][1], 42.0);

      expect(json['start_point']['type'], 'Point');
      expect(json['start_point']['coordinates'][0], 3.0);
    });
  });
}