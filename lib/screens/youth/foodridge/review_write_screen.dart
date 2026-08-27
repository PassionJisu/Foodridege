import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/attached_photo.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/photo_attach_field.dart';

/// Foodridge review write — English UI. Does NOT award meal tickets.
class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key, required this.shopId});
  final String shopId;

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final _content = TextEditingController();
  int _stars = 5;
  AttachedPhoto? _photo;
  bool _saving = false;

  @override
  void dispose() {
    _content.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = context.read<AuthProvider>();
    final provider = context.read<FoodridgeProvider>();
    final user = auth.appUser;
    if (user == null) return;
    setState(() => _saving = true);
    final err = provider.addReview(
      userId: user.uid,
      shopId: widget.shopId,
      author: user.name,
      stars: _stars,
      comment: _content.text,
      photo: _photo,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thanks for your review!'),
        content: const Text(
          'Your review was posted. Meal tickets are only earned in Chingu-kase.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FoodridgeProvider>();
    final user = context.watch<AuthProvider>().appUser!;
    final shop = provider.shopById(widget.shopId);
    final allowed = provider.canWriteReviewFor(user.uid, widget.shopId);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: Text('Review · ${shop.name}')),
      body: !allowed
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  provider.reviewBlockReason(user.uid, widget.shopId),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF8A7466)),
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text('Stars', style: TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: List.generate(5, (i) {
                    return IconButton(
                      onPressed: () => setState(() => _stars = i + 1),
                      icon: Icon(
                        i < _stars ? Icons.star : Icons.star_border,
                        color: AppColors.sage,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: _content,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Share your experience',
                  ),
                ),
                PhotoAttachField(
                  photo: _photo,
                  onChanged: (value) => setState(() => _photo = value),
                  label: 'Add a photo (optional)',
                  cameraLabel: 'Take photo',
                  galleryLabel: 'Choose from gallery',
                  removeLabel: 'Remove photo',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? 'Posting…' : 'Post review'),
                ),
              ],
            ),
    );
  }
}
