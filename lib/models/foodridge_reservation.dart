enum FoodridgeReservationStatus { reserved, arrived, completed, cancelled }

extension FoodridgeReservationStatusX on FoodridgeReservationStatus {
  String get label => switch (this) {
        FoodridgeReservationStatus.reserved => 'Booked',
        FoodridgeReservationStatus.arrived => 'Checked in',
        FoodridgeReservationStatus.completed => 'Completed',
        FoodridgeReservationStatus.cancelled => 'Cancelled',
      };
}

enum FoodridgePaymentMethod { onSite, inApp }

extension FoodridgePaymentMethodX on FoodridgePaymentMethod {
  String get label => switch (this) {
        FoodridgePaymentMethod.onSite => 'Pay at store',
        FoodridgePaymentMethod.inApp => 'Pay in app',
      };

  String get pickupNote => switch (this) {
        FoodridgePaymentMethod.onSite =>
          'Pay when you pick up at the kitchen.',
        FoodridgePaymentMethod.inApp =>
          'Paid in app. Pick up at the kitchen.',
      };
}

/// Foodridge2 Reservation 모델을 Final 더미 데이터에 맞게 단순화 (스탬프 제외).
class FoodridgeReservation {
  FoodridgeReservation({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.shopName,
    required this.itemLabel,
    required this.price,
    required this.createdAt,
    this.status = FoodridgeReservationStatus.reserved,
    this.paymentMethod = FoodridgePaymentMethod.onSite,
    this.paid = false,
    this.arrivedAt,
    this.reviewed = false,
  });

  final String id;
  final String userId;
  final String shopId;
  final String shopName;
  final String itemLabel;
  final int price;
  final DateTime createdAt;
  FoodridgeReservationStatus status;
  FoodridgePaymentMethod paymentMethod;
  bool paid;
  DateTime? arrivedAt;
  bool reviewed;

  bool get canWriteReview =>
      !reviewed &&
      (status == FoodridgeReservationStatus.arrived ||
          status == FoodridgeReservationStatus.completed);
}
