import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/sale_request.dart';
import '../models/product.dart';

class SaleProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<SaleRequest> _mySaleRequests = [];
  List<SaleRequest> _allSaleRequests = [];
  bool _isLoading = false;

  List<SaleRequest> get mySaleRequests => _mySaleRequests;
  List<SaleRequest> get allSaleRequests => _allSaleRequests;
  bool get isLoading => _isLoading;

  /// [Driver/Admin 전용] 모든 신청 내역 가져오기
  Future<void> fetchAllSaleRequests() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('sale_requests').get();
      _allSaleRequests = snapshot.docs.map((doc) => SaleRequest.fromFirestore(doc)).toList();
      _allSaleRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('Error fetching all sale requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 상태 업데이트 로직
  Future<bool> updateSaleRequestStatus(String requestId, SaleRequestStatus status) async {
    try {
      await _firestore.collection('sale_requests').doc(requestId).update({
        'status': status.name,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating sale request status: $e');
      return false;
    }
  }

  Future<void> fetchMySaleRequests(String restaurantId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 인덱스 문제 방지를 위해 orderBy를 제거하고 클라이언트 사이드 정렬 적용
      final snapshot = await _firestore
          .collection('sale_requests')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();
      
      _mySaleRequests = snapshot.docs.map((doc) => SaleRequest.fromFirestore(doc)).toList();
      
      // 최신순 정렬 (클라이언트 사이드)
      _mySaleRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      debugPrint('Fetched ${_mySaleRequests.length} sale requests for restaurant: $restaurantId');
    } catch (e) {
      debugPrint('Error fetching sale requests: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitSaleRequest({
    required String restaurantId,
    required String restaurantName,
    required String branchName,
    required ProductCategory category,
    required int quantity,
    required int pricePerUnit,
  }) async {
    try {
      await _firestore.collection('sale_requests').add({
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'branchName': branchName,
        'category': category.name,
        'quantity': quantity,
        'pricePerUnit': pricePerUnit,
        'status': SaleRequestStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchMySaleRequests(restaurantId);
      return true;
    } catch (e) {
      debugPrint('Error submitting sale request: $e');
      return false;
    }
  }

  /// 다중 품목 신청 (Batch 처리)
  Future<bool> submitMultipleSaleRequests({
    required String restaurantId,
    required String restaurantName,
    required String branchName,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final batch = _firestore.batch();
      for (var item in items) {
        final docRef = _firestore.collection('sale_requests').doc();
        batch.set(docRef, {
          'restaurantId': restaurantId,
          'restaurantName': restaurantName,
          'branchName': branchName,
          'category': (item['category'] as ProductCategory).name,
          'quantity': item['quantity'],
          'pricePerUnit': item['pricePerUnit'],
          'status': SaleRequestStatus.pending.name,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
      await fetchMySaleRequests(restaurantId);
      return true;
    } catch (e) {
      debugPrint('Error submitting multiple sale requests: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 월별 정산 합계 계산
  int getMonthlySettlementAmount(int year, int month) {
    return _mySaleRequests
        .where((req) => 
            req.status == SaleRequestStatus.collected &&
            req.createdAt.year == year && 
            req.createdAt.month == month)
        .fold(0, (total, req) => total + req.totalPrice);
  }
}
