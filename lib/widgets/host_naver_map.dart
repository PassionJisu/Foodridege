import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

import '../core/config/naver_config.dart';
import '../services/naver_map_service.dart';
import '../theme/app_theme.dart';

/// Android/iOS에서는 네이티브 네이버맵, 그 외(Windows 등)에서는 정적 지도를 그린다.
/// `NaverMap()`을 초기화 전에 절대 생성하지 않는다.
class HostNaverMap extends StatelessWidget {
  const HostNaverMap({
    super.key,
    required this.initialTarget,
    this.initialZoom = 11,
    this.onNativeReady,
    this.pins = const [],
  });

  final NLatLng initialTarget;
  final double initialZoom;
  final void Function(NaverMapController controller)? onNativeReady;
  final List<NLatLng> pins;

  @override
  Widget build(BuildContext context) {
    if (NaverConfig.isNativeReady) {
      return NaverMap(
        options: NaverMapViewOptions(
          initialCameraPosition: NCameraPosition(
            target: initialTarget,
            zoom: initialZoom,
          ),
          locale: const NLocale('ko', 'KR'),
          locationButtonEnable: false,
        ),
        onMapReady: onNativeReady,
      );
    }
    return _FallbackNaverMap(
      center: initialTarget,
      zoom: initialZoom,
      pins: pins,
    );
  }
}

class _FallbackNaverMap extends StatefulWidget {
  const _FallbackNaverMap({
    required this.center,
    required this.zoom,
    required this.pins,
  });

  final NLatLng center;
  final double zoom;
  final List<NLatLng> pins;

  @override
  State<_FallbackNaverMap> createState() => _FallbackNaverMapState();
}

class _FallbackNaverMapState extends State<_FallbackNaverMap> {
  Uint8List? _png;
  var _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant _FallbackNaverMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.center != widget.center ||
        oldWidget.pins.length != widget.pins.length) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final bytes = await NaverMapService.staticRaster(
        lat: widget.center.latitude,
        lng: widget.center.longitude,
        width: 800,
        height: 600,
        level: widget.zoom.round().clamp(8, 16),
        markers: widget.pins,
      );
      if (!mounted) return;
      setState(() {
        _png = bytes;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Fallback map load failed: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _png == null) {
      return const ColoredBox(
        color: Color(0xFFE8E0D4),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_png != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          Image.memory(_png!, fit: BoxFit.cover),
          const Positioned(
            right: 8,
            bottom: 8,
            child: Text(
              'NAVER',
              style: TextStyle(
                fontSize: 10,
                color: Colors.black54,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      );
    }
    return _LocalPinMap(center: widget.center, pins: widget.pins);
  }
}

/// 정적 지도 API까지 실패해도 좌표 핀은 보이게 한다.
class _LocalPinMap extends StatelessWidget {
  const _LocalPinMap({required this.center, required this.pins});

  final NLatLng center;
  final List<NLatLng> pins;

  @override
  Widget build(BuildContext context) {
    final points = pins.isEmpty ? [center] : pins;
    return ColoredBox(
      color: const Color(0xFFD7E4D0),
      child: CustomPaint(
        painter: _PinPainter(points: points, center: center),
        child: const Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Text(
              '지도 SDK를 쓸 수 없는 환경 · 핀만 표시',
              style: TextStyle(fontSize: 11, color: Color(0xFF5E734C)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PinPainter extends CustomPainter {
  _PinPainter({required this.points, required this.center});

  final List<NLatLng> points;
  final NLatLng center;

  @override
  void paint(Canvas canvas, Size size) {
    final lats = points.map((p) => p.latitude).toList();
    final lngs = points.map((p) => p.longitude).toList();
    var minLat = lats.reduce((a, b) => a < b ? a : b);
    var maxLat = lats.reduce((a, b) => a > b ? a : b);
    var minLng = lngs.reduce((a, b) => a < b ? a : b);
    var maxLng = lngs.reduce((a, b) => a > b ? a : b);
    if ((maxLat - minLat).abs() < 0.01) {
      minLat -= 0.02;
      maxLat += 0.02;
    }
    if ((maxLng - minLng).abs() < 0.01) {
      minLng -= 0.02;
      maxLng += 0.02;
    }
    const pad = 28.0;
    Offset toXy(NLatLng p) {
      final x = pad + (p.longitude - minLng) / (maxLng - minLng) * (size.width - pad * 2);
      final y = pad + (maxLat - p.latitude) / (maxLat - minLat) * (size.height - pad * 2);
      return Offset(x, y);
    }

    final line = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    if (points.length > 1) {
      final path = Path()..moveTo(toXy(points.first).dx, toXy(points.first).dy);
      for (final p in points.skip(1)) {
        final o = toXy(p);
        path.lineTo(o.dx, o.dy);
      }
      canvas.drawPath(path, line);
    }

    final pin = Paint()..color = AppColors.secondary;
    for (var i = 0; i < points.length; i++) {
      final o = toXy(points[i]);
      canvas.drawCircle(o, 8, pin);
      final tp = TextPainter(
        text: TextSpan(
          text: '${i + 1}',
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
        textDirection: ui.TextDirection.ltr,
      )..layout();
      tp.paint(canvas, o.translate(-tp.width / 2, -tp.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant _PinPainter oldDelegate) => true;
}
