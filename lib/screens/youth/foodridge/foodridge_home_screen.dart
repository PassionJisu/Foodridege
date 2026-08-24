import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_cart_screen.dart';
import 'foodridge_map_screen.dart';
import 'foodridge_reservations_screen.dart';
import 'shop_detail_screen.dart';

class FoodridgeHomeScreen extends StatelessWidget {
  const FoodridgeHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<FoodridgeProvider>();

    final shops = provider.shops;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Foodridge'),
        actions: [
          IconButton(
            tooltip: 'Map',
            icon: const Icon(Icons.map_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeMapScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Cart',
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeCartScreen(),
                ),
              );
            },
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeReservationsScreen(),
                ),
              );
            },
            child: const Text('My bookings'),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: shops.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final shop = shops[i];
          final avg = provider.averageStars(shop.id);
          final minPrice = provider.minPriceForStore(shop.id);
          final remaining = provider.remainingCountForStore(shop.id);

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ShopDetailScreen(shopId: shop.id),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4C8B4)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 72,
                      height: 72,
                      child: shop.photoAsset != null
                          ? Image.asset(
                              shop.photoAsset!,
                              fit: BoxFit.cover,
                            )
                          : Container(color: AppColors.canvasDeep),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          shop.cuisine,
                          style: const TextStyle(
                            color: Color(0xFF8A7466),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          minPrice == null
                              ? 'Sold out'
                              : 'From ₩$minPrice',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppColors.sage,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Remaining: $remaining',
                          style: const TextStyle(
                            color: Color(0xFF8A7466),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star,
                              size: 13, color: Color(0xFFE0A800)),
                          const SizedBox(width: 4),
                          Text(
                            avg > 0 ? avg.toStringAsFixed(1) : '—',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                              color: AppColors.ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Icon(Icons.chevron_right,
                          color: Color(0xFF8A7466)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

