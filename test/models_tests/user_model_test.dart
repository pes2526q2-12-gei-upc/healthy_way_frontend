import 'package:flutter_test/flutter_test.dart';

// ¡En minúsculas!
import 'package:healthy_way_frontend/shared/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    test('fromJson() carga correctamente con team_name', () {
      final json = {
        'user_id': 1,
        'nom': 'Raul',
        'username': 'raul123',
        'email': 'raul@test.com',
        'team_name': 'Los Invicibles',
      };

      final user = User.fromJson(json);

      expect(user.userId, 1);
      expect(user.nom, 'Raul');
      expect(user.team, 'Los Invicibles');
      expect(user.hasTeam, true);
    });

    test('fromJson() maneja un usuario sin equipo (string vacío o null)', () {
      final json = {
        'user_id': 2,
        'nom': 'Ana',
        'username': 'ana99',
        'email': 'ana@test.com',
        'team_name': '', // Backend devuelve vacío
      };

      final user = User.fromJson(json);

      expect(user.userId, 2);
      expect(user.team, null); // Tu lógica lo convierte en null
      expect(user.hasTeam, false);
    });

    test('toJson() convierte correctamente a Map', () {
      final user = User(
        userId: 3,
        nom: 'Carlos',
        username: 'carlosx',
        email: 'carlos@test.com',
        team: 'Runners',
      );

      final json = user.toJson();

      expect(json['user_id'], 3);
      expect(json['nom'], 'Carlos');
      expect(json['team'], 'Runners');
    });
  });
}