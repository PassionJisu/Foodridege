import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/foodridge_reservation.dart';
import '../models/foreign_shop.dart';
import '../services/location_service.dart';

class FoodridgeProvider with ChangeNotifier {
  FoodridgeProvider() {
    _shops = List.of(SeedData.shops);
    _reviews = List.of(SeedData.shopReviews);
  }

  late List<ForeignShop> _shops;
  late List<ShopReview> _reviews;
  final List<FoodridgeReservation> _reservations = [];

  List<ForeignShop> get shops => List.unmodifiable(_shops);
  List<FoodridgeReservation> get reservations => List.unmodifiable(_reservations);

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

  List<FoodridgeReservation> reservationsFor(String userId) {
    return _reservations.where((r) => r.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  FoodridgeReservation? createReservation({
    required String userId,
    required String shopId,
  }) {
    final shop = shopById(shopId);
    if (!shop.partnerSurplus) return null;
    final reservation = FoodridgeReservation(
      id: 'fr-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      shopId: shopId,
      shopName: shop.name,
      itemLabel: shop.surplusLabel ?? 'Surprise bag',
      price: shop.surplusPrice ?? 0,
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

  /// Foodridge2 verifyArrival — 스탬프 적립 없이 도착만 처리.
  Future<ArrivalResult> verifyArrival(
    String reservationId, {
    bool bypassGps = false,
  }) async {
    final idx = _reservations.indexWhere((r) => r.id == reservationId);
    if (idx < 0) {
      return const ArrivalResult(success: false, message: '예약을 찾을 수 없어요.');
    }
    final reservation = _reservations[idx];
    final shop = shopById(reservation.shopId);
    if (reservation.status != FoodridgeReservationStatus.reserved) {
      return const ArrivalResult(success: false, message: '이미 도착 확인된 예약이에요.');
    }

    final ArrivalResult result;
    if (bypassGps) {
      result = const ArrivalResult(
        success: true,
        message: '데모 도착 처리되었습니다. 이제 리뷰를 작성할 수 있어요.',
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
      return '가게에 도착한 뒤 GPS 도착 확인을 완료하면 리뷰를 작성할 수 있어요.';
    }
    return '서플러스 박스를 예약한 뒤, 현장에서 도착 확인을 해야 리뷰를 쓸 수 있어요.';
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
    if (comment.trim().isEmpty) return '리뷰 내용을 입력해 주세요.';
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
