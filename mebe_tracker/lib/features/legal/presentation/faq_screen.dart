import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';

class _Faq {
  const _Faq(this.question, this.answer);
  final String question;
  final String answer;
}

const _kFaqs = [
  _Faq(
    'MeBé Tracker có thay thế bác sĩ nhi khoa không?',
    'Không. Ứng dụng chỉ hỗ trợ ghi chép và thống kê dữ liệu chăm sóc bé. Mọi quyết định y tế cần tham khảo ý kiến bác sĩ.',
  ),
  _Faq(
    'Làm sao để nâng cấp lên Premium?',
    'Vào Hồ sơ > Premium & Thanh toán > Nâng cấp Premium, chọn gói phù hợp và thanh toán qua App Store/Google Play.',
  ),
  _Faq(
    'Tôi có thể chia sẻ dữ liệu bé với chồng/vợ không?',
    'Có, tính năng Chia sẻ gia đình (yêu cầu Premium) cho phép mời thành viên gia đình xem và cùng ghi chép dữ liệu của bé.',
  ),
  _Faq(
    'Dữ liệu của tôi có an toàn không?',
    'Dữ liệu được mã hoá khi truyền tải và lưu trữ trên Firebase, chỉ chủ tài khoản và thành viên được mời mới truy cập được. Xem chi tiết tại Chính sách bảo mật.',
  ),
  _Faq(
    'Làm sao để xoá tài khoản?',
    'Vào Hồ sơ > cuộn xuống Vùng nguy hiểm > Xoá tài khoản. Thao tác này không thể hoàn tác.',
  ),
  _Faq(
    'Tính năng "Hỏi AI" hoạt động thế nào?',
    'AI phân tích dữ liệu bé đã ghi để trả lời câu hỏi của bạn. Câu trả lời chỉ mang tính tham khảo, không thay thế tư vấn y khoa.',
  ),
  _Faq(
    'Tôi quên mật khẩu, phải làm sao?',
    'Tại màn hình Đăng nhập, chọn "Quên mật khẩu?" và làm theo hướng dẫn gửi qua email.',
  ),
];

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.powder,
      appBar: AppBar(
        title: const Text('Câu hỏi thường gặp'),
        backgroundColor: AppColors.powder,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: _kFaqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final faq = _kFaqs[index];
          return Material(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                title: Text(faq.question, style: AppTextStyles.bodyLg.copyWith(fontWeight: FontWeight.w700)),
                childrenPadding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(faq.answer, style: AppTextStyles.bodyMd.copyWith(height: 1.5)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
