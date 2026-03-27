import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

class HealthyWayApp extends StatelessWidget {
  const HealthyWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthy Way',
      debugShowCheckedModeBanner: false,

      // Definimos la ruta inicial (Login)
      initialRoute: AppRouter.loginRoute,

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