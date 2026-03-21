import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/widgets/custom_map_widget.dart';

class RouteMapScreen extends StatefulWidget {
  const RouteMapScreen({super.key});

  @override
  State<RouteMapScreen> createState() => _RouteMapScreenState();
}

class _RouteMapScreenState extends State<RouteMapScreen> {
  final MapController _mapController = MapController();

  final String distance = "2.4";
  final String pace = "5:30";
  final String calories = "210";

  final List<LatLng> _fullRoute = [
    const LatLng(41.4285, 2.1448),
    const LatLng(41.4277, 2.1463),
    const LatLng(41.4265, 2.1453),
    const LatLng(41.4255, 2.1472),
    const LatLng(41.4245, 2.1464),
    const LatLng(41.4238, 2.1476),
  ];

  final int _currentIndex = 2;

  List<LatLng> _traversedRoute = [];
  List<LatLng> _remainingRoute = [];

  @override
  void initState() {
    super.initState();
    _splitRoute();
  }

  void _splitRoute() {
    _traversedRoute = _fullRoute.sublist(0, _currentIndex + 1);
    _remainingRoute = _fullRoute.sublist(_currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final LatLng currentPosition = _fullRoute[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. EL MAPA COMPARTIDO
          CustomMapWidget(
            mapController: _mapController,
            initialCenter: currentPosition,
            initialZoom: 16.5,
            polylines: [
              Polyline(
                points: _remainingRoute,
                strokeWidth: 6.0,
                color: Colors.grey.shade400,
              ),
              Polyline(
                points: _traversedRoute,
                strokeWidth: 6.0,
                color: const Color(0xFF2864FF),
              ),
            ],
            markers: [
              Marker(
                point: currentPosition,
                width: 24,
                height: 24,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2864FF),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 6, offset: const Offset(0, 3)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // 2. INTERFAZ SUPERIOR FLOTANTE
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildMapOverlayButton(
                          icon: Icons.arrow_back,
                          onTap: () {
                            Navigator.pop(context);
                          },
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
                          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem('DISTÀNCIA', distance, 'km'),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildStatItem('RITME', pace, '/km'),
                          Container(width: 1, height: 40, color: Colors.grey.shade300),
                          _buildStatItem('KCAL', calories, ''),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. BOTÓN FLOTANTE
          Positioned(
            right: 16,
            bottom: 32,
            child: _buildMapOverlayButton(
              icon: Icons.my_location,
              iconColor: Colors.blueAccent,
              bgColor: Colors.white,
              onTap: () {
                _mapController.move(currentPosition, 16.5);
              },
            ),
          ),
        ],
      ),
    );
  }

  // BOTÓN LOCAL MANTENIDO
  Widget _buildMapOverlayButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.black87,
    Color bgColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: Icon(icon, color: iconColor, size: 24),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Color(0xFF0B233B)),
            children: [
              if (unit.isNotEmpty) const TextSpan(text: ' '),
              TextSpan(
                text: unit,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ],
    );
  }
}