import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

enum OrderStatus {
  reserved('예약됨(장바구니)'),
  paid('결제완료');

  final String label;
  const OrderStatus(this.label);

  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => OrderStatus.reserved,
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.branchName,
    required this.restaurantName,
    required this.quantity,
    required this.status,
    required this.createdAt,
    this.paidAt,
  });

  final String id;
  final String userId;
  final String productId;
  final String productName;
  final int price;
  final String branchName;
  final String restaurantName;
  final int quantity;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? paidAt;

  factory OrderModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data();
      if (data == null) throw Exception('문서 데이터가 비어있습니다.');

      int parseNum(dynamic value) {
        if (value == null) return 0;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return OrderModel(
        id: doc.id,
        userId: data['userId'] as String? ?? '',
        productId: data['productId'] as String? ?? '',
        productName: data['productName'] as String? ?? '',
        price: parseNum(data['price']),
        branchName: data['branchName'] as String? ?? '',
        restaurantName: data['restaurantName'] as String? ?? '',
        quantity: parseNum(data['quantity']),
        status: OrderStatus.fromValue(data['status'] as String? ?? 'reserved'),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        paidAt: (data['paidAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      debugPrint('Error parsing order (ID: ${doc.id}): $e');
      rethrow;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'productId': productId,
      'productName': productName,
      'price': price,
      'branchName': branchName,
      'restaurantName': restaurantName,
      'quantity': quantity,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (paidAt != null) 'paidAt': Timestamp.fromDate(paidAt!),
    };
  }
}
