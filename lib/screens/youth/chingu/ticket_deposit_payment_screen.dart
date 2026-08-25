import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../theme/app_theme.dart';
import 'free_ticket_flow.dart';

/// 식권 전액(1,000원) 결제 데모 — 보유 무료 식권이 있으면 사용 여부를 묻는다.
class TicketDepositPaymentScreen extends StatefulWidget {
  const TicketDepositPaymentScreen({
    super.key,
    required this.matchTitle,
    this.amount = 1000,
  });

  final String matchTitle;
  final int amount;

  @override
  State<TicketDepositPaymentScreen> createState() =>
      _TicketDepositPaymentScreenState();
}

enum _Stage { confirm, processing }

class _TicketDepositPaymentScreenState extends State<TicketDepositPaymentScreen> {
  _Stage _stage = _Stage.confirm;
  String _processingLabel = '결제 처리 중…';

  Future<void> _pay() async {
    final auth = context.read<AuthProvider>();
    final coupons = auth.appUser?.displayCouponCount ?? 0;
    var useFree = false;
    if (coupons > 0) {
      final answer = await askApplyFreeTicketOnPay(context, coupons);
      if (!mounted || answer == null) return;
      useFree = answer;
    }

    setState(() {
      _stage = _Stage.processing;
      _processingLabel = useFree ? '무료 식권으로 결제 중…' : '결제 처리 중…';
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    if (useFree && !auth.consumeMealCoupon()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('무료 식권을 사용하지 못했습니다. 다시 시도해 주세요.')),
      );
      setState(() => _stage = _Stage.confirm);
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final coupons =
        context.watch<AuthProvider>().appUser?.displayCouponCount ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('식권 결제')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: switch (_stage) {
            _Stage.confirm => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    widget.matchTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.canvasDeep,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      coupons > 0
                          ? '식권 금액 ${widget.amount}원.\n'
                              '무료 식권 $coupons장을 가지고 있습니다. '
                              '결제할 때 사용할지 선택할 수 있습니다.\n'
                              '현장 키오스크 추가 결제는 없습니다.'
                          : '식권 금액 ${widget.amount}원을 즉시 결제합니다.\n'
                              '현장 키오스크 추가 결제는 없습니다.',
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                    onPressed: _pay,
                    child: Text(
                      coupons > 0 ? '결제하기' : '${widget.amount}원 결제하기',
                    ),
                  ),
                ],
              ),
            _Stage.processing => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(_processingLabel),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }
}
