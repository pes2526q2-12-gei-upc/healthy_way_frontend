import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final CameraFit? initialCameraFit;

  final List<Polygon>? polygons;

  final List<LatLng> plannedRoute;
  final List<LatLng> traversedRoute;

  final bool showStartMarker;
  final bool showEndMarker;
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
    this.polygons,
  });

  @override
  Widget build(BuildContext context) {
    // 1. CONSTRUIR POLÍNEAS AUTOMÁTICAS
    final List<Polyline> allPolylines = [...polylines];

    if (plannedRoute.length > 1) {
      allPolylines.add(
        Polyline(
          points: plannedRoute,
          strokeWidth: 6.0,
          color: Colors.grey.shade400,
        ),
      );
    }

    if (traversedRoute.length > 1) {
      allPolylines.add(
        Polyline(
          points: traversedRoute,
          strokeWidth: 6.0,
          color: const Color(0xFF2864FF),
        ),
      );
    }

    // 2. CONSTRUIR MARCADORES AUTOMÁTICOS
    final List<Marker> allMarkers = [...markers];

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
        maxZoom: 18.0,
      ),
      children: [
        // MAPA OSM
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.healthy_way.app',
        ),

        // POLÍGONOS
        if (polygons != null && polygons!.isNotEmpty)
          PolygonLayer(
            polygons: polygons!,
          ),

        // POLYLINES
        if (allPolylines.isNotEmpty)
          PolylineLayer(polylines: allPolylines),

        // MARKERS
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
            decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.2), shape: BoxShape.circle),
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