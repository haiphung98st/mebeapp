import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Numeric input for manual-entry forms: a centered [TextField] with
/// step +/- buttons on either side, clamped to [min]/[max].
class ManualNumberField extends StatefulWidget {
  const ManualNumberField({
    super.key,
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.onChanged,
    this.decimals = 0,
    this.hint,
  });

  final String label;
  final String unit;
  final double value;
  final double min;
  final double max;
  final double step;
  final int decimals;
  final ValueChanged<double> onChanged;
  final String? hint;

  @override
  State<ManualNumberField> createState() => _ManualNumberFieldState();
}

class _ManualNumberFieldState extends State<ManualNumberField> {
  late final TextEditingController _controller;

  String _format(double v) => widget.decimals == 0 ? v.round().toString() : v.toStringAsFixed(widget.decimals);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: _format(widget.value));
  }

  @override
  void didUpdateWidget(covariant ManualNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only resync the text when the value changed from outside this field
    // (e.g. the +/- buttons or a recalculation elsewhere) — never while the
    // user is actively typing, or the cursor would keep jumping to the start.
    if (oldWidget.value != widget.value && double.tryParse(_controller.text) != widget.value) {
      _controller.text = _format(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _step(double delta) {
    final v = (widget.value + delta).clamp(widget.min, widget.max);
    widget.onChanged(v);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: AppTextStyles.headingSm),
        if (widget.hint != null) ...[
          const SizedBox(height: 2),
          Text(widget.hint!, style: AppTextStyles.bodySm),
        ],
        const SizedBox(height: 8),
        Row(
          children: [
            _StepButton(icon: Icons.remove, onTap: () => _step(-widget.step)),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                keyboardType: TextInputType.numberWithOptions(decimal: widget.decimals > 0),
                inputFormatters: [
                  if (widget.decimals == 0)
                    FilteringTextInputFormatter.digitsOnly
                  else
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                textAlign: TextAlign.center,
                style: AppTextStyles.headingLg.copyWith(color: AppColors.blossom),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.blush),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    borderSide: const BorderSide(color: AppColors.blossom, width: 2),
                  ),
                  filled: true,
                  fillColor: AppColors.powder,
                  suffixText: widget.unit,
                  suffixStyle: AppTextStyles.bodySm,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                onChanged: (s) {
                  final v = double.tryParse(s);
                  if (v != null) widget.onChanged(v.clamp(widget.min, widget.max));
                },
                onSubmitted: (s) {
                  final v = double.tryParse(s) ?? widget.value;
                  final clamped = v.clamp(widget.min, widget.max);
                  widget.onChanged(clamped);
                  _controller.text = _format(clamped);
                },
              ),
            ),
            const SizedBox(width: 10),
            _StepButton(icon: Icons.add, onTap: () => _step(widget.step)),
          ],
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.powder,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: AppColors.blush),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: AppColors.blossom, size: 20),
        ),
      ),
    );
  }
}
