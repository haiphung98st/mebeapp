// Baby size comparisons and development info per pregnancy week.
class WeeklyBabyInfo {
  const WeeklyBabyInfo({
    required this.week,
    required this.sizeComparison,
    required this.sizeEmoji,
    required this.lengthCm,
    required this.weightG,
    required this.highlight,
  });

  final int week;
  final String sizeComparison; // Vietnamese
  final String sizeEmoji;
  final double lengthCm;
  final double weightG;
  final String highlight;
}

const weeklyBabyData = <WeeklyBabyInfo>[
  WeeklyBabyInfo(week: 4, sizeComparison: 'Hạt vừng', sizeEmoji: '🌱', lengthCm: 0.1, weightG: 0, highlight: 'Phôi thai đang hình thành!'),
  WeeklyBabyInfo(week: 5, sizeComparison: 'Hạt mè', sizeEmoji: '🌿', lengthCm: 0.2, weightG: 0, highlight: 'Tim bắt đầu đập'),
  WeeklyBabyInfo(week: 6, sizeComparison: 'Hạt đậu', sizeEmoji: '🫘', lengthCm: 0.6, weightG: 0, highlight: 'Chồi tay chân hình thành'),
  WeeklyBabyInfo(week: 7, sizeComparison: 'Quả việt quất', sizeEmoji: '🫐', lengthCm: 1.3, weightG: 1, highlight: 'Não bộ phát triển nhanh'),
  WeeklyBabyInfo(week: 8, sizeComparison: 'Quả nho', sizeEmoji: '🍇', lengthCm: 1.6, weightG: 1, highlight: 'Ngón tay bắt đầu rõ'),
  WeeklyBabyInfo(week: 9, sizeComparison: 'Quả ô liu', sizeEmoji: '🫒', lengthCm: 2.3, weightG: 2, highlight: 'Các cơ quan hình thành'),
  WeeklyBabyInfo(week: 10, sizeComparison: 'Quả dâu', sizeEmoji: '🍓', lengthCm: 3.2, weightG: 4, highlight: 'Bé bắt đầu vận động!'),
  WeeklyBabyInfo(week: 11, sizeComparison: 'Quả chanh vàng', sizeEmoji: '🍋', lengthCm: 4.1, weightG: 7, highlight: 'Mống mắt hình thành'),
  WeeklyBabyInfo(week: 12, sizeComparison: 'Quả mơ', sizeEmoji: '🍑', lengthCm: 5.4, weightG: 14, highlight: 'Hết nguy cơ sảy thai'),
  WeeklyBabyInfo(week: 13, sizeComparison: 'Quả đậu Hà Lan', sizeEmoji: '🫑', lengthCm: 7.4, weightG: 23, highlight: 'Bước vào tam cá nguyệt 2'),
  WeeklyBabyInfo(week: 14, sizeComparison: 'Quả chanh', sizeEmoji: '🍋', lengthCm: 8.7, weightG: 43, highlight: 'Bé có thể mút ngón tay'),
  WeeklyBabyInfo(week: 15, sizeComparison: 'Quả lê', sizeEmoji: '🍐', lengthCm: 10.1, weightG: 70, highlight: 'Lông mày xuất hiện'),
  WeeklyBabyInfo(week: 16, sizeComparison: 'Quả bơ', sizeEmoji: '🥑', lengthCm: 11.6, weightG: 100, highlight: 'Bé nghe được âm thanh'),
  WeeklyBabyInfo(week: 17, sizeComparison: 'Củ cải', sizeEmoji: '🥕', lengthCm: 13.0, weightG: 140, highlight: 'Dây mỡ bắt đầu hình thành'),
  WeeklyBabyInfo(week: 18, sizeComparison: 'Cái ớt chuông', sizeEmoji: '🫑', lengthCm: 14.2, weightG: 190, highlight: 'Có thể siêu âm thấy giới tính'),
  WeeklyBabyInfo(week: 19, sizeComparison: 'Quả cà chua', sizeEmoji: '🍅', lengthCm: 15.3, weightG: 240, highlight: 'Bé vận động nhiều hơn'),
  WeeklyBabyInfo(week: 20, sizeComparison: 'Quả chuối', sizeEmoji: '🍌', lengthCm: 16.4, weightG: 300, highlight: 'Bán chặng đường rồi!'),
  WeeklyBabyInfo(week: 21, sizeComparison: 'Quả cà rốt', sizeEmoji: '🥕', lengthCm: 26.7, weightG: 360, highlight: 'Bé nuốt nước ối nhiều hơn'),
  WeeklyBabyInfo(week: 22, sizeComparison: 'Trái bắp', sizeEmoji: '🌽', lengthCm: 27.8, weightG: 430, highlight: 'Bé đáp lại tiếng mẹ'),
  WeeklyBabyInfo(week: 23, sizeComparison: 'Quả xoài', sizeEmoji: '🥭', lengthCm: 28.9, weightG: 501, highlight: 'Da bắt đầu hồng hào'),
  WeeklyBabyInfo(week: 24, sizeComparison: 'Quả ổi', sizeEmoji: '🍈', lengthCm: 30.0, weightG: 600, highlight: 'Phổi bắt đầu tập thở'),
  WeeklyBabyInfo(week: 25, sizeComparison: 'Củ cải trắng', sizeEmoji: '🥬', lengthCm: 34.6, weightG: 660, highlight: 'Não phát triển nhanh'),
  WeeklyBabyInfo(week: 26, sizeComparison: 'Bó cải xanh', sizeEmoji: '🥦', lengthCm: 35.6, weightG: 760, highlight: 'Mắt mở đôi mắt rồi!'),
  WeeklyBabyInfo(week: 27, sizeComparison: 'Bó súp lơ', sizeEmoji: '🥦', lengthCm: 36.6, weightG: 875, highlight: 'Ngủ theo chu kỳ rõ rệt'),
  WeeklyBabyInfo(week: 28, sizeComparison: 'Cây cà tím', sizeEmoji: '🍆', lengthCm: 37.6, weightG: 1005, highlight: 'Bước vào tam cá nguyệt 3!'),
  WeeklyBabyInfo(week: 29, sizeComparison: 'Quả bí đao', sizeEmoji: '🥒', lengthCm: 38.6, weightG: 1153, highlight: 'Xương cứng dần'),
  WeeklyBabyInfo(week: 30, sizeComparison: 'Quả dưa chuột lớn', sizeEmoji: '🥒', lengthCm: 39.9, weightG: 1319, highlight: 'Lông tơ bắt đầu rụng'),
  WeeklyBabyInfo(week: 31, sizeComparison: 'Trái dừa xiêm', sizeEmoji: '🥥', lengthCm: 41.1, weightG: 1502, highlight: 'Bé đạp nhiều hơn'),
  WeeklyBabyInfo(week: 32, sizeComparison: 'Quả dưa lưới', sizeEmoji: '🍈', lengthCm: 42.4, weightG: 1702, highlight: 'Mắt nhận biết ánh sáng'),
  WeeklyBabyInfo(week: 33, sizeComparison: 'Quả dứa', sizeEmoji: '🍍', lengthCm: 43.7, weightG: 1918, highlight: 'Não và phổi trưởng thành'),
  WeeklyBabyInfo(week: 34, sizeComparison: 'Quả bưởi', sizeEmoji: '🍊', lengthCm: 45.0, weightG: 2146, highlight: 'Hầu hết cơ quan hoàn thiện'),
  WeeklyBabyInfo(week: 35, sizeComparison: 'Quả dưa hấu nhỏ', sizeEmoji: '🍉', lengthCm: 46.2, weightG: 2383, highlight: 'Bé quay đầu xuống'),
  WeeklyBabyInfo(week: 36, sizeComparison: 'Quả đu đủ', sizeEmoji: '🍈', lengthCm: 47.4, weightG: 2622, highlight: 'Sắp đủ tháng rồi!'),
  WeeklyBabyInfo(week: 37, sizeComparison: 'Củ khoai tây lớn', sizeEmoji: '🥔', lengthCm: 48.6, weightG: 2859, highlight: 'Đủ tháng rồi!'),
  WeeklyBabyInfo(week: 38, sizeComparison: 'Quả bí ngòi lớn', sizeEmoji: '🥒', lengthCm: 49.8, weightG: 3083, highlight: 'Mọi thứ đã sẵn sàng'),
  WeeklyBabyInfo(week: 39, sizeComparison: 'Trái dưa hấu', sizeEmoji: '🍉', lengthCm: 50.7, weightG: 3288, highlight: 'Sẵn sàng chào đời!'),
  WeeklyBabyInfo(week: 40, sizeComparison: 'Quả bí ngô nhỏ', sizeEmoji: '🎃', lengthCm: 51.2, weightG: 3462, highlight: 'Ngày dự sinh đây rồi!'),
];

WeeklyBabyInfo? infoForWeek(int week) {
  try {
    return weeklyBabyData.firstWhere((d) => d.week == week);
  } catch (_) {
    return null;
  }
}
