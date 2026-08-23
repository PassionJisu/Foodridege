import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/vending.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/vending_provider.dart';
import '../../../theme/app_theme.dart';

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

    return Scaffold(
      backgroundColor: AppColors.vendingBg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            DropdownButtonFormField<String>(
              key: ValueKey(selectedId),
              initialValue: selectedId,
              dropdownColor: AppColors.vendingCard,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.vendingCard,
                labelText: '지점 선택',
                labelStyle: const TextStyle(color: Colors.white70),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
                ),
              ),
              items: machines
                  .map(
                    (m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.name),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() => _machineId = value),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  Image.asset(
                    'assets/images/vending_banner.png',
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 210,
                      color: const Color(0xFF163022),
                    ),
                  ),
                  Container(
                    height: 210,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.25),
                          Colors.black.withValues(alpha: 0.72),
                        ],
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.vendingLeaf.withValues(alpha: 0.85),
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
                            '${user.contributedGrams} g',
                            style: const TextStyle(
                              color: AppColors.vendingAccent,
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            '자판기 1회 이용 = 200g · 당일 반찬만 적재됩니다',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                const Text(
                  '현재 판매 중',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '$used / ${VendingMachine.maxSlots} 슬롯',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              machine.location,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
            if (machine.isExpired)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  '입고 마감 후 24시간이 지나 전량 폐기 대상입니다.',
                  style: TextStyle(color: Colors.orangeAccent, fontSize: 12),
                ),
              ),
            const SizedBox(height: 16),
            if (slots.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 48),
                child: Column(
                  children: [
                    Icon(Icons.kitchen_outlined, size: 64, color: Colors.white.withValues(alpha: 0.25)),
                    const SizedBox(height: 12),
                    const Text(
                      '현재 입고된 상품이 없어요',
                      style: TextStyle(color: Colors.white54),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '1,000원 / 200g 균일 · 앱에서 예약·결제는 하지 않습니다',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
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
                    color: AppColors.vendingCard,
                    borderRadius: BorderRadius.circular(16),
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
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'No. ${slot.displayNumber.toString().padLeft(2, '0')}  ·  ${slot.quantity}개  ·  1,000원',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
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
      default:
        return 0xFF4A6741;
    }
  }
}
