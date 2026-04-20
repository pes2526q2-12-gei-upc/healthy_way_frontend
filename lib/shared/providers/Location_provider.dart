import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:healthy_way_frontend/core/services/location_service.dart';

class LocationProvider extends ChangeNotifier {
  String _placeName = 'Cercant ubicació...';
  bool _isLoading = false;

  String get placeName => _placeName;
  bool get isLoading => _isLoading;

  Future<void> fetchLocationName() async {
    _isLoading = true;
    notifyListeners();

    try {
      final pos = await LocationService.getCurrentLocation();

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
    } catch (e) {
      debugPrint('Error obteniendo la ubicación: $e');
      _placeName = 'Sense ubicació';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}