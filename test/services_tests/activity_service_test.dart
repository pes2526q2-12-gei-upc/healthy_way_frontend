import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';

import 'package:healthy_way_frontend/shared/models/activity.dart';
import 'package:healthy_way_frontend/shared/models/route_model.dart';
import 'package:healthy_way_frontend/core/services/activity_service.dart';

void main() {
  group('ActivityService Tests', () {

    final dummyRoute = RouteModel(
        id: '1', name: 'Ruta Test', distance: 10.0, isPrivate: false,
        createdBy: 1, createdAt: DateTime.now(), trajectory: [],
        startPoint: const LatLng(0,0), endPoint: const LatLng(0,0),
        location: 'Test', altitude: '0', elevationGain: '0'
    );

    final dummyActivity = Activity(
        distance: 10.0, startTime: DateTime.now(), endTime: DateTime.now(),
        modality: 'Running', pace: 5.0, userId: 1,
        createRoute: false, route: dummyRoute
    );

    test('createActivity retorna datos cuando el status es 201', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/api/v1/activities/upload');
        return http.Response(jsonEncode({'success': true, 'activity_id': 123}), 201);
      });

      final service = ActivityService(client: mockClient);

      // Act
      final result = await service.createActivity(dummyActivity);

      // Assert
      expect(result['success'], true);
      expect(result['activity_id'], 123);
    });

    test('createActivity lanza Exception cuando el servidor falla (ej. 500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final service = ActivityService(client: mockClient);

      expect(
              () async => await service.createActivity(dummyActivity),
          throwsA(isA<Exception>())
      );
    });
  });
}