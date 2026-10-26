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
// painted look for types with no bespoke "gem" illustration (see
// _gemStopsOf below). Types left unmapped (baby facial expressions,
// pump, mascot, teeth, pregnancy — no suitable off-the-shelf equivalent)
// keep the original CustomPainter illustration below.
const _solarIconFor = <MeBeIconType, IconData>{
  MeBeIconType.stats: SolarIconsBold.pieChart,
  MeBeIconType.wonderWeeks: SolarIconsBold.cloudBolt,
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
  MeBeIconType.soundscapeMusic: SolarIconsBold.musicNote2,
  MeBeIconType.mapTrail: SolarIconsBold.route,
  MeBeIconType.moodTimelineRainbow: SolarIconsBold.starRainbow,
  MeBeIconType.timeCapsule: SolarIconsBold.box,
  MeBeIconType.temperature: SolarIconsBold.thermometer,
  MeBeIconType.motorSkill: SolarIconsBold.walkingRound,
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

// ── "Candy Crush gem" background — squircle + 3(/4)-stop radial gradient +
// tinted stroke + gloss highlight, matching the MeBé Icon Set design file
// exactly (one entry per redesigned MeBeIconType).
class _GemSpec {
  const _GemSpec(this.colors, this.stops, this.stroke);
  final List<Color> colors;
  final List<double> stops;
  final Color stroke;
}

const _gemSpecs = <MeBeIconType, _GemSpec>{
  MeBeIconType.home: _GemSpec(
    [Color(0xFFFF9EC8), Color(0xFFF472A0), Color(0xFFC23070)],
    [0.0, 0.55, 1.0],
    Color(0xFFE05590),
  ),
  MeBeIconType.bottle: _GemSpec(
    [Color(0xFFFFD4A8), Color(0xFFFFB997), Color(0xFFD4762A)],
    [0.0, 0.55, 1.0],
    Color(0xFFE0893A),
  ),
  MeBeIconType.sleep: _GemSpec(
    [Color(0xFFB8AAFF), Color(0xFF8B7FE8), Color(0xFF5044B8)],
    [0.0, 0.55, 1.0],
    Color(0xFF6055C8),
  ),
  MeBeIconType.diaper: _GemSpec(
    [Color(0xFFA8EED8), Color(0xFF7DE8C8), Color(0xFF28A878)],
    [0.0, 0.55, 1.0],
    Color(0xFF38B888),
  ),
  MeBeIconType.growth: _GemSpec(
    [Color(0xFFFFA8C8), Color(0xFFF472A0), Color(0xFFA83060)],
    [0.0, 0.55, 1.0],
    Color(0xFFD04080),
  ),
  MeBeIconType.vaccine: _GemSpec(
    [Color(0xFFFFE0A8), Color(0xFFFFB997), Color(0xFFCC6820)],
    [0.0, 0.55, 1.0],
    Color(0xFFD07828),
  ),
  MeBeIconType.memory: _GemSpec(
    [Color(0xFFE4C8FF), Color(0xFFC9A8F5), Color(0xFF8050CC)],
    [0.0, 0.55, 1.0],
    Color(0xFF9860DC),
  ),
  MeBeIconType.aiChat: _GemSpec(
    [Color(0xFFFFB8D0), Color(0xFFF472A0), Color(0xFFC9A8F5), Color(0xFF8050CC)],
    [0.0, 0.45, 0.75, 1.0],
    Color(0xFFB060D8),
  ),
  MeBeIconType.community: _GemSpec(
    [Color(0xFFFFD0A8), Color(0xFFFFB997), Color(0xFFC06020)],
    [0.0, 0.55, 1.0],
    Color(0xFFD07030),
  ),
  MeBeIconType.timer: _GemSpec(
    [Color(0xFFC8F0E8), Color(0xFF7DE8C8), Color(0xFF1890A0)],
    [0.0, 0.55, 1.0],
    Color(0xFF28A0B0),
  ),
  MeBeIconType.breastfeed: _GemSpec(
    [Color(0xFFFFD0E8), Color(0xFFF472A0), Color(0xFFA03060)],
    [0.0, 0.55, 1.0],
    Color(0xFFD04080),
  ),
  MeBeIconType.solidFood: _GemSpec(
    [Color(0xFFFFE0B8), Color(0xFFFFB997), Color(0xFFC06020)],
    [0.0, 0.55, 1.0],
    Color(0xFFD07030),
  ),
  MeBeIconType.photo: _GemSpec(
    [Color(0xFFFFD0E8), Color(0xFFF472A0), Color(0xFFC9A8F5), Color(0xFF7848C8)],
    [0.0, 0.45, 0.75, 1.0],
    Color(0xFFC060C8),
  ),
  MeBeIconType.calendar: _GemSpec(
    [Color(0xFFD8C8FF), Color(0xFFC9A8F5), Color(0xFF5838A8)],
    [0.0, 0.55, 1.0],
    Color(0xFF6848B8),
  ),
  MeBeIconType.profile: _GemSpec(
    [Color(0xFFFFD0E8), Color(0xFFF472A0), Color(0xFFA03068)],
    [0.0, 0.55, 1.0],
    Color(0xFFC04078),
  ),
  MeBeIconType.premium: _GemSpec(
    [Color(0xFFFFF0A0), Color(0xFFF0C020), Color(0xFFA07008)],
    [0.0, 0.50, 1.0],
    Color(0xFFC09010),
  ),
  MeBeIconType.letter: _GemSpec(
    [Color(0xFFE4D0FF), Color(0xFFC9A8F5), Color(0xFF6838B8)],
    [0.0, 0.55, 1.0],
    Color(0xFF7848C8),
  ),
  MeBeIconType.voiceJournal: _GemSpec(
    [Color(0xFFB8F0E0), Color(0xFF7DE8C8), Color(0xFF1880A0)],
    [0.0, 0.55, 1.0],
    Color(0xFF28A0B8),
  ),
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
        _paintBreastfeedGem(canvas);
      case MeBeIconType.baby:
      case MeBeIconType.babyHappy:
        _paintBreastfeed(canvas);
      case MeBeIconType.pump:
        _paintPump(canvas);
      case MeBeIconType.growth:
        _paintGrowth(canvas);
      case MeBeIconType.journal:
        _paintJournal(canvas);
      case MeBeIconType.memory:
        _paintMemory(canvas);
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

  /// Gem-style squircle background matching the MeBé Icon Set design:
  /// multi-stop radial gradient + tinted stroke. Falls back to the plain
  /// [_bg] look if this [type] has no [_gemSpecs] entry.
  void _bgGem(Canvas canvas) {
    final spec = _gemSpecs[type];
    if (spec == null) {
      _bg(canvas, Colors.white);
      return;
    }
    final rrect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2, 2, 44, 44),
      const Radius.circular(13),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(18.8, 16.2),
          28,
          spec.colors,
          spec.stops,
        ),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = spec.stroke
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

  // ── Home (house) ────────────────────────────────────────
  void _paintHome(Canvas canvas) {
    _bgGem(canvas);
    final s = 0.6; // 80->48 viewBox scale
    Offset p(double x, double y) => Offset(x * s, y * s);
    final house = Path()
      ..moveTo(p(40, 18).dx, p(40, 18).dy)
      ..lineTo(p(60, 36).dx, p(60, 36).dy)
      ..lineTo(p(55, 36).dx, p(55, 36).dy)
      ..lineTo(p(55, 58).dx, p(55, 58).dy)
      ..lineTo(p(46, 58).dx, p(46, 58).dy)
      ..lineTo(p(46, 46).dx, p(46, 46).dy)
      ..lineTo(p(34, 46).dx, p(34, 46).dy)
      ..lineTo(p(34, 58).dx, p(34, 58).dy)
      ..lineTo(p(25, 58).dx, p(25, 58).dy)
      ..lineTo(p(25, 36).dx, p(25, 36).dy)
      ..lineTo(p(20, 36).dx, p(20, 36).dy)
      ..close();
    canvas.drawPath(house, Paint()..color = Colors.white.withValues(alpha: 0.95));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(p(36, 47).dx, p(36, 47).dy, 8 * s, 11 * s),
        Radius.circular(3 * s),
      ),
      Paint()..color = _gemSpecs[type]!.colors[1].withValues(alpha: 0.6),
    );
  }

  // ── Sleep (moon + stars + zzz) ─────────────────────────
  void _paintSleep(Canvas canvas) {
    _bgGem(canvas);
    final full = Path()..addOval(Rect.fromCenter(center: const Offset(23.4, 18.6), width: 21.6, height: 21.6));
    final cut = Path()..addOval(Rect.fromCenter(center: const Offset(28.8, 15.6), width: 15.6, height: 15.6));
    final crescent = Path.combine(PathOperation.difference, full, cut);
    canvas.drawPath(crescent, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawCircle(const Offset(14.4, 15.6), 1.5, Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawCircle(const Offset(34.8, 31.2), 1.2, Paint()..color = Colors.white.withValues(alpha: 0.7));
    canvas.drawCircle(const Offset(33.6, 18), 0.9, Paint()..color = Colors.white.withValues(alpha: 0.6));
    final tp1 = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 9.6,
          fontWeight: FontWeight.w900,
          color: Colors.white.withValues(alpha: 0.85),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp1.paint(canvas, const Offset(14.5, 29));
    final tp2 = TextPainter(
      text: TextSpan(
        text: 'z',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 7.2,
          fontWeight: FontWeight.w900,
          color: Colors.white.withValues(alpha: 0.6),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp2.paint(canvas, const Offset(19, 24));
  }

  // ── Bottle ──────────────────────────────────────────────
  void _paintBottle(Canvas canvas) {
    _bgGem(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(19.8, 9.6, 8.4, 4.8), const Radius.circular(2.4)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(18, 13.2, 12, 21.6), const Radius.circular(6)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(19.2, 22.8, 9.6, 9.6), const Radius.circular(3.6)),
      Paint()..color = Colors.white.withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(21, 7.2, 6, 3.6), const Radius.circular(1.8)),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
  }

  // ── Diaper ──────────────────────────────────────────────
  void _paintDiaper(Canvas canvas) {
    _bgGem(canvas);
    final diaper = Path()
      ..moveTo(9.6, 16.8)
      ..quadraticBezierTo(14.4, 14.4, 24, 20.4)
      ..quadraticBezierTo(33.6, 14.4, 38.4, 16.8)
      ..lineTo(36, 34.8)
      ..quadraticBezierTo(30, 31.2, 24, 34.8)
      ..quadraticBezierTo(18, 31.2, 12, 34.8)
      ..close();
    canvas.drawPath(diaper, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(7.8, 14.4, 6, 4.8), const Radius.circular(2.4)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(34.2, 14.4, 6, 4.8), const Radius.circular(2.4)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawPath(
      Path()
        ..moveTo(18, 22.8)
        ..quadraticBezierTo(24, 26.4, 30, 22.8),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.5)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );
  }

  // ── Premium (crown + jewels) ───────────────────────────
  void _paintPremium(Canvas canvas) {
    _bgGem(canvas);
    final crown = Path()
      ..moveTo(8.4, 31.2)
      ..lineTo(8.4, 22.8)
      ..lineTo(15.6, 28.8)
      ..lineTo(24, 12)
      ..lineTo(32.4, 28.8)
      ..lineTo(39.6, 22.8)
      ..lineTo(39.6, 31.2)
      ..close();
    canvas.drawPath(crown, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8.4, 31.2, 31.2, 6), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawCircle(const Offset(24, 20.4), 3, Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.85));
    canvas.drawCircle(const Offset(13.2, 27.6), 2.4, Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.85));
    canvas.drawCircle(const Offset(34.8, 27.6), 2.4, Paint()..color = const Color(0xFF7DE8C8).withValues(alpha: 0.85));
  }

  // ── baby / happy (bunny + heart) — kept distinct from the
  // breastfeed gem illustration below.
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

  // ── Breastfeed (mom + baby silhouette + heart) ─────────
  void _paintBreastfeedGem(Canvas canvas) {
    _bgGem(canvas);
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(20.4, 13.2), width: 9.6, height: 10.8),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawPath(
      Path()
        ..moveTo(12, 37.2)
        ..quadraticBezierTo(12, 26.4, 20.4, 26.4)
        ..quadraticBezierTo(28.8, 26.4, 30, 31.2)
        ..lineTo(27.6, 37.2)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
    canvas.drawCircle(const Offset(31.2, 25.2), 4.2, Paint()..color = Colors.white.withValues(alpha: 0.85));
    canvas.drawPath(
      Path()
        ..moveTo(27, 28.8)
        ..quadraticBezierTo(30, 33.6, 34.8, 31.2)
        ..lineTo(33.6, 37.2)
        ..lineTo(22.8, 37.2),
      Paint()..color = Colors.white.withValues(alpha: 0.75),
    );
    _drawHeart(canvas, const Offset(22.8, 20.4), 5.5, const Color(0xFFFFB7CE).withValues(alpha: 0.85));
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

  // ── Growth (bar chart + trend arrow) ───────────────────
  void _paintGrowth(Canvas canvas) {
    _bgGem(canvas);
    final bars = [
      (9.6, 31.2, 6.0, 7.2, 0.5),
      (18.0, 25.2, 6.0, 13.2, 0.7),
      (26.4, 18.0, 6.0, 20.4, 0.85),
    ];
    for (final (x, y, w, h, a) in bars) {
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, y, w, h),
          topLeft: const Radius.circular(1.8),
          topRight: const Radius.circular(1.8),
        ),
        Paint()..color = Colors.white.withValues(alpha: a),
      );
    }
    final trend = Path()
      ..moveTo(10.8, 30)
      ..quadraticBezierTo(18, 16.8, 33.6, 10.8);
    canvas.drawPath(
      trend,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    final arrow = Path()
      ..moveTo(28.8, 8.4)
      ..lineTo(34.8, 10.8)
      ..lineTo(31.2, 15.6);
    canvas.drawPath(
      arrow,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ── Memory (heart + star) ──────────────────────────────
  void _paintMemory(Canvas canvas) {
    _bgGem(canvas);
    _drawHeart(canvas, const Offset(24, 27.6), 10, Colors.white.withValues(alpha: 0.92));
    _drawFilledStar(
      canvas,
      const Offset(24, 25.8),
      4.2,
      1.8,
      Paint()..color = _gemSpecs[type]!.colors[1].withValues(alpha: 0.7),
    );
  }

  // ── Journal (book) ──────────────────────────────────────
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
    _bgGem(canvas);
    canvas.drawCircle(const Offset(24, 18), 9.6, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawCircle(const Offset(21, 16.8), 1.5, Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.7));
    canvas.drawCircle(const Offset(27, 16.8), 1.5, Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.7));
    canvas.drawPath(
      Path()
        ..moveTo(20.4, 21)
        ..quadraticBezierTo(24, 24, 27.6, 21),
      Paint()
        ..color = const Color(0xFFF472A0).withValues(alpha: 0.7)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      Path()
        ..moveTo(9.6, 42)
        ..quadraticBezierTo(9.6, 31.2, 24, 31.2)
        ..quadraticBezierTo(38.4, 31.2, 38.4, 42),
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
    canvas.drawPath(
      Path()
        ..moveTo(19.2, 9.6)
        ..quadraticBezierTo(21.6, 12, 24, 9.6)
        ..quadraticBezierTo(26.4, 12, 28.8, 9.6)
        ..quadraticBezierTo(26.4, 14.4, 24, 12)
        ..quadraticBezierTo(21.6, 14.4, 19.2, 9.6)
        ..close(),
      Paint()..color = const Color(0xFFFFB7CE).withValues(alpha: 0.85),
    );
  }

  // ── Calendar (with marked day) ─────────────────────────
  void _paintCalendar(Canvas canvas) {
    _bgGem(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8.4, 14.4, 31.2, 27.6), const Radius.circular(4.8)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(8.4, 14.4, 31.2, 9.6), const Radius.circular(4.8)),
      Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.55),
    );
    canvas.drawRect(
      const Rect.fromLTWH(8.4, 19.2, 31.2, 4.8),
      Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.55),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(15.6, 9.6, 3, 8.4), const Radius.circular(1.5)),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(29.4, 9.6, 3, 8.4), const Radius.circular(1.5)),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    for (final dx in [15.6, 21.6, 27.6, 33.6]) {
      canvas.drawCircle(Offset(dx, 31.2), 1.8, Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.7));
    }
    for (final dx in [15.6, 21.6]) {
      canvas.drawCircle(Offset(dx, 37.2), 1.8, Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.5));
    }
    canvas.drawCircle(const Offset(27.6, 37.2), 3, Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.85));
  }

  // ── AI Chat (speech bubble + dots + sparkle) ───────────
  void _paintAiChat(Canvas canvas) {
    _bgGem(canvas);
    final bubble = Path()
      ..moveTo(8.4, 12)
      ..quadraticBezierTo(8.4, 8.4, 12, 8.4)
      ..lineTo(36, 8.4)
      ..quadraticBezierTo(39.6, 8.4, 39.6, 12)
      ..lineTo(39.6, 27.6)
      ..quadraticBezierTo(39.6, 31.2, 36, 31.2)
      ..lineTo(26.4, 31.2)
      ..lineTo(21.6, 37.2)
      ..lineTo(19.2, 31.2)
      ..lineTo(12, 31.2)
      ..quadraticBezierTo(8.4, 31.2, 8.4, 27.6)
      ..close();
    canvas.drawPath(bubble, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawCircle(const Offset(16.8, 19.8), 2.4, Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.8));
    canvas.drawCircle(const Offset(24, 19.8), 2.4, Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.8));
    canvas.drawCircle(const Offset(31.2, 19.8), 2.4, Paint()..color = const Color(0xFF7DE8C8).withValues(alpha: 0.8));
    _drawStar(canvas, const Offset(32.4, 10.2), 2.4, Colors.white.withValues(alpha: 0.8));
  }

  // ── Photo / gallery (stacked frames + heart) ───────────
  void _paintPhoto(Canvas canvas) {
    _bgGem(canvas);
    canvas.save();
    canvas.translate(25.2, 27);
    canvas.rotate(-8 * math.pi / 180);
    canvas.translate(-25.2, -27);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(14.4, 18, 21.6, 18), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.5),
    );
    canvas.restore();
    canvas.save();
    canvas.translate(22.8, 25.8);
    canvas.rotate(-3 * math.pi / 180);
    canvas.translate(-22.8, -25.8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(12, 16.8, 21.6, 18), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.restore();
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(10.8, 15.6, 21.6, 18), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(13.2, 18, 16.8, 10.8), const Radius.circular(1.8)),
      Paint()..color = const Color(0xFFFFD6E4).withValues(alpha: 0.6),
    );
    canvas.drawCircle(const Offset(16.8, 21.6), 2.4, Paint()..color = const Color(0xFFFFB997).withValues(alpha: 0.8));
    canvas.drawPath(
      Path()
        ..moveTo(13.2, 28.8)
        ..lineTo(18, 22.8)
        ..lineTo(21.6, 26.4)
        ..lineTo(25.2, 21.6)
        ..lineTo(30, 28.8)
        ..close(),
      Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.6),
    );
    _drawHeart(canvas, const Offset(24, 15.6), 5, Colors.white.withValues(alpha: 0.9));
  }

  // ── Timer (clock face) ─────────────────────────────────
  void _paintTimer(Canvas canvas) {
    _bgGem(canvas);
    canvas.drawCircle(const Offset(24, 26.4), 13.2, Paint()..color = Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(
      const Offset(24, 26.4),
      10.2,
      Paint()
        ..color = const Color(0xFF7DE8C8).withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9,
    );
    canvas.drawLine(
      const Offset(24, 26.4),
      const Offset(24, 18),
      Paint()
        ..color = const Color(0xFF28A0B0)
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(24, 26.4),
      const Offset(31.2, 30),
      Paint()
        ..color = const Color(0xFF7DE8C8)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(const Offset(24, 26.4), 1.5, Paint()..color = const Color(0xFF28A0B0));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(21.6, 10.8, 4.8, 3.6), const Radius.circular(1.8)),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(19.2, 13.2, 9.6, 2.4), const Radius.circular(1.2)),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
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
    _bgGem(canvas);
    final bowl = Path()
      ..moveTo(10.8, 27.6)
      ..quadraticBezierTo(10.8, 37.2, 24, 37.2)
      ..quadraticBezierTo(37.2, 37.2, 37.2, 27.6)
      ..close();
    canvas.drawPath(bowl, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24, 27.6), width: 26.4, height: 7.2),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(24, 27.6), width: 16.8, height: 4.8),
      Paint()..color = const Color(0xFFFFB997).withValues(alpha: 0.55),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(32.4, 14.4), width: 7.2, height: 9.6),
      Paint()..color = Colors.white.withValues(alpha: 0.9),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(31.5, 18.6, 1.8, 13.2), const Radius.circular(0.9)),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
    canvas.drawCircle(const Offset(16.8, 19.2), 1.8, Paint()..color = Colors.white.withValues(alpha: 0.7));
    canvas.drawCircle(const Offset(14.4, 14.4), 1.2, Paint()..color = Colors.white.withValues(alpha: 0.5));
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

  // ── Vaccine (syringe + shield check) ───────────────────
  void _paintVaccine(Canvas canvas) {
    _bgGem(canvas);
    canvas.save();
    canvas.translate(26.4, 24.6);
    canvas.rotate(-math.pi / 4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-9.6, -3, 19.2, 6), const Radius.circular(3)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(-16.2, -1.8, 3.6, 8.4), const Radius.circular(1.8)),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.restore();
    canvas.drawLine(
      const Offset(33, 15.6),
      const Offset(39, 9.6),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 2.1
        ..strokeCap = StrokeCap.round,
    );
    final shield = Path()
      ..moveTo(10.8, 31.2)
      ..quadraticBezierTo(10.8, 38.4, 16.8, 40.8)
      ..quadraticBezierTo(22.8, 38.4, 22.8, 31.2)
      ..lineTo(16.8, 28.8)
      ..close();
    canvas.drawPath(shield, Paint()..color = Colors.white.withValues(alpha: 0.8));
    canvas.drawPath(
      Path()
        ..moveTo(13.2, 36)
        ..lineTo(16.2, 39)
        ..lineTo(20.4, 33.6),
      Paint()
        ..color = _gemSpecs[type]!.colors[1].withValues(alpha: 0.9)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
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

  // ── Letter (envelope + wax seal + clock) ───────────────
  void _paintLetter(Canvas canvas) {
    _bgGem(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(7.2, 15.6, 33.6, 22.8), const Radius.circular(3.6)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawPath(
      Path()
        ..moveTo(7.2, 15.6)
        ..lineTo(24, 27.6)
        ..lineTo(40.8, 15.6),
      Paint()
        ..color = const Color(0xFFC9A8F5).withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(const Offset(24, 31.2), 6, Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.85));
    _drawHeart(canvas, const Offset(24, 31.2), 3, Colors.white.withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(34.8, 13.2), 5.4, Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.85));
    canvas.drawLine(
      const Offset(34.2, 13.8),
      const Offset(34.2, 10.8),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      const Offset(34.2, 13.8),
      const Offset(37.2, 15.6),
      Paint()
        ..color = Colors.white
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round,
    );
  }

  // ── Voice journal (microphone + sound waves) ───────────
  void _paintVoiceJournal(Canvas canvas) {
    _bgGem(canvas);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(19.2, 8.4, 9.6, 16.8), const Radius.circular(4.8)),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    for (final y in [13.2, 16.2, 19.2]) {
      canvas.drawLine(
        Offset(20.4, y),
        Offset(27.6, y),
        Paint()
          ..color = const Color(0xFF7DE8C8).withValues(alpha: 0.6)
          ..strokeWidth = 0.9,
      );
    }
    canvas.drawPath(
      Path()
        ..moveTo(13.2, 24)
        ..quadraticBezierTo(13.2, 34.8, 24, 34.8)
        ..quadraticBezierTo(34.8, 34.8, 34.8, 24),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.88)
        ..strokeWidth = 2.4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(22.2, 33.6, 3.6, 7.2), const Radius.circular(1.8)),
      Paint()..color = Colors.white.withValues(alpha: 0.88),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(16.8, 39.6, 14.4, 3), const Radius.circular(1.5)),
      Paint()..color = Colors.white.withValues(alpha: 0.8),
    );
    final wavePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(Path()..moveTo(8.4, 21.6)..quadraticBezierTo(9.6, 24, 8.4, 26.4), wavePaint..color = Colors.white.withValues(alpha: 0.65));
    canvas.drawPath(Path()..moveTo(6, 19.2)..quadraticBezierTo(7.8, 24, 6, 28.8), wavePaint..color = Colors.white.withValues(alpha: 0.45));
    canvas.drawPath(Path()..moveTo(39.6, 21.6)..quadraticBezierTo(38.4, 24, 39.6, 26.4), wavePaint..color = Colors.white.withValues(alpha: 0.65));
    canvas.drawPath(Path()..moveTo(42, 19.2)..quadraticBezierTo(40.2, 24, 42, 28.8), wavePaint..color = Colors.white.withValues(alpha: 0.45));
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
    _bgGem(canvas);
    canvas.drawCircle(const Offset(24, 18), 5.4, Paint()..color = Colors.white.withValues(alpha: 0.92));
    canvas.drawPath(
      Path()
        ..moveTo(14.4, 34.8)
        ..quadraticBezierTo(14.4, 26.4, 24, 26.4)
        ..quadraticBezierTo(33.6, 26.4, 33.6, 34.8),
      Paint()..color = Colors.white.withValues(alpha: 0.92),
    );
    canvas.drawCircle(const Offset(13.2, 20.4), 4.2, Paint()..color = Colors.white.withValues(alpha: 0.75));
    canvas.drawPath(
      Path()
        ..moveTo(6, 34.8)
        ..quadraticBezierTo(6, 27.6, 13.2, 27.6)
        ..quadraticBezierTo(19.2, 27.6, 19.2, 32.4),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
    canvas.drawCircle(const Offset(34.8, 20.4), 4.2, Paint()..color = Colors.white.withValues(alpha: 0.75));
    canvas.drawPath(
      Path()
        ..moveTo(42, 34.8)
        ..quadraticBezierTo(42, 27.6, 34.8, 27.6)
        ..quadraticBezierTo(28.8, 27.6, 28.8, 32.4),
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );
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
