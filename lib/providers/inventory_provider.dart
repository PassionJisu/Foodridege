import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';

class InventoryProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  /// 특정 지점의 모든 유효 상품 리스트
  List<Product> getProductsByBranch(String branchName) {
    return _products.where((p) => p.branchName == branchName && p.quantity > 0 && !p.isExpired).toList();
  }

  /// 특정 지점의 전체 음식 개수 (재고 합계)
  int getTotalCountByBranch(String branchName) {
    return getProductsByBranch(branchName).fold(0, (sum, p) => sum + p.quantity);
  }

  /// 특정 지점 내의 식당 목록 및 해당 식당의 상품 개수
  Map<String, int> getRestaurantsWithCount(String branchName) {
    final branchProducts = getProductsByBranch(branchName);
    final Map<String, int> restaurants = {};
    for (var product in branchProducts) {
      restaurants[product.donorName] = (restaurants[product.donorName] ?? 0) + product.quantity;
    }
    return restaurants;
  }

  /// 특정 지점 및 특정 식당의 상품 리스트
  List<Product> getProductsByRestaurant(String branchName, String restaurantName) {
    return getProductsByBranch(branchName).where((p) => p.donorName == restaurantName).toList();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products').get();
      _products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetInventory() async {
    try {
      final batch = _firestore.batch();
      final snapshot = await _firestore.collection('products').get();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'quantity': 0});
      }

      await batch.commit();
      await fetchProducts();
    } catch (e) {
      debugPrint('Error resetting inventory: $e');
    }
  }
}
