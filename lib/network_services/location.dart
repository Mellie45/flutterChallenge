import 'package:flutter_code_challenge/utilities/globals.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

class Location {
  dynamic latitude;
  dynamic longitude;
  String locServ = 'Please enable location services';
  String locPerm = 'Please enable location permissions';
  String locPermAlways = 'Location permissions are permanently denied, we cannot request permission to access your location.';

  Future<void> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error(locServ);

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(locPerm);
      }
    }
    if (permission == LocationPermission.deniedForever) return Future.error(locPermAlways);

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint(position.toString());
    } catch (e) {
      final SnackBar snackBar = SnackBar(content: Text('Location not found ${e.toString()}'));
      snackbarKey.currentState?.showSnackBar(snackBar);

      debugPrint('Location call failed: $e');
    }
  }
}
