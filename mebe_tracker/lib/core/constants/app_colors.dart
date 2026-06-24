import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── PRIMARY GIRL PALETTE ──
  static const blossom = Color(0xFFF472A0); // primary CTA / active
  static const petal = Color(0xFFFFB7CE); // mid pink
  static const blush = Color(0xFFFFD6E4); // light pink
  static const powder = Color(0xFFFFF0F6); // bg tint
  static const cream = Color(0xFFFFFAFB); // surface

  // ── ACCENT ──
  static const lavender = Color(0xFFC9A8F5); // purple accent
  static const lilac = Color(0xFFEEE0FF); // purple light
  static const mint = Color(0xFF7DE8C8); // success
  static const mintLight = Color(0xFFDFFAF2); // success bg
  static const peach = Color(0xFFFFB997); // warm
  static const peachLight = Color(0xFFFFEDE3); // warm bg
  static const mauve = Color(0xFFB06090); // deep text accent

  // ── SLEEP SCREEN SPECIAL ──
  static const nightDeep = Color(0xFF3D1A6E);
  static const nightMid = Color(0xFF5B3A8A);
  static const nightLight = Color(0xFF7B5AAA);

  // ── NEUTRALS ──
  static const ink = Color(0xFF3D1A35); // headings
  static const body = Color(0xFF7A4D6A); // body text
  static const muted = Color(0xFFB899AC); // placeholder
  static const divider = Color(0xFFF5DCE8); // borders
  static const white = Color(0xFFFFFFFF);

  // ── SEMANTIC ──
  static const success = Color(0xFF34A880);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF38BDF8);

  // ── GRADIENTS (per-screen headers) ──
  static const gradientHome = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF472A0), Color(0xFFD94F8A), Color(0xFFC9A8F5)],
    stops: [0.0, 0.6, 1.0],
  );
  static const gradientFeeding = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF85B3), Color(0xFFF472A0)],
  );
  static const gradientPump = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC9A8F5), Color(0xFFA67CD8)],
  );
  static const gradientSleep = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B3A8A), Color(0xFF3D1A6E)],
  );
  static const gradientGrowth = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF50C8A0), Color(0xFF34A880)],
  );

  // ── EAR COLORS PER SCREEN (matches bunny-header mockup) ──
  static const homeEarLeftGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFB7CE), Color(0xFFF472A0)],
  );
  static const homeEarRightGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE8C5FF), Color(0xFFC9A8F5)],
  );
  static const feedingEarLeft = Color(0xFFFFB7CE);
  static const feedingEarRight = Color(0xFFFFC8DB);
  static const pumpEarLeft = Color(0xFFDFC8FF);
  static const pumpEarRight = Color(0xFFEDD8FF);
  static const sleepEarLeft = Color(0xFF7B5AAA);
  static const sleepEarRight = Color(0xFF8D6ABF);
  static const growthEarLeft = Color(0xFF7DE8C8);
  static const growthEarRight = Color(0xFF9DF0D5);
}
