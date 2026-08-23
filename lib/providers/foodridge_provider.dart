import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/foreign_shop.dart';

class FoodridgeProvider with ChangeNotifier {
  FoodridgeProvider() {
    _shops = List.of(SeedData.shops);
    _reviews = List.of(SeedData.shopReviews);
  }

  late List<ForeignShop> _shops;
  late List<ShopReview> _reviews;

  List<ForeignShop> get shops => List.unmodifiable(_shops);

  ForeignShop shopById(String id) => _shops.firstWhere((s) => s.id == id);

  List<ShopReview> reviewsFor(String shopId) {
    final list = _reviews.where((r) => r.shopId == shopId).toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  double averageStars(String shopId) {
    final list = reviewsFor(shopId);
    if (list.isEmpty) return 0;
    return list.fold<int>(0, (sum, r) => sum + r.stars) / list.length;
  }

  void addReview({
    required String shopId,
    required String author,
    required int stars,
    required String comment,
  }) {
    _reviews.add(
      ShopReview(
        id: 'sr-${DateTime.now().millisecondsSinceEpoch}',
        shopId: shopId,
        author: author,
        stars: stars,
        comment: comment.trim(),
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }
}
