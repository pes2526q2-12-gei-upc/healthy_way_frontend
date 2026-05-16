import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthy_way_frontend/shared/models/route_model.dart';
import 'package:latlong2/latlong.dart';
import '../../core/services/location_service.dart';
import 'package:geocoding/geocoding.dart';

final senseLocationMessage = 'Ubicació desconeguda';

class TrackingProvider extends ChangeNotifier {
  final LocationService _locationService = LocationService();

  StreamSubscription<LocationPoint>? _subscription;
  Timer? _timer;
  final Stopwatch _stopwatch = Stopwatch();

  // --- RUTAS ---
  late RouteModel rutaSeleccionada;
  bool routeIsSelected = false;
  bool running = false;

  List<LatLng> traversedRoute = [];

  // --- ESTADÍSTICAS Y ESTADO ---
  double distanceDouble = 0.0;
  String distance = '0.00';
  String pace = '0.00';
  String elevation = '0';
  String calories = '0';
  String placeName = senseLocationMessage;
  double maxAltitude = 0;
  double altitudeGained = 0.1;
  double? _lastAltitude;

  DateTime startTime = DateTime.now();
  String modality = 'Running';

  // NUEVO: Bandera para saber si hemos llegado al destino
  bool isFinished = false;

  bool get isRunning => _stopwatch.isRunning;

  bool validModality() {
    return modality == 'Running' || modality == 'Cycling';
  }

  void toggleModality() {
    if (modality == 'Running') {
      modality = 'Cycling';
    } else {
      modality = 'Running';
    }
    notifyListeners();
  }

  Future<void> _updatePlaceName(LatLng pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        placeName = '${p.locality}';
      } else {
        placeName = senseLocationMessage;
      }
    } catch (e) {
      placeName = senseLocationMessage;
    }
  }


  // 1. INICIAR
  Future<void> startRun() async {
    if (_stopwatch.isRunning) return;

    _stopwatch.start();
    _startTimer();

    await _locationService.startTracking();

    _subscription ??= _locationService.locationStream.listen((LocationPoint point) {
      _updateLocation(point);
    });

    running = true;

    startTime = DateTime.now(); // Guardamos el momento de inicio para calcular el tiempo total al finalizar

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
    distanceDouble = 0.0;
    distance = '0.00';
    pace = '0:00';
    elevation = '0';
    calories = '0';
    placeName =  senseLocationMessage;
    isFinished = false;
    _stopwatch.reset();
    running = false;
    modality = 'Running';
    startTime = DateTime.now();
    maxAltitude = 0;
    altitudeGained = 0.1;
    _lastAltitude = null;
    notifyListeners();
  }

  // --- Lógica Interna ---

  void _updateLocation(LocationPoint point) {
    elevation = point.altitude.toStringAsFixed(0);

    if (point.altitude > maxAltitude) {
      maxAltitude = point.altitude;
    }

    if (_lastAltitude == null) {
      _lastAltitude = point.altitude;
    }
    else {
      double diff = point.altitude - _lastAltitude!;

      if (diff >= 3.0) {
        altitudeGained += diff;
        _lastAltitude = point.altitude;
      }
      else if (diff <= -3.0) {
        _lastAltitude = point.altitude;
      }
    }

    final newPos = point.latLng;
    if (!isRunning || isFinished) return;

    if (traversedRoute.isNotEmpty) {
      final lastPos = traversedRoute.last;
      distanceDouble += Geolocator.distanceBetween(
          lastPos.latitude, lastPos.longitude,
          newPos.latitude, newPos.longitude);

      distance = (distanceDouble / 1000).toStringAsFixed(2);
    }
    traversedRoute.add(newPos);
    _updateStats();

    // --- NUEVO: AUTO-COMPLETAR LA RUTA ---
    if (routeIsSelected) {
      final endPoint = rutaSeleccionada.trajectory.last;
      final distanceToEnd = Geolocator.distanceBetween(
          newPos.latitude, newPos.longitude,
          endPoint.latitude, endPoint.longitude);

      if (distanceToEnd < 30.0) {
        isFinished = true;
        stopRun();
        notifyListeners();
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
    final distKm = distanceDouble / 1000;

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

    if(distanceDouble == 0.0) {
      calories = '0';
    } else {
      calories =
          (70 * 9 * (_stopwatch.elapsed.inSeconds / 3600)).toStringAsFixed(0);
    }

    if(placeName == senseLocationMessage && traversedRoute.isNotEmpty) {
      _updatePlaceName(traversedRoute.first);
    }
  }

  String formatElapsed() {
    final d = _stopwatch.elapsed;
    final hours = d.inHours.remainder(100);
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void setSelectedRoute(RouteModel route) {
    rutaSeleccionada = route;
    routeIsSelected = true;
    notifyListeners();
  }
}