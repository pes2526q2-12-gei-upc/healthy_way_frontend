import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPoint {
  final LatLng latLng;
  final double altitude;

  const LocationPoint({required this.latLng, required this.altitude});
}

class LocationService {

  LocationSettings getSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: "Entrenamiento en curso",
          notificationText: "Tu ruta se está grabando...",
          enableWakeLock: true,
        ),
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
        activityType: ActivityType.fitness,
        showBackgroundLocationIndicator: true,
        pauseLocationUpdatesAutomatically: false,
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
    final error = await checkAndRequestPermission();

    if (error != null) {
      throw Exception(error);
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );

    return LatLng(position.latitude, position.longitude);
  }

  static Future<String?> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. ¿Está el GPS activado en los ajustes del móvil?
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return 'El GPS está apagado. Necesitamos que enciendas el GPS para que puedas utilizar HealthyWay correctamente.';
    }

    // 2. ¿Tenemos permiso básico de la app?
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return 'El usuario ha denegado el permiso.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return 'Permisos denegados para siempre. Debe ir a Ajustes.';
    }

    // 3. ¿Tenemos solo permiso parcial? Pedimos "Permitir siempre"
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.whileInUse) {
        return 'background_needed';
      }
    }
    return null;
  }

  // --- NUEVO: Ubicación en tiempo real ---
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StreamController<LocationPoint> _locationController = StreamController.broadcast();
  Stream<LocationPoint> get locationStream => _locationController.stream;

  StreamSubscription<Position>? _positionSubscription;

  Future<String?> startTracking() async {
    final error = await checkAndRequestPermission();

    if (error != null) {
      return error;
    }

    late LocationSettings settings = getSettings();

    if (_positionSubscription != null) return null;

    _positionSubscription = Geolocator.getPositionStream(
        locationSettings: settings
    ).listen((Position pos) {
      final point = LocationPoint(
        latLng: LatLng(pos.latitude, pos.longitude),
        altitude: pos.altitude,
      );
      _locationController.add(point);
    });

    return null;
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