import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../../../shared/models/story_card.dart';
import '../data/story_card_provider.dart';
import 'widgets/story_card_widget.dart';

const _gradientMemory = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF85B3), Color(0xFFF472A0), Color(0xFFA67CD8)],
  stops: [0.0, 0.55, 1.0],
);

class StoryCardsScreen extends ConsumerWidget {
  const StoryCardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(storyCardsProvider).value ?? [];
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientMemory,
              earLeftColor: AppColors.petal,
              earRightColor: AppColors.lilac,
              title: 'Thẻ kỷ niệm 📖',
              subtitle: '${cards.length} kỷ niệm đẹp',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          if (cards.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('📖', style: TextStyle(fontSize: 56)),
                    SizedBox(height: AppSpacing.md),
                    Text(
                      'Chưa có thẻ kỷ niệm',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.body,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Nhấn + để tạo thẻ đầu tiên',
                      style: TextStyle(color: AppColors.muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) {
                    final card = cards[i];
                    return _CardGridItem(card: card, isPremium: isPremium);
                  },
                  childCount: cards.length,
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: isPremium
            ? () => _showCreateDialog(context, ref)
            : () => context.push('/home/subscription'),
        backgroundColor: AppColors.blossom,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: Text(isPremium ? 'Tạo thẻ' : 'Premium ✨'),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context, WidgetRef ref) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateCardSheet(ref: ref),
    );
  }
}

class _CardGridItem extends ConsumerWidget {
  const _CardGridItem({required this.card, required this.isPremium});

  final StoryCard card;
  final bool isPremium;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repaintKey = GlobalKey();
    return RepaintBoundary(
      key: repaintKey,
      child: StoryCardWidget(
        card: card,
        compact: true,
        onTap: () => _showDetail(context, ref, card, repaintKey, isPremium),
        onShare: isPremium ? () => _shareCard(context, repaintKey) : null,
      ),
    );
  }

  Future<void> _showDetail(
    BuildContext context,
    WidgetRef ref,
    StoryCard card,
    GlobalKey repaintKey,
    bool isPremium,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CardDetailSheet(
        card: card,
        isPremium: isPremium,
        onShare: () => _shareCard(context, repaintKey),
        onDelete: () async {
          final user = ref.read(currentUserProvider);
          final baby = ref.read(activeBabyProvider);
          if (user != null && baby != null) {
            await deleteStoryCard(user.uid, baby.id, card.id);
          }
        },
      ),
    );
  }

  Future<void> _shareCard(BuildContext context, GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final bytes = byteData.buffer.asUint8List();
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'memory_card.png')],
        text: '${card.titleVi} 💕 — ${card.contentVi}\n\nMeBé ✨',
      );
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể chia sẻ thẻ này')),
        );
      }
    }
  }
}

class _CardDetailSheet extends StatelessWidget {
  const _CardDetailSheet({
    required this.card,
    required this.isPremium,
    required this.onShare,
    required this.onDelete,
  });

  final StoryCard card;
  final bool isPremium;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  StoryCardWidget(card: card),
                  const SizedBox(height: AppSpacing.xl),
                  if (isPremium)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        onShare();
                      },
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Chia sẻ kỷ niệm'),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Xoá thẻ?'),
                          content: const Text(
                              'Kỷ niệm này sẽ bị xoá vĩnh viễn.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Huỷ'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Xoá',
                                  style: TextStyle(color: AppColors.error)),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && context.mounted) {
                        onDelete();
                        Navigator.pop(context);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xoá thẻ'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCardSheet extends ConsumerStatefulWidget {
  const _CreateCardSheet({required this.ref});

  final WidgetRef ref;

  @override
  ConsumerState<_CreateCardSheet> createState() => _CreateCardSheetState();
}

class _CreateCardSheetState extends ConsumerState<_CreateCardSheet> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  String _theme = 'blossom';
  bool _saving = false;

  static const _themeOptions = [
    ('blossom', '🌸 Hồng'),
    ('lavender', '💜 Tím'),
    ('mint', '🌿 Xanh'),
    ('gold', '⭐ Vàng'),
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (title.isEmpty || content.isEmpty) return;

    setState(() => _saving = true);
    final user = ref.read(currentUserProvider);
    final baby = ref.read(activeBabyProvider);
    if (user == null || baby == null) {
      setState(() => _saving = false);
      return;
    }
    final now = DateTime.now();
    final card = StoryCard(
      id: const Uuid().v4(),
      babyId: baby.id,
      userId: user.uid,
      type: 'custom',
      titleVi: title,
      contentVi: content,
      theme: _theme,
      cardDate: now,
      createdAt: now,
    );
    await saveStoryCard(user.uid, baby.id, card);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tạo thẻ kỷ niệm',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Tiêu đề',
                hintText: 'VD: Lần đầu cười toe toét 😊',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _contentCtrl,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Nội dung',
                hintText: 'Kể lại khoảnh khắc này...',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Màu sắc',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.body,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: _themeOptions.map((opt) {
                final selected = _theme == opt.$1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _theme = opt.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.blossom.withValues(alpha: 0.1)
                            : Colors.transparent,
                        border: Border.all(
                          color: selected
                              ? AppColors.blossom
                              : AppColors.divider,
                          width: selected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        opt.$2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.blossom : AppColors.body,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Lưu kỷ niệm 💕'),
            ),
          ],
        ),
      ),
    );
  }
}
