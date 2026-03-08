import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
// Ajusta estas rutas según tus carpetas:
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../shared/widgets/custom_filter_chip.dart';
import '../../../core/router/app_router.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // --- ESTADOS DE LA PANTALLA ---
  bool isZonesCapturedSelected = true; // Controla el botón de zonas
  bool isRunningMode = true; // true = Correr, false = Bici

  // Controlador del mapa (para mover la cámara en el futuro)
  final MapController _mapController = MapController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Usamos el índice 1 (Mapes) para que se marque en azul abajo
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),

      body: Stack(
        children: [
          // 1. EL MAPA DE FONDO (OSM)
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: LatLng(41.3851, 2.1734), // Coordenadas iniciales (ej. Barcelona)
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                // Esta URL es la de OpenStreetMap por defecto
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.tuapp.nombre', // ¡Cámbialo por el tuyo en el futuro!
              ),
            ],
          ),

          // 2. INTERFAZ SUPERIOR (Buscador, Planificar y Filtros)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fila del Buscador y Botón Planificar
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
                        onPressed: () {
                          // TODO: Navegar a la vista de planificar en el futuro
                        },
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

                  // Fila de Filtros Reutilizables
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
                        // Aquí en el futuro puedes añadir más CustomFilterChip
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BOTONES FLOTANTES DE LA DERECHA
          Positioned(
            right: 16,
            bottom: 32, // Espacio para que no choque con la barra inferior
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Botón Toggle: Correr / Bici
                _FloatingMapButton(
                  icon: isRunningMode ? Icons.directions_run : Icons.directions_bike,
                  color: Colors.blue[700]!,
                  iconColor: Colors.white,
                  onTap: () {
                    setState(() {
                      isRunningMode = !isRunningMode; // Cambia entre los dos estados
                    });
                  },
                ),
                const SizedBox(height: 12),

                // Botón "E" -> Navega a la vista de tu compañero
                _FloatingMapButton(
                  icon: Icons.explicit, // Icono "E" temporal
                  color: Colors.white,
                  iconColor: Colors.black87,
                  onTap: () {
                    // Viaja a la pantalla Explore (la de tu compañero)
                    Navigator.pushNamed(context, AppRouter.exploreRoute);
                  },
                ),
                const SizedBox(height: 12),

                // Botón Localización
                _FloatingMapButton(
                  icon: Icons.my_location,
                  color: Colors.white,
                  iconColor: Colors.black87,
                  onTap: () {
                    // TODO: Centrar el mapa en la ubicación del usuario
                  },
                ),
                const SizedBox(height: 12),

                // Botón Capas
                _FloatingMapButton(
                  icon: Icons.layers_outlined,
                  color: Colors.white,
                  iconColor: Colors.black87,
                  onTap: () {
                    // TODO: Abrir menú de capas
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Widget privado para hacer los botones circulares flotantes iguales
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