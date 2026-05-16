import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:healthy_way_frontend/core/router/app_router.dart';
import 'package:healthy_way_frontend/shared/models/route_model.dart';
import '../../../shared/models/user_model.dart';
import '../../../shared/widgets/custom_map_widget.dart';
import '../../../shared/providers/tracking_provider.dart';
import '../../../core/services/user_service.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({super.key});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  bool _isFavorite = false;
  final MapController _mapController = MapController();
  late RouteModel rutaSeleccionada;
  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    getRutaSeleccionada();
  }

  Future<void> getRutaSeleccionada() async {
    final trackingProvider = context.read<TrackingProvider>();
    setState(() { rutaSeleccionada = trackingProvider.rutaSeleccionada; _isLoadingRoute = false; });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (!_isLoadingRoute)
            Positioned(
              top: 0, left: 0, right: 0, height: size.height * 0.65,
              child: CustomMapWidget(
                mapController: _mapController,
                initialCameraFit: rutaSeleccionada.trajectory.isNotEmpty ? CameraFit.bounds(bounds: LatLngBounds.fromPoints(rutaSeleccionada.trajectory), padding: const EdgeInsets.all(40.0), maxZoom: 18.0) : null,
                initialCenter: rutaSeleccionada.trajectory.isNotEmpty ? rutaSeleccionada.trajectory.first : const LatLng(41.3851, 2.1734),
                initialZoom: 15.0,
                traversedRoute: rutaSeleccionada.trajectory,
                showStartMarker: true,
                showEndMarker: rutaSeleccionada.trajectory.length > 1,
              ),
            ),

          if (_isLoadingRoute)
            Positioned(top: size.height * 0.25, left: 0, right: 0, child: const Center(child: CircularProgressIndicator(color: Color(0xFF2864FF)))),

          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMapOverlayButton(icon: Icons.arrow_back, onTap: () {
                      context.read<TrackingProvider>().routeIsSelected = false;
                      Navigator.pop(context);
                    }),
                    _buildMapOverlayButton(
                      icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                      iconColor: _isFavorite ? Colors.pink : Colors.white,
                      onTap: () => setState(() => _isFavorite = !_isFavorite),
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16, top: size.height * 0.57,
            child: _buildMapOverlayButton(icon: Icons.my_location, iconColor: Colors.black87, bgColor: Colors.white, onTap: () {
              if (rutaSeleccionada.trajectory.isNotEmpty) _mapController.move(rutaSeleccionada.trajectory.first, 16.0);
            }),
          ),

          if (!_isLoadingRoute)
            Positioned(
              top: size.height * 0.65, left: 0, right: 0, bottom: 0,
              child: Container(
                decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))]),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(rutaSeleccionada.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF0B233B)), overflow: TextOverflow.ellipsis, maxLines: 2),
                                  const SizedBox(height: 8),
                                  Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Colors.blueAccent), const SizedBox(width: 4), Text(rutaSeleccionada.location, style: TextStyle(color: Colors.grey.shade600, fontSize: 14))]),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildDifficultyBadge(rutaSeleccionada.distance, rutaSeleccionada.elevationGain),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            _buildMetricCard(l10n.distance, rutaSeleccionada.distance.toString(), 'km'),
                            const SizedBox(width: 12),
                            _buildMetricCard(l10n.altitude, rutaSeleccionada.elevationGain.toString(), 'm'),
                            const SizedBox(width: 12),
                            FutureBuilder<User?>(
                              future: UserService().getUserProfile(rutaSeleccionada.createdBy),
                              builder: (context, snapshot) {
                                String nombreCreador;
                                if (snapshot.connectionState == ConnectionState.waiting) { nombreCreador = l10n.loading; }
                                else if (snapshot.hasError || snapshot.data == null) { nombreCreador = l10n.unknown; }
                                else { nombreCreador = snapshot.data!.nom; }
                                return _buildMetricCard(l10n.createdBy, nombreCreador, '');
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, AppRouter.runningRoute),
                            icon: const Icon(Icons.touch_app),
                            label: Text(l10n.selectRoute, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[700], foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapOverlayButton({required IconData icon, required VoidCallback onTap, Color iconColor = Colors.white, Color bgColor = Colors.black26}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle, boxShadow: [if (bgColor == Colors.white) BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade100, width: 2)),
        child: Column(
          children: [
            Text(title, style: TextStyle(color: Colors.blueAccent.shade200, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            RichText(text: TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B)), children: [const TextSpan(text: ' '), TextSpan(text: unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.normal))])),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(double distance, double elevationGain) {
    final l10n = AppLocalizations.of(context)!;
    String label;
    Color color;

    if (distance < 5 && elevationGain < 100) { label = l10n.easy; color = const Color(0xFF22C55E); }
    else if (distance < 10 && elevationGain < 300) { label = l10n.moderate; color = const Color(0xFFEAB308); }
    else if (distance < 20 && elevationGain < 600) { label = l10n.hard; color = const Color(0xFFF97316); }
    else { label = l10n.veryHard; color = const Color(0xFFEF4444); }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: color.withValues(alpha: 0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.fitness_center, color: color, size: 16), const SizedBox(width: 6), Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.bold))]),
    );
  }
}