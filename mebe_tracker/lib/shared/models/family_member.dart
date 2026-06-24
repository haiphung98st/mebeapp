import 'package:cloud_firestore/cloud_firestore.dart';

enum FamilyMemberStatus { pending, accepted }

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.email,
    required this.role,
    required this.status,
    required this.invitedAt,
  });

  final String id;
  final String email;
  final String role;
  final FamilyMemberStatus status;
  final DateTime invitedAt;

  factory FamilyMember.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return FamilyMember(
      id: doc.id,
      email: data['email'] as String,
      role: data['role'] as String? ?? 'viewer',
      status: (data['status'] as String?) == 'accepted'
          ? FamilyMemberStatus.accepted
          : FamilyMemberStatus.pending,
      invitedAt: (data['invitedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'email': email,
        'role': role,
        'status': status.name,
        'invitedAt': Timestamp.fromDate(invitedAt),
      };
}
