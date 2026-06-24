import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

/// Circular progress ring used for the "today summary" stats (feeding,
/// sleep, diaper, pump) on the Home screen.
class RingChart extends StatelessWidget {
  const RingChart({
    super.key,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.trackColor,
    required this.label,
    this.size = 56,
    this.valueText,
    this.valueStyle,
    this.backgroundColor,
  });

  final double value;
  final double maxValue;
  final Color color;
  final Color trackColor;
  final String label;
  final double size;
  final String? valueText;
  final TextStyle? valueStyle;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final progress = maxValue <= 0 ? 0.0 : (value / maxValue).clamp(0.0, 1.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor ?? trackColor.withValues(alpha: 0.25),
            shape: BoxShape.circle,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(size, size),
                painter: _RingPainter(
                  progress: progress,
                  color: color,
                  trackColor: trackColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  valueText ?? value.toStringAsFixed(0),
                  style: valueStyle ??
                      AppTextStyles.headingSm.copyWith(fontSize: size * 0.23),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: AppTextStyles.label.copyWith(color: AppColors.muted),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.09;
    final radius = (size.width - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, trackPaint);

    if (progress > 0) {
      final progressPaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * progress,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor;
  }
}
