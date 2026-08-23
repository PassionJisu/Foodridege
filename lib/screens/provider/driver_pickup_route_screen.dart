import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DriverPickupRouteScreen extends StatelessWidget {
  const DriverPickupRouteScreen({super.key});

  static const _stops = [
    _Stop('전남대 학생식당', '광주 북구 용봉로 77', '12:40 도착'),
    _Stop('광주여대 학생식당', '광주 광산구 광주여대길 201', '13:20 도착'),
    _Stop('전남대 자판기 입고', '학생회관 1층', '14:00 입고 마무리'),
    _Stop('광주여대 자판기', '캠퍼스 후문', '14:40 입고'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('수거 동선')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '오늘의 수거 노선 · 광주 01구역',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '점심 이후 1회 수거 · 출발 전 전날 재고 전량 폐기',
            style: TextStyle(color: Color(0xFF8A7466)),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1.6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFFE7E3D2),
                child: Stack(
                  children: [
                    CustomPaint(painter: _RoutePainter(), size: Size.infinite),
                    const Positioned(
                      left: 12,
                      top: 12,
                      child: Text('Gwangju · Buk-gu', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_stops.length, (index) {
            final stop = _stops[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.sage,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(stop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${stop.address}\n${stop.time}'),
              isThreeLine: true,
            );
          }),
        ],
      ),
    );
  }
}

class _Stop {
  const _Stop(this.name, this.address, this.time);
  final String name;
  final String address;
  final String time;
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final line = Paint()
      ..color = AppColors.sage
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.75)
      ..quadraticBezierTo(
        size.width * 0.45,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.35,
      );
    canvas.drawPath(path, line);
    final dot = Paint()..color = AppColors.secondary;
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.75), 7, dot);
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.38), 7, dot);
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.35), 7, dot);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
