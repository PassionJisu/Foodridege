import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

enum SaleRequestStatus {
  pending('신청 완료'),
  collected('수거 완료'),
  cancelled('취소됨');

  final String label;
  const SaleRequestStatus(this.label);

  static SaleRequestStatus fromValue(String value) {
    return SaleRequestStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => SaleRequestStatus.pending,
    );
  }
}

class SaleRequest {
  const SaleRequest({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.branchName,
    required this.category,
    required this.quantity,
    required this.pricePerUnit,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String restaurantId;
  final String restaurantName;
  final String branchName;
  final ProductCategory category;
  final int quantity;
  final int pricePerUnit;
  final SaleRequestStatus status;
  final DateTime createdAt;

  int get totalPrice => quantity * pricePerUnit;

  factory SaleRequest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return SaleRequest(
      id: doc.id,
      restaurantId: data['restaurantId'] as String? ?? '',
      restaurantName: data['restaurantName'] as String? ?? '',
      branchName: data['branchName'] as String? ?? '',
      category: ProductCategory.fromValue(data['category'] as String? ?? 'processed'),
      quantity: data['quantity'] as int? ?? 0,
      pricePerUnit: data['pricePerUnit'] as int? ?? 0,
      status: SaleRequestStatus.fromValue(data['status'] as String? ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'branchName': branchName,
      'category': category.name,
      'quantity': quantity,
      'pricePerUnit': pricePerUnit,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
