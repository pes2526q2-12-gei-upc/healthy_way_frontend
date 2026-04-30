import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:healthy_way_frontend/core/router/app_router.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/widgets/custom_map_widget.dart';
import '../../../shared/providers/tracking_provider.dart';

import '../../../core/services/activity_service.dart';
import '../../../shared/models/activity.dart';
import '../../../shared/models/route_model.dart';

class ResultsRouteScreen extends StatelessWidget {
  const ResultsRouteScreen({super.key});

  // Métod helper para crear las columnas de estadísticas limpiamente
  Widget _buildStatColumn(String title, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = context.read<TrackingProvider>();
    final fullRoute = trackingProvider.traversedRoute;

    // 1. BOUNDS Y ZOOM DINÁMICO (Solo si hay recorrido real: 2+ puntos)
    LatLngBounds? routeBounds;
    if (fullRoute.length > 1) {
      routeBounds = LatLngBounds.fromPoints(fullRoute);
    }

    // 2. CENTRO EXACTO (Si hay 1 o más puntos, nos centramos en el último. Si hay 0, L'Hospitalet)
    final center = fullRoute.isNotEmpty
        ? fullRoute.last
        : const LatLng(41.3596, 2.1002);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Resultats',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double mapHeight = (constraints.maxHeight * 0.45).clamp(220.0, 520.0);

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // --- 1. MAP ---
                        Container(
                          height: mapHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha((0.06 * 255).round()),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CustomMapWidget(
                              mapController: MapController(),
                              initialCenter: center,
                              initialZoom: 16.0,
                              initialCameraFit: routeBounds != null
                                  ? CameraFit.bounds(
                                bounds: routeBounds,
                                padding: const EdgeInsets.all(40.0),
                                maxZoom: 18.0, // <-- Límite de zoom
                              )
                                  : null,
                              traversedRoute: fullRoute,
                              showStartMarker: true,
                              showEndMarker: fullRoute.length > 1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- 2. STATS CARD 1 ---
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatColumn('DISTÀNCIA', '${trackingProvider.distance} km'),
                                Container(width: 1, height: 48, color: Colors.grey.shade300),
                                _buildStatColumn('TEMPS', trackingProvider.formatElapsed()),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- 3. STATS CARD 2 ---
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _buildStatColumn('RITME', trackingProvider.pace),
                                Container(width: 1, height: 48, color: Colors.grey.shade300),
                                _buildStatColumn('KCAL', trackingProvider.calories),
                                Container(width: 1, height: 48, color: Colors.grey.shade300),
                                _buildStatColumn('DESNIVELL', '${trackingProvider.elevation} m'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- 4. BOTONES ---
                        ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(context, AppRouter.saveFormRoute);
                            if (result == true && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ruta guardada')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2864FF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Guardar ruta', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        // Espacio entre botones
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () async {
                            // Creamos una actividad con todos los datos pero sin ruta, ya que created_route tiene que ser false para que no intente guardar la ruta
                            final activity = Activity(
                              distance: double.parse((trackingProvider.distanceDouble/1000).toStringAsFixed(2)),
                              startTime: trackingProvider.startTime,
                              endTime: DateTime.now(),
                              modality: trackingProvider.modality,
                              pace: double.parse(trackingProvider.pace.replaceAll(':', '.').replaceAll('>', '')),
                              userId: context.read<AuthProvider>().currentUser!.userId,
                              createRoute: false,
                              route: RouteModel(
                                id: '99',
                                name: 'noCrearRuta',
                                distance: 1.0,
                                isPrivate: false,
                                createdBy: 99,
                                createdAt: DateTime.now(),
                                trajectory: [],
                                startPoint: const LatLng(0, 0),
                                endPoint: const LatLng(0, 0),
                                location: 'string',
                                altitude: '1',
                                elevationGain: '1',
                              ),
                            );

                            // Guardamos la actividad sin ruta
                            await ActivityService().createActivity(activity);
                            if (!context.mounted) return;

                            trackingProvider.reset();
                            trackingProvider.routeIsSelected = false;
                            Navigator.pushNamedAndRemoveUntil(context, AppRouter.homeRoute, (r) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Sortir sense guardar', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
