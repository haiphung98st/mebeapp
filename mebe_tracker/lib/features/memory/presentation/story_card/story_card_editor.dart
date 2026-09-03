import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../shared/providers/baby_provider.dart';
import '../../../../shared/providers/subscription_provider.dart';
import '../../../subscription/presentation/subscription_screen.dart';
import '../photo_filter.dart';
import 'story_card_export.dart';
import 'story_frame.dart';
import 'story_frame_painter.dart';

class StoryCardEditorScreen extends ConsumerStatefulWidget {
  const StoryCardEditorScreen({super.key});

  @override
  ConsumerState<StoryCardEditorScreen> createState() => _StoryCardEditorScreenState();
}

class _StoryCardEditorScreenState extends ConsumerState<StoryCardEditorScreen> {
  StoryFrameStyle _style = StoryFrameStyle.blossomGarden;
  ui.Image? _photo;
  late final TextEditingController _nameController;
  late final TextEditingController _taglineController;
  double _warmth = 0;
  bool _exporting = false;

  @override
  void initState() {
    super.initState();
    final baby = ref.read(activeBabyProvider);
    _nameController = TextEditingController(text: baby?.name ?? '');
    _taglineController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    final image = await decodeImageBytes(bytes);
    if (mounted) setState(() => _photo = image);
  }

  void _selectFrame(StoryFrameStyle style, bool isPremium, bool userIsPremium) {
    if (isPremium && !userIsPremium) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SubscriptionScreen()));
      return;
    }
    setState(() => _style = style);
  }

  Future<void> _exportAndShare() async {
    setState(() => _exporting = true);
    try {
      final bytes = await exportStoryCard(
        style: _style,
        photo: _photo,
        babyName: _nameController.text.trim().isEmpty ? 'Bé yêu' : _nameController.text.trim(),
        dateText: DateFormat('dd/MM/yyyy').format(DateTime.now()),
        tagline: _taglineController.text.trim().isEmpty ? null : _taglineController.text.trim(),
        photoFilter: warmthColorFilter(_warmth),
      );
      if (!mounted) return;
      await Share.shareXFiles([
        XFile.fromData(Uint8List.fromList(bytes), name: 'mebe_story_card.png', mimeType: 'image/png'),
      ]);
    } catch (e, st) {
      debugPrint('Story card export error: $e\n$st');
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

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Tạo Story Card'),
        backgroundColor: AppColors.powder,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: TextButton(
              onPressed: _exporting ? null : _exportAndShare,
              child: _exporting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Lưu & Chia sẻ'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: StoryFramePainter.width / StoryFramePainter.height,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 280),
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 16, offset: const Offset(0, 6))],
                ),
                child: CustomPaint(
                  painter: StoryFramePainter(
                    style: _style,
                    photo: _photo,
                    babyName: _nameController.text.trim().isEmpty ? 'Bé yêu' : _nameController.text.trim(),
                    dateText: DateFormat('dd/MM/yyyy').format(DateTime.now()),
                    tagline: _taglineController.text.trim().isEmpty ? null : _taglineController.text.trim(),
                    photoFilter: warmthColorFilter(_warmth),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Ảnh', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: _pickPhoto,
            icon: const Icon(Icons.photo_library_outlined),
            label: Text(_photo == null ? 'Chọn ảnh từ thư viện' : 'Đổi ảnh khác'),
          ),
          if (_photo != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Độ ấm', style: AppTextStyles.bodySm),
            Slider(
              value: _warmth,
              min: -1,
              max: 1,
              activeColor: AppColors.blossom,
              onChanged: (v) => setState(() => _warmth = v),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text('Nội dung', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Tên bé'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _taglineController,
            decoration: const InputDecoration(labelText: 'Dòng tagline (tuỳ chọn)', hintText: 'vd: Bé lật rồi!'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Chọn khung', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: storyFrames.length,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
              itemBuilder: (context, index) {
                final frame = storyFrames[index];
                final selected = frame.style == _style;
                final locked = frame.isPremium && !isPremium;
                return GestureDetector(
                  onTap: () => _selectFrame(frame.style, frame.isPremium, isPremium),
                  child: Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: selected ? AppColors.blossom : AppColors.divider, width: selected ? 2 : 1),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_frames_outlined, color: selected ? AppColors.blossom : AppColors.muted),
                            const SizedBox(height: 4),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                frame.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles.label.copyWith(fontSize: 9),
                              ),
                            ),
                          ],
                        ),
                        if (locked)
                          const Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(Icons.lock, size: 12, color: AppColors.muted),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
