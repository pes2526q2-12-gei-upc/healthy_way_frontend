import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/core/router/app_router.dart';
import '../../../shared/widgets/custom_bottom_nav_bar.dart';

class RouteViewScreen extends StatefulWidget {
  const RouteViewScreen({super.key});

  @override
  State<RouteViewScreen> createState() => _RouteViewScreenState();
}

class _RouteViewScreenState extends State<RouteViewScreen> {
  // Estado para el botón de favorito
  bool _isFavorite = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. FONDO DEL MAPA (A prueba de fallos para Web)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Container(
              color: const Color(0xFFE0E5EC),
              // Reemplazado Image.network por un Icono para evitar bloqueos por CORS en Flutter Web
              child: const Center(
                child: Icon(Icons.map, size: 120, color: Colors.black12),
              ),
            ),
          ),

          // Ruta dibujada simulada
          Positioned(
            top: size.height * 0.2,
            left: size.width * 0.1,
            child: Transform.rotate(
              angle: -0.2,
              child: Container(
                width: 200,
                height: 4,
                color: Colors.blueAccent,
              ),
            ),
          ),

          // 2. BOTONES SUPERIORES SUPERPUESTOS AL MAPA
          // Aseguramos el SafeArea dentro de un Positioned para no romper el Stack
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

          // Botones inferiores del mapa
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
                  onTap: () {},
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
                    // Manija de arrastre
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

                    // Título y Etiquetas
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

                    // Fila de Métricas
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
                    const SizedBox(height: 24),

                    // Tarjeta Calidad del Aire
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue.shade50, width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.air, color: Colors.blueAccent, size: 20),
                                    const SizedBox(width: 8),
                                    const Text(
                                      "Qualitat de l'aire",
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0B233B)),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                      const SizedBox(width: 4),
                                      Text('Excel·lent', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Índex AQI previst', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                RichText(
                                  text: TextSpan(
                                    text: '25',
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Color(0xFF0B233B)),
                                    children: [
                                      TextSpan(text: ' / 500', style: TextStyle(fontSize: 14, color: Colors.grey.shade500, fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('Pòl·len: Baix', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                    Text('Partícules: Mínim', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Barra de progreso nativa y segura
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: 0.15, // Porcentaje visual (aprox. 25/200)
                                minHeight: 6,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Perfil de Elevación
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.terrain, color: Colors.blueAccent),
                              SizedBox(width: 8),
                              Text("Perfil d'Elevació", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0B233B))),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            height: 100,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Max\n450m', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),

      // 4. BOTTOM NAVIGATION BAR
      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 1),
    );
  }

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

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? Colors.blueAccent : Colors.grey.shade400, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.blueAccent : Colors.grey.shade500,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}