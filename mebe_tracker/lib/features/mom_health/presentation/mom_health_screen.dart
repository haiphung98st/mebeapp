import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../data/mom_health_entry.dart';
import '../data/mom_health_provider.dart';

class MomHealthScreen extends ConsumerStatefulWidget {
  const MomHealthScreen({super.key});

  @override
  ConsumerState<MomHealthScreen> createState() => _MomHealthScreenState();
}

class _MomHealthScreenState extends ConsumerState<MomHealthScreen> {
  int _mood = 3;
  int _water = 4;
  double _sleep = 7;
  final List<String> _meds = [];
  final _medCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadToday());
  }

  void _loadToday() {
    final today = ref.read(todayMomHealthProvider);
    if (today != null) {
      setState(() {
        _mood = today.mood;
        _water = today.waterGlasses;
        _sleep = today.sleepHours;
        _meds.addAll(today.medicines);
      });
    }
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    setState(() => _saving = true);
    final existing = ref.read(todayMomHealthProvider);
    final entry = MomHealthEntry(
      id: existing?.dateKey ?? _todayKey(),
      userId: user.uid,
      date: DateTime.now(),
      mood: _mood,
      waterGlasses: _water,
      sleepHours: _sleep,
      medicines: List.from(_meds),
    );
    await saveMomHealthEntry(user, entry);
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu check-in hôm nay')),
      );
    }
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _medCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(momHealthEntriesProvider).value ?? [];
    final motivation = dailyMotivations[DateTime.now().day % dailyMotivations.length];

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Sức khoẻ mẹ'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _MotivationCard(text: motivation),
          const SizedBox(height: AppSpacing.lg),
          _CheckInCard(
            mood: _mood,
            water: _water,
            sleep: _sleep,
            medicines: _meds,
            medCtrl: _medCtrl,
            onMoodChanged: (v) => setState(() => _mood = v),
            onWaterChanged: (v) => setState(() => _water = v),
            onSleepChanged: (v) => setState(() => _sleep = v),
            onAddMed: () {
              final m = _medCtrl.text.trim();
              if (m.isNotEmpty) {
                setState(() {
                  _meds.add(m);
                  _medCtrl.clear();
                });
              }
            },
            onRemoveMed: (m) => setState(() => _meds.remove(m)),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blossom,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Lưu check-in hôm nay'),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _EpdsCard(),
          const SizedBox(height: AppSpacing.lg),
          _SelfCareChecklist(),
          if (entries.length >= 3) ...[
            const SizedBox(height: AppSpacing.lg),
            _WeeklyTrendChart(entries: entries.take(7).toList().reversed.toList()),
          ],
        ],
      ),
    );
  }
}

// ─── Motivation ───────────────────────────────────────────────────────────────

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.blossom, AppColors.lavender],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMd.copyWith(
          color: AppColors.white,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

// ─── Check-in card ────────────────────────────────────────────────────────────

class _CheckInCard extends StatelessWidget {
  const _CheckInCard({
    required this.mood,
    required this.water,
    required this.sleep,
    required this.medicines,
    required this.medCtrl,
    required this.onMoodChanged,
    required this.onWaterChanged,
    required this.onSleepChanged,
    required this.onAddMed,
    required this.onRemoveMed,
  });

  final int mood;
  final int water;
  final double sleep;
  final List<String> medicines;
  final TextEditingController medCtrl;
  final ValueChanged<int> onMoodChanged;
  final ValueChanged<int> onWaterChanged;
  final ValueChanged<double> onSleepChanged;
  final VoidCallback onAddMed;
  final ValueChanged<String> onRemoveMed;

  static const _moodEmoji = ['😢', '😕', '😐', '🙂', '😊'];
  static const _moodLabel = ['Rất buồn', 'Buồn', 'Bình thường', 'Vui', 'Rất vui'];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Tâm trạng hôm nay', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (i) {
                final selected = mood == i + 1;
                return GestureDetector(
                  onTap: () => onMoodChanged(i + 1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.petal
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(_moodEmoji[i],
                            style: TextStyle(fontSize: selected ? 28 : 22)),
                        Text(_moodLabel[i],
                            style: TextStyle(
                                fontSize: 9,
                                color: selected
                                    ? AppColors.blossom
                                    : AppColors.muted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const Divider(height: AppSpacing.xl),
            Text('Uống nước', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.local_drink_outlined,
                    color: AppColors.lavender, size: 20),
                Expanded(
                  child: Slider(
                    value: water.toDouble(),
                    min: 0,
                    max: 10,
                    divisions: 10,
                    label: '$water ly',
                    activeColor: AppColors.lavender,
                    onChanged: (v) => onWaterChanged(v.round()),
                  ),
                ),
                Text('$water ly',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.lavender)),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Text('Giờ ngủ đêm qua', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.bedtime_outlined,
                    color: AppColors.mint, size: 20),
                Expanded(
                  child: Slider(
                    value: sleep,
                    min: 0,
                    max: 12,
                    divisions: 24,
                    label: '${sleep}h',
                    activeColor: AppColors.mint,
                    onChanged: onSleepChanged,
                  ),
                ),
                Text('${sleep.toStringAsFixed(1)}h',
                    style: AppTextStyles.bodyMd
                        .copyWith(color: AppColors.mint)),
              ],
            ),
            const Divider(height: AppSpacing.xl),
            Text('Thuốc đã uống', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                ...medicines.map((m) => Chip(
                      label: Text(m),
                      onDeleted: () => onRemoveMed(m),
                      backgroundColor: AppColors.petal,
                      deleteIconColor: AppColors.blossom,
                    )),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: medCtrl,
                    decoration: const InputDecoration(
                      hintText: 'Tên thuốc',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppColors.blossom),
                  onPressed: onAddMed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EPDS quiz ────────────────────────────────────────────────────────────────

class _EpdsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: () => _showEpds(context),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              const Icon(Icons.psychology_outlined,
                  color: AppColors.lavender, size: 28),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kiểm tra Baby Blues (EPDS)',
                        style: AppTextStyles.bodyMd),
                    Text(
                      'Bộ câu hỏi đánh giá trầm cảm sau sinh chuẩn Edinburgh',
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  void _showEpds(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg)),
      ),
      builder: (_) => const _EpdsSheet(),
    );
  }
}

