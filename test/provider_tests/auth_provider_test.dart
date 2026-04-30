import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Importa las rutas correctas de tu proyecto
import 'package:healthy_way_frontend/shared/models/user_model.dart';
import 'package:healthy_way_frontend/shared/providers/auth_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  group('AuthProvider Tests', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'token_falso_para_tests'});

    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('El estado inicial debe ser no autenticado (null)', () {
      final authProvider = AuthProvider();

      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, false);
    });

    test('login() debe guardar el usuario y cambiar el estado', () async {
      final authProvider = AuthProvider();

      // Creamos un usuario falso
      final dummyUser = User(
          userId: 1,
          nom: 'Raul',
          username: 'raul123',
          email: 'raul@test.com',
          team: 'Alpha'
      );

      // Flag para comprobar si notifyListeners() fue llamado
      bool wasNotified = false;
      authProvider.addListener(() {
        wasNotified = true;
      });

      // Ejecutamos el login
      await authProvider.login(dummyUser);

      // Comprobamos el estado interno del provider
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.nom, 'Raul');
      expect(authProvider.isAuthenticated, true);

      // Comprobamos que avisó a la interfaz gráfica
      expect(wasNotified, true);

      // Comprobamos que se guardó en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final savedUserString = prefs.getString('saved_user');
      expect(savedUserString, isNotNull);
      expect(savedUserString!.contains('raul123'), true);
    });

    test('logout() debe borrar el usuario y limpiar SharedPreferences', () async {
      final authProvider = AuthProvider();
      final dummyUser = User(
          userId: 1, nom: 'Raul', username: 'raul123', email: 'r@test.com'
      );

      // Hacemos login primero
      await authProvider.login(dummyUser);
      expect(authProvider.isAuthenticated, true);

      // Luego hacemos logout
      await authProvider.logout();

      expect(authProvider.currentUser, isNull);
      expect(authProvider.isAuthenticated, false);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('saved_user'), isNull);
    });

    test('loadSavedUser() debe cargar el usuario si existe en SharedPreferences', () async {
      // Simulamos que el usuario ya había hecho login ayer (metiendo datos manuales en memoria)
      final dummyUser = User(
          userId: 99, nom: 'Maria', username: 'maria99', email: 'm@test.com'
      );
      SharedPreferences.setMockInitialValues({
        'saved_user': jsonEncode(dummyUser.toJson())
      });

      final authProvider = AuthProvider();

      // Comprobamos que antes de cargar, es null
      expect(authProvider.currentUser, isNull);

      // Cargamos el usuario
      await authProvider.loadSavedUser();

      // Comprobamos que lo ha leído bien de la memoria
      expect(authProvider.currentUser, isNotNull);
      expect(authProvider.currentUser!.userId, 99);
      expect(authProvider.currentUser!.nom, 'Maria');
      expect(authProvider.isAuthenticated, true);
    });
  });
}