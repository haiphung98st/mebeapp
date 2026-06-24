/// Hardcoded standard infant milestones (Vietnamese), 0-12 months,
/// with expected age window in weeks per WHO motor/language milestones.
class MilestoneDef {
  const MilestoneDef({
    required this.key,
    required this.titleVi,
    required this.expectedWeekMin,
    required this.expectedWeekMax,
  });

  final String key;
  final String titleVi;
  final int expectedWeekMin;
  final int expectedWeekMax;
}

const milestoneDefs = [
  MilestoneDef(key: 'social_smile', titleVi: 'Biết cười xã hội', expectedWeekMin: 4, expectedWeekMax: 8),
  MilestoneDef(key: 'grasps_objects', titleVi: 'Biết cầm nắm đồ vật', expectedWeekMin: 12, expectedWeekMax: 20),
  MilestoneDef(key: 'rolls_over', titleVi: 'Biết lật người', expectedWeekMin: 12, expectedWeekMax: 20),
  MilestoneDef(key: 'sits_without_support', titleVi: 'Biết ngồi vững không cần đỡ', expectedWeekMin: 20, expectedWeekMax: 32),
  MilestoneDef(key: 'babbles', titleVi: 'Biết nói bập bẹ', expectedWeekMin: 24, expectedWeekMax: 36),
  MilestoneDef(key: 'crawls', titleVi: 'Biết bò', expectedWeekMin: 28, expectedWeekMax: 40),
  MilestoneDef(key: 'stands_with_support', titleVi: 'Biết đứng vịn', expectedWeekMin: 32, expectedWeekMax: 44),
  MilestoneDef(key: 'says_mama_baba', titleVi: 'Biết nói "ba", "mẹ"', expectedWeekMin: 32, expectedWeekMax: 48),
  MilestoneDef(key: 'waves_bye', titleVi: 'Biết vẫy tay chào', expectedWeekMin: 36, expectedWeekMax: 52),
  MilestoneDef(key: 'stands_alone', titleVi: 'Biết đứng vững không vịn', expectedWeekMin: 44, expectedWeekMax: 56),
  MilestoneDef(key: 'walks_few_steps', titleVi: 'Biết đi vài bước', expectedWeekMin: 44, expectedWeekMax: 60),
];
