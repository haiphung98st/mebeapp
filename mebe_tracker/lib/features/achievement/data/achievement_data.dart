import '../../../shared/models/diaper_entry.dart';
import '../../../shared/models/feeding_entry.dart';
import '../../../shared/models/pump_entry.dart';
import '../../../shared/models/sleep_entry.dart';

class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.category,
    this.tier = AchievementTier.bronze,
  });

  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementCategory category;
  final AchievementTier tier;
}

enum AchievementCategory { feeding, sleep, diaper, pumping, growth, app, special }

enum AchievementTier { bronze, silver, gold, platinum }

const allAchievements = [
  // ── FEEDING ──────────────────────────────────────────────────────────────────
  AchievementDef(
    id: 'first_feed',
    name: 'Cữ đầu tiên',
    description: 'Ghi lại cữ bú đầu tiên của bé',
    icon: '🍼',
    category: AchievementCategory.feeding,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'feeding_10',
    name: 'Mẹ siêng năng',
    description: 'Ghi lại 10 cữ bú',
    icon: '🤱',
    category: AchievementCategory.feeding,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'feeding_100',
    name: 'Mẹ chuyên nghiệp',
    description: 'Ghi lại 100 cữ bú',
    icon: '⭐',
    category: AchievementCategory.feeding,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'feeding_500',
    name: 'Siêu mẹ',
    description: 'Ghi lại 500 cữ bú',
    icon: '🏆',
    category: AchievementCategory.feeding,
    tier: AchievementTier.gold,
  ),
  AchievementDef(
    id: 'solid_first',
    name: 'Ăn dặm rồi!',
    description: 'Bé lần đầu ăn thức ăn đặc',
    icon: '🥣',
    category: AchievementCategory.feeding,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'breastfeed_30',
    name: 'Mẹ sữa mẹ',
    description: 'Ghi lại 30 lần bú mẹ',
    icon: '💕',
    category: AchievementCategory.feeding,
    tier: AchievementTier.silver,
  ),

  // ── SLEEP ─────────────────────────────────────────────────────────────────────
  AchievementDef(
    id: 'first_sleep',
    name: 'Giấc đầu tiên',
    description: 'Ghi lại giấc ngủ đầu tiên của bé',
    icon: '🌙',
    category: AchievementCategory.sleep,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'sleep_50',
    name: 'Canh bé ngủ',
    description: 'Ghi lại 50 giấc ngủ',
    icon: '😴',
    category: AchievementCategory.sleep,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'sleep_100h',
    name: 'Bé ngủ ngon',
    description: 'Tổng 100 giờ ngủ được ghi lại',
    icon: '💤',
    category: AchievementCategory.sleep,
    tier: AchievementTier.gold,
  ),
  AchievementDef(
    id: 'night_5h',
    name: 'Đêm bình yên',
    description: 'Bé ngủ liền 5 giờ trong đêm',
    icon: '🌟',
    category: AchievementCategory.sleep,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'nap_10',
    name: 'Chuyên gia giấc ngắn',
    description: 'Ghi lại 10 giấc ngủ ngắn',
    icon: '☁️',
    category: AchievementCategory.sleep,
    tier: AchievementTier.bronze,
  ),

  // ── DIAPER ───────────────────────────────────────────────────────────────────
  AchievementDef(
    id: 'first_diaper',
    name: 'Tã đầu tiên',
    description: 'Ghi lại lần thay tã đầu tiên',
    icon: '🌸',
    category: AchievementCategory.diaper,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'diaper_50',
    name: 'Mẹ đổi tã nhanh',
    description: 'Ghi lại 50 lần thay tã',
    icon: '⚡',
    category: AchievementCategory.diaper,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'diaper_200',
    name: 'Chuyên gia thay tã',
    description: 'Ghi lại 200 lần thay tã',
    icon: '🎖️',
    category: AchievementCategory.diaper,
    tier: AchievementTier.silver,
  ),

  // ── PUMPING ──────────────────────────────────────────────────────────────────
  AchievementDef(
    id: 'first_pump',
    name: 'Hút sữa đầu tiên',
    description: 'Ghi lại lần hút sữa đầu tiên',
    icon: '🥛',
    category: AchievementCategory.pumping,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'pump_500ml',
    name: 'Mẹ nhiều sữa',
    description: 'Tổng tích trữ đạt 500ml',
    icon: '🍶',
    category: AchievementCategory.pumping,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'pump_2000ml',
    name: 'Kho sữa của bé',
    description: 'Tổng tích trữ đạt 2000ml',
    icon: '🏅',
    category: AchievementCategory.pumping,
    tier: AchievementTier.gold,
  ),
  AchievementDef(
    id: 'pump_5000ml',
    name: 'Siêu tích trữ',
    description: 'Tổng tích trữ đạt 5000ml',
    icon: '👑',
    category: AchievementCategory.pumping,
    tier: AchievementTier.platinum,
  ),

  // ── GROWTH ───────────────────────────────────────────────────────────────────
  AchievementDef(
    id: 'first_weight',
    name: 'Cân đầu tiên',
    description: 'Ghi lại cân nặng đầu tiên của bé',
    icon: '⚖️',
    category: AchievementCategory.growth,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'first_vaccine',
    name: 'Tiêm chủng đầu tiên',
    description: 'Đánh dấu mũi tiêm đầu tiên cho bé',
    icon: '💉',
    category: AchievementCategory.growth,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'ww_leap_1',
    name: 'Leap đầu tiên!',
    description: 'Bé vượt qua Leap 1',
    icon: '🧠',
    category: AchievementCategory.growth,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'ww_leap_5',
    name: 'Năm Leap kỳ diệu',
    description: 'Bé vượt qua 5 Leap phát triển',
    icon: '🌈',
    category: AchievementCategory.growth,
    tier: AchievementTier.gold,
  ),
  AchievementDef(
    id: 'ww_all_leaps',
    name: 'Hành trình kỳ diệu',
    description: 'Bé vượt qua tất cả 10 Leap',
    icon: '✨',
    category: AchievementCategory.growth,
    tier: AchievementTier.platinum,
  ),

  // ── APP ───────────────────────────────────────────────────────────────────────
  AchievementDef(
    id: 'baby_created',
    name: 'Hành trình bắt đầu',
    description: 'Tạo hồ sơ bé đầu tiên',
    icon: '👶',
    category: AchievementCategory.app,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'streak_7',
    name: '7 ngày liên tiếp',
    description: 'Ghi chép đầy đủ 7 ngày liên tiếp',
    icon: '🔥',
    category: AchievementCategory.app,
    tier: AchievementTier.silver,
  ),
  AchievementDef(
    id: 'streak_30',
    name: 'Tháng vàng',
    description: 'Ghi chép đầy đủ 30 ngày liên tiếp',
    icon: '🌞',
    category: AchievementCategory.app,
    tier: AchievementTier.gold,
  ),
  AchievementDef(
    id: 'premium',
    name: 'Mẹ cao cấp',
    description: 'Nâng cấp lên MeBé Premium',
    icon: '💎',
    category: AchievementCategory.app,
    tier: AchievementTier.gold,
  ),
  AchievementDef(
    id: 'night_owl',
    name: 'Mẹ thức đêm',
    description: 'Ghi lại sự kiện lúc 2–4 giờ sáng',
    icon: '🦉',
    category: AchievementCategory.special,
    tier: AchievementTier.bronze,
  ),
  AchievementDef(
    id: 'early_bird',
    name: 'Dậy sớm cùng bé',
    description: 'Ghi lại sự kiện trước 6 giờ sáng',
    icon: '🌅',
    category: AchievementCategory.special,
    tier: AchievementTier.bronze,
  ),
];

