import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/growth_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import 'widgets/growth_poster_widget.dart';

class GrowthPosterScreen extends ConsumerStatefulWidget {
  const GrowthPosterScreen({super.key});

  @override
  ConsumerState<GrowthPosterScreen> createState() =>
      _GrowthPosterScreenState();
}

class _GrowthPosterScreenState extends ConsumerState<GrowthPosterScreen> {
  final _repaintKey = GlobalKey();
  String _theme = 'blossom';
  bool _saving = false;

  static const _themes = [
    ('blossom', '🌸 Hồng'),
    ('lavender', '💜 Tím'),
    ('mint', '🌿 Xanh'),
    ('gold', '⭐ Vàng'),
  ];

  Future<Uint8List?> _captureImage() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveToGallery() async {
    setState(() => _saving = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) return;
      final tmp = File('${Directory.systemTemp.path}/growth_poster.png');
      await tmp.writeAsBytes(bytes);
      await Gal.putImage(tmp.path, album: 'MeBé');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu vào thư viện ảnh 📸')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    setState(() => _saving = true);
    try {
      final bytes = await _captureImage();
      if (bytes == null) return;
      await Share.shareXFiles(
        [XFile.fromData(bytes, mimeType: 'image/png', name: 'growth_poster.png')],
        text: 'Hành trình phát triển của bé 💕 — MeBé ✨',
      );
    } catch (_) {
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final baby = ref.watch(activeBabyProvider);
    final growths = ref.watch(allGrowthsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.info,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Poster phát triển 📏',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: !isPremium
          ? _PremiumGate(onUpgrade: () => context.push('/home/subscription'))
          : baby == null
              ? const Center(child: Text('Chưa có thông tin bé'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    children: [
                      // Theme selector
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _themes.map((t) {
                          final selected = _theme == t.$1;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _theme = t.$1),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.info.withValues(alpha: 0.1)
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.info
                                        : AppColors.divider,
                                    width: selected ? 2 : 1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  t.$2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: selected
                                        ? AppColors.info
                                        : AppColors.body,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Poster preview
                      RepaintBoundary(
                        key: _repaintKey,
                        child: GrowthPosterWidget(
                          baby: baby,
                          entries: growths,
                          theme: _theme,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _saving ? null : _saveToGallery,
                              icon: const Icon(Icons.save_alt_rounded),
                              label: const Text('Lưu ảnh'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _share,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                              ),
                              icon: const Icon(Icons.share_rounded),
                              label: const Text('Chia sẻ'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                    ],
                  ),
                ),
    );
  }
}

class _PremiumGate extends StatelessWidget {
  const _PremiumGate({required this.onUpgrade});

  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📏', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Poster phát triển',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Tạo poster đẹp về hành trình phát triển của bé.\nCần Premium.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.body),
            ),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: onUpgrade,
              child: const Text('Nâng cấp Premium ✨'),
            ),
          ],
        ),
      ),
    );
  }
}
