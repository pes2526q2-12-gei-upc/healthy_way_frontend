import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'shared/providers/Auth_provider.dart';
import 'shared/providers/tracking_provider.dart';
Future<void> main() async {
  // Asegura que los bindings de Flutter estén listos (necesario si luego añades Firebase o plugins nativos como el GPS aquí)
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();

  await authProvider.loadSavedUser();

  runApp(
    // Envolvemos toda la app en un MultiProvider
    MultiProvider(
      providers: [
        // Aquí registramos nuestro Provider para que nazca con la app
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const HealthyWayApp(),
    ),
  );
}