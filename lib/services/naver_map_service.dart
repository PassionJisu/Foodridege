import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:http/http.dart' as http;

import '../core/config/naver_config.dart';

class DrivingRoute {
  const DrivingRoute({
    required this.path,
    required this.distanceMeters,
    required this.durationMs,
  });

  final List<NLatLng> path;
  final int distanceMeters;
  final int durationMs;
}

/// Foodridge2 Naver Maps REST 래퍼 이식.
class NaverMapService {
  NaverMapService._();

  static const _base = 'https://maps.apigw.ntruss.com';
  static const _timeout = Duration(seconds: 10);

  static Map<String, String> get _headers => {
        'x-ncp-apigw-api-key-id': NaverConfig.clientId,
        'x-ncp-apigw-api-key': NaverConfig.clientSecret,
        'Accept': 'application/json',
      };

  static Future<DrivingRoute?> drivingRouteDetail({
    required NLatLng start,
    required NLatLng goal,
    List<NLatLng> waypoints = const [],
  }) async {
    final path = waypoints.length > 5
        ? '/map-direction-15/v1/driving'
        : '/map-direction/v1/driving';

    final params = <String, String>{
      'start': '${start.longitude},${start.latitude}',
      'goal': '${goal.longitude},${goal.latitude}',
    };
    if (waypoints.isNotEmpty) {
      params['waypoints'] =
          waypoints.map((w) => '${w.longitude},${w.latitude}').join('|');
    }

    final uri = Uri.parse('$_base$path').replace(queryParameters: params);
    final res = await http.get(uri, headers: _headers).timeout(_timeout);
    if (res.statusCode != 200) return null;

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final route = body['route'] as Map<String, dynamic>?;
    if (route == null) return null;
    final traoptimal = route['traoptimal'] as List<dynamic>? ?? [];
    if (traoptimal.isEmpty) return null;

    final first = traoptimal.first as Map<String, dynamic>;
    final rawPath = first['path'] as List<dynamic>? ?? [];
    final summary = first['summary'] as Map<String, dynamic>? ?? {};

    return DrivingRoute(
      path: [
        for (final p in rawPath)
          NLatLng(
            ((p as List)[1] as num).toDouble(),
            (p[0] as num).toDouble(),
          ),
      ],
      distanceMeters: (summary['distance'] as num?)?.toInt() ?? 0,
      durationMs: (summary['duration'] as num?)?.toInt() ?? 0,
    );
  }

  /// Windows 등 네이티브 SDK가 없는 환경용 네이버 정적 지도.
  static Future<Uint8List?> staticRaster({
    required double lat,
    required double lng,
    required int width,
    required int height,
    int level = 11,
    List<NLatLng> markers = const [],
  }) async {
    final w = width.clamp(200, 1024);
    final h = height.clamp(200, 1024);
    final qp = <String, String>{
      'w': '$w',
      'h': '$h',
      'center': '$lng,$lat',
      'level': '${level.clamp(1, 20)}',
      'scale': '2',
      'format': 'png',
    };
    var uri = Uri.parse('$_base/map-static/v2/raster').replace(
      queryParameters: qp,
    );
    if (markers.isNotEmpty) {
      final extra = markers
          .take(12)
          .map(
            (m) =>
                'markers=${Uri.encodeQueryComponent('type:d|size:mid|pos:${m.longitude} ${m.latitude}')}',
          )
          .join('&');
      uri = Uri.parse('${uri.toString()}&$extra');
    }
    final res = await http
        .get(
          uri,
          headers: {
            ..._headers,
            'Accept': 'image/png,image/jpeg,*/*',
          },
        )
        .timeout(_timeout);
    if (res.statusCode != 200 || res.bodyBytes.isEmpty) {
      debugPrint('Naver static map failed: ${res.statusCode}');
      return null;
    }
    return res.bodyBytes;
  }
}
