import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_toast.dart';
import '../../data/admin_provider.dart';
import '../admin_shell.dart';

class AdminConfigScreen extends ConsumerStatefulWidget {
  const AdminConfigScreen({super.key});

  @override
  ConsumerState<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends ConsumerState<AdminConfigScreen> {
  bool _loaded = false;

  bool _maintenanceMode = false;
  final _maintenanceMsgController = TextEditingController();
  final _forceUpdateController = TextEditingController();
  final _bannerController = TextEditingController();
  bool _aiEnabled = true;
  double _aiMonthlyBudget = 50.0;

  bool _isSaving = false;

  @override
  void dispose() {
    _maintenanceMsgController.dispose();
    _forceUpdateController.dispose();
    _bannerController.dispose();
    super.dispose();
  }

  void _loadFromConfig(AppConfig config) {
    if (_loaded) return;
    _loaded = true;
    _maintenanceMode = config.maintenanceMode;
    _maintenanceMsgController.text = config.maintenanceModeMessage;
    _forceUpdateController.text = config.forceUpdateVersion;
    _bannerController.text = config.announcementBanner;
    _aiEnabled = config.aiEnabled;
    _aiMonthlyBudget = config.aiMonthlyBudgetUsd;
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(adminNotifierProvider.notifier).updateConfig({
        'maintenanceMode': _maintenanceMode,
        'maintenanceModeMessage': _maintenanceMsgController.text.trim(),
        'forceUpdateVersion': _forceUpdateController.text.trim(),
        'announcementBanner': _bannerController.text.trim(),
        'aiEnabled': _aiEnabled,
        'aiMonthlyBudgetUsd': _aiMonthlyBudget,
      });
      if (mounted) AppToast.success(context, 'Đã lưu cấu hình');
    } catch (e) {
      if (mounted) AppToast.error(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final configAsync = ref.watch(appConfigProvider);

    configAsync.whenData(_loadFromConfig);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader('Bảo trì hệ thống'),
          _ConfigCard(children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Maintenance Mode'),
              subtitle: const Text('Khoá toàn bộ người dùng (trừ admin)',
                  style: TextStyle(color: AdminColors.textSecondary, fontSize: 12)),
              value: _maintenanceMode,
              onChanged: (v) => setState(() => _maintenanceMode = v),
            ),
            if (_maintenanceMode) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _maintenanceMsgController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Thông báo bảo trì',
                  hintText: 'Hệ thống đang bảo trì...',
                ),
              ),
            ],
          ]),
          const SizedBox(height: 16),
          _SectionHeader('Cập nhật bắt buộc'),
          _ConfigCard(children: [
            TextField(
              controller: _forceUpdateController,
              decoration: const InputDecoration(
                labelText: 'Phiên bản tối thiểu',
                hintText: 'Vd: 2.1.0 (để trống để tắt)',
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _SectionHeader('Thông báo ứng dụng'),
          _ConfigCard(children: [
            TextField(
              controller: _bannerController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Banner thông báo',
                hintText: 'Để trống để ẩn banner',
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _SectionHeader('AI & Chi phí'),
          _ConfigCard(children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('AI Chat'),
              subtitle: const Text('Bật/tắt tính năng Hỏi AI cho toàn bộ app',
                  style: TextStyle(color: AdminColors.textSecondary, fontSize: 12)),
              value: _aiEnabled,
              onChanged: (v) => setState(() => _aiEnabled = v),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 18, color: AdminColors.textSecondary),
                const SizedBox(width: 4),
                Text('Ngân sách AI tháng: \$${_aiMonthlyBudget.toStringAsFixed(0)}',
                    style: theme.textTheme.bodySmall),
              ],
            ),
            Slider(
              value: _aiMonthlyBudget,
              min: 10,
              max: 500,
              divisions: 49,
              label: '\$${_aiMonthlyBudget.toStringAsFixed(0)}',
              activeColor: AdminColors.primary,
              onChanged: (v) => setState(() => _aiMonthlyBudget = v),
            ),
          ]),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Lưu cấu hình', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: AdminColors.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _ConfigCard extends StatelessWidget {
  const _ConfigCard({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdminColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AdminColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}
