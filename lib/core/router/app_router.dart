import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';

class AppRouter {
  // Definimos nombres constantes para evitar errores de escritura
  static const String loginRoute = '/';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );

    // Caso por defecto para rutas no encontradas (Error 404)
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no definida: ${settings.name}')),
          ),
        );
    }
  }
}