import 'package:flutter/foundation.dart';

import '../data/seed_data.dart';
import '../models/vending.dart';

class VendingProvider with ChangeNotifier {
  VendingProvider() {
    _machines = SeedData.machines.map((m) => m).toList();
    _slots.addAll([
      VendingSlot(
        id: 'demo-1',
        machineId: 'vm-jnu',
        displayNumber: 1,
        internalCode: 'VM-JNU-IN101',
        name: '멸치볶음',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-2',
        machineId: 'vm-jnu',
        displayNumber: 2,
        internalCode: 'VM-JNU-IN102',
        name: '시금치나물',
        quantity: 3,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-gwu-1',
        machineId: 'vm-gwu',
        displayNumber: 1,
        internalCode: 'VM-GWU-IN101',
        name: '콩자반',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-scnu-1',
        machineId: 'vm-scnu',
        displayNumber: 1,
        internalCode: 'VM-SCN-IN101',
        name: '깍두기',
        quantity: 5,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-gju-1',
        machineId: 'vm-gju',
        displayNumber: 1,
        internalCode: 'VM-GJU-IN101',
        name: '제육볶음',
        quantity: 5,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-honam-1',
        machineId: 'vm-honam',
        displayNumber: 1,
        internalCode: 'VM-HON-IN101',
        name: '계란말이',
        quantity: 4,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-chosun-1',
        machineId: 'vm-chosun',
        displayNumber: 1,
        internalCode: 'VM-CHO-IN101',
        name: '잡채',
        quantity: 3,
        createdAt: DateTime.now(),
      ),
      VendingSlot(
        id: 'demo-chosun-2',
        machineId: 'vm-chosun',
        displayNumber: 2,
        internalCode: 'VM-CHO-IN102',
        name: '고등어조림',
        quantity: 2,
        createdAt: DateTime.now(),
      ),
    ]);
    _internalSeq = 102;
  }

  late List<VendingMachine> _machines;
  final List<VendingSlot> _slots = [];
  int _internalSeq = 100;

  List<VendingMachine> get machines => List.unmodifiable(_machines);
  List<VendingSlot> get slots => List.unmodifiable(_slots);

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

  /// Next display numbers (1–20) that are free for this machine.
  List<int> availableDisplayNumbers(String machineId) {
    final used = slotsFor(machineId).map((s) => s.displayNumber).toSet();
    return [
      for (var n = 1; n <= VendingMachine.maxSlots; n++)
        if (!used.contains(n)) n,
    ];
  }

  String? stockDish({
    required String machineId,
    required String name,
    required int quantity,
    String? photoAsset,
  }) {
    if (quantity <= 0) return '수량을 입력해 주세요.';
    final remaining = remainingSlots(machineId);
    if (quantity > remaining) {
      return '잔여 슬롯은 $remaining개입니다. (최대 ${VendingMachine.maxSlots})';
    }

    final existing = slotsFor(machineId).where((s) => s.name == name);
    if (existing.isNotEmpty) {
      final slot = existing.first;
      final index = _slots.indexWhere((s) => s.id == slot.id);
      _slots[index] = VendingSlot(
        id: slot.id,
        machineId: slot.machineId,
        displayNumber: slot.displayNumber,
        internalCode: slot.internalCode,
        name: slot.name,
        quantity: slot.quantity + quantity,
        photoAsset: slot.photoAsset,
        createdAt: slot.createdAt,
      );
      notifyListeners();
      return null;
    }

    final numbers = availableDisplayNumbers(machineId);
    if (numbers.isEmpty) return '빈 번호가 없습니다.';
    final displayNumber = numbers.first;
    _internalSeq += 1;
    final internalCode = '${machineId.toUpperCase()}-IN$_internalSeq';

    _slots.add(
      VendingSlot(
        id: 'slot-${DateTime.now().millisecondsSinceEpoch}-$displayNumber',
        machineId: machineId,
        displayNumber: displayNumber,
        internalCode: internalCode,
        name: name,
        quantity: quantity,
        photoAsset: photoAsset,
        createdAt: DateTime.now(),
      ),
    );
    notifyListeners();
    return null;
  }

  String? completeStocking(String machineId) {
    final index = _machines.indexWhere((m) => m.id == machineId);
    if (index < 0) return '자판기를 찾을 수 없습니다.';
    if (usedSlots(machineId) == 0) return '입고된 음식이 없습니다.';
    _machines[index] = _machines[index].copyWith(
      stockingCompletedAt: DateTime.now(),
      disposalConfirmed: false,
      clearDisposed: true,
    );
    notifyListeners();
    return null;
  }

  /// After-lunch collection: dispose leftover inventory and reset slot data.
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
