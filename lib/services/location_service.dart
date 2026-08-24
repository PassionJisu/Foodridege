import 'package:geolocator/geolocator.dart';

/// 도착 인증 결과.
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

/// GPS 기반 위치 확인 서비스.
///
/// 실내·도심에서는 GPS 오차가 20~50m까지 발생하므로 판정 반경을
/// [arrivalRadiusMeters] 만큼 넉넉하게 둡니다.
class LocationService {
  LocationService._();

  static const arrivalRadiusMeters = 150.0;

  /// 위치 권한을 확인/요청하고 현재 좌표를 반환합니다.
  /// 권한이 없거나 서비스가 꺼져 있으면 예외 메시지를 담아 던집니다.
  static Future<Position> currentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationFailure('기기의 위치 서비스가 꺼져 있어요. 설정에서 켜주세요.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure('위치 권한이 거부되어 도착 확인을 할 수 없어요.');
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure('위치 권한이 영구적으로 거부되어 있어요. 앱 설정에서 허용해주세요.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
  }

  /// 목표 좌표까지의 거리를 계산해 도착 여부를 판정합니다.
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
          message: '도착이 확인되었습니다! (약 ${distance.round()}m)',
          distanceMeters: distance,
        );
      }
      return ArrivalResult(
        success: false,
        message:
            '아직 가게에서 약 ${_readableDistance(distance)} 떨어져 있어요. '
            '가게 앞에서 다시 시도해주세요.',
        distanceMeters: distance,
      );
    } on LocationFailure catch (e) {
      return ArrivalResult(success: false, message: e.message);
    } catch (_) {
      return const ArrivalResult(
        success: false,
        message: '위치를 확인하지 못했어요. 잠시 후 다시 시도해주세요.',
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
