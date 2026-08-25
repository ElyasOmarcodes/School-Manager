import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../core/utils/numerals.dart';
import '../../core/utils/pdf_kit.dart';
import '../../core/l10n/strings.dart';
import '../../data/repositories/timetable_repository.dart';

/// ═══════════════════════════════════════════════════════════
///  **د مهالویش چاپ — پرته له پرېدنې.**
///
///  **د پرېدنې دوه سرچینې وې:**
///
///  ۱. **ستنې له پاڼې بهر.** یو اونیز جدول شپږ ورځې لري، د مدرسې
///     جدول اته ساعتونه — او که پلنوالی په ثابتو پکسلونو ټاکل
///     شوی وای، وروستۍ ستنه به له پاڼې بهر پاتې وه. حل: هره
///     ستنه د پاڼې یوه **برخه** ده (`FractionColumnWidth`)، نو
///     مجموعه تل سمه ۱۰۰٪ ده.
///
///  ۲. **کرښې د پاڼې د پای پر سر.** یوه کرښه چې نیمه پر دې پاڼه
///     او نیمه پر بلې وه. حل: `MultiPage` هره کرښه بشپړه لېږدوي،
///     او د ستنو سرلیک پر هره پاڼه تکرارېږي — نو دویمه پاڼه هم
///     لوستل کېږي.
///
///  **د پاڼې اندازه پخپله ټاکل کېږي:** لږې ستنې → A4 افقي؛ ډېرې
///  → A3 افقي. نو هېڅ وخت دومره تنګ نه شي چې د کتاب نوم پرې شي.
/// ═══════════════════════════════════════════════════════════

/// د اونیز جدول چاپ — یو بخش، ورځې × ساعتونه.
Future<Uint8List> buildWeeklyTimetablePdf({
  required TimetableGrid grid,
  required String schoolName,
  required String sectionLabel,
  required AppLocale locale,
  required String Function(int day) dayName,
}) async {
  final teaching = grid.slots.toList();
  final columns = <String>[
    'ساعت',
    for (final d in grid.days) dayName(d),
  ];

  final rows = <List<String>>[];
  for (final slot in teaching) {
    if (slot.isBreak) {
      rows.add([
        '${locale.num(slot.name)}\n'
            '${locale.num(slot.startTime)}–${locale.num(slot.endTime)}',
        for (final _ in grid.days) '— تفریح —',
      ]);
      continue;
    }
    rows.add([
      '${locale.num(slot.name)}\n'
          '${locale.num(slot.startTime)}–${locale.num(slot.endTime)}',
      for (final d in grid.days) _cellText(grid.at(d, slot.id)),
    ]);
  }

  return _document(
    schoolName: schoolName,
    title: 'اونیز مهالویش — $sectionLabel',
    columns: columns,
    rows: rows,
    firstColumnWeight: 0.85,
  );
}

/// د مدرسې جدول — درجې × ساعتونه.
Future<Uint8List> buildDailyTimetablePdf({
  required DailyGrid grid,
  required String schoolName,
  required AppLocale locale,
}) async {
  final teaching = grid.slots.toList();

  final columns = <String>[
    'درجه',
    for (final slot in teaching)
      slot.isBreak
          ? 'تفریح'
          : '${locale.num(slot.name)}\n'
                '${locale.num(slot.startTime)}–${locale.num(slot.endTime)}',
  ];

  final rows = <List<String>>[
    for (final row in grid.rows)
      [
        row.label,
        for (final slot in teaching)
          slot.isBreak ? '—' : _cellText(grid.at(row.sectionId, slot.id)),
      ],
  ];

  return _document(
    schoolName: schoolName,
    title: 'د مدرسې مهالویش',
    subtitle: 'هره ورځ هماغه ترتیب تدریسېږي.',
    columns: columns,
    rows: rows,
    firstColumnWeight: 1.1,
  );
}

/// د خانې متن — کتاب، بیا استاد، بیا کوټه.
String _cellText(TimetableCell? c) {
  if (c == null) return '';
  final lines = <String>[c.title];
  if (c.teacherName != null) lines.add(c.teacherName!);
  if (c.entry.room != null) lines.add(c.entry.room!);
  return lines.join('\n');
}

Future<Uint8List> _document({
  required String schoolName,
  required String title,
  String? subtitle,
  required List<String> columns,
  required List<List<String>> rows,
  double firstColumnWeight = 1,
}) async {
  // **د پاڼې اندازه له ستنو سره جوړېږي، نه برعکس.**
  final format = columns.length <= 8
      ? PdfPageFormat.a4.landscape
      : PdfPageFormat.a3.landscape;

  // لومړۍ ستنه (ساعت/درجه) لږ پلنه، پاتې ټولې برابرې — یو
  // مهالویش چې یوه ستنه يې دوه چنده وي، ناسم لوستل کېږي.
  final share = <int, pw.TableColumnWidth>{
    0: pw.FractionColumnWidth(
      firstColumnWeight / (firstColumnWeight + columns.length - 1),
    ),
    for (var i = 1; i < columns.length; i++)
      i: pw.FractionColumnWidth(
        1 / (firstColumnWeight + columns.length - 1),
      ),
  };

  final doc = pw.Document(theme: await pdfTheme());

  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(12 * PdfPageFormat.mm),
      textDirection: pw.TextDirection.rtl,
      header: (c) => c.pageNumber == 1
          ? pdfHeader(schoolName: schoolName, title: title, subtitle: subtitle)
          : pw.SizedBox(height: 6),
      footer: (c) => pdfFooter(c, schoolName),
      build: (c) => [
        pw.Table(
          border: pw.TableBorder.all(color: pdfLine, width: 0.45),
          columnWidths: share,
          defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
          children: [
            pw.TableRow(
              repeat: true,
              decoration: const pw.BoxDecoration(color: pdfHeadBg),
              children: [
                for (final h in columns)
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 6,
                    ),
                    child: pw.Text(
                      h,
                      textAlign: pw.TextAlign.center,
                      softWrap: true,
                      style: const pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: pdfInk,
                      ),
                    ),
                  ),
              ],
            ),
            for (var r = 0; r < rows.length; r++)
              pw.TableRow(
                decoration: r.isOdd
                    ? const pw.BoxDecoration(color: pdfZebra)
                    : null,
                children: [
                  for (var i = 0; i < columns.length; i++)
                    pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 6,
                      ),
                      child: pw.Text(
                        i < rows[r].length ? rows[r][i] : '',
                        textAlign: pw.TextAlign.center,
                        // **دا کرښه ده چې پرېدنه بندوي.**
                        softWrap: true,
                        style: pw.TextStyle(
                          fontSize: i == 0 ? 8 : 7.5,
                          fontWeight: i == 0
                              ? pw.FontWeight.bold
                              : pw.FontWeight.normal,
                          color: i == 0 ? pdfInk : pdfInk,
                          lineSpacing: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    ),
  );

  return doc.save();
}

Future<void> printTimetable(Uint8List bytes) =>
    Printing.layoutPdf(onLayout: (_) async => bytes);
