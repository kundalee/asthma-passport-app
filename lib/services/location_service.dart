import 'package:geolocator/geolocator.dart';

class LocationService {
  // Returns the device's current (latitude, longitude), or null if location
  // services are off, permission was denied, or the request otherwise fails.
  static Future<(double latitude, double longitude)?> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );
      return (position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }
}
