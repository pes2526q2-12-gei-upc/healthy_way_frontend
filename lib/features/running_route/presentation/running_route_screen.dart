import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:healthy_way_frontend/core/router/app_router.dart';
import 'package:latlong2/latlong.dart';
import 'results_route_screen.dart';
import 'package:geolocator/geolocator.dart';

class RunningRouteScreen extends StatefulWidget {
  const RunningRouteScreen({super.key});

  @override
  State<RunningRouteScreen> createState() => _RunningRouteScreenState();
}

class _RunningRouteScreenState extends State<RunningRouteScreen> {
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  DateTime? _lastNotificationTime;

  // Ruta recogida durante el running
  List<Position> _collectedRoute = [];

  // Suscripción al stream de posición
  StreamSubscription<Position>? _subscription;

  // Stats de ejemplo (si tienes cálculos reales, actualízalos en tiempo real)
  String _distance = '0.0';
  double distanceDouble = 0.0;
  String _pace = '0:00';
  String _elevation = '0';
  String _calories = '0';

  void savePosition(Position newPos) {
    _collectedRoute.add(newPos);
  }

  LocationSettings getSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high, // GPS puro para máxima precisión
        distanceFilter: 5,               // Actualiza cada 5 metros
        intervalDuration: const Duration(seconds: 3), // O cada 3 segundos
        // IMPRESCINDIBLE para que no se pare al bloquear el móvil:
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Entrenamiento en curso",
          notificationText: "Tu ruta se está grabando...",
          enableWakeLock: true, // Evita que el procesador se duerma
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
        activityType: ActivityType.fitness, // Ayuda a iOS a optimizar el sensor para deporte
        showBackgroundLocationIndicator: true, // Barra azul arriba para que el usuario sepa que grabas
        pauseLocationUpdatesAutomatically: false, // Evita que iOS pare el GPS si te detienes en un semáforo
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      );
    }
  }

  Future<void> permissionsAndInit() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. ¿Está el GPS activado en los ajustes del móvil?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('El GPS está apagado. Necesitamos que enciendas el GPS para que puedas utilizar HealthyWay correctamente.');
      return;
    }

    // 2. ¿Tenemos permiso de la app?
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si no tiene, se lo pedimos ahora mismo
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print('El usuario ha denegado el permiso.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print('Permisos denegados para siempre. Debe ir a Ajustes.');
      return;
    }

    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      // Si sigue siendo whileInUse, avisamos que puede haber cortes
      if (permission == LocationPermission.whileInUse) {
        print("Aviso: La ruta podría detenerse al bloquear el teléfono ya que solo tenemos permiso parcial. Para el correcto funcionamiento ve ajustes y permite la ubicacion todo el tiempo.");
      }
    }

    // 3. Si llegamos aquí
    initSub();
  }

  void initSub() {
    late LocationSettings settings = getSettings();

    // 4. Nos suscribimos al stream de posición
    _subscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((Position position) {
      // Distancia incremental desde el último punto (si existe)
      if(_collectedRoute.length > 1) {
        distanceDouble += Geolocator.distanceBetween(
            _collectedRoute.last.latitude,
            _collectedRoute.last.longitude,
            position.latitude, position.longitude);
        // Actualizamos la distancia formateada a 2 decimales en Kilómetros
        _distance = (distanceDouble / 1000).toStringAsFixed(10);
      }
      // Actualizar pace
      if(distanceDouble > 0.0) {
        final elapsedMinutes = _stopwatch.elapsed.inSeconds / 60;
        _pace =
        elapsedMinutes > 0 ? '${(elapsedMinutes / double.parse(_distance))
            .toStringAsFixed(2)}:00' : '0:00';
      }
      // Actualizar elevacion (provisionalmente solo mostramos 40, pero idealmente sería la diferencia entre el punto más alto y el más bajo)
      _elevation = (40).toStringAsFixed(0);
      // Actualizar calorias peso 70kg elpased time y 9 MET
      _calories = (70 * 9 * (_stopwatch.elapsed.inSeconds / 3600)).toStringAsFixed(0);

      savePosition(position);
      // Forzamos actualización de la UI cada vez que llega un nuevo punto
      if (mounted) setState(() {});
    });
  }

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
    _startTimer();
    permissionsAndInit();
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
        _subscription?.pause();
      } else {
        _stopwatch.start();
        _subscription?.resume();
      }
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
    _subscription?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final elapsed = _stopwatch.elapsed;
    const darkTimerColor = Color(0xFF0B233B);
    final size = MediaQuery.of(context).size;
    const double smallBtnSize = 64;

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
                                  // Calcular alpha dinámico en lugar de usar withOpacity
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

              // Espaciador dinámico
              SizedBox(height: size.height * 0.08),

              // Hoja blanca inferior principal (ahora con barra de controles incluida)
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  ),
                  child: Column(
                    children: [
                      // Área scrollable con el contenido principal
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
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
                                      // Distancia
                                      Expanded(
                                        child: Container(
                                          height: 95,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                          decoration: BoxDecoration(color: const Color(0xFFF7F8FA), borderRadius: BorderRadius.circular(12)),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: const [
                                                  Icon(Icons.pin_drop_outlined, color: Colors.blueAccent, size: 14),
                                                  SizedBox(width: 4),
                                                  Flexible(child: Text('DISTANCIA', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                                ],
                                              ),
                                              const Spacer(),
                                              // Mostramos _distance en lugar de un valor fijo
                                              Text('$_distance km', style: TextStyle(fontSize: 16, color: Colors.blueAccent.shade700, fontWeight: FontWeight.bold)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

                                      // Calidad del aire
                                      Expanded(
                                        child: Container(
                                          height: 95,
                                          decoration: BoxDecoration(
                                            color: Colors.greenAccent.shade400,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 3),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Row(
                                                  children: const [
                                                    Icon(Icons.air, color: Colors.green, size: 14),
                                                    SizedBox(width: 4),
                                                    Flexible(child: Text('QUALITAT AIRE', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                                                  ],
                                                ),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text('AQI 25', style: TextStyle(fontSize: 10, color: Colors.green.shade700, fontWeight: FontWeight.bold)),
                                                    const Text('Excel·lent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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

                                // 2. CAMBIAMOS EL Spacer(flex: 3) POR UN SizedBox
                                const SizedBox(height: 32),

                                // Métricas: RITME / KCAL / ALTITUD
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
                                          // Mostramos _pace en lugar de un valor fijo
                                          _metricItem('RITME', _pace, '/km'),
                                          Container(width: 1, height: 34, color: Colors.grey.shade300),
                                          // Mostramos _calories en lugar de un valor fijo
                                          _metricItem('KCAL', _calories, 'kcal'),
                                          Container(width: 1, height: 34, color: Colors.grey.shade300),
                                          // Mostramos _elevation en lugar de un valor fijo
                                          _metricItem('ALTITUD', _elevation, 'm'),
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

                      // Barra inferior fija con los controles (dentro de la hoja blanca)
                      Padding(
                        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom, top: 6),
                        child: Container(
                          color: Colors.white,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Finalitzar (ligeramente hacia el centro)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      // 1) Parar y capturar el tiempo
                                      _stopwatch.stop();
                                      final timeStr = _formatElapsed(_stopwatch.elapsed);

                                      // 2) Cancelar timers / subscripciones para liberar recursos inmediatamente
                                      _timer?.cancel();
                                      _subscription?.cancel();

                                      // 3) Navegar reemplazando la pantalla actual
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ResultsRouteScreen(),
                                          settings: RouteSettings(
                                            arguments: {
                                              'route': _collectedRoute,
                                              'distance': _distance,
                                              'pace': _pace,
                                              'time': timeStr,
                                              'elevation': _elevation,
                                              'calories': _calories,
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: smallBtnSize,
                                      height: smallBtnSize,
                                      decoration: const BoxDecoration(color: Color(0xFFF0F2F6), shape: BoxShape.circle),
                                      child: const Icon(Icons.stop, color: Colors.black54),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text('FINALITZAR', style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(width: 24),

                              // Botón central Play/Pause (elevado)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Transform.translate(
                                    offset: const Offset(0, -10),
                                    child: GestureDetector(
                                      onTap: _toggleRunning,
                                      child: Container(
                                        width: 82,
                                        height: 82,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 6),
                                          boxShadow: [
                                            BoxShadow(color: Colors.blue.withAlpha((0.3 * 255).round()), blurRadius: 14, spreadRadius: 2),
                                          ],
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(color: Colors.blue[700], shape: BoxShape.circle),
                                          child: Icon(_stopwatch.isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 36),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const SizedBox(height: 6),
                                ],
                              ),
                              const SizedBox(width: 24),

                              // Mapa
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  GestureDetector(
                                    onTap: () => Navigator.pushNamed(context, AppRouter.routeMap),
                                    child: Container(
                                      width: smallBtnSize,
                                      height: smallBtnSize,
                                      decoration: const BoxDecoration(color: Color(0xFFF0F2F6), shape: BoxShape.circle),
                                      child: const Icon(Icons.map_outlined, color: Colors.black54),
                                    ),
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
