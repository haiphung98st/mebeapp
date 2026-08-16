import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/who_growth_data.dart';

class WhoArcChart extends StatefulWidget {
  const WhoArcChart({
    super.key,
    required this.metric,
    required this.value,
    required this.percentile,
    required this.ageMonths,
  });

  final GrowthMetric metric;
  final double value;
  final int percentile;
  final double ageMonths;

  @override
  State<WhoArcChart> createState() => _WhoArcChartState();
}

class _WhoArcChartState extends State<WhoArcChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(WhoArcChart old) {
    super.didUpdateWidget(old);
    if (old.percentile != widget.percentile) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) => CustomPaint(
        painter: _ArcPainter(
          percentile: widget.percentile,
          animationValue: _animation.value,
        ),
        child: SizedBox(
          width: 200,
          height: 120,
          child: Align(
            alignment: const Alignment(0, 0.8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'P${widget.percentile}',
                  style: AppTextStyles.headingLg.copyWith(
                    color: _percentileColor(widget.percentile),
                    fontSize: 24,
                  ),
                ),
                Text(
                  _percentileLabel(widget.percentile),
                  style: AppTextStyles.bodySm.copyWith(
                    color: _percentileColor(widget.percentile),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _percentileColor(int p) {
    if (p < 3 || p > 97) return AppColors.error;
    if (p < 15 || p > 85) return AppColors.warning;
    return AppColors.success;
  }

  String _percentileLabel(int p) {
    if (p < 3) return 'Thấp hơn P3';
    if (p < 15) return 'Dưới trung bình';
    if (p <= 85) return 'Bình thường';
    if (p <= 97) return 'Trên trung bình';
    return 'Cao hơn P97';
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter({required this.percentile, required this.animationValue});

  final int percentile;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height * 0.92;
    final radius = size.width * 0.44;
    const strokeWidth = 14.0;

    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    void drawArc(double from, double to, Color color) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = color;
      final start = startAngle + sweepAngle * from;
      final sweep = sweepAngle * (to - from);
      canvas.drawArc(rect, start, sweep, false, paint);
    }

    // Draw zones: P0–3 red, P3–15 orange, P15–85 green, P85–97 orange, P97–100 red
    drawArc(0.00, 0.03, AppColors.error.withOpacity(0.3));
    drawArc(0.03, 0.15, AppColors.warning.withOpacity(0.3));
    drawArc(0.15, 0.85, AppColors.success.withOpacity(0.25));
    drawArc(0.85, 0.97, AppColors.warning.withOpacity(0.3));
    drawArc(0.97, 1.00, AppColors.error.withOpacity(0.3));

    // Draw zone outlines as ticks at P3/P15/P50/P85/P97
    final tickPaint = Paint()
      ..color = AppColors.muted.withOpacity(0.4)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (final p in [3, 15, 50, 85, 97]) {
      final angle = math.pi + sweepAngle * p / 100;
      final innerR = radius - strokeWidth / 2 - 2;
      final outerR = radius + strokeWidth / 2 + 2;
      final cos = math.cos(angle);
      final sin = math.sin(angle);
      canvas.drawLine(
        Offset(cx + innerR * cos, cy + innerR * sin),
        Offset(cx + outerR * cos, cy + outerR * sin),
        tickPaint,
      );
    }

    // Animated needle
    final animatedPct = (percentile / 100) * animationValue;
    final needleAngle = math.pi + sweepAngle * animatedPct;
    final needleLength = radius - strokeWidth / 2;
    final needleColor = _colorForPct(animatedPct * 100);

    final needlePaint = Paint()
      ..color = needleColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, cy),
      Offset(
        cx + needleLength * math.cos(needleAngle),
        cy + needleLength * math.sin(needleAngle),
      ),
      needlePaint,
    );

    // Needle pivot circle
    canvas.drawCircle(
      Offset(cx, cy),
      5,
      Paint()..color = needleColor,
    );

    // P label ticks text at P3/P50/P97
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (final (p, label) in [(3, 'P3'), (50, 'P50'), (97, 'P97')]) {
      final angle = math.pi + sweepAngle * p / 100;
      final labelR = radius + strokeWidth / 2 + 14;
      textPainter.text = TextSpan(
        text: label,
        style: const TextStyle(
          color: Color(0xFFB899AC),
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout();
      final pos = Offset(
        cx + labelR * math.cos(angle) - textPainter.width / 2,
        cy + labelR * math.sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    }
  }

  Color _colorForPct(double p) {
    if (p < 3 || p > 97) return AppColors.error;
    if (p < 15 || p > 85) return AppColors.warning;
    return AppColors.success;
  }

  @override
  bool shouldRepaint(_ArcPainter old) =>
      old.percentile != percentile || old.animationValue != animationValue;
}

class WhoArcChartCard extends StatelessWidget {
  const WhoArcChartCard({
    super.key,
    required this.metric,
    required this.value,
    required this.percentile,
    required this.ageMonths,
  });

  final GrowthMetric metric;
  final double value;
  final int percentile;
  final double ageMonths;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.mint.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                growthMetricIcon(metric),
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Text(
                growthMetricLabel(metric),
                style: AppTextStyles.bodyLg.copyWith(color: AppColors.ink),
              ),
              const Spacer(),
              Text(
                '${value.toStringAsFixed(metric == GrowthMetric.weight ? 2 : 1)} ${growthMetricUnit(metric)}',
                style: AppTextStyles.headingSm.copyWith(
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          WhoArcChart(
            metric: metric,
            value: value,
            percentile: percentile,
            ageMonths: ageMonths,
          ),
          const SizedBox(height: 4),
          _WhoReferenceRow(metric: metric, ageMonths: ageMonths),
        ],
      ),
    );
  }
}

class _WhoReferenceRow extends StatelessWidget {
  const _WhoReferenceRow({required this.metric, required this.ageMonths});
  final GrowthMetric metric;
  final double ageMonths;

  @override
  Widget build(BuildContext context) {
    final p3 = WhoGrowthStandard.p3(metric, ageMonths);
    final p50 = WhoGrowthStandard.p50(metric, ageMonths);
    final p97 = WhoGrowthStandard.p97(metric, ageMonths);
    final unit = growthMetricUnit(metric);
    final isWeight = metric == GrowthMetric.weight;

    String fmt(double v) => v.toStringAsFixed(isWeight ? 1 : 0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _RefLabel('P3', '${fmt(p3)} $unit', AppColors.error),
        _RefLabel('P50', '${fmt(p50)} $unit', AppColors.success),
        _RefLabel('P97', '${fmt(p97)} $unit', AppColors.warning),
      ],
    );
  }
}

class _RefLabel extends StatelessWidget {
  const _RefLabel(this.label, this.value, this.color);
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF7A4D6A),
          ),
        ),
      ],
    );
  }
}
