import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/monthly_digest_generator.dart';

final _digestYearProvider = StateProvider<int>((ref) => DateTime.now().year);
final _digestMonthProvider = StateProvider<int>((ref) => DateTime.now().month);

final _digestProvider = FutureProvider<MonthlyDigest?>((ref) async {
  final user = ref.watch(currentUserProvider);
  final baby = ref.watch(activeBabyProvider);
  if (user == null || baby == null) return null;
  final year = ref.watch(_digestYearProvider);
  final month = ref.watch(_digestMonthProvider);
  return MonthlyDigestGenerator().generate(
    userId: user.uid,
    baby: baby,
    year: year,
    month: month,
  );
});

class MonthlyDigestScreen extends ConsumerStatefulWidget {
  const MonthlyDigestScreen({super.key});

  @override
  ConsumerState<MonthlyDigestScreen> createState() =>
      _MonthlyDigestScreenState();
}

class _MonthlyDigestScreenState extends ConsumerState<MonthlyDigestScreen> {
  final _repaintKey = GlobalKey();
  final List<XFile> _photos = [];
  bool _isSaving = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 85);
    if (picked.isNotEmpty) {
      setState(() {
        // Keep max 6 photos
        _photos.addAll(picked);
        if (_photos.length > 6) _photos.removeRange(6, _photos.length);
      });
    }
  }

  void _removePhoto(int index) {
    setState(() => _photos.removeAt(index));
  }

  Future<Uint8List?> _captureCard() async {
    final boundary = _repaintKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      final bytes = await _captureCard();
      if (bytes == null) return;
      final tmp = File('${Directory.systemTemp.path}/digest_card.png');
      await tmp.writeAsBytes(bytes);
      await Gal.putImage(tmp.path, album: 'MeBé');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu vào thư viện ảnh 📸')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareDigest(MonthlyDigest digest) async {
    setState(() => _isSaving = true);
    try {
      final bytes = await _captureCard();
      if (bytes != null) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/mebe_digest.png');
        await file.writeAsBytes(bytes);
        await Share.shareXFiles(
          [XFile(file.path, mimeType: 'image/png')],
          text: '${digest.monthLabel} ${digest.year} — ${digest.babyName} ✨\n\nMeBé',
        );
      } else {
        // Fallback: text only
        final text = _buildShareText(digest);
        await Share.share(text);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _buildShareText(MonthlyDigest digest) {
    return '''📊 Tổng kết ${digest.monthLabel} ${digest.year}
👶 ${digest.babyName} — ${digest.ageMonths} tháng tuổi

🍼 Tổng cữ bú: ${digest.totalFeedings}
😴 Trung bình ngủ: ${digest.avgSleepHours.toStringAsFixed(1)}h/ngày
🌸 Thay tã: ${digest.totalDiapers} lần
${digest.weightKg != null ? '⚖️ Cân nặng: ${digest.weightKg!.toStringAsFixed(2)} kg\n' : ''}${digest.highlights.map((h) => '✨ $h').join('\n')}

MeBé ✨''';
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final digestAsync = ref.watch(_digestProvider);
    final year = ref.watch(_digestYearProvider);
    final month = ref.watch(_digestMonthProvider);

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.peach,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Tổng kết tháng 📊',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
        ),
      ),
      body: !isPremium
          ? _PremiumGate(onUpgrade: () => context.push('/home/subscription'))
          : Column(
              children: [
                _MonthSelector(
                  year: year,
                  month: month,
                  onChangeYear: (v) =>
                      ref.read(_digestYearProvider.notifier).state = v,
                  onChangeMonth: (v) =>
                      ref.read(_digestMonthProvider.notifier).state = v,
                ),
                Expanded(
                  child: digestAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Lỗi: $e')),
                    data: (digest) => digest == null
                        ? const Center(child: Text('Chưa có dữ liệu'))
                        : _DigestContent(
                            digest: digest,
                            photos: _photos,
                            repaintKey: _repaintKey,
                            isSaving: _isSaving,
                            onPickPhoto: _pickPhoto,
                            onRemovePhoto: _removePhoto,
                            onSave: _saveToGallery,
                            onShare: () => _shareDigest(digest),
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ── Month selector ────────────────────────────────────────────────────────────

class _MonthSelector extends StatelessWidget {
  const _MonthSelector({
    required this.year,
    required this.month,
    required this.onChangeYear,
    required this.onChangeMonth,
  });

  final int year;
  final int month;
  final ValueChanged<int> onChangeYear;
  final ValueChanged<int> onChangeMonth;

  static const _months = [
    '', 'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (month == 1) {
                onChangeYear(year - 1);
                onChangeMonth(12);
              } else {
                onChangeMonth(month - 1);
              }
            },
          ),
          Text(
            '${_months[month]} $year',
            style: AppTextStyles.headingMd,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              final now = DateTime.now();
              if (year == now.year && month == now.month) return;
              if (month == 12) {
                onChangeYear(year + 1);
                onChangeMonth(1);
              } else {
                onChangeMonth(month + 1);
              }
            },
          ),
        ],
      ),
    );
  }
}

// ── Main digest content ───────────────────────────────────────────────────────

