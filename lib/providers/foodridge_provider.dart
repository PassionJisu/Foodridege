import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/foodridge_cart_line.dart';
import '../models/foodridge_menu_item.dart';
import '../models/foodridge_reservation.dart';
import '../models/foreign_shop.dart';
import '../services/location_service.dart';

/// Foodridge demo backend:
/// - local menu items + stock (no DB)
/// - cart (local)
/// - checkout => reservation (GPS check-in => review)
class FoodridgeProvider with ChangeNotifier {
  FoodridgeProvider() {
    _shops = List.of(SeedData.shops);
    _menuItems = List.of(SeedData.menuItems);
    _reviews = List.of(SeedData.shopReviews);
  }

  late List<ForeignShop> _shops;
  late List<FoodridgeMenuItem> _menuItems;
  late List<ShopReview> _reviews;

  final List<FoodridgeReservation> _reservations = [];
  final List<FoodridgeCartLine> _cartLines = [];

  List<ForeignShop> get shops => List.unmodifiable(_shops);
  List<FoodridgeReservation> get reservations => List.unmodifiable(_reservations);

  ForeignShop shopById(String id) => _shops.firstWhere((s) => s.id == id);

  List<FoodridgeMenuItem> menuItemsFor(String storeId) {
    final list = _menuItems.where((m) => m.storeId == storeId).toList();
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  int remainingCountForStore(String storeId) =>
      _menuItems.where((m) => m.storeId == storeId).fold<int>(0, (sum, m) {
        if (m.remainingQty <= 0) return sum;
        return sum + m.remainingQty;
      });

  int? minPriceForStore(String storeId) {
    final available = _menuItems
        .where((m) => m.storeId == storeId && m.remainingQty > 0)
        .toList();
    if (available.isEmpty) return null;
    available.sort((a, b) => a.price.compareTo(b.price));
    return available.first.price;
  }

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

  List<FoodridgeReservation> reservationsFor(String userId) {
    return _reservations.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // --------------------
  // Cart (local)
  // --------------------
  List<FoodridgeCartLine> cartFor(String userId) {
    final list =
        _cartLines.where((c) => c.userId == userId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int cartTotalFor(String userId) =>
      cartFor(userId).fold<int>(0, (sum, line) => sum + line.lineTotal);

  String? addToCart({
    required String userId,
    required String menuItemId,
    int qty = 1,
  }) {
    if (qty <= 0) return 'Invalid quantity.';
    final mIdx = _menuItems.indexWhere((m) => m.id == menuItemId);
    if (mIdx < 0) return 'Menu item not found.';
    final item = _menuItems[mIdx];
    if (item.remainingQty < qty) return 'Not enough stock.';

    // Deduct stock immediately for demo simplicity.
    _menuItems[mIdx] = item.copyWith(remainingQty: item.remainingQty - qty);

    final existingIdx = _cartLines.indexWhere(
      (l) => l.userId == userId && l.menuItemId == menuItemId,
    );
    if (existingIdx >= 0) {
      final existing = _cartLines[existingIdx];
      _cartLines[existingIdx] = existing.copyWith(qty: existing.qty + qty);
    } else {
      _cartLines.add(
        FoodridgeCartLine(
          id: 'fc-${DateTime.now().millisecondsSinceEpoch}-$menuItemId',
          userId: userId,
          menuItemId: menuItemId,
          storeId: item.storeId,
          menuItemName: item.name,
          unitPrice: item.price,
          qty: qty,
          createdAt: DateTime.now(),
        ),
      );
    }
    notifyListeners();
    return null;
  }

  void removeCartLine({
    required String userId,
    required String cartLineId,
  }) {
    final idx = _cartLines.indexWhere(
      (l) => l.userId == userId && l.id == cartLineId,
    );
    if (idx < 0) return;
    final line = _cartLines[idx];

    final mIdx = _menuItems.indexWhere((m) => m.id == line.menuItemId);
    if (mIdx >= 0) {
      final item = _menuItems[mIdx];
      _menuItems[mIdx] = item.copyWith(remainingQty: item.remainingQty + line.qty);
    }

    _cartLines.removeAt(idx);
    notifyListeners();
  }

  String? checkoutCart({required String userId}) {
    final lines = cartFor(userId);
    if (lines.isEmpty) return 'Cart is empty.';

    // One reservation per store (so review is also per store).
    final byStore = <String, List<FoodridgeCartLine>>{};
    for (final l in lines) {
      byStore.putIfAbsent(l.storeId, () => []).add(l);
    }

    for (final entry in byStore.entries) {
      final storeId = entry.key;
      final store = shopById(storeId);
      final storeLines = entry.value;
      final total = storeLines.fold<int>(0, (sum, l) => sum + l.lineTotal);
      final itemLabel = storeLines.length == 1
          ? storeLines.first.menuItemName
          : '${storeLines.length} items in cart';

      _reservations.add(
        FoodridgeReservation(
          id: 'fr-${DateTime.now().millisecondsSinceEpoch}-$storeId',
          userId: userId,
          shopId: storeId,
          shopName: store.name,
          itemLabel: itemLabel,
          price: total,
          createdAt: DateTime.now(),
        ),
      );
    }

    _cartLines.removeWhere((l) => l.userId == userId);
    notifyListeners();
    return null;
  }

  // --------------------
  // Owner demo: add menu items
  // --------------------
  String? addMenuItem({
    required String storeId,
    required String name,
    required int price,
    required int remainingQty,
    String? photoAsset,
  }) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'Menu name is required.';
    if (price <= 0) return 'Price must be greater than 0.';
    if (remainingQty <= 0) return 'Remaining stock must be greater than 0.';

    _menuItems.add(
      FoodridgeMenuItem(
        id: 'mi-${DateTime.now().millisecondsSinceEpoch}',
        storeId: storeId,
        name: trimmed,
        price: price,
        remainingQty: remainingQty,
        photoAsset: photoAsset,
      ),
    );
    notifyListeners();
    return null;
  }

  // --------------------
  // Reservations & reviews (Foodridge2-style)
  // --------------------
  FoodridgeReservation? createReservation({
    required String userId,
    required String shopId,
  }) {
    // Backward compatibility: create a single booking if any menu item is available.
    final min = minPriceForStore(shopId);
    if (min == null) return null;
    final shop = shopById(shopId);
    final reservation = FoodridgeReservation(
      id: 'fr-${DateTime.now().millisecondsSinceEpoch}-$shopId',
      userId: userId,
      shopId: shopId,
      shopName: shop.name,
      itemLabel: shop.surplusLabel ?? 'Surplus box',
      price: shop.surplusPrice ?? min,
      createdAt: DateTime.now(),
    );
    _reservations.add(reservation);
    notifyListeners();
    return reservation;
  }

  void cancelReservation(String id) {
    final i = _reservations.indexWhere((r) => r.id == id);
    if (i < 0) return;
    if (_reservations[i].status != FoodridgeReservationStatus.reserved) return;
    _reservations[i].status = FoodridgeReservationStatus.cancelled;
    notifyListeners();
  }

  /// GPS check-in (no stamp).
  Future<ArrivalResult> verifyArrival(
    String reservationId, {
    bool bypassGps = false,
  }) async {
    final idx = _reservations.indexWhere((r) => r.id == reservationId);
    if (idx < 0) {
      return const ArrivalResult(success: false, message: 'Booking not found.');
    }
    final reservation = _reservations[idx];
    final shop = shopById(reservation.shopId);
    if (reservation.status != FoodridgeReservationStatus.reserved) {
      return const ArrivalResult(
        success: false,
        message: 'This booking is already checked in.',
      );
    }

    final ArrivalResult result;
    if (bypassGps) {
      result = const ArrivalResult(
        success: true,
        message: 'Demo check-in complete. You can write a review now.',
        distanceMeters: 0,
      );
    } else {
      result = await LocationService.verifyArrival(
        targetLat: shop.lat,
        targetLng: shop.lng,
      );
      if (!result.success) return result;
    }

    reservation.status = FoodridgeReservationStatus.arrived;
    reservation.arrivedAt = DateTime.now();
    notifyListeners();
    return result;
  }

  FoodridgeReservation? reviewableReservationFor(String userId, String shopId) {
    for (final r in _reservations) {
      if (r.userId == userId && r.shopId == shopId && r.canWriteReview) {
        return r;
      }
    }
    return null;
  }

  bool canWriteReviewFor(String userId, String shopId) =>
      reviewableReservationFor(userId, shopId) != null;

  String reviewBlockReason(String userId, String shopId) {
    final hasReserved = _reservations.any(
      (r) =>
          r.userId == userId &&
          r.shopId == shopId &&
          r.status == FoodridgeReservationStatus.reserved,
    );
    if (hasReserved) {
      return 'Complete GPS check-in at the kitchen to unlock reviews.';
    }
    return 'Book from cart first, then check in on-site to leave a review.';
  }

  String? addReview({
    required String userId,
    required String shopId,
    required String author,
    required int stars,
    required String comment,
    String? photoNote,
  }) {
    final reservation = reviewableReservationFor(userId, shopId);
    if (reservation == null) {
      return reviewBlockReason(userId, shopId);
    }
    if (comment.trim().isEmpty) return 'Please enter a review.';
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
    reservation.reviewed = true;
    reservation.status = FoodridgeReservationStatus.completed;
    notifyListeners();
    return null;
  }
}
