import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/growth_provider.dart';
import '../../../../shared/providers/subscription_provider.dart';
import '../../../subscription/presentation/subscription_screen.dart';
import '../photo_filter.dart';
import '../story_card/story_card_export.dart';
import 'baby_book_export.dart';
import 'baby_book_frame.dart';
import 'baby_book_frame_painter.dart';

enum _Mode { bookPage, poster }

class BabyBookFrameEditorScreen extends ConsumerStatefulWidget {
  const BabyBookFrameEditorScreen({super.key});

  @override
  ConsumerState<BabyBookFrameEditorScreen> createState() => _BabyBookFrameEditorScreenState();
}

class _BabyBookFrameEditorScreenState extends ConsumerState<BabyBookFrameEditorScreen> {
  _Mode _mode = _Mode.bookPage;
  BookLayout _layout = BookLayout.monthlyAlbum;
  PosterTheme _theme = PosterTheme.blossom;
  ui.Image? _mainPhoto;
  final List<ui.Image?> _miniPhotos = [null, null];
  late final TextEditingController _milestonesController;
  late final TextEditingController _taglineController;
  double _warmth = 0;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    _milestonesController = TextEditingController();
    _taglineController = TextEditingController();
  }

  @override
  void dispose() {
    _milestonesController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _pickMainPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked == null) return;
    final image = await decodeImageBytes(await picked.readAsBytes());
    if (mounted) setState(() => _mainPhoto = image);
  }

  Future<void> _pickMiniPhoto(int index) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;
    final image = await decodeImageBytes(await picked.readAsBytes());
    if (mounted) setState(() => _miniPhotos[index] = image);
  }

  Future<void> _exportAndShare() async {
    final baby = ref.read(activeBabyProvider);
    if (baby == null) return;
    setState(() => _exporting = true);
    try {
      final latest = ref.read(latestGrowthProvider);
      final weight = latest?.weightKg != null ? '${latest!.weightKg!.toStringAsFixed(1)} kg' : null;
      final height = latest?.heightCm != null ? '${latest!.heightCm!.toStringAsFixed(0)} cm' : null;
      final milestones = _milestonesController.text.trim().isEmpty ? null : _milestonesController.text.trim();
      final tagline = _taglineController.text.trim().isEmpty ? null : _taglineController.text.trim();
      final filter = warmthColorFilter(_warmth);

      final Uint8List bytes;
      if (_mode == _Mode.bookPage) {
        bytes = await exportBabyBookPage(
          layout: _layout,
          mainPhoto: _mainPhoto,
          miniPhotos: _miniPhotos,
          data: BabyBookPageData(
            title: formatBabyAge(baby.dateOfBirth),
            babyName: baby.name,
            dateRange: _dateRangeLabel(),
            weight: weight,
            height: height,
            milestones: milestones,
            tagline: tagline,
          ),
          photoFilter: filter,
        );
      } else {
        bytes = await exportGrowthPoster(
          theme: _theme,
          photo: _mainPhoto,
          data: GrowthPosterData(
            babyName: baby.name,
            ageText: formatBabyAge(baby.dateOfBirth),
            dateText: _dateRangeLabel(),
            weight: weight,
            height: height,
            milestones: milestones,
            quote: tagline,
          ),
          photoFilter: filter,
        );
      }
      if (!mounted) return;
      await Share.shareXFiles([
        XFile.fromData(bytes, name: 'mebe_baby_book.png', mimeType: 'image/png'),
      ]);
    } catch (e, st) {
      debugPrint('Baby book export error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            duration: const Duration(seconds: 10),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  String _dateRangeLabel() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Khung Baby Book'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: isPremium ? _buildEditor(context) : _buildUpsell(context),
    );
  }

  Widget _buildUpsell(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text('Khung Baby Book là tính năng Premium', style: AppTextStyles.headingSm, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Tạo trang album và poster tăng trưởng in được, đầy đủ ảnh và cột mốc của bé.',
              style: AppTextStyles.bodyMd,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen())),
              child: const Text('Nâng cấp Premium'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    final aspect = _mode == _Mode.bookPage
        ? BabyBookPagePainter.width / BabyBookPagePainter.height
        : GrowthPosterPainter.width / GrowthPosterPainter.height;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        SegmentedButton<_Mode>(
          segments: const [
            ButtonSegment(value: _Mode.bookPage, label: Text('Trang Album')),
            ButtonSegment(value: _Mode.poster, label: Text('Poster')),
          ],
          selected: {_mode},
          onSelectionChanged: (s) => setState(() => _mode = s.first),
        ),
        const SizedBox(height: AppSpacing.lg),
        Center(
          child: AspectRatio(
            aspectRatio: aspect,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 340),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
              ),
              child: _buildPreview(),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Ảnh chính', style: AppTextStyles.headingSm),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: _pickMainPhoto,
          icon: const Icon(Icons.photo_library_outlined),
          label: Text(_mainPhoto == null ? 'Chọn ảnh chính' : 'Đổi ảnh chính'),
        ),
        if (_mode == _Mode.bookPage && _layout == BookLayout.monthlyAlbum) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: List.generate(
              2,
              (i) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: OutlinedButton(
                  onPressed: () => _pickMiniPhoto(i),
                  child: Text(_miniPhotos[i] == null ? 'Ảnh phụ ${i + 1}' : 'Đã chọn ${i + 1}'),
                ),
              ),
            ),
          ),
        ],
        if (_mainPhoto != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text('Độ ấm', style: AppTextStyles.bodySm),
          Slider(value: _warmth, min: -1, max: 1, activeColor: AppColors.blossom, onChanged: (v) => setState(() => _warmth = v)),
        ],
        const SizedBox(height: AppSpacing.lg),
        Text('Nội dung', style: AppTextStyles.headingSm),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _milestonesController,
          decoration: const InputDecoration(labelText: 'Cột mốc (tuỳ chọn)', hintText: 'vd: Lật · Cười to · Nhận ra mẹ'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: _taglineController,
          decoration: const InputDecoration(labelText: 'Lời nhắn / trích dẫn (tuỳ chọn)'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(_mode == _Mode.bookPage ? 'Chọn layout' : 'Chọn phong cách poster', style: AppTextStyles.headingSm),
        const SizedBox(height: AppSpacing.sm),
        _mode == _Mode.bookPage ? _layoutSelector() : _themeSelector(),
        const SizedBox(height: AppSpacing.xl),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _exporting ? null : _exportAndShare,
            icon: _exporting
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.share_outlined),
            label: const Text('Lưu & Chia sẻ'),
          ),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    if (_mode == _Mode.bookPage) {
      return CustomPaint(
        painter: BabyBookPagePainter(
          layout: _layout,
          mainPhoto: _mainPhoto,
          miniPhotos: _miniPhotos,
          data: BabyBookPageData(
            title: 'Trang kỷ niệm',
            babyName: ref.watch(activeBabyProvider)?.name ?? 'Bé yêu',
            dateRange: _dateRangeLabel(),
            weight: null,
            height: null,
            milestones: _milestonesController.text.trim().isEmpty ? null : _milestonesController.text.trim(),
            tagline: _taglineController.text.trim().isEmpty ? null : _taglineController.text.trim(),
          ),
          photoFilter: warmthColorFilter(_warmth),
        ),
        child: const SizedBox.expand(),
      );
    }
    return CustomPaint(
      painter: GrowthPosterPainter(
        theme: _theme,
        photo: _mainPhoto,
        data: GrowthPosterData(
          babyName: ref.watch(activeBabyProvider)?.name ?? 'Bé yêu',
          ageText: formatBabyAge(ref.watch(activeBabyProvider)?.dateOfBirth ?? DateTime.now()),
          dateText: _dateRangeLabel(),
          quote: _taglineController.text.trim().isEmpty ? null : _taglineController.text.trim(),
          milestones: _milestonesController.text.trim().isEmpty ? null : _milestonesController.text.trim(),
        ),
        photoFilter: warmthColorFilter(_warmth),
      ),
      child: const SizedBox.expand(),
    );
  }

  Widget _layoutSelector() {
    return Row(
      children: bookLayouts
          .map((info) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _SelectorChip(
                    label: info.name,
                    selected: info.layout == _layout,
                    onTap: () => setState(() => _layout = info.layout),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _themeSelector() {
    return Row(
      children: posterThemes
          .map((info) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _SelectorChip(
                    label: info.name,
                    selected: info.theme == _theme,
                    onTap: () => setState(() => _theme = info.theme),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _SelectorChip extends StatelessWidget {
  const _SelectorChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppColors.blossom : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: selected ? AppColors.blossom : AppColors.divider),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.white : AppColors.body,
          ),
        ),
      ),
    );
  }
}
