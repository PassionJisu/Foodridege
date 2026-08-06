import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/report.dart';

class ReportProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Report> _myReports = [];
  List<Report> _allReports = [];
  bool _isLoading = false;

  List<Report> get myReports => _myReports;
  List<Report> get allReports => _allReports;
  bool get isLoading => _isLoading;

  Future<void> fetchMyReports(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // 인덱스 문제 확인을 위해 우선 orderBy를 제거하거나, 
      // 에러 메시지에 포함된 URL을 통해 인덱스를 생성해야 합니다.
      final snapshot = await _firestore
          .collection('reports')
          .where('userId', isEqualTo: userId)
          .get(); // 일단 정렬 없이 가져오기 시도
      
      _myReports = snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      
      // 정렬은 클라이언트 사이드에서 수행 (인덱스 없이도 가능)
      _myReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      debugPrint('Fetched ${_myReports.length} reports for user: $userId');
    } catch (e) {
      debugPrint('Error fetching reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// [Admin 전용] 모든 신고 내역 가져오기
  Future<void> fetchAllReports() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('reports').get();
      _allReports = snapshot.docs.map((doc) => Report.fromFirestore(doc)).toList();
      
      // 최신순 정렬
      _allReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      debugPrint('Fetched ${_allReports.length} total reports for admin.');
    } catch (e) {
      debugPrint('Error fetching all reports: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitReport({
    required String userId,
    required String userName,
    required ReportType type,
    required String content,
    String? offenderId,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'userId': userId,
        'userName': userName,
        'type': type.name,
        'content': content,
        'status': ReportStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        if (offenderId != null) 'offenderId': offenderId,
      });
      await fetchMyReports(userId);
      return true;
    } catch (e) {
      debugPrint('Error submitting report: $e');
      return false;
    }
  }

  Future<bool> withdrawReport(String reportId, String userId) async {
    try {
      final ref = _firestore.collection('reports').doc(reportId);
      final doc = await ref.get();
      if (!doc.exists) return false;
      
      final report = Report.fromFirestore(doc);
      if (!report.canWithdraw) return false;

      await ref.delete();
      await fetchMyReports(userId);
      return true;
    } catch (e) {
      debugPrint('Error withdrawing report: $e');
      return false;
    }
  }

  /// [Admin 전용] 신고 처리
  Future<void> processReport(String reportId, ReportStatus status, {String? adminComment}) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final reportRef = _firestore.collection('reports').doc(reportId);
        final reportDoc = await transaction.get(reportRef);
        final report = Report.fromFirestore(reportDoc);

        transaction.update(reportRef, {
          'status': status.name,
          'adminComment': adminComment,
          'processedAt': FieldValue.serverTimestamp(),
        });

        if (status == ReportStatus.accepted) {
          // 1. 신고자에게 무료 쿠폰 지급
          final reporterRef = _firestore.collection('users').doc(report.userId);
          transaction.update(reporterRef, {
            'freeMealCount': FieldValue.increment(1),
          });

          // 2. 피신고자에게 패널티 부여 (있을 경우)
          if (report.offenderId != null) {
            final offenderRef = _firestore.collection('users').doc(report.offenderId!);
            final offenderDoc = await transaction.get(offenderRef);
            final penaltyPoints = (offenderDoc.data()?['penaltyPoints'] as int? ?? 0) + 1;
            
            Map<String, dynamic> updateData = {'penaltyPoints': penaltyPoints};
            
            // 2점 초과 시 6개월 정지
            if (penaltyPoints > 2) {
              final suspendedUntil = DateTime.now().add(const Duration(days: 180));
              updateData['suspendedUntil'] = Timestamp.fromDate(suspendedUntil);
            }
            
            transaction.update(offenderRef, updateData);
          }
        }
      });
    } catch (e) {
      debugPrint('Error processing report: $e');
    }
  }
}
