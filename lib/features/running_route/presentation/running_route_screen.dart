import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:healthy_way_frontend/core/router/app_router.dart';
import 'results_route_screen.dart';
import '../../../shared/providers/tracking_provider.dart';

class RunningRouteScreen extends StatefulWidget {
  const RunningRouteScreen({super.key});

  @override
  State<RunningRouteScreen> createState() => _RunningRouteScreenState();
}

class _RunningRouteScreenState extends State<RunningRouteScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<TrackingProvider>();
      provider.reset();
      provider.startRun();
    });
  }

  @override
  Widget build(BuildContext context) {
    final trackingProvider = context.watch<TrackingProvider>();

    // --- NUEVO: ESCUCHADOR DE AUTO-FINALIZACIÓN ---
    if (trackingProvider.isFinished) {
      // Solo navegamos si ESTA pantalla es la que está visible en primer plano
      if (ModalRoute.of(context)?.isCurrent == true) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Usamos pushAndRemoveUntil para limpiar la pila de pantallas (evita botón "atrás" raro)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const ResultsRouteScreen()),
                (route) => route.isFirst, // Mantiene solo el Home debajo
          );
        });
      }
    }

    final size = MediaQuery.of(context).size;
    const darkTimerColor = Color(0xFF0B233B);
    const double smallBtnSize = 64;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F3FF), Color(0xFF90C2FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
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
                          width: 36, height: 36,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                        ),
                      ),
                    ),
                    Text('RUTA EN MARXA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey[900], letterSpacing: 0.6)),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  color: Colors.white, elevation: 0,
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
                                Text(trackingProvider.isRunning ? 'ENREGISTRANT' : 'PAUSAT', style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 12)),
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
                        SizedBox(
                          height: 36,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: List.generate(10, (i) {
                              final heights = [6, 12, 18, 26, 18, 14, 10, 20, 8, 16];
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                child: Container(
                                  width: 6, height: heights[i].toDouble(),
                                  decoration: BoxDecoration(color: Colors.blueAccent.withAlpha(((0.8 - i * 0.05).clamp(0.0, 1.0) * 255).round()), borderRadius: BorderRadius.circular(3)),
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

              SizedBox(height: size.height * 0.08),

              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                  child: Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              children: [
                                const SizedBox(height: 12),
                                Container(width: 40, height: 4, decoration: const BoxDecoration(color: Color(0xFFE0E0E0), borderRadius: BorderRadius.all(Radius.circular(4)))),
                                const SizedBox(height: 24),

                                Text('TEMPS TOTAL', style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                                const SizedBox(height: 4),
                                Text(
                                  trackingProvider.formatElapsed(),
                                  style: const TextStyle(fontSize: 72, fontWeight: FontWeight.w900, letterSpacing: 2, color: darkTimerColor),
                                ),
                                const SizedBox(height: 24),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 95, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                          decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(children: const [Icon(Icons.pin_drop_outlined, color: Colors.blueAccent, size: 14), SizedBox(width: 4), Flexible(child: Text('DISTANCIA', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
                                              const Spacer(),
                                              Text('${trackingProvider.distance} km', style: TextStyle(fontSize: 16, color: Colors.blueAccent.shade700, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Container(
                                          height: 95, decoration: BoxDecoration(color: Colors.greenAccent.shade400, borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(horizontal: 3),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(children: const [Icon(Icons.air, color: Colors.green, size: 14), SizedBox(width: 4), Flexible(child: Text('QUALITAT AIRE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis))]),
                                                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('AQI 25', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)), const Text('Excel·lent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))])
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 32),

                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  child: Card(
                                    elevation: 0, color: const Color(0xFFF7F8FA), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 6),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                                        children: [
                                          _metricItem('RITME', trackingProvider.pace, '/km'),
                                          Container(width: 1, height: 34, color: Colors.grey.shade300),
                                          _metricItem('KCAL', trackingProvider.calories, 'kcal'),
                                          Container(width: 1, height: 34, color: Colors.grey.shade300),
                                          _metricItem('ALTITUD', trackingProvider.elevation, 'm'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // Finalización MANUAL
                                      context.read<TrackingProvider>().stopRun();
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(builder: (_) => const ResultsRouteScreen()),
                                      );
                                    },
                                    child: Container(width: smallBtnSize, height: smallBtnSize, decoration: const BoxDecoration(color: Color(0xFFF0F2F6), shape: BoxShape.circle), child: const Icon(Icons.stop, color: Colors.black54)),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('FINALITZAR', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, -10),
                                    child: GestureDetector(
                                      onTap: () => context.read<TrackingProvider>().toggleRun(),
                                      child: Container(
                                        width: 82, height: 82,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 6),
                                          boxShadow: [BoxShadow(color: Colors.blue.withAlpha((0.3 * 255).round()), blurRadius: 14, spreadRadius: 2)],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(color: Colors.blue[700], shape: BoxShape.circle),
                                          child: Icon(trackingProvider.isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6), const SizedBox(height: 6),
                                ],
                              ),
                              const SizedBox(width: 24),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRouter.routeMap),
                                    child: Container(width: smallBtnSize, height: smallBtnSize, decoration: const BoxDecoration(color: Color(0xFFF0F2F6), shape: BoxShape.circle), child: const Icon(Icons.map_outlined, color: Colors.black54)),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('MAPA', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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

  Widget _metricItem(String title, String value, String unit) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        RichText(text: TextSpan(text: value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black), children: [TextSpan(text: unit, style: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12, color: Colors.grey))])),
      ],
    );
  }
}