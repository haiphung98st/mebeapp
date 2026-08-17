import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/providers/baby_provider.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/growth_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../data/story_card_provider.dart';

class BabyBookScreen extends ConsumerStatefulWidget {
  const BabyBookScreen({super.key});

  @override
  ConsumerState<BabyBookScreen> createState() => _BabyBookScreenState();
}

class _BabyBookScreenState extends ConsumerState<BabyBookScreen> {
  bool _generating = false;

  Future<pw.Document> _buildPdf() async {
    final baby = ref.read(activeBabyProvider);
    final growths = ref.read(allGrowthsProvider).value ?? [];
    final cards = ref.read(storyCardsProvider).value ?? [];
    final doc = pw.Document();

    // Cover page
    doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (ctx) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(
              '🐰',
              style: pw.TextStyle(fontSize: 72),
            ),
            pw.SizedBox(height: 24),
            pw.Text(
              'Baby Book',
              style: pw.TextStyle(
                fontSize: 36,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              baby?.name ?? 'Bé yêu',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            if (baby != null) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                'Sinh ngày ${baby.dateOfBirth.day}/${baby.dateOfBirth.month}/${baby.dateOfBirth.year}',
                style: pw.TextStyle(fontSize: 14),
              ),
            ],
            pw.SizedBox(height: 48),
            pw.Text(
              'Tạo bởi MeBé ✨',
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    ));

    // Growth table page
    if (growths.isNotEmpty) {
      doc.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Bảng tăng trưởng 📏',
              style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 16),
            pw.Table(
              border: pw.TableBorder.all(width: 0.5),
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    _cell('Ngày đo', isHeader: true),
                    _cell('Cân nặng (kg)', isHeader: true),
                    _cell('Chiều cao (cm)', isHeader: true),
                    _cell('Vòng đầu (cm)', isHeader: true),
                  ],
                ),
                ...growths.take(20).map((e) => pw.TableRow(
                      children: [
                        _cell('${e.measuredAt.day}/${e.measuredAt.month}/${e.measuredAt.year}'),
                        _cell(e.weightKg?.toStringAsFixed(2) ?? '—'),
                        _cell(e.heightCm?.toStringAsFixed(1) ?? '—'),
                        _cell(e.headCircumferenceCm?.toStringAsFixed(1) ?? '—'),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ));
    }

    // Story cards pages
    if (cards.isNotEmpty) {
      for (var i = 0; i < cards.length && i < 10; i++) {
        final card = cards[i];
        doc.addPage(pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(48),
          build: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                card.titleVi,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                '${card.cardDate.day}/${card.cardDate.month}/${card.cardDate.year}',
                style: pw.TextStyle(fontSize: 12),
              ),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text(
                card.contentVi,
                style: pw.TextStyle(fontSize: 14, lineSpacing: 4),
              ),
            ],
          ),
        ));
      }
    }

    return doc;
  }

  pw.Widget _cell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  Future<void> _preview() async {
    setState(() => _generating = true);
    try {
      final pdf = await _buildPdf();
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Baby Book PDF')),
              body: PdfPreview(
                build: (format) => pdf.save(),
                allowPrinting: true,
                allowSharing: true,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tạo PDF: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(isPremiumProvider);
    final baby = ref.watch(activeBabyProvider);
    final growths = ref.watch(allGrowthsProvider).value ?? [];
    final cards = ref.watch(storyCardsProvider).value ?? [];

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.mauve,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Baby Book PDF 📚',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: !isPremium
          ? _PremiumGate(onUpgrade: () => context.push('/home/subscription'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Preview card
                  Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB06090), Color(0xFF8B2252)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📚', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          baby?.name ?? 'Baby Book',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Cuốn sách kỷ niệm của bé',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Contents preview
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nội dung sách',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _ContentRow(
                          emoji: '📖',
                          label: 'Trang bìa',
                          count: '1 trang',
                        ),
                        _ContentRow(
                          emoji: '📏',
                          label: 'Bảng tăng trưởng',
                          count: '${growths.length} lần đo',
                        ),
                        _ContentRow(
                          emoji: '🎴',
                          label: 'Thẻ kỷ niệm',
                          count: '${cards.take(10).length} thẻ',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  ElevatedButton.icon(
                    onPressed: _generating ? null : _preview,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mauve,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: _generating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.picture_as_pdf_rounded),
                    label: Text(
                      _generating ? 'Đang tạo PDF...' : 'Xem & In PDF',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  const _ContentRow({
    required this.emoji,
    required this.label,
    required this.count,
  });

  final String emoji;
  final String label;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.body),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
            ),
          ),
        ],
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
            const Text('📚', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Baby Book PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Tạo cuốn sách kỷ niệm đẹp cho bé.\nCần Premium.',
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
