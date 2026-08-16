class LeapData {
  const LeapData({
    required this.number,
    required this.name,
    required this.stormStartWeek,
    required this.stormEndWeek,
    required this.sunnyEndWeek,
    required this.description,
    required this.skills,
    required this.tipsForMom,
  });

  final int number;
  final String name;
  final int stormStartWeek;
  final int stormEndWeek;
  final int sunnyEndWeek;
  final String description;
  final List<String> skills;
  final List<String> tipsForMom;
}

const wonderWeeksLeaps = [
  LeapData(
    number: 1,
    name: 'Thế giới cảm giác',
    stormStartWeek: 4,
    stormEndWeek: 5,
    sunnyEndWeek: 7,
    description:
        'Bé bắt đầu nhận ra rằng thế giới không hoàn toàn là một phần của chính bé. '
        'Các giác quan phát triển và bé nhạy cảm hơn với ánh sáng, âm thanh, mùi và xúc giác.',
    skills: [
      'Tập trung nhìn vào khuôn mặt người thân',
      'Phản ứng với âm thanh và giọng nói',
      'Nhận ra mùi của mẹ',
      'Cử động tay chân có chủ đích hơn',
    ],
    tipsForMom: [
      'Ôm bé nhiều hơn, da kề da giúp bé cảm thấy an toàn',
      'Nói chuyện nhẹ nhàng và hát ru cho bé nghe',
      'Giảm tiếng ồn xung quanh khi bé quấy',
      'Cho bé bú khi cần — bé đang học cảm giác no/đói',
    ],
  ),
  LeapData(
    number: 2,
    name: 'Các khuôn mẫu',
    stormStartWeek: 7,
    stormEndWeek: 9,
    sunnyEndWeek: 11,
    description:
        'Bé bắt đầu nhận ra các khuôn mẫu đơn giản — hình dạng, âm thanh lặp đi lặp lại, '
        'và thói quen hàng ngày. Đây là bước đầu để bé hiểu về trật tự của thế giới.',
    skills: [
      'Mỉm cười đáp lại khuôn mặt',
      'Theo dõi vật chuyển động bằng mắt',
      'Phát ra âm thanh như "ah", "eh"',
      'Nhận ra thói quen bú và ngủ',
    ],
    tipsForMom: [
      'Tạo thói quen nhất quán để bé cảm thấy an tâm',
      'Nói chuyện và hát các bài lặp đi lặp lại',
      'Cho bé nhìn các vật có màu sắc tương phản',
      'Massage nhẹ nhàng theo nhịp đều đặn',
    ],
  ),
  LeapData(
    number: 3,
    name: 'Chuyển tiếp trơn tru',
    stormStartWeek: 11,
    stormEndWeek: 12,
    sunnyEndWeek: 15,
    description:
        'Bé khám phá ra sự chuyển đổi — từ trạng thái này sang trạng thái khác. '
        'Bé bắt đầu hiểu rằng mọi vật không chỉ "có" hoặc "không có" mà còn có thể thay đổi.',
    skills: [
      'Phát ra nhiều âm thanh khác nhau',
      'Cười thành tiếng',
      'Điều khiển tay và chân linh hoạt hơn',
      'Ngẩng đầu khi nằm sấp',
    ],
    tipsForMom: [
      'Chơi trò "ú òa" đơn giản với bé',
      'Cho bé tập nằm sấp mỗi ngày (tummy time)',
      'Hát các bài có nhịp điệu thay đổi',
      'Bình tĩnh khi bé quấy — đây là giai đoạn bình thường',
    ],
  ),
  LeapData(
    number: 4,
    name: 'Sự kiện',
    stormStartWeek: 14,
    stormEndWeek: 15,
    sunnyEndWeek: 19,
    description:
        'Bé nhận ra rằng thế giới được tạo thành từ các sự kiện — hành động có nguyên nhân '
        'và kết quả. Đây là bước nhảy vọt lớn trong tư duy nhân quả của bé.',
    skills: [
      'Với tay và cầm nắm đồ vật',
      'Chú ý đến những điều xảy ra xung quanh',
      'Bắt chước các cử chỉ đơn giản',
      'Phân biệt người quen và người lạ',
    ],
    tipsForMom: [
      'Cho bé chơi với đồ chơi phát ra tiếng khi chạm vào',
      'Mô tả những gì bạn đang làm cho bé nghe',
      'Kiên nhẫn — bé có thể bám mẹ hơn trong giai đoạn này',
      'Đọc sách tranh ảnh đơn giản cho bé',
    ],
  ),
  LeapData(
    number: 5,
    name: 'Các mối quan hệ',
    stormStartWeek: 22,
    stormEndWeek: 26,
    sunnyEndWeek: 30,
    description:
        'Bé bắt đầu hiểu về khoảng cách và mối quan hệ không gian — xa/gần, trong/ngoài, '
        'lên/xuống. Bé cũng nhận ra mối quan hệ giữa người và vật xung quanh.',
    skills: [
      'Ngồi với sự hỗ trợ',
      'Hiểu "không" và các từ đơn giản',
      'Ăn thức ăn đặc đầu tiên',
      'Lo lắng khi xa mẹ (separation anxiety bắt đầu)',
    ],
    tipsForMom: [
      'Chơi "lấy vật từ hộp" để bé hiểu trong/ngoài',
      'Nói tên các vật khi chỉ vào chúng',
      'Kiên nhẫn với separation anxiety — đây là dấu hiệu gắn kết tốt',
      'Bắt đầu thức ăn dặm nếu bé sẵn sàng',
    ],
  ),
  LeapData(
    number: 6,
    name: 'Các loại',
    stormStartWeek: 33,
    stormEndWeek: 37,
    sunnyEndWeek: 42,
    description:
        'Bé học cách phân loại — hiểu rằng những thứ khác nhau có thể thuộc cùng một nhóm. '
        'Đây là nền tảng cho tư duy trừu tượng và ngôn ngữ.',
    skills: [
      'Nhận ra các con vật và tên gọi',
      'Bập bẹ "mama", "dada"',
      'Cầm cốc và tự uống nước',
      'Hiểu các lệnh đơn giản',
    ],
    tipsForMom: [
      'Phân loại đồ chơi theo màu sắc, hình dạng',
      'Đọc sách có hình ảnh các nhóm đồ vật',
      'Chơi trò đặt tên — "đây là mèo, đây là chó"',
      'Cho bé tham gia các hoạt động gia đình đơn giản',
    ],
  ),
  LeapData(
    number: 7,
    name: 'Chuỗi hành động',
    stormStartWeek: 40,
    stormEndWeek: 44,
    sunnyEndWeek: 47,
    description:
        'Bé hiểu rằng để đạt mục tiêu, cần thực hiện nhiều bước theo thứ tự. '
        'Đây là bước đầu của tư duy lập kế hoạch và giải quyết vấn đề.',
    skills: [
      'Đi những bước đầu tiên',
      'Nói được một vài từ',
      'Chơi giả vờ đơn giản',
      'Sử dụng cử chỉ như vẫy tay, chỉ tay',
    ],
    tipsForMom: [
      'Tạo trò chơi có nhiều bước đơn giản',
      'Khích lệ bé khi bé cố gắng tự làm',
      'Đọc sách có câu chuyện đơn giản, có trình tự',
      'Kiên nhẫn với những lần "thử và sai" của bé',
    ],
  ),
  LeapData(
    number: 8,
    name: 'Các chương trình',
    stormStartWeek: 46,
    stormEndWeek: 51,
    sunnyEndWeek: 55,
    description:
        'Bé hiểu rằng có nhiều cách để đạt được cùng một mục tiêu. '
        'Bé bắt đầu lựa chọn chiến lược và thích nghi với hoàn cảnh.',
    skills: [
      'Đi vững hơn, có thể chạy',
      'Nói nhiều từ và ghép 2 từ',
      'Giải quyết vấn đề đơn giản',
      'Chơi giả vờ phức tạp hơn',
    ],
    tipsForMom: [
      'Cho bé chọn giữa hai lựa chọn đơn giản',
      'Chơi trò xếp hình và ghép đồ',
      'Đọc sách và thảo luận "tại sao"',
      'Khuyến khích tính độc lập trong giới hạn an toàn',
    ],
  ),
  LeapData(
    number: 9,
    name: 'Các nguyên lý',
    stormStartWeek: 51,
    stormEndWeek: 54,
    sunnyEndWeek: 59,
    description:
        'Bé bắt đầu hiểu các quy tắc và nguyên lý — rằng có những luật lệ chi phối '
        'cách mọi thứ hoạt động. Bé bắt đầu kiểm tra giới hạn.',
    skills: [
      'Hiểu khái niệm "của tôi" và "của bạn"',
      'Biết tên của nhiều đồ vật',
      'Chơi theo các quy tắc đơn giản',
      'Thể hiện cảm xúc phong phú hơn',
    ],
    tipsForMom: [
      'Đặt ra các quy tắc nhất quán, rõ ràng',
      'Giải thích "tại sao" theo cách bé hiểu được',
      'Chơi các trò chơi có luật đơn giản',
      'Đọc sách về cảm xúc và xã hội',
    ],
  ),
  LeapData(
    number: 10,
    name: 'Hệ thống',
    stormStartWeek: 59,
    stormEndWeek: 64,
    sunnyEndWeek: 70,
    description:
        'Bé hiểu rằng thế giới được tổ chức thành các hệ thống — gia đình, xã hội, '
        'thiên nhiên. Đây là bước nhảy vọt cuối cùng và là nền tảng cho tư duy trưởng thành.',
    skills: [
      'Hiểu vai trò trong gia đình và cộng đồng',
      'Nói câu dài hơn, kể chuyện',
      'Chơi hợp tác với các trẻ khác',
      'Thể hiện sự đồng cảm',
    ],
    tipsForMom: [
      'Giải thích các mối quan hệ trong gia đình',
      'Cho bé tham gia các hoạt động cộng đồng',
      'Khen ngợi hành vi tốt, giải thích hành vi không phù hợp',
      'Đọc sách về cộng đồng và thế giới xung quanh',
    ],
  ),
];

