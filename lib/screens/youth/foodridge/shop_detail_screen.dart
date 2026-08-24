import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_reservations_screen.dart';
import 'review_write_screen.dart';
import 'foodridge_map_screen.dart';

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
          Text(shop.description, style: const TextStyle(height: 1.45, fontSize: 15)),
          const SizedBox(height: 12),
          Text(shop.address, style: const TextStyle(color: Color(0xFF8A7466))),
          if (shop.partnerSurplus) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.canvasDeep,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's surplus box",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(shop.surplusLabel ?? 'Surprise bag'),
                  Text(
                    '₩${shop.surplusPrice}  ·  in-store pickup',
                    style: const TextStyle(color: Color(0xFF8A7466)),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                    onPressed: () {
                      final r = provider.createReservation(
                        userId: user.uid,
                        shopId: shop.id,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            r == null
                                ? 'No surplus booking available for this kitchen.'
                                : 'Booked! Confirm arrival with GPS, then leave a review.',
                          ),
                          action: r == null
                              ? null
                              : SnackBarAction(
                                  label: 'My bookings',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const FoodridgeReservationsScreen(),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      );
                    },
                    child: const Text('Book surplus box'),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text(
            reviews.isEmpty ? 'Reviews' : 'Reviews  ·  ${avg.toStringAsFixed(1)} / 5',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'You can write a review only after booking and GPS check-in.',
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
