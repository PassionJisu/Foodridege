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

  static const int maxSlots = 20;

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
    required this.internalCode,
    required this.name,
    required this.quantity,
    this.photoAsset,
    this.createdAt,
  });

  final String id;
  final String machineId;
  /// User/driver facing number, always 1–20.
  final int displayNumber;
  /// Machine-specific internal identifier.
  final String internalCode;
  final String name;
  final int quantity;
  final String? photoAsset;
  final DateTime? createdAt;

  int get slotUsage => quantity;
}
