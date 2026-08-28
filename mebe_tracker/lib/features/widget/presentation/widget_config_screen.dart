import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../widget_provider.dart';

// Mirrors the native widgets' own palette (ios/MeBeWidget/MeBeWidget.swift,
// android .../widget/MeBeWidget.kt) so the in-app preview matches what
// actually renders on the home screen, not the main app's brighter theme.
class _WidgetColors {
  static const background = Color(0xFFFFF0F6);
  static const primary = Color(0xFF9E5E94);
  static const text = Color(0xFF3D1A35);
  static const subtext = Color(0xFF7A4D6A);
  static const accentBlue = Color(0xFF6BAEE8);
  static const accentGreen = Color(0xFF6BC299);
  static const accentPink = Color(0xFFF5ABC2);
}

enum _PreviewSize { small, medium, large }

String _timeAgo(DateTime? time) {
  if (time == null) return '--';
  final mins = DateTime.now().difference(time).inMinutes;
  if (mins < 60) return '$mins phút trước';
  return '${mins ~/ 60} giờ trước';
}

String _sleepLabel(int minutes) {
  if (minutes == 0) return '--';
  if (minutes < 60) return '${minutes}p';
  final h = minutes ~/ 60;
  final m = minutes % 60;
  return m > 0 ? '${h}h${m}p' : '${h}h';
}

String _feedingIcon(String type) {
  switch (type) {
    case 'breastLeft':
    case 'breastRight':
      return '🤱';
    case 'bottle':
      return '🍼';
    default:
      return '🥛';
  }
}

class WidgetConfigScreen extends ConsumerStatefulWidget {
  const WidgetConfigScreen({super.key});

  @override
  ConsumerState<WidgetConfigScreen> createState() => _WidgetConfigScreenState();
}

class _WidgetConfigScreenState extends ConsumerState<WidgetConfigScreen> {
  _PreviewSize _size = _PreviewSize.medium;

  Future<void> _forceUpdate() async {
    ref.invalidate(widgetDataProvider);
    await ref.read(widgetDataProvider.future);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Widget đã được cập nhật ✓')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(widgetDataProvider).value ?? WidgetData.empty();
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Tiện ích màn hình'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text('Xem trước', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          SegmentedButton<_PreviewSize>(
            segments: const [
              ButtonSegment(value: _PreviewSize.small, label: Text('Nhỏ')),
              ButtonSegment(value: _PreviewSize.medium, label: Text('Vừa')),
              ButtonSegment(value: _PreviewSize.large, label: Text('Lớn')),
            ],
            selected: {_size},
            onSelectionChanged: (s) => setState(() => _size = s.first),
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(child: _WidgetPreview(size: _size, data: data, isPremium: isPremium)),
          if (!isPremium) ...[
            const SizedBox(height: AppSpacing.sm),
            Center(
              child: Text(
                'Widget đầy đủ thông tin dành cho Premium',
                style: AppTextStyles.bodySm.copyWith(color: AppColors.muted),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          _InstallInstructions(),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _forceUpdate,
              icon: const Icon(Icons.refresh),
              label: const Text('Cập nhật widget ngay'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WidgetPreview extends StatelessWidget {
  const _WidgetPreview({required this.size, required this.data, required this.isPremium});

  final _PreviewSize size;
  final WidgetData data;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    switch (size) {
      case _PreviewSize.small:
        return _PreviewShell(
          width: 155,
          height: 155,
          child: isPremium ? _SmallPremium(data: data) : const _PreviewUpsell(fontScale: 1),
        );
      case _PreviewSize.medium:
        return _PreviewShell(
          width: 329,
          height: 155,
          child: isPremium ? _MediumPremium(data: data) : const _PreviewUpsell(fontScale: 1.2),
        );
      case _PreviewSize.large:
        return _PreviewShell(
          width: 329,
          height: 345,
          child: isPremium ? _LargePremium(data: data) : const _PreviewUpsell(fontScale: 1.4),
        );
    }
  }
}

class _PreviewShell extends StatelessWidget {
  const _PreviewShell({required this.width, required this.height, required this.child});

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _WidgetColors.background,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 14, offset: const Offset(0, 5)),
        ],
      ),
      child: child,
    );
  }
}

class _PreviewUpsell extends StatelessWidget {
  const _PreviewUpsell({required this.fontScale});

  final double fontScale;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🐰', style: TextStyle(fontSize: 28 * fontScale)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Nâng cấp Premium\nđể xem chi tiết ✨',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10 * fontScale, color: _WidgetColors.subtext),
            ),
          ],
        ),
      ),
    );
  }
}

class _SmallPremium extends StatelessWidget {
  const _SmallPremium({required this.data});

