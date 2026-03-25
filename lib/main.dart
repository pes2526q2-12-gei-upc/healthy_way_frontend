import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'shared/providers/tracking_provider.dart';
void main() {
  // Asegura que los bindings de Flutter estén listos (necesario si luego añades Firebase o plugins nativos como el GPS aquí)
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // Envolvemos toda la app en un MultiProvider
    MultiProvider(
      providers: [
        // Aquí registramos nuestro Provider para que nazca con la app
        ChangeNotifierProvider(create: (_) => TrackingProvider()),

        // para futuras funcionalidades, como autenticación, podríamos añadir más providers aquí:
        // ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const HealthyWayApp(),
    ),
  );
}