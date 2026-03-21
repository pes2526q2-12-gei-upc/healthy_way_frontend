import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/core/router/app_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../shared/widgets/custom_map_widget.dart';

class ResultsRouteScreen extends StatefulWidget {
  // Opcional: se pueden pasar stats y ruta a través de los argumentos de la ruta.
  const ResultsRouteScreen({super.key});

  @override
  State<ResultsRouteScreen> createState() => _ResultsRouteScreenState();
}

class _ResultsRouteScreenState extends State<ResultsRouteScreen> {
  final MapController _mapController = MapController();

  // Datos por defecto (si no se pasan argumentos)
  List<LatLng> _fullRoute = [
    const LatLng(41.4285, 2.1448),
    const LatLng(41.4277, 2.1463),
    const LatLng(41.4265, 2.1453),
    const LatLng(41.4255, 2.1472),
    const LatLng(41.4245, 2.1464),
    const LatLng(41.4238, 2.1476),
  ];

  String _distance = '2.4';
  String _pace = '5:30';
  String _time = '00:14:32';
  String _calories = '210';
  String _elevation = '45';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Intentamos leer argumentos si fueron pasados por Navigator
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args != null && args is Map<String, dynamic>) {
      if (args['route'] is List<LatLng>) {
        // si se pasó la ruta directamente
        // ignore: avoid_dynamic_calls
        final List<LatLng> provided = args['route'];
        if (provided.isNotEmpty) {
          // Reemplazamos la ruta por la proporcionada
          _fullRoute = List<LatLng>.from(provided);
        }
      }

      // Leer stats si vienen
      if (args['distance'] != null) _distance = args['distance'].toString();
      if (args['pace'] != null) _pace = args['pace'].toString();
      if (args['time'] != null) _time = args['time'].toString();
      if (args['calories'] != null) _calories = args['calories'].toString();
      if (args['elevation'] != null) _elevation = args['elevation'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng center = _fullRoute.isNotEmpty ? _fullRoute[_fullRoute.length ~/ 2] : const LatLng(41.4285, 2.1448);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Resultats', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculamos alturas relativas para que el mapa ocupe buena parte de la pantalla
            final double maxH = constraints.maxHeight;
            final double mapHeight = (maxH * 0.45).clamp(220.0, 520.0);
            final content = Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Caja con mapa (ahora dinámica en función de la pantalla)
                  Container(
                    height: mapHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha((0.06 * 255).round()), blurRadius: 12, offset: const Offset(0, 6)),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: CustomMapWidget(
                        mapController: _mapController,
                        initialCenter: center,
                        initialZoom: 15.5,
                        polylines: [
                          Polyline(points: _fullRoute, strokeWidth: 6.0, color: const Color(0xFF2864FF)),
                        ],
                        markers: [
                          Marker(
                            point: _fullRoute.first,
                            width: 14,
                            height: 14,
                            child: Container(decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3))),
                          ),
                          Marker(
                            point: _fullRoute.last,
                            width: 14,
                            height: 14,
                            child: Container(decoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3))),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Stats agrupadas en Cards (cada fila en una Card, con divisores verticales)
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // DISTANCIA
                          Expanded(
                            child: Column(
                              children: [
                                Text('DISTÀNCIA', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('$_distance km', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 48, color: Colors.grey.shade300),
                          // TEMPS
                          Expanded(
                            child: Column(
                              children: [
                                Text('TEMPS', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(_time, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // RITME
                          Expanded(
                            child: Column(
                              children: [
                                Text('RITME', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text(_pace, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 48, color: Colors.grey.shade300),
                          // KCAL
                          Expanded(
                            child: Column(
                              children: [
                                Text('KCAL', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('$_calories', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                              ],
                            ),
                          ),
                          Container(width: 1, height: 48, color: Colors.grey.shade300),
                          // DESNIVELL
                          Expanded(
                            child: Column(
                              children: [
                                Text('DESNIVELL', style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text('$_elevation m', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B))),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SaveRouteFormScreen(
                            route: _fullRoute,
                            distance: _distance,
                            pace: _pace,
                            time: _time,
                            elevation: _elevation,
                            calories: _calories,
                          ),
                        ),
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
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRouter.homeRoute, (r) => false),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0x66666666), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    child: const Text('Tornar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            );

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(child: content),
              ),
            );
          },
        ),
      ),
    );
  }
}

// Formulario para guardar la ruta
class SaveRouteFormScreen extends StatefulWidget {
  final List<LatLng>? route;
  final String? distance;
  final String? pace;
  final String? time;
  final String? elevation;
  final String? calories;

  const SaveRouteFormScreen({super.key, this.route, this.distance, this.pace, this.time, this.elevation, this.calories});

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
    final route = widget.route ?? [];
    final LatLng center = route.isNotEmpty
        ? route[route.length ~/ 2]
        : const LatLng(41.4285, 2.1448);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Guardar ruta', style: TextStyle(
            color: Colors.black87, fontWeight: FontWeight.bold)),
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
                // Mapa pequeño de preview (en formulario) - usar porcentaje de pantalla para ocupar más espacio
                Container(
                  height: (MediaQuery
                      .of(context)
                      .size
                      .height * 0.32).clamp(140.0, 380.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withAlpha((0.06 *
                        255).round()),
                        blurRadius: 10,
                        offset: const Offset(0, 6))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomMapWidget(
                      mapController: MapController(),
                      initialCenter: center,
                      initialZoom: 15.0,
                      polylines: [
                        if (route.isNotEmpty) Polyline(
                            points: route, strokeWidth: 5.0, color: const Color(
                            0xFF2864FF))
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _nameCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Nom de la ruta',
                            border: OutlineInputBorder()),
                        validator: (v) =>
                        (v == null || v
                            .trim()
                            .isEmpty) ? 'Introdueix un nom' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Text('Visibilitat:', style: TextStyle(
                              fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          ChoiceChip(
                            label: const Text('Pública'),
                            selected: _isPublic,
                            onSelected: (s) => setState(() => _isPublic = true),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Privada'),
                            selected: !_isPublic,
                            onSelected: (s) =>
                                setState(() =>
                            _isPublic = !s ? _isPublic : !_isPublic),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState?.validate() ?? false) {
                            // Aquí normalmente guardarías en la base de datos o backend
                            Navigator.pushNamedAndRemoveUntil(
                                context, AppRouter.homeRoute, (r) => false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF2864FF)),
                        child: const Text('Desar', style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white)),
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
