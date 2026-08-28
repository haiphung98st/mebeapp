import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'baby_book_frame.dart';

/// Renders one Baby Book page (photo collage + measurements/milestones) at
/// A4-landscape print resolution (2480×1860, 300dpi).
class BabyBookPagePainter extends CustomPainter {
  BabyBookPagePainter({
    required this.layout,
    required this.mainPhoto,
    required this.miniPhotos,
    required this.data,
    this.photoFilter,
  });

  static const width = 2480.0;
  static const height = 1860.0;

  final BookLayout layout;
  final ui.Image? mainPhoto;
  final List<ui.Image?> miniPhotos;
  final BabyBookPageData data;
  final ColorFilter? photoFilter;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / width;
    canvas.save();
    canvas.scale(scale, scale);
    switch (layout) {
      case BookLayout.monthlyAlbum:
        _paintMonthlyAlbum(canvas);
      case BookLayout.moonlightDark:
        _paintMoonlightDark(canvas);
    }
    canvas.restore();
  }

  void _paintMonthlyAlbum(Canvas canvas) {
    canvas.drawRect(const Rect.fromLTWH(0, 0, width, height), Paint()..color = const Color(0xFFFFF6FA));

    final mainRect = const Rect.fromLTWH(100, 100, 1280, 1660);
    _drawPhoto(canvas, mainRect, mainPhoto, radius: 32, borderColor: Colors.white, borderWidth: 14);

    final textX = 1480.0;
    _drawText(canvas, data.title, Offset(textX, 160), fontSize: 34, fontWeight: FontWeight.w700, color: const Color(0xFFF472A0), align: TextAlign.left);
    _drawText(canvas, data.babyName, Offset(textX, 220), fontSize: 76, fontWeight: FontWeight.w900, color: const Color(0xFF8B2252), align: TextAlign.left);
    _drawText(canvas, data.dateRange, Offset(textX, 320), fontSize: 32, color: const Color(0xFFB86A8C), align: TextAlign.left);

    var statsY = 420.0;
    for (final stat in [
      if (data.weight != null) '⚖️  ${data.weight}',
      if (data.height != null) '📏  ${data.height}',
    ]) {
      _drawText(canvas, stat, Offset(textX, statsY), fontSize: 36, fontWeight: FontWeight.w700, color: const Color(0xFF5A2A45), align: TextAlign.left);
      statsY += 60;
    }

    if (data.milestones != null) {
      _drawText(canvas, 'CỘT MỐC', Offset(textX, statsY + 30), fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFFF472A0), align: TextAlign.left);
      _drawWrappedText(canvas, data.milestones!, Rect.fromLTWH(textX, statsY + 70, 820, 200), fontSize: 30, color: const Color(0xFF5A2A45));
    }

    if (data.tagline != null) {
      _drawText(canvas, '"${data.tagline}"', Offset(textX, height - 260), fontSize: 34, fontWeight: FontWeight.w700, color: const Color(0xFFF472A0), align: TextAlign.left);
    }

    // Mini photos row
    var miniX = textX;
    for (final mini in miniPhotos.take(3)) {
      _drawPhoto(canvas, Rect.fromLTWH(miniX, height - 190, 250, 130), mini, radius: 12, borderColor: Colors.white, borderWidth: 6);
      miniX += 270;
    }

    _drawText(canvas, 'MeBé Tracker 🌸', Offset(textX, height - 60), fontSize: 22, color: const Color(0xFFF472A0).withValues(alpha: 0.5), align: TextAlign.left);
  }

  void _paintMoonlightDark(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..shader = ui.Gradient.linear(Offset.zero, const Offset(0, height), [const Color(0xFF241B4E), const Color(0xFF140C33)]),
    );

    const cx = 640.0, cy = 900.0, r = 620.0;
    _drawCirclePhoto(canvas, const Offset(cx, cy), r, mainPhoto, borderColor: const Color(0xFFC9A8F5), borderWidth: 18);

    final textX = 1400.0;
    _drawText(canvas, data.title, Offset(textX, 300), fontSize: 32, color: const Color(0xFFC9A8F5), align: TextAlign.left);
    _drawText(canvas, data.babyName, Offset(textX, 360), fontSize: 84, fontWeight: FontWeight.w900, color: Colors.white, align: TextAlign.left);
    _drawText(canvas, data.dateRange, Offset(textX, 470), fontSize: 32, color: const Color(0xFFC9A8F5), align: TextAlign.left);

    var statsY = 580.0;
    for (final stat in [
      if (data.weight != null) '⚖️  ${data.weight}',
      if (data.height != null) '📏  ${data.height}',
    ]) {
      _drawText(canvas, stat, Offset(textX, statsY), fontSize: 36, fontWeight: FontWeight.w700, color: const Color(0xFFFDE68A), align: TextAlign.left);
      statsY += 60;
    }

    if (data.milestones != null) {
      _drawWrappedText(canvas, data.milestones!, Rect.fromLTWH(textX, statsY + 30, 900, 260), fontSize: 30, color: Colors.white.withValues(alpha: 0.85));
    }

    if (data.tagline != null) {
      _drawText(canvas, '"${data.tagline}"', Offset(textX, height - 260), fontSize: 34, fontWeight: FontWeight.w700, color: const Color(0xFFFDE68A), align: TextAlign.left);
    }

    _drawText(canvas, 'MeBé Tracker 🌙', Offset(textX, height - 70), fontSize: 22, color: const Color(0xFFC9A8F5).withValues(alpha: 0.6), align: TextAlign.left);
  }

  // ── Helpers ────────────────────────────────────────────────
  void _drawPhoto(Canvas canvas, Rect rect, ui.Image? photo, {required double radius, required Color borderColor, required double borderWidth}) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect.inflate(borderWidth), Paint()..color = borderColor);
    if (photo != null) {
      canvas.save();
      canvas.clipRRect(rrect);
      paintImage(canvas: canvas, rect: rect, image: photo, fit: BoxFit.cover, colorFilter: photoFilter);
      canvas.restore();
    } else {
      canvas.drawRRect(rrect, Paint()..color = Colors.grey.withValues(alpha: 0.25));
    }
  }

  void _drawCirclePhoto(Canvas canvas, Offset center, double radius, ui.Image? photo, {required Color borderColor, required double borderWidth}) {
    canvas.drawCircle(center, radius + borderWidth, Paint()..color = borderColor);
    if (photo != null) {
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
      paintImage(canvas: canvas, rect: Rect.fromCircle(center: center, radius: radius), image: photo, fit: BoxFit.cover, colorFilter: photoFilter);
      canvas.restore();
    } else {
      canvas.drawCircle(center, radius, Paint()..color = Colors.white.withValues(alpha: 0.12));
    }
  }

  void _drawText(Canvas canvas, String text, Offset origin, {double fontSize = 40, FontWeight fontWeight = FontWeight.w400, Color color = Colors.black, TextAlign align = TextAlign.center}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color)),
      textAlign: align,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - origin.dx - 100);
    tp.paint(canvas, align == TextAlign.left ? origin : origin - Offset(tp.width / 2, 0));
  }

  void _drawWrappedText(Canvas canvas, String text, Rect rect, {double fontSize = 30, Color color = Colors.black}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, color: color, height: 1.4)),
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: rect.width);
    tp.paint(canvas, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant BabyBookPagePainter old) => true;
}

