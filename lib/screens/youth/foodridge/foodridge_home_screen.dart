import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/foreign_shop.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_cart_screen.dart';
import 'foodridge_map_screen.dart';
import 'foodridge_reservations_screen.dart';
import 'shop_detail_screen.dart';

enum _MealPickFilter { all, halal, vegan, veget, chinese }

class FoodridgeHomeScreen extends StatefulWidget {
  const FoodridgeHomeScreen({super.key});

  @override
  State<FoodridgeHomeScreen> createState() => _FoodridgeHomeScreenState();
}

class _FoodridgeHomeScreenState extends State<FoodridgeHomeScreen> {
  _MealPickFilter _filter = _MealPickFilter.all;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<ForeignShop> _filtered(List<ForeignShop> shops) {
    final q = _query.trim().toLowerCase();
    return shops.where((shop) {
      switch (_filter) {
        case _MealPickFilter.all:
          break;
        case _MealPickFilter.halal:
          if (shop.badge != DietBadge.halal) return false;
          break;
        case _MealPickFilter.vegan:
          if (shop.badge != DietBadge.vegan) return false;
          break;
        case _MealPickFilter.veget:
          if (shop.badge != DietBadge.vegetarian) return false;
          break;
        case _MealPickFilter.chinese:
          if (!shop.cuisine.toLowerCase().contains('chinese')) return false;
          break;
      }
      if (q.isEmpty) return true;
      return shop.name.toLowerCase().contains(q) ||
          shop.cuisine.toLowerCase().contains(q) ||
          shop.address.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final provider = context.watch<FoodridgeProvider>();
    final user = auth.appUser;
    final shops = _filtered(provider.shops);
    final bookingCount =
        user == null ? 0 : provider.reservationsFor(user.uid).length;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        title: const Text('MealPick'),
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
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter == _MealPickFilter.all,
                  onTap: () => setState(() => _filter = _MealPickFilter.all),
                ),
                _FilterChip(
                  label: 'Halal',
                  selected: _filter == _MealPickFilter.halal,
                  onTap: () => setState(() => _filter = _MealPickFilter.halal),
                ),
                _FilterChip(
                  label: 'Vegan',
                  selected: _filter == _MealPickFilter.vegan,
                  onTap: () => setState(() => _filter = _MealPickFilter.vegan),
                ),
                _FilterChip(
                  label: 'Veget',
                  selected: _filter == _MealPickFilter.veget,
                  onTap: () => setState(() => _filter = _MealPickFilter.veget),
                ),
                _FilterChip(
                  label: 'Chinese',
                  selected: _filter == _MealPickFilter.chinese,
                  onTap: () =>
                      setState(() => _filter = _MealPickFilter.chinese),
                ),
              ],
            ),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.sage.withValues(alpha: 0.25),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? AppColors.sage : AppColors.ink,
        ),
      ),
    );
  }
}
