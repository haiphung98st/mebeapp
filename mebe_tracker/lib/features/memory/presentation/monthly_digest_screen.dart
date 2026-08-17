import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/monthly_digest_generator.dart';

final _digestYearProvider = StateProvider<int>((ref) => DateTime.now().year);
final _digestMonthProvider = StateProvider<int>((ref) => DateTime.now().month);

final _digestProvider = FutureProvider<MonthlyDigest?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return null;
  final year = ref.watch(_digestYearProvider);
  final month = ref.watch(_digestMonthProvider);
  return MonthlyDigestGenerator().generate(
    userId: user.uid,
    baby: baby,
    year: year,
    month: month,
  );
});

class MonthlyDigestScreen extends ConsumerWidget {
  const MonthlyDigestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final digestAsync = ref.watch(_digestProvider);
    final year = ref.watch(_digestYearProvider);
    final month = ref.watch(_digestMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.peach,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tổng kết tháng 📊',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: !isPremium
          ? _PremiumGate(onUpgrade: () => context.push('/home/subscription'))
          : Column(
              children: [
                _MonthSelector(
                  year: year,
                  month: month,
                  onChangeYear: (v) =>
                      ref.read(_digestYearProvider.notifier).state = v,
                  onChangeMonth: (v) =>
                      ref.read(_digestMonthProvider.notifier).state = v,
                ),
                Expanded(
                  child: digestAsync.when(
                    loading: () => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    error: (e, _) => Center(child: Text('Lỗi: $e')),
                    data: (digest) => digest == null
                        ? const Center(child: Text('Chưa có dữ liệu'))
                        : _DigestContent(digest: digest),
                  ),
                ),
              ],
            ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.year,
    required this.month,
    required this.onChangeYear,
    required this.onChangeMonth,
  });

  final int year;
  final int month;
  final ValueChanged<int> onChangeYear;
  final ValueChanged<int> onChangeMonth;

  static const _months = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (month == 1) {
                onChangeYear(year - 1);
                onChangeMonth(12);
              } else {
                onChangeMonth(month - 1);
              }
            },
          ),
          Text(
            '${_months[month]} $year',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final now = DateTime.now();
              if (year == now.year && month == now.month) return;
              if (month == 12) {
                onChangeYear(year + 1);
                onChangeMonth(1);
              } else {
                onChangeMonth(month + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DigestContent extends StatelessWidget {
  const _DigestContent({required this.digest});

  final MonthlyDigest digest;

  void _share() {
    final text = '''📊 Tổng kết ${digest.monthLabel} ${digest.year}
👶 ${digest.babyName} — ${digest.ageMonths} tháng tuổi

🍼 Tổng cữ bú: ${digest.totalFeedings}
😴 Trung bình ngủ: ${digest.avgSleepHours.toStringAsFixed(1)}h/ngày
🌸 Thay tã: ${digest.totalDiapers} lần
${digest.weightKg != null ? '⚖️ Cân nặng: ${digest.weightKg!.toStringAsFixed(2)} kg\n' : ''}${digest.highlights.map((h) => '✨ $h').join('\n')}

MeBé ✨''';
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Gradient hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB997), Color(0xFFFF8C68)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text('📊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${digest.monthLabel} ${digest.year}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${digest.babyName} — ${digest.ageMonths} tháng tuổi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  // Stat row
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.peach.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBox(
                          emoji: '🍼',
                          label: 'Cữ bú',
                          value: '${digest.totalFeedings}',
                        ),
                        _Divider(),
                        _StatBox(
                          emoji: '😴',
                          label: 'Ngủ/ngày',
                          value: '${digest.avgSleepHours.toStringAsFixed(1)}h',
                        ),
                        _Divider(),
                        _StatBox(
                          emoji: '🌸',
                          label: 'Thay tã',
                          value: '${digest.totalDiapers}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Growth
                  if (digest.weightKg != null || digest.heightCm != null)
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (digest.weightKg != null)
                            _StatBox(
                              emoji: '⚖️',
                              label: 'Cân nặng',
                              value: '${digest.weightKg!.toStringAsFixed(2)} kg',
                            ),
                          if (digest.heightCm != null)
                            _StatBox(
                              emoji: '📏',
                              label: 'Chiều cao',
                              value: '${digest.heightCm!.toStringAsFixed(1)} cm',
                            ),
                        ],
                      ),
                    ),

                  // Achievements
                  if (digest.newAchievementNames.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _SectionCard(
                      title: 'Thành tích tháng này 🏆',
                      children: digest.newAchievementNames
                          .map((a) => _BulletItem(text: a))
                          .toList(),
                    ),
                  ],

                  // Highlights
                  if (digest.highlights.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    _SectionCard(
                      title: 'Điểm nổi bật ✨',
                      children: digest.highlights
                          .map((h) => _BulletItem(text: h))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _share,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.peach,
                      ),
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('Chia sẻ tổng kết'),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.divider,
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: AppColors.body),
      ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  const _PremiumGate({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Tổng kết hàng tháng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Nhìn lại hành trình cùng bé mỗi tháng.\nCần Premium để xem.',
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
      ),
    );
  }
}
