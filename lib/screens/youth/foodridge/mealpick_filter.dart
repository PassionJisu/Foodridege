import 'package:flutter/material.dart';

import '../../../models/foreign_shop.dart';
import '../../../theme/app_theme.dart';

enum MealPickFilter { all, halal, vegan, veget, chinese }

extension MealPickFilterX on MealPickFilter {
  String get label => switch (this) {
        MealPickFilter.all => 'All',
        MealPickFilter.halal => 'Halal',
        MealPickFilter.vegan => 'Vegan',
        MealPickFilter.veget => 'Veget',
        MealPickFilter.chinese => 'Chinese',
      };

  bool matchesShop(ForeignShop shop) {
    return switch (this) {
      MealPickFilter.all => true,
      MealPickFilter.halal => shop.badge == DietBadge.halal,
      MealPickFilter.vegan => shop.badge == DietBadge.vegan,
      MealPickFilter.veget => shop.badge == DietBadge.vegetarian,
      MealPickFilter.chinese => shop.cuisine.toLowerCase().contains('chinese'),
    };
  }
}

List<ForeignShop> filterMealPickShops(
  Iterable<ForeignShop> shops, {
  MealPickFilter filter = MealPickFilter.all,
  String query = '',
}) {
  final q = query.trim().toLowerCase();
  return shops.where((shop) {
    if (!filter.matchesShop(shop)) return false;
    if (q.isEmpty) return true;
    return shop.name.toLowerCase().contains(q) ||
        shop.cuisine.toLowerCase().contains(q) ||
        shop.address.toLowerCase().contains(q) ||
        (shop.surplusLabel?.toLowerCase().contains(q) ?? false);
  }).toList();
}

class MealPickCategoryBar extends StatelessWidget {
  const MealPickCategoryBar({
    super.key,
    required this.selected,
    required this.onChanged,
    this.elevated = false,
  });

  final MealPickFilter selected;
  final ValueChanged<MealPickFilter> onChanged;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in MealPickFilter.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filter.label),
                selected: selected == filter,
                onSelected: (_) => onChanged(filter),
                selectedColor: AppColors.sage.withValues(alpha: 0.25),
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected == filter ? AppColors.sage : AppColors.ink,
                ),
              ),
            ),
        ],
      ),
    );

    if (!elevated) return chips;

    return Material(
      elevation: 4,
      color: Colors.white.withValues(alpha: 0.96),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 6, 4, 6),
        child: chips,
      ),
    );
  }
}
