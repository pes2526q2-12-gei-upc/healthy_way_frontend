import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/route_model.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/location_provider.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';
import '../../../core/services/route_service.dart';
import '../../../core/services/location_service.dart';

class HomePage extends StatefulWidget {

  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePage(); // El "puente"
}

class _HomePage extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    iniciaGPS();
  }

  Future<void> iniciaGPS() async {
    await LocationService().startTracking();

    if (!mounted) return;

    context.read<LocationProvider>().fetchLocationName();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9), // Fondo gris clarito
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 0),

      // 2. CUERPO DE LA PANTALLA
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABECERA AZUL ---
            Container(
              padding: const EdgeInsets.only(top: 60, left: 24, right: 24, bottom: 32),
              decoration: BoxDecoration(
                color: Colors.blue[700],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  // Perfil y Notificaciones
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Benvingut de nou,', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              Text(context.watch<AuthProvider>().currentUser!.nom, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Tarjeta Calidad del Aire
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.air, color: Colors.greenAccent, size: 32),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("QUALITAT DE L'AIRE", style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold)),
                                Row(
                                  children: [
                                    const Text('Excel·lent ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('(AQI 25)', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Barcelona', style: TextStyle(color: Colors.white, fontSize: 12)),
                            Text('Actualitzat ara', style: TextStyle(color: Colors.white70, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO PRINCIPAL (Blanco/Gris) ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta "La Conquesta"
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flag_outlined, color: Colors.blue[800]),
                                const SizedBox(width: 8),
                                Text('La Conquesta', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('3r', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                                const Text('Posició global', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                        const Text('Equip "Los Gambas"', style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Territori capturat (Setmana)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            Text('65%', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue[800])),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: 0.65,
                            minHeight: 12,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Text('Punts totals', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('12.4k', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                              ],
                            ),
                            Container(width: 1, height: 30, color: Colors.grey[300]),
                            const Column(
                              children: [
                                Text('Arees noves', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('+4', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Botón "Cerca una ruta" (Texto pequeño eliminado según petición)
                  InkWell(
                    onTap: () {
                      // AQUÍ: Acción para buscar ruta
                    },
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.white.withValues(alpha: 0.2),
                            child: const Icon(Icons.search, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Cerca una ruta\nsaludable',
                              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sección "Rutes Recomanades"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Rutes Recomanades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue[900])),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Veure tot'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Coger rutas del route service y mostrarlas. Si no hay rutas, mostrar mensaje de "No hay rutas recomendadas disponibles"
                  FutureBuilder<List<RouteModel>>(
                    future: RouteService().getRecommendedRoutes(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error al cargar las rutas recomendadas'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No hay rutas recomendadas disponibles'));
                      } else {
                        final routes = snapshot.data!;
                        return Column(
                          children: routes.map((route) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: _RouteCard(
                              title: route.name,
                              distance: '${route.distance} km',
                              /*
                              time: '${route.estimatedTime} min',
                              badgeText: route.difficulty.toUpperCase(),
                              badgeColor: route.difficulty == 'fàcil' ? Colors.green : route.difficulty == 'mitjà' ? Colors.orange : Colors.red,
                              teamControl: '${route.teamControl}% control',*/
                              // Placeholder, ya que el backend no devuelve el tiempo estimado
                              time: '45 min',
                              badgeText: 'FÀCIL',
                              badgeColor: Colors.green,
                              teamControl: '75% control',
                            ),
                          )).toList(),
                        );
                      }
                    },
                  ),

                  // Espacio al final para que no tape la barra inferior al hacer scroll
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS AUXILIARES ---

class _RouteCard extends StatelessWidget {
  final String title;
  final String distance;
  final String time;
  final String badgeText;
  final Color badgeColor;
  final String teamControl;

  const _RouteCard({
    required this.title,
    required this.distance,
    required this.time,
    required this.badgeText,
    required this.badgeColor,
    required this.teamControl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          // Placeholder para la imagen de la ruta
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: Colors.grey[300],
              child: const Icon(Icons.landscape, color: Colors.grey),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900]), overflow: TextOverflow.ellipsis)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                      child: Text(badgeText, style: TextStyle(color: badgeColor, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(distance, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 12),
                    const Icon(Icons.schedule, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(time, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Colors.blue[700]),
                    const SizedBox(width: 4),
                    Text(teamControl, style: TextStyle(fontSize: 12, color: Colors.blue[700], fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}