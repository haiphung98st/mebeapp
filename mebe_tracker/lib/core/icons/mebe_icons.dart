import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// All icon types MeBé draws itself instead of using Material/Cupertino
/// glyphs — a soft-gradient illustration style consistent with the rest of
/// the app's bunny/pastel visual language.
enum MeBeIconType {
  // Nav
  home, baby, journal, premium, stats, profile,
  // Features
  breastfeed, bottle, pump, sleep, diaper, growth,
  calendar, timer, wonderWeeks, memory, aiChat, photo,
  // Actions
  quickLog, play, pause, edit, share, sync, add, delete,
  // Status
  done, warning, babyHappy, babySleeping, babyCrying, milestone,
  // Home activity grid extras
  milkStorage, solidFood, scanMilk,
}

enum _GradientFamily { blossom, lavender, mint, gold, blue, coral, green }

const _gradients = <_GradientFamily, List<Color>>{
  _GradientFamily.blossom: [Color(0xFFF9A8CB), Color(0xFFF472A0)],
  _GradientFamily.lavender: [Color(0xFFE2D4FF), Color(0xFF8B5CF6)],
  _GradientFamily.mint: [Color(0xFF7DE8C8), Color(0xFF3ABFA0)],
  _GradientFamily.gold: [Color(0xFFFFD580), Color(0xFFF4A020)],
  _GradientFamily.blue: [Color(0xFF93B4FB), Color(0xFF5B8EF0)],
  _GradientFamily.coral: [Color(0xFFFFB890), Color(0xFFEB6834)],
  _GradientFamily.green: [Color(0xFF6EE7B7), Color(0xFF059669)],
};

const _gradientsActive = <_GradientFamily, List<Color>>{
  _GradientFamily.blossom: [Color(0xFFF472A0), Color(0xFFC9184A)],
  _GradientFamily.lavender: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
  _GradientFamily.mint: [Color(0xFF3ABFA0), Color(0xFF0F766E)],
  _GradientFamily.gold: [Color(0xFFF59E0B), Color(0xFFD97706)],
  _GradientFamily.blue: [Color(0xFF5B8EF0), Color(0xFF2E5EC7)],
  _GradientFamily.coral: [Color(0xFFEB6834), Color(0xFFC2410C)],
  _GradientFamily.green: [Color(0xFF059669), Color(0xFF047857)],
};

const _familyOf = <MeBeIconType, _GradientFamily>{
  MeBeIconType.home: _GradientFamily.blossom,
  MeBeIconType.breastfeed: _GradientFamily.blossom,
  MeBeIconType.baby: _GradientFamily.blossom,
  MeBeIconType.babyHappy: _GradientFamily.blossom,
  MeBeIconType.sleep: _GradientFamily.lavender,
  MeBeIconType.wonderWeeks: _GradientFamily.lavender,
  MeBeIconType.memory: _GradientFamily.lavender,
  MeBeIconType.babySleeping: _GradientFamily.lavender,
  MeBeIconType.diaper: _GradientFamily.mint,
  MeBeIconType.journal: _GradientFamily.mint,
  MeBeIconType.sync: _GradientFamily.mint,
  MeBeIconType.done: _GradientFamily.mint,
  MeBeIconType.share: _GradientFamily.mint,
  MeBeIconType.premium: _GradientFamily.gold,
  MeBeIconType.stats: _GradientFamily.gold,
  MeBeIconType.milestone: _GradientFamily.gold,
  MeBeIconType.timer: _GradientFamily.gold,
  MeBeIconType.bottle: _GradientFamily.gold,
  MeBeIconType.calendar: _GradientFamily.blue,
  MeBeIconType.profile: _GradientFamily.blue,
  MeBeIconType.quickLog: _GradientFamily.blue,
  MeBeIconType.photo: _GradientFamily.blue,
  MeBeIconType.play: _GradientFamily.blue,
  MeBeIconType.edit: _GradientFamily.blue,
  MeBeIconType.aiChat: _GradientFamily.coral,
  MeBeIconType.warning: _GradientFamily.coral,
  MeBeIconType.babyCrying: _GradientFamily.coral,
  MeBeIconType.delete: _GradientFamily.coral,
  MeBeIconType.growth: _GradientFamily.green,
  MeBeIconType.pump: _GradientFamily.green,
  MeBeIconType.add: _GradientFamily.green,
  MeBeIconType.pause: _GradientFamily.green,
  MeBeIconType.milkStorage: _GradientFamily.blue,
  MeBeIconType.solidFood: _GradientFamily.gold,
  MeBeIconType.scanMilk: _GradientFamily.coral,
};

