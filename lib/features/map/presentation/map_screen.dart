import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/zone_service.dart';
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
  bool isZonesCapturedSelected = false;
  bool isRunningMode = true;

  List<Polygon> _capturedHexagons = [];
  bool _isLoadingZones = false;

  final MapController _mapController = MapController();

  // Ubicación actual del usuario
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    _userLocation = await LocationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {});

    _mapController.move(_userLocation!, 15.0);

    await LocationService().startTracking();

    LocationService().locationStream.listen((position) {
      if (!mounted) return;
      setState(() {
        _userLocation = position;
      });
    });
  }

  Future<void> _fetchZones() async {
    if (!isZonesCapturedSelected) {
      setState(() => _capturedHexagons = []);
      return;
    }

    setState(() => _isLoadingZones = true);

    try {
      final bounds = _mapController.camera.visibleBounds;
      final zones = await ZoneService().getZonesCapturades(
        bounds: bounds,
        sport: isRunningMode ? 'Running' : 'Cycling',
        team: '',
      );
      setState(() {
        _capturedHexagons = zones;
      });
    } catch (e) {
      print("Error obteniendo zonas: $e");
    } finally {
      setState(() => _isLoadingZones = false);
    }
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
          CustomMapWidget(
            mapController: _mapController,
            initialCenter: _userLocation ?? const LatLng(41.3851, 2.1734),
            initialZoom: 15.0,
            userLocation: _userLocation, // PUNTO AZUL
            polygons: _capturedHexagons,
          ),

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
                              hintText: 'Cercar rutes',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, AppRouter.exploreRoute);
                            },
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
                            _fetchZones();
                          },
                        ),
                        // Si está cargando, mostramos un pequeño spinner
                        if (_isLoadingZones) ...[
                          const SizedBox(width: 8),
                          const SizedBox(
                              width: 16, height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2)
                          )
                        ]
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
                    if(isZonesCapturedSelected) {
                      _fetchZones();
                    }
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