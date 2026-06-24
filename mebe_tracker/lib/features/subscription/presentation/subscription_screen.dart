import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/bunny_avatar.dart';
import '../../../shared/providers/auth_provider.dart';
import '../../../shared/providers/subscription_provider.dart';
import '../../../shared/services/iap_service.dart';

const _freeFeatures = ['Theo dõi cơ bản', 'Lịch sử 30 ngày', '1 thiết bị'];

const _premiumFeatures = [
  'Lịch sử không giới hạn',
  'Chia sẻ gia đình',
  'Biểu đồ AI insights',
  'Export PDF',
  'Kho sữa nâng cao',
  'Lịch tiêm chủng',
  'Widget',
  'Hỗ trợ ưu tiên',
];

class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  bool _isYearly = true;
  bool _isLoading = false;
  List<ProductDetails> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    final iap = ref.read(iapServiceProvider);
    await iap.initConnection(user.uid);
    final products = await iap.getProducts();
    if (mounted) setState(() => _products = products);
  }

  ProductDetails? get _selectedProduct {
    final productId = _isYearly ? IapProductIds.yearly : IapProductIds.monthly;
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  Future<void> _buy() async {
    final product = _selectedProduct;
    if (product == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tải được sản phẩm, vui lòng thử lại sau')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await ref.read(iapServiceProvider).buyProduct(product);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mua Premium không thành công, vui lòng thử lại')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(iapServiceProvider).restorePurchases();
      final isPremium = ref.read(isPremiumProvider);
      if (mounted && !isPremium) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không tìm thấy giao dịch nào để khôi phục')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(purchaseFlowStatusProvider, (previous, next) {
      final status = next.value;
      if (status == null) return;
      switch (status) {
        case PurchaseFlowStatus.pending:
          setState(() => _isLoading = true);
          break;
        case PurchaseFlowStatus.success:
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chào mừng đến với MeBé Premium! 🎉')),
          );
          break;
        case PurchaseFlowStatus.failed:
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Giao dịch không thành công, vui lòng thử lại')),
          );
          break;
        case PurchaseFlowStatus.restoreNotFound:
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy giao dịch nào để khôi phục')),
          );
          break;
        case PurchaseFlowStatus.idle:
          setState(() => _isLoading = false);
          break;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        backgroundColor: AppColors.powder,
        elevation: 0,
        title: const Text('Premium'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            const BunnyAvatar(size: 88, earColor: AppColors.blossom),
            const SizedBox(height: AppSpacing.md),
            Text('MeBé Premium 🎀', style: AppTextStyles.displaySm),
            const SizedBox(height: AppSpacing.xl),
            _FeatureComparisonList(),
            const SizedBox(height: AppSpacing.xl),
            _PricingToggle(
              isYearly: _isYearly,
              onChanged: (value) => setState(() => _isYearly = value),
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _buy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blossom,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : const Text('Dùng thử Premium 7 ngày miễn phí'),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: AppSpacing.md,
              children: [
                TextButton(onPressed: _isLoading ? null : _restore, child: const Text('Khôi phục giao dịch')),
                TextButton(onPressed: () {}, child: const Text('Điều khoản')),
                TextButton(onPressed: () {}, child: const Text('Bảo mật')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureComparisonList extends StatelessWidget {
  const _FeatureComparisonList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Miễn phí', style: AppTextStyles.headingSm),
        const SizedBox(height: AppSpacing.xs),
        ..._freeFeatures.map((f) => _FeatureRow(text: f, isPremium: false)),
        const SizedBox(height: AppSpacing.lg),
        Text('Premium', style: AppTextStyles.headingSm.copyWith(color: AppColors.blossom)),
        const SizedBox(height: AppSpacing.xs),
        ..._premiumFeatures.map((f) => _FeatureRow(text: f, isPremium: true)),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({required this.text, required this.isPremium});

  final String text;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isPremium ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isPremium ? AppColors.mint : AppColors.muted,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(text, style: AppTextStyles.bodyMd),
        ],
      ),
    );
  }
}

class _PricingToggle extends StatelessWidget {
  const _PricingToggle({required this.isYearly, required this.onChanged});

  final bool isYearly;
  final void Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PriceCard(
            title: 'Hàng tháng',
            price: '49.000đ/tháng',
            isSelected: !isYearly,
            onTap: () => onChanged(false),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _PriceCard(
            title: 'Hàng năm',
            price: '399.000đ/năm (tiết kiệm 32%)',
            badge: 'Phổ biến nhất',
            isSelected: isYearly,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _PriceCard extends StatelessWidget {
  const _PriceCard({
    required this.title,
    required this.price,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final String title;
  final String price;
  final bool isSelected;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isSelected ? AppColors.blossom : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.headingSm),
                const SizedBox(height: AppSpacing.xs),
                Text(price, style: AppTextStyles.bodyMd),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: -10,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.blossom,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  badge!,
                  style: AppTextStyles.label.copyWith(color: AppColors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
