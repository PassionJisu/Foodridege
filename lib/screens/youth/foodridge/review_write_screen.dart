import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';

/// Foodridge2 review_write_screen 이식 — 크림톤, 스탬프 문구 제외.
class ReviewWriteScreen extends StatefulWidget {
  const ReviewWriteScreen({super.key, required this.shopId});
  final String shopId;

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final _content = TextEditingController();
  int _stars = 5;
  String? _photoNote;
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
      photoNote: _photoNote,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final reward = await auth.recordReviewReward();
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리뷰가 등록되었어요!'),
        content: Text(reward),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
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
      appBar: AppBar(title: Text('${shop.name} 리뷰')),
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
                const Text('별점', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  decoration: const InputDecoration(hintText: '리뷰를 남겨 주세요'),
                ),
                TextButton(
                  onPressed: () => setState(() => _photoNote = '사진 첨부(데모)'),
                  child: Text(_photoNote ?? '사진 첨부 (선택)'),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? '등록 중…' : '리뷰 등록'),
                ),
              ],
            ),
    );
  }
}