class _EpdsSheet extends StatefulWidget {
  const _EpdsSheet();

  @override
  State<_EpdsSheet> createState() => _EpdsSheetState();
}

class _EpdsSheetState extends State<_EpdsSheet> {
  final List<int?> _answers = List.filled(10, null);

  int get _total => _answers.whereType<int>().fold(0, (a, b) => a + b);
  bool get _complete => _answers.every((a) => a != null);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (_, ctrl) => ListView(
        controller: ctrl,
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Bộ câu hỏi EPDS', style: AppTextStyles.headingMd),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Trong 7 ngày qua, bạn cảm thấy thế nào?',
            style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...List.generate(epdsQuestions.length, (i) {
            return Padding(
              padding:
                  const EdgeInsets.only(bottom: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${i + 1}. ${epdsQuestions[i]}',
                      style: AppTextStyles.bodyMd),
                  const SizedBox(height: AppSpacing.sm),
                  ...List.generate(4, (j) {
                    final labels = [
                      'Không, không bao giờ',
                      'Hiếm khi',
                      'Đôi khi',
                      'Thường xuyên',
                    ];
                    return RadioListTile<int>(
                      dense: true,
                      title: Text(labels[j],
                          style: AppTextStyles.bodySm),
                      value: j,
                      groupValue: _answers[i],
                      activeColor: AppColors.blossom,
                      onChanged: (v) =>
                          setState(() => _answers[i] = v),
                    );
                  }),
                ],
              ),
            );
          }),
          if (_complete) ...[
            const Divider(),
            const SizedBox(height: AppSpacing.md),
            _EpdsResult(score: _total),
            const SizedBox(height: AppSpacing.xl),
          ],
          ElevatedButton(
            onPressed: _complete
                ? () => Navigator.of(context).pop()
                : null,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blossom),
            child: Text(_complete ? 'Đóng' : 'Trả lời đủ 10 câu để xem kết quả'),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _EpdsResult extends StatelessWidget {
  const _EpdsResult({required this.score});
  final int score;

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    final String advice;
    if (score <= 9) {
      color = AppColors.mint;
      label = 'Bình thường (${score}/30)';
      advice = 'Tuyệt vời! Tâm lý của bạn đang ổn định. Hãy tiếp tục chăm sóc bản thân nhé.';
    } else if (score <= 12) {
      color = AppColors.warning;
      label = 'Cần chú ý (${score}/30)';
      advice = 'Bạn có một số dấu hiệu căng thẳng. Hãy chia sẻ với người thân hoặc bác sĩ.';
    } else {
      color = AppColors.error;
      label = 'Nên gặp chuyên gia (${score}/30)';
      advice = 'Điểm số cho thấy bạn có thể đang trải qua trầm cảm sau sinh. Hãy liên hệ bác sĩ càng sớm càng tốt.';
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.headingSm
                  .copyWith(color: color)),
          const SizedBox(height: AppSpacing.sm),
          Text(advice,
              style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}

// ─── Self-care checklist ──────────────────────────────────────────────────────

const _selfCareItems = [
  '🚿 Tắm rửa',
  '🍽️ Ăn đủ 3 bữa',
  '🚶 Đi bộ 10 phút',
  '📞 Trò chuyện với người thân',
  '📖 Đọc sách / nghe nhạc',
  '🧘 Thở sâu / thiền 5 phút',
];

class _SelfCareChecklist extends StatefulWidget {
  @override
  State<_SelfCareChecklist> createState() => _SelfCareChecklistState();
}

class _SelfCareChecklistState extends State<_SelfCareChecklist> {
  final Set<String> _done = {};

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Checklist tự chăm sóc hôm nay',
                style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.sm),
            ..._selfCareItems.map((item) => CheckboxListTile(
                  dense: true,
                  title: Text(item, style: AppTextStyles.bodyMd),
                  value: _done.contains(item),
                  activeColor: AppColors.mint,
                  onChanged: (v) => setState(() {
                    if (v == true) {
                      _done.add(item);
                    } else {
                      _done.remove(item);
                    }
                  }),
                )),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${_done.length}/${_selfCareItems.length} hoàn thành',
              style: AppTextStyles.bodySm
                  .copyWith(color: AppColors.mint),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Weekly trend chart ───────────────────────────────────────────────────────

class _WeeklyTrendChart extends StatelessWidget {
  const _WeeklyTrendChart({required this.entries});
  final List<MomHealthEntry> entries;

  static const _moodColors = [
    AppColors.error,
    AppColors.warning,
    AppColors.muted,
    AppColors.mint,
    AppColors.blossom,
  ];

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('dd/MM');
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xu hướng 7 ngày', style: AppTextStyles.label),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 80,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: entries.map((e) {
                  final barH = max(12.0, e.mood / 5 * 60);
                  final color = _moodColors[(e.mood - 1).clamp(0, 4)];
                  return Expanded(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            ['😢', '😕', '😐', '🙂', '😊']
                                [e.mood - 1],
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            height: barH,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            fmt.format(e.date),
                            style: const TextStyle(
                                fontSize: 8, color: AppColors.muted),
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
      ),
    );
  }
}