/// A single MeBé icon: a soft circular background plus a gradient-filled
/// illustration, drawn entirely with [CustomPainter] (no image assets).
class MeBeIcon extends StatelessWidget {
  const MeBeIcon({
    super.key,
    required this.type,
    this.size = 28,
    this.isActive = false,
    this.overrideColor,
  });

  final MeBeIconType type;
  final double size;
  final bool isActive;
  final Color? overrideColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MeBeIconPainter(type: type, isActive: isActive, overrideColor: overrideColor),
      ),
    );
  }
}

class _MeBeIconPainter extends CustomPainter {
  _MeBeIconPainter({required this.type, required this.isActive, this.overrideColor});

  final MeBeIconType type;
  final bool isActive;
  final Color? overrideColor;

  List<Color> get _colors {
    if (overrideColor != null) return [overrideColor!, overrideColor!];
    final family = _familyOf[type] ?? _GradientFamily.blossom;
    return (isActive ? _gradientsActive : _gradients)[family]!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 48, size.height / 48);

    switch (type) {
      case MeBeIconType.home:
        _paintHome(canvas);
      case MeBeIconType.sleep:
      case MeBeIconType.babySleeping:
        _paintSleep(canvas);
      case MeBeIconType.bottle:
        _paintBottle(canvas);
      case MeBeIconType.diaper:
        _paintDiaper(canvas);
      case MeBeIconType.premium:
        _paintPremium(canvas);
      case MeBeIconType.breastfeed:
      case MeBeIconType.baby:
      case MeBeIconType.babyHappy:
        _paintBreastfeed(canvas);
      case MeBeIconType.pump:
        _paintPump(canvas);
      case MeBeIconType.growth:
        _paintGrowth(canvas);
      case MeBeIconType.journal:
      case MeBeIconType.memory:
        _paintJournal(canvas);
      case MeBeIconType.stats:
        _paintStats(canvas);
      case MeBeIconType.profile:
        _paintProfile(canvas);
      case MeBeIconType.calendar:
        _paintCalendar(canvas);
      case MeBeIconType.aiChat:
        _paintAiChat(canvas);
      case MeBeIconType.photo:
        _paintPhoto(canvas);
      case MeBeIconType.timer:
        _paintTimer(canvas);
      case MeBeIconType.wonderWeeks:
        _paintWonderWeeks(canvas);
      case MeBeIconType.milestone:
        _paintMilestone(canvas);
      case MeBeIconType.warning:
        _paintWarning(canvas);
      case MeBeIconType.babyCrying:
        _paintBabyCrying(canvas);
      case MeBeIconType.quickLog:
        _paintBolt(canvas);
      case MeBeIconType.play:
        _paintPlay(canvas);
      case MeBeIconType.pause:
        _paintPause(canvas);
      case MeBeIconType.edit:
        _paintEdit(canvas);
      case MeBeIconType.share:
        _paintShare(canvas);
      case MeBeIconType.sync:
        _paintSync(canvas);
      case MeBeIconType.add:
        _paintAdd(canvas);
      case MeBeIconType.delete:
        _paintDelete(canvas);
      case MeBeIconType.done:
        _paintDone(canvas);
      case MeBeIconType.milkStorage:
        _paintMilkStorage(canvas);
      case MeBeIconType.solidFood:
        _paintSolidFood(canvas);
      case MeBeIconType.scanMilk:
        _paintScanMilk(canvas);
    }
    canvas.restore();
  }

  Paint get _fill => Paint()..shader = ui.Gradient.linear(const Offset(24, 8), const Offset(24, 40), _colors);

  void _bg(Canvas canvas, Color color) => canvas.drawCircle(const Offset(24, 24), 22, Paint()..color = color);

  // ── Home (bunny face) ──────────────────────────────────
  void _paintHome(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF0F6));
    final body = Path()
      ..moveTo(24, 10)
      ..cubicTo(36, 14, 38, 26, 36, 32)
      ..cubicTo(34, 38, 28, 40, 24, 40)
      ..cubicTo(20, 40, 14, 38, 12, 32)
      ..cubicTo(10, 26, 12, 14, 24, 10)
      ..close();
    canvas.drawPath(body, _fill);
    final earPaint = Paint()..color = _colors.first;
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, 16), width: 8, height: 14), earPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(30, 16), width: 8, height: 14), earPaint);
    final eyePaint = Paint()..color = Colors.white;
    canvas.drawCircle(const Offset(21, 26), 2, eyePaint);
    canvas.drawCircle(const Offset(27, 26), 2, eyePaint);
    final smile = Path()
      ..moveTo(21, 31)
      ..quadraticBezierTo(24, 34, 27, 31);
    canvas.drawPath(
      smile,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Sleep (moon + stars) ───────────────────────────────
  void _paintSleep(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F0FF));
    final full = Path()..addOval(Rect.fromCenter(center: const Offset(24, 22), width: 20, height: 20));
    final cut = Path()..addOval(Rect.fromCenter(center: const Offset(28, 19), width: 16, height: 16));
    final crescent = Path.combine(PathOperation.difference, full, cut);
    canvas.drawPath(crescent, _fill);
    _drawStar(canvas, const Offset(34, 14), 3, _colors.first);
    _drawStar(canvas, const Offset(15, 32), 2.5, _colors.first);
  }

  // ── Bottle ──────────────────────────────────────────────
  void _paintBottle(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF5F0));
    final bottle = Path()
      ..moveTo(18, 28)
      ..cubicTo(16, 26, 16, 22, 18, 20)
      ..lineTo(20, 18)
      ..lineTo(20, 14)
      ..lineTo(28, 14)
      ..lineTo(28, 18)
      ..lineTo(30, 20)
      ..cubicTo(32, 22, 32, 26, 30, 28)
      ..lineTo(30, 36)
      ..cubicTo(30, 37, 29, 38, 28, 38)
      ..lineTo(20, 38)
      ..cubicTo(19, 38, 18, 37, 18, 36)
      ..close();
    canvas.drawPath(bottle, _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(22, 10, 4, 6), const Radius.circular(2)),
      Paint()..color = _colors.first,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(20, 26, 8, 10), const Radius.circular(4)),
      Paint()..color = Colors.white.withValues(alpha: 0.4),
    );
  }

  // ── Diaper ──────────────────────────────────────────────
  void _paintDiaper(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    final diaper = Path()
      ..moveTo(14, 22)
      ..lineTo(34, 22)
      ..cubicTo(36, 24, 36, 32, 34, 36)
      ..lineTo(24, 36)
      ..lineTo(14, 36)
      ..cubicTo(12, 32, 12, 24, 14, 22)
      ..close();
    canvas.drawPath(diaper, _fill);
    final top = Path()
      ..moveTo(18, 22)
      ..cubicTo(18, 18, 22, 16, 24, 16)
      ..cubicTo(26, 16, 30, 18, 30, 22);
    canvas.drawPath(
      top,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(16, 23), 3, Paint()..color = Colors.white.withValues(alpha: 0.7));
    canvas.drawCircle(const Offset(32, 23), 3, Paint()..color = Colors.white.withValues(alpha: 0.7));
  }

  // ── Premium (star) ────────────────────────────────────
  void _paintPremium(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    _drawFilledStar(canvas, const Offset(24, 24), 13, 5.5, _fill);
    canvas.drawCircle(const Offset(24, 24), 3, Paint()..color = Colors.white.withValues(alpha: 0.4));
  }

  // ── Breastfeed / baby / happy (bunny + heart) ─────────
  void _paintBreastfeed(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF0F6));
    canvas.drawCircle(const Offset(24, 22), 12, _fill);
    final earPaint = Paint()..color = _colors.first;
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, 12), width: 6, height: 10), earPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(30, 12), width: 6, height: 10), earPaint);
    canvas.drawCircle(const Offset(21, 22), 1.6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(27, 22), 1.6, Paint()..color = Colors.white);
    _drawHeart(canvas, const Offset(24, 36), 6, _colors.last);
  }

  // ── Pump (droplet pair) ───────────────────────────────
  void _paintPump(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    for (final dx in [-6.0, 6.0]) {
      final drop = Path()
        ..moveTo(24 + dx, 12)
        ..cubicTo(24 + dx - 6, 22, 24 + dx - 6, 30, 24 + dx, 34)
        ..cubicTo(24 + dx + 6, 30, 24 + dx + 6, 22, 24 + dx, 12)
        ..close();
      canvas.drawPath(drop, _fill);
    }
  }

  // ── Growth (bar chart trending up) ────────────────────
  void _paintGrowth(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF6));
    final bars = [
      (14.0, 30.0, 6.0, 8.0),
      (22.0, 24.0, 6.0, 14.0),
      (30.0, 16.0, 6.0, 22.0),
    ];
    for (final (x, y, w, h) in bars) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(Rect.fromLTWH(x, y, w, h), topLeft: const Radius.circular(3), topRight: const Radius.circular(3)),
        _fill,
      );
    }
    final trend = Path()
      ..moveTo(14, 26)
      ..lineTo(22, 20)
      ..lineTo(30, 12);
    canvas.drawPath(
      trend,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Journal / Memory (book) ────────────────────────────
  void _paintJournal(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    final cover = RRect.fromRectAndRadius(const Rect.fromLTWH(12, 12, 24, 26), const Radius.circular(4));
    canvas.drawRRect(cover, _fill);
    canvas.drawLine(
      const Offset(24, 12),
      const Offset(24, 38),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..strokeWidth = 1.5,
    );
    for (final y in [20.0, 26.0]) {
      canvas.drawLine(
        Offset(28, y),
        Offset(32, y),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.7)
          ..strokeWidth = 1.5,
      );
    }
  }

  // ── Stats (donut) ──────────────────────────────────────
  void _paintStats(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    canvas.drawArc(
      Rect.fromCenter(center: const Offset(24, 24), width: 24, height: 24),
      -math.pi / 2,
      math.pi * 1.5,
      false,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(12, 12), const Offset(36, 36), _colors)
        ..strokeWidth = 6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Profile (person) ───────────────────────────────────
  void _paintProfile(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    canvas.drawCircle(const Offset(24, 18), 7, _fill);
    final body = Path()
      ..moveTo(12, 38)
      ..cubicTo(12, 28, 36, 28, 36, 38)
      ..close();
    canvas.drawPath(body, _fill);
  }

  // ── Calendar ────────────────────────────────────────────
  void _paintCalendar(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    final base = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 12, 28, 24), const Radius.circular(5));
    canvas.drawRRect(base, _fill);
    canvas.drawRect(const Rect.fromLTWH(10, 12, 28, 6), Paint()..color = Colors.white.withValues(alpha: 0.35));
    canvas.drawCircle(const Offset(24, 26), 3, Paint()..color = Colors.white);
  }

  // ── AI Chat (bunny + speech bubble) ────────────────────
  void _paintAiChat(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    final bubble = RRect.fromRectAndRadius(const Rect.fromLTWH(11, 13, 26, 18), const Radius.circular(9));
    canvas.drawRRect(bubble, _fill);
    final tail = Path()
      ..moveTo(18, 31)
      ..lineTo(15, 37)
      ..lineTo(23, 31)
      ..close();
    canvas.drawPath(tail, _fill);
    for (final dx in [-5.0, 0.0, 5.0]) {
      canvas.drawCircle(Offset(24 + dx, 22), 1.8, Paint()..color = Colors.white);
    }
  }

  // ── Photo (camera) ─────────────────────────────────────
  void _paintPhoto(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 16, 28, 20), const Radius.circular(6));
    canvas.drawRRect(body, _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 11, 12, 6), const Radius.circular(3)),
      Paint()..color = _colors.first,
    );
    canvas.drawCircle(const Offset(24, 26), 6, Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawCircle(const Offset(24, 26), 6, Paint()
      ..color = _colors.last
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2);
  }

  // ── Timer (clock) ──────────────────────────────────────
  void _paintTimer(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    canvas.drawCircle(const Offset(24, 25), 13, _fill);
    canvas.drawLine(
      const Offset(24, 25),
      const Offset(24, 17),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(24, 25),
      const Offset(29, 27),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRect(const Rect.fromLTWH(21, 9, 6, 3), Paint()..color = _colors.first);
  }

  // ── Wonder weeks (wave + star) ─────────────────────────
  void _paintWonderWeeks(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F0FF));
    final wave = Path()
      ..moveTo(10, 28)
      ..quadraticBezierTo(17, 18, 24, 28)
      ..quadraticBezierTo(31, 38, 38, 28);
    canvas.drawPath(
      wave,
      Paint()
        ..shader = ui.Gradient.linear(const Offset(10, 20), const Offset(38, 36), _colors)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    _drawStar(canvas, const Offset(24, 14), 4, _colors.last);
  }

  // ── Milestone (flag) ───────────────────────────────────
  void _paintMilestone(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    canvas.drawLine(
      const Offset(18, 12),
      const Offset(18, 38),
      Paint()
        ..color = _colors.last
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
    final flag = Path()
      ..moveTo(18, 13)
      ..lineTo(34, 17)
      ..lineTo(18, 24)
      ..close();
    canvas.drawPath(flag, _fill);
  }

  // ── Warning ─────────────────────────────────────────────
  void _paintWarning(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    final tri = Path()
      ..moveTo(24, 10)
      ..lineTo(38, 34)
      ..lineTo(10, 34)
      ..close();
    canvas.drawPath(tri, _fill);
    canvas.drawRect(const Rect.fromLTWH(23, 20, 2, 8), Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(24, 31), 1.4, Paint()..color = Colors.white);
  }

  // ── Baby crying (face) ─────────────────────────────────
  void _paintBabyCrying(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    canvas.drawCircle(const Offset(24, 24), 13, _fill);
    canvas.drawLine(const Offset(19, 20), const Offset(22, 23), Paint()..color = Colors.white..strokeWidth = 1.8..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(22, 20), const Offset(19, 23), Paint()..color = Colors.white..strokeWidth = 1.8..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(26, 20), const Offset(29, 23), Paint()..color = Colors.white..strokeWidth = 1.8..strokeCap = StrokeCap.round);
    canvas.drawLine(const Offset(29, 20), const Offset(26, 23), Paint()..color = Colors.white..strokeWidth = 1.8..strokeCap = StrokeCap.round);
    final mouth = Path()
      ..moveTo(20, 31)
      ..quadraticBezierTo(24, 27, 28, 31);
    canvas.drawPath(mouth, Paint()..color = Colors.white..strokeWidth = 1.8..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);
    canvas.drawCircle(const Offset(19, 27), 1.4, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(29, 27), 1.4, Paint()..color = Colors.white.withValues(alpha: 0.9));
  }

  // ── Quick log (bolt) ────────────────────────────────────
  void _paintBolt(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    final bolt = Path()
      ..moveTo(26, 10)
      ..lineTo(16, 26)
      ..lineTo(22, 26)
      ..lineTo(20, 38)
      ..lineTo(32, 20)
      ..lineTo(25, 20)
      ..close();
    canvas.drawPath(bolt, _fill);
  }

  void _paintPlay(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    final tri = Path()
      ..moveTo(19, 15)
      ..lineTo(33, 24)
      ..lineTo(19, 33)
      ..close();
    canvas.drawPath(tri, _fill);
  }

  void _paintPause(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(17, 14, 6, 20), const Radius.circular(3)), _fill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(27, 14, 6, 20), const Radius.circular(3)), _fill);
  }

  void _paintEdit(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    canvas.save();
    canvas.translate(24, 24);
    canvas.rotate(-math.pi / 4);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-3, -14, 6, 22), const Radius.circular(3)), _fill);
    final tip = Path()
      ..moveTo(-3, 8)
      ..lineTo(3, 8)
      ..lineTo(0, 14)
      ..close();
    canvas.drawPath(tip, _fill);
    canvas.restore();
  }

  void _paintShare(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    for (final c in [const Offset(32, 14), const Offset(32, 34), const Offset(16, 24)]) {
      canvas.drawCircle(c, 4, _fill);
    }
    final linePaint = Paint()
      ..shader = ui.Gradient.linear(const Offset(16, 14), const Offset(32, 34), _colors)
      ..strokeWidth = 2;
    canvas.drawLine(const Offset(16, 24), const Offset(32, 14), linePaint);
    canvas.drawLine(const Offset(16, 24), const Offset(32, 34), linePaint);
  }

  void _paintSync(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    final rect = Rect.fromCenter(center: const Offset(24, 24), width: 22, height: 22);
    canvas.drawArc(rect, -math.pi * 0.85, math.pi * 1.3, false, Paint()
      ..shader = ui.Gradient.linear(const Offset(13, 13), const Offset(35, 35), _colors)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 1.3, false, Paint()
      ..shader = ui.Gradient.linear(const Offset(13, 13), const Offset(35, 35), _colors)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round);
  }

  void _paintAdd(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF6));
    final paint = Paint()
      ..shader = ui.Gradient.linear(const Offset(24, 12), const Offset(24, 36), _colors)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(24, 14), const Offset(24, 34), paint);
    canvas.drawLine(const Offset(14, 24), const Offset(34, 24), paint);
  }

  void _paintDelete(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(14, 16, 20, 20), const Radius.circular(4)), _fill);
    canvas.drawRect(const Rect.fromLTWH(11, 13, 26, 3), Paint()..color = _colors.last);
    canvas.drawRect(const Rect.fromLTWH(20, 9, 8, 4), Paint()..color = _colors.last);
    for (final x in [20.0, 24.0, 28.0]) {
      canvas.drawLine(Offset(x, 20), Offset(x, 32), Paint()..color = Colors.white.withValues(alpha: 0.7)..strokeWidth = 1.5);
    }
  }

  // ── Milk storage (fridge box) ──────────────────────────
  void _paintMilkStorage(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    final box = RRect.fromRectAndRadius(const Rect.fromLTWH(10, 12, 28, 24), const Radius.circular(6));
    canvas.drawRRect(box, _fill);
    canvas.drawLine(
      const Offset(10, 22),
      const Offset(38, 22),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.5,
    );
    for (final rect in [const Rect.fromLTWH(14, 15, 6, 5), const Rect.fromLTWH(22, 15, 5, 5), const Rect.fromLTWH(29, 15, 5, 5)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = Colors.white.withValues(alpha: 0.6),
      );
    }
    for (final rect in [const Rect.fromLTWH(14, 26, 5, 6), const Rect.fromLTWH(21, 26, 10, 6)]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        Paint()..color = Colors.white.withValues(alpha: 0.3),
      );
    }
  }

  // ── Solid food (bowl + spoon) ──────────────────────────
  void _paintSolidFood(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    final bowl = Path()
      ..moveTo(9, 22)
      ..lineTo(39, 22)
      ..cubicTo(39, 32, 33, 37, 24, 37)
      ..cubicTo(15, 37, 9, 32, 9, 22)
      ..close();
    canvas.drawPath(bowl, _fill);
    canvas.drawOval(const Rect.fromLTWH(9, 19, 30, 6), Paint()..color = _colors.first);
    canvas.drawCircle(const Offset(34, 12), 4.5, Paint()..color = _colors.last);
    canvas.drawLine(
      const Offset(31.5, 15.5),
      const Offset(25, 28),
      Paint()
        ..color = _colors.last
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Scan milk (camera + scan lines) ────────────────────
  void _paintScanMilk(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(8, 16, 32, 20), const Radius.circular(6));
    canvas.drawRRect(body, _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(16, 11, 10, 6), const Radius.circular(3)),
      Paint()..color = _colors.first,
    );
    canvas.drawCircle(const Offset(24, 26), 7, Paint()..color = Colors.white.withValues(alpha: 0.25));
    canvas.drawCircle(const Offset(24, 26), 4.5, Paint()..color = Colors.white.withValues(alpha: 0.45));
    canvas.drawCircle(const Offset(12, 20.5), 1.6, Paint()..color = _colors.first);
    final scanPaint = Paint()
      ..color = _colors.last.withValues(alpha: 0.6)
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(8, 27), const Offset(13, 27), scanPaint);
    canvas.drawLine(const Offset(35, 27), const Offset(40, 27), scanPaint);
  }

  void _paintDone(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    canvas.drawCircle(const Offset(24, 24), 15, _fill);
    final check = Path()
      ..moveTo(17, 24)
      ..lineTo(22, 29)
      ..lineTo(31, 18);
    canvas.drawPath(check, Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round);
  }

  // ── Shared primitives ────────────────────────────────────
  void _drawStar(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    for (var i = 0; i < 4; i++) {
      final angle = i * math.pi / 2 - math.pi / 4;
      final pt = Offset(center.dx + size * math.cos(angle), center.dy + size * math.sin(angle));
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    path.close();
    canvas.drawPath(path, Paint()..color = color);
  }

  void _drawFilledStar(Canvas canvas, Offset center, double outer, double inner, Paint paint) {
    final path = Path();
    for (var i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * math.pi / 180;
      final innerAngle = ((i * 72 + 36) - 90) * math.pi / 180;
      final ox = center.dx + outer * math.cos(outerAngle);
      final oy = center.dy + outer * math.sin(outerAngle);
      final ix = center.dx + inner * math.cos(innerAngle);
      final iy = center.dy + inner * math.sin(innerAngle);
      if (i == 0) {
        path.moveTo(ox, oy);
      } else {
        path.lineTo(ox, oy);
      }
      path.lineTo(ix, iy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawHeart(Canvas canvas, Offset center, double size, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy + size * 0.7)
      ..cubicTo(center.dx - size * 1.4, center.dy - size * 0.4, center.dx - size * 0.4, center.dy - size * 1.3,
          center.dx, center.dy - size * 0.5)
      ..cubicTo(center.dx + size * 0.4, center.dy - size * 1.3, center.dx + size * 1.4, center.dy - size * 0.4,
          center.dx, center.dy + size * 0.7)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MeBeIconPainter old) =>
      old.type != type || old.isActive != isActive || old.overrideColor != overrideColor;
}
