import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_header.dart';
import '../data/motor_entry.dart';
import '../data/motor_provider.dart';

class MotorSkillsScreen extends ConsumerStatefulWidget {
  const MotorSkillsScreen({super.key});

  @override
  ConsumerState<MotorSkillsScreen> createState() => _MotorSkillsScreenState();
}

class _MotorSkillsScreenState extends ConsumerState<MotorSkillsScreen> {
  BabyActivity _selectedActivity = BabyActivity.tummyTime;
  bool _timerRunning = false;
  int _elapsed = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _elapsed = 0;
      _timerRunning = true;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsed++);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _timerRunning = false);
    if (_elapsed > 0) {
      ref.read(motorNotifierProvider.notifier).log(_selectedActivity, _elapsed);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${_selectedActivity.emoji} ${_selectedActivity.label} — ${_fmtDuration(_elapsed)} đã lưu!',
          ),
        ),
      );
      setState(() => _elapsed = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final weeklySummary = ref.watch(weeklyMotorSummaryProvider);
    final recentEntries = ref.watch(allMotorsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.powder,
      body: Column(
        children: [
          BunnyHeader(
            gradient: AppColors.gradientGrowth,
            earLeftColor: AppColors.growthEarLeft,
            earRightColor: AppColors.growthEarRight,
            title: 'Vận động',
            subtitle: 'Luyện tập cùng bé',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActivityPicker(
                    selected: _selectedActivity,
                    onSelect: (a) {
                      if (_timerRunning) return;
                      setState(() => _selectedActivity = a);
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TimerCard(
                    activity: _selectedActivity,
                    elapsed: _elapsed,
                    running: _timerRunning,
                    onStart: _startTimer,
                    onStop: _stopTimer,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _WeeklyChart(summary: weeklySummary),
                  const SizedBox(height: AppSpacing.lg),
                  _RecentList(entries: recentEntries.take(10).toList()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityPicker extends StatelessWidget {
  const _ActivityPicker({required this.selected, required this.onSelect});
  final BabyActivity selected;
  final void Function(BabyActivity) onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: BabyActivity.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final activity = BabyActivity.values[i];
          final isSelected = activity == selected;
          return GestureDetector(
            onTap: () => onSelect(activity),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 72,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mintLight : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: isSelected ? AppColors.success : AppColors.divider,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(activity.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    activity.label,
                    style: AppTextStyles.bodySm.copyWith(
                      color: isSelected ? AppColors.success : AppColors.muted,
                      fontSize: 9,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _TimerCard extends StatelessWidget {
  const _TimerCard({
    required this.activity,
    required this.elapsed,
    required this.running,
    required this.onStart,
    required this.onStop,
  });

  final BabyActivity activity;
  final int elapsed;
  final bool running;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.gradientGrowth,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Text(
            '${activity.emoji} ${activity.label}',
            style: AppTextStyles.bodyMd.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _fmtDuration(elapsed),
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GestureDetector(
            onTap: running ? onStop : onStart,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                running ? Icons.stop_rounded : Icons.play_arrow_rounded,
                size: 40,
                color: running ? AppColors.error : AppColors.success,
              ),
            ),
          ),
          if (running) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nhấn dừng để lưu',
              style: AppTextStyles.bodySm.copyWith(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  const _WeeklyChart({required this.summary});
  final Map<String, int> summary;

  @override
  Widget build(BuildContext context) {
    final values = summary.values.toList();
    final maxVal = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hoạt động 7 ngày qua',
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: summary.entries.map((e) {
                final frac = maxVal > 0 ? e.value / maxVal : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (e.value > 0)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              _fmtShort(e.value),
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.success,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: 80 * frac.toDouble(),
                          decoration: BoxDecoration(
                            color: frac > 0 ? AppColors.mint : AppColors.divider,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          e.key,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.muted,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentList extends StatelessWidget {
  const _RecentList({required this.entries});
  final List<MotorEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return Center(
        child: Text(
          'Chưa có hoạt động nào.\nBắt đầu hẹn giờ để ghi lại!',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gần đây',
          style: AppTextStyles.bodyMd.copyWith(
            color: AppColors.ink,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...entries.map((e) {
          final h = e.startTime.hour.toString().padLeft(2, '0');
          final m = e.startTime.minute.toString().padLeft(2, '0');
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.mintLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(e.activity.emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.activity.label, style: AppTextStyles.bodyMd),
                      Text(
                        '$h:$m',
                        style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  _fmtDuration(e.durationSeconds),
                  style: AppTextStyles.headingSm.copyWith(color: AppColors.success),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

String _fmtDuration(int secs) {
  final m = secs ~/ 60;
  final s = secs % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

String _fmtShort(int secs) {
  if (secs < 60) return '${secs}s';
  return '${secs ~/ 60}m';
}
