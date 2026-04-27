import 'package:flutter_test/flutter_test.dart';
import 'package:healthy_way_frontend/core/services/user_service.dart';

void main() {
  test('Login con credenciales reales', () async {
    final userService = UserService();
    
    try {
      final user = await userService.login('chris', 'Aa123___');
      expect(user, isNotNull);
      expect(user!.username, 'chris');
    } catch (e) {
      fail('Error durante el login: $e');
    }
  });
}
