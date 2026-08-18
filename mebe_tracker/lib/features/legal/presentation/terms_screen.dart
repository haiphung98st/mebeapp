import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'legal_text_screen.dart';

const _kTermsLastUpdated = '14/08/2026';

const _kTermsContent = '''
> ⚠️ **LƯU Ý QUAN TRỌNG VỀ Y TẾ**
>
> MeBé Tracker là ứng dụng theo dõi và ghi chép thông tin chăm sóc trẻ, **không phải** là thiết bị y tế và **không thay thế** cho tư vấn, chẩn đoán hoặc điều trị y khoa chuyên nghiệp. Mọi thông tin, gợi ý, hoặc phân tích AI trong ứng dụng chỉ mang tính chất tham khảo. Luôn tham khảo ý kiến bác sĩ nhi khoa hoặc chuyên gia y tế trước khi đưa ra quyết định liên quan đến sức khoẻ của bé.

## 1. Giới thiệu dịch vụ

MeBé Tracker ("Ứng dụng", "chúng tôi") là ứng dụng di động hỗ trợ cha mẹ theo dõi các hoạt động chăm sóc trẻ sơ sinh và trẻ nhỏ, bao gồm: cữ bú, hút sữa, giấc ngủ, tăng trưởng, tiêm chủng, thay tã, và các kỷ niệm của bé. Bằng việc tạo tài khoản và sử dụng Ứng dụng, bạn đồng ý với các Điều khoản Sử dụng ("Điều khoản") này.

Nếu bạn không đồng ý với bất kỳ điều khoản nào dưới đây, vui lòng không sử dụng Ứng dụng.

## 2. Miễn trừ trách nhiệm y tế (chi tiết)

- Ứng dụng cung cấp công cụ ghi chép và thống kê dựa trên dữ liệu do người dùng nhập, **không** tự chẩn đoán hay điều trị bất kỳ tình trạng sức khoẻ nào.
- Các tính năng phân tích AI (gợi ý cữ bú, nhận xét tăng trưởng, trả lời câu hỏi trong "Hỏi AI") được tạo tự động và **có thể chứa sai sót**. Đây không phải là ý kiến của chuyên gia y tế.
- Trong trường hợp khẩn cấp hoặc khi bé có dấu hiệu bất thường, hãy liên hệ ngay cơ sở y tế gần nhất hoặc gọi cấp cứu, **không** dựa vào Ứng dụng để xử lý tình huống khẩn cấp.
- Biểu đồ tăng trưởng, lịch tiêm chủng gợi ý trong Ứng dụng tham khảo theo chuẩn WHO/Bộ Y tế nhưng cần được bác sĩ xác nhận phù hợp với thể trạng riêng của từng bé.

## 3. Tài khoản người dùng

- Bạn phải từ 18 tuổi trở lên để tạo tài khoản, hoặc có sự đồng ý của cha mẹ/người giám hộ nếu dưới độ tuổi này.
- Bạn chịu trách nhiệm bảo mật thông tin đăng nhập (email, mật khẩu, sinh trắc học) và mọi hoạt động diễn ra dưới tài khoản của mình.
- Bạn cam kết cung cấp thông tin chính xác khi đăng ký và cập nhật kịp thời khi có thay đổi.
- Chúng tôi có quyền tạm ngưng hoặc chấm dứt tài khoản vi phạm Điều khoản này mà không cần báo trước, trong trường hợp phát hiện gian lận, lạm dụng hệ thống, hoặc vi phạm pháp luật.

## 4. Quyền sở hữu trí tuệ

Toàn bộ mã nguồn, giao diện, thương hiệu "MeBé Tracker", logo, và nội dung do chúng tôi tạo ra thuộc quyền sở hữu của chúng tôi. Bạn được cấp quyền sử dụng cá nhân, không độc quyền, không thể chuyển nhượng để sử dụng Ứng dụng cho mục đích cá nhân, phi thương mại.

## 5. Thanh toán và hoàn tiền

- Gói **Premium** được thanh toán qua App Store (Apple) hoặc Google Play, theo chu kỳ hàng tháng/hàng năm tuỳ lựa chọn của bạn.
- Việc gia hạn tự động được thực hiện trừ khi bạn huỷ ít nhất 24 giờ trước khi kết thúc chu kỳ hiện tại, thông qua cài đặt tài khoản App Store/Google Play.
- Chính sách hoàn tiền tuân theo quy định của Apple App Store và Google Play Store tương ứng — chúng tôi không trực tiếp xử lý hoàn tiền cho các giao dịch qua các nền tảng này.
- Giá gói Premium có thể thay đổi; thay đổi giá sẽ được thông báo trước và chỉ áp dụng cho chu kỳ gia hạn tiếp theo.

## 6. Nội dung người dùng

- Dữ liệu bạn nhập (nhật ký, ảnh, ghi âm, ghi chú) thuộc quyền sở hữu của bạn. Chúng tôi chỉ lưu trữ và xử lý để cung cấp dịch vụ.
- Bạn cam kết không tải lên nội dung vi phạm pháp luật, xâm phạm quyền riêng tư của người khác, hoặc chứa mã độc.
- Bạn có thể xuất hoặc xoá dữ liệu của mình bất kỳ lúc nào trong phần Hồ sơ > Xuất dữ liệu / Xoá tài khoản.

## 7. Giới hạn trách nhiệm

Trong phạm vi tối đa pháp luật cho phép, chúng tôi không chịu trách nhiệm đối với các thiệt hại gián tiếp, ngẫu nhiên, hoặc hệ quả phát sinh từ việc sử dụng hoặc không thể sử dụng Ứng dụng, bao gồm nhưng không giới hạn ở quyết định chăm sóc sức khoẻ dựa trên thông tin từ Ứng dụng. Ứng dụng được cung cấp "nguyên trạng" (as-is), không có bảo đảm nào về tính chính xác tuyệt đối hoặc không gián đoạn dịch vụ.

## 8. Thay đổi điều khoản

Chúng tôi có thể cập nhật Điều khoản này theo thời gian. Khi có thay đổi quan trọng, chúng tôi sẽ thông báo trong Ứng dụng và yêu cầu bạn xác nhận đồng ý lại trước khi tiếp tục sử dụng.

## 9. Luật áp dụng

Điều khoản này được điều chỉnh bởi pháp luật nước Cộng hoà Xã hội Chủ nghĩa Việt Nam. Mọi tranh chấp phát sinh sẽ được giải quyết tại cơ quan tài phán có thẩm quyền tại Việt Nam.

## 10. Liên hệ

Nếu có thắc mắc về Điều khoản Sử dụng, vui lòng liên hệ:
**Email:** support@mebetracker.app
''';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalTextScreen(
      title: 'Điều khoản sử dụng',
      markdownContent: _kTermsContent,
      lastUpdated: _kTermsLastUpdated,
      accentColor: AppColors.blossom,
    );
  }
}
