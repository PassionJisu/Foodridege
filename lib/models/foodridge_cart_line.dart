/// Cart line for Foodridge demo (no backend).
class FoodridgeCartLine {
  const FoodridgeCartLine({
    required this.id,
    required this.userId,
    required this.menuItemId,
    required this.storeId,
    required this.menuItemName,
    required this.unitPrice,
    required this.qty,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String menuItemId;
  final String storeId;
  final String menuItemName;
  final int unitPrice;
  final int qty;
  final DateTime createdAt;

  int get lineTotal => unitPrice * qty;

  FoodridgeCartLine copyWith({String? id, int? qty}) {
    return FoodridgeCartLine(
      id: id ?? this.id,
      userId: userId,
      menuItemId: menuItemId,
      storeId: storeId,
      menuItemName: menuItemName,
      unitPrice: unitPrice,
      qty: qty ?? this.qty,
      createdAt: createdAt,
    );
  }
}

