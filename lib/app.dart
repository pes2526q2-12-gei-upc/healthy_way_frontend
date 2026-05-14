import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/shared/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/home/presentation/home_page.dart';
import 'l10n/app_localizations.dart';

class HealthyWayApp extends StatelessWidget {
  const HealthyWayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = context.watch<AuthProvider>().isAuthenticated;
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: const [
        Locale('ca'),
        Locale('es'),
        Locale('en'),
      ],

      title: 'Healthy Way',
      debugShowCheckedModeBanner: false,

      home: isAuthenticated ? const HomePage() : const LoginPage(),

      onGenerateRoute: AppRouter.generateRoute,

      onUnknownRoute: (settings) {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      },

      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
    );
  }
}