import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/icons/mebe_icons.dart';
import '../../../core/widgets/error_card.dart';
import '../../../features/admin/data/admin_provider.dart';
import '../../../features/achievement/data/achievement_provider.dart';
import '../../../features/wonder_weeks/data/wonder_weeks_data.dart';
import '../../../features/wonder_weeks/data/wonder_weeks_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/home_provider.dart';
import '../../../shared/providers/night_mode_provider.dart';
import '../../../shared/providers/sleep_provider.dart';
import '../../../shared/providers/smart_notification_provider.dart';
import '../../../shared/providers/stats_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import 'widgets/daily_summary_card.dart';
import 'widgets/feature_group.dart';
import 'widgets/home_header.dart';
import 'widgets/home_skeleton.dart';
import 'widgets/recent_events_list.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _onRefresh(WidgetRef ref) async {
    ref.invalidate(allFeedingsProvider);
    ref.invalidate(allSleepsProvider);
    ref.invalidate(allDiapersProvider);
    ref.invalidate(allPumpsProvider);
    await Future.wait([
      ref.read(allFeedingsProvider.future),
      ref.read(allSleepsProvider.future),
      ref.read(allDiapersProvider.future),
      ref.read(allPumpsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNight = ref.watch(nightModeProvider);
    if (isNight) return const _NightHomeView();

    final baby = ref.watch(activeBabyProvider);
    ref.watch(weeklyReportSchedulerProvider);
    ref.watch(smartNotificationSchedulerProvider);

    final isPremium = ref.watch(isPremiumProvider);
    final feedingsAsync = ref.watch(allFeedingsProvider);
    final sleepsAsync = ref.watch(allSleepsProvider);
    final diapersAsync = ref.watch(allDiapersProvider);
    final pumpsAsync = ref.watch(allPumpsProvider);
    final isLoading = baby != null &&
        (feedingsAsync.isLoading || sleepsAsync.isLoading || diapersAsync.isLoading || pumpsAsync.isLoading) &&
        !feedingsAsync.hasValue;
    final hasError = baby != null &&
        (feedingsAsync.hasError || sleepsAsync.hasError || diapersAsync.hasError || pumpsAsync.hasError);

    final todayFeedings = ref.watch(todayFeedingsProvider);
    final todaySleeps = ref.watch(todaySleepsProvider);
    final todayDiapers = ref.watch(todayDiapersProvider);
    final todayPumps = ref.watch(todayPumpsProvider);
    final recentEvents = ref.watch(recentEventsProvider);

    final sleepHours = todaySleeps.fold<double>(
      0,
      (sum, e) => sum + (e.durationMinutes ?? 0) / 60,
    );
    final pumpMl = todayPumps.fold<double>(
      0,
      (sum, e) => sum + (e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0),
    );

    final appConfig = ref.watch(appConfigProvider).valueOrNull;
    final announcementBanner = appConfig?.announcementBanner ?? '';
    ref.watch(achievementEvaluatorProvider);
    final currentLeap = ref.watch(wonderWeeksCurrentLeapProvider);
    final nextLeap = ref.watch(wonderWeeksNextLeapProvider);
    final currentWwWeek = ref.watch(wonderWeeksCurrentWeekProvider);
    final showWwBanner = currentLeap != null ||
        (nextLeap != null && currentWwWeek >= nextLeap.stormStartWeek - 2);

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(ref),
        child: CustomScrollView(
          slivers: [
            if (announcementBanner.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.sm,
                  ),
                  color: AppColors.warning,
                  child: Text(
                    announcementBanner,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            const SliverToBoxAdapter(child: HomeHeader()),
            if (isLoading)
              const SliverToBoxAdapter(child: HomeSkeleton())
            else if (hasError)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: ErrorCard(onRetry: () => _onRefresh(ref)),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxxl,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (showWwBanner)
                      _WonderWeeksBanner(
                        currentLeap: currentLeap,
                        nextLeap: nextLeap,
                        currentWeek: currentWwWeek,
                        onTap: () => context.push('/home/growth/wonder-weeks'),
                      ),
                    if (showWwBanner) const SizedBox(height: AppSpacing.lg),

                    // ── Sinh hoạt hàng ngày ─────────────────────────────
                    HomeFeatureGroup(
                      icon: '🤱',
                      iconBg: const Color(0xFFFFE8F3),
                      featureIconBg: const Color(0xFFFFF0F7),
                      name: 'Sinh hoạt hàng ngày',
                      description: 'Bú · Ngủ · Tã · Hút sữa',
                      badge: '${todayFeedings.length} cữ hôm nay',
                      initiallyExpanded: true,
                      statsStrip: _DailyStatsStrip(
                        feedCount: todayFeedings.length,
                        sleepHours: sleepHours,
                        diaperCount: todayDiapers.length,
                      ),
                      features: [
                        HomeFeature(
                          icon: '🤱',
                          iconType: MeBeIconType.breastfeed,
                          label: 'Bú mẹ',
                          onTap: () => context.go('/home/feeding'),
                        ),
                        HomeFeature(
                          icon: '🍼',
                          iconType: MeBeIconType.bottle,
                          label: 'Bú bình',
                          onTap: () => context.go('/home/feeding'),
                        ),
                        HomeFeature(
                          icon: '🌙',
                          iconType: MeBeIconType.sleep,
                          label: 'Ngủ',
                          onTap: () => context.go('/home/sleep'),
                        ),
                        HomeFeature(
                          icon: '🌸',
                          iconType: MeBeIconType.diaper,
                          label: 'Thay tã',
                          onTap: () => context.go('/home/diaper'),
                        ),
                        HomeFeature(
                          icon: '🥛',
                          iconType: MeBeIconType.pump,
                          label: 'Hút sữa',
                          onTap: () => context.go('/home/pumping'),
                        ),
                        HomeFeature(
                          icon: '🧊',
                          iconType: MeBeIconType.milkStorage,
                          label: 'Kho sữa',
                          onTap: () => context.go('/home/pumping'),
                        ),
                        HomeFeature(
                          icon: '🥣',
                          iconType: MeBeIconType.solidFood,
                          label: 'Ăn dặm',
                          onTap: () => context.push('/home/solid-food'),
                        ),
                        HomeFeature(
                          icon: '📷',
                          iconType: MeBeIconType.scanMilk,
                          label: 'Quét sữa CT',
                          onTap: () => context.push('/formula-scanner'),
                        ),
                      ],
                    ),

                    // ── Phát triển & Sức khoẻ ───────────────────────────
                    HomeFeatureGroup(
                      icon: '📈',
                      iconBg: const Color(0xFFE4FBF4),
                      featureIconBg: const Color(0xFFEDFDF7),
                      name: 'Phát triển & Sức khoẻ',
                      description: 'Cân nặng · Vaccine · Thuốc',
                      features: [
                        HomeFeature(icon: '⚖️', label: 'Cân nặng', onTap: () => context.go('/home/growth')),
                        HomeFeature(icon: '💉', label: 'Tiêm chủng', onTap: () => context.go('/home/vaccine')),
                        HomeFeature(icon: '🌡️', label: 'Sức khoẻ', onTap: () => context.push('/home/health')),
                        HomeFeature(icon: '🦷', label: 'Mọc răng', onTap: () => context.push('/home/growth/teeth')),
                        HomeFeature(icon: '🏃', label: 'Vận động', onTap: () => context.push('/home/growth/motor')),
                        HomeFeature(icon: '🤰', label: 'Mang thai', onTap: () => context.push('/prenatal')),
                      ],
                    ),

                    // ── Kế hoạch & Lịch ──────────────────────────────────
                    HomeFeatureGroup(
                      icon: '📅',
                      iconBg: const Color(0xFFFFF3E0),
                      featureIconBg: const Color(0xFFFFFBF0),
                      name: 'Kế hoạch & Lịch',
                      description: 'EASY · Wonder Weeks · Thống kê',
                      features: [
                        HomeFeature(icon: '📋', label: 'Lịch EASY', onTap: () => context.push('/easy')),
                        HomeFeature(icon: '🌙', label: 'Wonder Weeks', onTap: () => context.push('/home/growth/wonder-weeks')),
                        HomeFeature(icon: '📊', label: 'Thống kê', onTap: () => context.push('/home/stats')),
                        HomeFeature(icon: '🏅', label: 'Thành tích', onTap: () => context.push('/achievements')),
                        HomeFeature(icon: '😊', label: 'Cảm xúc', onTap: () => context.go('/home/diaper')),
                        HomeFeature(icon: '👥', label: 'Cộng đồng', onTap: () => context.push('/community')),
                        HomeFeature(icon: '🎉', label: 'Year Wrapped', onTap: () => context.push('/wrapped')),
                      ],
                    ),

                    // ── Kỷ niệm (Premium) ────────────────────────────────
                    HomeFeatureGroup(
                      icon: '💝',
                      iconBg: const Color(0xFFF0EAFF),
                      featureIconBg: const Color(0xFFF5F0FF),
                      name: 'Kỷ niệm',
                      description: 'Nhật ký · Thư · Hộp thời gian',
                      isPremium: true,
                      features: [
                        HomeFeature(icon: '✨', label: 'Story Cards', isPremium: !isPremium, onTap: () => context.push('/memory/story-cards')),
                        HomeFeature(icon: '💌', label: 'Thư tương lai', isPremium: !isPremium, onTap: () => context.push('/memory/letters')),
                        HomeFeature(icon: '🎙️', label: 'Voice Journal', isPremium: !isPremium, onTap: () => context.push('/memory/voice-journal')),
                        HomeFeature(icon: '⏳', label: 'Hộp thời gian', isPremium: !isPremium, onTap: () => context.push('/memory/time-capsule')),
                        HomeFeature(icon: '📖', label: 'Baby Book', isPremium: !isPremium, onTap: () => context.push('/memory/baby-book')),
                        HomeFeature(icon: '🌈', label: 'Mood Timeline', isPremium: !isPremium, onTap: () => context.push('/memory/mood-timeline')),
                        HomeFeature(icon: '🗺️', label: 'Milestone Map', isPremium: !isPremium, onTap: () => context.push('/memory/milestone-map')),
                        HomeFeature(icon: '🎵', label: 'Soundscape', isPremium: !isPremium, onTap: () => context.push('/memory/soundscape')),
                      ],
                    ),

                    // ── Mẹ khoẻ ──────────────────────────────────────────
                    HomeFeatureGroup(
                      icon: '🌸',
                      iconBg: const Color(0xFFFFE8F3),
                      featureIconBg: const Color(0xFFFFF0F7),
                      name: 'Mẹ khoẻ',
                      description: 'Mood · Nước · Thuốc bổ',
                      features: [
                        HomeFeature(icon: '😊', label: 'Tâm trạng mẹ', onTap: () => context.push('/home/mom-health')),
                        HomeFeature(icon: '💧', label: 'Uống nước', onTap: () => context.push('/home/mom-health')),
                        HomeFeature(icon: '💊', label: 'Thuốc bổ', onTap: () => context.push('/home/mom-health')),
                        HomeFeature(icon: '😴', label: 'Giấc ngủ mẹ', onTap: () => context.push('/home/mom-health')),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.sm),
                    DailySummaryCard(
                      feedingCount: todayFeedings.length,
                      sleepHours: sleepHours,
                      diaperCount: todayDiapers.length,
                      pumpMl: pumpMl,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    RecentEventsList(events: recentEvents),
                    const SizedBox(height: AppSpacing.lg),
                    OutlinedButton.icon(
                      onPressed: () => context.push('/home/stats'),
                      icon: const Icon(Icons.bar_chart, color: AppColors.blossom),
                      label: const Text('Xem thống kê & AI insights'),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }

}

// ── Night Home View ───────────────────────────────────────────────────────────

class _NightHomeView extends ConsumerWidget {
  const _NightHomeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nextFeedingTime = ref.watch(nextFeedingTimeProvider);
    final sleepState = ref.watch(activeSleepProvider);

    String? nextStr;
    if (nextFeedingTime != null) {
      final h = nextFeedingTime.hour.toString().padLeft(2, '0');
      final m = nextFeedingTime.minute.toString().padLeft(2, '0');
      nextStr = '$h:$m';
    }

    String elapsedStr = '';
    if (sleepState.isActive) {
      final s = sleepState.elapsedSeconds;
      final hh = (s ~/ 3600).toString().padLeft(2, '0');
      final mm = ((s % 3600) ~/ 60).toString().padLeft(2, '0');
      elapsedStr = '$hh:$mm';
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D0A1A),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  const Text('🌙', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text('Chế độ ban đêm',
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => ref
                        .read(nightModeOverrideProvider.notifier)
                        .forceDisable(),
                    child: const Text('Tắt',
                        style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cữ tiếp theo',
                  style: TextStyle(
                      color: Colors.white38,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  nextStr ?? '--:--',
                  style: const TextStyle(
                    color: Color(0xFFFFB7CE),
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -4,
                  ),
                ),
              ],
            ),
            if (sleepState.isActive) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 20, vertical: 12),
                margin: const EdgeInsets.symmetric(horizontal: 32),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1228),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFF2D1A5C)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('🌙',
                        style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bé đang ngủ',
                            style: TextStyle(
                                color: Colors.white60, fontSize: 12)),
                        Text(
                          elapsedStr,
                          style: const TextStyle(
                            color: Color(0xFFC9A8F5),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Row(
                children: [
                  _NightButton('🤱', 'Ghi bú',
                      onTap: () => context.push('/home/feeding')),
                  const SizedBox(width: 12),
                  _NightButton('🌸', 'Ghi tã',
                      onTap: () => context.push('/home/diaper')),
                  const SizedBox(width: 12),
                  _NightButton(
                    '⏹',
                    'Dừng ngủ',
                    onTap: () =>
                        ref.read(activeSleepProvider.notifier).reset(),
                    enabled: sleepState.isActive,
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

class _NightButton extends StatelessWidget {
  const _NightButton(this.icon, this.label,
      {required this.onTap, this.enabled = true});

  final String icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: enabled
                ? const Color(0xFF1A1228)
                : const Color(0xFF0F0A18),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: enabled
                  ? const Color(0xFF2D1A5C)
                  : const Color(0xFF1A1228),
            ),
          ),
          child: Column(
            children: [
              Text(icon,
                  style: TextStyle(
                      fontSize: 28,
                      color: enabled ? null : Colors.white12)),
              const SizedBox(height: 6),
              Text(label,
                  style: TextStyle(
                      color: enabled ? Colors.white60 : Colors.white12,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Today's feed/sleep/diaper counts shown above the activity icon grid —
/// fills the space that would otherwise sit empty between the section
/// header and the grid with something actually useful.
class _DailyStatsStrip extends StatelessWidget {
  const _DailyStatsStrip({
    required this.feedCount,
    required this.sleepHours,
    required this.diaperCount,
  });

  final int feedCount;
  final double sleepHours;
  final int diaperCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        children: [
          Expanded(child: _StatChip(value: '$feedCount', label: 'Cữ bú', color: AppColors.blossom)),
          const SizedBox(width: 8),
          Expanded(
            child: _StatChip(
              value: sleepHours > 0 ? '${sleepHours.toStringAsFixed(1)}h' : '—',
              label: 'Giờ ngủ',
              color: AppColors.lavender,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: _StatChip(value: '$diaperCount', label: 'Thay tã', color: AppColors.mint)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color, letterSpacing: -0.5),
          ),
          const SizedBox(height: 1),
          Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.muted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _WonderWeeksBanner extends StatelessWidget {
  const _WonderWeeksBanner({
    required this.currentLeap,
    required this.nextLeap,
    required this.currentWeek,
    required this.onTap,
  });

  final LeapData? currentLeap;
  final LeapData? nextLeap;
  final int currentWeek;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isStormy = currentLeap != null;
    final weeksUntilNext = nextLeap != null ? nextLeap!.stormStartWeek - currentWeek : 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isStormy
              ? AppColors.warning.withOpacity(0.08)
              : const Color(0xFF7B5AAA).withOpacity(0.07),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isStormy
                ? AppColors.warning.withOpacity(0.3)
                : const Color(0xFF7B5AAA).withOpacity(0.25),
          ),
        ),
        child: Row(
          children: [
            Text(
              isStormy ? '⛈️' : '🧠',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isStormy
                        ? 'Leap ${currentLeap!.number}: ${currentLeap!.name}'
                        : 'Sắp đến Leap ${nextLeap!.number} ($weeksUntilNext tuần nữa)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B3A8A),
                    ),
                  ),
                  Text(
                    isStormy
                        ? 'Bé đang trong giai đoạn phát triển nhảy vọt 🌟'
                        : nextLeap!.name,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.body,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFF7B5AAA), size: 18),
          ],
        ),
      ),
    );
  }
}
