import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/attached_photo.dart';
import '../../../models/user_role.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/attached_photo_view.dart';
import '../../../widgets/photo_attach_field.dart';
import 'foodridge_cart_screen.dart';
import 'foodridge_checkout_screen.dart';
import 'foodridge_map_screen.dart';
import 'review_write_screen.dart';

class ShopDetailScreen extends StatelessWidget {
  const ShopDetailScreen({super.key, required this.shopId});

  final String shopId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FoodridgeProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final shop = provider.shopById(shopId);
    final reviews = provider.reviewsFor(shop.id);
    final avg = provider.averageStars(shop.id);
    final canReview = provider.canWriteReviewFor(user.uid, shop.id);
    final menu = provider.menuItemsFor(shop.id);
    final canOrder = user.role.isConsumer || user.role == UserRole.admin;
    final draftTotal = provider.draftTotalFor(user.uid, shop.id);
    final draftCount = provider.draftCountFor(user.uid, shop.id);
    final cartCount = provider.cartCountFor(user.uid);
    final showOrderBar = canOrder && draftCount > 0;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(shop.name),
        actions: [
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
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
              final draftQty = provider.draftQtyFor(
                userId: user.uid,
                menuItemId: item.id,
              );
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
                        child: AttachedPhoto.fromParts(
                                  assetPath: item.photoAsset,
                                  filePath: item.photoPath,
                                  bytes: item.photoBytes,
                                ) !=
                                null
                            ? AttachedPhotoView(
                                photo: AttachedPhoto.fromParts(
                                  assetPath: item.photoAsset,
                                  filePath: item.photoPath,
                                  bytes: item.photoBytes,
                                )!,
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
                    if (canOrder)
                      draftQty > 0
                          ? _QtyStepper(
                              qty: draftQty,
                              onMinus: () => provider.decrementDraft(
                                userId: user.uid,
                                menuItemId: item.id,
                              ),
                              onPlus: item.remainingQty <= 0
                                  ? null
                                  : () {
                                      final err = provider.addToDraft(
                                        userId: user.uid,
                                        menuItemId: item.id,
                                      );
                                      if (err != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(err)),
                                        );
                                      }
                                    },
                            )
                          : FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sage,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: item.remainingQty <= 0
                                  ? null
                                  : () {
                                      final err = provider.addToDraft(
                                        userId: user.uid,
                                        menuItemId: item.id,
                                      );
                                      if (err != null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(err)),
                                        );
                                      }
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
              onPressed: () => _showAddMenuDialog(context, provider, shop.id),
              child: const Text('Add menu item'),
            ),
          ],

          const SizedBox(height: 24),
          Text(
            reviews.isEmpty
                ? 'Reviews'
                : 'Reviews  ·  ${avg.toStringAsFixed(1)} / 5',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write a review after booking and GPS check-in.',
            style: TextStyle(color: Color(0xFF8A7466), fontSize: 12),
          ),
          const SizedBox(height: 12),
          if (reviews.isEmpty)
            const Text(
              'No reviews yet.',
              style: TextStyle(color: Color(0xFF8A7466)),
            ),
          ...reviews.map(
            (review) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${'★' * review.stars}  ${review.author}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(review.comment),
                  if (review.photo != null && review.photo!.hasImage) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: AttachedPhotoView(
                        photo: review.photo!,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ],
              ),
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
      bottomNavigationBar: showOrderBar
          ? Material(
              elevation: 12,
              color: Colors.white,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$draftCount item${draftCount == 1 ? '' : 's'} selected',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '₩$draftTotal',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: AppColors.sage,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                final err = provider.commitDraftToCart(
                                  userId: user.uid,
                                  storeId: shop.id,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(err ?? 'Saved to cart.'),
                                  ),
                                );
                              },
                              child: const Text('Add to cart'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.sage,
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => FoodridgeCheckoutScreen(
                                      source: MealPickCheckoutSource.shopDraft,
                                      storeId: shop.id,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Book / Pay'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Future<void> _showAddMenuDialog(
    BuildContext context,
    FoodridgeProvider provider,
    String storeId,
  ) async {
    final result = await showDialog<_AddMenuResult>(
      context: context,
      builder: (context) => const _AddMenuDialog(),
    );
    if (result == null || !context.mounted) return;

    final err = provider.addMenuItem(
      storeId: storeId,
      name: result.name,
      price: result.price,
      remainingQty: result.remaining,
      photoAsset: result.photo?.assetPath,
      photoPath: result.photo?.filePath,
      photoBytes: result.photo?.bytes,
    );

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(err ?? 'Menu added.')),
    );
  }
}

class _AddMenuResult {
  const _AddMenuResult({
    required this.name,
    required this.price,
    required this.remaining,
    this.photo,
  });

  final String name;
  final int price;
  final int remaining;
  final AttachedPhoto? photo;
}

class _AddMenuDialog extends StatefulWidget {
  const _AddMenuDialog();

  @override
  State<_AddMenuDialog> createState() => _AddMenuDialogState();
}

class _AddMenuDialogState extends State<_AddMenuDialog> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(text: '4000');
  final _remainingController = TextEditingController(text: '3');
  AttachedPhoto? _photo;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _remainingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width;
    final dialogWidth = maxWidth < 420 ? maxWidth - 48 : 360.0;

    return AlertDialog(
      title: const Text('Owner: Add menu item'),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PhotoAttachField(
                photo: _photo,
                onChanged: (value) => setState(() => _photo = value),
                label: 'Menu photo',
                cameraLabel: 'Take photo',
                galleryLabel: 'Choose from gallery',
                removeLabel: 'Remove photo',
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Price (₩)'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _remainingController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Remaining qty'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(
              context,
              _AddMenuResult(
                name: _nameController.text,
                price: int.tryParse(_priceController.text) ?? 0,
                remaining: int.tryParse(_remainingController.text) ?? 0,
                photo: _photo,
              ),
            );
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _QtyStepper extends StatelessWidget {
  const _QtyStepper({
    required this.qty,
    required this.onMinus,
    required this.onPlus,
  });

  final int qty;
  final VoidCallback onMinus;
  final VoidCallback? onPlus;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton.filledTonal(
          visualDensity: VisualDensity.compact,
          onPressed: onMinus,
          icon: const Icon(Icons.remove, size: 18),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$qty',
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
        IconButton.filled(
          visualDensity: VisualDensity.compact,
          style: IconButton.styleFrom(backgroundColor: AppColors.sage),
          onPressed: onPlus,
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
        ),
      ],
    );
  }
}
