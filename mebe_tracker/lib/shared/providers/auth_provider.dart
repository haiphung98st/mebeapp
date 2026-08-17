import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../core/config/app_secrets.dart';

// ── Admin role ────────────────────────────────────────────────────────────────

enum AdminRole {
  user,
  support,
  admin,
  superadmin;

  int get level => index;

  static AdminRole fromClaim(String? role) {
    switch (role) {
      case 'superadmin':
        return AdminRole.superadmin;
      case 'admin':
        return AdminRole.admin;
      case 'support':
        return AdminRole.support;
      default:
        return AdminRole.user;
    }
  }

  String get displayName {
    switch (this) {
      case AdminRole.superadmin:
        return 'Superadmin';
      case AdminRole.admin:
        return 'Admin';
      case AdminRole.support:
        return 'Support';
      case AdminRole.user:
        return 'User';
    }
  }
}

final adminRoleProvider = FutureProvider<AdminRole>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return AdminRole.user;
  final result = await user.getIdTokenResult(true);
  final role = result.claims?['role'] as String?;
  return AdminRole.fromClaim(role);
});

final isAdminUserProvider = Provider<bool>((ref) {
  final roleAsync = ref.watch(adminRoleProvider);
  final role = roleAsync.value;
  return role != null && role.level >= AdminRole.support.level;
});

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.userChanges();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authStateProvider).value;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthRepository {
  AuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ??
            GoogleSignIn(clientId: kIsWeb ? AppSecrets.webGoogleClientId : null);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.isNotEmpty) {
      await credential.user?.updateDisplayName(displayName);
    }
    return credential;
  }

  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign-in-cancelled',
        message: 'Đăng nhập Google đã bị huỷ.',
      );
    }
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) return;
    final credential = EmailAuthProvider.credential(email: email, password: currentPassword);
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
