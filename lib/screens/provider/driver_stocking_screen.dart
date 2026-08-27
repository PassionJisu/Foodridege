import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/seed_data.dart';
import '../../models/attached_photo.dart';
import '../../providers/vending_provider.dart';
import '../../widgets/photo_attach_field.dart';

/// 기사 환승반찬 입고 — 지점 선택 없음, 전역 번호 1~120 순차 부여.
class DriverStockingScreen extends StatefulWidget {
  const DriverStockingScreen({super.key});

  @override
  State<DriverStockingScreen> createState() => _DriverStockingScreenState();
}

class _DriverStockingScreenState extends State<DriverStockingScreen> {
  String _dishName = SeedData.dishPresets.first.name;
  final _customName = TextEditingController();
  final _quantity = TextEditingController(text: '1');
  AttachedPhoto? _photo;

  @override
  void dispose() {
    _customName.dispose();
    _quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vending = context.watch<VendingProvider>();
    final slots = vending.allSlotsSorted;
    final next = vending.nextGlobalNumber;

    return Scaffold(
      appBar: AppBar(title: const Text('환승반찬 입고')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            '지점 선택 없이 입고합니다. 다음 부여 번호: $next / ${VendingProvider.maxGlobalNumbers}',
            style: const TextStyle(fontWeight: FontWeight.w600),
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
            decoration: const InputDecoration(labelText: '수량'),
          ),
          const SizedBox(height: 8),
          PhotoAttachField(
            photo: _photo,
            onChanged: (value) => setState(() => _photo = value),
            label: '음식 사진 첨부',
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              final qty = int.tryParse(_quantity.text) ?? 0;
              final result = vending.stockDishGlobal(
                name: _dishName,
                quantity: qty,
                photoAsset: _photo?.assetPath,
                photoPath: _photo?.filePath,
                photoBytes: _photo?.bytes,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    result.error ??
                        '$_dishName $qty개 · 번호 ${result.assignedNumber}번 부여',
                  ),
                ),
              );
            },
            child: const Text('입고하기'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _confirmDispose(context, vending),
            child: const Text('전날 재고 전량 폐기'),
          ),
          const SizedBox(height: 20),
          const Text('슬롯 현황', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(slot.name),
                subtitle: Text('${slot.quantity}개'),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _confirmDispose(
    BuildContext context,
    VendingProvider vending,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('전량 폐기'),
        content: const Text(
          '전날 재고를 전량 폐기하고 데이터를 초기화합니다.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('폐기'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      vending.disposeAllInventory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('전량 폐기 · 재고가 초기화되었습니다.')),
      );
    }
  }
}
