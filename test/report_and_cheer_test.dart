import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_app/data/seed_data.dart';
import 'package:flutter_app/models/report.dart';
import 'package:flutter_app/providers/chingu_provider.dart';
import 'package:flutter_app/providers/report_provider.dart';
import 'package:flutter_app/screens/youth/chingu/chingu_ranking_screen.dart';
import 'package:flutter_app/services/demo_auth_store.dart';

void main() {
  test('친구카세 예약 일정은 평일만 있다', () {
    final scheduled = SeedData.matches.where((m) => !m.isCompleted).toList();
    expect(scheduled.map((m) => m.roundLabel).toList(), [
      '10월 1일 (목)',
      '10월 2일 (금)',
      '10월 5일 (월)',
      '10월 6일 (화)',
    ]);
    for (final match in scheduled) {
      expect(match.date.weekday, lessThan(6));
    }
  });

  test('신고 더미가 있고 접수·철회·처리가 된다', () async {
    final reports = ReportProvider();
    expect(reports.pendingReports, isNotEmpty);
    expect(reports.completedReports, isNotEmpty);

    await reports.fetchMyReports('demo-student');
    expect(reports.myReports, isNotEmpty);
    expect(
      reports.myReports.every((r) => r.userId == 'demo-student'),
      isTrue,
    );

    final before = DemoAuthStore.userById('demo-student')!.mealCouponCount;
    final pendingId = reports.pendingReports
        .firstWhere((r) => r.userId == 'demo-student')
        .id;
    final accepted = await reports.processReport(
      pendingId,
      ReportStatus.accepted,
      adminComment: '확인 후 조치했습니다.',
    );
    expect(accepted, isTrue);
    expect(
      reports.allReports.firstWhere((r) => r.id == pendingId).status,
      ReportStatus.accepted,
    );
    expect(
      DemoAuthStore.userById('demo-student')!.mealCouponCount,
      before + 1,
    );

    final submitted = await reports.submitReport(
      userId: 'demo-student',
      userName: '김대학',
      type: ReportType.damage,
      content: '광주대 자판기 버튼이 빠졌습니다.',
    );
    expect(submitted, isTrue);
    final newPending = reports.pendingReports.firstWhere(
      (r) => r.content.contains('광주대'),
    );
    expect(
      await reports.withdrawReport(newPending.id, 'demo-student'),
      isTrue,
    );
    expect(
      reports.allReports.firstWhere((r) => r.id == newPending.id).status,
      ReportStatus.withdrawn,
    );
  });

  test('하루 한 번 응원한 뒤에는 다른 팀을 응원할 수 없다', () {
    final chingu = ChinguProvider();
    expect(chingu.cheer('gju'), isNull);
    expect(chingu.alreadyCheeredToday('gju'), isTrue);
    expect(chingu.cheer('nambu'), '하루에 1곳만 응원할 수 있어요!');
    expect(chingu.alreadyCheeredToday('nambu'), isFalse);
  });

  testWidgets('다른 학교 응원 버튼을 누르면 하루 1곳 팝업이 뜬다', (tester) async {
    final chingu = ChinguProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: chingu,
        child: const MaterialApp(home: ChinguRankingScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('응원').first);
    await tester.pump();

    await tester.tap(find.text('응원').first);
    await tester.pump();

    expect(find.text('하루에 1곳만 응원할 수 있어요!'), findsOneWidget);
  });
}
