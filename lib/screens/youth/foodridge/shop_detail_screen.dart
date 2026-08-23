import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import 'foodridge_map_screen.dart';

class ShopDetailScreen extends StatefulWidget {
  const ShopDetailScreen({super.key, required this.shopId});

  final String shopId;

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  final _comment = TextEditingController();
  int _stars = 5;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FoodridgeProvider>();
    final shop = provider.shopById(widget.shopId);
    final reviews = provider.reviewsFor(shop.id);
    final avg = provider.averageStars(shop.id);

    return Scaffold(
      appBar: AppBar(title: Text(shop.name)),
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
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              DietMark(badge: shop.badge),
            ],
          ),
          const SizedBox(height: 12),
          Text(shop.description, style: const TextStyle(height: 1.45, fontSize: 15)),
          const SizedBox(height: 12),
          Text(shop.address, style: const TextStyle(color: Colors.black54)),
          if (shop.partnerSurplus) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Surplus box (partner kitchen)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(shop.surplusLabel ?? 'Surprise bag'),
                  Text(
                    '₩${shop.surplusPrice}  ·  pickup in-store today',
                    style: const TextStyle(color: Colors.black54),
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
            'Reviews are only visible on this restaurant page.',
            style: TextStyle(color: Colors.black45, fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const Text('No reviews yet.', style: TextStyle(color: Colors.black45)),
          ...reviews.map(
            (review) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('${'★' * review.stars}  ${review.author}'),
              subtitle: Text(review.comment),
            ),
          ),
          const Divider(height: 32),
          const Text('Leave a review', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: List.generate(5, (i) {
              return IconButton(
                onPressed: () => setState(() => _stars = i + 1),
                icon: Icon(
                  i < _stars ? Icons.star : Icons.star_border,
                  color: Colors.orange,
                ),
              );
            }),
          ),
          TextField(
            controller: _comment,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Share a short note for other international students',
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (_comment.text.trim().isEmpty) return;
              final name = context.read<AuthProvider>().appUser?.name ?? 'Guest';
              provider.addReview(
                shopId: shop.id,
                author: name,
                stars: _stars,
                comment: _comment.text,
              );
              _comment.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Review posted on this restaurant only.')),
              );
            },
            child: const Text('Post review'),
          ),
        ],
      ),
    );
  }
}
