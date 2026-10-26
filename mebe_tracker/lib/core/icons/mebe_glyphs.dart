import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Small single-tone line glyphs MeBé draws itself instead of using
/// Material icons, for compact UI contexts (buttons, list tiles, app
/// bars) where the full gradient-illustration [MeBeIcon] would be too
/// heavy. Rounded caps/joins throughout to match the app's soft visual
/// language.
enum MeBeGlyphType {
  close,
  chevronRight,
  chevronLeft,
  add,
  addCircleOutline,
  deleteOutline,
  delete,
  checkCircle,
  check,
  lockOutline,
  editOutlined,
  arrowBack,
  share,
  stop,
  starOutline,
  star,
  remove,
  removeCircleOutline,
  expandMore,
  expandLess,
  cameraAlt,
  calendarToday,
  search,
  refresh,
  personOutline,
  pause,
  playArrow,
  warningAmber,
  infoOutline,
  history,
  emailOutlined,
  visibilityOutlined,
  visibilityOffOutlined,
  people,
  settingsGear,
  unlockOutline,
  trendUp,
  trendDown,
  scaleWeight,
  rulerLength,
  headCircle,
  moonNight,
  nursingHeart,
  diaperSmall,
}

/// A single-tone line-drawn UI glyph, drawn with [CustomPainter] on a
/// 24×24 viewport (scaled to [size]).
class MeBeGlyph extends StatelessWidget {
  const MeBeGlyph(this.type, {super.key, this.size = 20, this.color, this.strokeWidth = 1.8});

  final MeBeGlyphType type;
  final double size;
  final Color? color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MeBeGlyphPainter(
          type: type,
          color: color ?? IconTheme.of(context).color ?? Colors.black87,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}

class _MeBeGlyphPainter extends CustomPainter {
  _MeBeGlyphPainter({required this.type, required this.color, required this.strokeWidth});

  final MeBeGlyphType type;
  final Color color;
  final double strokeWidth;

