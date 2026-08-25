import 'dart:typed_data';

import 'package:printing/printing.dart';

import '../../core/utils/pdf_kit.dart';
import '../../data/repositories/report_repository.dart';

/// یو رپوټ چاپوي.
///
/// **افقي پاڼه ولې؟** ځکه چې د حاضرۍ رپوټ اته ستنې لري. په عمودي
/// A4 کې به ستنې دومره نرۍ وې چې نومونه پرې شي — او یو رپوټ چې
/// نومونه يې نه لوستل کېږي بې‌ګټې دی.
Future<void> printReport({
  required ReportTable table,
  required String schoolName,
}) async {
  final bytes = await buildReportPdf(table: table, schoolName: schoolName);
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}

Future<Uint8List> buildReportPdf({
  required ReportTable table,
  required String schoolName,
}) async {
  // **د ګډ PDF بنسټ له لارې** — نو هر صادرات یو شان ښکاري او هېڅ
  // ستنه له پاڼې بهر نه پاتې کېږي: پلنوالی د پاڼې برخې دي، نه
  // ثابت پکسلونه، او هره خانه راټولېږي.
  return buildPdfDocument(
    schoolName: schoolName,
    title: table.title,
    subtitle: table.subtitle,
    format: pageFor(table.columns.length),
    body: (c) => [
      pdfTable(
        columns: table.columns,
        rows: table.rows,
        totals: table.totals,
        // لومړۍ ستنه معمولاً نوم دی — ورته لږ ډېر ځای.
        weights: const {0: 1.6},
        numericColumns: [
          for (var i = 1; i < table.columns.length; i++) i,
        ],
      ),
    ],
  );
}
