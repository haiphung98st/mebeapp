import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../data/formula_database.dart';

/// Scanner screen. Pop with [FormulaScanResult] when formula is identified,
/// or null when user cancels.
class FormulaScannerScreen extends StatefulWidget {
  const FormulaScannerScreen({super.key});

  @override
  State<FormulaScannerScreen> createState() => _FormulaScannerScreenState();
}

class _FormulaScannerScreenState extends State<FormulaScannerScreen> {
  final _controller = MobileScannerController();
  FormulaMilk? _found;
  String? _scannedBarcode;
  bool _paused = false;

  void _onDetect(BarcodeCapture capture) {
    if (_paused) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;
      _controller.stop();
      _handleBarcode(raw);
      return;
    }
  }

  void _handleBarcode(String raw) {
    setState(() {
      _found = lookupBarcode(raw);
      _scannedBarcode = raw;
      _paused = true;
    });
  }

  Future<void> _pickFromGallery() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    _controller.stop();
    final capture = await _controller.analyzeImage(picked.path);
    if (!mounted) return;
    final raw = capture?.barcodes.firstOrNull?.rawValue;
    if (raw == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy mã vạch trong ảnh này')),
      );
      _controller.start();
      return;
    }
    _handleBarcode(raw);
  }

  void _retry() {
    setState(() {
      _found = null;
      _scannedBarcode = null;
      _paused = false;
    });
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Quét mã sữa công thức'),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            tooltip: 'Tải ảnh mã vạch từ thư viện',
            onPressed: _pickFromGallery,
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Viewfinder overlay
          Center(
            child: Container(
              width: 260,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.blossom, width: 3),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _scannedBarcode == null
                ? _HintBar()
                : _found != null
                    ? _FoundCard(
                        formula: _found!,
                        onUse: () => Navigator.of(context)
                            .pop(FormulaScanResult(formula: _found!)),
                        onRetry: _retry,
                      )
                    : _NotFoundCard(
                        barcode: _scannedBarcode!,
                        onRetry: _retry,
                      ),
          ),
        ],
      ),
    );
  }
}

class _HintBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: Colors.black87,
      child: const Text(
        'Hướng camera vào barcode trên hộp sữa',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }
}

class _FoundCard extends StatelessWidget {
  const _FoundCard({
    required this.formula,
    required this.onUse,
    required this.onRetry,
  });

  final FormulaMilk formula;
  final VoidCallback onUse;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.mint, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text('Tìm thấy!',
                  style: AppTextStyles.headingSm
                      .copyWith(color: AppColors.mint)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(formula.brand, style: AppTextStyles.label),
          Text(formula.name, style: AppTextStyles.headingMd),
          Text('Giai đoạn ${formula.stage} · Gợi ý: ${formula.typicalServingMl.toInt()} ml/lần',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onRetry,
                  child: const Text('Quét lại'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blossom),
                  onPressed: onUse,
                  child: const Text('Dùng sữa này'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _NotFoundCard extends StatelessWidget {
  const _NotFoundCard({required this.barcode, required this.onRetry});

  final String barcode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLg)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: AppColors.muted, size: 36),
          const SizedBox(height: AppSpacing.sm),
          Text('Không tìm thấy sữa', style: AppTextStyles.headingSm),
          Text('Barcode: $barcode',
              style: AppTextStyles.bodySm.copyWith(color: AppColors.muted)),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onRetry,
              child: const Text('Quét lại'),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class FormulaScanResult {
  const FormulaScanResult({required this.formula});
  final FormulaMilk formula;
}
