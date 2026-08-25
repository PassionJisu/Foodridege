import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import 'chingu_hub_screen.dart';

/// 홈·포스터·마이페이지의 보유 무료 식권을 눌렀을 때 사용 흐름을 시작한다.
Future<void> promptUseHeldFreeTickets(BuildContext context) async {
  final user = context.read<AuthProvider>().appUser;
  final count = user?.displayCouponCount ?? 0;
  if (count <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('보유한 무료 식권이 없습니다.')),
    );
    return;
  }

  final use = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('무료 식권'),
      content: Text(
        '무료로 사용할 수 있는 식권 $count개를 가지고 계세요!\n식권을 사용하겠습니까?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('나중에'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('사용하기'),
        ),
      ],
    ),
  );
  if (use != true || !context.mounted) return;

  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => const ChinguHubScreen(initialTab: 0),
    ),
  );
}

/// 결제 직전: 무료 식권을 이번에 쓸지 묻는다. null이면 결제 취소.
Future<bool?> askApplyFreeTicketOnPay(BuildContext context, int count) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('무료 식권 사용'),
      content: Text(
        '무료 식권 $count장이 있습니다.\n이번 결제에 사용하시겠습니까?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('1,000원 결제'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('무료 식권 사용'),
        ),
      ],
    ),
  );
}