class _DigestContent extends StatelessWidget {
  const _DigestContent({
    required this.digest,
    required this.photos,
    required this.repaintKey,
    required this.isSaving,
    required this.onPickPhoto,
    required this.onRemovePhoto,
    required this.onSave,
    required this.onShare,
  });

  final MonthlyDigest digest;
  final List<XFile> photos;
  final GlobalKey repaintKey;
  final bool isSaving;
  final VoidCallback onPickPhoto;
  final void Function(int) onRemovePhoto;
  final VoidCallback onSave;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Capture area wrapped in RepaintBoundary
          RepaintBoundary(
            key: repaintKey,
            child: _ShareCard(digest: digest, photos: photos),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              children: [
                // Photo upload section
                _PhotoSection(
                  photos: photos,
                  onPickPhoto: onPickPhoto,
                  onRemovePhoto: onRemovePhoto,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isSaving ? null : onSave,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.peach,
                          side: const BorderSide(color: AppColors.peach),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.save_alt_rounded, size: 18),
                        label: const Text('Lưu ảnh'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: isSaving ? null : onShare,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.blossom,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusFull,
                            ),
                          ),
                        ),
                        icon: isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.share_rounded, size: 18),
                        label: const Text('Chia sẻ tổng kết'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xxxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Share card (the part that gets captured as image) ─────────────────────────

class _ShareCard extends StatelessWidget {
  const _ShareCard({required this.digest, required this.photos});
  final MonthlyDigest digest;
  final List<XFile> photos;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.powder,
      child: Column(
        children: [
          // Gradient hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xxxl,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB997), Color(0xFFFF8C68)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                const Text('📊', style: TextStyle(fontSize: 48)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  '${digest.monthLabel} ${digest.year}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '${digest.babyName} — ${digest.ageMonths} tháng tuổi',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          Transform.translate(
            offset: const Offset(0, -24),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  // Stats row
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.peach.withValues(alpha: 0.2),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatBox(
                          emoji: '🍼',
                          label: 'Cữ bú',
                          value: '${digest.totalFeedings}',
                        ),
                        _VSep(),
                        _StatBox(
                          emoji: '😴',
                          label: 'Ngủ/ngày',
                          value:
                              '${digest.avgSleepHours.toStringAsFixed(1)}h',
                        ),
                        _VSep(),
                        _StatBox(
                          emoji: '🌸',
                          label: 'Thay tã',
                          value: '${digest.totalDiapers}',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Growth
                  if (digest.weightKg != null || digest.heightCm != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (digest.weightKg != null)
                            _StatBox(
                              emoji: '⚖️',
                              label: 'Cân nặng',
                              value:
                                  '${digest.weightKg!.toStringAsFixed(2)} kg',
                            ),
                          if (digest.heightCm != null)
                            _StatBox(
                              emoji: '📏',
                              label: 'Chiều cao',
                              value:
                                  '${digest.heightCm!.toStringAsFixed(1)} cm',
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Photo grid (only shown if photos uploaded)
                  if (photos.isNotEmpty) ...[
                    _PhotoGrid(photos: photos),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Achievements
                  if (digest.newAchievementNames.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Thành tích tháng này 🏆',
                      children: digest.newAchievementNames
                          .map((a) => _BulletItem(text: a))
                          .toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // Highlights
                  if (digest.highlights.isNotEmpty) ...[
                    _SectionCard(
                      title: 'Điểm nổi bật ✨',
                      children: digest.highlights
                          .map((h) => _BulletItem(text: h))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo grid inside share card ─────────────────────────────────────────────

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos});
  final List<XFile> photos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ảnh tháng này 📷', style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
            ),
            itemCount: photos.length,
            itemBuilder: (_, i) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(photos[i].path),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Photo picker section (interactive, outside capture boundary) ──────────────

class _PhotoSection extends StatelessWidget {
  const _PhotoSection({
    required this.photos,
    required this.onPickPhoto,
    required this.onRemovePhoto,
  });

  final List<XFile> photos;
  final VoidCallback onPickPhoto;
  final void Function(int) onRemovePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('📷', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Ảnh tháng này', style: AppTextStyles.headingSm),
              ),
              Text(
                '${photos.length}/6',
                style: AppTextStyles.bodySm,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Thêm ảnh để hiển thị trong tổng kết & chia sẻ',
            style: AppTextStyles.bodySm,
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 80,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                // Add photo button
                if (photos.length < 6)
                  GestureDetector(
                    onTap: onPickPhoto,
                    child: Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: AppColors.powder,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.petal,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            color: AppColors.blossom,
                            size: 28,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Thêm ảnh',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.blossom,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Photo thumbnails
                ...List.generate(photos.length, (i) {
                  return Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          File(photos[i].path),
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto(i),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Shared sub-widgets ────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.emoji,
    required this.label,
    required this.value,
  });

  final String emoji;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        Text(label, style: AppTextStyles.bodySm),
      ],
    );
  }
}

class _VSep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.divider);
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.headingSm),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  const _BulletItem({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(text, style: AppTextStyles.bodyMd),
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
            const Text('📊', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text('Tổng kết hàng tháng', style: AppTextStyles.headingLg),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Nhìn lại hành trình cùng bé mỗi tháng.\nCần Premium để xem.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMd,
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
