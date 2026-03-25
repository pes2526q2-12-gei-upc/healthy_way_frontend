import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:healthy_way_frontend/core/router/app_router.dart';
import '../../../shared/widgets/custom_map_widget.dart';

 import '../../../shared/providers/tracking_provider.dart';

class ResultsRouteScreen extends StatelessWidget {
  const ResultsRouteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Leemos los datos finales del Provider
    final trackingProvider = context.read<TrackingProvider>();
    final fullRoute = trackingProvider.traversedRoute;

    // Calculamos el centro para la cámara del mapa
    final center = fullRoute.isNotEmpty
        ? fullRoute[fullRoute.length ~/ 2]
        : const LatLng(41.4285, 2.1448);

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
                              initialZoom: 15.5,
                              polylines: [
                                Polyline(
                                  points: fullRoute,
                                  strokeWidth: 6.0,
                                  color: const Color(0xFF2864FF),
                                ),
                              ],
                              markers: fullRoute.isNotEmpty
                                  ? [
                                Marker(
                                  point: fullRoute.first,
                                  width: 14,
                                  height: 14,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                  ),
                                ),
                                Marker(
                                  point: fullRoute.last,
                                  width: 14,
                                  height: 14,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 3),
                                    ),
                                  ),
                                ),
                              ]
                                  : [],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- 2. STATS CARD 1 (Distancia y Tiempo) ---
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('DISTÀNCIA', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('${trackingProvider.distance} km', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 48, color: Colors.grey.shade300),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('TEMPS', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(trackingProvider.formatElapsed(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // --- 3. STATS CARD 2 (Ritmo, KCAL, Elevación) ---
                        Card(
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('RITME', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(trackingProvider.pace, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 48, color: Colors.grey.shade300),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('KCAL', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text(trackingProvider.calories, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                                    ],
                                  ),
                                ),
                                Container(width: 1, height: 48, color: Colors.grey.shade300),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Text('DESNIVELL', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 6),
                                      Text('${trackingProvider.elevation} m', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                                    ],
                                  ),
                                ),
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
                            if (result == true) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ruta guardada')));
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
    // Leemos el provider para dibujar el mapa pequeño
    final provider = context.read<TrackingProvider>();
    final route = provider.traversedRoute;

    // Calculamos el centro de la ruta o ponemos uno por defecto
    final center = route.isNotEmpty
        ? route[route.length ~/ 2]
        : const LatLng(41.4285, 2.1448);

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
                      initialZoom: 15.0,
                      polylines: [
                        if (route.isNotEmpty)
                          Polyline(
                            points: route,
                            strokeWidth: 5.0,
                            color: const Color(0xFF2864FF),
                          ),
                      ],
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Introdueix un nom';
                          }
                          return null;
                        },
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
                            onSelected: (selected) {
                              setState(() => _isPublic = true);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Privada'),
                            selected: !_isPublic,
                            onSelected: (selected) {
                              setState(() {
                                // Si seleccionan privada, _isPublic pasa a false
                                _isPublic = false;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Limpiamos la ruta de la memoria al guardar
                            provider.reset();
                            // Volvemos a la pantalla de inicio
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