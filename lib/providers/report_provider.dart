import 'package:flutter/material.dart';

import '../models/report.dart';
import '../services/demo_auth_store.dart';

/// 데모용 로컬 신고 Provider (Firestore 없음). 접수·철회·관리자 처리.
class ReportProvider with ChangeNotifier {
  ReportProvider() {
    _seedDemo();
  }

  final List<Report> _reports = [];
  String? _myUserId;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  List<Report> get allReports {
    final list = List<Report>.of(_reports);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  List<Report> get myReports {
    final uid = _myUserId;
    if (uid == null) return const [];
    return allReports.where((r) => r.userId == uid).toList();
  }

  List<Report> get pendingReports =>
      allReports.where((r) => r.status == ReportStatus.pending).toList();

  List<Report> get completedReports =>
      allReports.where((r) => r.status != ReportStatus.pending).toList();

  void _seedDemo() {
    final now = DateTime.now();
    _reports.addAll([
      Report(
        id: 'rp-1',
        userId: 'demo-student',
        userName: '김대학',
        type: ReportType.cleanliness,
        content: '전남대 환승반찬 자판기 안쪽에 국물이 말라 붙어 있고 냄새가 납니다.',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      Report(
        id: 'rp-2',
        userId: 'demo-youth',
        userName: '이청년',
        type: ReportType.damage,
        content: '광주여대 자판기 문이 잘 닫히지 않아 찬 공기가 샙니다.',
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
      Report(
        id: 'rp-3',
        userId: 'demo-guest-1',
        userName: '박유학',
        type: ReportType.inconvenience,
        content: 'MealPick 픽업 안내 시간과 가게 실제 마감이 달라 대기했습니다.',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Report(
        id: 'rp-4',
        userId: 'demo-student',
        userName: '김대학',
        type: ReportType.cleanliness,
        content: '호남대 자판기 바닥에 국물이 흘러 있었습니다.',
        createdAt: now.subtract(const Duration(days: 3)),
        status: ReportStatus.accepted,
        adminComment: '현장 확인 후 청소 완료. 유효 신고로 무료 식권 1장을 지급했습니다.',
        processedAt: now.subtract(const Duration(days: 2)),
      ),
      Report(
        id: 'rp-5',
        userId: 'demo-youth',
        userName: '이청년',
        type: ReportType.other,
        content: '친구카세 메뉴가 너무 적어서 신고합니다.',
        createdAt: now.subtract(const Duration(days: 4)),
        status: ReportStatus.rejected,
        adminComment: '메뉴 구성은 신고 대상이 아닙니다. 일정별 메뉴는 앱 안내를 확인해 주세요.',
        processedAt: now.subtract(const Duration(days: 3)),
      ),
      Report(
        id: 'rp-6',
        userId: 'demo-guest-2',
        userName: '정민수',
        type: ReportType.inconvenience,
        content: '조선대 자판기 번호가 안내와 다르게 붙어 있었습니다.',
        createdAt: now.subtract(const Duration(days: 6)),
        status: ReportStatus.withdrawn,
        processedAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  Future<void> fetchMyReports(String userId) async {
    _myUserId = userId;
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllReports() async {
    _isLoading = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 80));
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> submitReport({
    required String userId,
    required String userName,
    required ReportType type,
    required String content,
    String? offenderId,
  }) async {
    final text = content.trim();
    if (text.isEmpty) return false;
    _reports.add(
      Report(
        id: 'rp-${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        userName: userName,
        type: type,
        content: text,
        createdAt: DateTime.now(),
        offenderId: offenderId,
      ),
    );
    _myUserId = userId;
    notifyListeners();
    return true;
  }

  Future<bool> withdrawReport(String reportId, String userId) async {
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) return false;
    final report = _reports[i];
    if (report.userId != userId || !report.canWithdraw) return false;
    _reports[i] = report.copyWith(
      status: ReportStatus.withdrawn,
      processedAt: DateTime.now(),
    );
    notifyListeners();
    return true;
  }

  Future<bool> processReport(
    String reportId,
    ReportStatus status, {
    String? adminComment,
  }) async {
    if (status == ReportStatus.pending) return false;
    final i = _reports.indexWhere((r) => r.id == reportId);
    if (i < 0) return false;
    final report = _reports[i];
    if (!report.isPending) return false;

    _reports[i] = report.copyWith(
      status: status,
      adminComment: adminComment?.trim().isEmpty == true
          ? null
          : adminComment?.trim(),
      processedAt: DateTime.now(),
    );

    if (status == ReportStatus.accepted) {
      DemoAuthStore.grantMealCoupon(report.userId);
      if (report.offenderId != null) {
        DemoAuthStore.addPenalty(report.offenderId!);
      }
    }
    notifyListeners();
    return true;
  }
}
