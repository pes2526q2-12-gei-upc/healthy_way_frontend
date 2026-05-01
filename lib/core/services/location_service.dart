import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {

  LocationSettings getSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high, // GPS puro para máxima precisión
        distanceFilter: 2,               // Actualiza cada 5 metros
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
        distanceFilter: 2,
        activityType: ActivityType.fitness, // Ayuda a iOS a optimizar el sensor para deporte
        showBackgroundLocationIndicator: true, // Barra azul arriba para que el usuario sepa que grabas
        pauseLocationUpdatesAutomatically: false, // Evita que iOS pare el GPS si te detienes en un semáforo
      );
    } else {
      return const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
    }
  }

  // --- Ubicación puntual (existente) ---
  static Future<LatLng> getCurrentLocation() async {
    await _checkAndRequestPermission();

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LatLng(position.latitude, position.longitude);
  }

  static Future<void> _checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. ¿Está el GPS activado en los ajustes del móvil?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint('El GPS está apagado. Necesitamos que enciendas el GPS para que puedas utilizar HealthyWay correctamente.');
      return;
    }

    // 2. ¿Tenemos permiso de la app?
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // Si no tiene, se lo pedimos ahora mismo
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint('El usuario ha denegado el permiso.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Permisos denegados para siempre. Debe ir a Ajustes.');
      return;
    }

    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      // Si sigue siendo whileInUse, avisamos que puede haber cortes
      if (permission == LocationPermission.whileInUse) {
        debugPrint("Aviso: La ruta podría detenerse al bloquear el teléfono ya que solo tenemos permiso parcial. Para el correcto funcionamiento ve ajustes y permite la ubicacion todo el tiempo.");
      }
    }
  }

  // --- NUEVO: Ubicación en tiempo real ---
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StreamController<LatLng> _locationController = StreamController.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;

  StreamSubscription<Position>? _positionSubscription;

  Future<void> startTracking() async {
    await _checkAndRequestPermission();

    late LocationSettings settings = getSettings();

    // Evitamos duplicar subscripciones
    if (_positionSubscription != null) return;

    _positionSubscription = Geolocator.getPositionStream(
        locationSettings: settings
    ).listen((Position pos) {
      final latLng = LatLng(pos.latitude, pos.longitude);
      _locationController.add(latLng);
    });
  }

  void stopTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  void dispose() {
    stopTracking();
    _locationController.close();
  }
}