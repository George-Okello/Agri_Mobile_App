import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import '../error/failures.dart';
import '../utils/either.dart';

class LocationService {
  static Future<Either<Failure, Position>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationFailure(
          'Location services are disabled. Please enable location services.',
        ));
      }
      
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(LocationFailure(
            'Location permission denied. Please grant location access.',
          ));
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return const Left(LocationFailure(
          'Location permission permanently denied. Please enable in settings.',
        ));
      }
      
      // Try to get current position with new settings parameter
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 30),
          ),
        );
        return Right(position);
      } on TimeoutException {
        // Fallback to last known position
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          return Right(lastPosition);
        }
        return const Left(LocationFailure(
          'Location request timed out. Please check your GPS signal.',
        ));
      }
    } catch (e) {
      // Try last known position as final fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          return Right(lastPosition);
        }
      } catch (_) {}
     
      return Left(LocationFailure(
        'Failed to get location: ${e.toString()}',
      ));
    }
  }
  
  // Alternative method with platform-specific settings
  static Future<Either<Failure, Position>> getCurrentLocationWithPlatformSettings() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return const Left(LocationFailure(
          'Location services are disabled. Please enable location services.',
        ));
      }
      
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return const Left(LocationFailure(
            'Location permission denied. Please grant location access.',
          ));
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        return const Left(LocationFailure(
          'Location permission permanently denied. Please enable in settings.',
        ));
      }
      
      // Platform-specific settings using dart:io
      late LocationSettings locationSettings;
      
      if (Platform.isAndroid) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 100,
          forceLocationManager: true,
          intervalDuration: const Duration(seconds: 10),
          timeLimit: const Duration(seconds: 30),
        );
      } else if (Platform.isIOS) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.high,
          activityType: ActivityType.other,
          distanceFilter: 100,
          pauseLocationUpdatesAutomatically: true,
          timeLimit: const Duration(seconds: 30),
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 30),
        );
      }
      
      try {
        final position = await Geolocator.getCurrentPosition(
          locationSettings: locationSettings,
        );
        return Right(position);
      } on TimeoutException {
        // Fallback to last known position
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          return Right(lastPosition);
        }
        return const Left(LocationFailure(
          'Location request timed out. Please check your GPS signal.',
        ));
      }
    } catch (e) {
      // Try last known position as final fallback
      try {
        final lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          return Right(lastPosition);
        }
      } catch (_) {}
     
      return Left(LocationFailure(
        'Failed to get location: ${e.toString()}',
      ));
    }
  }
  
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
  
  static Future<LocationPermission> getLocationPermission() async {
    return await Geolocator.checkPermission();
  }
  
  static Future<LocationPermission> requestLocationPermission() async {
    return await Geolocator.requestPermission();
  }
  
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
  
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}