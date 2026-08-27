import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/vending.dart';

class StockResult {
  const StockResult({this.error, this.assignedNumber});
  final String? error;
  final int? assignedNumber;
}

/// 환승반찬 입고 — 전역 번호 1~120 순차 부여 (지점 선택 없음).
class VendingProvider with ChangeNotifier {
  VendingProvider() {
    _machines = SeedData.machines.map((m) => m).toList();
    _slots.addAll([
      VendingSlot(
        id: 'demo-1',
        machineId: 'vm-jnu',
        displayNumber: 1,
        name: '멸치볶음',
        quantity: 4,
        photoAsset: 'assets/images/myeolchi.jpg',
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-2',
        machineId: 'vm-jnu',
        displayNumber: 2,
        name: '시금치나물',
        quantity: 3,
        photoAsset: 'assets/images/sigumchi.jpg',
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-gwu-1',
        machineId: 'vm-gwu',
        displayNumber: 3,
        name: '콩자반',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-scnu-1',
        machineId: 'vm-nambu',
        displayNumber: 4,
        name: '깍두기',
        quantity: 5,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-gju-1',
        machineId: 'vm-gju',
        displayNumber: 5,
        name: '제육볶음',
        quantity: 5,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-honam-1',
        machineId: 'vm-honam',
        displayNumber: 6,
        name: '계란말이',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-chosun-1',
        machineId: 'vm-chosun',
        displayNumber: 7,
        name: '잡채',
        quantity: 3,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-chosun-2',
        machineId: 'vm-chosun',
        displayNumber: 8,
        name: '고등어조림',
        quantity: 2,
        createdAt: DateTime.now(),
      ),
    ]);
    _nextGlobalNumber = 9;
  }

  static const int maxGlobalNumbers = 120;

  late List<VendingMachine> _machines;
  final List<VendingSlot> _slots = [];
  int _nextGlobalNumber = 1;
  int _roundRobin = 0;

  List<VendingMachine> get machines => List.unmodifiable(_machines);
  List<VendingSlot> get slots => List.unmodifiable(_slots);

  int get nextGlobalNumber => _nextGlobalNumber;

  List<VendingSlot> get allSlotsSorted {
    final list = List<VendingSlot>.of(_slots);
    list.sort((a, b) => a.displayNumber.compareTo(b.displayNumber));
    return list;
  }

  VendingMachine machineById(String id) =>
      _machines.firstWhere((m) => m.id == id);

  List<VendingSlot> slotsFor(String machineId) {
    final list = _slots.where((s) => s.machineId == machineId).toList();
    list.sort((a, b) => a.displayNumber.compareTo(b.displayNumber));
    return list;
  }

  int usedSlots(String machineId) =>
      slotsFor(machineId).fold(0, (sum, s) => sum + s.quantity);

  int remainingSlots(String machineId) =>
      VendingMachine.maxSlots - usedSlots(machineId);

  /// 기사 입고: 지점 선택 없이 전역 번호만 부여. 학생 화면용으로 지점 라운드로빈 배치.
  StockResult stockDishGlobal({
    required String name,
    required int quantity,
    String? photoAsset,
    String? photoPath,
    Uint8List? photoBytes,
  }) {
    if (quantity <= 0) {
      return const StockResult(error: '수량을 입력해 주세요.');
    }
    if (_nextGlobalNumber > maxGlobalNumbers) {
      return const StockResult(error: '번호가 모두 소진되었습니다. (최대 120번)');
    }

    final machineId = _machines[_roundRobin % _machines.length].id;
    _roundRobin += 1;
    final displayNumber = _nextGlobalNumber;
    _nextGlobalNumber += 1;

    _slots.add(
      VendingSlot(
        id: 'slot-${DateTime.now().millisecondsSinceEpoch}-$displayNumber',
        machineId: machineId,
        displayNumber: displayNumber,
        name: name,
        quantity: quantity,
        photoAsset: photoAsset,
        photoPath: photoPath,
        photoBytes: photoBytes,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return StockResult(assignedNumber: displayNumber);
  }

  /// 하위 호환: 기존 호출부는 전역 입고로 위임.
  String? stockDish({
    required String machineId,
    required String name,
    required int quantity,
    String? photoAsset,
  }) {
    final result = stockDishGlobal(
      name: name,
      quantity: quantity,
      photoAsset: photoAsset,
    );
    return result.error;
  }

  void disposeAllInventory() {
    _slots.clear();
    _nextGlobalNumber = 1;
    for (var i = 0; i < _machines.length; i++) {
      _machines[i] = _machines[i].copyWith(
        disposedAt: DateTime.now(),
        disposalConfirmed: true,
        clearStocking: true,
      );
    }
    notifyListeners();
  }

  String? disposeInventory(String machineId) {
    final index = _machines.indexWhere((m) => m.id == machineId);
    if (index < 0) return '자판기를 찾을 수 없습니다.';
    _slots.removeWhere((s) => s.machineId == machineId);
    _machines[index] = _machines[index].copyWith(
      disposedAt: DateTime.now(),
      disposalConfirmed: true,
      clearStocking: true,
    );
    notifyListeners();
    return null;
  }
}
