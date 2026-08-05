import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  inconvenience('이용자 불편'),
  cleanliness('청결 상태'),
  damage('기물 파손'),
  other('기타');

  final String label;
  const ReportType(this.label);

  static ReportType fromValue(String value) {
    return ReportType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportType.other,
    );
  }
}

enum ReportStatus {
  pending('대기 중'),
  accepted('수용됨'),
  rejected('거절됨'),
  withdrawn('철회됨');

  final String label;
  const ReportStatus(this.label);

  static ReportStatus fromValue(String value) {
    return ReportStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReportStatus.pending,
    );
  }
}

class Report {
  const Report({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.content,
    required this.createdAt,
    this.offenderId,
    this.status = ReportStatus.pending,
    this.adminComment,
    this.processedAt,
  });

  final String id;
  final String userId;
  final String userName;
  final ReportType type;
  final String content;
  final DateTime createdAt;
  final String? offenderId;
  final ReportStatus status;
  final String? adminComment;
  final DateTime? processedAt;

  bool get canWithdraw => status == ReportStatus.pending;

  factory Report.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Report(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      type: ReportType.fromValue(data['type'] as String? ?? 'other'),
      content: data['content'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      offenderId: data['offenderId'] as String?,
      status: ReportStatus.fromValue(data['status'] as String? ?? 'pending'),
      adminComment: data['adminComment'] as String?,
      processedAt: (data['processedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'type': type.name,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (offenderId != null) 'offenderId': offenderId,
      'status': status.name,
      if (adminComment != null) 'adminComment': adminComment,
      if (processedAt != null) 'processedAt': Timestamp.fromDate(processedAt!),
    };
  }
}
