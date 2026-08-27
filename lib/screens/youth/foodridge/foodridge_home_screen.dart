import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/foreign_shop.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_cart_screen.dart';
import 'foodridge_map_screen.dart';
import 'foodridge_reservations_screen.dart';
import 'mealpick_filter.dart';
import 'shop_detail_screen.dart';

class FoodridgeHomeScreen extends StatefulWidget {
  const FoodridgeHomeScreen({super.key});

  @override
  State<FoodridgeHomeScreen> createState() => _FoodridgeHomeScreenState();
}

class _FoodridgeHomeScreenState extends State<FoodridgeHomeScreen> {
  MealPickFilter _filter = MealPickFilter.all;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ForeignShop> _filtered(List<ForeignShop> shops) {
    return filterMealPickShops(shops, filter: _filter, query: _query);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<FoodridgeProvider>();
    final user = auth.appUser;
    final shops = _filtered(provider.shops);
    final bookingCount =
        user == null ? 0 : provider.reservationsFor(user.uid).length;
    final cartCount = user == null ? 0 : provider.cartCountFor(user.uid);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        toolbarHeight: 72,
        title: const Text('MealPick'),
        actions: [
          _MealPickBarButton(
            icon: Icons.map_outlined,
            label: 'Map',
            ring: true,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FoodridgeMapScreen(initialFilter: _filter),
                ),
              );
            },
          ),
          const SizedBox(width: 14),
          _MealPickBarButton(
            icon: Icons.shopping_cart_outlined,
            label: 'Cart',
            badgeCount: cartCount,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeCartScreen(),
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search kitchens, cuisine, or menus',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
          if (_query.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: shops.isEmpty ? Colors.redAccent : AppColors.sage,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  shops.isEmpty
                      ? 'No results'
                      : '${shops.length} place${shops.length == 1 ? '' : 's'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeReservationsScreen(),
                ),
              );
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD4C8B4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event_available_outlined, color: AppColors.sage),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My bookings',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Check-in and reviews for your reservations',
                          style: TextStyle(
                            color: Color(0xFF8A7466),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (bookingCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sage.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$bookingCount',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.sage,
                        ),
                      ),
                    ),
                  const Icon(Icons.chevron_right, color: Color(0xFF8A7466)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Categories',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          const SizedBox(height: 10),
          MealPickCategoryBar(
            selected: _filter,
            onChanged: (value) => setState(() => _filter = value),
          ),
          const SizedBox(height: 16),
          if (shops.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  _query.trim().isNotEmpty
                      ? 'No restaurants match your search.'
                      : 'No restaurants in this category.',
                  style: const TextStyle(color: Color(0xFF8A7466)),
                ),
              ),
            )
          else
            ...shops.map((shop) {
              final avg = provider.averageStars(shop.id);
              final minPrice = provider.minPriceForStore(shop.id);
              final remaining = provider.remainingCountForStore(shop.id);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
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
                                const Icon(
                                  Icons.star,
                                  size: 13,
                                  color: Color(0xFFE0A800),
                                ),
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
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF8A7466),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _MealPickBarButton extends StatelessWidget {
  const _MealPickBarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.ring = false,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool ring;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    Widget glyph = Icon(icon, size: 28, color: AppColors.ink);
    if (badgeCount > 0) {
      glyph = Badge(
        label: Text('$badgeCount'),
        child: glyph,
      );
    }
    if (ring) {
      glyph = Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE53935), width: 2),
        ),
        child: glyph,
      );
    } else {
      glyph = Padding(padding: const EdgeInsets.all(7), child: glyph);
    }

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            glyph,
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
