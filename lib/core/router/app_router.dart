import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';

class AppRouter {
  // Definimos nombres constantes para evitar errores de escritura
  static const String loginRoute = '/';
  static const String homeRoute = '/home';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case homeRoute:
        return MaterialPageRoute(builder: (_) => const HomePage());

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