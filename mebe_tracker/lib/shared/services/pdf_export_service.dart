import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../models/feeding_entry.dart';
import '../models/growth_entry.dart';
import '../models/sleep_entry.dart';
import '../providers/vaccine_provider.dart';

class MonthlyReportData {
  const MonthlyReportData({
    required this.babyName,
    required this.month,
    required this.feedings,
    required this.sleeps,
    required this.latestGrowth,
    required this.vaccineItems,
  });

  final String babyName;
  final DateTime month;
  final List<FeedingEntry> feedings;
  final List<SleepEntry> sleeps;
  final GrowthEntry? latestGrowth;
  final List<VaccineViewItem> vaccineItems;
}

class PdfExportService {
  Future<File> generateMonthlyReport(MonthlyReportData data) async {
    // Default PDF fonts (Helvetica) don't cover Vietnamese diacritics —
    // load a Unicode font so the whole document renders correctly.
    final baseFont = await PdfGoogleFonts.notoSansRegular();
    final boldFont = await PdfGoogleFonts.notoSansBold();
    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: baseFont, bold: boldFont),
    );
    final totalFeedMl = data.feedings.fold<double>(0, (sum, f) => sum + (f.amountMl ?? 0));
    final totalSleepMin = data.sleeps.fold<int>(0, (sum, s) => sum + (s.durationMinutes ?? 0));
    final completedVaccines = data.vaccineItems.where((v) => v.isCompleted).length;

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Báo cáo tháng ${data.month.month}/${data.month.year} — ${data.babyName}',
              style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 16),
            pw.Text('Bú/ăn', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Số cữ: ${data.feedings.length} · Tổng lượng: ${totalFeedMl.toStringAsFixed(0)} ml'),
            pw.SizedBox(height: 12),
            pw.Text('Giấc ngủ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Số giấc: ${data.sleeps.length} · Tổng thời gian: ${(totalSleepMin / 60).toStringAsFixed(1)} giờ'),
            pw.SizedBox(height: 12),
            pw.Text('Phát triển', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text(
              data.latestGrowth == null
                  ? 'Chưa có dữ liệu đo'
                  : 'Cân nặng: ${data.latestGrowth!.weightKg ?? '-'} kg · Chiều cao: ${data.latestGrowth!.heightCm ?? '-'} cm',
            ),
            pw.SizedBox(height: 12),
            pw.Text('Tiêm chủng', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.Text('Đã tiêm: $completedVaccines/${data.vaccineItems.length} mũi'),
          ],
        ),
      ),
    );

    final bytes = await doc.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/mebe_report_${data.month.year}_${data.month.month}.pdf');
    await file.writeAsBytes(bytes);
    return file;
  }

  Future<void> share(File file) async {
    await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo MeBé Tracker');
  }
}
