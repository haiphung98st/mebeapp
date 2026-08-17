import 'package:flutter/material.dart';

import '../../../../shared/models/baby_profile.dart';
import '../../../../shared/models/growth_entry.dart';

class GrowthPosterWidget extends StatelessWidget {
  const GrowthPosterWidget({
    super.key,
    required this.baby,
    required this.entries,
    required this.theme,
  });

  final BabyProfile baby;
  final List<GrowthEntry> entries;
  final String theme; // 'blossom'|'lavender'|'mint'|'gold'

  static const _themes = {
    'blossom': _PosterTheme(
      gradient: LinearGradient(
        colors: [Color(0xFFFFB7CE), Color(0xFFF472A0)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: Color(0xFFF472A0),
      bg: Color(0xFFFFE4EF),
      text: Color(0xFF8B2252),
    ),
    'lavender': _PosterTheme(
      gradient: LinearGradient(
        colors: [Color(0xFFDFC8FF), Color(0xFFA67CD8)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: Color(0xFFA67CD8),
      bg: Color(0xFFF0E8FF),
      text: Color(0xFF5E3A8C),
    ),
    'mint': _PosterTheme(
      gradient: LinearGradient(
        colors: [Color(0xFF7DE8C8), Color(0xFF34A880)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: Color(0xFF34A880),
      bg: Color(0xFFDFFAF2),
      text: Color(0xFF1A6B52),
    ),
    'gold': _PosterTheme(
      gradient: LinearGradient(
        colors: [Color(0xFFFFD700), Color(0xFFD4A017)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      accent: Color(0xFFD4A017),
      bg: Color(0xFFFFF8E1),
      text: Color(0xFF7A5B00),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final t = _themes[theme] ?? _themes['blossom']!;
    // A4 ratio: 210 × 297
    return AspectRatio(
      aspectRatio: 210 / 297,
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: t.gradient,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          baby.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Hành trình phát triển 💕',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.85),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Sinh ngày ${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text('🐰', style: TextStyle(fontSize: 48)),
                ],
              ),
            ),

            // Mini chart
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: _GrowthMiniChart(entries: entries, accent: t.accent),
              ),
            ),

            // Table
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: _GrowthTable(entries: entries, t: t),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Text(
                    'MeBé ✨',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: t.accent.withValues(alpha: 0.6),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Ngày tạo: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                    style: TextStyle(
                      fontSize: 9,
                      color: t.text.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PosterTheme {
  const _PosterTheme({
    required this.gradient,
    required this.accent,
    required this.bg,
    required this.text,
  });

  final LinearGradient gradient;
  final Color accent;
  final Color bg;
  final Color text;
}

class _GrowthTable extends StatelessWidget {
  const _GrowthTable({required this.entries, required this.t});

  final List<GrowthEntry> entries;
  final _PosterTheme t;

  @override
  Widget build(BuildContext context) {
    final rows = entries.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header row
        Container(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: t.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Ngày đo',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'Cân nặng',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  'Chiều cao',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        ...rows.map((e) {
          final date = e.measuredAt;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '${date.day}/${date.month}/${date.year}',
                    style: TextStyle(
                      fontSize: 10,
                      color: t.text.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    e.weightKg != null
                        ? '${e.weightKg!.toStringAsFixed(2)} kg'
                        : '—',
                    style: TextStyle(
                      fontSize: 10,
                      color: t.text.withValues(alpha: 0.8),
                      fontVariations: const [FontVariation('wght', 700)],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Text(
                    e.heightCm != null
                        ? '${e.heightCm!.toStringAsFixed(1)} cm'
                        : '—',
                    style: TextStyle(
                      fontSize: 10,
                      color: t.text.withValues(alpha: 0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _GrowthMiniChart extends StatelessWidget {
  const _GrowthMiniChart({required this.entries, required this.accent});

  final List<GrowthEntry> entries;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final weightEntries =
        entries.where((e) => e.weightKg != null).toList();
    if (weightEntries.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có dữ liệu cân nặng',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      );
    }
    return CustomPaint(
      painter: _ChartPainter(entries: weightEntries, accent: accent),
      child: const SizedBox.expand(),
    );
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({required this.entries, required this.accent});

  final List<GrowthEntry> entries;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    if (entries.length < 2) return;

    final weights = entries.map((e) => e.weightKg!).toList();
    final minW = weights.reduce((a, b) => a < b ? a : b);
    final maxW = weights.reduce((a, b) => a > b ? a : b);
    final range = (maxW - minW).clamp(0.5, double.infinity);

    final paint = Paint()
      ..color = accent
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = accent.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    final dotPaint = Paint()
      ..color = accent
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final n = entries.length;
    final pts = <Offset>[];

    for (var i = 0; i < n; i++) {
      final x = (i / (n - 1)) * size.width;
      final y = size.height -
          ((weights[i] - minW) / range) * (size.height * 0.8) -
          size.height * 0.1;
      pts.add(Offset(x, y));
    }

    fillPath.moveTo(pts.first.dx, size.height);
    fillPath.lineTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < n; i++) {
      fillPath.lineTo(pts[i].dx, pts[i].dy);
    }
    fillPath.lineTo(pts.last.dx, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < n; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);

    for (final pt in pts) {
      canvas.drawCircle(pt, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter old) => old.entries != entries;
}
