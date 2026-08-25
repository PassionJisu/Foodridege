import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

enum StudentOrigin {
  korean('korean', '일반 한국인 대학생'),
  exchange('exchange', '외국인 (교환학생)');

  const StudentOrigin(this.value, this.label);
  final String value;
  final String label;

  static StudentOrigin fromValue(String? value) {
    return StudentOrigin.values.firstWhere(
      (e) => e.value == value,
      orElse: () => StudentOrigin.korean,
    );
  }
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.birthDate,
    required this.rrnLastDigit,
    required this.phone,
    this.address,
    this.schoolInfo,
    this.businessRegistrationNumber,
    this.createdAt,
    this.streakCount = 0,
    this.lastOrderDate,
    this.freeMealCount = 0,
    this.penaltyPoints = 0,
    this.suspendedUntil,
    this.purchaseDayCount = 0,
    this.totalUsageCount = 0,
    this.vendingUsageCount = 0,
    this.chinguUsageCount = 0,
    this.rewardStack = 0,
    this.mealCouponCount = 0,
    this.helpedYouthCount = 0,
    this.reviewCount = 0,
    this.studentOrigin,
    this.stayStart,
    this.stayEnd,
  });

  final String uid;
  final String email;
  final UserRole role;
  final String name;
  final DateTime birthDate;
  final String rrnLastDigit;
  final String phone;
  final String? address;
  final String? schoolInfo;
  final String? businessRegistrationNumber;
  final DateTime? createdAt;
  final int streakCount;
  final DateTime? lastOrderDate;
  final int freeMealCount;
  final int penaltyPoints;
  final DateTime? suspendedUntil;
  final int purchaseDayCount;
  final int totalUsageCount;
  final int vendingUsageCount;
  final int chinguUsageCount;
  final int rewardStack;
  final int mealCouponCount;
  /// 점주 데모용: 배려를 받은 청년 수
  final int helpedYouthCount;
  /// 리뷰 작성 횟수 (5회마다 식권 리워드)
  final int reviewCount;
  /// 대학생: 한국인 / 외국인(교환학생)
  final StudentOrigin? studentOrigin;
  final DateTime? stayStart;
  final DateTime? stayEnd;

  bool get isExchangeStudent => studentOrigin == StudentOrigin.exchange;

  /// 체류 종료일 다음날부터 자동 탈퇴 대상.
  bool get isStayExpired {
    if (!isExchangeStudent || stayEnd == null) return false;
    final end = DateTime(stayEnd!.year, stayEnd!.month, stayEnd!.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(end);
  }

  static const reviewsPerCoupon = 5;

  int get reviewsToNextCoupon {
    final rem = reviewCount % reviewsPerCoupon;
    return rem == 0 && reviewCount > 0 ? reviewsPerCoupon : reviewsPerCoupon - rem;
  }

  int get contributedGrams => vendingUsageCount * 200;

  /// 표시용 kg (자판기 1회 = 0.2kg)
  double get contributedKg => contributedGrams / 1000.0;

  String get contributedKgLabel {
    final kg = contributedKg;
    if (kg == kg.roundToDouble()) return '${kg.toInt()}kg';
    return '${kg.toStringAsFixed(1)}kg';
  }

  int get usageDays {
    final start = createdAt ?? DateTime.now();
    return DateTime.now().difference(start).inDays.clamp(0, 36500) + 1;
  }

  int get displayCouponCount => mealCouponCount > 0 ? mealCouponCount : freeMealCount;

  bool get isSuspended {
    if (suspendedUntil == null) return false;
    return suspendedUntil!.isAfter(DateTime.now());
  }

  AppUser copyWith({
    int? vendingUsageCount,
    int? chinguUsageCount,
    int? rewardStack,
    int? mealCouponCount,
    int? freeMealCount,
    int? totalUsageCount,
    int? helpedYouthCount,
    int? reviewCount,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid,
      email: email,
      role: role,
      name: name,
      birthDate: birthDate,
      rrnLastDigit: rrnLastDigit,
      phone: phone,
      address: address,
      schoolInfo: schoolInfo,
      businessRegistrationNumber: businessRegistrationNumber,
      createdAt: createdAt ?? this.createdAt,
      streakCount: streakCount,
      lastOrderDate: lastOrderDate,
      freeMealCount: freeMealCount ?? this.freeMealCount,
      penaltyPoints: penaltyPoints,
      suspendedUntil: suspendedUntil,
      purchaseDayCount: purchaseDayCount,
      totalUsageCount: totalUsageCount ?? this.totalUsageCount,
      vendingUsageCount: vendingUsageCount ?? this.vendingUsageCount,
      chinguUsageCount: chinguUsageCount ?? this.chinguUsageCount,
      rewardStack: rewardStack ?? this.rewardStack,
      mealCouponCount: mealCouponCount ?? this.mealCouponCount,
      helpedYouthCount: helpedYouthCount ?? this.helpedYouthCount,
      reviewCount: reviewCount ?? this.reviewCount,
      studentOrigin: studentOrigin,
      stayStart: stayStart,
      stayEnd: stayEnd,
    );
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: UserRole.fromValue(data['role'] as String? ?? 'student'),
      name: data['name'] as String? ?? '',
      birthDate: (data['birthDate'] as Timestamp?)?.toDate() ?? DateTime(2000),
      rrnLastDigit: data['rrnLastDigit'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      address: data['address'] as String?,
      schoolInfo: data['schoolInfo'] as String?,
      businessRegistrationNumber: data['businessRegistrationNumber'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      streakCount: data['streakCount'] as int? ?? 0,
      lastOrderDate: (data['lastOrderDate'] as Timestamp?)?.toDate(),
      freeMealCount: data['freeMealCount'] as int? ?? 0,
      penaltyPoints: data['penaltyPoints'] as int? ?? 0,
      suspendedUntil: (data['suspendedUntil'] as Timestamp?)?.toDate(),
      purchaseDayCount: data['purchaseDayCount'] as int? ?? 0,
      totalUsageCount: data['totalUsageCount'] as int? ?? 0,
      vendingUsageCount: data['vendingUsageCount'] as int? ?? 0,
      chinguUsageCount: data['chinguUsageCount'] as int? ?? 0,
      rewardStack: data['rewardStack'] as int? ?? 0,
      mealCouponCount: data['mealCouponCount'] as int? ?? data['freeMealCount'] as int? ?? 0,
      helpedYouthCount: data['helpedYouthCount'] as int? ?? 0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      studentOrigin: data['studentOrigin'] == null
          ? null
          : StudentOrigin.fromValue(data['studentOrigin'] as String?),
      stayStart: (data['stayStart'] as Timestamp?)?.toDate(),
      stayEnd: (data['stayEnd'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'role': role.value,
      'name': name,
      'birthDate': Timestamp.fromDate(birthDate),
      'rrnLastDigit': rrnLastDigit,
      'phone': phone,
      if (address != null && address!.isNotEmpty) 'address': address,
      if (schoolInfo != null && schoolInfo!.isNotEmpty) 'schoolInfo': schoolInfo,
      if (businessRegistrationNumber != null && businessRegistrationNumber!.isNotEmpty)
        'businessRegistrationNumber': businessRegistrationNumber,
      'createdAt': FieldValue.serverTimestamp(),
      'streakCount': streakCount,
      if (lastOrderDate != null) 'lastOrderDate': Timestamp.fromDate(lastOrderDate!),
      'freeMealCount': freeMealCount,
      'penaltyPoints': penaltyPoints,
      if (suspendedUntil != null) 'suspendedUntil': Timestamp.fromDate(suspendedUntil!),
      'purchaseDayCount': purchaseDayCount,
      'totalUsageCount': totalUsageCount,
      'vendingUsageCount': vendingUsageCount,
      'chinguUsageCount': chinguUsageCount,
      'rewardStack': rewardStack,
      'mealCouponCount': mealCouponCount,
      'helpedYouthCount': helpedYouthCount,
      'reviewCount': reviewCount,
      if (studentOrigin != null) 'studentOrigin': studentOrigin!.value,
      if (stayStart != null) 'stayStart': Timestamp.fromDate(stayStart!),
      if (stayEnd != null) 'stayEnd': Timestamp.fromDate(stayEnd!),
    };
  }
}
