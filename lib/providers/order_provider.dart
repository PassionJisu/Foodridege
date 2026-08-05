import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../models/order.dart';
import '../models/product.dart';

class OrderProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderModel> _myCart = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<OrderModel> get myCart => _myCart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyCart(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: OrderStatus.reserved.name)
          .get();
      _myCart = snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching cart: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 장바구니 담기 (예약) - 즉시 재고 및 한도 차감
  Future<bool> reserveItem({
    required AppUser user,
    required Product product,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. 오늘 주문/예약 수량 확인 (1일 4개 제한)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      
      final todayOrders = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .get();

      int totalOrderedToday = 0;
      for (var doc in todayOrders.docs) {
        totalOrderedToday += (doc.data()['quantity'] as int? ?? 0);
      }

      if (totalOrderedToday + 1 > 4) {
        _errorMessage = '1인당 1일 최대 4개까지만 구매/예약 가능합니다. (현재 가능: ${4 - totalOrderedToday}개)';
        return false;
      }

      // 2. 트랜잭션: 재고 차감 및 예약 문서 생성
      await _firestore.runTransaction((transaction) async {
        final productRef = _firestore.collection('products').doc(product.id);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) throw Exception('상품이 존재하지 않습니다.');

        final currentStock = productDoc.data()!['quantity'] as int;
        if (currentStock < 1) throw Exception('재고가 부족합니다.');

        transaction.update(productRef, {'quantity': currentStock - 1});

        final orderRef = _firestore.collection('orders').doc();
        transaction.set(orderRef, {
          'userId': user.uid,
          'productId': product.id,
          'productName': product.name,
          'price': product.price,
          'branchName': product.branchName,
          'restaurantName': product.donorName,
          'quantity': 1,
          'status': OrderStatus.reserved.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      await fetchMyCart(user.uid);
      return true;
    } catch (e) {
      _errorMessage = '장바구니 담기에 실패했습니다: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 예약 취소 (롤백) - 재고 및 한도 즉시 복구
  Future<bool> cancelReservation(OrderModel order) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.runTransaction((transaction) async {
        final productRef = _firestore.collection('products').doc(order.productId);
        final productDoc = await transaction.get(productRef);
        
        if (productDoc.exists) {
          final currentStock = productDoc.data()!['quantity'] as int;
          transaction.update(productRef, {'quantity': currentStock + order.quantity});
        }

        transaction.delete(_firestore.collection('orders').doc(order.id));
      });
      await fetchMyCart(order.userId);
      return true;
    } catch (e) {
      _errorMessage = '예약 취소에 실패했습니다: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 결제 확정
  Future<bool> confirmPayment(String userId, List<OrderModel> orders) async {
    if (orders.isEmpty) return false;
    _isLoading = true;
    notifyListeners();

    try {
      await _firestore.runTransaction((transaction) async {
        final userRef = _firestore.collection('users').doc(userId);
        final userDoc = await transaction.get(userRef);
        final userData = userDoc.data()!;

        // 1. 주문 상태 변경
        for (var order in orders) {
          transaction.update(_firestore.collection('orders').doc(order.id), {
            'status': OrderStatus.paid.name,
            'paidAt': FieldValue.serverTimestamp(),
          });
        }

        // 2. 구매 혜택 (누적 3일 구매 시 무료 쿠폰)
        final lastOrderDate = (userData['lastOrderDate'] as Timestamp?)?.toDate();
        final now = DateTime.now();
        final startOfToday = DateTime(now.year, now.month, now.day);
        
        bool isNewDay = lastOrderDate == null || 
            DateTime(lastOrderDate.year, lastOrderDate.month, lastOrderDate.day).isBefore(startOfToday);

        int purchaseDayCount = userData['purchaseDayCount'] as int? ?? 0;
        int freeMealCount = userData['freeMealCount'] as int? ?? 0;
        int totalUsageCount = (userData['totalUsageCount'] as int? ?? 0) + orders.length;

        if (isNewDay) {
          purchaseDayCount += 1;
          if (purchaseDayCount >= 3) {
            freeMealCount += 1;
            purchaseDayCount = 0; // 초기화
          }
        }

        transaction.update(userRef, {
          'lastOrderDate': FieldValue.serverTimestamp(),
          'purchaseDayCount': purchaseDayCount,
          'freeMealCount': freeMealCount,
          'totalUsageCount': totalUsageCount,
        });
      });
      await fetchMyCart(userId);
      return true;
    } catch (e) {
      _errorMessage = '결제 처리 중 오류가 발생했습니다: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