  final WidgetData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.babyName.isEmpty ? 'MeBé' : data.babyName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _WidgetColors.text),
          ),
          const SizedBox(height: 4),
          if (data.isSleeping)
            Text('🌙 Ngủ', style: TextStyle(fontSize: 11, color: _WidgetColors.accentBlue))
          else
            Text(
              '${_feedingIcon(data.lastFeedingType)} Bú ${_timeAgo(data.lastFeedingTime)}',
              style: const TextStyle(fontSize: 11, color: _WidgetColors.subtext),
            ),
          const Spacer(),
          Row(
            children: [
              _StatChip('🤱 ${data.todayFeedingCount}'),
              const SizedBox(width: 4),
              _StatChip('🌸 ${data.todayDiaperCount}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _WidgetColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, color: _WidgetColors.text)),
    );
  }
}

class _MediumPremium extends StatelessWidget {
  const _MediumPremium({required this.data});

  final WidgetData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.babyName.isEmpty ? 'MeBé' : data.babyName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _WidgetColors.text),
                ),
                const SizedBox(height: 6),
                if (data.isSleeping)
                  Text('🌙 Đang ngủ', style: TextStyle(fontSize: 12, color: _WidgetColors.accentBlue))
                else
                  Text(
                    '${_feedingIcon(data.lastFeedingType)} Bú gần nhất\n${_timeAgo(data.lastFeedingTime)}',
                    style: const TextStyle(fontSize: 11, color: _WidgetColors.text),
                  ),
              ],
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _MiniStatRow('🤱', '${data.todayFeedingCount} cữ'),
                  const SizedBox(height: 4),
                  _MiniStatRow('🌙', _sleepLabel(data.todaySleepMinutes)),
                  const SizedBox(height: 4),
                  _MiniStatRow('🌸', '${data.todayDiaperCount} tã'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatRow extends StatelessWidget {
  const _MiniStatRow(this.icon, this.label);

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: _WidgetColors.text)),
      ],
    );
  }
}

class _LargePremium extends StatelessWidget {
  const _LargePremium({required this.data});

  final WidgetData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '🐰 ${data.babyName.isEmpty ? 'MeBé' : data.babyName}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _WidgetColors.text),
                ),
              ),
              Text('${data.babyAgeWeeks} tuần', style: const TextStyle(fontSize: 11, color: _WidgetColors.subtext)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          if (data.isSleeping)
            Text('🌙 Đang ngủ', style: TextStyle(fontSize: 13, color: _WidgetColors.accentBlue))
          else ...[
            Text(
              '${_feedingIcon(data.lastFeedingType)} Bú ${_timeAgo(data.lastFeedingTime)}',
              style: const TextStyle(fontSize: 13, color: _WidgetColors.text),
            ),
            if (data.nextFeedingTime != null)
              Text(
                '⏰ Bú tiếp: ${_timeAgo(data.nextFeedingTime)}',
                style: const TextStyle(fontSize: 11, color: _WidgetColors.subtext),
              ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _LargeStatCard('🤱', 'Bú', '${data.todayFeedingCount} cữ', _WidgetColors.accentPink),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LargeStatCard('🌙', 'Ngủ', _sleepLabel(data.todaySleepMinutes), _WidgetColors.accentBlue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _LargeStatCard('🌸', 'Thay tã', '${data.todayDiaperCount} lần', _WidgetColors.accentGreen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _LargeStatCard(
                  '🥛',
                  'Hút sữa',
                  data.todayPumpMl > 0 ? '${data.todayPumpMl.toInt()}ml' : '--',
                  _WidgetColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LargeStatCard extends StatelessWidget {
  const _LargeStatCard(this.icon, this.label, this.value, this.color);

  final String icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 10, color: _WidgetColors.subtext)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _InstallInstructions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.sm),
            child: Row(
              children: [
                Text('Cách thêm widget', style: AppTextStyles.headingSm),
              ],
            ),
          ),
          const ExpansionTile(
            title: Text('📱 iPhone / iPad'),
            childrenPadding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            children: [
              _Step(1, 'Nhấn giữ màn hình chính cho đến khi icon rung'),
              _Step(2, 'Nhấn nút + ở góc trên trái'),
              _Step(3, 'Tìm kiếm "MeBé"'),
              _Step(4, 'Chọn kích thước và nhấn Thêm tiện ích'),
            ],
          ),
          const ExpansionTile(
            title: Text('🤖 Android'),
            childrenPadding: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
            children: [
              _Step(1, 'Nhấn giữ màn hình chính'),
              _Step(2, 'Chọn "Tiện ích" (Widgets)'),
              _Step(3, 'Tìm MeBé trong danh sách'),
              _Step(4, 'Kéo thả vào màn hình'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.number, this.text);

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.blush, shape: BoxShape.circle),
            child: Text('$number', style: AppTextStyles.label.copyWith(color: AppColors.blossom)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodyMd)),
        ],
      ),
    );
  }
}
