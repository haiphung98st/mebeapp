import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

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
  done, warning, babyHappy, babySleeping, babyCrying, babyCalm, babyFussy, milestone,
  // Home activity grid extras
  milkStorage, solidFood, scanMilk,
  // Recurring feature icons (Phase 2)
  mascotBunny, vaccine, teeth, pregnancy, letter, voiceJournal, soundscapeMusic,
  mapTrail, moodTimelineRainbow, timeCapsule, diaperWet, diaperDirty, temperature,
  motorSkill, community, wonderWeeksStormy, wonderWeeksCalm, easySchedule, napTime,
  weightScale, trophy, celebration, momCare, vitamin,
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
  MeBeIconType.babyCalm: _GradientFamily.lavender,
  MeBeIconType.babyFussy: _GradientFamily.coral,
  MeBeIconType.mascotBunny: _GradientFamily.blossom,
  MeBeIconType.vaccine: _GradientFamily.blue,
  MeBeIconType.teeth: _GradientFamily.blue,
  MeBeIconType.pregnancy: _GradientFamily.blossom,
  MeBeIconType.letter: _GradientFamily.lavender,
  MeBeIconType.voiceJournal: _GradientFamily.lavender,
  MeBeIconType.soundscapeMusic: _GradientFamily.lavender,
  MeBeIconType.mapTrail: _GradientFamily.lavender,
  MeBeIconType.moodTimelineRainbow: _GradientFamily.gold,
  MeBeIconType.timeCapsule: _GradientFamily.gold,
  MeBeIconType.diaperWet: _GradientFamily.mint,
  MeBeIconType.diaperDirty: _GradientFamily.mint,
  MeBeIconType.temperature: _GradientFamily.coral,
  MeBeIconType.motorSkill: _GradientFamily.green,
  MeBeIconType.community: _GradientFamily.blue,
  MeBeIconType.wonderWeeksStormy: _GradientFamily.lavender,
  MeBeIconType.wonderWeeksCalm: _GradientFamily.lavender,
  MeBeIconType.easySchedule: _GradientFamily.gold,
  MeBeIconType.napTime: _GradientFamily.gold,
  MeBeIconType.weightScale: _GradientFamily.green,
  MeBeIconType.trophy: _GradientFamily.gold,
  MeBeIconType.celebration: _GradientFamily.coral,
  MeBeIconType.momCare: _GradientFamily.blossom,
  MeBeIconType.vitamin: _GradientFamily.coral,
};

