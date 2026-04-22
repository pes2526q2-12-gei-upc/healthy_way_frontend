import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/providers/tracking_provider.dart';
import '../../../shared/widgets/custom_map_widget.dart';
import '../../../shared/models/RouteModel.dart';
import '../../../core/services/route_service.dart';

import '../../../shared/providers/Auth_provider.dart';
import '../../../shared/models/Activity.dart';
import '../../../core/services/activity_service.dart';


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
    final distance = provider.distanceDouble;
    final elevation = provider.elevation;
    final location = provider.routeIsSelected ? provider.rutaSeleccionada.location : provider.placeName;

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
                        onPressed: () async {
                          if (route.isEmpty) { // <-- Cambia esto por el nombre de tu variable real
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No hay ninguna ruta para guardar')),
                            );
                            return;
                          }
                          if (_formKey.currentState?.validate() ?? false) {
                            final nuevaRuta = RouteModel(
                              id: 10.toString(),
                              name: _nameCtrl.text.trim(),
                              trajectory: route,
                              startPoint: route.first,
                              endPoint: route.last,
                              distance: double.parse((distance/1000).toStringAsFixed(2)), // <-- Redondear a 2 decimales
                              createdBy: context.read<AuthProvider>().currentUser!.userId,
                              isPrivate: !_isPublic,
                              location: location,
                              createdAt: DateTime.now(),
                              elevation_gain: elevation,
                              altitude: elevation,
                              modality: provider.getModality(),
                            );

                            // Creamos la actividad con la ruta y luego guardamos la ruta en el servidor
                            final newActivity = Activity(
                              distance: double.parse((distance/1000).toStringAsFixed(2)),
                              startTime: provider.startTime,
                              endTime: DateTime.now(),
                              modality: provider.modality,
                              userId: context.read<AuthProvider>().currentUser!.userId,
                              pace: double.parse(provider.pace.replaceAll(':', '.')),
                              createRoute: true,
                              route: nuevaRuta,
                            );

                            await ActivityService().createActivity(newActivity);
                            //await RouteService().createRoute(nuevaRuta);
                            provider.reset();
                            provider.routeIsSelected = false;
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
                          'Guardar ruta',
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