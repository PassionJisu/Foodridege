import 'package:flutter/material.dart';

import '../data/org_locations.dart';
import '../models/attached_photo.dart';
import '../models/product.dart';
import '../models/sale_request.dart';
import 'vending_provider.dart';

/// 데모용 로컬 SaleProvider (DB 없음). 기관 수거 신청 → 번호 배정 → 신청 내역.
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

  List<SaleRequest> get pendingPickups =>
      _requests.where((r) => r.status == SaleRequestStatus.pending).toList();

  List<SaleRequest> get collectedForStocking =>
      _requests.where((r) => r.status == SaleRequestStatus.collected).toList()
        ..sort((a, b) => (a.displayNumber ?? 9999).compareTo(b.displayNumber ?? 9999));

  void _seedDemo() {
    final now = DateTime.now();
    final loc1 = OrgLocations.resolve('광주광역시 식자재지원센터');
    final loc2 = OrgLocations.resolve('광주 농식품유통센터');
    final loc3 = OrgLocations.resolve('호남대 근처 공동부엌');
    final loc4 = OrgLocations.resolve('조선대 기숙사 식당 지원');
    _requests.addAll([
      SaleRequest(
        id: 'sr-demo-1',
        restaurantId: 'org-demo',
        restaurantName: loc1.name,
        branchName: loc1.address,
        category: ProductCategory.sidedish,
        quantity: 12,
        pricePerUnit: 0,
        status: SaleRequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 5)),
        photoAsset: 'assets/images/shop_bibimbap.png',
        itemLabel: '시금치나물',
        displayNumber: 9,
        machineId: 'vm-jnu',
        machineName: '전남대 환승반찬',
        pickupAddress: loc1.address,
        lat: loc1.lat,
        lng: loc1.lng,
      ),
      SaleRequest(
        id: 'sr-demo-2',
        restaurantId: 'org-demo',
        restaurantName: loc2.name,
        branchName: loc2.address,
        category: ProductCategory.fresh,
        quantity: 8,
        pricePerUnit: 0,
        status: SaleRequestStatus.pending,
        createdAt: now.subtract(const Duration(hours: 8)),
        itemLabel: '버섯볶음',
        displayNumber: 10,
        machineId: 'vm-gwu',
        machineName: '광주여대 환승반찬',
        pickupAddress: loc2.address,
        lat: loc2.lat,
        lng: loc2.lng,
      ),
      SaleRequest(
        id: 'sr-demo-3',
        restaurantId: 'org-demo',
        restaurantName: loc3.name,
        branchName: loc3.address,
        category: ProductCategory.sidedish,
        quantity: 20,
        pricePerUnit: 0,
        status: SaleRequestStatus.collected,
        createdAt: now.subtract(const Duration(days: 1)),
        itemLabel: '계란말이',
        displayNumber: 11,
        machineId: 'vm-nambu',
        machineName: '남부대 환승반찬',
        pickupAddress: loc3.address,
        lat: loc3.lat,
        lng: loc3.lng,
      ),
      SaleRequest(
        id: 'sr-demo-4',
        restaurantId: 'org-demo',
        restaurantName: loc4.name,
        branchName: loc4.address,
        category: ProductCategory.processed,
        quantity: 15,
        pricePerUnit: 0,
        status: SaleRequestStatus.stocked,
        createdAt: now.subtract(const Duration(days: 2)),
        itemLabel: '고등어조림',
        displayNumber: 8,
        machineId: 'vm-chosun',
        machineName: '조선대 환승반찬',
        pickupAddress: loc4.address,
        lat: loc4.lat,
        lng: loc4.lng,
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
    _requests[i] = _requests[i].copyWith(status: status);
    notifyListeners();
    return true;
  }

  Future<int> markOrgCollected(String restaurantName) async {
    var count = 0;
    for (var i = 0; i < _requests.length; i++) {
      final req = _requests[i];
      if (req.restaurantName == restaurantName &&
          req.status == SaleRequestStatus.pending) {
        _requests[i] = req.copyWith(status: SaleRequestStatus.collected);
        count++;
      }
    }
    if (count > 0) notifyListeners();
    return count;
  }

  Future<bool> submitOrgSupplyItems({
    required String orgId,
    required String orgName,
    required List<({String name, int qty, String note, AttachedPhoto? photo})>
        items,
    required List<SlotAssignment> assignments,
    String? pickupAddress,
    double? lat,
    double? lng,
  }) async {
    if (items.length != assignments.length) return false;
    _isLoading = true;
    notifyListeners();
    try {
      final place = OrgLocations.resolve(orgName, address: pickupAddress);
      for (var i = 0; i < items.length; i++) {
        final item = items[i];
        final slot = assignments[i];
        _requests.add(
          SaleRequest(
            id: 'sr-${DateTime.now().millisecondsSinceEpoch}-${item.name.hashCode}',
            restaurantId: orgId,
            restaurantName: orgName,
            branchName: slot.machineName,
            category: ProductCategory.sidedish,
            quantity: item.qty,
            pricePerUnit: 0,
            status: SaleRequestStatus.pending,
            createdAt: DateTime.now(),
            photoAsset: item.photo?.assetPath,
            photoPath: item.photo?.filePath,
            photoBytes: item.photo?.bytes,
            itemLabel: item.name,
            displayNumber: slot.displayNumber,
            machineId: slot.machineId,
            machineName: slot.machineName,
            pickupAddress: pickupAddress ?? place.address,
            lat: lat ?? place.lat,
            lng: lng ?? place.lng,
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