// Solar Icons (Bold) mapping — modern rounded glyphs replacing the hand-
// painted look for types with a good semantic match. Types left unmapped
// (baby facial expressions, diaper, breastfeed/pump, mascot, teeth,
// pregnancy — no suitable off-the-shelf equivalent) keep the original
// CustomPainter illustration below.
const _solarIconFor = <MeBeIconType, IconData>{
  MeBeIconType.home: SolarIconsBold.homeSmile,
  MeBeIconType.baby: SolarIconsBold.smileCircle,
  MeBeIconType.journal: SolarIconsBold.notebook,
  MeBeIconType.premium: SolarIconsBold.crownStar,
  MeBeIconType.stats: SolarIconsBold.pieChart,
  MeBeIconType.profile: SolarIconsBold.userCircle,
  MeBeIconType.bottle: SolarIconsBold.bottle,
  MeBeIconType.sleep: SolarIconsBold.moonSleep,
  MeBeIconType.growth: SolarIconsBold.chart_2,
  MeBeIconType.calendar: SolarIconsBold.calendar,
  MeBeIconType.timer: SolarIconsBold.stopwatch,
  MeBeIconType.wonderWeeks: SolarIconsBold.cloudBolt,
  MeBeIconType.memory: SolarIconsBold.galleryWide,
  MeBeIconType.aiChat: SolarIconsBold.chatRoundDots,
  MeBeIconType.photo: SolarIconsBold.gallery,
  MeBeIconType.quickLog: SolarIconsBold.penNewSquare,
  MeBeIconType.play: SolarIconsBold.play,
  MeBeIconType.pause: SolarIconsBold.pause,
  MeBeIconType.edit: SolarIconsBold.pen2,
  MeBeIconType.share: SolarIconsBold.share,
  MeBeIconType.sync: SolarIconsBold.refreshCircle,
  MeBeIconType.add: SolarIconsBold.plus,
  MeBeIconType.delete: SolarIconsBold.trashBinMinimalistic,
  MeBeIconType.done: SolarIconsBold.checkCircle,
  MeBeIconType.warning: SolarIconsBold.dangerTriangle,
  MeBeIconType.milestone: SolarIconsBold.flag_2,
  MeBeIconType.scanMilk: SolarIconsBold.scanner_2,
  MeBeIconType.vaccine: SolarIconsBold.syringe,
  MeBeIconType.letter: SolarIconsBold.letter,
  MeBeIconType.voiceJournal: SolarIconsBold.microphone2,
  MeBeIconType.soundscapeMusic: SolarIconsBold.musicNote2,
  MeBeIconType.mapTrail: SolarIconsBold.route,
  MeBeIconType.moodTimelineRainbow: SolarIconsBold.starRainbow,
  MeBeIconType.timeCapsule: SolarIconsBold.box,
  MeBeIconType.temperature: SolarIconsBold.thermometer,
  MeBeIconType.motorSkill: SolarIconsBold.walkingRound,
  MeBeIconType.community: SolarIconsBold.usersGroupRounded,
  MeBeIconType.wonderWeeksStormy: SolarIconsBold.cloudStorm,
  MeBeIconType.wonderWeeksCalm: SolarIconsBold.cloudSun2,
  MeBeIconType.easySchedule: SolarIconsBold.calendarMark,
  MeBeIconType.napTime: SolarIconsBold.bed,
  MeBeIconType.weightScale: SolarIconsBold.scale,
  MeBeIconType.trophy: SolarIconsBold.medalStar,
  MeBeIconType.celebration: SolarIconsBold.confetti,
  MeBeIconType.momCare: SolarIconsBold.handHeart,
  MeBeIconType.vitamin: SolarIconsBold.pills,
};

List<Color> _resolveColors(MeBeIconType type, bool isActive, Color? overrideColor) {
  if (overrideColor != null) return [overrideColor, overrideColor];
  final family = _familyOf[type] ?? _GradientFamily.blossom;
  return (isActive ? _gradientsActive : _gradients)[family]!;
}

