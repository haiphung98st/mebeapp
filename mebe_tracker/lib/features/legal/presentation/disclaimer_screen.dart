import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

/// Standalone medical-disclaimer reader, reachable from Hồ sơ > Hỗ trợ & Pháp lý
/// and from the registration consent links.
class DisclaimerScreen extends StatelessWidget {
  const DisclaimerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Miễn trừ trách nhiệm y tế'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'MeBé Tracker không phải là thiết bị y tế và không thay thế tư vấn của bác sĩ.',
                      style: AppTextStyles.headingSm.copyWith(color: AppColors.warning),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _Point(
              text:
                  'Toàn bộ nội dung trong Ứng dụng — bao gồm thống kê, biểu đồ tăng trưởng, lịch tiêm chủng gợi ý và câu trả lời từ tính năng "Hỏi AI" — chỉ mang tính chất tham khảo, dựa trên dữ liệu do chính bạn nhập.',
            ),
            _Point(
              text:
                  'Các gợi ý từ AI có thể chứa sai sót hoặc không phù hợp với tình trạng riêng của bé bạn. Đây không phải là chẩn đoán hay chỉ định y khoa.',
            ),
            _Point(
              text:
                  'Luôn tham khảo ý kiến bác sĩ nhi khoa trước khi thay đổi chế độ ăn, giấc ngủ, hoặc bất kỳ quyết định nào liên quan đến sức khoẻ của bé.',
            ),
            _Point(
              text:
                  'Trong tình huống khẩn cấp (sốt cao, khó thở, co giật...), hãy gọi cấp cứu hoặc đến cơ sở y tế gần nhất ngay lập tức — không chờ đợi hoặc dựa vào Ứng dụng.',
            ),
            _Point(
              text:
                  'Biểu đồ tăng trưởng tham khảo chuẩn WHO nhưng cần bác sĩ đối chiếu với thể trạng cụ thể của bé để đánh giá chính xác.',
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Bằng việc sử dụng MeBé Tracker, bạn xác nhận đã hiểu và đồng ý với nội dung miễn trừ trách nhiệm này.',
              style: AppTextStyles.bodySm,
            ),
          ],
        ),
      ),
    );
  }
}

class _Point extends StatelessWidget {
  const _Point({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.circle, size: 6, color: AppColors.warning),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: AppTextStyles.bodyMd.copyWith(height: 1.5))),
        ],
      ),
    );
  }
}
