import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/foreign_shop.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'shop_detail_screen.dart';

class FoodridgeMapScreen extends StatelessWidget {
  const FoodridgeMapScreen({super.key});

  static const _minLat = 35.1728;
  static const _maxLat = 35.1802;
  static const _minLng = 126.9018;
  static const _maxLng = 126.9142;

  @override
  Widget build(BuildContext context) {
    final shops = context.watch<FoodridgeProvider>().shops;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F1EC),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Foodridge',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Independent kitchens near CNU — not listed on Baemin or Coupang Eats.',
                    style: TextStyle(color: Colors.black54, height: 1.35),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: AspectRatio(
                aspectRatio: 1.35,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFFD7E3D4), Color(0xFFB9CDB8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 16,
                              top: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                color: Colors.white.withValues(alpha: 0.9),
                                child: const Text(
                                  'Chonnam National University',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                            ...shops.map((shop) {
                              final x = (shop.lng - _minLng) / (_maxLng - _minLng);
                              final y = 1 - (shop.lat - _minLat) / (_maxLat - _minLat);
                              return Positioned(
                                left: (x * (constraints.maxWidth - 36)).clamp(8, constraints.maxWidth - 36),
                                top: (y * (constraints.maxHeight - 36)).clamp(8, constraints.maxHeight - 36),
                                child: GestureDetector(
                                  onTap: () => _openShop(context, shop),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: _pinColor(shop.badge),
                                        size: 28,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Nearby kitchens',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(shop.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${shop.cuisine}\n${shop.address}'),
                      isThreeLine: true,
                      trailing: DietMark(badge: shop.badge),
                      onTap: () => _openShop(context, shop),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openShop(BuildContext context, ForeignShop shop) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopDetailScreen(shopId: shop.id)),
    );
  }

  Color _pinColor(DietBadge badge) {
    switch (badge) {
      case DietBadge.halal:
        return const Color(0xFF1B7A4A);
      case DietBadge.vegan:
        return const Color(0xFF2E7D32);
      case DietBadge.vegetarian:
        return const Color(0xFF558B2F);
      case DietBadge.none:
        return AppColors.primary;
    }
  }
}

class DietMark extends StatelessWidget {
  const DietMark({super.key, required this.badge});

  final DietBadge badge;

  @override
  Widget build(BuildContext context) {
    if (badge == DietBadge.none) {
      return const SizedBox.shrink();
    }
    final label = switch (badge) {
      DietBadge.halal => 'HALAL',
      DietBadge.vegan => 'VEGAN',
      DietBadge.vegetarian => 'VEG',
      DietBadge.none => '',
    };
    final color = switch (badge) {
      DietBadge.halal => const Color(0xFF1B7A4A),
      DietBadge.vegan => const Color(0xFF2E7D32),
      DietBadge.vegetarian => const Color(0xFF558B2F),
      DietBadge.none => Colors.grey,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(6),
        color: color.withValues(alpha: 0.08),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
