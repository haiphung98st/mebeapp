import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/chat_provider.dart';
import '../domain/models/chat_models.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({
    super.key,
    this.prefilledMessage,
    this.conversationId,
  });

  final String? prefilledMessage;
  final String? conversationId;

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.conversationId != null) {
        ref.read(chatProvider.notifier).loadConversation(widget.conversationId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.powder,
        elevation: 0,
        title: Row(
          children: [
            const Text('🐰', style: TextStyle(fontSize: 20)),
            const SizedBox(width: AppSpacing.xs),
            Text('Hỏi bé', style: AppTextStyles.headingMd),
          ],
        ),
        actions: [
          if (isPremium)
            IconButton(
              icon: const Icon(Icons.history_rounded, color: AppColors.blossom),
              onPressed: () => context.push('/ai-chat/history'),
              tooltip: 'Lịch sử',
            ),
          if (isPremium)
            IconButton(
              icon: const Icon(Icons.add_comment_outlined, color: AppColors.blossom),
              onPressed: () => ref.read(chatProvider.notifier).startNewConversation(),
              tooltip: 'Cuộc trò chuyện mới',
            ),
        ],
      ),
      body: isPremium
          ? _ChatContent(prefilledMessage: widget.prefilledMessage)
          : const AiChatPaywall(),
    );
  }
}

// ── PAYWALL ───────────────────────────────────────────────────────────────────

