import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf'),
  );

  final doc = pw.Document(
    theme: pw.ThemeData.withFont(base: regular, bold: bold),
  );

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4.landscape,
      margin: const pw.EdgeInsets.all(14 * PdfPageFormat.mm),
      textDirection: pw.TextDirection.rtl,
      header: (context) => context.pageNumber == 1
          ? _header(table, schoolName)
          : pw.SizedBox(height: 8),
      footer: (context) => pw.Padding(
        padding: const pw.EdgeInsets.only(top: 8),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              schoolName,
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
            pw.Text(
              'مخ ${context.pageNumber} له ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
      ),
      build: (context) => [
        if (table.highlights.isNotEmpty) ...[
          pw.Row(
            children: [
              for (final h in table.highlights) _highlight(h),
            ],
          ),
          pw.SizedBox(height: 14),
        ],
        if (table.isEmpty)
          pw.Center(
            child: pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 40),
              child: pw.Text(
                'دې رپوټ ته هېڅ معلومات نشته.',
                style: const pw.TextStyle(fontSize: 12, color: _muted),
              ),
            ),
          )
        else
          _table(table),
      ],
    ),
  );

  return doc.save();
}

const PdfColor _ink = PdfColor.fromInt(0xFF141726);
const PdfColor _muted = PdfColor.fromInt(0xFF6B7189);
const PdfColor _line = PdfColor.fromInt(0xFFD8DCE8);
const PdfColor _brand = PdfColor.fromInt(0xFF5B4BE8);
const PdfColor _warn = PdfColor.fromInt(0xFFF43F5E);
const PdfColor _head = PdfColor.fromInt(0xFFF1F3F9);

pw.Widget _header(ReportTable t, String schoolName) => pw.Container(
  margin: const pw.EdgeInsets.only(bottom: 14),
  padding: const pw.EdgeInsets.only(bottom: 10),
  decoration: const pw.BoxDecoration(
    border: pw.Border(bottom: pw.BorderSide(color: _brand, width: 1.6)),
  ),
  child: pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Expanded(
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              schoolName,
              style: const pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              t.title,
              style: const pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: _brand,
              ),
            ),
            pw.Text(
              t.subtitle,
              style: const pw.TextStyle(fontSize: 9.5, color: _muted),
            ),
          ],
        ),
      ),
      pw.Text(
        'د چاپ نېټه: ${_now()}',
        style: const pw.TextStyle(fontSize: 8.5, color: _muted),
      ),
    ],
  ),
);

pw.Widget _highlight(({String label, String value, bool warn}) h) =>
    pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 3),
        padding: const pw.EdgeInsets.symmetric(vertical: 9, horizontal: 10),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: h.warn ? _warn : _line, width: 0.7),
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              h.value,
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
                color: h.warn ? _warn : _ink,
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              h.label,
              style: const pw.TextStyle(fontSize: 8, color: _muted),
            ),
          ],
        ),
      ),
    );

pw.Widget _table(ReportTable t) => pw.Table(
  border: pw.TableBorder.all(color: _line, width: 0.5),
  children: [
    pw.TableRow(
      decoration: const pw.BoxDecoration(color: _head),
      repeat: true,
      children: [for (final c in t.columns) _cell(c, bold: true)],
    ),
    for (final row in t.rows)
      pw.TableRow(children: [for (final c in row) _cell(c)]),
    if (t.totals.isNotEmpty)
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: _head),
        children: [for (final c in t.totals) _cell(c, bold: true)],
      ),
  ],
);

pw.Widget _cell(String text, {bool bold = false}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 6),
  child: pw.Text(
    text,
    style: pw.TextStyle(
      fontSize: 8.5,
      color: bold ? _ink : _muted,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    ),
  ),
);

String _now() {
  final t = DateTime.now();
  return '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}
