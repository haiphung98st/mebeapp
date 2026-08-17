import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/bunny_header.dart';
import '../../../shared/models/time_capsule.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/time_capsule_provider.dart';

const _gradientCapsule = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFFF85B3), Color(0xFFF472A0)],
);

class TimeCapsuleScreen extends ConsumerWidget {
  const TimeCapsuleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final capsules = ref.watch(timeCapsulesProvider).value ?? [];
    final isPremium = ref.watch(isPremiumProvider);
    final unlocked = capsules.where((c) => c.isUnlocked && !c.isOpened).toList();
    final locked = capsules.where((c) => !c.isUnlocked).toList();
    final opened = capsules.where((c) => c.isOpened).toList();

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: BunnyHeader(
              gradient: _gradientCapsule,
              earLeftColor: AppColors.petal,
              earRightColor: AppColors.lilac,
              title: 'Hộp thời gian 🎁',
              subtitle: '${capsules.length} hộp',
              actions: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
            ),
          ),

          if (!isPremium)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: _PremiumGate(
                  onUpgrade: () => context.push('/home/subscription'),
                ),
              ),
            )
          else ...[
            if (unlocked.isNotEmpty) ...[
              _SectionHeader(title: '🔓 Sẵn sàng mở (${unlocked.length})'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _CapsuleTile(
                    capsule: unlocked[i],
                    isUnlocked: true,
                    onOpen: () => _openCapsule(context, ref, unlocked[i]),
                  ),
                  childCount: unlocked.length,
                ),
              ),
            ],
            if (locked.isNotEmpty) ...[
              _SectionHeader(title: '🔒 Đang khoá (${locked.length})'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _CapsuleTile(
                    capsule: locked[i],
                    isUnlocked: false,
                  ),
                  childCount: locked.length,
                ),
              ),
            ],
            if (opened.isNotEmpty) ...[
              _SectionHeader(title: '📦 Đã mở (${opened.length})'),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _CapsuleTile(
                    capsule: opened[i],
                    isUnlocked: true,
                    isOpened: true,
                  ),
                  childCount: opened.length,
                ),
              ),
            ],
            if (capsules.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🎁', style: TextStyle(fontSize: 56)),
                      SizedBox(height: AppSpacing.md),
                      Text(
                        'Chưa có hộp thời gian',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: isPremium
          ? FloatingActionButton.extended(
              onPressed: () => context.push('/memory/time-capsule/create'),
              backgroundColor: AppColors.blossom,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Tạo hộp'),
            )
          : null,
    );
  }

  Future<void> _openCapsule(
    BuildContext context,
    WidgetRef ref,
    TimeCapsule capsule,
  ) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CapsuleOpenSheet(capsule: capsule, ref: ref),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.sm,
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.body,
          ),
        ),
      ),
    );
  }
}

class _CapsuleTile extends StatelessWidget {
  const _CapsuleTile({
    required this.capsule,
    required this.isUnlocked,
    this.isOpened = false,
    this.onOpen,
  });

  final TimeCapsule capsule;
  final bool isUnlocked;
  final bool isOpened;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: 4,
      ),
      child: GestureDetector(
        onTap: isUnlocked && !isOpened ? onOpen : null,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.blossom.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Progress ring
              SizedBox(
                width: 52,
                height: 52,
                child: CustomPaint(
                  painter: _ProgressRingPainter(
                    progress: capsule.progressFraction,
                    color: isOpened
                        ? AppColors.mint
                        : isUnlocked
                            ? AppColors.success
                            : AppColors.blossom,
                  ),
                  child: Center(
                    child: Text(
                      isOpened ? '📦' : isUnlocked ? '🎁' : '🔒',
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capsule.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      capsule.unlockAgeLabel,
                      style: TextStyle(
                        fontSize: 11,
                        color: isUnlocked ? AppColors.success : AppColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isUnlocked) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Còn ${capsule.timeUntilUnlock.inDays} ngày',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                    Text(
                      '${capsule.items.length} kỷ niệm',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (isUnlocked && !isOpened)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.blossom,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Mở',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 6) / 2;

    final bgPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final fgPaint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter old) =>
      old.progress != progress;
}

class _CapsuleOpenSheet extends ConsumerWidget {
  const _CapsuleOpenSheet({required this.capsule, required this.ref});

  final TimeCapsule capsule;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
                  const Center(
                    child: Text('🎉', style: TextStyle(fontSize: 56)),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    capsule.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ...capsule.items.map((item) => _ItemCard(item: item)),
                  const SizedBox(height: AppSpacing.xl),
                  ElevatedButton(
                    onPressed: () async {
                      final user = widgetRef.read(currentUserProvider);
                      final baby = widgetRef.read(activeBabyProvider);
                      if (user != null && baby != null) {
                        await markCapsuleOpened(
                          user.uid,
                          baby.id,
                          capsule.id,
                        );
                      }
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: const Text('Đóng hộp 📦'),
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

class _ItemCard extends StatelessWidget {
  const _ItemCard({required this.item});

  final CapsuleItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.powder,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.emoji ?? '📝',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.titleVi,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.contentVi,
            style: const TextStyle(fontSize: 13, color: AppColors.body),
          ),
        ],
      ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  const _PremiumGate({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFE4EF), Color(0xFFFFF0F6)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Text('🎁', style: TextStyle(fontSize: 56)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Hộp thời gian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Gửi kỷ niệm đến tương lai. Cần Premium.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.body),
          ),
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: onUpgrade,
            child: const Text('Nâng cấp Premium ✨'),
          ),
        ],
      ),
    );
  }
}
