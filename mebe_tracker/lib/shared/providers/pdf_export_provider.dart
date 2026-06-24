import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/pdf_export_service.dart';
import 'baby_provider.dart';
import 'growth_provider.dart';
import 'home_provider.dart';
import 'vaccine_provider.dart';

final pdfExportServiceProvider = Provider<PdfExportService>((ref) => PdfExportService());

final monthlyReportProvider = FutureProvider<MonthlyReportData?>((ref) async {
  final baby = ref.watch(activeBabyProvider);
  if (baby == null) return null;

  final now = DateTime.now();
  final monthStart = DateTime(now.year, now.month, 1);
  bool inMonth(DateTime date) => date.isAfter(monthStart) || date.isAtSameMomentAs(monthStart);

  final feedings = (ref.watch(allFeedingsProvider).value ?? const [])
      .where((f) => inMonth(f.startTime))
      .toList();
  final sleeps = (ref.watch(allSleepsProvider).value ?? const [])
      .where((s) => inMonth(s.startTime))
      .toList();
  final latestGrowth = ref.watch(latestGrowthProvider);
  final vaccineItems = ref.watch(vaccineViewListProvider);

  return MonthlyReportData(
    babyName: baby.name,
    month: now,
    feedings: feedings,
    sleeps: sleeps,
    latestGrowth: latestGrowth,
    vaccineItems: vaccineItems,
  );
});
