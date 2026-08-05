import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/inventory_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/product.dart';
import 'cart_screen.dart';

class FoodReservationScreen extends StatelessWidget {
  const FoodReservationScreen({
    super.key,
    required this.branchName,
    required this.restaurantName,
  });

  final String branchName;
  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    final inventory = context.watch<InventoryProvider>();
    final products = inventory.getProductsByRestaurant(branchName, restaurantName);

    return Scaffold(
      appBar: AppBar(
        title: Text(restaurantName),
      ),
      body: products.isEmpty
          ? const Center(child: Text('현재 예약 가능한 메뉴가 없습니다.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.category.label,
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${product.price}원',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              '잔여 ${product.quantity}개',
                              style: TextStyle(
                                color: product.quantity < 3 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _handleReservation(context, product),
                              child: const Text('장바구니 담기'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _handleReservation(BuildContext context, Product product) async {
    final auth = context.read<AuthProvider>();
    final order = context.read<OrderProvider>();

    if (auth.appUser == null) return;

    final success = await order.reserveItem(
      user: auth.appUser!,
      product: product,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('장바구니에 담겼습니다! (수량 즉시 차감)')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CartScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(order.errorMessage ?? '예약에 실패했습니다.')),
      );
    }
  }
}
