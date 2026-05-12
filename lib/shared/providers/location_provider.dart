import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:healthy_way_frontend/core/services/location_service.dart';
import 'package:latlong2/latlong.dart';

import '../../core/services/user_service.dart';

class LocationProvider extends ChangeNotifier {
  String _placeName = 'Cercant ubicació...';
  int _weatherScore = -1;
  LatLng _currentLocation = const LatLng(0, 0);
  bool _isLoading = false;

  String get placeName => _placeName;
  int get weatherScore => _weatherScore;
  LatLng get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;

  Future<void> fetchLocationName(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final pos = await LocationService.getCurrentLocation();

      _currentLocation = LatLng(pos.latitude, pos.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _placeName = p.locality ?? 'Ubicació desconeguda';
      } else {
        _placeName = 'Ubicació desconeguda';
      }
      final latLng = LatLng(pos.latitude, pos.longitude);
      _weatherScore = await UserService().rankWeatherLocation(userId, latLng);

    } catch (e) {
      debugPrint('Error obteniendo la ubicación: $e');
      _placeName = 'Sense ubicació';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}