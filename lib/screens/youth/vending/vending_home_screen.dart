import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/vending.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/vending_provider.dart';
import '../../../theme/app_theme.dart';
import '../../provider/org_supply_screen.dart';

class VendingHomeScreen extends StatefulWidget {
  const VendingHomeScreen({super.key});

  @override
  State<VendingHomeScreen> createState() => _VendingHomeScreenState();
}

class _VendingHomeScreenState extends State<VendingHomeScreen> {
  String? _machineId;

  @override
  Widget build(BuildContext context) {
    final vending = context.watch<VendingProvider>();
    final user = context.watch<AuthProvider>().appUser!;
    final machines = vending.machines;
    final selectedId = _machineId ?? machines.first.id;
    final machine = vending.machineById(selectedId);
    final slots = vending.slotsFor(selectedId);
    final used = vending.usedSlots(selectedId);
    final showSupplyFab = user.role.canSubmitSupply;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      floatingActionButton: showSupplyFab
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const OrgSupplyScreen(),
                  ),
                );
              },
              backgroundColor: AppColors.sage,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.inventory_2_outlined),
              label: const Text('환승반찬 입고'),
            )
          : null,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 88),
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(selectedId),
              initialValue: selectedId,
              decoration: const InputDecoration(labelText: '지점 선택'),
              items: machines
                  .map((m) => DropdownMenuItem(value: m.id, child: Text(m.name)))
                  .toList(),
              onChanged: (value) => setState(() => _machineId = value),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                height: 180,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/vending_banner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.sage),
                    ),
                    Container(
                      color: AppColors.sage.withValues(alpha: 0.72),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '식자재 순환 프로젝트',
                              style: TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '내가 환경과 지역사회에 기여한 무게',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          Text(
                            user.contributedKgLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Text(
                  '현재 판매 중',
                  style: TextStyle(
                    color: AppColors.ink,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$used / ${VendingMachine.maxSlots} 슬롯',
                  style: const TextStyle(color: Color(0xFF8A7466)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              machine.location,
              style: const TextStyle(color: Color(0xFF8A7466), fontSize: 12),
            ),
            if (machine.isExpired)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '입고 마감 후 24시간이 지나 전량 폐기 대상입니다.',
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            if (slots.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.kitchen_outlined, size: 64, color: Color(0xFFC4B5A5)),
                    SizedBox(height: 12),
                    Text(
                      '현재 입고된 상품이 없어요',
                      style: TextStyle(color: Color(0xFF8A7466)),
                    ),
                  ],
                ),
              )
            else
              ...slots.map(
                (slot) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD4C8B4)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Color(SeedColor.forName(slot.name)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.rice_bowl, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              slot.name,
                              style: const TextStyle(
                                color: AppColors.ink,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'No. ${slot.displayNumber.toString().padLeft(2, '0')}  ·  ${slot.quantity}개  ·  1,000원',
                              style: const TextStyle(
                                color: Color(0xFF8A7466),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SeedColor {
  static int forName(String name) {
    switch (name) {
      case '멸치볶음':
        return 0xFFC4783A;
      case '시금치나물':
        return 0xFF3D8B6E;
      case '계란말이':
        return 0xFFD4A017;
      case '콩자반':
        return 0xFF5C4033;
      case '제육볶음':
        return 0xFFB33A3A;
      case '고등어조림':
        return 0xFF4A6FA5;
      case '잡채':
        return 0xFF8B6914;
      default:
        return 0xFF4A6741;
    }
  }
}
