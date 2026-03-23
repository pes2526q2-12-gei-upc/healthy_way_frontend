import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_filter_chip.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/custom_map_widget.dart';
import '../../../core/services/location_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool isZonesCapturedSelected = true;
  bool isRunningMode = true;

  final MapController _mapController = MapController();

  // Ubicación actual del usuario
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    // 1️⃣ Obtener ubicación inicial
    _userLocation = await LocationService.getCurrentLocation();
    setState(() {});

    // 2️⃣ Centrar el mapa en la ubicación inicial
    _mapController.move(_userLocation!, 15.0);

    // 3️⃣ Iniciar seguimiento en tiempo real
    await LocationService().startTracking();

    // 4️⃣ Suscribirse a actualizaciones
    LocationService().locationStream.listen((position) {
      setState(() {
        _userLocation = position;
      });
    });
  }

  @override
  void dispose() {
    // Detener seguimiento cuando la pantalla se cierra
    LocationService().stopTracking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Stack(
        children: [
          // 1️⃣ MAPA REUTILIZABLE
          CustomMapWidget(
            mapController: _mapController,
            initialCenter: _userLocation ?? const LatLng(41.3851, 2.1734),
            initialZoom: 15.0,
            userLocation: _userLocation, // PUNTO AZUL
          ),

          // 2️⃣ INTERFAZ SUPERIOR
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Cerca rutes, equips o zones...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[700],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          elevation: 4,
                        ),
                        child: const Text('+ Planificar', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomFilterChip(
                          label: 'Zones Capturades',
                          icon: Icons.flag_outlined,
                          isSelected: isZonesCapturedSelected,
                          onTap: () {
                            setState(() {
                              isZonesCapturedSelected = !isZonesCapturedSelected;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3️⃣ BOTONES FLOTANTES
          Positioned(
            right: 16,
            bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FloatingMapButton(
                  icon: isRunningMode ? Icons.directions_run : Icons.directions_bike,
                  color: Colors.blue[700]!,
                  iconColor: Colors.white,
                  onTap: () {
                    setState(() {
                      isRunningMode = !isRunningMode;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _FloatingMapButton(
                  icon: Icons.explicit,
                  color: Colors.white,
                  iconColor: Colors.black87,
                  onTap: () {
                    Navigator.pushNamed(context, AppRouter.exploreRoute);
                  },
                ),
                const SizedBox(height: 12),
                _FloatingMapButton(
                  icon: Icons.my_location,
                  color: Colors.white,
                  iconColor: Colors.black87,
                  onTap: () {
                    if (_userLocation != null) {
                      _mapController.move(_userLocation!, 15.0);
                    }
                  },
                ),
                const SizedBox(height: 12),
                _FloatingMapButton(
                  icon: Icons.layers_outlined,
                  color: Colors.white,
                  iconColor: Colors.black87,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// BOTONES FLOTANTES
class _FloatingMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _FloatingMapButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: iconColor),
        onPressed: onTap,
      ),
    );
  }
}