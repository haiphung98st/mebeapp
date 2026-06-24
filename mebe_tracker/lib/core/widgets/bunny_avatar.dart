import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Hand-drawn bunny mascot used as logo, baby avatar, and header icon.
/// Geometry mirrors the 38x44 viewBox of the reference SVG mockup.
class BunnyAvatar extends StatelessWidget {
  const BunnyAvatar({
    super.key,
    this.size = 64,
    this.isAsleep = false,
    this.primaryColor = AppColors.white,
    this.earColor = AppColors.petal,
    this.earInnerColor,
    this.cheekColor,
    this.eyeColor,
    this.noseColor,
  });

  final double size;
  final bool isAsleep;
  final Color primaryColor;
  final Color earColor;
  final Color? earInnerColor;
  final Color? cheekColor;
  final Color? eyeColor;
  final Color? noseColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size * 44 / 38,
      child: CustomPaint(
        painter: _BunnyPainter(
          isAsleep: isAsleep,
          headColor: primaryColor,
          earColor: earColor,
          earInnerColor: earInnerColor ?? earColor.withValues(alpha: 0.55),
          cheekColor: cheekColor ?? AppColors.petal,
          eyeColor: eyeColor ?? AppColors.ink,
          noseColor: noseColor ?? AppColors.blossom,
        ),
      ),
    );
  }
}

class _BunnyPainter extends CustomPainter {
  _BunnyPainter({
    required this.isAsleep,
    required this.headColor,
    required this.earColor,
    required this.earInnerColor,
    required this.cheekColor,
    required this.eyeColor,
    required this.noseColor,
  });

  final bool isAsleep;
  final Color headColor;
  final Color earColor;
  final Color earInnerColor;
  final Color cheekColor;
  final Color eyeColor;
  final Color noseColor;

  // Reference geometry is defined against a 38x44 viewBox.
  static const _vbW = 38.0;
  static const _vbH = 44.0;

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / _vbW;
    final sy = size.height / _vbH;
    Offset p(double x, double y) => Offset(x * sx, y * sy);
    double dx(double v) => v * sx;
    double dy(double v) => v * sy;

    void oval(Offset center, double w, double h, Paint paint) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: w, height: h),
        paint,
      );
    }

    final earPaint = Paint()..color = earColor;
    final earInnerPaint = Paint()..color = earInnerColor;
    oval(p(11, 12), dx(12), dy(26), earPaint);
    oval(p(11, 12), dx(7), dy(18), earInnerPaint);
    oval(p(27, 12), dx(12), dy(26), earPaint);
    oval(p(27, 12), dx(7), dy(18), earInnerPaint);

    final headPaint = Paint()..color = headColor;
    oval(p(19, 30), dx(32), dy(28), headPaint);

    final cheekPaint = Paint()..color = cheekColor.withValues(alpha: 0.55);
    oval(p(11, 34), dx(10), dy(7), cheekPaint);
    oval(p(27, 34), dx(10), dy(7), cheekPaint);

    if (isAsleep) {
      final closedEyePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = dx(1.5)
        ..strokeCap = StrokeCap.round;
      final leftEye = Path()
        ..moveTo(p(11.5, 28).dx, p(11.5, 28).dy)
        ..quadraticBezierTo(
          p(14, 26.5).dx,
          p(14, 26.5).dy,
          p(16.5, 28).dx,
          p(16.5, 28).dy,
        );
      final rightEye = Path()
        ..moveTo(p(21.5, 28).dx, p(21.5, 28).dy)
        ..quadraticBezierTo(
          p(24, 26.5).dx,
          p(24, 26.5).dy,
          p(26.5, 28).dx,
          p(26.5, 28).dy,
        );
      canvas.drawPath(leftEye, closedEyePaint);
      canvas.drawPath(rightEye, closedEyePaint);

      final zzzPaint = TextPainter(textDirection: TextDirection.ltr);
      void drawZ(String text, double x, double y, double fontSize, double opacity) {
        zzzPaint.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: fontSize * ((sx + sy) / 2),
            fontWeight: FontWeight.bold,
            color: Colors.white.withValues(alpha: opacity),
          ),
        );
        zzzPaint.layout();
        zzzPaint.paint(canvas, p(x, y));
      }
      drawZ('z', 27, 11, 7, 0.6);
      drawZ('z', 30, 6, 9, 0.5);
      drawZ('Z', 33, 0, 11, 0.4);
    } else {
      final eyePaint = Paint()..color = eyeColor;
      oval(p(14, 28), dx(4.4), dy(5), eyePaint);
      oval(p(24, 28), dx(4.4), dy(5), eyePaint);
      final highlightPaint = Paint()..color = Colors.white;
      canvas.drawCircle(p(15, 27), dx(0.8), highlightPaint);
      canvas.drawCircle(p(25, 27), dx(0.8), highlightPaint);
    }

    final nosePaint = Paint()..color = noseColor;
    oval(p(19, 33), dx(4), dy(2.8), nosePaint);

    if (!isAsleep) {
      final smilePaint = Paint()
        ..color = noseColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = dx(1.2)
        ..strokeCap = StrokeCap.round;
      final smile = Path()
        ..moveTo(p(16, 35.5).dx, p(16, 35.5).dy)
        ..quadraticBezierTo(
          p(19, 38).dx,
          p(19, 38).dy,
          p(22, 35.5).dx,
          p(22, 35.5).dy,
        );
      canvas.drawPath(smile, smilePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _BunnyPainter oldDelegate) {
    return oldDelegate.isAsleep != isAsleep ||
        oldDelegate.headColor != headColor ||
        oldDelegate.earColor != earColor ||
        oldDelegate.earInnerColor != earInnerColor ||
        oldDelegate.cheekColor != cheekColor ||
        oldDelegate.eyeColor != eyeColor ||
        oldDelegate.noseColor != noseColor;
  }
}
