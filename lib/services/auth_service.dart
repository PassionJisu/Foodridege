import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/user_role.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentAppUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return getUserProfile(user.uid);
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  Future<AppUser> signUp({
    required String email,
    required String password,
    required UserRole role,
    required String name,
    required DateTime birthDate,
    required String rrnLastDigit,
    required String phone,
    String? address,
    String? schoolInfo,
    String? businessRegistrationNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;
    final appUser = AppUser(
      uid: uid,
      email: email.trim(),
      role: role,
      name: name.trim(),
      birthDate: birthDate,
      rrnLastDigit: rrnLastDigit,
      phone: phone.trim(),
      address: address?.trim(),
      schoolInfo: schoolInfo?.trim(),
      businessRegistrationNumber: businessRegistrationNumber?.trim(),
    );

    await _firestore.collection('users').doc(uid).set(appUser.toFirestore());
    return appUser;
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final profile = await getUserProfile(credential.user!.uid);
    if (profile == null) {
      throw FirebaseAuthException(
        code: 'profile-not-found',
        message: '사용자 프로필을 찾을 수 없습니다. 회원가입을 먼저 진행해 주세요.',
      );
    }
    return profile;
  }

  Future<void> signOut() => _auth.signOut();
}
