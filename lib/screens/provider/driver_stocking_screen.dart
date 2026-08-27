import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/seed_data.dart';
import '../../models/sale_request.dart';
import '../../providers/sale_provider.dart';
import '../../providers/vending_provider.dart';
import '../../theme/app_theme.dart';

/// 기사 환승반찬 입고 — 신청 때 배정된 번호로 대학 자판기에 입고.
class DriverStockingScreen extends StatefulWidget {
  const DriverStockingScreen({super.key});

  @override
  State<DriverStockingScreen> createState() => _DriverStockingScreenState();
}

class _DriverStockingScreenState extends State<DriverStockingScreen> {
  @override
  Widget build(BuildContext context) {
    final vending = context.watch<VendingProvider>();
    final sale = context.watch<SaleProvider>();
    final waiting = sale.collectedForStocking;
    final slots = vending.allSlotsSorted;

    return Scaffold(
      appBar: AppBar(title: const Text('환승반찬 입고')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            '수거 완료된 품목을 배정된 슬롯 번호 그대로 대학 자판기에 입고합니다.',
            style: TextStyle(fontWeight: FontWeight.w600, height: 1.4),
          ),
          const SizedBox(height: 16),
          Text(
            '입고 대기  ${waiting.length}건',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (waiting.isEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                '입고할 수거 완료 품목이 없습니다. 먼저 수거 대상 목록 또는 동선에서 수거를 완료해 주세요.',
                style: TextStyle(color: Color(0xFF8A7466)),
              ),
            )
          else
            ...waiting.map(
              (req) => _StockCard(
                request: req,
                onStock: () => _stockRequest(req, vending, sale),
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => _confirmDispose(context, vending),
            child: const Text('전날 재고 전량 폐기'),
          ),
          const SizedBox(height: 20),
          const Text('실시간 재고', style: TextStyle(fontWeight: FontWeight.bold)),
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
                subtitle: Text(
                  '${slot.quantity}개 · ${vending.machineById(slot.machineId).name}',
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _stockRequest(
    SaleRequest request,
    VendingProvider vending,
    SaleProvider sale,
  ) async {
    if (!request.hasSlotAssignment) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('배정된 슬롯 번호가 없습니다.')),
      );
      return;
    }
    final result = vending.stockReserved(
      displayNumber: request.displayNumber!,
      machineId: request.machineId!,
      name: request.itemLabel ?? request.category.label,
      quantity: request.quantity,
      photoAsset: request.photoAsset,
      photoPath: request.photoPath,
      photoBytes: request.photoBytes,
    );
    if (result.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error!)),
      );
      return;
    }
    await sale.updateSaleRequestStatus(request.id, SaleRequestStatus.stocked);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${request.itemLabel ?? request.category.label} · No. ${result.assignedNumber} → ${result.machineName}',
        ),
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
          '판매기한이 지난 전날 재고를 전량 회수·폐기하고 데이터를 초기화합니다.',
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

class _StockCard extends StatelessWidget {
  const _StockCard({required this.request, required this.onStock});

  final SaleRequest request;
  final VoidCallback onStock;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD4C8B4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.sage,
                child: Text(
                  '${request.displayNumber ?? '-'}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.itemLabel ?? request.category.label,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${request.restaurantName} · ${request.quantity}개',
                      style: const TextStyle(
                        color: Color(0xFF8A7466),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            request.slotSummary,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
              onPressed: onStock,
              child: const Text('이 번호로 입고'),
            ),
          ),
        ],
      ),
    );
  }
}
