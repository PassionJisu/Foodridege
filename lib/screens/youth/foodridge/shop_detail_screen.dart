import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_cart_screen.dart';
import 'foodridge_map_screen.dart';
import 'foodridge_reservations_screen.dart';
import 'review_write_screen.dart';

class ShopDetailScreen extends StatelessWidget {
  const ShopDetailScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FoodridgeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser!;

    final shop = provider.shopById(shopId);
    final reviews = provider.reviewsFor(shop.id);
    final avg = provider.averageStars(shop.id);
    final canReview = provider.canWriteReviewFor(user.uid, shop.id);
    final menu = provider.menuItemsFor(shop.id);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(shop.name),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeReservationsScreen(),
                ),
              );
            },
            child: const Text('My bookings'),
          ),
          IconButton(
            tooltip: 'Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FoodridgeCartScreen(),
                ),
              );
            },
            icon: const Icon(Icons.shopping_cart_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (shop.photoAsset != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                shop.photoAsset!,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              Expanded(
                child: Text(
                  shop.cuisine,
                  style: const TextStyle(color: Color(0xFF8A7466)),
                ),
              ),
              DietMark(badge: shop.badge),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            shop.description,
            style: const TextStyle(height: 1.45, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Text(shop.address, style: const TextStyle(color: Color(0xFF8A7466))),

          const SizedBox(height: 20),
          const Text(
            'Available menu',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 10),

          if (menu.isEmpty)
            const Text(
              'No available items right now.',
              style: TextStyle(color: Color(0xFF8A7466)),
            )
          else
            ...menu.map((item) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD4C8B4)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 68,
                        height: 68,
                        child: item.photoAsset != null
                            ? Image.asset(
                                item.photoAsset!,
                                fit: BoxFit.cover,
                              )
                            : Container(color: AppColors.canvasDeep),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '₩${item.price} · Remaining ${item.remainingQty}',
                            style: const TextStyle(
                              color: Color(0xFF8A7466),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.sage,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: item.remainingQty <= 0
                          ? null
                          : () {
                              final err = provider.addToCart(
                                userId: user.uid,
                                menuItemId: item.id,
                                qty: 1,
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(err ?? 'Added to cart.')),
                              );
                            },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              );
            }),

          if (user.role.canManageStore) ...[
            const SizedBox(height: 6),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.goldBright,
                foregroundColor: Colors.black,
              ),
              onPressed: () async {
                final nameController = TextEditingController();
                final priceController = TextEditingController(text: '4000');
                final remainingController = TextEditingController(text: '3');

                final ok = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Owner: Add menu item'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Name'),
                          ),
                          TextField(
                            controller: priceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Price (₩)'),
                          ),
                          TextField(
                            controller: remainingController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Remaining qty'),
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );

                if (ok != true) return;

                final price = int.tryParse(priceController.text) ?? 0;
                final remaining = int.tryParse(remainingController.text) ?? 0;
                final err = provider.addMenuItem(
                  storeId: shop.id,
                  name: nameController.text,
                  price: price,
                  remainingQty: remaining,
                  photoAsset: shop.photoAsset,
                );

                if (err != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(err)),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menu added.')),
                  );
                }
              },
              child: const Text('Add menu item'),
            ),
          ],

          const SizedBox(height: 24),
          Text(
            reviews.isEmpty ? 'Reviews' : 'Reviews  ·  ${avg.toStringAsFixed(1)} / 5',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write a review after booking and GPS check-in.',
            style: TextStyle(color: Color(0xFF8A7466), fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const Text('No reviews yet.', style: TextStyle(color: Color(0xFF8A7466))),
          ...reviews.map(
            (review) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${'★' * review.stars}  ${review.author}'),
              subtitle: Text(review.comment),
            ),
          ),

          const Divider(height: 32),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
            onPressed: canReview
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewWriteScreen(shopId: shop.id),
                      ),
                    );
                  }
                : null,
            child: Text(
              canReview ? 'Write a review' : 'Available after check-in',
            ),
          ),
          if (!canReview)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                provider.reviewBlockReason(user.uid, shop.id),
                style: const TextStyle(color: Color(0xFF8A7466), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}

