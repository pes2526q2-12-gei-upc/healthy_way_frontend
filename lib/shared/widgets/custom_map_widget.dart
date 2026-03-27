import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final CameraFit? initialCameraFit;

  final List<LatLng> plannedRoute;   // Ruta a seguir entera (fondo gris)
  final List<LatLng> traversedRoute; // Ruta real hecha por el usuario (azul por encima)

  final bool showStartMarker; // Punto verde al inicio
  final bool showEndMarker;   // Punto rojo al final
  final LatLng? userLocation;

  final List<Polyline> polylines;
  final List<Marker> markers;

  const CustomMapWidget({
    super.key,
    required this.mapController,
    required this.initialCenter,
    this.initialZoom = 15.5,
    this.initialCameraFit,
    this.plannedRoute = const [],
    this.traversedRoute = const [],
    this.showStartMarker = false,
    this.showEndMarker = false,
    this.polylines = const [],
    this.markers = const [],
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    // 1. CONSTRUIR POLÍNEAS AUTOMÁTICAS (El orden importa: de abajo hacia arriba)
    final List<Polyline> allPolylines = [...polylines];

    // Primero la ruta planificada (fondo gris) - Solo si hay más de 1 punto
    if (plannedRoute.length > 1) {
      allPolylines.add(
        Polyline(
          points: plannedRoute,
          strokeWidth: 6.0,
          color: Colors.grey.shade400, // Gris para indicar el camino a seguir
        ),
      );
    }

    // Segundo, la ruta real que se va pisando (azul por encima) - Solo si hay más de 1 punto
    if (traversedRoute.length > 1) {
      allPolylines.add(
        Polyline(
          points: traversedRoute,
          strokeWidth: 6.0,
          color: const Color(0xFF2864FF), // Azul vibrante para lo que ya has recorrido
        ),
      );
    }

    // 2. CONSTRUIR MARCADORES AUTOMÁTICOS
    final List<Marker> allMarkers = [...markers];

    // Priorizamos la ruta planificada para poner los marcadores de inicio/fin.
    final List<LatLng> baseRoute = plannedRoute.isNotEmpty ? plannedRoute : traversedRoute;

    if (baseRoute.isNotEmpty) {
      if (showStartMarker) {
        allMarkers.add(_buildStartMarker(baseRoute.first));
      }
      if (showEndMarker) {
        allMarkers.add(_buildEndMarker(baseRoute.last));
      }
    }

    if (userLocation != null) {
      allMarkers.add(_buildUserLocationMarker(userLocation!));
    }

    // 3. RENDERIZAR MAPA
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        initialCameraFit: initialCameraFit,
        maxZoom: 18.0, // <-- NUEVO: Límite para que no desaparezca el fondo (mapa gris)
      ),
      children: [
        // 🌍 MAPA OSM
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.healthy_way.app',
        ),

        // 📍 POLYLINES
        if (allPolylines.isNotEmpty)
          PolylineLayer(polylines: allPolylines),

        // 📍 MARKERS
        if (allMarkers.isNotEmpty)
          MarkerLayer(markers: allMarkers),
      ],
    );
  }

  // CONSTRUCTORES DE MARCADORES PERSONALIZADOS
  Marker _buildStartMarker(LatLng position) {
    return Marker(
      point: position,
      width: 14,
      height: 14,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3)
        ),
      ),
    );
  }

  Marker _buildEndMarker(LatLng position) {
    return Marker(
      point: position,
      width: 14,
      height: 14,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3)
        ),
      ),
    );
  }

  Marker _buildUserLocationMarker(LatLng position) {
    return Marker(
      point: position,
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.2), shape: BoxShape.circle),
          ),
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
          ),
        ],
      ),
    );
  }
}