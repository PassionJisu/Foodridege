import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Foodridge2 할매키친 보증금 결제 플로우를 친구카세 식권에 맞게 이식한 데모 화면.
class TicketDepositPaymentScreen extends StatefulWidget {
  const TicketDepositPaymentScreen({
    super.key,
    required this.matchTitle,
    this.depositAmount = 500,
  });

  final String matchTitle;
  final int depositAmount;

  @override
  State<TicketDepositPaymentScreen> createState() =>
      _TicketDepositPaymentScreenState();
}

enum _Stage { confirm, processing, done }

class _TicketDepositPaymentScreenState extends State<TicketDepositPaymentScreen> {
  _Stage _stage = _Stage.confirm;

  Future<void> _pay() async {
    setState(() => _stage = _Stage.processing);
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _stage = _Stage.done);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('식권 보증금 결제')),
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
                      '식권 예약을 위해 보증금 ${widget.depositAmount}원을 결제합니다.\n'
                      '현장 수령 확인 시 보증금은 환급되며, 노쇼 시에는 환급되지 않습니다.\n'
                      '현장 키오스크에서는 보증금 제외 1,000원으로 발권됩니다.',
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                    onPressed: _pay,
                    child: Text('보증금 ${widget.depositAmount}원 결제'),
                  ),
                ],
              ),
            _Stage.processing => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('결제 처리 중…'),
                  ],
                ),
              ),
            _Stage.done => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.check_circle, color: AppColors.sage, size: 72),
                  const SizedBox(height: 16),
                  const Text(
                    '보증금 결제가 완료되었습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '식권이 예약되었습니다. 경기 당일 키오스크에서 발권해 주세요.',
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('확인'),
                  ),
                ],
              ),
          },
        ),
      ),
    );
  }
}
