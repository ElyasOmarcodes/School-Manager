import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../data/db/database.dart';
import '../../data/repositories/exam_repository.dart';

/// د شاګرد کارنامه — چاپي بڼه.
///
/// **ولې هر شاګرد یوه بشپړه پاڼه؟** ځکه چې کارنامه کور ته ځي او د
/// پلار په لاس کې پاتې کېږي. که دوه په یوه پاڼه وای، هغه به يې
/// پرې کولو ته اړ و — او د یوه بل کور د ماشوم نمرې به يې لیدلې.
Future<void> printReportCards({
  required List<StudentResult> results,
  required Exam exam,
  required String schoolName,
  required String className,
}) async {
  final bytes = await buildReportCards(
    results: results,
    exam: exam,
    schoolName: schoolName,
    className: className,
  );
  await Printing.layoutPdf(onLayout: (_) async => bytes);
}

Future<Uint8List> buildReportCards({
  required List<StudentResult> results,
  required Exam exam,
  required String schoolName,
  required String className,
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

  for (final r in results) {
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(16 * PdfPageFormat.mm),
        textDirection: pw.TextDirection.rtl,
        build: (context) => _card(
          r,
          exam: exam,
          schoolName: schoolName,
          className: className,
        ),
      ),
    );
  }

  return doc.save();
}

const PdfColor _ink = PdfColor.fromInt(0xFF141726);
const PdfColor _muted = PdfColor.fromInt(0xFF6B7189);
const PdfColor _line = PdfColor.fromInt(0xFFD8DCE8);
const PdfColor _brand = PdfColor.fromInt(0xFF5B4BE8);
const PdfColor _ok = PdfColor.fromInt(0xFF10B981);
const PdfColor _bad = PdfColor.fromInt(0xFFF43F5E);

pw.Widget _card(
  StudentResult r, {
  required Exam exam,
  required String schoolName,
  required String className,
}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      // ── سرلیک ──────────────────────────────────────────
      pw.Container(
        padding: const pw.EdgeInsets.only(bottom: 12),
        decoration: const pw.BoxDecoration(
          border: pw.Border(bottom: pw.BorderSide(color: _brand, width: 2)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              schoolName,
              style: const pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
                color: _ink,
              ),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'د زده‌کړې کارنامه',
              style: const pw.TextStyle(fontSize: 12, color: _muted),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              exam.name,
              style: const pw.TextStyle(
                fontSize: 13,
                fontWeight: pw.FontWeight.bold,
                color: _brand,
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 16),

      // ── د شاګرد پېژندنه ────────────────────────────────
      pw.Row(
        children: [
          _field('نوم', [
            r.student.firstName,
            if (r.student.lastName?.isNotEmpty ?? false) r.student.lastName!,
          ].join(' ')),
          _field('د پلار نوم', r.student.fatherName),
          _field('ټولګی', className),
          _field('د داخلې نمبر', r.student.admissionNo),
        ],
      ),
      pw.SizedBox(height: 18),

      // ── د مضمونونو جدول ────────────────────────────────
      pw.Table(
        border: pw.TableBorder.all(color: _line, width: 0.6),
        columnWidths: const {
          0: pw.FlexColumnWidth(3),
          1: pw.FlexColumnWidth(1.2),
          2: pw.FlexColumnWidth(1.2),
          3: pw.FlexColumnWidth(1.2),
          4: pw.FlexColumnWidth(1.4),
        },
        children: [
          pw.TableRow(
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFF1F3F9),
            ),
            children: [
              _th('مضمون'),
              _th('بشپړه'),
              _th('لاسته راغلې'),
              _th('سلنه'),
              _th('پایله'),
            ],
          ),
          for (final s in r.subjects)
            pw.TableRow(
              children: [
                _td(s.subjectName, align: pw.TextAlign.right),
                _td('${s.fullMark}'),
                _td(
                  s.isAbsent ? 'غیرحاضر' : _fmt(s.obtained ?? 0),
                  color: s.isAbsent ? _bad : _ink,
                ),
                _td(s.isAbsent ? '—' : '${s.percent.round()}٪'),
                _td(
                  s.passed ? 'کامیاب' : 'ناکام',
                  color: s.passed ? _ok : _bad,
                  bold: true,
                ),
              ],
            ),
        ],
      ),
      pw.SizedBox(height: 18),

      // ── لنډیز ──────────────────────────────────────────
      pw.Row(
        children: [
          _summary('مجموعه', '${_fmt(r.obtainedTotal)} / ${r.fullTotal}'),
          _summary('سلنه', '${r.percent.round()}٪'),
          _summary('درجه', '${r.band.letter} — ${r.band.label}'),
          _summary('مقام', '${r.rank} له ${r.outOf} څخه'),
        ],
      ),
      pw.SizedBox(height: 14),

      pw.Container(
        width: double.infinity,
        padding: const pw.EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        decoration: pw.BoxDecoration(
          color: (r.passedAll ? _ok : _bad).shade(0.9),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Text(
          r.passedAll
              ? 'پایله: کامیاب'
              : 'پایله: په ${r.failed.length} مضمون کې ناکام — '
                    '${r.failed.map((f) => f.subjectName).join('، ')}',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: r.passedAll ? _ok : _bad,
          ),
        ),
      ),

      pw.Spacer(),

      // ── لاسلیکونه ──────────────────────────────────────
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _signature('د ټولګي مشر'),
          _signature('د ښوونځي مدیر'),
          _signature('د والدینو لاسلیک'),
        ],
      ),
    ],
  );
}

pw.Widget _field(String label, String value) => pw.Expanded(
  child: pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
      pw.SizedBox(height: 2),
      pw.Text(
        value,
        style: const pw.TextStyle(
          fontSize: 11,
          fontWeight: pw.FontWeight.bold,
          color: _ink,
        ),
      ),
    ],
  ),
);

pw.Widget _th(String text) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 8),
  child: pw.Text(
    text,
    textAlign: pw.TextAlign.center,
    style: const pw.TextStyle(
      fontSize: 9.5,
      fontWeight: pw.FontWeight.bold,
      color: _muted,
    ),
  ),
);

pw.Widget _td(
  String text, {
  PdfColor color = _ink,
  bool bold = false,
  pw.TextAlign align = pw.TextAlign.center,
}) => pw.Padding(
  padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 8),
  child: pw.Text(
    text,
    textAlign: align,
    style: pw.TextStyle(
      fontSize: 10,
      color: color,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    ),
  ),
);

pw.Widget _summary(String label, String value) => pw.Expanded(
  child: pw.Container(
    margin: const pw.EdgeInsets.symmetric(horizontal: 3),
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _line, width: 0.6),
      borderRadius: pw.BorderRadius.circular(7),
    ),
    child: pw.Column(
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 8, color: _muted)),
        pw.SizedBox(height: 3),
        pw.Text(
          value,
          style: const pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: _ink,
          ),
        ),
      ],
    ),
  ),
);

pw.Widget _signature(String label) => pw.Column(
  children: [
    pw.Container(width: 120, height: 0.8, color: _line),
    pw.SizedBox(height: 5),
    pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: _muted)),
  ],
);

String _fmt(double v) =>
    v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