  Paint get _stroke => Paint()
    ..color = color
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  Paint get _fillPaint => Paint()..color = color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    switch (type) {
      case MeBeGlyphType.close:
        canvas.drawLine(const Offset(6, 6), const Offset(18, 18), _stroke);
        canvas.drawLine(const Offset(18, 6), const Offset(6, 18), _stroke);
      case MeBeGlyphType.chevronRight:
        canvas.drawPath(Path()..moveTo(9, 5)..lineTo(16, 12)..lineTo(9, 19), _stroke);
      case MeBeGlyphType.chevronLeft:
        canvas.drawPath(Path()..moveTo(15, 5)..lineTo(8, 12)..lineTo(15, 19), _stroke);
      case MeBeGlyphType.add:
        canvas.drawLine(const Offset(12, 5), const Offset(12, 19), _stroke);
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), _stroke);
      case MeBeGlyphType.addCircleOutline:
        canvas.drawCircle(const Offset(12, 12), 8.5, _stroke);
        canvas.drawLine(const Offset(12, 8), const Offset(12, 16), _stroke);
        canvas.drawLine(const Offset(8, 12), const Offset(16, 12), _stroke);
      case MeBeGlyphType.remove:
        canvas.drawLine(const Offset(5, 12), const Offset(19, 12), _stroke);
      case MeBeGlyphType.removeCircleOutline:
        canvas.drawCircle(const Offset(12, 12), 8.5, _stroke);
        canvas.drawLine(const Offset(8, 12), const Offset(16, 12), _stroke);
      case MeBeGlyphType.deleteOutline:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 7, 12, 13), const Radius.circular(2)), _stroke);
        canvas.drawLine(const Offset(4, 7), const Offset(20, 7), _stroke);
        canvas.drawLine(const Offset(9.5, 4), const Offset(14.5, 4), _stroke);
        for (final x in [9.5, 12.0, 14.5]) {
          canvas.drawLine(Offset(x, 10), Offset(x, 17), _stroke);
        }
      case MeBeGlyphType.delete:
        final body = RRect.fromRectAndRadius(const Rect.fromLTWH(6, 7, 12, 13), const Radius.circular(2));
        canvas.drawRRect(body, _fillPaint);
        canvas.drawLine(const Offset(4, 7), const Offset(20, 7), _stroke);
        canvas.drawLine(const Offset(9.5, 4), const Offset(14.5, 4), _stroke);
      case MeBeGlyphType.checkCircle:
        canvas.drawCircle(const Offset(12, 12), 8.5, _stroke);
        canvas.drawPath(Path()..moveTo(8, 12.5)..lineTo(11, 15.5)..lineTo(16, 9), _stroke);
      case MeBeGlyphType.check:
        canvas.drawPath(Path()..moveTo(5, 12.5)..lineTo(10, 17.5)..lineTo(19, 6.5), _stroke);
      case MeBeGlyphType.lockOutline:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(5, 11, 14, 10), const Radius.circular(2.5)), _stroke);
        canvas.drawArc(const Rect.fromLTWH(7.5, 4, 9, 12), 3.4, 2.6, false, _stroke);
        canvas.drawCircle(const Offset(12, 16), 1.4, _fillPaint);
      case MeBeGlyphType.editOutlined:
        canvas.save();
        canvas.translate(12, 12);
        canvas.rotate(-0.785398);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-2, -8.5, 4, 12), const Radius.circular(1.5)), _stroke);
        canvas.drawPath(Path()..moveTo(-2, 3.5)..lineTo(2, 3.5)..lineTo(0, 8)..close(), _fillPaint);
        canvas.restore();
      case MeBeGlyphType.arrowBack:
        canvas.drawLine(const Offset(19, 12), const Offset(5, 12), _stroke);
        canvas.drawPath(Path()..moveTo(11, 6)..lineTo(5, 12)..lineTo(11, 18), _stroke);
      case MeBeGlyphType.share:
        for (final c in [const Offset(18, 6), const Offset(18, 18), const Offset(6, 12)]) {
          canvas.drawCircle(c, 2.6, _stroke);
        }
        canvas.drawLine(const Offset(8.3, 10.8), const Offset(15.7, 7.2), _stroke);
        canvas.drawLine(const Offset(8.3, 13.2), const Offset(15.7, 16.8), _stroke);
      case MeBeGlyphType.stop:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 6, 12, 12), const Radius.circular(2.5)), _fillPaint);
      case MeBeGlyphType.starOutline:
        canvas.drawPath(_starPath(), _stroke);
      case MeBeGlyphType.star:
        canvas.drawPath(_starPath(), _fillPaint);
      case MeBeGlyphType.expandMore:
        canvas.drawPath(Path()..moveTo(5, 9)..lineTo(12, 16)..lineTo(19, 9), _stroke);
      case MeBeGlyphType.expandLess:
        canvas.drawPath(Path()..moveTo(5, 15)..lineTo(12, 8)..lineTo(19, 15), _stroke);
      case MeBeGlyphType.cameraAlt:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4, 7.5, 16, 12), const Radius.circular(2.5)), _stroke);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(9, 4.5, 6, 3.4), const Radius.circular(1.2)), _stroke);
        canvas.drawCircle(const Offset(12, 13.5), 3.6, _stroke);
      case MeBeGlyphType.calendarToday:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4, 5.5, 16, 14), const Radius.circular(2.5)), _stroke);
        canvas.drawLine(const Offset(4, 10), const Offset(20, 10), _stroke);
        canvas.drawLine(const Offset(8, 3.5), const Offset(8, 7), _stroke);
        canvas.drawLine(const Offset(16, 3.5), const Offset(16, 7), _stroke);
      case MeBeGlyphType.search:
        canvas.drawCircle(const Offset(10.5, 10.5), 6, _stroke);
        canvas.drawLine(const Offset(15, 15), const Offset(19.5, 19.5), _stroke);
      case MeBeGlyphType.refresh:
        canvas.drawArc(const Rect.fromLTWH(5, 5, 14, 14), -1.2, 4.6, false, _stroke);
        canvas.drawPath(Path()..moveTo(19, 5)..lineTo(19, 9.5)..lineTo(14.5, 9.5)..close(), _fillPaint);
      case MeBeGlyphType.personOutline:
        canvas.drawCircle(const Offset(12, 8.5), 3.8, _stroke);
        canvas.drawPath(Path()..moveTo(5.5, 19.5)..cubicTo(5.5, 14.5, 18.5, 14.5, 18.5, 19.5), _stroke);
      case MeBeGlyphType.people:
        canvas.drawCircle(const Offset(9, 8.5), 3.2, _stroke);
        canvas.drawPath(Path()..moveTo(3.5, 19)..cubicTo(3.5, 14.8, 14.5, 14.8, 14.5, 19), _stroke);
        canvas.drawCircle(const Offset(17, 9), 2.6, _stroke);
        canvas.drawPath(Path()..moveTo(15, 14)..cubicTo(18.5, 14, 20.5, 16, 20.5, 19), _stroke);
      case MeBeGlyphType.pause:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(7, 5, 3.4, 14), const Radius.circular(1.4)), _fillPaint);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(13.6, 5, 3.4, 14), const Radius.circular(1.4)), _fillPaint);
      case MeBeGlyphType.playArrow:
        canvas.drawPath(Path()..moveTo(7, 4.5)..lineTo(19, 12)..lineTo(7, 19.5)..close(), _fillPaint);
      case MeBeGlyphType.warningAmber:
        canvas.drawPath(Path()..moveTo(12, 4)..lineTo(21, 20)..lineTo(3, 20)..close(), _stroke);
        canvas.drawLine(const Offset(12, 10), const Offset(12, 15), _stroke);
        canvas.drawCircle(const Offset(12, 17.5), 0.9, _fillPaint);
      case MeBeGlyphType.infoOutline:
        canvas.drawCircle(const Offset(12, 12), 8.5, _stroke);
        canvas.drawLine(const Offset(12, 11), const Offset(12, 16.5), _stroke);
        canvas.drawCircle(const Offset(12, 7.5), 0.9, _fillPaint);
      case MeBeGlyphType.history:
        canvas.drawArc(const Rect.fromLTWH(4, 4, 16, 16), 0.6, 5.0, false, _stroke);
        canvas.drawPath(Path()..moveTo(4.5, 4)..lineTo(4.5, 8.5)..lineTo(9, 8.5)..close(), _fillPaint);
        canvas.drawLine(const Offset(12, 8), const Offset(12, 12.3), _stroke);
        canvas.drawLine(const Offset(12, 12.3), const Offset(15, 14), _stroke);
      case MeBeGlyphType.emailOutlined:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(3.5, 5.5, 17, 13), const Radius.circular(2)), _stroke);
        canvas.drawPath(Path()..moveTo(4, 6.5)..lineTo(12, 13)..lineTo(20, 6.5), _stroke);
      case MeBeGlyphType.visibilityOutlined:
        canvas.drawPath(Path()..moveTo(2.5, 12)..cubicTo(5, 6.5, 19, 6.5, 21.5, 12)..cubicTo(19, 17.5, 5, 17.5, 2.5, 12)..close(), _stroke);
        canvas.drawCircle(const Offset(12, 12), 3, _stroke);
      case MeBeGlyphType.visibilityOffOutlined:
        canvas.drawPath(Path()..moveTo(2.5, 12)..cubicTo(5, 6.5, 19, 6.5, 21.5, 12)..cubicTo(19, 17.5, 5, 17.5, 2.5, 12)..close(), _stroke);
        canvas.drawCircle(const Offset(12, 12), 3, _stroke);
        canvas.drawLine(const Offset(4, 4), const Offset(20, 20), _stroke);
      case MeBeGlyphType.settingsGear:
        canvas.drawCircle(const Offset(12, 12), 3.4, _stroke);
        for (var i = 0; i < 6; i++) {
          final angle = i * math.pi / 3;
          final inner = Offset(12 + 6.5 * math.cos(angle), 12 + 6.5 * math.sin(angle));
          final outer = Offset(12 + 9 * math.cos(angle), 12 + 9 * math.sin(angle));
          canvas.drawLine(inner, outer, _stroke);
        }
      case MeBeGlyphType.unlockOutline:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(5, 11, 14, 10), const Radius.circular(2.5)), _stroke);
        canvas.drawArc(const Rect.fromLTWH(6.5, 3, 9, 12), math.pi * 0.9, 1.7, false, _stroke);
        canvas.drawCircle(const Offset(12, 16), 1.4, _fillPaint);
      case MeBeGlyphType.trendUp:
        canvas.drawPath(Path()..moveTo(4, 16)..lineTo(10, 10)..lineTo(14, 14)..lineTo(20, 6), _stroke);
        canvas.drawPath(Path()..moveTo(14, 6)..lineTo(20, 6)..lineTo(20, 12), _stroke);
      case MeBeGlyphType.trendDown:
        canvas.drawPath(Path()..moveTo(4, 8)..lineTo(10, 14)..lineTo(14, 10)..lineTo(20, 18), _stroke);
        canvas.drawPath(Path()..moveTo(14, 18)..lineTo(20, 18)..lineTo(20, 12), _stroke);
      case MeBeGlyphType.scaleWeight:
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(6, 9, 12, 11), const Radius.circular(3)), _stroke);
        canvas.drawArc(const Rect.fromLTWH(9, 4, 6, 8), math.pi, math.pi, false, _stroke);
      case MeBeGlyphType.rulerLength:
        canvas.save();
        canvas.translate(12, 12);
        canvas.rotate(-math.pi / 4);
        canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-10, -3.5, 20, 7), const Radius.circular(1.5)), _stroke);
        for (final x in [-6.0, -2.0, 2.0, 6.0]) {
          canvas.drawLine(Offset(x, -3.5), Offset(x, 0), _stroke);
        }
        canvas.restore();
      case MeBeGlyphType.headCircle:
        canvas.drawCircle(const Offset(12, 13), 7.5, _stroke);
        canvas.drawLine(const Offset(17.3, 18.3), const Offset(20, 21), _stroke);
      case MeBeGlyphType.moonNight:
        final full = Path()..addOval(const Rect.fromLTWH(4, 4, 16, 16));
        final cut = Path()..addOval(const Rect.fromLTWH(8, 2, 13, 13));
        canvas.drawPath(Path.combine(PathOperation.difference, full, cut), _fillPaint);
      case MeBeGlyphType.nursingHeart:
        canvas.drawCircle(const Offset(12, 9.5), 5.5, _stroke);
        final heart = Path()
          ..moveTo(12, 20)
          ..cubicTo(6, 16.5, 7.5, 12, 12, 14.5)
          ..cubicTo(16.5, 12, 18, 16.5, 12, 20)
          ..close();
        canvas.drawPath(heart, _fillPaint);
      case MeBeGlyphType.diaperSmall:
        canvas.drawPath(
          Path()
            ..moveTo(5, 9)
            ..lineTo(19, 9)
            ..cubicTo(20.5, 11, 20.5, 16, 19, 18.5)
            ..lineTo(12, 18.5)
            ..lineTo(5, 18.5)
            ..cubicTo(3.5, 16, 3.5, 11, 5, 9)
            ..close(),
          _stroke,
        );
    }
    canvas.restore();
  }

  Path _starPath() {
    final path = Path();
    const cx = 12.0, cy = 12.0, outer = 9.0, inner = 3.6;
    for (var i = 0; i < 5; i++) {
      final oa = (i * 72 - 90) * math.pi / 180;
      final ia = ((i * 72 + 36) - 90) * math.pi / 180;
      final ox = cx + outer * math.cos(oa), oy = cy + outer * math.sin(oa);
      final ix = cx + inner * math.cos(ia), iy = cy + inner * math.sin(ia);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant _MeBeGlyphPainter old) =>
      old.type != type || old.color != color || old.strokeWidth != strokeWidth;
}
