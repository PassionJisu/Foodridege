import 'dart:typed_data';

/// Foodridge menu item (store food) for demo cart/booking flow.
class FoodridgeMenuItem {
  const FoodridgeMenuItem({
    required this.id,
    required this.storeId,
    required this.name,
    required this.price,
    required this.remainingQty,
    this.photoAsset,
    this.photoPath,
    this.photoBytes,
  });

  final String id;
  final String storeId;
  final String name;
  final int price;
  final int remainingQty;
  final String? photoAsset;
  final String? photoPath;
  final Uint8List? photoBytes;

  FoodridgeMenuItem copyWith({int? remainingQty}) {
    return FoodridgeMenuItem(
      id: id,
      storeId: storeId,
      name: name,
      price: price,
      remainingQty: remainingQty ?? this.remainingQty,
      photoAsset: photoAsset,
      photoPath: photoPath,
      photoBytes: photoBytes,
    );
  }
}

