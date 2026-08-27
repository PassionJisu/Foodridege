import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/attached_photo.dart';
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
  final List<FoodridgeCartLine> _draftLines = [];

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
    return _reservations
        .where(
          (r) =>
              r.userId == userId &&
              r.status != FoodridgeReservationStatus.cancelled,
        )
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // --------------------
  // Cart (local) & shop draft (temporary hold on restaurant page)
  // --------------------
  List<FoodridgeCartLine> cartFor(String userId) {
    final list =
        _cartLines.where((c) => c.userId == userId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int cartTotalFor(String userId) =>
      cartFor(userId).fold<int>(0, (sum, line) => sum + line.lineTotal);

  int cartCountFor(String userId) =>
      cartFor(userId).fold<int>(0, (sum, line) => sum + line.qty);

  List<FoodridgeCartLine> draftFor(String userId, String storeId) {
    final list = _draftLines
        .where((c) => c.userId == userId && c.storeId == storeId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  int draftTotalFor(String userId, String storeId) =>
      draftFor(userId, storeId).fold<int>(0, (sum, line) => sum + line.lineTotal);

  int draftCountFor(String userId, String storeId) =>
      draftFor(userId, storeId).fold<int>(0, (sum, line) => sum + line.qty);

  int draftQtyFor({
    required String userId,
    required String menuItemId,
  }) {
    return _draftLines
        .where((l) => l.userId == userId && l.menuItemId == menuItemId)
        .fold<int>(0, (sum, l) => sum + l.qty);
  }

  String? addToDraft({
    required String userId,
    required String menuItemId,
    int qty = 1,
  }) {
    return _addToLines(
      target: _draftLines,
      userId: userId,
      menuItemId: menuItemId,
      qty: qty,
    );
  }

  void decrementDraft({
    required String userId,
    required String menuItemId,
  }) {
    final idx = _draftLines.indexWhere(
      (l) => l.userId == userId && l.menuItemId == menuItemId,
    );
    if (idx < 0) return;
    final line = _draftLines[idx];
    _restoreStock(line.menuItemId, 1);
    if (line.qty <= 1) {
      _draftLines.removeAt(idx);
    } else {
      _draftLines[idx] = line.copyWith(qty: line.qty - 1);
    }
    notifyListeners();
  }

  String? addToCart({
    required String userId,
    required String menuItemId,
    int qty = 1,
  }) {
    return _addToLines(
      target: _cartLines,
      userId: userId,
      menuItemId: menuItemId,
      qty: qty,
    );
  }

  String? _addToLines({
    required List<FoodridgeCartLine> target,
    required String userId,
    required String menuItemId,
    int qty = 1,
  }) {
    if (qty <= 0) return 'Invalid quantity.';
    final mIdx = _menuItems.indexWhere((m) => m.id == menuItemId);
    if (mIdx < 0) return 'Menu item not found.';
    final item = _menuItems[mIdx];
    if (item.remainingQty < qty) return 'Not enough stock.';

    _menuItems[mIdx] = item.copyWith(remainingQty: item.remainingQty - qty);

    final existingIdx = target.indexWhere(
      (l) => l.userId == userId && l.menuItemId == menuItemId,
    );
    if (existingIdx >= 0) {
      final existing = target[existingIdx];
      target[existingIdx] = existing.copyWith(qty: existing.qty + qty);
    } else {
      target.add(
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

  void _restoreStock(String menuItemId, int qty) {
    final mIdx = _menuItems.indexWhere((m) => m.id == menuItemId);
    if (mIdx < 0) return;
    final item = _menuItems[mIdx];
    _menuItems[mIdx] = item.copyWith(remainingQty: item.remainingQty + qty);
  }

  String? commitDraftToCart({
    required String userId,
    required String storeId,
  }) {
    final drafts = draftFor(userId, storeId);
    if (drafts.isEmpty) return 'Select a menu item first.';

    for (final line in drafts) {
      final existingIdx = _cartLines.indexWhere(
        (l) => l.userId == userId && l.menuItemId == line.menuItemId,
      );
      if (existingIdx >= 0) {
        final existing = _cartLines[existingIdx];
        _cartLines[existingIdx] = existing.copyWith(qty: existing.qty + line.qty);
      } else {
        _cartLines.add(
          line.copyWith(
            id: 'fc-${DateTime.now().millisecondsSinceEpoch}-${line.menuItemId}',
          ),
        );
      }
    }
    _draftLines.removeWhere(
      (l) => l.userId == userId && l.storeId == storeId,
    );
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
    _restoreStock(line.menuItemId, line.qty);
    _cartLines.removeAt(idx);
    notifyListeners();
  }

  String? checkoutCart({
    required String userId,
    FoodridgePaymentMethod paymentMethod = FoodridgePaymentMethod.onSite,
    bool paid = false,
  }) {
    return _checkoutLines(
      userId: userId,
      lines: cartFor(userId),
      paymentMethod: paymentMethod,
      paid: paid,
      clearCart: true,
    );
  }

  String? checkoutDraft({
    required String userId,
    required String storeId,
    FoodridgePaymentMethod paymentMethod = FoodridgePaymentMethod.onSite,
    bool paid = false,
  }) {
    return _checkoutLines(
      userId: userId,
      lines: draftFor(userId, storeId),
      paymentMethod: paymentMethod,
      paid: paid,
      clearDraftStoreId: storeId,
    );
  }

  String? _checkoutLines({
    required String userId,
    required List<FoodridgeCartLine> lines,
    required FoodridgePaymentMethod paymentMethod,
    required bool paid,
    bool clearCart = false,
    String? clearDraftStoreId,
  }) {
    if (lines.isEmpty) return 'Nothing to check out.';

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
          : '${storeLines.length} items';

      _reservations.add(
        FoodridgeReservation(
          id: 'fr-${DateTime.now().millisecondsSinceEpoch}-$storeId',
          userId: userId,
          shopId: storeId,
          shopName: store.name,
          itemLabel: itemLabel,
          price: total,
          createdAt: DateTime.now(),
          paymentMethod: paymentMethod,
          paid: paid || paymentMethod == FoodridgePaymentMethod.inApp,
        ),
      );
    }

    if (clearCart) {
      _cartLines.removeWhere((l) => l.userId == userId);
    }
    if (clearDraftStoreId != null) {
      _draftLines.removeWhere(
        (l) => l.userId == userId && l.storeId == clearDraftStoreId,
      );
    }
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
    String? photoPath,
    Uint8List? photoBytes,
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
        photoPath: photoPath,
        photoBytes: photoBytes,
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
    _reservations.removeWhere(
      (r) =>
          r.id == id && r.status == FoodridgeReservationStatus.reserved,
    );
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
    AttachedPhoto? photo,
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
        photo: photo,
      ),
    );
    reservation.reviewed = true;
    reservation.status = FoodridgeReservationStatus.completed;
    notifyListeners();
    return null;
  }
}
