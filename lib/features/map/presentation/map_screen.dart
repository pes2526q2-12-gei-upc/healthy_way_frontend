import 'dart:async';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
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

  List<Polygon> _visibleHexagons = [];
  List<Polygon> _allCapturedHexagons = [];
  bool _isLoadingZones = false;

  final MapController _mapController = MapController();
  StreamSubscription? _mapEventSubscription;

  final TextEditingController _teamSearchController = TextEditingController();
  String _teamSearchQuery = '';
  final FocusNode _teamSearchFocusNode = FocusNode();

  Timer? _debounce;
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _mapEventSubscription = _mapController.mapEventStream.listen((event) {
      if (isZonesCapturedSelected) _filterVisibleHexagons();
    });
  }

  Future<void> _initializeLocation() async {
    _userLocation = await LocationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {});
    _mapController.move(_userLocation!, 15.0);
    await LocationService().startTracking();
    LocationService().locationStream.listen((position) {
      if (!mounted) return;
      setState(() { _userLocation = position.latLng; });
    });
  }

  Future<void> _fetchZones() async {
    if (!isZonesCapturedSelected) {
      setState(() { _allCapturedHexagons = []; _visibleHexagons = []; });
      return;
    }
    setState(() => _isLoadingZones = true);
    try {
      List<Polygon<Object>> zones;
      if (_teamSearchQuery.isNotEmpty) {
        zones = await ZoneService().getZonesCapturades(modality: isRunningMode ? 'running' : 'cycling', team: _teamSearchQuery);
      } else {
        zones = await ZoneService().getZonesCapturades(modality: isRunningMode ? 'running' : 'cycling');
      }
      setState(() { _allCapturedHexagons = zones; });
      _filterVisibleHexagons();
    } catch (e) {
      debugPrint("Error obteniendo zonas: $e");
    } finally {
      setState(() => _isLoadingZones = false);
    }
  }

  void _filterVisibleHexagons() {
    try {
      final bounds = _mapController.camera.visibleBounds;
      setState(() { _visibleHexagons = _allCapturedHexagons.where((polygon) => polygon.points.any((point) => bounds.contains(point))).toList(); });
    } catch (e) {
      debugPrint("Error filtrando hexágonos visibles: $e");
    }
  }

  @override
  void dispose() {
    _teamSearchController.dispose();
    _teamSearchFocusNode.dispose();
    LocationService().stopTracking();
    _mapEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
      body: Stack(
        children: [
          CustomMapWidget(
            mapController: _mapController,
            initialCenter: _userLocation ?? const LatLng(41.3851, 2.1734),
            initialZoom: 15.0,
            userLocation: _userLocation,
            polygons: _visibleHexagons,
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
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))]),
                          child: TextField(
                            readOnly: true,
                            decoration: InputDecoration(
                              hintText: l10n.searchRoutes,
                              prefixIcon: const Icon(Icons.search, color: Colors.grey),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onTap: () => Navigator.pushNamed(context, AppRouter.exploreRoute),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        CustomFilterChip(
                          label: l10n.capturedZones,
                          icon: Icons.flag_outlined,
                          isSelected: isZonesCapturedSelected,
                          onTap: () {
                            setState(() {
                              isZonesCapturedSelected = !isZonesCapturedSelected;
                              if (!isZonesCapturedSelected) { _teamSearchController.clear(); _teamSearchQuery = ''; }
                            });
                            _fetchZones();
                          },
                        ),

                        if (isZonesCapturedSelected) ...[
                          const SizedBox(width: 2),
                          SizedBox(
                            width: 160,
                            height: 36,
                            child: TextField(
                              controller: _teamSearchController,
                              focusNode: _teamSearchFocusNode,
                              onChanged: (value) {
                                _teamSearchQuery = value;
                                if (_debounce?.isActive ?? false) _debounce!.cancel();
                                _debounce = Timer(const Duration(milliseconds: 500), () {
                                  if (mounted) {
                                    _fetchZones().then((_) => _teamSearchFocusNode.requestFocus());
                                  }
                                });
                              },
                              decoration: InputDecoration(
                                hintText: l10n.searchTeam,
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                suffixIcon: _isLoadingZones ? const Padding(padding: EdgeInsets.all(10), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))) : null,
                                hintStyle: const TextStyle(fontSize: 13),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                filled: true, fillColor: Colors.white,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey.shade300)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.blue.shade300, width: 1.5)),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16, bottom: 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FloatingMapButton(icon: isRunningMode ? Icons.directions_run : Icons.directions_bike, color: Colors.blue[700]!, iconColor: Colors.white, onTap: () {
                  setState(() { isRunningMode = !isRunningMode; });
                  if (isZonesCapturedSelected) _fetchZones();
                }),
                const SizedBox(height: 12),
                _FloatingMapButton(icon: Icons.my_location, color: Colors.white, iconColor: Colors.black87, onTap: () {
                  if (_userLocation != null) _mapController.move(_userLocation!, 15.0);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingMapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color iconColor;

  const _FloatingMapButton({required this.icon, required this.onTap, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 8, offset: const Offset(0, 4))]),
      child: IconButton(icon: Icon(icon, color: iconColor), onPressed: onTap),
    );
  }
}