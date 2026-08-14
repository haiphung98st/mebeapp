import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/app_toast.dart';
import '../admin_utils.dart';
import '../../data/admin_provider.dart';

Future<void> showGrantBottomSheet(
  BuildContext context, {
  required String uid,
  required String displayName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _GrantBottomSheet(uid: uid, displayName: displayName),
  );
}

class _GrantBottomSheet extends ConsumerStatefulWidget {
  const _GrantBottomSheet({required this.uid, required this.displayName});
  final String uid;
  final String displayName;

  @override
  ConsumerState<_GrantBottomSheet> createState() => _GrantBottomSheetState();
}

class _GrantBottomSheetState extends ConsumerState<_GrantBottomSheet> {
  int _selectedDurationIndex = 1;
  String _selectedReason = kGrantReasons.first;
  final _noteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _grant() async {
    setState(() => _isLoading = true);
    try {
      final duration = kGrantDurations[_selectedDurationIndex];
      await ref.read(adminNotifierProvider.notifier).grantPremium(
            uid: widget.uid,
            durationDays: duration.days,
            reason: _selectedReason,
            note: _noteController.text.trim(),
          );
      if (mounted) {
        Navigator.of(context).pop();
        AppToast.success(context, 'Đã cấp Premium ${duration.label} cho ${widget.displayName}');
      }
    } catch (e) {
      if (mounted) AppToast.error(context, 'Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Color(0xFF2ED573), size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Cấp Premium cho ${widget.displayName}',
                        style: theme.textTheme.titleMedium),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(16),
                children: [
                  Text('Thời hạn', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(kGrantDurations.length, (i) {
                      final d = kGrantDurations[i];
                      final selected = _selectedDurationIndex == i;
                      return ChoiceChip(
                        label: Text(d.label),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedDurationIndex = i),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Text('Lý do', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedReason,
                    dropdownColor: theme.colorScheme.surface,
                    items: kGrantReasons
                        .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedReason = v!),
                    decoration: const InputDecoration(labelText: 'Lý do cấp'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ghi chú (tuỳ chọn)',
                      hintText: 'Thông tin thêm về lần cấp này...',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _grant,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : Text('Cấp ${kGrantDurations[_selectedDurationIndex].label}'),
                    ),
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
