import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/sale_request.dart';

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
    return getProductsByBranch(branchName).fold(0, (total, p) => total + p.quantity);
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

  /// 매매 신청 내역을 바탕으로 실제 재고로 입고 처리
  Future<bool> addStockFromRequest(SaleRequest request) async {
    _isLoading = true;
    notifyListeners();

    try {
      final productsRef = _firestore.collection('products');
      
      // 동일한 식당, 동일한 지점, 동일한 카테고리의 상품이 있는지 확인 (고도화 포인트)
      // 여기서는 매번 새로운 상품 문서로 등록하거나, 기존 문서 업데이트 로직 선택 가능
      // 기획안에 따라 '신규 입고'로 처리하여 새로운 문서를 생성합니다.
      
      await productsRef.add({
        'name': '[수거] ${request.category.label}',
        'category': request.category.name,
        'quantity': request.quantity,
        'price': request.pricePerUnit,
        'donorName': request.restaurantName,
        'branchName': request.branchName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint('Error adding stock from request: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('products').get();
      final List<Product> loadedProducts = [];
      
      for (var doc in snapshot.docs) {
        try {
          loadedProducts.add(Product.fromFirestore(doc));
        } catch (e) {
          // 특정 문서 하나가 잘못되어도 나머지는 보여주도록 개별 try-catch
          debugPrint('Skipping invalid product doc: ${doc.id}');
        }
      }
      
      _products = loadedProducts;
      debugPrint('Successfully loaded ${_products.length} products.');
    } catch (e) {
      debugPrint('Error fetching products collection: $e');
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

  /// 테스트용 데모 데이터 생성 (늘찬 라운지 1호점)
  Future<void> seedDemoData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final batch = _firestore.batch();
      final productsRef = _firestore.collection('products');

      final List<Map<String, dynamic>> demoData = [
        {
          'name': '맛있는 제육볶음',
          'category': ProductCategory.sidedish.name,
          'quantity': 5,
          'price': 5000,
          'donorName': '맛나식당',
          'branchName': '늘찬 라운지 1호점',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': '엄마표 멸치볶음',
          'category': ProductCategory.sidedish.name,
          'quantity': 10,
          'price': 3000,
          'donorName': '학생식당',
          'branchName': '늘찬 라운지 1호점',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': '수제 치즈버거',
          'category': ProductCategory.processed.name,
          'quantity': 3,
          'price': 7000,
          'donorName': '청년버거',
          'branchName': '늘찬 라운지 1호점',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': '된장찌개 밀키트',
          'category': ProductCategory.fresh.name,
          'quantity': 4,
          'price': 6000,
          'donorName': '든든한식',
          'branchName': '늘찬 라운지 1호점',
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'name': '시원한 아이스 아메리카노',
          'category': ProductCategory.beverage.name,
          'quantity': 8,
          'price': 2500,
          'donorName': '카페루루',
          'branchName': '늘찬 라운지 1호점',
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];

      for (var data in demoData) {
        batch.set(productsRef.doc(), data);
      }

      await batch.commit();
      await fetchProducts();
    } catch (e) {
      debugPrint('Error seeding demo data: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
