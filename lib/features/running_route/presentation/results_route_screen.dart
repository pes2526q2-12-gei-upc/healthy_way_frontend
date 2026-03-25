import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:healthy_way_frontend/core/router/app_router.dart';
import '../../../shared/widgets/custom_map_widget.dart';
import '../providers/tracking_provider.dart';

class ResultsRouteScreen extends StatelessWidget {
  const ResultsRouteScreen({super.key});

  // Método helper para crear las columnas de estadísticas limpiamente
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
                        // --- 1. MAPA ---
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
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SaveRouteFormScreen()),
                            );
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
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            trackingProvider.reset();
                            Navigator.pushNamedAndRemoveUntil(context, AppRouter.homeRoute, (r) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0x66666666),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Tornar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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

// ==========================================================
// --- FORMULARIO PARA GUARDAR RUTA (SaveRouteFormScreen) ---
// ==========================================================

class SaveRouteFormScreen extends StatefulWidget {
  const SaveRouteFormScreen({super.key});

  @override
  State<SaveRouteFormScreen> createState() => _SaveRouteFormScreenState();
}

class _SaveRouteFormScreenState extends State<SaveRouteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCtrl = TextEditingController();
  bool _isPublic = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<TrackingProvider>();
    final route = provider.traversedRoute;

    LatLngBounds? routeBounds;
    if (route.length > 1) {
      routeBounds = LatLngBounds.fromPoints(route);
    }
    final center = route.isNotEmpty
        ? route.last
        : const LatLng(41.3596, 2.1002);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'Guardar ruta',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- MAPA PEQUEÑO DE PREVIEW ---
                Container(
                  height: (MediaQuery.of(context).size.height * 0.32).clamp(140.0, 380.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.06 * 255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 6),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomMapWidget(
                      mapController: MapController(),
                      initialCenter: center,
                      initialZoom: 16.0,
                      initialCameraFit: routeBounds != null
                          ? CameraFit.bounds(
                        bounds: routeBounds,
                        padding: const EdgeInsets.all(20.0),
                        maxZoom: 18.0, // <-- Límite de zoom también aquí
                      )
                          : null,
                      traversedRoute: route,
                      showStartMarker: true,
                      showEndMarker: route.length > 1,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // --- FORMULARIO DE TEXTO ---
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nom de la ruta',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                        (value == null || value.trim().isEmpty) ? 'Introdueix un nom' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text(
                            'Visibilitat:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text('Pública'),
                            selected: _isPublic,
                            onSelected: (_) => setState(() => _isPublic = true),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Privada'),
                            selected: !_isPublic,
                            onSelected: (_) => setState(() => _isPublic = false),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            provider.reset();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRouter.homeRoute,
                                  (route) => false,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF2864FF),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Desar',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}