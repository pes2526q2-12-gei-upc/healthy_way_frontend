import 'dart:async';
import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/core/router/app_router.dart';


class RunningRouteScreen extends StatefulWidget {
  const RunningRouteScreen({super.key});

  @override
  State<RunningRouteScreen> createState() => _RunningRouteScreenState();
}

class _RunningRouteScreenState extends State<RunningRouteScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _startTimer();
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  void _toggleRunning() {
    setState(() {
      if (_stopwatch.isRunning) {
        _stopwatch.stop();
      } else {
        _stopwatch.start();
      }
    });
  }

  void _stopAll() {
    setState(() {
      _stopwatch.stop();
      _stopwatch.reset();
    });
  }

  String _formatElapsed(Duration d) {
    final hours = d.inHours.remainder(100);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    const darkTimerColor = Color(0xFF0B233B);
    final size = MediaQuery.of(context).size;
    const double smallBtnSize = 64;

    // Posición a 25% de la pantalla, centrada respecto al botón
    final double leftPos = size.width * 0.25 - smallBtnSize / 2;
    final double rightPos = size.width * 0.25 - smallBtnSize / 2;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            // Fondo superior restaurado pero con azul MAS FUERTE
            colors: [Color(0xFFE8F3FF), Color(0xFF90C2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                        ),
                      ),
                    ),
                    Text(
                      'RUTA EN MARXA',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900], // Revertido al color oscuro para que contraste
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),

              // Tarjeta superior (Ruta)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                                const SizedBox(width: 8),
                                Text('ENREGISTRANT', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
                              ],
                            ),
                            const Icon(Icons.terrain, color: Colors.blueAccent, size: 20),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text("Ruta Vall d'Hebron", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text('Barcelona, Horta', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Gráfico de barras
                        SizedBox(
                          height: 36,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(10, (i) {
                              final heights = [6, 12, 18, 26, 18, 14, 10, 20, 8, 16];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Container(
                                  width: 6,
                                  height: heights[i].toDouble(),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.8 - i * 0.05), borderRadius: BorderRadius.circular(3)),
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Espaciador dinámico
              SizedBox(height: size.height * 0.08),

              // Hoja blanca inferior principal
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      // Manija de arrastre (pull bar)
                      Container(width: 40, height: 4, decoration: const BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.all(Radius.circular(4)))),
                      const SizedBox(height: 24),

                      // TEMPS TOTAL + timer grande
                      Text('TEMPS TOTAL', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      const SizedBox(height: 4),
                      Text(
                        _formatElapsed(elapsed),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          color: darkTimerColor,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // DISTANCIA y QUALITAT AIRE
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Row(
                          children: [
                            // Distancia (ALTURA REDUCIDA)
                            Expanded(
                              child: Container(
                                height: 95, // Altura reducida de 115 a 95
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Padding ajustado
                                decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.pin_drop_outlined, color: Colors.blueAccent, size: 14), // Icono mas pequeño
                                        SizedBox(width: 4), // Espaciado mas corto
                                        Flexible(child: Text('DISTANCIA', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                    const Spacer(), // Empuja el texto hacia abajo
                                    const Text('0.0 km', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Texto mas pequeño
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Calidad del aire (ALTURA REDUCIDA)
                            Expanded(
                              child: Container(
                                height: 95, // Altura reducida de 115 a 95
                                decoration: BoxDecoration(
                                  color: Colors.greenAccent.shade400,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 3),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), // Padding ajustado
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuye los elementos
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.air, color: Colors.green, size: 14), // Icono mas pequeño
                                          SizedBox(width: 4), // Espaciado mas corto
                                          Flexible(child: Text('QUALITAT AIRE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('AQI 25', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                          const Text('Excel·lent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Texto mas pequeño
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Spacer superior aumentado para bajar la tarjeta
                      const Spacer(flex: 3), // Aumentado de flex:1 a flex:3 para empujar hacia abajo

                      // Métricas: RITME / KCAL / ALTITUD (BAJADA UN PELIN)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          elevation: 0,
                          color: const Color(0xFFF7F8FA),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 6),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _metricItem('RITME', '5:30', '/km'),
                                Container(width: 1, height: 34, color: Colors.grey.shade300),
                                _metricItem('KCAL', '010', ''),
                                Container(width: 1, height: 34, color: Colors.grey.shade300),
                                _metricItem('ALTITUD', '145', 'm'),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Spacer inferior reducido para dejar que las métricas bajen
                      const Spacer(flex: 2), // Mantenido o ajustado para equilibrar

                      // Controles inferiores
                      SizedBox(
                        height: 140,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Botón FINALITZAR
                            Positioned(
                              left: leftPos,
                              bottom: 24,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      _stopAll();
                                      Navigator.pushNamed(context, AppRouter.homeRoute);
                                    },
                                    child: Container(
                                      width: smallBtnSize,
                                      height: smallBtnSize,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0F2F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.square_outlined, color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('FINALITZAR', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                            // Botón MAPA
                            Positioned(
                              right: rightPos,
                              bottom: 24,
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRouter.routeMap),
                                    child: Container(
                                      width: smallBtnSize,
                                      height: smallBtnSize,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFF0F2F6),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.map_outlined, color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text('MAPA', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),

                            // Botón central Play/Pause
                            Positioned(
                              bottom: 34,
                              child: GestureDetector(
                                onTap: _toggleRunning,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 6),
                                    boxShadow: [
                                      BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 18, spreadRadius: 2),
                                    ],
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.blue[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _stopwatch.isRunning ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 38,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para las métricas secundarias inferiores
  Widget _metricItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
            children: [
              TextSpan(text: unit, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
