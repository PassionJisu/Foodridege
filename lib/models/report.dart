enum ReportType {
  inconvenience('이용자 불편'),
  cleanliness('청결 상태'),
  damage('기물 파손'),
  other('기타');

  final String label;
  const ReportType(this.label);
}

enum ReportStatus {
  pending('대기 중'),
  accepted('수용됨'),
  rejected('거절됨'),
  withdrawn('철회됨');

  final String label;
  const ReportStatus(this.label);
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
  bool get isPending => status == ReportStatus.pending;

  Report copyWith({
    ReportStatus? status,
    String? adminComment,
    DateTime? processedAt,
  }) {
    return Report(
      id: id,
      userId: userId,
      userName: userName,
      type: type,
      content: content,
      createdAt: createdAt,
      offenderId: offenderId,
      status: status ?? this.status,
      adminComment: adminComment ?? this.adminComment,
      processedAt: processedAt ?? this.processedAt,
    );
  }
}
