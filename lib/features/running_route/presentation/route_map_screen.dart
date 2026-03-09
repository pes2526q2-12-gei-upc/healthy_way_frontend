// dart
import 'package:flutter/material.dart';

class RouteMapScreen extends StatelessWidget {
  const RouteMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Mapa de la ruta (placeholder)'),
      ),
    );
  }
}
