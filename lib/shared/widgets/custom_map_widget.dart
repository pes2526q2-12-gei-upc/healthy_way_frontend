import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomMapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final double initialZoom;
  final List<Polyline> polylines;
  final List<Marker> markers;

  const CustomMapWidget({
    super.key,
    required this.mapController,
    required this.initialCenter,
    this.initialZoom = 15.5,
    this.polylines = const [],
    this.markers = const [],
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.healthy_way.app',
        ),
        if (polylines.isNotEmpty)
          PolylineLayer(polylines: polylines),
        if (markers.isNotEmpty)
          MarkerLayer(markers: markers),
      ],
    );
  }
}