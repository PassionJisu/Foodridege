import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale_request.dart';

class DriverPickupListScreen extends StatefulWidget {
  const DriverPickupListScreen({super.key});

  @override
  State<DriverPickupListScreen> createState() => _DriverPickupListScreenState();
}

class _DriverPickupListScreenState extends State<DriverPickupListScreen> {
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
    final pendingRequests = saleProvider.allSaleRequests
        .where((req) => req.status == SaleRequestStatus.pending)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('수거 대상 목록'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => saleProvider.fetchAllSaleRequests(),
          ),
        ],
      ),
      body: saleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : pendingRequests.isEmpty
              ? const Center(child: Text('수거 대기 중인 물품이 없습니다.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = pendingRequests[index];
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
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(108, 40),
                                ),
                                onPressed: () => _handlePickup(request),
                                child: const Text('수거 완료'),
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

  Future<void> _handlePickup(SaleRequest request) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('수거 확인'),
        content: Text('${request.restaurantName}의 ${request.category.label} 물품을 수거하셨나요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context
          .read<SaleProvider>()
          .updateSaleRequestStatus(request.id, SaleRequestStatus.collected);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('수거 완료 처리되었습니다.')),
        );
      }
    }
  }
}
