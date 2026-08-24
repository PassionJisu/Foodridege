import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_reservations_screen.dart';

class FoodridgeCartScreen extends StatelessWidget {
  const FoodridgeCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;
    final provider = context.watch<FoodridgeProvider>();

    final cart = provider.cartFor(user.uid);
    final total = provider.cartTotalFor(user.uid);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: const Text('Cart'),
      ),
      body: cart.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty.',
                style: TextStyle(color: Color(0xFF8A7466)),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final line = cart[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFD4C8B4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              line.menuItemName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                color: AppColors.ink,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'From ${line.storeId} · ₩${line.unitPrice} · Qty ${line.qty}',
                              style: const TextStyle(
                                color: Color(0xFF8A7466),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Line total: ₩${line.lineTotal}',
                                    style: const TextStyle(
                                      color: AppColors.sage,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: () {
                                    provider.removeCartLine(
                                      userId: user.uid,
                                      cartLineId: line.id,
                                    );
                                  },
                                  icon: const Icon(Icons.delete_outline,
                                      color: Colors.redAccent),
                                )
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₩$total',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 22,
                              color: AppColors.sage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.sage,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final result = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Checkout'),
                                content: const Text(
                                  'Create bookings from your cart and move to GPS check-in?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Cancel'),
                                  ),
                                  FilledButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );

                            if (result != true) return;
                            final err =
                                provider.checkoutCart(userId: user.uid);
                            if (err != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err)),
                              );
                              return;
                            }
                            if (!context.mounted) return;
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FoodridgeReservationsScreen(),
                              ),
                            );
                          },
                          child: const Text('Checkout & book'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