/// A single MeBé icon: either a gradient-tinted Solar Icon (modern, rounded
/// style) or — for the handful of baby-specific concepts with no suitable
/// off-the-shelf equivalent — the original hand-painted [CustomPainter]
/// illustration.
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
    final solarIcon = _solarIconFor[type];
    if (solarIcon != null) {
      final colors = _resolveColors(type, isActive, overrideColor);
      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ).createShader(bounds),
        child: Icon(solarIcon, size: size, color: Colors.white),
      );
    }
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

  List<Color> get _colors => _resolveColors(type, isActive, overrideColor);

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
      case MeBeIconType.babyCalm:
        _paintBabyCalm(canvas);
      case MeBeIconType.babyFussy:
        _paintBabyFussy(canvas);
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
      case MeBeIconType.mascotBunny:
        _paintMascotBunny(canvas);
      case MeBeIconType.vaccine:
        _paintVaccine(canvas);
      case MeBeIconType.teeth:
        _paintTeeth(canvas);
      case MeBeIconType.pregnancy:
        _paintPregnancy(canvas);
      case MeBeIconType.letter:
        _paintLetter(canvas);
      case MeBeIconType.voiceJournal:
        _paintVoiceJournal(canvas);
      case MeBeIconType.soundscapeMusic:
        _paintSoundscapeMusic(canvas);
      case MeBeIconType.mapTrail:
        _paintMapTrail(canvas);
      case MeBeIconType.moodTimelineRainbow:
        _paintMoodTimelineRainbow(canvas);
      case MeBeIconType.timeCapsule:
        _paintTimeCapsule(canvas);
      case MeBeIconType.diaperWet:
        _paintDiaperWet(canvas);
      case MeBeIconType.diaperDirty:
        _paintDiaperDirty(canvas);
      case MeBeIconType.temperature:
        _paintTemperature(canvas);
      case MeBeIconType.motorSkill:
        _paintMotorSkill(canvas);
      case MeBeIconType.community:
        _paintCommunity(canvas);
      case MeBeIconType.wonderWeeksStormy:
        _paintWonderWeeksStormy(canvas);
      case MeBeIconType.wonderWeeksCalm:
        _paintWonderWeeksCalm(canvas);
      case MeBeIconType.easySchedule:
        _paintEasySchedule(canvas);
      case MeBeIconType.napTime:
        _paintNapTime(canvas);
      case MeBeIconType.weightScale:
        _paintWeightScale(canvas);
      case MeBeIconType.trophy:
        _paintTrophy(canvas);
      case MeBeIconType.celebration:
        _paintCelebration(canvas);
      case MeBeIconType.momCare:
        _paintMomCare(canvas);
      case MeBeIconType.vitamin:
        _paintVitamin(canvas);
    }
    _highlight(canvas);
    canvas.restore();
  }

  Paint get _fill => Paint()..shader = ui.Gradient.linear(const Offset(24, 8), const Offset(24, 40), _colors);

  void _bg(Canvas canvas, Color color) {
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2, 2, 44, 44),
      const Radius.circular(13),
    );
    canvas.drawRRect(rrect, Paint()..color = color);
    // Radial depth overlay — darker edges for 3D gem look
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(18, 15),
          28,
          [Colors.white.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.09)],
        ),
    );
    // Subtle tinted border
    final family = _familyOf[type] ?? _GradientFamily.blossom;
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = (_gradients[family]![1]).withValues(alpha: 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  void _highlight(Canvas canvas) {
    canvas.save();
    canvas.translate(17, 13);
    canvas.rotate(-25 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 15, height: 8.5),
      Paint()..color = Colors.white.withValues(alpha: 0.28),
    );
    canvas.restore();
  }

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

  // ── Baby calm (bunny, relaxed eyes) ────────────────────
  void _paintBabyCalm(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F0FF));
    canvas.drawCircle(const Offset(24, 22), 12, _fill);
    final earPaint = Paint()..color = _colors.first;
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, 12), width: 6, height: 10), earPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(30, 12), width: 6, height: 10), earPaint);
    final eyePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(Path()..moveTo(19, 22)..quadraticBezierTo(21, 24, 23, 22), eyePaint);
    canvas.drawPath(Path()..moveTo(25, 22)..quadraticBezierTo(27, 24, 29, 22), eyePaint);
    canvas.drawPath(
      Path()
        ..moveTo(20, 28)
        ..quadraticBezierTo(24, 31, 28, 28),
      eyePaint,
    );
  }

  // ── Baby fussy (bunny, furrowed brow) ──────────────────
  void _paintBabyFussy(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    canvas.drawCircle(const Offset(24, 22), 12, _fill);
    final earPaint = Paint()..color = _colors.first;
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, 12), width: 6, height: 10), earPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(30, 12), width: 6, height: 10), earPaint);
    canvas.drawCircle(const Offset(21, 22), 1.6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(27, 22), 1.6, Paint()..color = Colors.white);
    final browPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(18.5, 17.5), const Offset(21.5, 18.8), browPaint);
    canvas.drawLine(const Offset(29.5, 17.5), const Offset(26.5, 18.8), browPaint);
    canvas.drawPath(
      Path()
        ..moveTo(20, 29)
        ..quadraticBezierTo(24, 26.5, 28, 29),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Mascot bunny (full body, sitting) ──────────────────
  void _paintMascotBunny(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF0F6));
    final earPaint = Paint()..color = _colors.first;
    canvas.drawOval(Rect.fromCenter(center: const Offset(18, 12), width: 6.5, height: 15), earPaint);
    canvas.drawOval(Rect.fromCenter(center: const Offset(30, 12), width: 6.5, height: 15), earPaint);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(18, 13), width: 3, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(30, 13), width: 3, height: 10),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    final body = Path()
      ..moveTo(24, 16)
      ..cubicTo(33, 16, 37, 24, 35, 32)
      ..cubicTo(33, 39, 15, 39, 13, 32)
      ..cubicTo(11, 24, 15, 16, 24, 16)
      ..close();
    canvas.drawPath(body, _fill);
    canvas.drawCircle(const Offset(20, 26), 1.6, Paint()..color = Colors.white);
    canvas.drawCircle(const Offset(28, 26), 1.6, Paint()..color = Colors.white);
    final nose = Path()
      ..moveTo(22.5, 30)
      ..lineTo(25.5, 30)
      ..lineTo(24, 32)
      ..close();
    canvas.drawPath(nose, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24, 36), width: 10, height: 5),
      Paint()..color = Colors.white.withValues(alpha: 0.35),
    );
  }

  // ── Vaccine (syringe) ────────────────────────────────────
  void _paintVaccine(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    canvas.save();
    canvas.translate(24, 24);
    canvas.rotate(-math.pi / 4);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-4, -14, 8, 18), const Radius.circular(2)), _fill);
    canvas.drawRect(const Rect.fromLTWH(-4, -18, 8, 5), Paint()..color = _colors.first);
    canvas.drawLine(const Offset(0, 4), const Offset(0, 13), Paint()..color = _colors.last..strokeWidth = 2.4..strokeCap = StrokeCap.round);
    for (final dy in [-9.0, -4.5, 0.0]) {
      canvas.drawLine(Offset(-4, dy), Offset(4, dy), Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 1.2);
    }
    canvas.restore();
  }

  // ── Teeth ──────────────────────────────────────────────
  void _paintTeeth(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    for (final dx in [-6.0, 6.0]) {
      final tooth = Path()
        ..moveTo(24 + dx - 5, 14)
        ..cubicTo(24 + dx - 6, 22, 24 + dx - 5, 32, 24 + dx - 2, 34)
        ..cubicTo(24 + dx, 32, 24 + dx, 30, 24 + dx + 2, 34)
        ..cubicTo(24 + dx + 5, 32, 24 + dx + 6, 22, 24 + dx + 5, 14)
        ..cubicTo(24 + dx, 11, 24 + dx - 5, 11, 24 + dx - 5, 14)
        ..close();
      canvas.drawPath(tooth, _fill);
    }
  }

  // ── Pregnancy (belly silhouette + heart) ───────────────
  void _paintPregnancy(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF0F6));
    final body = Path()
      ..moveTo(20, 10)
      ..cubicTo(16, 10, 15, 14, 16, 17)
      ..cubicTo(11, 19, 9, 26, 13, 32)
      ..cubicTo(17, 39, 31, 39, 33, 30)
      ..cubicTo(35, 22, 30, 16, 24, 15)
      ..cubicTo(24, 12, 22, 10, 20, 10)
      ..close();
    canvas.drawPath(body, _fill);
    _drawHeart(canvas, const Offset(24, 27), 4.5, Colors.white.withValues(alpha: 0.85));
  }

  // ── Letter (envelope) ──────────────────────────────────
  void _paintLetter(Canvas canvas) {
    _bg(canvas, const Color(0xFFF3F0FF));
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(9, 14, 30, 21), const Radius.circular(4));
    canvas.drawRRect(body, _fill);
    final flap = Path()
      ..moveTo(9, 16)
      ..lineTo(24, 28)
      ..lineTo(39, 16);
    canvas.drawPath(
      flap,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.7)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── Voice journal (microphone) ─────────────────────────
  void _paintVoiceJournal(Canvas canvas) {
    _bg(canvas, const Color(0xFFF3F0FF));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(19, 9, 10, 18), const Radius.circular(5)), _fill);
    canvas.drawArc(
      const Rect.fromLTWH(13, 18, 22, 18),
      0,
      math.pi,
      false,
      Paint()
        ..color = _colors.last
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(24, 32),
      const Offset(24, 38),
      Paint()
        ..color = _colors.last
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(18, 38),
      const Offset(30, 38),
      Paint()
        ..color = _colors.last
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Soundscape (music notes) ───────────────────────────
  void _paintSoundscapeMusic(Canvas canvas) {
    _bg(canvas, const Color(0xFFF3F0FF));
    for (final (cx, cy, stemTop) in [(18.0, 32.0, 12.0), (30.0, 28.0, 16.0)]) {
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 6.5, height: 5), _fill);
      canvas.drawLine(Offset(cx + 3.1, cy), Offset(cx + 3.1, stemTop), Paint()..color = _colors.last..strokeWidth = 2);
      canvas.drawLine(Offset(cx + 3.1, stemTop), Offset(cx + 7, stemTop + 2), Paint()..color = _colors.last..strokeWidth = 2);
    }
  }

  // ── Milestone map (pin + trail) ────────────────────────
  void _paintMapTrail(Canvas canvas) {
    _bg(canvas, const Color(0xFFF3F0FF));
    for (final c in [const Offset(13, 32), const Offset(23, 24), const Offset(31, 30)]) {
      canvas.drawCircle(c, 2, Paint()..color = Colors.white.withValues(alpha: 0.7));
    }
    canvas.drawLine(const Offset(13, 32), const Offset(23, 24), Paint()..color = Colors.white.withValues(alpha: 0.5)..strokeWidth = 1.6);
    canvas.drawLine(const Offset(23, 24), const Offset(31, 30), Paint()..color = Colors.white.withValues(alpha: 0.5)..strokeWidth = 1.6);
    final pin = Path()
      ..moveTo(31, 9)
      ..cubicTo(26, 9, 23, 12.5, 23, 17)
      ..cubicTo(23, 22, 31, 30, 31, 30)
      ..cubicTo(31, 30, 39, 22, 39, 17)
      ..cubicTo(39, 12.5, 36, 9, 31, 9)
      ..close();
    canvas.drawPath(pin, _fill);
    canvas.drawCircle(const Offset(31, 17), 3.2, Paint()..color = Colors.white);
  }

  // ── Mood timeline (rainbow) ─────────────────────────────
  void _paintMoodTimelineRainbow(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    for (final (r, c) in [
      (15.0, _colors.first),
      (11.0, Color.lerp(_colors.first, _colors.last, 0.5)!),
      (7.0, _colors.last),
    ]) {
      canvas.drawArc(
        Rect.fromCenter(center: const Offset(24, 32), width: r * 2, height: r * 2),
        math.pi,
        math.pi,
        false,
        Paint()
          ..color = c
          ..strokeWidth = 3.2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  // ── Time capsule (gift box, open/closed via isActive) ──
  void _paintTimeCapsule(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    final lidOpen = isActive;
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(12, 22, 24, 16), const Radius.circular(3)), _fill);
    if (lidOpen) {
      canvas.save();
      canvas.translate(12, 22);
      canvas.rotate(-0.35);
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-1, -7, 26, 7), const Radius.circular(2)), Paint()..color = _colors.first);
      canvas.restore();
      _drawStar(canvas, const Offset(24, 12), 3, _colors.last);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(10, 18, 28, 7), const Radius.circular(2)), Paint()..color = _colors.first);
    }
    canvas.drawLine(const Offset(24, 22), const Offset(24, 38), Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 2);
  }

  // ── Diaper wet (droplet) ────────────────────────────────
  void _paintDiaperWet(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    final drop = Path()
      ..moveTo(24, 10)
      ..cubicTo(24 - 9, 22, 24 - 9, 31, 24, 36)
      ..cubicTo(24 + 9, 31, 24 + 9, 22, 24, 10)
      ..close();
    canvas.drawPath(drop, _fill);
    canvas.drawOval(const Rect.fromLTWH(20, 24, 4, 6), Paint()..color = Colors.white.withValues(alpha: 0.4));
  }

  // ── Diaper dirty (swirl) ────────────────────────────────
  void _paintDiaperDirty(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF8));
    canvas.drawCircle(const Offset(24, 25), 12, _fill);
    canvas.drawArc(
      const Rect.fromLTWH(17, 18, 14, 14),
      -math.pi * 0.6,
      math.pi * 1.5,
      false,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Temperature (thermometer) ──────────────────────────
  void _paintTemperature(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    canvas.drawCircle(const Offset(24, 32), 6, _fill);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(21, 10, 6, 24), const Radius.circular(3)), _fill);
    canvas.drawLine(
      const Offset(24, 15),
      const Offset(24, 30),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(24, 32), 2.4, Paint()..color = Colors.white);
  }

  // ── Motor skill (footprints) ───────────────────────────
  void _paintMotorSkill(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF6));
    void foot(Offset o, double angle) {
      canvas.save();
      canvas.translate(o.dx, o.dy);
      canvas.rotate(angle);
      canvas.drawOval(const Rect.fromLTWH(-4, -3, 8, 11), _fill);
      for (final dx in [-3.5, -1.2, 1.2, 3.5]) {
        canvas.drawCircle(Offset(dx, -6.5), 1.4, Paint()..color = _colors.first);
      }
      canvas.restore();
    }

    foot(const Offset(18, 30), -0.15);
    foot(const Offset(30, 18), 0.15);
  }

  // ── Community (people) ─────────────────────────────────
  void _paintCommunity(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F5FF));
    for (final (cx, r) in [(15.0, 6.0), (33.0, 6.0)]) {
      canvas.drawCircle(Offset(cx, 18), r * 0.6, Paint()..color = _colors.first);
      final body = Path()
        ..moveTo(cx - r, 36)
        ..cubicTo(cx - r, 28, cx + r, 28, cx + r, 36)
        ..close();
      canvas.drawPath(body, Paint()..color = _colors.first);
    }
    canvas.drawCircle(const Offset(24, 20), 7.5, _fill);
    final body = Path()
      ..moveTo(14, 39)
      ..cubicTo(14, 29, 34, 29, 34, 39)
      ..close();
    canvas.drawPath(body, _fill);
  }

  // ── Wonder weeks stormy (cloud + bolt) ─────────────────
  void _paintWonderWeeksStormy(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0F0FF));
    final cloud = Path()
      ..addOval(const Rect.fromLTWH(11, 14, 15, 13))
      ..addOval(const Rect.fromLTWH(20, 10, 16, 15))
      ..addOval(const Rect.fromLTWH(28, 15, 12, 11));
    canvas.drawPath(cloud, _fill);
    final bolt = Path()
      ..moveTo(25, 26)
      ..lineTo(18, 38)
      ..lineTo(23, 36)
      ..lineTo(21, 44)
      ..lineTo(30, 32)
      ..lineTo(25, 34)
      ..close();
    canvas.drawPath(bolt, Paint()..color = _colors.last);
  }

  // ── Wonder weeks calm (sun) ─────────────────────────────
  void _paintWonderWeeksCalm(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    canvas.drawCircle(const Offset(24, 24), 9, _fill);
    for (var i = 0; i < 8; i++) {
      final angle = i * math.pi / 4;
      final inner = Offset(24 + 13 * math.cos(angle), 24 + 13 * math.sin(angle));
      final outer = Offset(24 + 18 * math.cos(angle), 24 + 18 * math.sin(angle));
      canvas.drawLine(inner, outer, Paint()..color = _colors.last..strokeWidth = 2.4..strokeCap = StrokeCap.round);
    }
  }

  // ── EASY schedule (clipboard) ──────────────────────────
  void _paintEasySchedule(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(11, 11, 26, 28), const Radius.circular(4)), _fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 9, 12, 5), const Radius.circular(2.5)),
      Paint()..color = _colors.first,
    );
    for (final y in [20.0, 26.0, 32.0]) {
      canvas.drawLine(Offset(16, y), Offset(32, y), Paint()..color = Colors.white.withValues(alpha: 0.6)..strokeWidth = 1.6);
    }
  }

  // ── Nap time (sleepy sun) ───────────────────────────────
  void _paintNapTime(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    canvas.drawCircle(const Offset(22, 25), 8, _fill);
    for (var i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final inner = Offset(22 + 11 * math.cos(angle), 25 + 11 * math.sin(angle));
      final outer = Offset(22 + 15 * math.cos(angle), 25 + 15 * math.sin(angle));
      canvas.drawLine(inner, outer, Paint()..color = _colors.last..strokeWidth = 2..strokeCap = StrokeCap.round);
    }
    final textStyle = Paint()
      ..color = _colors.last
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(31, 12), const Offset(35, 12), textStyle);
    canvas.drawLine(const Offset(35, 12), const Offset(31, 16), textStyle);
    canvas.drawLine(const Offset(31, 16), const Offset(35, 16), textStyle);
  }

  // ── Weight (baby scale) ─────────────────────────────────
  void _paintWeightScale(Canvas canvas) {
    _bg(canvas, const Color(0xFFF0FFF6));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(9, 24, 30, 14), const Radius.circular(6)), _fill);
    canvas.drawArc(
      const Rect.fromLTWH(16, 15, 16, 16),
      math.pi,
      math.pi,
      false,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(24, 31), 4, Paint()..color = Colors.white.withValues(alpha: 0.85));
  }

  // ── Trophy ───────────────────────────────────────────────
  void _paintTrophy(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF8F0));
    final cup = Path()
      ..moveTo(17, 13)
      ..lineTo(31, 13)
      ..lineTo(30, 24)
      ..cubicTo(30, 29, 26, 31, 24, 31)
      ..cubicTo(22, 31, 18, 29, 18, 24)
      ..close();
    canvas.drawPath(cup, _fill);
    canvas.drawArc(const Rect.fromLTWH(9, 13, 10, 12), math.pi / 2, math.pi, false, Paint()..color = _colors.first..strokeWidth = 2.2..style = PaintingStyle.stroke);
    canvas.drawArc(const Rect.fromLTWH(29, 13, 10, 12), -math.pi / 2, math.pi, false, Paint()..color = _colors.first..strokeWidth = 2.2..style = PaintingStyle.stroke);
    canvas.drawRect(const Rect.fromLTWH(22, 31, 4, 5), Paint()..color = _colors.last);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(17, 36, 14, 3), const Radius.circular(1.5)), Paint()..color = _colors.last);
  }

  // ── Celebration (confetti burst) ───────────────────────
  void _paintCelebration(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    _drawStar(canvas, const Offset(24, 20), 6, _colors.last);
    for (final (dx, dy, c) in [
      (-11.0, -4.0, _colors.first),
      (11.0, -6.0, _colors.first),
      (-8.0, 12.0, _colors.last),
      (9.0, 13.0, _colors.first),
      (0.0, -14.0, _colors.last),
    ]) {
      canvas.drawCircle(Offset(24 + dx, 24 + dy), 2.2, Paint()..color = c);
    }
  }

  // ── Mom care (heart in hands) ───────────────────────────
  void _paintMomCare(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF0F6));
    _drawHeart(canvas, const Offset(24, 21), 8, _colors.last);
    final leftHand = Path()
      ..moveTo(9, 32)
      ..cubicTo(9, 27, 15, 25, 20, 28)
      ..cubicTo(16, 29, 13, 32, 13, 36);
    final rightHand = Path()
      ..moveTo(39, 32)
      ..cubicTo(39, 27, 33, 25, 28, 28)
      ..cubicTo(32, 29, 35, 32, 35, 36);
    final handStroke = Paint()
      ..color = _colors.first
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(leftHand, handStroke);
    canvas.drawPath(rightHand, handStroke);
  }

  // ── Vitamin (pill capsule) ──────────────────────────────
  void _paintVitamin(Canvas canvas) {
    _bg(canvas, const Color(0xFFFFF3EC));
    canvas.save();
    canvas.translate(24, 24);
    canvas.rotate(-math.pi / 4);
    final capsule = RRect.fromRectAndRadius(const Rect.fromLTWH(-14, -6, 28, 12), const Radius.circular(6));
    canvas.drawRRect(capsule, Paint()..color = _colors.first);
    canvas.save();
    canvas.clipRRect(capsule);
    canvas.drawRect(const Rect.fromLTWH(0, -6, 14, 12), Paint()..color = _colors.last);
    canvas.restore();
    canvas.restore();
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
