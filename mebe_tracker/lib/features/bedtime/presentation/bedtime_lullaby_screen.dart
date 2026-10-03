import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class BedtimeLullabyScreen extends StatelessWidget {
  const BedtimeLullabyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5EFFF),
      body: CustomScrollView(
        slivers: [
          // ── Hero header ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD4C4FF), Color(0xFFF5EFFF)],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 60),
                        Text('🌙', style: TextStyle(fontSize: 64)),
                        SizedBox(height: 8),
                        Text('🎵', style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.white
                                  .withValues(alpha: 0.9),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close,
                                size: 18, color: AppColors.body),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color:
                                AppColors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_horiz,
                              size: 18, color: AppColors.body),
                        ),
                      ],
                    ),
                  ),
                ),
                // Title overlay at bottom of hero
                Positioned(
                  left: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  right: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Nhạc ru',
                          style: AppTextStyles.headingLg
                              .copyWith(color: AppColors.nightDeep)),
                      Text('Chọn một giai điệu cho giấc ngủ của bé',
                          style: AppTextStyles.bodyMd
                              .copyWith(color: AppColors.body)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Nhạc ru không lời ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
              child: Text('Nhạc ru không lời',
                  style: AppTextStyles.headingSm
                      .copyWith(color: AppColors.ink)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              _instrumentals.map((l) => _LullabyTile(lullaby: l)).toList(),
            ),
          ),

          // ── Nhạc ru có lời ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
              child: Text('Nhạc ru có lời',
                  style: AppTextStyles.headingSm
                      .copyWith(color: AppColors.ink)),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              _vocal.map((l) => _LullabyTile(lullaby: l)).toList(),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }
}

// ── Static Data ───────────────────────────────────────────────────────────────

class _Lullaby {
  const _Lullaby(this.title, this.duration, this.hasLyrics);
  final String title;
  final String duration;
  final bool hasLyrics;
}

const _instrumentals = [
  _Lullaby('Giấc Mơ Nhỏ', '02:36', false),
  _Lullaby('Đêm Bình Yên', '02:51', false),
  _Lullaby('Gió Đưa Mơ', '03:18', false),
  _Lullaby('Chốn Mộng Mơ', '02:12', false),
];

const _vocal = [
  _Lullaby('Ru Con', '03:45', true),
  _Lullaby('Lời Mẹ Ru', '04:10', true),
  _Lullaby('À Ơi', '02:58', true),
  _Lullaby('Con Chim Vành Khuyên', '03:22', true),
];

// ── Lullaby Tile ──────────────────────────────────────────────────────────────

class _LullabyTile extends StatelessWidget {
  const _LullabyTile({required this.lullaby});
  final _Lullaby lullaby;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.nightDeep.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          // Cover
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              gradient: const LinearGradient(
                colors: [Color(0xFF5B3A8A), Color(0xFF3D1A6E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Text('🎵', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lullaby.title,
                    style:
                        AppTextStyles.bodyMd.copyWith(color: AppColors.ink)),
                const SizedBox(height: 3),
                Text(
                  '${lullaby.hasLyrics ? 'Có lời' : 'Không lời'}  •  ${lullaby.duration}',
                  style: AppTextStyles.bodySm
                      .copyWith(color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Play button
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.lilac,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow,
                color: AppColors.nightDeep, size: 22),
          ),
        ],
      ),
    );
  }
}
