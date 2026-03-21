import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationService {
  // --- Ubicación puntual (existente) ---
  static Future<LatLng> getCurrentLocation() async {
    await _checkAndRequestPermission();

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  static Future<void> _checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permisos de ubicación denegados permanentemente');
    }
  }

  // --- NUEVO: Ubicación en tiempo real ---
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  final StreamController<LatLng> _locationController = StreamController.broadcast();
  Stream<LatLng> get locationStream => _locationController.stream;

  StreamSubscription<Position>? _positionSubscription;

  Future<void> startTracking({double distanceFilter = 5}) async {
    await _checkAndRequestPermission();

    // Evitamos duplicar subscripciones
    if (_positionSubscription != null) return;

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: distanceFilter.toInt(),
      ),
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