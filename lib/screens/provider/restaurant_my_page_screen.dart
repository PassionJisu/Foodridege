import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sale_provider.dart';
import '../../models/sale_request.dart';

class RestaurantMyPageScreen extends StatefulWidget {
  const RestaurantMyPageScreen({super.key});

  @override
  State<RestaurantMyPageScreen> createState() => _RestaurantMyPageScreenState();
}

class _RestaurantMyPageScreenState extends State<RestaurantMyPageScreen> {
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
    final auth = context.watch<AuthProvider>();
    final saleProvider = context.watch<SaleProvider>();
    final user = auth.appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final now = DateTime.now();
    final monthlyTotal = saleProvider.getMonthlySettlementAmount(now.year, now.month);

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지 (사장님)')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 사장님 정보 카드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange.shade50,
                      child: const Icon(Icons.restaurant, size: 30, color: Colors.orange),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text('사업자 번호: ${user.businessRegistrationNumber ?? "미등록"}', 
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatItem(label: '이번 달 매매 건수', value: '${saleProvider.mySaleRequests.length}건'),
                    _StatItem(label: '정산 예정 금액', value: '$monthlyTotal원', color: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const Text('최근 매매 신청 내역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (saleProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (saleProvider.mySaleRequests.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: Text('최근 내역이 없습니다.')),
            )
          else
            ...saleProvider.mySaleRequests.take(5).map((req) => _SaleRequestTile(request: req)),
          
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('문의하기'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () async {
              Navigator.of(context).popUntil((route) => route.isFirst);
              await auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value, this.color = Colors.black});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

class _SaleRequestTile extends StatelessWidget {
  const _SaleRequestTile({required this.request});
  final SaleRequest request;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        title: Text('${request.category.label} ${request.quantity}개'),
        subtitle: Text('${request.branchName} | ${request.createdAt.toString().split(' ')[0]}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(request.status).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            request.status.label,
            style: TextStyle(fontSize: 12, color: _getStatusColor(request.status), fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(SaleRequestStatus status) {
    switch (status) {
      case SaleRequestStatus.pending: return Colors.orange;
      case SaleRequestStatus.collected: return Colors.green;
      case SaleRequestStatus.stocked: return Colors.blue;
      case SaleRequestStatus.cancelled: return Colors.red;
    }
  }
}
