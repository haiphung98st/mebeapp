import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/family_member.dart';
import '../services/family_sharing_service.dart';
import 'auth_provider.dart';

final familySharingServiceProvider = Provider<FamilySharingService>((ref) {
  return FamilySharingService();
});

final familyMembersProvider = StreamProvider<List<FamilyMember>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value(const []);
  return ref.watch(familySharingServiceProvider).watchMembers(user.uid);
});

/// The invite waiting for the signed-in user's own email, if any.
final myPendingInviteProvider = StreamProvider<PendingInvite?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null || user.email == null) return Stream.value(null);
  return ref.watch(familySharingServiceProvider).watchMyInvite(user.email!);
});
