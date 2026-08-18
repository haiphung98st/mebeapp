import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import 'legal_text_screen.dart';

const _kPrivacyLastUpdated = '14/08/2026';

const _kPrivacyContent = '''
Chính sách Bảo mật này giải thích cách MeBé Tracker ("chúng tôi") thu thập, sử dụng, lưu trữ và bảo vệ dữ liệu cá nhân của bạn, tuân thủ **Nghị định 13/2023/NĐ-CP về Bảo vệ Dữ liệu Cá nhân** của Việt Nam.

## 1. Dữ liệu chúng tôi thu thập

**Dữ liệu bạn cung cấp trực tiếp:**
- Thông tin tài khoản: họ tên, email, mật khẩu (mã hoá), ảnh đại diện
- Thông tin của bé: tên, ngày sinh, giới tính, cân nặng/chiều cao
- Dữ liệu chăm sóc: cữ bú, giấc ngủ, thay tã, tiêm chủng, ghi chú, ảnh, ghi âm nhật ký
- Thông tin thanh toán khi nâng cấp Premium (xử lý bởi Apple/Google, chúng tôi không lưu số thẻ)

**Dữ liệu thu thập tự động:**
- Nhật ký sự cố kỹ thuật (crash log) qua Firebase Crashlytics để cải thiện độ ổn định
- Thông tin thiết bị cơ bản: hệ điều hành, phiên bản ứng dụng (phục vụ hỗ trợ kỹ thuật)

**Dữ liệu KHÔNG được thu thập:**
- Vị trí định vị GPS chính xác
- Danh bạ điện thoại
- Lịch sử duyệt web hoặc dữ liệu từ ứng dụng khác

## 2. Mục đích và căn cứ pháp lý xử lý dữ liệu

| Mục đích | Căn cứ pháp lý |
|---|---|
| Cung cấp tính năng theo dõi, thống kê | Thực hiện hợp đồng dịch vụ (Điều khoản Sử dụng) |
| Gửi thông báo nhắc nhở (cữ bú, tiêm chủng...) | Sự đồng ý của người dùng |
| Phân tích AI (gợi ý, trả lời trong Hỏi AI) | Sự đồng ý của người dùng |
| Xử lý thanh toán Premium | Thực hiện hợp đồng |
| Khắc phục lỗi, đảm bảo an ninh hệ thống | Lợi ích hợp pháp của chúng tôi |
| Tuân thủ yêu cầu pháp luật | Nghĩa vụ pháp lý |

## 3. Bên thứ ba xử lý dữ liệu

Chúng tôi chia sẻ dữ liệu với các đối tác xử lý sau, chỉ trong phạm vi cần thiết để cung cấp dịch vụ:

- **Firebase / Google Cloud** — lưu trữ dữ liệu, xác thực tài khoản, thông báo đẩy, phân tích sự cố (Crashlytics)
- **Anthropic (Claude AI)** — xử lý câu hỏi trong tính năng "Hỏi AI"; nội dung câu hỏi có thể được gửi đến API của Anthropic để tạo câu trả lời
- **OpenAI (Whisper)** — chuyển đổi ghi âm nhật ký giọng nói thành văn bản (nếu bạn sử dụng tính năng nhật ký giọng nói)
- **Apple App Store / Google Play** — xử lý thanh toán gói Premium

Các bên thứ ba này chỉ nhận dữ liệu cần thiết cho chức năng tương ứng và bị ràng buộc bởi chính sách bảo mật riêng của họ.

## 4. Nơi lưu trữ dữ liệu

Dữ liệu của bạn được lưu trữ trên hạ tầng Firebase tại khu vực **asia-southeast1 (Singapore)**. Chúng tôi áp dụng các biện pháp kỹ thuật để đảm bảo an toàn dữ liệu khi truyền tải quốc tế theo quy định của Nghị định 13/2023/NĐ-CP.

## 5. Biện pháp bảo mật

- Mã hoá dữ liệu khi truyền tải (TLS/HTTPS) và khi lưu trữ
- Xác thực đăng nhập qua Firebase Authentication, hỗ trợ sinh trắc học (Face ID/Touch ID)
- Quy tắc phân quyền Firestore đảm bảo chỉ chủ tài khoản (và thành viên gia đình được mời) mới truy cập được dữ liệu
- Giám sát và ghi nhận sự cố bảo mật qua Firebase Crashlytics

## 6. Thời gian lưu trữ

Dữ liệu được lưu trữ trong suốt thời gian bạn duy trì tài khoản. Khi bạn xoá tài khoản, dữ liệu cá nhân sẽ được xoá khỏi hệ thống trong vòng **30 ngày**, trừ dữ liệu cần lưu giữ theo nghĩa vụ pháp lý (ví dụ hoá đơn thanh toán).

## 7. Quyền của bạn theo Nghị định 13/2023/NĐ-CP

Với tư cách chủ thể dữ liệu, bạn có các quyền sau:

1. **Quyền được biết** — biết về hoạt động xử lý dữ liệu cá nhân của mình (chính sách này)
2. **Quyền đồng ý** — đồng ý hoặc không đồng ý cho phép xử lý dữ liệu cá nhân
3. **Quyền truy cập** — xem lại dữ liệu cá nhân của mình trong phần Hồ sơ
4. **Quyền chỉnh sửa** — cập nhật, sửa đổi thông tin cá nhân bất kỳ lúc nào
5. **Quyền xoá dữ liệu** — yêu cầu xoá tài khoản và toàn bộ dữ liệu liên quan
6. **Quyền phản đối/hạn chế xử lý** — rút lại sự đồng ý đối với các mục đích không bắt buộc (ví dụ thông báo, phân tích AI)
7. **Quyền di chuyển dữ liệu** — yêu cầu xuất dữ liệu ở định dạng có thể đọc được (PDF/JSON)

Để thực hiện các quyền trên, liên hệ **privacy@mebetracker.app**.

## 8. Cookie và theo dõi

Ứng dụng di động không sử dụng cookie trình duyệt. Chúng tôi có thể sử dụng mã định danh thiết bị ẩn danh cho mục đích phân tích lỗi kỹ thuật (Firebase Crashlytics), không dùng cho quảng cáo.

## 9. Dữ liệu trẻ em

Ứng dụng thu thập thông tin về trẻ em (con của người dùng) do chính cha mẹ/người giám hộ hợp pháp nhập vào và quản lý. Chúng tôi không thu thập dữ liệu trực tiếp từ trẻ em dưới 16 tuổi. Cha mẹ/người giám hộ chịu trách nhiệm và có toàn quyền kiểm soát dữ liệu của con mình trong Ứng dụng.

## 10. Thay đổi chính sách

Khi có thay đổi quan trọng về cách xử lý dữ liệu, chúng tôi sẽ thông báo trong Ứng dụng và yêu cầu bạn xác nhận đồng ý lại trước khi tiếp tục sử dụng.

## 11. Liên hệ / Cán bộ phụ trách bảo vệ dữ liệu (DPO)

**Email:** privacy@mebetracker.app
Chúng tôi sẽ phản hồi yêu cầu liên quan đến dữ liệu cá nhân trong vòng **72 giờ làm việc**.
''';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LegalTextScreen(
      title: 'Chính sách bảo mật',
      markdownContent: _kPrivacyContent,
      lastUpdated: _kPrivacyLastUpdated,
      accentColor: AppColors.lavender,
    );
  }
}
