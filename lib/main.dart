import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'shared/providers/auth_provider.dart';
import 'shared/providers/tracking_provider.dart';
import 'shared/providers/location_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();

  await authProvider.loadSavedUser();

  runApp(
    // Envolvemos toda la app en un MultiProvider
    MultiProvider(
      providers: [
        // Aquí registramos nuestro Provider para que nazca con la app
        ChangeNotifierProvider(create: (_) => TrackingProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider.value(value: authProvider),
      ],
      child: const HealthyWayApp(),
    ),
  );
}