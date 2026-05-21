import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

  Future<String?> fetchLocationName(int userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final permissionError = await LocationService.checkAndRequestPermission();
      if (permissionError != null && permissionError != 'background_needed') {
        _placeName = 'Sense ubicació';
        return permissionError;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _currentLocation = LatLng(position.latitude, position.longitude);

      List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        _placeName = p.locality ?? 'Ubicació desconeguda';
      } else {
        _placeName = 'Ubicació desconeguda';
      }

      _weatherScore = await UserService().rankWeatherLocation(userId, _currentLocation);

      return permissionError;

    } catch (e) {
      _placeName = 'Sense ubicació';
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.replaceFirst('Exception: ', '');
      }
      return errorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}