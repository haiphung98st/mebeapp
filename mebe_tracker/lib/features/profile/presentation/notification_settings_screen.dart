import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Cài đặt thông báo'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          SwitchListTile(
            title: const Text('Nhắc cho bé bú'),
            value: settings.feedingReminderEnabled,
            onChanged: notifier.setFeedingReminderEnabled,
          ),
          SwitchListTile(
            title: const Text('Nhắc giờ ngủ'),
            value: settings.sleepReminderEnabled,
            onChanged: notifier.setSleepReminderEnabled,
          ),
          SwitchListTile(
            title: const Text('Nhắc sữa sắp hết hạn'),
            value: settings.milkExpiryReminderEnabled,
            onChanged: notifier.setMilkExpiryReminderEnabled,
          ),
          SwitchListTile(
            title: const Text('Nhắc lịch tiêm chủng'),
            value: settings.vaccineReminderEnabled,
            onChanged: notifier.setVaccineReminderEnabled,
          ),
          const Divider(height: AppSpacing.xl),
          SwitchListTile(
            title: const Text('Nhắc hút sữa định kỳ'),
            value: settings.pumpReminderEnabled,
            onChanged: (value) async {
              await notifier.setPumpReminderEnabled(value);
              if (value) {
                await NotificationService.instance.schedulePumpReminder(settings.pumpIntervalHours);
              } else {
                await NotificationService.instance.cancelPumpReminder();
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                Text('Mỗi', style: AppTextStyles.bodyMd),
                const SizedBox(width: AppSpacing.sm),
                DropdownButton<int>(
                  value: settings.pumpIntervalHours,
                  items: const [2, 3, 4]
                      .map((h) => DropdownMenuItem(value: h, child: Text('$h giờ')))
                      .toList(),
                  onChanged: settings.pumpReminderEnabled
                      ? (hours) async {
                          if (hours == null) return;
                          await notifier.setPumpIntervalHours(hours);
                          await NotificationService.instance.schedulePumpReminder(hours);
                        }
                      : null,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              'Tạm dừng nhắc hút sữa từ ${settings.quietHourStart}h đến ${settings.quietHourEnd}h sáng',
              style: AppTextStyles.bodySm,
            ),
          ),
        ],
      ),
    );
  }
}
