import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'results_route_screen.dart';

import '../../../shared/widgets/custom_map_widget.dart';
import '../../../shared/providers/tracking_provider.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = context.watch<TrackingProvider>();

    // --- NUEVO: ESCUCHADOR DE AUTO-FINALIZACIÓN (Igual que en RunningRouteScreen) ---
    if (trackingProvider.isFinished) {
      if (ModalRoute.of(context)?.isCurrent == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ResultsRouteScreen()),
                (route) => route.isFirst,
          );
        });
      }
    }

    final traversedRoute = trackingProvider.traversedRoute;
    //
    List<LatLng> plannedRoute = trackingProvider.routeIsSelected ? trackingProvider.rutaSeleccionada.trajectory : [];

    // 1. CENTRO DEL MAPA CORREGIDO:
    // Ya NO le decimos que vaya a plannedRoute.first. Si no hay GPS, se queda en la zona general de L'Hospitalet.
    final mapCenter = traversedRoute.isNotEmpty
        ? traversedRoute.last
        : const LatLng(41.3596, 2.1002);

    // 2. TU UBICACIÓN REAL
    final realUserLocation = traversedRoute.isNotEmpty ? traversedRoute.last : null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          CustomMapWidget(
            mapController: _mapController,
            initialCenter: mapCenter,
            initialZoom: 15.5,
            plannedRoute: plannedRoute,
            traversedRoute: traversedRoute,
            userLocation: realUserLocation,
            showStartMarker: true,
            showEndMarker: true,
            polylines: [
              if (plannedRoute.isNotEmpty)
                Polyline(
                  points: plannedRoute,
                  strokeWidth: 5.0,
                  color: Colors.grey.shade400,
                ),
              if (traversedRoute.isNotEmpty)
                Polyline(
                  points: traversedRoute,
                  strokeWidth: 6.0,
                  color: const Color(0xFF2864FF),
                ),
            ],
          ),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMapOverlayButton(
                            icon: Icons.arrow_back,
                            onTap: () => Navigator.pop(context)
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5))
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('DISTÀNCIA', trackingProvider.distance, 'km'),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildStatItem('RITME', trackingProvider.pace, '/km'),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildStatItem('KCAL', trackingProvider.calories, ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16, bottom: 32,
            child: _buildMapOverlayButton(
              icon: Icons.my_location,
              iconColor: Colors.blueAccent,
              bgColor: Colors.white,
              onTap: () {
                final targetLocation = realUserLocation ?? mapCenter;
                _mapController.move(targetLocation, 16.5);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapOverlayButton({required IconData icon, required VoidCallback onTap, Color iconColor = Colors.black87, Color bgColor = Colors.white}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))]
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(title, style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        RichText(
            text: TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0B233B)),
                children: [
                  if (unit.isNotEmpty) const TextSpan(text: ' '),
                  TextSpan(text: unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.normal))
                ]
            )
        ),
      ],
    );
  }
}