enum LeapStatus { beforeFirst, stormy, sunny, done }

class LeapState {
  const LeapState({
    required this.leap,
    required this.status,
    required this.weekFromEdd,
    required this.daysUntilStorm,
    required this.daysInStorm,
  });

  final LeapData leap;
  final LeapStatus status;
  final int weekFromEdd;
  final int daysUntilStorm;
  final int daysInStorm;

  bool get isActive => status == LeapStatus.stormy || status == LeapStatus.sunny;
}

class WonderWeeksService {
  static DateTime baseDate(DateTime dateOfBirth, DateTime? edd) =>
      edd ?? dateOfBirth;

  static int weeksFromBase(DateTime dateOfBirth, DateTime? edd) {
    final base = baseDate(dateOfBirth, edd);
    return DateTime.now().difference(base).inDays ~/ 7;
  }

  static LeapData? currentLeap(DateTime dateOfBirth, DateTime? edd) {
    final weeks = weeksFromBase(dateOfBirth, edd);
    for (final leap in wonderWeeksLeaps) {
      if (weeks >= leap.stormStartWeek && weeks < leap.sunnyEndWeek) {
        return leap;
      }
    }
    return null;
  }

  static LeapStatus leapStatus(LeapData leap, int weeks) {
    if (weeks < leap.stormStartWeek) return LeapStatus.beforeFirst;
    if (weeks < leap.stormEndWeek) return LeapStatus.stormy;
    if (weeks < leap.sunnyEndWeek) return LeapStatus.sunny;
    return LeapStatus.done;
  }

  static LeapData? nextLeap(DateTime dateOfBirth, DateTime? edd) {
    final weeks = weeksFromBase(dateOfBirth, edd);
    for (final leap in wonderWeeksLeaps) {
      if (weeks < leap.stormStartWeek) return leap;
    }
    return null;
  }

  static List<LeapState> allLeapStates(DateTime dateOfBirth, DateTime? edd) {
    final base = baseDate(dateOfBirth, edd);
    final now = DateTime.now();
    final weeks = now.difference(base).inDays ~/ 7;
    return wonderWeeksLeaps.map((leap) {
      final status = leapStatus(leap, weeks);
      final stormStart = base.add(Duration(days: leap.stormStartWeek * 7));
      final daysUntilStorm = stormStart.difference(now).inDays;
      final daysInStorm = now.difference(stormStart).inDays;
      return LeapState(
        leap: leap,
        status: status,
        weekFromEdd: weeks,
        daysUntilStorm: daysUntilStorm.clamp(0, 999),
        daysInStorm: daysInStorm.clamp(0, 999),
      );
    }).toList();
  }
}
