import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale_request.dart';

class SaleHistoryScreen extends StatefulWidget {
  const SaleHistoryScreen({super.key});

  @override
  State<SaleHistoryScreen> createState() => _SaleHistoryScreenState();
}

class _SaleHistoryScreenState extends State<SaleHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().appUser;
      if (user != null) {
        context.read<SaleProvider>().fetchMySaleRequests(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final saleProvider = context.watch<SaleProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('매매 신청 내역'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final user = context.read<AuthProvider>().appUser;
              if (user != null) saleProvider.fetchMySaleRequests(user.uid);
            },
          ),
        ],
      ),
      body: saleProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : saleProvider.mySaleRequests.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: saleProvider.mySaleRequests.length,
                  itemBuilder: (context, index) {
                    final request = saleProvider.mySaleRequests[index];
                    return _SaleRequestCard(request: request);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            '신청한 내역이 없습니다.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

class _SaleRequestCard extends StatelessWidget {
  const _SaleRequestCard({required this.request});
  final SaleRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(request.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    request.status.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(request.status),
                    ),
                  ),
                ),
                Text(
                  request.createdAt.toString().split(' ')[0],
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '[${request.category.label}] ${request.quantity}개',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  request.branchName,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const Spacer(),
                Text(
                  '예정 금액: ${request.totalPrice}원',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SaleRequestStatus status) {
    switch (status) {
      case SaleRequestStatus.pending: return Colors.orange;
      case SaleRequestStatus.collected: return Colors.green;
      case SaleRequestStatus.cancelled: return Colors.red;
    }
  }
}
