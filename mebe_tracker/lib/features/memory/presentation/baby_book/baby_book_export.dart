import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'baby_book_frame.dart';
import 'baby_book_frame_painter.dart';

Future<Uint8List> exportBabyBookPage({
  required BookLayout layout,
  required ui.Image? mainPhoto,
  required List<ui.Image?> miniPhotos,
  required BabyBookPageData data,
  ColorFilter? photoFilter,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, BabyBookPagePainter.width, BabyBookPagePainter.height));
  BabyBookPagePainter(layout: layout, mainPhoto: mainPhoto, miniPhotos: miniPhotos, data: data, photoFilter: photoFilter)
      .paint(canvas, const Size(BabyBookPagePainter.width, BabyBookPagePainter.height));
  final picture = recorder.endRecording();
  final image = await picture.toImage(BabyBookPagePainter.width.toInt(), BabyBookPagePainter.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<Uint8List> exportGrowthPoster({
  required PosterTheme theme,
  required ui.Image? photo,
  required GrowthPosterData data,
  ColorFilter? photoFilter,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, GrowthPosterPainter.width, GrowthPosterPainter.height));
  GrowthPosterPainter(theme: theme, photo: photo, data: data, photoFilter: photoFilter)
      .paint(canvas, const Size(GrowthPosterPainter.width, GrowthPosterPainter.height));
  final picture = recorder.endRecording();
  final image = await picture.toImage(GrowthPosterPainter.width.toInt(), GrowthPosterPainter.height.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}
