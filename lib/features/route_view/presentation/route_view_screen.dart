import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:healthy_way_frontend/core/router/app_router.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_map_widget.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({super.key});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  bool _isFavorite = false;
  final MapController _mapController = MapController();

  List<LatLng> _routePoints = [
    const LatLng(41.4285, 2.1448),
    const LatLng(41.4238, 2.1476),
  ];

  bool _isLoadingRoute = true;

  @override
  void initState() {
    super.initState();
    _fetchRealRoute();
  }

  Future<void> _fetchRealRoute() async {
    const String apiKey = 'TU_API_KEY_AQUI';
    final startCoords = '2.1448,41.4285';
    final endCoords = '2.1476,41.4238';

    final url = 'https://api.openrouteservice.org/v2/directions/foot-walking?api_key=$apiKey&start=$startCoords&end=$endCoords';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List dynamicCoords = data['features'][0]['geometry']['coordinates'];

        final List<LatLng> realPath = dynamicCoords
            .map((coord) => LatLng(coord[1], coord[0]))
            .toList();

        setState(() {
          _routePoints = realPath;
          _isLoadingRoute = false;
        });
      } else {
        setState(() => _isLoadingRoute = false);
      }
    } catch (e) {
      setState(() => _isLoadingRoute = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. EL MAPA COMPARTIDO
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: CustomMapWidget(
              mapController: _mapController,
              initialCenter: const LatLng(41.4260, 2.1460),
              polylines: [
                Polyline(
                  points: _routePoints,
                  strokeWidth: 5.0,
                  color: _isLoadingRoute ? Colors.grey : const Color(0xFF2864FF),
                ),
              ],
              markers: [
                Marker(
                  point: _routePoints.first,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2864FF), width: 4),
                    ),
                  ),
                ),
                Marker(
                  point: _routePoints.last,
                  width: 20,
                  height: 20,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF2864FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (_isLoadingRoute)
            Positioned(
              top: size.height * 0.25,
              left: 0,
              right: 0,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2864FF)),
              ),
            ),

          // 2. BOTONES SUPERIORES SUPERPUESTOS AL MAPA
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMapOverlayButton(
                      icon: Icons.arrow_back,
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.exploreRoute);
                      },
                    ),
                    Row(
                      children: [
                        _buildMapOverlayButton(
                          icon: _isFavorite ? Icons.favorite : Icons.favorite_border,
                          iconColor: _isFavorite ? Colors.pink : Colors.white,
                          onTap: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildMapOverlayButton(
                          icon: Icons.share_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            top: size.height * 0.3,
            child: Column(
              children: [
                _buildMapOverlayButton(
                  icon: Icons.layers_outlined,
                  iconColor: Colors.blueAccent,
                  bgColor: Colors.white,
                  onTap: () {},
                ),
                const SizedBox(height: 12),
                _buildMapOverlayButton(
                  icon: Icons.my_location,
                  iconColor: Colors.blueAccent,
                  bgColor: Colors.white,
                  onTap: () {
                    _mapController.move(const LatLng(41.4260, 2.1460), 15.5);
                  },
                ),
              ],
            ),
          ),

          // 3. PANEL BLANCO INFERIOR (Detalles de la ruta)
          Positioned(
            top: size.height * 0.42,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
                  ]
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Ruta Vall d'Hebron",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0B233B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.blueAccent),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Barcelona, Horta',
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  'Mitjana',
                                  style: TextStyle(
                                    color: Colors.blue.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Text('4.8', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(width: 4),
                                  Icon(Icons.star, color: Colors.amber.shade400, size: 18),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          _buildMetricCard('DISTANCIA', '5.2', 'km'),
                          const SizedBox(width: 12),
                          _buildMetricCard('TEMPS', '35', 'm'),
                          const SizedBox(width: 12),
                          _buildMetricCard('CALORIES', '520', 'kcal'),
                        ],
                      ),
                    ),
                    // ... (El resto de tus tarjetas de aire y elevación se mantienen igual)
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

  // BOTÓN LOCAL MANTENIDO
  Widget _buildMapOverlayButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = Colors.white,
    Color bgColor = Colors.black26,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          boxShadow: [
            if (bgColor == Colors.white)
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2))
          ],
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, String unit) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100, width: 2),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.blueAccent.shade200, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0B233B)),
                children: [
                  const TextSpan(text: ' '),
                  TextSpan(text: unit, style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.normal)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}