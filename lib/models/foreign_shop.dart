import 'attached_photo.dart';

enum DietBadge { none, halal, vegan, vegetarian }

class ForeignShop {
  const ForeignShop({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.badge,
    this.partnerSurplus = false,
    this.surplusLabel,
    this.surplusPrice,
    this.photoAsset,
  });

  final String id;
  final String name;
  final String cuisine;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final DietBadge badge;
  final bool partnerSurplus;
  final String? surplusLabel;
  final int? surplusPrice;
  final String? photoAsset;
}

class ShopReview {
  const ShopReview({
    required this.id,
    required this.shopId,
    required this.author,
    required this.stars,
    required this.comment,
    required this.createdAt,
    this.photo,
  });

  final String id;
  final String shopId;
  final String author;
  final int stars;
  final String comment;
  final DateTime createdAt;
  final AttachedPhoto? photo;
}
