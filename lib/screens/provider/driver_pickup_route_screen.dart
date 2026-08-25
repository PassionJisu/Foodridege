import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/naver_map_service.dart';
import '../../core/config/naver_config.dart';
import '../../theme/app_theme.dart';

class DriverPickupRouteScreen extends StatefulWidget {
  const DriverPickupRouteScreen({super.key});

  @override
  State<DriverPickupRouteScreen> createState() =>
      _DriverPickupRouteScreenState();
}

class _DriverPickupRouteScreenState extends State<DriverPickupRouteScreen> {
  bool _showMap = NaverConfig.sdkReady;
  final Set<int> _done = {};
  DrivingRoute? _summary;

  static const _stops = [
    _Stop('전남대 학생식당', '광주 북구 용봉로 77', 35.1761, 126.9058),
    _Stop('광주여대 학생식당', '광주 광산구 광주여대길 201', 35.1628, 126.7965),
    _Stop('전남대 자판기', '학생회관 1층', 35.1752, 126.9079),
    _Stop('광주여대 자판기', '캠퍼스 후문', 35.1619, 126.7988),
  ];

  @override
  void initState() {
    super.initState();
    _prepareMap();
  }

  Future<void> _prepareMap() async {
    final ok = await NaverConfig.ensureSdk();
    if (mounted) setState(() => _showMap = ok);
  }

  Future<void> _navigate(_Stop stop) async {
    final app = Uri.parse(
      'nmap://route/car?dlat=${stop.lat}&dlng=${stop.lng}'
      '&dname=${Uri.encodeComponent(stop.name)}&appname=com.foodridge.app',
    );
    final web = Uri.parse(
      'https://map.naver.com/p/directions/-/${stop.lng},${stop.lat},'
      '${Uri.encodeComponent(stop.name)}/-/car',
    );
    if (await canLaunchUrl(app)) {
      await launchUrl(app);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _stops.length - _done.length;
    final nextIndex = List.generate(_stops.length, (i) => i)
        .where((i) => !_done.contains(i))
        .cast<int?>()
        .firstWhere((_) => true, orElse: () => null);
    final next = nextIndex == null ? null : _stops[nextIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('수거 동선'),
        actions: [
          IconButton(
            tooltip: _showMap ? '목록만 보기' : '지도 보기',
            onPressed: () => setState(() => _showMap = !_showMap),
            icon: Icon(_showMap ? Icons.list_alt : Icons.map_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.canvasDeep,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                _MiniStat(label: '정차', value: '${_stops.length}곳'),
                const SizedBox(width: 14),
                _MiniStat(label: '남음', value: '$remaining곳'),
                if (_summary != null) ...[
                  const SizedBox(width: 14),
                  _MiniStat(
                    label: '거리',
                    value: _summary!.distanceMeters < 1000
                        ? '${_summary!.distanceMeters}m'
                        : '${(_summary!.distanceMeters / 1000).toStringAsFixed(1)}km',
                  ),
                ],
                const Spacer(),
                if (next != null)
                  TextButton(
                    onPressed: () => _navigate(next),
                    child: const Text('길안내'),
                  ),
              ],
            ),
          ),
          if (_showMap)
            Expanded(
              flex: 4,
              child: _RouteMap(
                key: ValueKey(_done.join(',')),
                stops: _stops,
                done: _done,
                onSummary: (s) {
                  if (mounted) setState(() => _summary = s);
                },
              ),
            ),
          Expanded(
            flex: _showMap ? 3 : 1,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: _stops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final stop = _stops[i];
                final done = _done.contains(i);
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: done ? AppColors.sage : const Color(0xFFD4C8B4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: done ? AppColors.sage : AppColors.secondary,
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              stop.name,
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        stop.address,
                        style: const TextStyle(color: Color(0xFF8A7466), fontSize: 12),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _navigate(stop),
                              icon: const Icon(Icons.directions, size: 16),
                              label: const Text('길안내'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sage,
                              ),
                              onPressed:
                                  done ? null : () => setState(() => _done.add(i)),
                              icon: const Icon(Icons.check, size: 16),
                              label: Text(done ? '완료됨' : '수거 완료'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stop {
  const _Stop(this.name, this.address, this.lat, this.lng);
  final String name;
  final String address;
  final double lat;
  final double lng;
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF8A7466))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
      ],
    );
  }
}

class _RouteMap extends StatefulWidget {
  const _RouteMap({
    super.key,
    required this.stops,
    required this.done,
    required this.onSummary,
  });

  final List<_Stop> stops;
  final Set<int> done;
  final ValueChanged<DrivingRoute?> onSummary;

  @override
  State<_RouteMap> createState() => _RouteMapState();
}

class _RouteMapState extends State<_RouteMap> {
  String? _error;

  Future<void> _draw(NaverMapController controller) async {
    final points = widget.stops.map((s) => NLatLng(s.lat, s.lng)).toList();
    await controller.addOverlayAll({
      for (var i = 0; i < widget.stops.length; i++)
        NMarker(
          id: 's$i',
          position: points[i],
          caption: NOverlayCaption(
            text: '${i + 1}. ${widget.stops[i].name}',
            textSize: 11,
          ),
          iconTintColor:
              widget.done.contains(i) ? AppColors.sage : AppColors.secondary,
        ),
    });

    if (points.length < 2) {
      await controller.updateCamera(
        NCameraUpdate.withParams(target: points.first, zoom: 13),
      );
      return;
    }

    try {
      final route = await NaverMapService.drivingRouteDetail(
        start: points.first,
        goal: points.last,
        waypoints: points.sublist(1, points.length - 1),
      );
      if (!mounted) return;
      if (route == null || route.path.isEmpty) {
        setState(() => _error = '경로를 계산하지 못해 지점만 표시합니다.');
        widget.onSummary(null);
      } else {
        await controller.addOverlay(
          NPathOverlay(
            id: 'route',
            coords: route.path,
            color: AppColors.sage,
            width: 5,
          ),
        );
        widget.onSummary(route);
      }
      await controller.updateCamera(
        NCameraUpdate.fitBounds(
          NLatLngBounds.from(points),
          padding: const EdgeInsets.all(48),
        ),
      );
    } catch (_) {
      if (mounted) {
        setState(() => _error = '지도 경로 조회 중 오류가 발생했습니다.');
        widget.onSummary(null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!NaverConfig.sdkReady) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            _error ?? '지도를 불러올 수 없습니다. 아래 목록에서 수거를 진행해 주세요.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF8A7466)),
          ),
        ),
      );
    }
    return Stack(
      children: [
        NaverMap(
          options: const NaverMapViewOptions(
            initialCameraPosition: NCameraPosition(
              target: NLatLng(35.1595, 126.8526),
              zoom: 11,
            ),
            locationButtonEnable: false,
          ),
          onMapReady: _draw,
        ),
        if (_error != null)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Material(
              elevation: 2,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Text(_error!, style: const TextStyle(fontSize: 12)),
              ),
            ),
          ),
      ],
    );
  }
}
