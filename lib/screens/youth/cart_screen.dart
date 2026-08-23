import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().appUser;
      if (user != null) {
        context.read<OrderProvider>().fetchMyCart(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final authProvider = context.watch<AuthProvider>();
    final cartItems = orderProvider.myCart;

    int totalPrice = cartItems.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: const Text('장바구니 (나의 예약)')),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? const Center(child: Text('장바구니가 비어 있습니다.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(item.productName),
                              subtitle: Text('${item.restaurantName} | ${item.price}원'),
                              trailing: IconButton(
                                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                onPressed: () => _handleCancel(item),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, -5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('총 결제 금액', style: TextStyle(fontSize: 16)),
                              Text(
                                '$totalPrice원',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () => _handlePayment(authProvider.appUser!.uid, cartItems),
                              child: const Text('결제하기 (외부 계좌 연동)'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  void _handleCancel(OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('예약 취소'),
        content: const Text('예약을 취소하시겠습니까? 냉장고 수량이 복구됩니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('아니오')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('예')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<OrderProvider>().cancelReservation(order);
    }
  }

  void _handlePayment(String userId, List<OrderModel> orders) async {
    // 외부 앱 연동 시뮬레이션
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('결제 확인'),
        content: const Text('외부 은행 앱과 연동하여 결제를 진행하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('결제 승인')),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await context.read<OrderProvider>().confirmPayment(userId, orders);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('결제가 완료되었습니다! 최종 구매가 확정되었습니다.')),
        );
        Navigator.pop(context);
      }
    }
  }
}