/// Renders a printable A4-portrait Growth Poster (2480×3508, 300dpi).
class GrowthPosterPainter extends CustomPainter {
  GrowthPosterPainter({required this.theme, required this.photo, required this.data, this.photoFilter});

  static const width = 2480.0;
  static const height = 3508.0;

  final PosterTheme theme;
  final ui.Image? photo;
  final GrowthPosterData data;
  final ColorFilter? photoFilter;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / width;
    canvas.save();
    canvas.scale(scale, scale);
    switch (theme) {
      case PosterTheme.blossom:
        _paintBlossom(canvas);
      case PosterTheme.starryNight:
        _paintStarryNight(canvas);
    }
    canvas.restore();
  }

  void _paintBlossom(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..shader = ui.Gradient.linear(Offset.zero, const Offset(0, height), [const Color(0xFFFFF0F8), const Color(0xFFFFE0EF)]),
    );
    final photoRect = const Rect.fromLTWH(240, 240, 2000, 2000);
    _drawPhoto(canvas, photoRect, borderColor: Colors.white, borderWidth: 24, radius: 60);
    _drawCenteredText(canvas, data.babyName, 2420, fontSize: 130, fontWeight: FontWeight.w900, color: const Color(0xFFC9184A));
    _drawCenteredText(canvas, '${data.ageText} · ${data.dateText}', 2560, fontSize: 62, color: const Color(0xFFF472A0));

    var y = 2700.0;
    for (final stat in [
      if (data.weight != null) 'Cân nặng: ${data.weight}',
      if (data.height != null) 'Chiều cao: ${data.height}',
    ]) {
      _drawCenteredText(canvas, stat, y, fontSize: 56, fontWeight: FontWeight.w700, color: const Color(0xFF5A2A45));
      y += 90;
    }
    if (data.milestones != null) {
      _drawCenteredText(canvas, data.milestones!, y + 30, fontSize: 50, color: const Color(0xFF8B2252));
      y += 120;
    }
    if (data.quote != null) {
      _drawCenteredText(canvas, '"${data.quote}"', height - 260, fontSize: 58, fontWeight: FontWeight.w700, color: const Color(0xFFF472A0));
    }
    _drawCenteredText(canvas, 'MeBé Tracker 🌸', height - 100, fontSize: 40, color: const Color(0xFFF472A0).withValues(alpha: 0.5));
  }

  void _paintStarryNight(Canvas canvas) {
    canvas.drawRect(
      const Rect.fromLTWH(0, 0, width, height),
      Paint()..shader = ui.Gradient.linear(Offset.zero, const Offset(0, height), [const Color(0xFF2D1B69), const Color(0xFF140C33)]),
    );
    final photoRect = const Rect.fromLTWH(240, 240, 2000, 2000);
    _drawPhoto(canvas, photoRect, borderColor: const Color(0xFFC9A8F5), borderWidth: 24, radius: 60, isCircleFallback: true);
    _drawCenteredText(canvas, data.babyName, 2420, fontSize: 130, fontWeight: FontWeight.w900, color: Colors.white);
    _drawCenteredText(canvas, '${data.ageText} · ${data.dateText}', 2560, fontSize: 62, color: const Color(0xFFC9A8F5));

    var y = 2700.0;
    for (final stat in [
      if (data.weight != null) 'Cân nặng: ${data.weight}',
      if (data.height != null) 'Chiều cao: ${data.height}',
    ]) {
      _drawCenteredText(canvas, stat, y, fontSize: 56, fontWeight: FontWeight.w700, color: const Color(0xFFFDE68A));
      y += 90;
    }
    if (data.milestones != null) {
      _drawCenteredText(canvas, data.milestones!, y + 30, fontSize: 50, color: Colors.white.withValues(alpha: 0.85));
      y += 120;
    }
    if (data.quote != null) {
      _drawCenteredText(canvas, '"${data.quote}"', height - 260, fontSize: 58, fontWeight: FontWeight.w700, color: const Color(0xFFFDE68A));
    }
    _drawCenteredText(canvas, 'MeBé Tracker 🌙', height - 100, fontSize: 40, color: const Color(0xFFC9A8F5).withValues(alpha: 0.5));
  }

  void _drawPhoto(Canvas canvas, Rect rect, {required Color borderColor, required double borderWidth, required double radius, bool isCircleFallback = false}) {
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect.inflate(borderWidth), Paint()..color = borderColor);
    if (photo != null) {
      canvas.save();
      canvas.clipRRect(rrect);
      paintImage(canvas: canvas, rect: rect, image: photo!, fit: BoxFit.cover, colorFilter: photoFilter);
      canvas.restore();
    } else {
      canvas.drawRRect(rrect, Paint()..color = Colors.white.withValues(alpha: isCircleFallback ? 0.1 : 0.6));
    }
  }

  void _drawCenteredText(Canvas canvas, String text, double y, {double fontSize = 60, FontWeight fontWeight = FontWeight.w400, Color color = Colors.white}) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: width - 200);
    tp.paint(canvas, Offset(width / 2 - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(covariant GrowthPosterPainter old) => true;
}
