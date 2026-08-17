import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/time_of_day_list_tile.dart';
import '../../../shared/models/notification_config.dart';
import '../../../shared/providers/notification_config_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // Local draft so we can "Save" all at once
  late NotificationConfig _draft;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _draft = ref.read(notificationConfigProvider);
  }

  void _set(NotificationConfig updated) {
    setState(() {
      _draft = updated;
      _dirty = true;
    });
  }

  Future<void> _save() async {
    final n = ref.read(notificationConfigProvider.notifier);
    await n.updateFeedingConfig(
      enabled: _draft.feedingEnabled,
      mode: _draft.feedingMode,
      intervalMinutes: _draft.feedingIntervalMinutes,
      fixedTimes: _draft.feedingFixedTimes,
      vibrate: _draft.feedingVibrate,
      sound: _draft.feedingSound,
    );
    await n.updatePumpConfig(
      enabled: _draft.pumpEnabled,
      mode: _draft.pumpMode,
      intervalMinutes: _draft.pumpIntervalMinutes,
      fixedTimes: _draft.pumpFixedTimes,
      activeHourStart: _draft.pumpActiveHourStart,
      activeHourEnd: _draft.pumpActiveHourEnd,
      dailyGoalSessions: _draft.pumpDailyGoalSessions,
      showProgress: _draft.pumpShowProgress,
    );
    await n.updateSleepConfig(
      enabled: _draft.sleepEnabled,
      windowReminder: _draft.sleepWindowReminder,
      overtimeAlert: _draft.sleepOvertimeAlert,
      maxNapMinutes: _draft.sleepMaxNapMinutes,
    );
    await n.updateVaccineConfig(
      enabled: _draft.vaccineEnabled,
      daysBeforeAlert: _draft.vaccineDaysBeforeAlert,
      secondAlert: _draft.vaccineSecondAlert,
      overdueAlert: _draft.vaccineOverdueAlert,
    );
    await n.updateMilkStashConfig(
      enabled: _draft.milkStashEnabled,
      expiryDays: _draft.milkStashExpiryDays,
      lowAlert: _draft.milkStashLowAlert,
      lowThresholdMl: _draft.milkStashLowThresholdMl,
    );
    await n.updateQuietHours(
      enabled: _draft.quietHoursEnabled,
      start: _draft.quietHourStart,
      end: _draft.quietHourEnd,
      exceptVaccine: _draft.quietHoursExceptVaccine,
    );
    await n.updateWeeklyReport(
      enabled: _draft.weeklyReportEnabled,
      dayOfWeek: _draft.weeklyReportDayOfWeek,
      hour: _draft.weeklyReportHour,
    );
    if (mounted) {
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🐰 Đã lưu cài đặt thông báo')),
      );
    }
  }

  Future<void> _reset() async {
    await ref.read(notificationConfigProvider.notifier).resetToDefault();
    if (mounted) {
      setState(() {
        _draft = ref.read(notificationConfigProvider);
        _dirty = false;
      });
    }
  }

  Future<void> _applyPreset(NotificationPreset preset) async {
    await ref
        .read(notificationConfigProvider.notifier)
        .applyPreset(preset);
    if (mounted) {
      setState(() {
        _draft = ref.read(notificationConfigProvider);
        _dirty = false;
      });
    }
  }

  Future<TimeOfDay?> _pickTime(BuildContext ctx, {int hour = 9, int minute = 0}) {
    return showTimePicker(
        context: ctx, initialTime: TimeOfDay(hour: hour, minute: minute));
  }

  String _fmtHm(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  String _fmtMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '$m phút';
    if (m == 0) return '$h tiếng';
    return '$h tiếng $m phút';
  }

  // ── PRESET PANEL ──────────────────────────────────────────

  Widget _presetPanel() {
    final presets = [
      (NotificationPreset.newborn, '🌙', 'Mới sinh', '2h · hút 3h'),
      (NotificationPreset.months3to6, '🌤️', '3-6 tháng', '3h · hút 4h'),
      (NotificationPreset.months6plus, '☀️', '6+ tháng', '4h · 2 lần hút'),
      (NotificationPreset.custom, '✏️', 'Tự chỉnh', 'Tuỳ bạn'),
    ];
    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: presets.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (ctx, i) {
          final (preset, emoji, label, sub) = presets[i];
          return GestureDetector(
            onTap: () => _applyPreset(preset),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 110,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$emoji $label',
                      style: AppTextStyles.bodySm
                          .copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(sub,
                      style: AppTextStyles.bodySm
                          .copyWith(color: AppColors.muted)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── SECTION CARD ─────────────────────────────────────────

  Widget _section(String title, List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.label),
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.sm),
              child: Column(children: children),
            ),
          ),
        ],
      ),
    );
  }

  Widget _switchRow(String title, bool value, ValueChanged<bool> onChanged,
      {String? subtitle}) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyMd),
      subtitle:
          subtitle != null ? Text(subtitle, style: AppTextStyles.bodySm) : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppColors.blossom,
    );
  }

  Widget _labeledRow(String label, Widget trailing) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
              child: Text(label, style: AppTextStyles.bodyMd)),
          trailing,
        ],
      ),
    );
  }

  Widget _slider(String label, double value, double min, double max,
      int divisions, String Function(double) fmt, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: AppTextStyles.bodyMd),
                Text(fmt(value),
                    style: AppTextStyles.bodySm
                        .copyWith(color: AppColors.blossom, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            activeColor: AppColors.blossom,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _numberStepper(int value, int min, int max,
      ValueChanged<int> onChanged) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _stepBtn(Icons.remove, value > min ? () => onChanged(value - 1) : null),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text('$value',
              style: AppTextStyles.bodyMd
                  .copyWith(fontWeight: FontWeight.w700)),
        ),
        _stepBtn(
            Icons.add, value < max ? () => onChanged(value + 1) : null),
      ],
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: onTap != null ? AppColors.blush : AppColors.powder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Icon(icon,
            size: 18,
            color: onTap != null ? AppColors.blossom : AppColors.muted),
      ),
    );
  }

  Widget _segmented<T>(List<(T, String)> options, T value,
      ValueChanged<T?> onChanged) {
    return SegmentedButton<T>(
      segments: options
          .map((o) => ButtonSegment(value: o.$1, label: Text(o.$2)))
          .toList(),
      selected: {value},
      onSelectionChanged: (s) => onChanged(s.firstOrNull),
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.blossom
              : AppColors.white;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? AppColors.white
              : AppColors.body;
        }),
      ),
    );
  }

  Widget _addTimeButton(List<TimeOfDayConfig> times,
      ValueChanged<List<TimeOfDayConfig>> onChanged) {
    const quickTimes = [
      (6, 0), (9, 0), (12, 0), (15, 0), (18, 0), (21, 0)
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...times.asMap().entries.map((e) => TimeOfDayListTile(
              config: e.value,
              onChanged: (updated) {
                final list = [...times];
                list[e.key] = updated;
                onChanged(list);
              },
              onDelete: () {
                final list = [...times]..removeAt(e.key);
                onChanged(list);
              },
            )),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                onPressed: () async {
                  final t = await _pickTime(context);
                  if (t != null) {
                    onChanged([
                      ...times,
                      TimeOfDayConfig(hour: t.hour, minute: t.minute),
                    ]);
                  }
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('+ Thêm giờ nhắc'),
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.blossom),
              ),
              Wrap(
                spacing: AppSpacing.sm,
                children: quickTimes.map((qt) {
                  return ActionChip(
                    label:
                        Text(_fmtHm(qt.$1, qt.$2), style: AppTextStyles.bodySm),
                    onPressed: () {
                      onChanged([
                        ...times,
                        TimeOfDayConfig(hour: qt.$1, minute: qt.$2),
                      ]);
                    },
                    backgroundColor: AppColors.blush,
                    labelStyle:
                        const TextStyle(color: AppColors.blossom),
                    side: BorderSide.none,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── SECTIONS ─────────────────────────────────────────────

  Widget _feedingSection() {
    return _section('CỮ BÚ 🤱', [
      _switchRow('Nhắc cữ bú', _draft.feedingEnabled,
          (v) => _set(_draft.copyWith(feedingEnabled: v))),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _draft.feedingEnabled
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          children: [
            _labeledRow(
              'Chế độ nhắc',
              _segmented(
                [(FeedingReminderMode.auto, 'Tự động'),
                 (FeedingReminderMode.fixed, 'Giờ cố định')],
                _draft.feedingMode,
                (v) => v != null
                    ? _set(_draft.copyWith(feedingMode: v))
                    : null,
              ),
            ),
            if (_draft.feedingMode == FeedingReminderMode.auto)
              _slider(
                'Khoảng cách giữa các cữ',
                _draft.feedingIntervalMinutes.toDouble(),
                60, 300, 16,
                (v) => _fmtMinutes(v.round()),
                (v) => _set(_draft.copyWith(feedingIntervalMinutes: v.round())),
              )
            else
              _addTimeButton(
                _draft.feedingFixedTimes,
                (list) => _set(_draft.copyWith(feedingFixedTimes: list)),
              ),
            _labeledRow(
              'Âm thanh',
              DropdownButton<NotificationSound>(
                value: _draft.feedingSound,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                      value: NotificationSound.gentle,
                      child: Text('Nhẹ nhàng')),
                  DropdownMenuItem(
                      value: NotificationSound.default_,
                      child: Text('Mặc định')),
                  DropdownMenuItem(
                      value: NotificationSound.cheerful,
                      child: Text('Vui vẻ')),
                  DropdownMenuItem(
                      value: NotificationSound.silent,
                      child: Text('Tắt tiếng')),
                ],
                onChanged: (v) =>
                    v != null ? _set(_draft.copyWith(feedingSound: v)) : null,
              ),
            ),
            _switchRow('Rung', _draft.feedingVibrate,
                (v) => _set(_draft.copyWith(feedingVibrate: v))),
          ],
        ),
      ),
    ]);
  }

  Widget _pumpSection() {
    return _section('HÚT SỮA 🥛', [
      _switchRow('Nhắc hút sữa', _draft.pumpEnabled,
          (v) => _set(_draft.copyWith(pumpEnabled: v))),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _draft.pumpEnabled
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          children: [
            _labeledRow(
              'Chế độ',
              _segmented(
                [(PumpReminderMode.interval, 'Chu kỳ'),
                 (PumpReminderMode.fixed, 'Cố định'),
                 (PumpReminderMode.disabled, 'Tắt')],
                _draft.pumpMode,
                (v) => v != null
                    ? _set(_draft.copyWith(pumpMode: v))
                    : null,
              ),
            ),
            if (_draft.pumpMode == PumpReminderMode.interval) ...[
              _slider(
                'Khoảng cách',
                _draft.pumpIntervalMinutes.toDouble(),
                60, 360, 12,
                (v) => _fmtMinutes(v.round()),
                (v) => _set(_draft.copyWith(
                    pumpIntervalMinutes: v.round())),
              ),
              _labeledRow(
                'Giờ hoạt động',
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final t = await _pickTime(context,
                            hour: _draft.pumpActiveHourStart);
                        if (t != null) {
                          _set(_draft.copyWith(
                              pumpActiveHourStart: t.hour));
                        }
                      },
                      child: _timeChip(_fmtHm(_draft.pumpActiveHourStart, 0)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: Text('—'),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final t = await _pickTime(context,
                            hour: _draft.pumpActiveHourEnd);
                        if (t != null) {
                          _set(_draft.copyWith(
                              pumpActiveHourEnd: t.hour));
                        }
                      },
                      child: _timeChip(_fmtHm(_draft.pumpActiveHourEnd, 0)),
                    ),
                  ],
                ),
              ),
            ] else if (_draft.pumpMode == PumpReminderMode.fixed)
              _addTimeButton(
                _draft.pumpFixedTimes,
                (list) => _set(_draft.copyWith(pumpFixedTimes: list)),
              ),
            _labeledRow(
              'Mục tiêu phiên hút/ngày',
              _numberStepper(
                  _draft.pumpDailyGoalSessions, 1, 8,
                  (v) => _set(
                      _draft.copyWith(pumpDailyGoalSessions: v))),
            ),
            _switchRow(
              'Nhắc tiến độ buổi tối',
              _draft.pumpShowProgress,
              (v) => _set(_draft.copyWith(pumpShowProgress: v)),
              subtitle: 'Nhắc lúc 21h nếu chưa đạt mục tiêu',
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _sleepSection() {
    return _section('GIẤC NGỦ 🌙', [
      _switchRow(
        'Nhắc chuẩn bị ngủ',
        _draft.sleepWindowReminder,
        (v) => _set(_draft.copyWith(sleepWindowReminder: v)),
        subtitle: 'Thông báo 15 phút trước cửa sổ ngủ dự báo',
      ),
      _switchRow(
        'Cảnh báo ngủ quá lâu',
        _draft.sleepOvertimeAlert,
        (v) => _set(_draft.copyWith(sleepOvertimeAlert: v)),
      ),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _draft.sleepOvertimeAlert
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: _slider(
          'Giới hạn giấc ngủ ngày',
          _draft.sleepMaxNapMinutes.toDouble(),
          30, 180, 10,
          (v) => '${v.round()} phút',
          (v) =>
              _set(_draft.copyWith(sleepMaxNapMinutes: v.round())),
        ),
      ),
    ]);
  }

  Widget _vaccineSection() {
    return _section('TIÊM CHỦNG 💉', [
      _switchRow('Nhắc lịch tiêm chủng', _draft.vaccineEnabled,
          (v) => _set(_draft.copyWith(vaccineEnabled: v))),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _draft.vaccineEnabled
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          children: [
            _labeledRow(
              'Nhắc trước bao nhiêu ngày',
              _numberStepper(
                  _draft.vaccineDaysBeforeAlert, 1, 14,
                  (v) => _set(_draft.copyWith(
                      vaccineDaysBeforeAlert: v))),
            ),
            _switchRow('Nhắc thêm lần 2 (trước 1 ngày)',
                _draft.vaccineSecondAlert,
                (v) => _set(_draft.copyWith(vaccineSecondAlert: v))),
            _switchRow('Cảnh báo khi quá hạn tiêm',
                _draft.vaccineOverdueAlert,
                (v) => _set(_draft.copyWith(vaccineOverdueAlert: v))),
            _switchRow(
              'Ưu tiên qua giờ không làm phiền',
              _draft.quietHoursExceptVaccine,
              (v) => _set(
                  _draft.copyWith(quietHoursExceptVaccine: v)),
              subtitle: 'Luôn gửi nhắc tiêm dù đang trong giờ yên tĩnh',
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _milkStashSection() {
    return _section('KHO SỮA 🧊', [
      _switchRow('Cảnh báo sữa sắp hết hạn', _draft.milkStashEnabled,
          (v) => _set(_draft.copyWith(milkStashEnabled: v))),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _draft.milkStashEnabled
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          children: [
            _labeledRow(
              'Cảnh báo trước (ngày)',
              _numberStepper(
                  _draft.milkStashExpiryDays, 1, 5,
                  (v) => _set(
                      _draft.copyWith(milkStashExpiryDays: v))),
            ),
            _switchRow('Cảnh báo kho sữa thấp',
                _draft.milkStashLowAlert,
                (v) => _set(_draft.copyWith(milkStashLowAlert: v))),
            if (_draft.milkStashLowAlert)
              _slider(
                'Ngưỡng cảnh báo',
                _draft.milkStashLowThresholdMl.toDouble(),
                50, 500, 9,
                (v) => '${v.round()} ml',
                (v) => _set(_draft.copyWith(
                    milkStashLowThresholdMl: v.round())),
              ),
          ],
        ),
      ),
    ]);
  }

  Widget _quietHoursSection() {
    return _section('GIỜ YÊN TĨNH 🔕', [
      _switchRow(
        'Bật giờ yên tĩnh',
        _draft.quietHoursEnabled,
        (v) => _set(_draft.copyWith(quietHoursEnabled: v)),
        subtitle: 'Không gửi thông báo trong khoảng giờ này',
      ),
      AnimatedCrossFade(
        duration: const Duration(milliseconds: 200),
        crossFadeState: _draft.quietHoursEnabled
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        firstChild: const SizedBox.shrink(),
        secondChild: Column(
          children: [
            _labeledRow(
              'Từ',
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () async {
                      final t = await _pickTime(context,
                          hour: _draft.quietHourStart);
                      if (t != null) {
                        _set(_draft.copyWith(quietHourStart: t.hour));
                      }
                    },
                    child: _timeChip(_fmtHm(_draft.quietHourStart, 0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text('—'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      final t = await _pickTime(context,
                          hour: _draft.quietHourEnd);
                      if (t != null) {
                        _set(_draft.copyWith(quietHourEnd: t.hour));
                      }
                    },
                    child: _timeChip(_fmtHm(_draft.quietHourEnd, 0)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
              child: Text(
                'Không nhắc từ ${_fmtHm(_draft.quietHourStart, 0)} đến ${_fmtHm(_draft.quietHourEnd, 0)}',
                style: AppTextStyles.bodySm
                    .copyWith(color: AppColors.muted),
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  Widget _weeklyReportSection() {
    const days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
    return _section('BÁO CÁO TUẦN 📊', [
      _switchRow('Báo cáo tuần', _draft.weeklyReportEnabled,
          (v) => _set(_draft.copyWith(weeklyReportEnabled: v))),
      if (_draft.weeklyReportEnabled) ...[
        _labeledRow(
          'Vào ngày',
          DropdownButton<int>(
            value: _draft.weeklyReportDayOfWeek,
            underline: const SizedBox.shrink(),
            items: List.generate(
                7,
                (i) => DropdownMenuItem(
                    value: i, child: Text(days[i]))),
            onChanged: (v) => v != null
                ? _set(_draft.copyWith(weeklyReportDayOfWeek: v))
                : null,
          ),
        ),
        _labeledRow(
          'Lúc',
          GestureDetector(
            onTap: () async {
              final t = await _pickTime(context,
                  hour: _draft.weeklyReportHour);
              if (t != null) {
                _set(_draft.copyWith(weeklyReportHour: t.hour));
              }
            },
            child: _timeChip(_fmtHm(_draft.weeklyReportHour, 0)),
          ),
        ),
      ],
    ]);
  }

  Widget _timeChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(label,
          style: AppTextStyles.bodySm.copyWith(
            color: AppColors.blossom,
            fontWeight: FontWeight.w700,
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
                  child: Text('Preset nhanh', style: AppTextStyles.label),
                ),
                _presetPanel(),
                const SizedBox(height: AppSpacing.md),
                _feedingSection(),
                _pumpSection(),
                _sleepSection(),
                _vaccineSection(),
                _milkStashSection(),
                _quietHoursSection(),
                _weeklyReportSection(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      OutlinedButton(
                        onPressed: _reset,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.muted,
                          side: BorderSide(color: AppColors.muted),
                          minimumSize:
                              const Size(double.infinity, 48),
                        ),
                        child: const Text('Khôi phục mặc định'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientHome,
                          borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg),
                        ),
                        child: ElevatedButton(
                          onPressed: _dirty ? _save : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: AppColors.white,
                            minimumSize:
                                const Size(double.infinity, 48),
                          ),
                          child: const Text('Lưu thay đổi'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
