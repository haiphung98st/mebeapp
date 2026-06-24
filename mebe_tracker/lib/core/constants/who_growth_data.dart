/// Hardcoded WHO Child Growth Standards (girls), 0-24 months, at P3/P50/P97.
/// Values are approximations of the official WHO tables, sampled monthly,
/// used to plot a reference curve and estimate a rough percentile.
enum GrowthMetric { weight, height, headCircumference }

String growthMetricLabel(GrowthMetric metric) {
  switch (metric) {
    case GrowthMetric.weight:
      return 'Cân nặng';
    case GrowthMetric.height:
      return 'Chiều cao';
    case GrowthMetric.headCircumference:
      return 'Vòng đầu';
  }
}

String growthMetricUnit(GrowthMetric metric) {
  return metric == GrowthMetric.weight ? 'kg' : 'cm';
}

String growthMetricIcon(GrowthMetric metric) {
  switch (metric) {
    case GrowthMetric.weight:
      return '⚖️';
    case GrowthMetric.height:
      return '📏';
    case GrowthMetric.headCircumference:
      return '🔵';
  }
}

const _weightP3 = [
  2.4, 3.2, 3.9, 4.5, 5.0, 5.4, 5.7, 6.0, 6.3, 6.5, 6.7, 6.9, 7.0,
  7.2, 7.3, 7.5, 7.6, 7.8, 7.9, 8.1, 8.2, 8.4, 8.5, 8.7, 8.8,
];
const _weightP50 = [
  3.2, 4.2, 5.1, 5.8, 6.4, 6.9, 7.3, 7.6, 7.9, 8.2, 8.5, 8.7, 8.9,
  9.2, 9.4, 9.6, 9.8, 10.0, 10.2, 10.4, 10.6, 10.9, 11.1, 11.3, 11.5,
];
const _weightP97 = [
  4.2, 5.5, 6.6, 7.5, 8.2, 8.8, 9.3, 9.8, 10.2, 10.5, 10.9, 11.2, 11.5,
  11.8, 12.1, 12.4, 12.6, 12.9, 13.2, 13.5, 13.7, 14.0, 14.3, 14.6, 14.8,
];

const _heightP3 = [
  45.4, 49.2, 52.0, 54.2, 55.7, 57.1, 58.4, 59.6, 60.7, 61.7, 62.7, 63.7, 64.5,
  65.3, 66.1, 66.9, 67.6, 68.3, 69.0, 69.7, 70.4, 71.0, 71.6, 72.2, 72.8,
];
const _heightP50 = [
  49.1, 53.7, 57.1, 59.8, 62.1, 64.0, 65.7, 67.3, 68.7, 70.1, 71.5, 72.8, 74.0,
  75.2, 76.4, 77.5, 78.6, 79.7, 80.7, 81.7, 82.7, 83.7, 84.6, 85.5, 86.4,
];
const _heightP97 = [
  52.9, 57.9, 61.7, 64.6, 66.9, 69.0, 70.9, 72.6, 74.2, 75.8, 77.3, 78.7, 80.1,
  81.4, 82.7, 83.9, 85.1, 86.3, 87.4, 88.5, 89.6, 90.7, 91.7, 92.7, 93.7,
];

const _headP3 = [
  32.0, 34.2, 35.8, 37.1, 38.1, 38.9, 39.6, 40.2, 40.7, 41.2, 41.5, 41.9, 42.2,
  42.4, 42.7, 42.9, 43.1, 43.3, 43.5, 43.6, 43.8, 44.0, 44.1, 44.2, 44.4,
];
const _headP50 = [
  33.9, 36.5, 38.3, 39.5, 40.6, 41.5, 42.2, 42.8, 43.4, 43.8, 44.2, 44.6, 44.9,
  45.2, 45.4, 45.7, 45.9, 46.1, 46.2, 46.4, 46.6, 46.7, 46.9, 47.0, 47.2,
];
const _headP97 = [
  35.8, 38.9, 40.8, 42.0, 43.1, 44.0, 44.8, 45.4, 46.0, 46.5, 46.9, 47.3, 47.6,
  47.9, 48.2, 48.5, 48.7, 48.9, 49.1, 49.3, 49.4, 49.6, 49.8, 49.9, 50.1,
];

List<double> _tableFor(GrowthMetric metric, int percentile) {
  switch (metric) {
    case GrowthMetric.weight:
      return percentile == 3 ? _weightP3 : (percentile == 50 ? _weightP50 : _weightP97);
    case GrowthMetric.height:
      return percentile == 3 ? _heightP3 : (percentile == 50 ? _heightP50 : _heightP97);
    case GrowthMetric.headCircumference:
      return percentile == 3 ? _headP3 : (percentile == 50 ? _headP50 : _headP97);
  }
}

double _interpolate(List<double> table, double ageMonths) {
  final clamped = ageMonths.clamp(0, 24).toDouble();
  final lowIndex = clamped.floor();
  final highIndex = clamped.ceil();
  if (lowIndex == highIndex) return table[lowIndex];
  final fraction = clamped - lowIndex;
  return table[lowIndex] + (table[highIndex] - table[lowIndex]) * fraction;
}

class WhoGrowthStandard {
  WhoGrowthStandard._();

  static double p3(GrowthMetric metric, double ageMonths) =>
      _interpolate(_tableFor(metric, 3), ageMonths);

  static double p50(GrowthMetric metric, double ageMonths) =>
      _interpolate(_tableFor(metric, 50), ageMonths);

  static double p97(GrowthMetric metric, double ageMonths) =>
      _interpolate(_tableFor(metric, 97), ageMonths);

  /// Rough percentile estimate via piecewise-linear interpolation between
  /// the P3/P50/P97 reference points, extrapolated outside that range.
  static int percentileFor(GrowthMetric metric, double ageMonths, double value) {
    final p3Value = p3(metric, ageMonths);
    final p50Value = p50(metric, ageMonths);
    final p97Value = p97(metric, ageMonths);

    double percentile;
    if (value <= p3Value) {
      final slope = (p3Value == 0) ? 0 : (3 / p3Value);
      percentile = value <= 0 ? 1 : (value * slope);
    } else if (value <= p50Value) {
      percentile = 3 + (value - p3Value) / (p50Value - p3Value) * (50 - 3);
    } else if (value <= p97Value) {
      percentile = 50 + (value - p50Value) / (p97Value - p50Value) * (97 - 50);
    } else {
      final slope = (97 - 50) / (p97Value - p50Value);
      percentile = 97 + (value - p97Value) * slope;
    }
    return percentile.clamp(1, 99).round();
  }
}
