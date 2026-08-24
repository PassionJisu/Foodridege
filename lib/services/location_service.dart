import 'package:geolocator/geolocator.dart';

/// Arrival verification result (Foodridge English copy).
class ArrivalResult {
  const ArrivalResult({
    required this.success,
    required this.message,
    this.distanceMeters,
  });

  final bool success;
  final String message;
  final double? distanceMeters;
}

/// GPS check-in used by Foodridge bookings.
class LocationService {
  LocationService._();

  static const arrivalRadiusMeters = 150.0;

  static Future<Position> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure(
        'Location services are off. Please enable them in Settings.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        'Location permission denied. Check-in is unavailable.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Location permission is permanently denied. Allow it in app settings.',
      );
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  static Future<ArrivalResult> verifyArrival({
    required double targetLat,
    required double targetLng,
  }) async {
    try {
      final position = await currentPosition();
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        targetLat,
        targetLng,
      );

      if (distance <= arrivalRadiusMeters) {
        return ArrivalResult(
          success: true,
          message: 'Check-in confirmed! (~${distance.round()}m)',
          distanceMeters: distance,
        );
      }
      return ArrivalResult(
        success: false,
        message:
            'You are still about ${_readableDistance(distance)} away. '
            'Try again in front of the kitchen.',
        distanceMeters: distance,
      );
    } on LocationFailure catch (e) {
      return ArrivalResult(success: false, message: e.message);
    } catch (_) {
      return const ArrivalResult(
        success: false,
        message: 'Could not verify location. Please try again.',
      );
    }
  }

  static String _readableDistance(double meters) {
    if (meters < 1000) return '${meters.round()}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }
}

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;

  @override
  String toString() => message;
}
