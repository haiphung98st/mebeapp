import 'package:flutter/material.dart';

/// Builds a non-destructive warmth adjustment for compositing a photo into
/// a frame — the original picked photo bytes are never touched; this only
/// tints how the pixels are drawn on canvas. [warmth] ranges -1 (cool) to
/// 1 (warm); 0 returns null (no filter, fastest path).
ColorFilter? warmthColorFilter(double warmth) {
  if (warmth == 0) return null;
  final r = 1 + warmth * 0.18;
  final b = 1 - warmth * 0.18;
  return ColorFilter.matrix([
    r, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, b, 0, 0,
    0, 0, 0, 1, 0,
  ]);
}
