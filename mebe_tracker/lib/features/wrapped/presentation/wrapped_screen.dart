import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/home_provider.dart';
import '../data/wrapped_stats.dart';

// Provider that computes stats for a given year
final wrappedYearProvider = StateProvider<int>((ref) => DateTime.now().year);

final wrappedStatsProvider = Provider<WrappedStats?>((ref) {
  final baby = ref.watch(activeBabyProvider);
  final feedings = ref.watch(allFeedingsProvider).value;
  final sleeps = ref.watch(allSleepsProvider).value;
  final diapers = ref.watch(allDiapersProvider).value;
  final pumps = ref.watch(allPumpsProvider).value;
  final year = ref.watch(wrappedYearProvider);

  if (baby == null ||
      feedings == null ||
      sleeps == null ||
      diapers == null ||
      pumps == null) return null;

  return WrappedStats.compute(
    year: year,
    babyName: baby.name,
    feedings: feedings,
    sleeps: sleeps,
    diapers: diapers,
    pumps: pumps,
  );
});

class WrappedScreen extends ConsumerStatefulWidget {
  const WrappedScreen({super.key});

  @override
  ConsumerState<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends ConsumerState<WrappedScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _totalPages = 6;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _totalPages - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_page > 0) {
      _controller.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(wrappedStatsProvider);
    final year = ref.watch(wrappedYearProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (stats == null)
            _LoadingPage(year: year)
          else
            PageView(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p),
              children: [
                _CoverPage(stats: stats),
                _FeedingPage(stats: stats),
                _SleepPage(stats: stats),
                _DiaperPage(stats: stats),
                _PumpPage(stats: stats),
                _FinalePage(stats: stats),
              ],
            ),

          // Progress dots
          if (stats != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              left: AppSpacing.lg,
              right: AppSpacing.lg,
              child: Row(
                children: List.generate(_totalPages, (i) {
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 3,
                      decoration: BoxDecoration(
                        color: i <= _page
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

          // Back button
          Positioned(
            top: MediaQuery.of(context).padding.top + 24,
            left: AppSpacing.md,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          // Nav tap zones
          if (stats != null)
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(child: GestureDetector(onTap: _prev)),
                  Expanded(child: GestureDetector(onTap: _next)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ── Page base ────────────────────────────────────────────────────────────────

class _StoryPage extends StatelessWidget {
  const _StoryPage({
    required this.gradient,
    required this.child,
    this.emoji = '',
  });

  final LinearGradient gradient;
  final Widget child;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: gradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xxxl + 12,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Shared number widget ──────────────────────────────────────────────────────

class _BigNumber extends StatelessWidget {
  const _BigNumber(this.value, {this.color = Colors.white});
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w900,
        color: color,
        height: 1.0,
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingPage extends StatelessWidget {
  const _LoadingPage({required this.year});
  final int year;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}

// ── Page 1: Cover ─────────────────────────────────────────────────────────────

class _CoverPage extends StatelessWidget {
  const _CoverPage({required this.stats});
  final WrappedStats stats;

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      gradient: const LinearGradient(
        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🐰', style: TextStyle(fontSize: 64)),
          const Spacer(),
          Text(
            '${stats.year}',
            style: const TextStyle(
              fontSize: 100,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
              letterSpacing: -4,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'NĂNG NĂM\nCỦA ${stats.babyName.toUpperCase()}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Nhấn để xem hành trình\ncủa bạn trong một năm qua ✨',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Spacer(),
              Text(
                'Chạm để tiếp tục →',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Page 2: Feeding ───────────────────────────────────────────────────────────

class _FeedingPage extends StatelessWidget {
  const _FeedingPage({required this.stats});
  final WrappedStats stats;

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      gradient: const LinearGradient(
        colors: [Color(0xFFFF6B9D), Color(0xFFFF8E53)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🍼', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'CỮ BÚ',
            style: AppTextStyles.label.copyWith(
              color: Colors.white70,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BigNumber('${stats.totalFeedings}'),
          const Text(
            'lần cho bé bú\ntrong cả năm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              children: [
                _StatRow('Bú mẹ tổng cộng', stats.breastHours),
                const Divider(color: Colors.white24, height: 20),
                _StatRow('Bú bình tổng cộng',
                    '${stats.totalBottleMl.toStringAsFixed(0)} ml'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Page 3: Sleep ─────────────────────────────────────────────────────────────

class _SleepPage extends StatelessWidget {
  const _SleepPage({required this.stats});
  final WrappedStats stats;

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      gradient: const LinearGradient(
        colors: [Color(0xFF4B0082), Color(0xFF7B5AAA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('😴', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'GIẤC NGỦ',
            style: AppTextStyles.label.copyWith(
              color: Colors.white70,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BigNumber(stats.sleepHoursStr),
          const Text(
            'tổng thời gian ngủ\ncủa bé trong năm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const Spacer(),
          _SleepMoonRow(hours: stats.totalSleepHours),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: _StatRow(
              'Giấc ngủ dài nhất',
              stats.longestSleepStr,
            ),
          ),
        ],
      ),
    );
  }
}

class _SleepMoonRow extends StatelessWidget {
  const _SleepMoonRow({required this.hours});
  final double hours;

  @override
  Widget build(BuildContext context) {
    final moons = (hours / 8).round().clamp(0, 20);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(
        moons.clamp(0, 20),
        (_) => const Text('🌙', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

// ── Page 4: Diapers ───────────────────────────────────────────────────────────

class _DiaperPage extends StatelessWidget {
  const _DiaperPage({required this.stats});
  final WrappedStats stats;

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      gradient: const LinearGradient(
        colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🌸', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'THAY TÃ',
            style: AppTextStyles.label.copyWith(
              color: Colors.white70,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BigNumber('${stats.totalDiapers}'),
          const Text(
            'lần thay tã\ncả năm trời',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const Spacer(),
          _DiaperBar(wet: stats.wetDiapers, dirty: stats.dirtyDiapers),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              children: [
                _StatRow('Tã ướt 💧', '${stats.wetDiapers}'),
                const Divider(color: Colors.white24, height: 20),
                _StatRow('Tã bẩn 💩', '${stats.dirtyDiapers}'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiaperBar extends StatelessWidget {
  const _DiaperBar({required this.wet, required this.dirty});
  final int wet;
  final int dirty;

  @override
  Widget build(BuildContext context) {
    final total = wet + dirty;
    if (total == 0) return const SizedBox.shrink();
    final wetRatio = wet / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tỷ lệ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              Expanded(
                flex: (wetRatio * 100).round(),
                child: Container(
                  height: 24,
                  color: Colors.blue.shade300,
                  alignment: Alignment.center,
                  child: const Text('💧', style: TextStyle(fontSize: 12)),
                ),
              ),
              Expanded(
                flex: 100 - (wetRatio * 100).round(),
                child: Container(
                  height: 24,
                  color: Colors.brown.shade300,
                  alignment: Alignment.center,
                  child: const Text('💩', style: TextStyle(fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Page 5: Pumping ───────────────────────────────────────────────────────────

class _PumpPage extends StatelessWidget {
  const _PumpPage({required this.stats});
  final WrappedStats stats;

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      gradient: const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🥛', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'HÚT SỮA',
            style: AppTextStyles.label.copyWith(
              color: Colors.white70,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _BigNumber('${stats.totalPumpSessions}'),
          const Text(
            'lần hút sữa\ntrong năm',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const Spacer(),
          if (stats.totalPumpMl > 0) ...[
            _MilkBottles(ml: stats.totalPumpMl),
            const SizedBox(height: AppSpacing.lg),
          ],
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: _StatRow(
              'Tổng sữa hút được',
              '${(stats.totalPumpMl / 1000).toStringAsFixed(1)} lít',
            ),
          ),
        ],
      ),
    );
  }
}

class _MilkBottles extends StatelessWidget {
  const _MilkBottles({required this.ml});
  final double ml;

  @override
  Widget build(BuildContext context) {
    final bottles = (ml / 150).round().clamp(0, 15);
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: List.generate(
        bottles,
        (_) => const Text('🍼', style: TextStyle(fontSize: 22)),
      ),
    );
  }
}

// ── Page 6: Finale ────────────────────────────────────────────────────────────

class _FinalePage extends StatelessWidget {
  const _FinalePage({required this.stats});
  final WrappedStats stats;

  void _share(BuildContext context) {
    final text = '''🐰 ${stats.babyName}'s ${stats.year} — Năng Năm

🍼 ${stats.totalFeedings} cữ bú
😴 ${stats.sleepHoursStr} giấc ngủ
🌸 ${stats.totalDiapers} lần thay tã
🥛 ${stats.totalPumpSessions} lần hút sữa
📅 ${stats.trackingDays} ngày ghi nhật ký

Cảm ơn vì đã không ngủ đủ giấc để yêu thương bé 💕
''';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return _StoryPage(
      gradient: const LinearGradient(
        colors: [Color(0xFF1A1A2E), Color(0xFF6A11CB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆', style: TextStyle(fontSize: 48)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'TỔNG KẾT',
            style: AppTextStyles.label.copyWith(
              color: Colors.white70,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${stats.trackingDays}',
            style: const TextStyle(
              fontSize: 72,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1,
            ),
          ),
          const Text(
            'ngày ghi nhật ký\ncùng bé yêu 💕',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: Colors.white24),
            ),
            child: Column(
              children: [
                _StatRow('Giờ bận nhất', stats.busiestHourStr),
                const Divider(color: Colors.white24, height: 20),
                _StatRow('Ngày bận nhất', stats.busiestDay),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _share(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF6A11CB),
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
              icon: const Icon(Icons.share_rounded),
              label: const Text(
                'Chia sẻ năng năm',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
