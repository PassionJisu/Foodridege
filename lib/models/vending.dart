class VendingMachine {
  const VendingMachine({
    required this.id,
    required this.name,
    required this.location,
    this.stockingCompletedAt,
    this.disposedAt,
    this.disposalConfirmed = false,
  });

  final String id;
  final String name;
  final String location;
  final DateTime? stockingCompletedAt;
  final DateTime? disposedAt;
  final bool disposalConfirmed;

  /// 지점별 표시용 상한 (기사 전역 번호는 1~120).
  static const int maxSlots = 120;

  bool get isExpired {
    if (stockingCompletedAt == null) return false;
    return DateTime.now().difference(stockingCompletedAt!).inHours >= 24;
  }

  VendingMachine copyWith({
    DateTime? stockingCompletedAt,
    DateTime? disposedAt,
    bool? disposalConfirmed,
    bool clearStocking = false,
    bool clearDisposed = false,
  }) {
    return VendingMachine(
      id: id,
      name: name,
      location: location,
      stockingCompletedAt:
          clearStocking ? null : (stockingCompletedAt ?? this.stockingCompletedAt),
      disposedAt: clearDisposed ? null : (disposedAt ?? this.disposedAt),
      disposalConfirmed: disposalConfirmed ?? this.disposalConfirmed,
    );
  }
}

class VendingSlot {
  const VendingSlot({
    required this.id,
    required this.machineId,
    required this.displayNumber,
    required this.name,
    required this.quantity,
    this.photoAsset,
    this.createdAt,
  });

  final String id;
  final String machineId;
  /// 기사/이용자 노출 번호 (전역 1~120).
  final int displayNumber;
  final String name;
  final int quantity;
  final String? photoAsset;
  final DateTime? createdAt;

  int get slotUsage => quantity;
}
