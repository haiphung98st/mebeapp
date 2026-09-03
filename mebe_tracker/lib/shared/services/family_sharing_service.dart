import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/family_member.dart';

/// A pending invite waiting at `pendingInvites/{emailLowercased}` for
/// whoever signs in with that email to accept or decline.
class PendingInvite {
  const PendingInvite({required this.email, required this.inviterUserId, required this.inviterName, required this.role});

  final String email;
  final String inviterUserId;
  final String inviterName;
  final String role;

  factory PendingInvite.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return PendingInvite(
      email: doc.id,
      inviterUserId: data['inviterUserId'] as String,
      inviterName: data['inviterName'] as String? ?? 'Gia đình',
      role: data['role'] as String? ?? 'viewer',
    );
  }
}

String _normalizeEmail(String email) => email.trim().toLowerCase();

/// Manages family member invites.
///
/// Two collections are involved because a client can never look up a
/// Firebase Auth UID from an email address before that person has signed
/// in — so the invite is first parked at `pendingInvites/{email}` (readable
/// by whoever's auth token has that email) and only turns into a real
/// `users/{inviterId}/familyMembers/{inviteeUid}` grant once the invitee
/// opens the app and accepts it. See firestore.rules for the matching
/// security rules this flow depends on.
class FamilySharingService {
  FamilySharingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _members(String userId) =>
      _firestore.collection('users').doc(userId).collection('familyMembers');

  DocumentReference<Map<String, dynamic>> _pendingInvite(String email) =>
      _firestore.collection('pendingInvites').doc(_normalizeEmail(email));

  Future<void> inviteByEmail(String userId, String email, {String? inviterName}) async {
    final normalized = _normalizeEmail(email);
    final member = FamilyMember(
      id: '',
      email: normalized,
      role: 'viewer',
      status: FamilyMemberStatus.pending,
      invitedAt: DateTime.now(),
    );
    await _members(userId).add(member.toFirestore());
    await _pendingInvite(normalized).set({
      'inviterUserId': userId,
      'inviterName': inviterName ?? 'Gia đình',
      'role': 'viewer',
      'invitedAt': Timestamp.now(),
    });
  }

  Future<void> revoke(String userId, String memberId, {String? memberEmail}) async {
    await _members(userId).doc(memberId).delete();
    if (memberEmail != null) {
      await _pendingInvite(memberEmail).delete().catchError((_) {});
    }
  }

  Stream<List<FamilyMember>> watchMembers(String userId) => _members(userId)
      .orderBy('invitedAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map(FamilyMember.fromFirestore).toList());

  /// The invite waiting for [email], if any — null once accepted/declined.
  Stream<PendingInvite?> watchMyInvite(String email) => _pendingInvite(email)
      .snapshots()
      .map((doc) => doc.exists ? PendingInvite.fromFirestore(doc) : null);

  Future<void> acceptInvite({
    required String inviteeUid,
    required String inviteeEmail,
    required PendingInvite invite,
  }) async {
    await _members(invite.inviterUserId).doc(inviteeUid).set(
      FamilyMember(
        id: inviteeUid,
        email: _normalizeEmail(inviteeEmail),
        role: invite.role,
        status: FamilyMemberStatus.accepted,
        invitedAt: DateTime.now(),
      ).toFirestore(),
    );
    await _pendingInvite(inviteeEmail).delete();
  }

  Future<void> declineInvite(String email) => _pendingInvite(email).delete();
}