class AiChatPaywall extends StatelessWidget {
  const AiChatPaywall({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              gradient: AppColors.gradientHome,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              children: [
                const Text('🐰', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Hỏi bé – Trợ lý AI của mẹ',
                  style: AppTextStyles.headingLg.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Đặt câu hỏi về chăm sóc bé và nhận câu trả lời tức thì',
                  style: AppTextStyles.bodyMd.copyWith(color: AppColors.white.withValues(alpha: 0.9)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _PreviewChatList(),
          const SizedBox(height: AppSpacing.xl),
          _FeatureList(),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => context.push('/home/subscription'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blossom,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              child: Text('Dùng thử Premium 7 ngày miễn phí', style: AppTextStyles.headingSm.copyWith(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewChatList extends StatelessWidget {
  final _fakeItems = const [
    ('user', 'Bé 3 tháng ngủ bao nhiêu tiếng mỗi ngày là đủ?'),
    ('assistant', 'Bé 3 tháng thường ngủ **14-17 tiếng** mỗi ngày 🌙\n\nMỗi giấc ban ngày kéo dài 1-2 tiếng, ban đêm bé có thể ngủ 4-6 tiếng liên tục rồi...'),
    ('user', 'Dấu hiệu bé đói là gì?'),
  ];

  const _PreviewChatList();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.transparent],
        stops: [0.4, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: IgnorePointer(
        child: Column(
          children: _fakeItems
              .map((item) => _PreviewChatItem(role: item.$1, content: item.$2))
              .toList(),
        ),
      ),
    );
  }
}

class _PreviewChatItem extends StatelessWidget {
  const _PreviewChatItem({required this.role, required this.content});

  final String role;
  final String content;

  @override
  Widget build(BuildContext context) {
    final isUser = role == 'user';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 14,
              backgroundColor: AppColors.blossom,
              child: Text('🐰', style: TextStyle(fontSize: 14)),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.blossom : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
              ),
              child: Text(
                content,
                style: AppTextStyles.bodyMd.copyWith(
                  color: isUser ? AppColors.white : AppColors.body,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _FeatureList extends StatelessWidget {
  const _FeatureList();

  @override
  Widget build(BuildContext context) {
    const features = [
      ('🤱', 'Tư vấn cho bú mẹ & sữa công thức'),
      ('🌙', 'Gợi ý lịch ngủ theo tuổi bé'),
      ('📊', 'Phân tích dữ liệu theo dõi của bé'),
      ('💉', 'Hỗ trợ lịch tiêm chủng'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tính năng Premium', style: AppTextStyles.headingMd),
        const SizedBox(height: AppSpacing.md),
        ...features.map((f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Text(f.$1, style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(f.$2, style: AppTextStyles.bodyMd)),
                ],
              ),
            )),
      ],
    );
  }
}

// ── CHAT CONTENT ──────────────────────────────────────────────────────────────

class _ChatContent extends ConsumerStatefulWidget {
  const _ChatContent({this.prefilledMessage});

  final String? prefilledMessage;

  @override
  ConsumerState<_ChatContent> createState() => _ChatContentState();
}

class _ChatContentState extends ConsumerState<_ChatContent> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.prefilledMessage != null) {
      _controller.text = widget.prefilledMessage!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    await ref.read(chatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);

    ref.listen<ChatState>(chatProvider, (_, next) {
      if (next.isStreaming || next.messages.isNotEmpty) _scrollToBottom();
    });

    return Column(
      children: [
        Expanded(
          child: chat.messages.isEmpty && !chat.isLoading && !chat.isStreaming
              ? _EmptyState(
                  onQuestion: (q) {
                    _controller.text = q;
                    _send();
                  },
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  itemCount: chat.messages.length +
                      (chat.isLoading ? 1 : 0) +
                      (chat.isStreaming ? 1 : 0) +
                      (chat.errorMessage != null ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < chat.messages.length) {
                      final msg = chat.messages[index];
                      return msg.role == 'user'
                          ? _UserBubble(message: msg)
                          : _AiBubble(content: msg.content, isStreaming: false);
                    }
                    if (chat.isLoading && index == chat.messages.length) {
                      return const _TypingIndicator();
                    }
                    if (chat.isStreaming) {
                      return _AiBubble(content: chat.streamingText, isStreaming: true);
                    }
                    if (chat.errorMessage != null) {
                      return _ErrorBubble(
                        code: chat.errorMessage!,
                        onDismiss: () => ref.read(chatProvider.notifier).clearError(),
                        onSubscribe: () => context.push('/home/subscription'),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
        ),
        _InputBar(
          controller: _controller,
          isLoading: chat.isLoading || chat.isStreaming,
          onSend: _send,
        ),
      ],
    );
  }
}

// ── BUBBLES ───────────────────────────────────────────────────────────────────

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: const BoxDecoration(
                color: AppColors.blossom,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(4),
                ),
              ),
              child: Text(
                message.content,
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBubble extends StatelessWidget {
  const _AiBubble({required this.content, required this.isStreaming});

  final String content;
  final bool isStreaming;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.blossom,
            child: Text('🐰', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blossom.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: content.isEmpty
                  ? const _TypingDots()
                  : Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Flexible(
                          child: MarkdownBody(
                            data: content,
                            styleSheet: MarkdownStyleSheet(
                              p: AppTextStyles.bodyMd,
                              strong: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                              listBullet: AppTextStyles.bodyMd,
                            ),
                          ),
                        ),
                        if (isStreaming) ...[
                          const SizedBox(width: 2),
                          const _BlinkingCursor(),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlinkingCursor extends StatefulWidget {
  const _BlinkingCursor();

  @override
  State<_BlinkingCursor> createState() => _BlinkingCursorState();
}

class _BlinkingCursorState extends State<_BlinkingCursor>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _controller.value,
        child: Text('|',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.blossom,
              fontWeight: FontWeight.w900,
            )),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.blossom,
            child: Text('🐰', style: TextStyle(fontSize: 14)),
          ),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const _TypingDots(),
          ),
        ],
      ),
    );
  }
}

class _TypingDots extends StatefulWidget {
  const _TypingDots();

  @override
  State<_TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<_TypingDots> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i * 0.33;
            final phase = (_controller.value - delay).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase * 2 : (1 - phase) * 2).clamp(0.3, 1.0);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: Opacity(
                opacity: opacity,
                child: const CircleAvatar(
                  radius: 4,
                  backgroundColor: AppColors.blossom,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ErrorBubble extends StatelessWidget {
  const _ErrorBubble({
    required this.code,
    required this.onDismiss,
    required this.onSubscribe,
  });

  final String code;
  final VoidCallback onDismiss;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    final isPremiumError = code == 'PREMIUM_REQUIRED';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                isPremiumError
                    ? 'Tính năng này chỉ dành cho Premium 🌸'
                    : 'Có lỗi xảy ra, vui lòng thử lại',
                style: AppTextStyles.bodyMd.copyWith(color: AppColors.error),
              ),
            ),
            if (isPremiumError)
              TextButton(
                onPressed: onSubscribe,
                child: Text('Nâng cấp', style: AppTextStyles.headingSm.copyWith(color: AppColors.blossom)),
              )
            else
              IconButton(
                icon: const Icon(Icons.close, size: 18, color: AppColors.muted),
                onPressed: onDismiss,
              ),
          ],
        ),
      ),
    );
  }
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onQuestion});

  final void Function(String) onQuestion;

  @override
  Widget build(BuildContext context) {
    const suggestions = [
      '🤱 Bé bú bao nhiêu lần mỗi ngày?',
      '🌙 Lịch ngủ cho bé 3 tháng?',
      '💉 Bé cần tiêm vắc xin gì tiếp theo?',
      '⚖️ Cân nặng bé như vậy có bình thường không?',
    ];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          const Text('🐰', style: TextStyle(fontSize: 64)),
          const SizedBox(height: AppSpacing.md),
          Text('Hỏi bé gì hôm nay?', style: AppTextStyles.displaySm),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Mình có thể giúp mẹ về chăm sóc, dinh dưỡng, và phát triển của bé',
            style: AppTextStyles.bodyMd,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            alignment: WrapAlignment.center,
            children: suggestions
                .map((s) => InkWell(
                      onTap: () => onQuestion(s),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.divider),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(s, style: AppTextStyles.bodyMd),
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── INPUT BAR ─────────────────────────────────────────────────────────────────

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.isLoading,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool isLoading;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blossom.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: 'Hỏi mình điều gì nhé mẹ ơi...',
                  hintStyle: AppTextStyles.bodyMd.copyWith(color: AppColors.muted),
                  filled: true,
                  fillColor: AppColors.powder,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
                textInputAction: TextInputAction.newline,
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            GestureDetector(
              onTap: isLoading ? null : onSend,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLoading ? AppColors.muted : AppColors.blossom,
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: AppColors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
