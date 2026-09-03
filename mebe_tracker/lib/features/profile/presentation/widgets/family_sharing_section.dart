import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/models/family_member.dart';
import '../../../../shared/providers/auth_provider.dart';
import '../../../../shared/providers/family_sharing_provider.dart';
import '../../../../shared/services/family_sharing_service.dart';
import '../../../subscription/presentation/premium_gate.dart';

class FamilySharingSection extends ConsumerWidget {
  const FamilySharingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myInvite = ref.watch(myPendingInviteProvider).value;

    return PremiumGate(
      feature: 'family_sharing',
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Chia sẻ gia đình', style: AppTextStyles.headingMd)),
                TextButton.icon(
                  onPressed: () => _showInviteDialog(context, ref),
                  icon: const Icon(Icons.person_add_alt, size: 16),
                  label: const Text('Mời thành viên'),
                ),
              ],
            ),
            if (myInvite != null) ...[
              const SizedBox(height: AppSpacing.sm),
              _InviteBanner(invite: myInvite),
              const SizedBox(height: AppSpacing.sm),
            ],
            Consumer(
              builder: (context, ref, _) {
                final members = ref.watch(familyMembersProvider).value ?? const <FamilyMember>[];
                if (members.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Text('Chưa có thành viên nào được mời', style: AppTextStyles.bodySm),
                  );
                }
                return Column(
                  children: members.map((member) => _MemberRow(member: member)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mời thành viên gia đình'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Email thành viên'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Hủy')),
          TextButton(
            onPressed: () async {
              final email = controller.text.trim();
              if (email.isEmpty) return;
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              await ref.read(familySharingServiceProvider).inviteByEmail(
                    user.uid,
                    email,
                    inviterName: user.displayName ?? user.email,
                  );
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Gửi lời mời'),
          ),
        ],
      ),
    );
  }
}

class _InviteBanner extends ConsumerStatefulWidget {
  const _InviteBanner({required this.invite});

  final PendingInvite invite;

  @override
  ConsumerState<_InviteBanner> createState() => _InviteBannerState();
}

class _InviteBannerState extends ConsumerState<_InviteBanner> {
  bool _busy = false;

  Future<void> _respond(bool accept) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _busy = true);
    try {
      final service = ref.read(familySharingServiceProvider);
      if (accept) {
        await service.acceptInvite(inviteeUid: user.uid, inviteeEmail: widget.invite.email, invite: widget.invite);
      } else {
        await service.declineInvite(widget.invite.email);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(accept ? 'Đã tham gia gia đình 🎉' : 'Đã từ chối lời mời')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Có lỗi xảy ra. Thử lại nhé 🐰')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.powder,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.blush),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.invite.inviterName} mời bạn tham gia theo dõi cùng gia đình',
            style: AppTextStyles.bodyMd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy ? null : () => _respond(false),
                  child: const Text('Từ chối'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: _busy ? null : () => _respond(true),
                  child: _busy
                      ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Chấp nhận'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends ConsumerWidget {
  const _MemberRow({required this.member});

  final FamilyMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.blush,
            child: Text(member.email[0].toUpperCase(), style: AppTextStyles.bodyMd),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(member.email, style: AppTextStyles.bodyMd),
                Text(
                  member.status == FamilyMemberStatus.accepted ? 'Đã tham gia' : 'Đang chờ chấp nhận',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
            tooltip: 'Xóa thành viên',
            onPressed: () {
              final user = ref.read(currentUserProvider);
              if (user == null) return;
              ref.read(familySharingServiceProvider).revoke(user.uid, member.id, memberEmail: member.email);
            },
          ),
        ],
      ),
    );
  }
}
