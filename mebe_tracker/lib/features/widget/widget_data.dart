class WidgetData {
  const WidgetData({
    required this.babyName,
    required this.babyAgeWeeks,
    required this.lastFeedingTime,
    required this.lastFeedingType,
    required this.nextFeedingTime,
    required this.isSleeping,
    required this.sleepStartTime,
    required this.todayFeedingCount,
    required this.todaySleepMinutes,
    required this.todayDiaperCount,
    required this.todayPumpMl,
    required this.isPremium,
  });

  final String babyName;
  final int babyAgeWeeks;
  final DateTime? lastFeedingTime;
  final String lastFeedingType;
  final DateTime? nextFeedingTime;
  final bool isSleeping;
  final DateTime? sleepStartTime;
  final int todayFeedingCount;
  final int todaySleepMinutes;
  final int todayDiaperCount;
  final double todayPumpMl;
  final bool isPremium;

  factory WidgetData.empty() => const WidgetData(
        babyName: '',
        babyAgeWeeks: 0,
        lastFeedingTime: null,
        lastFeedingType: '',
        nextFeedingTime: null,
        isSleeping: false,
        sleepStartTime: null,
        todayFeedingCount: 0,
        todaySleepMinutes: 0,
        todayDiaperCount: 0,
        todayPumpMl: 0,
        isPremium: false,
      );

  Map<String, dynamic> toJson() => {
        'babyName': babyName,
        'babyAgeWeeks': babyAgeWeeks,
        'lastFeedingTime': lastFeedingTime?.toIso8601String(),
        'lastFeedingType': lastFeedingType,
        'nextFeedingTime': nextFeedingTime?.toIso8601String(),
        'isSleeping': isSleeping,
        'sleepStartTime': sleepStartTime?.toIso8601String(),
        'todayFeedingCount': todayFeedingCount,
        'todaySleepMinutes': todaySleepMinutes,
        'todayDiaperCount': todayDiaperCount,
        'todayPumpMl': todayPumpMl,
        'isPremium': isPremium,
      };
}
