import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../data/chat_provider.dart';
import '../data/chat_service.dart';
import '../domain/models/chat_models.dart';

class ChatHistoryScreen extends ConsumerWidget {
  const ChatHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.uid;
    if (userId == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.powder,
        elevation: 0,
        title: Text('Lịch sử trò chuyện', style: AppTextStyles.headingMd),
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: ref.read(chatServiceProvider).watchConversations(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.blossom));
          }
          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💬', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: AppSpacing.md),
                  Text('Chưa có cuộc trò chuyện nào', style: AppTextStyles.bodyMd),
                ],
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: conversations.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final conv = conversations[index];
              return _ConversationTile(
                conversation: conv,
                onTap: () {
                  ref.read(chatProvider.notifier).loadConversation(conv.id);
                  context.pop();
                },
                onDelete: () async {
                  try {
                    await ref.read(chatServiceProvider).deleteConversation(conv.id);
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Không thể xoá cuộc trò chuyện')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({
    required this.conversation,
    required this.onTap,
    required this.onDelete,
  });

  final ChatConversation conversation;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(conversation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.blossom.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: AppColors.blush,
                child: Text('🐰', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.lastMessage ?? 'Cuộc trò chuyện mới',
                      style: AppTextStyles.headingSm,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (conversation.lastReply != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        conversation.lastReply!,
                        style: AppTextStyles.bodySm,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeago.format(conversation.updatedAt, locale: 'en_short'),
                    style: AppTextStyles.bodySm,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.blush,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      '${conversation.messageCount ~/ 2} tin',
                      style: AppTextStyles.label.copyWith(color: AppColors.blossom),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
