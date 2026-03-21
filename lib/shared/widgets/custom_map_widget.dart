import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final List<Polyline> polylines;
  final List<Marker> markers;

  /// 🔵 NUEVO: ubicación del usuario
  final LatLng? userLocation;

  const CustomMapWidget({
    super.key,
    required this.mapController,
    required this.initialCenter,
    this.initialZoom = 15.5,
    this.polylines = const [],
    this.markers = const [],
    this.userLocation,
  });

  @override
  Widget build(BuildContext context) {
    // 👇 combinamos markers existentes + user location
    final List<Marker> allMarkers = [
      ...markers,
      if (userLocation != null) _buildUserLocationMarker(userLocation!),
    ];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
      ),
      children: [
        // 🌍 MAPA OSM
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.healthy_way.app',
        ),

        // 📍 POLYLINES (rutas)
        if (polylines.isNotEmpty)
          PolylineLayer(polylines: polylines),

        // 📍 MARKERS (incluye usuario)
        if (allMarkers.isNotEmpty)
          MarkerLayer(markers: allMarkers),
      ],
    );
  }

  /// 🔵 Marker típico estilo Google Maps
  Marker _buildUserLocationMarker(LatLng position) {
    return Marker(
      point: position,
      width: 50,
      height: 50,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Círculo grande (precisión)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
          ),

          // Punto azul central
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