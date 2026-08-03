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
    };
  }
}
