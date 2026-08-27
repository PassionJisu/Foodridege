import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'product.dart';

enum SaleRequestStatus {
  pending('신청 완료'),
  collected('수거 완료'),
  stocked('입고 완료'),
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
    this.photoAsset,
    this.photoPath,
    this.photoBytes,
    this.itemLabel,
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
  final String? photoAsset;
  final String? photoPath;
  final Uint8List? photoBytes;
  final String? itemLabel;

  int get totalPrice => quantity * pricePerUnit;

  factory SaleRequest.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final data = doc.data();
      if (data == null) throw Exception('문서 데이터가 비어있습니다.');

      int parseNum(dynamic value) {
        if (value == null) return 0;
        if (value is num) return value.toInt();
        if (value is String) return int.tryParse(value) ?? 0;
        return 0;
      }

      return SaleRequest(
        id: doc.id,
        restaurantId: data['restaurantId'] as String? ?? '',
        restaurantName: data['restaurantName'] as String? ?? '',
        branchName: data['branchName'] as String? ?? '',
        category: ProductCategory.fromValue(data['category'] as String? ?? 'processed'),
        quantity: parseNum(data['quantity']),
        pricePerUnit: parseNum(data['pricePerUnit']),
        status: SaleRequestStatus.fromValue(data['status'] as String? ?? 'pending'),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        photoAsset: data['photoAsset'] as String?,
        photoPath: data['photoPath'] as String?,
        itemLabel: data['itemLabel'] as String?,
      );
    } catch (e) {
      debugPrint('Error parsing sale request (ID: ${doc.id}): $e');
      rethrow;
    }
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
      if (photoAsset != null) 'photoAsset': photoAsset,
      if (photoPath != null) 'photoPath': photoPath,
      if (itemLabel != null) 'itemLabel': itemLabel,
    };
  }
}
