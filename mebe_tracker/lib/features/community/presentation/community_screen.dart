import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../data/community_message.dart';
import '../data/community_provider.dart';

class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    setState(() => _sending = true);
    _ctrl.clear();
    try {
      await ref.read(communityNotifierProvider.notifier).sendMessage(text);
      _scrollToBottom();
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final baby = ref.watch(activeBabyProvider);
    final messagesAsync = ref.watch(communityMessagesProvider);
    final communityKey = ref.watch(communityKeyProvider);
    final memberCountAsync = ref.watch(communityMemberCountProvider);
    final currentUid = ref.watch(currentUserProvider)?.uid;

    // Auto-scroll when new messages arrive
    ref.listen(communityMessagesProvider, (_, __) => _scrollToBottom());

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: Column(
        children: [
          BunnyHeader(
            gradient: const LinearGradient(
              colors: [Color(0xFFF472A0), Color(0xFF9B59B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            earLeftColor: AppColors.blossom,
            earRightColor: AppColors.lavender,
            title: 'Cộng đồng',
            subtitle: baby != null
                ? 'Bé sinh tuần ${_weekLabel(baby.dateOfBirth)}'
                : 'Nhóm theo tuần sinh',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: IconButton(
              icon: const Icon(Icons.bar_chart_rounded, color: Colors.white),
              onPressed: () => context.push('/community/stats'),
              tooltip: 'Thống kê nhóm',
            ),
            child: memberCountAsync.whenOrNull(
              data: (count) => count > 0
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: AppSpacing.sm, bottom: AppSpacing.sm),
                      child: Text(
                        '👶 $count mẹ trong nhóm',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : null,
            ),
          ),

          // Info chip
          if (communityKey != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              color: AppColors.lavender.withOpacity(0.15),
              child: Text(
                '🔒 Nhóm ẩn danh · Chỉ mẹ cùng tuần sinh mới thấy',
                style:
                    AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ),

          // Message list
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Lỗi tải tin nhắn',
                    style: AppTextStyles.bodyMd),
              ),
              data: (messages) {
                if (messages.isEmpty) {
                  return _EmptyState();
                }
                return ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i];
                    final isMe = msg.userId == currentUid;
                    final showName = i == 0 ||
                        messages[i - 1].userId != msg.userId;
                    return _MessageBubble(
                      message: msg,
                      isMe: isMe,
                      showName: showName,
                    );
                  },
                );
              },
            ),
          ),

          // Input bar
          _InputBar(
            controller: _ctrl,
            sending: _sending,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  String _weekLabel(DateTime dob) {
    final week = communityKeyForDate(dob);
    // Format: "week_2024_W23" → "23/2024"
    final parts = week.split('_');
    if (parts.length >= 3) {
      return '${parts[2].replaceAll('W', '')}/${parts[1]}';
    }
    return week;
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('💬', style: TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Chưa có tin nhắn nào',
              style: AppTextStyles.headingSm.copyWith(color: AppColors.ink),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Hãy là người đầu tiên\nchào nhóm nhé! 👋',
              style: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Message bubble ────────────────────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showName,
  });

  final CommunityMessage message;
  final bool isMe;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showName && !isMe) ...[
            Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 2),
              child: Text(
                message.displayName,
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.blossom,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          Row(
            mainAxisAlignment:
                isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                _Avatar(name: message.displayName),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: isMe ? AppColors.blossom : AppColors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        message.text,
                        style: TextStyle(
                          color: isMe ? Colors.white : AppColors.ink,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _timeStr(message.createdAt),
                        style: TextStyle(
                          color:
                              isMe ? Colors.white70 : AppColors.muted,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: AppSpacing.sm),
            ],
          ),
        ],
      ),
    );
  }

  String _timeStr(DateTime t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    // Use last 2 chars of name as initials seed for color
    final code = name.codeUnits.fold(0, (a, b) => a + b) % 6;
    final colors = [
      AppColors.blossom,
      AppColors.mint,
      AppColors.lavender,
      AppColors.peach,
      AppColors.mauve,
      AppColors.info,
    ];
    return CircleAvatar(
      radius: 16,
      backgroundColor: colors[code],
      child: Text(
        name.length > 4 ? name.substring(name.length - 2) : name,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ── Input bar ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.sm,
        bottom: AppSpacing.sm + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.sentences,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: 'Nhắn tin cho nhóm...',
                hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide(color: AppColors.divider),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  borderSide: BorderSide(color: AppColors.blossom),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                isDense: true,
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.blossom,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: sending ? null : onSend,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
