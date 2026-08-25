import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

/// 네이버 클라우드 플랫폼(Maps) 인증 정보.
///
/// Dynamic Map 타일이 회색 격자로만 보이면 콘솔 앱 등록을 확인하세요.
/// - Android 패키지: `com.foodridge.foodridge`
/// - iOS Bundle ID: `com.foodridge.foodridge`
/// - Android SHA-1: `keytool -list -v -keystore %USERPROFILE%\\.android\\debug.keystore -alias androiddebugkey -storepass android -keypass android`
///
/// - [clientId]: Dynamic Map(SDK) 초기화
/// - [clientSecret]: Geocoding / Directions REST API 전용 (타일 로딩에는 불필요)
class NaverConfig {
  static const clientId = '8g5kdjjd6g';
  static const clientSecret = 'JwkrWBt4pgVWEDxmdfccafyOWk1m75L0sw5pW6yp';

  /// `FlutterNaverMap().init`이 끝난 뒤에만 지도 위젯을 그린다.
  static bool sdkReady = false;

  static Future<bool> ensureSdk() async {
    if (sdkReady) return true;
    try {
      await FlutterNaverMap().init(
        clientId: clientId,
        onAuthFailed: (ex) {
          debugPrint('Naver Map auth failed: $ex');
        },
      );
      // ignore: invalid_use_of_internal_member
      sdkReady = FlutterNaverMap.isInitialized;
      return sdkReady;
    } catch (e) {
      debugPrint('Naver Map init failed: $e');
      sdkReady = false;
      return false;
    }
  }
}
