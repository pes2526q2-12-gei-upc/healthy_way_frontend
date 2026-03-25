import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/services/location_service.dart';

class TrackingProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  StreamSubscription<LatLng>? _subscription;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  // --- RUTAS ---
  final List<LatLng> plannedRoute = const [
    LatLng(41.3596, 2.1002),
    LatLng(41.3621, 2.1028),
    LatLng(41.3654, 2.1065),
    LatLng(41.3688, 2.1102),
    LatLng(41.3712, 2.1140),
    LatLng(41.3745, 2.1185),
    LatLng(41.3781, 2.1221), // META
  ];

  List<LatLng> traversedRoute = [];

  // --- ESTADÍSTICAS Y ESTADO ---
  double _distanceDouble = 0.0;
  String distance = '0.00';
  String pace = '0:00';
  String elevation = '40';
  String calories = '0';

  // NUEVO: Bandera para saber si hemos llegado al destino
  bool isFinished = false;

  bool get isRunning => _stopwatch.isRunning;

  // 1. INICIAR
  Future<void> startRun() async {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();
    _startTimer();

    await _locationService.startTracking();

    _subscription ??= _locationService.locationStream.listen((LatLng pos) {
      _updateLocation(pos);
    });

    notifyListeners();
  }

  // 2. PAUSAR / REANUDAR
  void toggleRun() {
    if (isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
    notifyListeners();
  }

  // 3. FINALIZAR MANUAL O AUTOMÁTICAMENTE
  void stopRun() {
    _stopwatch.stop();
    _timer?.cancel();
    _timer = null;
    _subscription?.cancel();
    _subscription = null;

    _locationService.stopTracking();
    notifyListeners();
  }

  // 4. RESETEAR
  void reset() {
    traversedRoute.clear();
    _distanceDouble = 0.0;
    distance = '0.00';
    pace = '0:00';
    calories = '0';
    isFinished = false; // Reiniciamos la bandera
    _stopwatch.reset();
    notifyListeners();
  }

  // --- Lógica Interna ---

  void _updateLocation(LatLng newPos) {
    if (!isRunning || isFinished) return; // Si ya acabó, ignoramos puntos

    if (traversedRoute.isNotEmpty) {
      final lastPos = traversedRoute.last;
      _distanceDouble += Geolocator.distanceBetween(
          lastPos.latitude, lastPos.longitude,
          newPos.latitude, newPos.longitude);

      distance = (_distanceDouble / 1000).toStringAsFixed(2);
    }
    traversedRoute.add(newPos);
    _updateStats();

    // --- NUEVO: AUTO-COMPLETAR LA RUTA ---
    if (plannedRoute.isNotEmpty) {
      final endPoint = plannedRoute.last;
      final distanceToEnd = Geolocator.distanceBetween(
          newPos.latitude, newPos.longitude,
          endPoint.latitude, endPoint.longitude);

      // Si estamos a menos de 30 metros de la meta...
      if (distanceToEnd < 30.0) {
        isFinished = true;
        stopRun(); // Detenemos todo internamente
        notifyListeners(); // Avisamos a las vistas para que naveguen
      }
    }
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (isRunning) {
        _updateStats();
        notifyListeners();
      }
    });
  }

  void _updateStats() {
    final elapsedMinutes = _stopwatch.elapsed.inSeconds / 60;
    final distKm = _distanceDouble / 1000;

    if (distKm > 0.01) {
      double paceMinutes = elapsedMinutes / distKm;
      if (paceMinutes > 99) {
        pace = "> 99";
      } else {
        int pMin = paceMinutes.floor();
        int pSec = ((paceMinutes - pMin) * 60).round();
        pace = '${pMin.toString().padLeft(2, '0')}:${pSec.toString().padLeft(2, '0')}';
      }
    } else {
      pace = '0:00';
    }

    calories = (70 * 9 * (_stopwatch.elapsed.inSeconds / 3600)).toStringAsFixed(0);
  }

  String formatElapsed() {
    final d = _stopwatch.elapsed;
    final hours = d.inHours.remainder(100);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}