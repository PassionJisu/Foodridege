import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/vending_provider.dart';
import '../../models/sale_request.dart';

class AdminStockingManageScreen extends StatefulWidget {
  const AdminStockingManageScreen({super.key});

  @override
  State<AdminStockingManageScreen> createState() => _AdminStockingManageScreenState();
}

class _AdminStockingManageScreenState extends State<AdminStockingManageScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SaleProvider>().fetchAllSaleRequests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();
    final collectedRequests = saleProvider.collectedForStocking;

    return Scaffold(
      appBar: AppBar(
        title: const Text('입고 관리'),
      ),
      body: saleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : collectedRequests.isEmpty
              ? const Center(child: Text('입고 처리할 물품이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: collectedRequests.length,
                  itemBuilder: (context, index) {
                    final request = collectedRequests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '[${request.restaurantName}] ${request.itemLabel ?? request.category.label} ${request.quantity}개',
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              request.slotSummary.isEmpty
                                  ? '지점: ${request.branchName}'
                                  : request.slotSummary,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(108, 40),
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () => _handleStocking(request),
                                child: const Text('입고 확정'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  void _handleStocking(SaleRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('입고 확정'),
        content: Text(
          request.hasSlotAssignment
              ? '${request.slotSummary} 슬롯으로 자판기 재고에 반영합니다.'
              : '수거된 물품을 확인하셨나요?\n확정 시 즉시 냉장고 재고에 반영됩니다.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확정')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final vending = context.read<VendingProvider>();
      final sale = context.read<SaleProvider>();
      final inventory = context.read<InventoryProvider>();

      if (request.hasSlotAssignment) {
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
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.error!)),
            );
          }
          return;
        }
      } else {
        final stockSuccess = await inventory.addStockFromRequest(request);
        if (!stockSuccess) return;
      }

      final statusSuccess =
          await sale.updateSaleRequestStatus(request.id, SaleRequestStatus.stocked);

      if (statusSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('냉장고 입고가 완료되었습니다!')),
        );
        sale.fetchAllSaleRequests();
      }
    }
  }
}
