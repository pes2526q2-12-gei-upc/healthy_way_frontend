import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:healthy_way_frontend/core/services/user_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('UserService Tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({});

    test('login() debe devolver un User si las credenciales son correctas (200)', () async {
      // 1. ARRANGE: Preparamos un servidor falso que siempre responda OK (200)
      final mockClient = MockClient((request) async {
        // Verificamos que llama a la URL correcta
        expect(request.url.path, '/api/v1/auth/login');

        // Devolvemos el JSON exacto que devolvería tu backend real
        final jsonResponse = {
          'authToken': 'token_falso_12345',
          'user': {
            'user_id': 1,
            'nom': 'Raul',
            'username': 'raul123',
            'email': 'raul@test.com',
            'team_name': 'Dream Team'
          }
        };
        return http.Response(jsonEncode(jsonResponse), 200);
      });

      // 2. ACT: Ejecutamos tu función de login
      final service = UserService(client: mockClient);
      final user = await service.login('raul123', 'passwordSegura');

      // 3. ASSERT: Verificamos que devuelve el usuario correcto
      expect(user, isNotNull);
      expect(user!.nom, 'Raul');
      expect(user.userId, 1);
    });

    test('login() debe devolver null si las credenciales son incorrectas (401)', () async {
      // 1. ARRANGE: Servidor falso que responde con error de autorización
      final mockClient = MockClient((request) async {
        return http.Response(jsonEncode({'error': 'Credenciales inválidas'}), 401);
      });

      final service = UserService(client: mockClient);

      // 2. ACT
      final user = await service.login('raul123', 'passwordIncorrecta');

      // 3. ASSERT: Como programaste en tu UserService, si no es 200, devuelve null
      expect(user, isNull);
    });
  });
}
