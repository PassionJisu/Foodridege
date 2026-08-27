import 'package:flutter/material.dart';

import '../models/attached_photo.dart';
import '../models/product.dart';
import '../models/sale_request.dart';

/// 데모용 로컬 SaleProvider (DB 없음). 기관 입고 신청 → 신청 내역으로 연결.
class SaleProvider with ChangeNotifier {
  SaleProvider() {
    _seedDemo();
  }

  final List<SaleRequest> _requests = [];
  bool _isLoading = false;

  List<SaleRequest> get mySaleRequests => List.unmodifiable(
        [..._requests]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );
  List<SaleRequest> get allSaleRequests => mySaleRequests;
  bool get isLoading => _isLoading;

  void _seedDemo() {
    final now = DateTime.now();
    _requests.addAll([
      SaleRequest(
        id: 'sr-demo-1',
        restaurantId: 'org-demo',
        restaurantName: '광주광역시 식자재지원센터',
        branchName: '환승반찬 입고',
        category: ProductCategory.sidedish,
        quantity: 12,
        pricePerUnit: 0,
        status: SaleRequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
        photoAsset: 'assets/images/shop_bibimbap.png',
        itemLabel: '시금치나물',
      ),
      SaleRequest(
        id: 'sr-demo-2',
        restaurantId: 'org-demo',
        restaurantName: '광주 농식품유통센터',
        branchName: '환승반찬 입고',
        category: ProductCategory.fresh,
        quantity: 8,
        pricePerUnit: 0,
        status: SaleRequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 8)),
      ),
      SaleRequest(
        id: 'sr-demo-3',
        restaurantId: 'org-demo',
        restaurantName: '호남대 근처 공동부엌',
        branchName: '환승반찬 입고',
        category: ProductCategory.sidedish,
        quantity: 20,
        pricePerUnit: 0,
        status: SaleRequestStatus.collected,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      SaleRequest(
        id: 'sr-demo-4',
        restaurantId: 'org-demo',
        restaurantName: '조선대 기숙사 식당 지원',
        branchName: '환승반찬 입고',
        category: ProductCategory.processed,
        quantity: 15,
        pricePerUnit: 0,
        status: SaleRequestStatus.stocked,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
    ]);
  }

  Future<void> fetchAllSaleRequests() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMySaleRequests(String restaurantId) async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateSaleRequestStatus(
    String requestId,
    SaleRequestStatus status,
  ) async {
    final i = _requests.indexWhere((r) => r.id == requestId);
    if (i < 0) return false;
    final old = _requests[i];
    _requests[i] = SaleRequest(
      id: old.id,
      restaurantId: old.restaurantId,
      restaurantName: old.restaurantName,
      branchName: old.branchName,
      category: old.category,
      quantity: old.quantity,
      pricePerUnit: old.pricePerUnit,
      status: status,
      createdAt: old.createdAt,
      photoAsset: old.photoAsset,
      photoPath: old.photoPath,
      photoBytes: old.photoBytes,
      itemLabel: old.itemLabel,
    );
    notifyListeners();
    return true;
  }

  Future<bool> submitOrgSupplyItems({
    required String orgId,
    required String orgName,
    required List<({String name, int qty, String note, AttachedPhoto? photo})>
        items,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      for (final item in items) {
        _requests.add(
          SaleRequest(
            id: 'sr-${DateTime.now().millisecondsSinceEpoch}-${item.name.hashCode}',
            restaurantId: orgId,
            restaurantName: orgName,
            branchName: '환승반찬 입고 · ${item.name}',
            category: ProductCategory.sidedish,
            quantity: item.qty,
            pricePerUnit: 0,
            status: SaleRequestStatus.pending,
            createdAt: DateTime.now(),
            photoAsset: item.photo?.assetPath,
            photoPath: item.photo?.filePath,
            photoBytes: item.photo?.bytes,
            itemLabel: item.name,
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 레거시 잔반 신청 화면 호환용 (데모).
  Future<bool> submitMultipleSaleRequests({
    required String restaurantId,
    required String restaurantName,
    required String branchName,
    required List<Map<String, dynamic>> items,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      for (final item in items) {
        final category = item['category'] as ProductCategory? ?? ProductCategory.sidedish;
        final quantity = item['quantity'] as int? ?? 0;
        final price = item['pricePerUnit'] as int? ?? 0;
        if (quantity <= 0) continue;
        _requests.add(
          SaleRequest(
            id: 'sr-${DateTime.now().millisecondsSinceEpoch}-${category.name}',
            restaurantId: restaurantId,
            restaurantName: restaurantName,
            branchName: branchName,
            category: category,
            quantity: quantity,
            pricePerUnit: price,
            status: SaleRequestStatus.pending,
            createdAt: DateTime.now(),
          ),
        );
        await Future<void>.delayed(const Duration(milliseconds: 5));
      }
      return true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getMonthlySettlementAmount(int year, int month) {
    return _requests
        .where(
          (req) =>
              req.status == SaleRequestStatus.collected &&
              req.createdAt.year == year &&
              req.createdAt.month == month,
        )
        .fold(0, (total, req) => total + req.totalPrice);
  }
}
