import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../../shared/models/notification_config.dart';

class TimeOfDayListTile extends StatefulWidget {
  const TimeOfDayListTile({
    super.key,
    required this.config,
    required this.onChanged,
    required this.onDelete,
  });

  final TimeOfDayConfig config;
  final ValueChanged<TimeOfDayConfig> onChanged;
  final VoidCallback onDelete;

  @override
  State<TimeOfDayListTile> createState() => _TimeOfDayListTileState();
}

class _TimeOfDayListTileState extends State<TimeOfDayListTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  bool _editingLabel = false;
  late TextEditingController _labelCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _labelCtrl =
        TextEditingController(text: widget.config.label ?? '');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: widget.config.hour, minute: widget.config.minute),
    );
    if (picked != null) {
      widget.onChanged(widget.config
          .copyWith(hour: picked.hour, minute: picked.minute));
    }
  }

  void _delete() {
    _ctrl.reverse().then((_) => widget.onDelete());
  }

  String _fmt(int h, int m) =>
      '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.powder,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Switch(
              value: widget.config.enabled,
              onChanged: (v) =>
                  widget.onChanged(widget.config.copyWith(enabled: v)),
              activeColor: AppColors.blossom,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: _editingLabel
                  ? TextField(
                      controller: _labelCtrl,
                      autofocus: true,
                      style: AppTextStyles.bodySm,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Nhãn (ví dụ: Sáng sớm)',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (v) {
                        widget.onChanged(widget.config.copyWith(label: v.isEmpty ? null : v));
                        setState(() => _editingLabel = false);
                      },
                    )
                  : GestureDetector(
                      onTap: () => setState(() => _editingLabel = true),
                      child: Text(
                        widget.config.label?.isNotEmpty == true
                            ? widget.config.label!
                            : 'Chạm để thêm nhãn',
                        style: AppTextStyles.bodySm.copyWith(
                          color: widget.config.label?.isNotEmpty == true
                              ? AppColors.body
                              : AppColors.muted,
                        ),
                      ),
                    ),
            ),
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                decoration: BoxDecoration(
                  color: AppColors.blush,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  _fmt(widget.config.hour, widget.config.minute),
                  style: AppTextStyles.bodySm.copyWith(
                    color: AppColors.blossom,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline,
                  color: AppColors.muted, size: 20),
              onPressed: _delete,
              tooltip: 'Xóa',
            ),
          ],
        ),
      ),
    );
  }
}
