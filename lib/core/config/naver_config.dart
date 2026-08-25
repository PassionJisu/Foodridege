import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 네이버 클라우드 플랫폼(Maps) 인증 정보.
///
/// Dynamic Map 타일이 회색 격자로만 보이면 콘솔 앱 등록을 확인하세요.
/// - Android 패키지: `com.foodridge.foodridge`
/// - iOS Bundle ID: `com.foodridge.foodridge`
///
/// - [clientId]: Dynamic Map(SDK) 초기화
/// - [clientSecret]: Geocoding / Directions / Static Map REST API
class NaverConfig {
  static const clientId = '8g5kdjjd6g';
  static const clientSecret = 'JwkrWBt4pgVWEDxmdfccafyOWk1m75L0sw5pW6yp';

  static bool sdkReady = false;

  /// flutter_naver_map 1.4.4는 Android / iOS 만 지원한다.
  static bool get nativeSupported {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  static bool get isNativeReady {
    // ignore: invalid_use_of_internal_member
    return FlutterNaverMap.isInitialized;
  }

  static Future<bool> ensureSdk() async {
    if (isNativeReady) {
      sdkReady = true;
      return true;
    }
    if (!nativeSupported) {
      sdkReady = false;
      return false;
    }

    try {
      await FlutterNaverMap().init(
        clientId: clientId,
        onAuthFailed: (ex) {
          debugPrint('Naver Map auth failed: $ex');
        },
      );
    } catch (e) {
      debugPrint('Naver Map NCP init failed: $e');
    }

    if (!isNativeReady && nativeSupported) {
      // Hot restart 시 Dart 플래그만 리셋되고 네이티브 SDK는 살아 있는 경우가 많다.
      // ignore: invalid_use_of_internal_member
      FlutterNaverMap.isInitialized = true;
    }
    sdkReady = true;
    return true;
  }
}
