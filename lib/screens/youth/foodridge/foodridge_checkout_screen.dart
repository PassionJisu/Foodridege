import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/foodridge_cart_line.dart';
import '../../../models/foodridge_reservation.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'foodridge_in_app_payment_screen.dart';
import 'foodridge_reservations_screen.dart';

enum MealPickCheckoutSource { cart, shopDraft }

class FoodridgeCheckoutScreen extends StatefulWidget {
  const FoodridgeCheckoutScreen({
    super.key,
    required this.source,
    this.storeId,
  });

  final MealPickCheckoutSource source;
  final String? storeId;

  @override
  State<FoodridgeCheckoutScreen> createState() =>
      _FoodridgeCheckoutScreenState();
}

class _FoodridgeCheckoutScreenState extends State<FoodridgeCheckoutScreen> {
  FoodridgePaymentMethod? _method;

  List<FoodridgeCartLine> _lines(FoodridgeProvider provider, String userId) {
    if (widget.source == MealPickCheckoutSource.shopDraft) {
      return provider.draftFor(userId, widget.storeId!);
    }
    return provider.cartFor(userId);
  }

  Future<void> _confirm() async {
    final method = _method;
    if (method == null) return;
    final auth = context.read<AuthProvider>();
    final user = auth.appUser;
    if (user == null) return;
    final provider = context.read<FoodridgeProvider>();
    final lines = _lines(provider, user.uid);
    final total = lines.fold<int>(0, (sum, l) => sum + l.lineTotal);
    final summary = lines.length == 1
        ? lines.first.menuItemName
        : '${lines.length} items';

    var paid = false;
    if (method == FoodridgePaymentMethod.inApp) {
      final ok = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => FoodridgeInAppPaymentScreen(
            amount: total,
            summary: summary,
          ),
        ),
      );
      if (ok != true) return;
      paid = true;
    }

    if (!mounted) return;
    final err = widget.source == MealPickCheckoutSource.shopDraft
        ? provider.checkoutDraft(
            userId: user.uid,
            storeId: widget.storeId!,
            paymentMethod: method,
            paid: paid,
          )
        : provider.checkoutCart(
            userId: user.uid,
            paymentMethod: method,
            paid: paid,
          );
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }

    final message = method == FoodridgePaymentMethod.inApp
        ? 'Paid in app. Pick up at the kitchen.'
        : 'Booked. Pay at the store when you pick up.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const FoodridgeReservationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final provider = context.watch<FoodridgeProvider>();
    final lines = _lines(provider, user.uid);
    final total = lines.fold<int>(0, (sum, l) => sum + l.lineTotal);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('Book / Pay')),
      body: lines.isEmpty
          ? const Center(
              child: Text(
                'Nothing to check out.',
                style: TextStyle(color: Color(0xFF8A7466)),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Order',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 10),
                ...lines.map(
                  (line) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${line.menuItemName}  ×${line.qty}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text('₩${line.lineTotal}'),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
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
                const SizedBox(height: 24),
                const Text(
                  'How would you like to pay?',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pickup is required either way.',
                  style: TextStyle(color: Color(0xFF8A7466), fontSize: 13),
                ),
                const SizedBox(height: 12),
                _PayOptionCard(
                  selected: _method == FoodridgePaymentMethod.onSite,
                  icon: Icons.storefront_outlined,
                  title: 'Pay at store',
                  subtitle:
                      'Reserve now and pay when you pick up. Same as the existing booking flow.',
                  onTap: () =>
                      setState(() => _method = FoodridgePaymentMethod.onSite),
                ),
                const SizedBox(height: 10),
                _PayOptionCard(
                  selected: _method == FoodridgePaymentMethod.inApp,
                  icon: Icons.smartphone_outlined,
                  title: 'Pay in app',
                  subtitle:
                      'Complete payment here, then pick up at the kitchen.',
                  onTap: () =>
                      setState(() => _method = FoodridgePaymentMethod.inApp),
                ),
              ],
            ),
      bottomNavigationBar: lines.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.sage,
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _method == null ? null : _confirm,
                  child: Text(
                    _method == FoodridgePaymentMethod.inApp
                        ? 'Continue to payment'
                        : _method == FoodridgePaymentMethod.onSite
                            ? 'Confirm booking'
                            : 'Choose a payment method',
                  ),
                ),
              ),
            ),
    );
  }
}

class _PayOptionCard extends StatelessWidget {
  const _PayOptionCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.sage : const Color(0xFFD4C8B4),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: selected ? AppColors.sage : AppColors.ink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected ? AppColors.sage : AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A7466),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.sage : const Color(0xFF8A7466),
            ),
          ],
        ),
      ),
    );
  }
}
