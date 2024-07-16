import 'package:location/location.dart';

class LocationService {
  Location location = Location();

  Stream<LocationData> getLocationStream() {
    return location.onLocationChanged;
  }

  Future<LocationData?> getCurrentLocation() async {
    try {
      return await location.getLocation();
    } catch (e) {
      print('Could not get location: $e');
      return null;
    }
  }

  void dispose() {
    // location.dispose();
  }
}

