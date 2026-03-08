import 'package:flutter/material.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/explore_routes/presentation/explore_routes_page.dart';
// 1. IMPORTAMOS LA NUEVA PANTALLA DEL MAPA (Asegúrate de que la ruta coincida con tus carpetas)
import '../../features/map/presentation/map_screen.dart';

class AppRouter {
  static const String loginRoute = '/';
  static const String homeRoute = '/home';
  static const String exploreRoute = '/explore';
  // 2. AÑADIMOS LA RUTA PARA EL MAPA GENERAL
  static const String mapRoute = '/map';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case loginRoute:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case homeRoute:
        return _fadeRoute(const HomePage());
      case exploreRoute:
        return _fadeRoute(const ExploreRoutesScreen());
    // 3. AÑADIMOS EL CASO PARA NAVEGAR AL MAPA
      case mapRoute:
        return _fadeRoute(const MapScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Ruta no definida: ${settings.name}')),
          ),
        );
    }
  }

  static PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    );
  }
}