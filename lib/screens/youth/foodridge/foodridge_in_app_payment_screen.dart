import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Demo in-app checkout for MealPick. Completes payment in-app; pickup is still required.
class FoodridgeInAppPaymentScreen extends StatefulWidget {
  const FoodridgeInAppPaymentScreen({
    super.key,
    required this.amount,
    required this.summary,
  });

  final int amount;
  final String summary;

  @override
  State<FoodridgeInAppPaymentScreen> createState() =>
      _FoodridgeInAppPaymentScreenState();
}

enum _PayStage { confirm, processing, done }

class _FoodridgeInAppPaymentScreenState
    extends State<FoodridgeInAppPaymentScreen> {
  _PayStage _stage = _PayStage.confirm;

  Future<void> _pay() async {
    setState(() => _stage = _PayStage.processing);
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    setState(() => _stage = _PayStage.done);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('In-app payment')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: switch (_stage) {
            _PayStage.confirm => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.summary,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFD4C8B4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Amount',
                          style: TextStyle(color: Color(0xFF8A7466)),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₩${widget.amount}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            color: AppColors.sage,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Payment is completed in the app. You still need to pick up at the kitchen.',
                          style: TextStyle(
                            color: Color(0xFF8A7466),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3C2A21), Color(0xFF5E734C)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FOODRIDGE PAY  ·  DEMO',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 18),
                        Text(
                          '••••  ••••  ••••  2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text(
                          'In-app checkout',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.sage,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    onPressed: _pay,
                    child: Text('Pay ₩${widget.amount}'),
                  ),
                ],
              ),
            _PayStage.processing => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Processing payment…'),
                  ],
                ),
              ),
            _PayStage.done => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: AppColors.sage, size: 56),
                    SizedBox(height: 12),
                    Text(
                      'Payment complete',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Pick up at the kitchen.',
                      style: TextStyle(color: Color(0xFF8A7466)),
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}
