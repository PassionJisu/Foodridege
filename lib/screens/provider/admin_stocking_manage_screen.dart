import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_provider.dart';
import '../../providers/inventory_provider.dart';
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
    final collectedRequests = saleProvider.allSaleRequests
        .where((req) => req.status == SaleRequestStatus.collected)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('입고 관리 (00:30)'),
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
                      child: ListTile(
                        title: Text('[${request.restaurantName}] ${request.category.label} ${request.quantity}개'),
                        subtitle: Text('지점: ${request.branchName}\n금액: ${request.totalPrice}원'),
                        trailing: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                          onPressed: () => _handleStocking(request),
                          child: const Text('입고 확정'),
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
        content: const Text('수거된 물품을 확인하셨나요?\n확정 시 즉시 냉장고 재고에 반영됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확정')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      // 1. 재고에 추가
      final stockSuccess = await context.read<InventoryProvider>().addStockFromRequest(request);
      
      if (stockSuccess && mounted) {
        // 2. 신청 상태를 stocked로 변경
        final statusSuccess = await context.read<SaleProvider>().updateSaleRequestStatus(request.id, SaleRequestStatus.stocked);
        
        if (statusSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('냉장고 입고가 완료되었습니다!')));
          context.read<SaleProvider>().fetchAllSaleRequests();
        }
      }
    }
  }
}
