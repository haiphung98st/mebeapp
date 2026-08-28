import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'story_frame.dart';
import 'story_frame_painter.dart';

/// Decodes picked-photo bytes into a [ui.Image] for use in a [CustomPainter].
Future<ui.Image> decodeImageBytes(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  return frame.image;
}

/// Renders a Story Card frame offscreen and returns share-ready PNG bytes
/// at its native 1080×1920 resolution.
Future<Uint8List> exportStoryCard({
  required StoryFrameStyle style,
  required ui.Image? photo,
  required String babyName,
  required String dateText,
  String? tagline,
  ColorFilter? photoFilter,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, StoryFramePainter.width, StoryFramePainter.height));
  final painter = StoryFramePainter(
    style: style,
    photo: photo,
    babyName: babyName,
    dateText: dateText,
    tagline: tagline,
    photoFilter: photoFilter,
  );
  painter.paint(canvas, const Size(StoryFramePainter.width, StoryFramePainter.height));

  final picture = recorder.endRecording();
  final image = await picture.toImage(StoryFramePainter.width.toInt(), StoryFramePainter.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