class AchievementInput {
  const AchievementInput({
    required this.feedings,
    required this.sleeps,
    required this.diapers,
    required this.pumps,
    required this.babyCreated,
    required this.isPremium,
    required this.babyWeekFromEdd,
  });

  final List<FeedingEntry> feedings;
  final List<SleepEntry> sleeps;
  final List<DiaperEntry> diapers;
  final List<PumpEntry> pumps;
  final bool babyCreated;
  final bool isPremium;
  final int babyWeekFromEdd;
}

class AchievementEvaluator {
  static Set<String> evaluate(AchievementInput input) {
    final unlocked = <String>{};
    final feedings = input.feedings;
    final sleeps = input.sleeps;
    final diapers = input.diapers;
    final pumps = input.pumps;

    // FEEDING
    if (feedings.isNotEmpty) unlocked.add('first_feed');
    if (feedings.length >= 10) unlocked.add('feeding_10');
    if (feedings.length >= 100) unlocked.add('feeding_100');
    if (feedings.length >= 500) unlocked.add('feeding_500');
    if (feedings.any((e) => e.type == FeedingType.solid)) unlocked.add('solid_first');
    final breastCount = feedings
        .where((e) =>
            e.type == FeedingType.breastLeft || e.type == FeedingType.breastRight)
        .length;
    if (breastCount >= 30) unlocked.add('breastfeed_30');

    // SLEEP
    if (sleeps.isNotEmpty) unlocked.add('first_sleep');
    if (sleeps.length >= 50) unlocked.add('sleep_50');
    final totalSleepHours = sleeps.fold<int>(0, (s, e) => s + (e.durationMinutes ?? 0)) / 60;
    if (totalSleepHours >= 100) unlocked.add('sleep_100h');
    final napCount = sleeps.where((e) => e.type == SleepType.nap).length;
    if (napCount >= 10) unlocked.add('nap_10');
    final hasLongNight = sleeps.any((e) =>
        e.type == SleepType.night && (e.durationMinutes ?? 0) >= 300);
    if (hasLongNight) unlocked.add('night_5h');

    // DIAPER
    if (diapers.isNotEmpty) unlocked.add('first_diaper');
    if (diapers.length >= 50) unlocked.add('diaper_50');
    if (diapers.length >= 200) unlocked.add('diaper_200');

    // PUMPING
    if (pumps.isNotEmpty) unlocked.add('first_pump');
    final totalPumpMl = pumps.fold<double>(
        0, (s, e) => s + (e.leftAmountMl ?? 0) + (e.rightAmountMl ?? 0));
    if (totalPumpMl >= 500) unlocked.add('pump_500ml');
    if (totalPumpMl >= 2000) unlocked.add('pump_2000ml');
    if (totalPumpMl >= 5000) unlocked.add('pump_5000ml');

    // GROWTH / WONDER WEEKS
    if (input.babyWeekFromEdd >= 7) unlocked.add('ww_leap_1');
    if (input.babyWeekFromEdd >= 34) unlocked.add('ww_leap_5');
    if (input.babyWeekFromEdd >= 64) unlocked.add('ww_all_leaps');

    // APP
    if (input.babyCreated) unlocked.add('baby_created');
    if (input.isPremium) unlocked.add('premium');

    // STREAK — check if any 7 or 30 consecutive days have an event
    final allEventDays = {
      ...feedings.map((e) => _dayKey(e.startTime)),
      ...sleeps.map((e) => _dayKey(e.startTime)),
      ...diapers.map((e) => _dayKey(e.time)),
      ...pumps.map((e) => _dayKey(e.startTime)),
    };
    final streak = _longestStreak(allEventDays);
    if (streak >= 7) unlocked.add('streak_7');
    if (streak >= 30) unlocked.add('streak_30');

    // SPECIAL
    final nightHours = {
      ...feedings.where((e) {
        final h = e.startTime.hour;
        return h >= 2 && h < 4;
      }).map((e) => _dayKey(e.startTime)),
      ...sleeps.where((e) {
        final h = e.startTime.hour;
        return h >= 2 && h < 4;
      }).map((e) => _dayKey(e.startTime)),
    };
    if (nightHours.isNotEmpty) unlocked.add('night_owl');

    final earlyBird = {
      ...feedings.where((e) => e.startTime.hour < 6).map((e) => _dayKey(e.startTime)),
      ...diapers.where((e) => e.time.hour < 6).map((e) => _dayKey(e.time)),
    };
    if (earlyBird.isNotEmpty) unlocked.add('early_bird');

    return unlocked;
  }

  static String _dayKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';

  static int _longestStreak(Set<String> dayKeys) {
    if (dayKeys.isEmpty) return 0;
    final sorted = dayKeys.toList()..sort();
    int streak = 1;
    int maxStreak = 1;
    for (var i = 1; i < sorted.length; i++) {
      final prev = DateTime.parse(sorted[i - 1]);
      final curr = DateTime.parse(sorted[i]);
      if (curr.difference(prev).inDays == 1) {
        streak++;
        if (streak > maxStreak) maxStreak = streak;
      } else {
        streak = 1;
      }
    }
    return maxStreak;
  }
}
