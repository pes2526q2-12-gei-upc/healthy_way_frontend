import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:healthy_way_frontend/shared/models/route_model.dart';
import 'package:healthy_way_frontend/core/services/route_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('RouteService Tests', () {

    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'token_falso_para_tests'});

    test('getRouteById retorna un RouteModel válido cuando el status es 200', () async {
      // 1. Arrange
      final String testRouteId = '99';

      final mockClient = MockClient((request) async {
        // Comprobamos que llama a la URL con el ID correcto
        expect(request.url.path, '/api/v1/routes/99');

        // Simulamos la respuesta de la base de datos
        final fakeJsonResponse = {
          'route_id': 99,
          'name': 'Ruta de prueba',
          'distance': 5.5,
          'private': true,
          'created_by': 1,
          'created_at': '2024-05-01T10:00:00.000Z',
          'trajectory': [[2.1, 41.1], [2.2, 41.2]],
          'start_point': [2.1, 41.1],
          'end_point': [2.2, 41.2],
          'location': 'Hospitalet',
          'altitude': 10,
          'elevationGain': 20,
          'modality': 'Cycling'
        };

        return http.Response(jsonEncode(fakeJsonResponse), 200);
      });

      final service = RouteService(client: mockClient);

      // 2. Act
      final route = await service.getRouteById(testRouteId);

      // 3. Assert
      expect(route, isA<RouteModel>()); // Verificamos que es del tipo correcto
      expect(route.id, '99');
      expect(route.name, 'Ruta de prueba');
      expect(route.location, 'Hospitalet');
    });

    test('deleteRoute no lanza error si el status es 200', () async {
      final mockClient = MockClient((request) async {
        expect(request.method, 'DELETE');
        return http.Response('Ruta eliminada', 200);
      });

      final service = RouteService(client: mockClient);

      // Si no lanza excepción, el test pasa automáticamente
      await service.deleteRoute('99');
    });

    test('deleteRoute lanza Exception si el status NO es 200', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final service = RouteService(client: mockClient);

      expect(
              () async => await service.deleteRoute('99'),
          throwsA(isA<Exception>())
      );
    });
  });
}