import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'story_frame.dart';

/// Renders a [StoryFrameStyle] onto a 1080×1920 (9:16) canvas — sized to
/// scale down for on-screen preview or export 1:1 as a share-ready PNG.
class StoryFramePainter extends CustomPainter {
  StoryFramePainter({
    required this.style,
    required this.photo,
    required this.babyName,
    required this.dateText,
    this.tagline,
    this.photoFilter,
  });

  static const width = 1080.0;
  static const height = 1920.0;

  final StoryFrameStyle style;
  final ui.Image? photo;
  final String babyName;
  final String dateText;
  final String? tagline;

  /// Optional adjustment (e.g. warmth) applied only when drawing the photo —
  /// the source image bytes are never modified, so switching frames or
  /// filters is instant and non-destructive.
  final ColorFilter? photoFilter;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / width;
    canvas.save();
    canvas.scale(scale, scale);
    switch (style) {
      case StoryFrameStyle.blossomGarden:
        _paintBlossomGarden(canvas);
      case StoryFrameStyle.bunnyCute:
        _paintBunnyCute(canvas);
      case StoryFrameStyle.starryNight:
        _paintStarryNight(canvas);
      case StoryFrameStyle.vintagePolaroid:
        _paintVintagePolaroid(canvas);
    }
    canvas.restore();
  }

  // ── Blossom Garden (free) ────────────────────────────────
  void _paintBlossomGarden(Canvas canvas) {
    final bg = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bg, const Radius.circular(60)),
      Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(1080, 1920), [
          const Color(0xFFFFF0F8),
          const Color(0xFFFFD6EC),
        ]),
    );
    _drawDashedBorder(canvas, const Color(0xFFF472A0));
    _drawFloralCorner(canvas, const Offset(130, 90), const Color(0xFFF472A0), flipX: false, flipY: false);
    _drawFloralCorner(canvas, const Offset(950, 90), const Color(0xFFF472A0), flipX: true, flipY: false);

    final photoRect = const Rect.fromLTWH(80, 220, 920, 920);
    _drawPhotoOrPlaceholder(canvas, photoRect, borderRadius: 50, borderColor: Colors.white, borderWidth: 16);

    _drawText(canvas, babyName, const Offset(540, 1220), fontSize: 80, fontWeight: FontWeight.w900, color: const Color(0xFFC9184A));
    _drawText(canvas, dateText, const Offset(540, 1320), fontSize: 48, color: const Color(0xFFF472A0));

    if (tagline != null && tagline!.isNotEmpty) {
      final tagRect = const Rect.fromLTWH(80, 1380, 920, 100);
      canvas.drawRRect(
        RRect.fromRectAndRadius(tagRect, const Radius.circular(50)),
        Paint()..color = const Color(0xFFF472A0).withValues(alpha: 0.12),
      );
      _drawText(canvas, tagline!, const Offset(540, 1430), fontSize: 52, fontWeight: FontWeight.w700, color: const Color(0xFFC9184A));
    }

    _drawStars(canvas, [const Offset(540, 1560), const Offset(440, 1580), const Offset(640, 1580)], const Color(0xFFFFD580), 24);
    _drawText(canvas, 'MeBé Tracker 🌸', const Offset(540, 1840), fontSize: 36, color: const Color(0xFFF472A0).withValues(alpha: 0.5));
  }

  // ── Bunny Cute (free) ─────────────────────────────────────
  void _paintBunnyCute(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, width, height), const Radius.circular(60)),
      Paint()..color = const Color(0xFFFFF8FB),
    );
    // Dotted border
    final rng = math.Random(7);
    for (var i = 0; i < 90; i++) {
      final t = i / 90;
      final perim = 2 * (width - 80) + 2 * (height - 80);
      final d = t * perim;
      Offset pt;
      if (d < width - 80) {
        pt = Offset(40 + d, 40);
      } else if (d < (width - 80) + (height - 80)) {
        pt = Offset(width - 40, 40 + (d - (width - 80)));
      } else if (d < 2 * (width - 80) + (height - 80)) {
        pt = Offset(width - 40 - (d - (width - 80) - (height - 80)), height - 40);
      } else {
        pt = Offset(40, height - 40 - (d - 2 * (width - 80) - (height - 80)));
      }
      canvas.drawCircle(pt, 6 + rng.nextDouble() * 3, Paint()..color = const Color(0xFFC9A8F5).withValues(alpha: 0.6));
    }

    // Bunny ears above photo
    final earPaint = Paint()..color = const Color(0xFFFFD6EC);
    canvas.save();
    canvas.translate(430, 130);
    canvas.rotate(-0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 90, height: 180), earPaint);
    canvas.restore();
    canvas.save();
    canvas.translate(650, 130);
    canvas.rotate(0.25);
    canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: 90, height: 180), earPaint);
    canvas.restore();

    final photoRect = const Rect.fromLTWH(90, 240, 900, 900);
    _drawPhotoOrPlaceholder(canvas, photoRect, borderRadius: 450, borderColor: const Color(0xFFF9A8CB), borderWidth: 18, isCircle: true);

    _drawText(canvas, babyName, const Offset(540, 1260), fontSize: 80, fontWeight: FontWeight.w900, color: const Color(0xFF8B5CF6));
    _drawText(canvas, dateText, const Offset(540, 1360), fontSize: 46, color: const Color(0xFFC9A8F5));

    if (tagline != null && tagline!.isNotEmpty) {
      _drawText(canvas, tagline!, const Offset(540, 1460), fontSize: 50, fontWeight: FontWeight.w700, color: const Color(0xFFF472A0));
    }

    _drawText(canvas, '🐰 MeBé Tracker', const Offset(540, 1850), fontSize: 36, color: const Color(0xFFC9A8F5).withValues(alpha: 0.6));
  }

  // ── Starry Night (premium) ────────────────────────────────
  void _paintStarryNight(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, width, height), const Radius.circular(60)),
      Paint()..shader = ui.Gradient.linear(Offset.zero, const Offset(0, 1920), [const Color(0xFF2D1B69), const Color(0xFF1A0F4A)]),
    );

    final rng = math.Random(42);
    for (var i = 0; i < 80; i++) {
      final x = rng.nextDouble() * width;
      final y = rng.nextDouble() * height;
      final r = 2.0 + rng.nextDouble() * 3;
      canvas.drawCircle(Offset(x, y), r, Paint()..color = Colors.white.withValues(alpha: 0.3 + rng.nextDouble() * 0.5));
    }

    canvas.drawCircle(const Offset(880, 170), 90, Paint()..color = const Color(0xFFFDE68A).withValues(alpha: 0.9));
    canvas.drawCircle(const Offset(915, 145), 74, Paint()..color = const Color(0xFF2D1B69));

    const cx = 540.0, cy = 860.0, r = 380.0;
    _drawPhotoOrPlaceholder(
      canvas,
      Rect.fromCircle(center: const Offset(cx, cy), radius: r),
      borderRadius: r,
      borderColor: const Color(0xFFC9A8F5),
      borderWidth: 12,
      isCircle: true,
    );

    _drawText(canvas, babyName, const Offset(540, 1340), fontSize: 90, fontWeight: FontWeight.w900, color: Colors.white);
    _drawText(canvas, dateText, const Offset(540, 1440), fontSize: 50, color: const Color(0xFFC9A8F5));

    if (tagline != null && tagline!.isNotEmpty) {
      _drawText(canvas, tagline!, const Offset(540, 1540), fontSize: 52, color: const Color(0xFFFDE68A));
    }

    _drawCloud(canvas, const Offset(150, 1720), 120, 60);
    _drawCloud(canvas, const Offset(920, 1750), 100, 50);
    _drawText(canvas, 'MeBé Tracker 🌙', const Offset(540, 1860), fontSize: 36, color: const Color(0xFFC9A8F5).withValues(alpha: 0.5));
  }

  // ── Vintage Polaroid (premium) ────────────────────────────
  void _paintVintagePolaroid(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, width, height), const Radius.circular(60)),
      Paint()..color = const Color(0xFFFAFAF5),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(40, 40, 1000, 1840), const Radius.circular(40)),
      Paint()
        ..color = const Color(0xFFD4C5A0)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );
    _drawTape(canvas, const Offset(340, 40), const Color(0xFFFFD580), 400, 60);

    final photoRect = const Rect.fromLTWH(80, 100, 920, 920);
    _drawPhotoOrPlaceholder(canvas, photoRect, borderRadius: 24, borderColor: const Color(0xFFF0EAD8), borderWidth: 20);

    _drawText(canvas, babyName, const Offset(540, 1120), fontSize: 100, fontWeight: FontWeight.w900, color: const Color(0xFF5A4230));
    canvas.drawLine(
      const Offset(100, 1180),
      const Offset(980, 1180),
      Paint()
        ..color = const Color(0xFFD4C5A0)
        ..strokeWidth = 3,
    );
    _drawText(canvas, dateText, const Offset(540, 1260), fontSize: 52, color: const Color(0xFF8A7060));
    if (tagline != null && tagline!.isNotEmpty) {
      _drawText(canvas, tagline!, const Offset(540, 1360), fontSize: 52, color: const Color(0xFF8A7060));
    }

    _drawStamp(canvas, const Offset(270, 1560), 'BABY', const Color(0xFFF472A0));
    _drawStamp(canvas, const Offset(540, 1560), 'LOVE', const Color(0xFF3ABFA0));
    _drawStamp(canvas, const Offset(810, 1560), '2026', const Color(0xFFF59E0B));

    _drawText(canvas, 'MeBé Tracker 📷', const Offset(540, 1850), fontSize: 36, color: const Color(0xFFB8A07A).withValues(alpha: 0.6));
  }

  // ── Shared drawing helpers ────────────────────────────────

  void _drawPhotoOrPlaceholder(
    Canvas canvas,
    Rect rect, {
    required double borderRadius,
    required Color borderColor,
    required double borderWidth,
    bool isCircle = false,
  }) {
    if (isCircle) {
      final center = rect.center;
      final radius = rect.width / 2;
      canvas.drawCircle(center, radius + borderWidth, Paint()..color = borderColor);
      if (photo != null) {
        canvas.save();
        canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
        paintImage(
          canvas: canvas,
          rect: Rect.fromCircle(center: center, radius: radius),
          image: photo!,
          fit: BoxFit.cover,
          colorFilter: photoFilter,
        );
        canvas.restore();
      } else {
        canvas.drawCircle(center, radius, Paint()..color = Colors.white.withValues(alpha: 0.6));
        canvas.drawCircle(
          center,
          radius * 0.5,
          Paint()
            ..color = borderColor.withValues(alpha: 0.5)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 4,
        );
      }
      return;
    }
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    canvas.drawRRect(rrect.inflate(borderWidth), Paint()..color = borderColor);
    if (photo != null) {
      canvas.save();
      canvas.clipRRect(rrect);
      paintImage(canvas: canvas, rect: rect, image: photo!, fit: BoxFit.cover, colorFilter: photoFilter);
      canvas.restore();
    } else {
      canvas.drawRRect(rrect, Paint()..color = Colors.white.withValues(alpha: 0.6));
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center, {
    double fontSize = 60,
    FontWeight fontWeight = FontWeight.w400,
    Color color = Colors.white,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color)),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 1000);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawDashedBorder(Canvas canvas, Color color) {
    final rect = const Rect.fromLTWH(20, 20, width - 40, height - 40);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));
    final path = Path()..addRRect(rrect);
    final dashPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final metric = path.computeMetrics().first;
    double distance = 0;
    var draw = true;
    while (distance < metric.length) {
      const dashLen = 24.0, gapLen = 18.0;
      final seg = draw ? dashLen : gapLen;
      if (draw) {
        canvas.drawPath(metric.extractPath(distance, math.min(distance + seg, metric.length)), dashPaint);
      }
      distance += seg;
      draw = !draw;
    }
  }

  void _drawFloralCorner(Canvas canvas, Offset center, Color color, {required bool flipX, required bool flipY}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.scale(flipX ? -1 : 1, flipY ? -1 : 1);
    canvas.drawCircle(Offset.zero, 44, Paint()..color = color.withValues(alpha: 0.5));
    canvas.drawCircle(Offset.zero, 24, Paint()..color = color);
    canvas.drawCircle(const Offset(-50, 18), 26, Paint()..color = color.withValues(alpha: 0.4));
    canvas.drawCircle(const Offset(18, -50), 24, Paint()..color = color.withValues(alpha: 0.4));
    canvas.restore();
  }

  void _drawStars(Canvas canvas, List<Offset> centers, Color color, double size) {
    for (final center in centers) {
      final path = Path();
      for (var i = 0; i < 5; i++) {
        final outerAngle = (i * 72 - 90) * math.pi / 180;
        final innerAngle = ((i * 72 + 36) - 90) * math.pi / 180;
        final ox = center.dx + size * math.cos(outerAngle);
        final oy = center.dy + size * math.sin(outerAngle);
        final ix = center.dx + size * 0.4 * math.cos(innerAngle);
        final iy = center.dy + size * 0.4 * math.sin(innerAngle);
        if (i == 0) {
          path.moveTo(ox, oy);
        } else {
          path.lineTo(ox, oy);
        }
        path.lineTo(ix, iy);
      }
      path.close();
      canvas.drawPath(path, Paint()..color = color);
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double w, double h) {
    canvas.drawOval(Rect.fromCenter(center: center, width: w, height: h), Paint()..color = Colors.white.withValues(alpha: 0.08));
    canvas.drawOval(
      Rect.fromCenter(center: center.translate(-w * 0.2, -h * 0.2), width: w * 0.7, height: h * 0.8),
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );
  }

  void _drawTape(Canvas canvas, Offset topLeft, Color color, double w, double h) {
    canvas.save();
    canvas.translate(topLeft.dx, topLeft.dy);
    canvas.rotate(-0.035);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), const Radius.circular(6)),
      Paint()..color = color.withValues(alpha: 0.4),
    );
    canvas.restore();
  }

  void _drawStamp(Canvas canvas, Offset center, String text, Color color) {
    final rect = Rect.fromCenter(center: center, width: 220, height: 120);
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(12)), Paint()..color = color.withValues(alpha: 0.15));
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    _drawText(canvas, text, center, fontSize: 48, fontWeight: FontWeight.w900, color: color.withValues(alpha: 0.7));
  }

  @override
  bool shouldRepaint(covariant StoryFramePainter old) =>
      old.style != style ||
      old.photo != photo ||
      old.babyName != babyName ||
      old.dateText != dateText ||
      old.tagline != tagline ||
      old.photoFilter != photoFilter;
}
