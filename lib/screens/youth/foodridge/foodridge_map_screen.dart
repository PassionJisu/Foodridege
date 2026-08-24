import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/foreign_shop.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_reservations_screen.dart';
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
    final surplus = shops.where((shop) => shop.partnerSurplus).toList();

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Foodridge',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.6,
                              color: AppColors.ink,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'CNU 인근 독립 키친 — 배달앱에 없는 가게를 모았습니다.',
                            style: TextStyle(color: Color(0xFF6A5346), height: 1.35),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const FoodridgeReservationsScreen(),
                          ),
                        );
                      },
                      child: const Text('내 예약'),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    const Text(
                      'Surplus bags today',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${surplus.length} partner kitchens',
                      style: const TextStyle(color: Color(0xFF8A7466), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: surplus.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final shop = surplus[index];
                    return _SurplusCard(
                      shop: shop,
                      onTap: () => _openShop(context, shop),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: AspectRatio(
                  aspectRatio: 1.45,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFE7E3D2), Color(0xFFD3DCC8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Positioned(
                                left: 16,
                                top: 16,
                                child: Text(
                                  'Chonnam National University',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink,
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
                                    child: Icon(
                                      Icons.location_on,
                                      color: _pinColor(shop.badge),
                                      size: 28,
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
            ),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: Text(
                  'Nearby kitchens',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList.separated(
                itemCount: shops.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return Material(
                    color: const Color(0xFFFFFBF3),
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openShop(context, shop),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: shop.photoAsset == null
                                  ? Container(
                                      width: 72,
                                      height: 72,
                                      color: AppColors.sage.withValues(alpha: 0.2),
                                    )
                                  : Image.asset(
                                      shop.photoAsset!,
                                      width: 72,
                                      height: 72,
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Text(
                                    shop.cuisine,
                                    style: const TextStyle(color: Color(0xFF8A7466), fontSize: 12),
                                  ),
                                  Text(
                                    shop.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Color(0xFF8A7466), fontSize: 11),
                                  ),
                                ],
                              ),
                            ),
                            DietMark(badge: shop.badge),
                          ],
                        ),
                      ),
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
        return AppColors.sage;
      case DietBadge.vegetarian:
        return const Color(0xFF7A8F4A);
      case DietBadge.none:
        return AppColors.secondary;
    }
  }
}

class _SurplusCard extends StatelessWidget {
  const _SurplusCard({required this.shop, required this.onTap});

  final ForeignShop shop;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 220,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (shop.photoAsset != null)
                Image.asset(shop.photoAsset!, fit: BoxFit.cover)
              else
                Container(color: AppColors.sage),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.75),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DietMark(badge: shop.badge),
                    const Spacer(),
                    Text(
                      shop.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      shop.surplusLabel ?? 'Surprise bag',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Text(
                      '₩${shop.surplusPrice}  ·  pickup today',
                      style: const TextStyle(
                        color: Color(0xFFFFE3B8),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
      DietBadge.vegan => AppColors.sage,
      DietBadge.vegetarian => const Color(0xFF7A8F4A),
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
