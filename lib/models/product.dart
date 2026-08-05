import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  bakery('베이커리'),
  sidedish('반찬/도시락'),
  processed('가공식품'),
  fresh('신선식품'),
  beverage('음료');

  final String label;
  const ProductCategory(this.label);

  factory ProductCategory.fromValue(String value) {
    return ProductCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ProductCategory.processed,
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    required this.donorName,
    required this.branchName,
    required this.createdAt,
  });

  final String id;
  final String name;
  final ProductCategory category;
  final int quantity;
  final int price;
  final String donorName;
  final String branchName;
  final DateTime createdAt;

  bool get isExpired {
    final now = DateTime.now();
    return now.difference(createdAt).inHours >= 24;
  }

  factory Product.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: ProductCategory.fromValue(data['category'] as String? ?? 'processed'),
      quantity: data['quantity'] as int? ?? 0,
      price: data['price'] as int? ?? 0,
      donorName: data['donorName'] as String? ?? '',
      branchName: data['branchName'] as String? ?? '늘찬 라운지 1호점',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category.name,
      'quantity': quantity,
      'price': price,
      'donorName': donorName,
      'branchName': branchName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
