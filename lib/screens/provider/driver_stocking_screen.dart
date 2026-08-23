import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/seed_data.dart';
import '../../models/vending.dart';
import '../../providers/vending_provider.dart';

class DriverStockingScreen extends StatefulWidget {
  const DriverStockingScreen({super.key});

  @override
  State<DriverStockingScreen> createState() => _DriverStockingScreenState();
}

class _DriverStockingScreenState extends State<DriverStockingScreen> {
  String? _machineId;
  String _dishName = SeedData.dishPresets.first.name;
  final _customName = TextEditingController();
  final _quantity = TextEditingController(text: '1');

  @override
  void dispose() {
    _customName.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vending = context.watch<VendingProvider>();
    final selectedId = _machineId ?? vending.machines.first.id;
    final machine = vending.machineById(selectedId);
    final slots = vending.slotsFor(selectedId);
    final used = vending.usedSlots(selectedId);

    return Scaffold(
      appBar: AppBar(title: const Text('자판기 입고')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey(selectedId),
            initialValue: selectedId,
            decoration: const InputDecoration(labelText: '자판기 지점'),
            items: vending.machines
                .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                .toList(),
            onChanged: (value) => setState(() => _machineId = value),
          ),
          const SizedBox(height: 8),
          Text(machine.location, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text(
            '사용 슬롯 $used / ${VendingMachine.maxSlots}  ·  사용자·기사 표시 번호는 1–20',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          if (machine.stockingCompletedAt != null)
            Text(
              '입고 마무리: ${DateFormat('MM.dd HH:mm').format(machine.stockingCompletedAt!)}'
              '${machine.isExpired ? '  ·  24시간 경과, 폐기 대상' : ''}',
            ),
          const SizedBox(height: 16),
          const Text('음식 사진 · 반찬명 입력', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: SeedData.dishPresets.map((dish) {
              final selected = _dishName == dish.name;
              return ChoiceChip(
                label: Text(dish.name),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _dishName = dish.name;
                    _customName.clear();
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _customName,
            decoration: const InputDecoration(
              labelText: '직접 입력 (당일 반찬명)',
            ),
            onChanged: (value) {
              if (value.trim().isNotEmpty) {
                setState(() => _dishName = value.trim());
              }
            },
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _quantity,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: '수량 (슬롯 차감)'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(_quantity.text) ?? 0;
              final error = vending.stockDish(
                machineId: selectedId,
                name: _dishName,
                quantity: qty,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                        error ??
                        '$_dishName $qty개가 번호 ${vending.slotsFor(selectedId).firstWhere((s) => s.name == _dishName).displayNumber}번으로 부여되었습니다.',
                  ),
                ),
              );
            },
            child: const Text('번호 부여 후 입고'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () {
              final error = vending.completeStocking(selectedId);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(error ?? '입고를 마무리했습니다. 24시간 후 전량 폐기 대상이 됩니다.')),
              );
            },
            child: const Text('입고 마무리'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _confirmDispose(context, vending, selectedId, machine.name),
            child: const Text('전날 재고 전량 폐기'),
          ),
          const SizedBox(height: 20),
          const Text('슬롯 현황 (표시 번호 / 내부 번호)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (slots.isEmpty)
            const Text('입고된 음식이 없습니다.')
          else
            ...slots.map(
              (slot) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: Color(
                    SeedData.dishPresets
                        .where((d) => d.name == slot.name)
                        .map((d) => d.color)
                        .cast<int>()
                        .followedBy(const [0xFF4A6741])
                        .first,
                  ),
                  child: Text(
                    '${slot.displayNumber}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(slot.name),
                subtitle: Text(
                  '표시 ${slot.displayNumber.toString().padLeft(2, '0')}  ·  내부 ${slot.internalCode}  ·  ${slot.quantity}개',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDispose(
    BuildContext context,
    VendingProvider vending,
    String machineId,
    String machineName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전량 폐기'),
        content: const Text(
          '점심 이후 수거 출발 전, 전날 재고를 전량 폐기하고 데이터를 초기화합니다.\n폐기 확인 표를 자판기에 부착해 주세요.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('폐기')),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      vending.disposeInventory(machineId);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('폐기 확인 표'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black87, width: 2),
                ),
                child: Column(
                  children: [
                    const Text('DISPOSAL CONFIRMED', style: TextStyle(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text(machineName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(DateFormat('yyyy.MM.dd HH:mm').format(DateTime.now())),
                    const SizedBox(height: 8),
                    const Text('전량 폐기 완료 · 재고 데이터 초기화', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('담당 확인', style: TextStyle(color: Colors.grey.shade700)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text('이 표를 자판기 전면에 부착해 책임감을 표시합니다.'),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('부착 완료')),
          ],
        ),
      );
    }
  }
}
