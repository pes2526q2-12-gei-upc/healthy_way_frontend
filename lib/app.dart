import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';

class HealthyWayApp extends StatelessWidget {
  const HealthyWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    return MaterialApp(
      title: 'Healthy Way',
      debugShowCheckedModeBanner: false,

      home: isAuthenticated ? const HomePage() : const LoginPage(),

      // Conectamos nuestra lógica de navegación
      onGenerateRoute: AppRouter.generateRoute,

      // Aquí podrías añadir el tema global más adelante
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}