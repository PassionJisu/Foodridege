import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/foodridge_reservation.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/foodridge_provider.dart';
import '../../../theme/app_theme.dart';
import 'review_write_screen.dart';

/// Foodridge2 reservations screen — cream UI, English copy, no stamps.
class FoodridgeReservationsScreen extends StatefulWidget {
  const FoodridgeReservationsScreen({super.key});

  @override
  State<FoodridgeReservationsScreen> createState() =>
      _FoodridgeReservationsScreenState();
}

class _FoodridgeReservationsScreenState
    extends State<FoodridgeReservationsScreen> {
  String? _verifyingId;

  Future<void> _verify(
    FoodridgeProvider provider,
    FoodridgeReservation reservation, {
    bool bypassGps = false,
  }) async {
    setState(() => _verifyingId = reservation.id);
    final result = await provider.verifyArrival(
      reservation.id,
      bypassGps: bypassGps,
    );
    if (!mounted) return;
    setState(() => _verifyingId = null);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        action: result.success
            ? SnackBarAction(
                label: 'Write review',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ReviewWriteScreen(shopId: reservation.shopId),
                    ),
                  );
                },
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().appUser!;
    final provider = context.watch<FoodridgeProvider>();
    final list = provider.reservationsFor(user.uid);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(title: const Text('My bookings')),
      body: list.isEmpty
          ? const Center(
              child: Text(
                'No surplus bookings yet.',
                style: TextStyle(color: Color(0xFF8A7466)),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = list[i];
                final verifying = _verifyingId == r.id;
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
                        r.shopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${r.itemLabel} · ₩${r.price}',
                        style: const TextStyle(color: Color(0xFF8A7466)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.paid
                            ? 'Paid in app · pickup remaining'
                            : r.paymentMethod.label,
                        style: const TextStyle(
                          color: AppColors.sage,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r.paymentMethod.pickupNote,
                        style: const TextStyle(
                          color: Color(0xFF8A7466),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r.status.label,
                        style: TextStyle(
                          color: r.status == FoodridgeReservationStatus.arrived
                              ? AppColors.sage
                              : AppColors.ink,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (r.status == FoodridgeReservationStatus.reserved)
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: verifying
                                    ? null
                                    : () => _verify(provider, r),
                                child: Text(
                                  verifying ? 'Checking…' : 'GPS check-in',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.sage,
                                ),
                                onPressed: verifying
                                    ? null
                                    : () => _verify(
                                          provider,
                                          r,
                                          bypassGps: true,
                                        ),
                                child: const Text("I've arrived"),
                              ),
                            ),
                          ],
                        ),
                      if (r.canWriteReview)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    ReviewWriteScreen(shopId: r.shopId),
                              ),
                            );
                          },
                          child: const Text('Write a review'),
                        ),
                      if (r.status == FoodridgeReservationStatus.reserved)
                        TextButton(
                          onPressed: () {
                            provider.cancelReservation(r.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Booking cancelled.'),
                              ),
                            );
                          },
                          child: const Text(
                            'Cancel booking',
                            style: TextStyle(color: Colors.redAccent),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
