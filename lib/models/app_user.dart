import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_role.dart';

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

  bool get isSuspended {
    if (suspendedUntil == null) return false;
    return suspendedUntil!.isAfter(DateTime.now());
  }

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AppUser(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      role: UserRole.fromValue(data['role'] as String? ?? 'youth'),
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
    };
  }
}
