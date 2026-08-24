import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// 식권 전액(1,500원) 결제 데모 — 키오스크 현장결제 없음.
class TicketDepositPaymentScreen extends StatefulWidget {
  const TicketDepositPaymentScreen({
    super.key,
    required this.matchTitle,
    this.amount = 1500,
  });

  final String matchTitle;
  final int amount;

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
                      '식권 금액 ${widget.amount}원을 즉시 결제합니다.\n'
                      '결제 완료 후 바로 리뷰를 작성할 수 있습니다.\n'
                      '현장 키오스크 추가 결제는 없습니다.',
                      style: const TextStyle(height: 1.45),
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.sage),
                    onPressed: _pay,
                    child: Text('${widget.amount}원 결제하기'),
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
                    '결제가 완료되었습니다',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '식권이 확정되었습니다. 리뷰를 작성해 주세요.',
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
