import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// ═══════════════════════════════════════════════════════════
///  **د PDF ګډه بنسټ — چې هر صادرات یو شان او بشپړ وي.**
///
///  **کومې ستونزې دا برخه حل کوي؟**
///
///  ۱. **پرې شوی جدول.** یو جدول چې اته ستنې لري، په A4 کې نه
///     ځایېږي — نو وروستۍ ستنې له پاڼې بهر پاتې کېدې. حل يې دا
///     دی چې ستنې **د پاڼې د پلنوالي په برخو** وویشل شي، نه په
///     ثابتو پکسلونو: بیا مجموعه تل ۱۰۰٪ وي او هېڅ شی بهر نه ځي.
///
///  ۲. **پرې شوی متن.** یو اوږد نوم په یوه نرۍ ستنه کې پخوا
///     پرېدل. اوس هره خانه **راټولېږي** (wrap)، نو کرښه لوړېږي —
///     خو هېڅ توری نه ورکېږي.
///
///  ۳. **د پاڼې د بدلون سرلیک.** د دویمې پاڼې جدول به بې‌سرلیکه
///     پیل کېده او څوک به نه پوهېده چې کومه ستنه څه ده. اوس
///     سرلیک پر هره پاڼه تکرارېږي.
///
///  ۴. **بې‌ثباته ښکارېدنه.** هر صادرات به خپل فونټ او خپل رنګ
///     لرل. اوس یو تیم دی، یو ځل لوستل کېږي او کیش کېږي.
///
///  ۵. **د پاڼې غلطه اندازه.** یو جدول له څو ستنو سره په A4 کې
///     ښه دی؛ له لسو سره نه. [pageFor] د ستنو له شمېره پاڼه
///     ټاکي — عمودي، افقي، یا A3 — نو هېڅ وخت ډېر تنګ نه شي.
/// ═══════════════════════════════════════════════════════════

const PdfColor pdfInk = PdfColor.fromInt(0xFF1B1F2A);
const PdfColor pdfMuted = PdfColor.fromInt(0xFF6B7280);
const PdfColor pdfLine = PdfColor.fromInt(0xFFD9DEE7);
const PdfColor pdfHeadBg = PdfColor.fromInt(0xFFF1F3F8);
const PdfColor pdfZebra = PdfColor.fromInt(0xFFFAFBFD);

pw.ThemeData? _theme;

/// فونټونه یو ځل لوستل کېږي — د هر صادرات لپاره بیا لوستل
/// څو سوه میلي‌ثانیې وخت نیسي او پایله يې یوه ده.
Future<pw.ThemeData> pdfTheme() async {
  if (_theme != null) return _theme!;
  final regular = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Vazirmatn-Regular.ttf'),
  );
  final bold = pw.Font.ttf(
    await rootBundle.load('assets/fonts/Vazirmatn-Bold.ttf'),
  );
  return _theme = pw.ThemeData.withFont(base: regular, bold: bold);
}

/// **د ستنو له شمېره سمه پاڼه.**
///
/// یو جدول چې اته ستنې لري، په عمودي A4 کې هره ستنه ۲۳ ملي‌متره
/// اخلي — یو نوم پکې نه ځایېږي. نو پاڼه له محتوا سره جوړېږي، نه
/// محتوا له پاڼې سره.
PdfPageFormat pageFor(int columns, {bool forceLandscape = false}) {
  if (columns <= 4 && !forceLandscape) return PdfPageFormat.a4;
  if (columns <= 10) return PdfPageFormat.a4.landscape;
  return PdfPageFormat.a3.landscape;
}

/// **د ستنو نسبي پلنوالی — له محتوا څخه.**
///
/// هره ستنه هغومره برخه اخلي څومره چې يې اوږد متن غواړي، خو د
/// یوې ټاکلې کچې تر منځ: یوه ستنه هېڅکله دومره نرۍ نه شي چې دوه
/// توري پکې ونه ځایېږي، او هېڅکله دومره پلنه نه شي چې نورې
/// وځپي.
Map<int, pw.TableColumnWidth> autoWidths({
  required List<String> columns,
  required List<List<String>> rows,
  Map<int, double>? weights,
  int sample = 120,
}) {
  final n = columns.length;
  final widest = List<double>.filled(n, 0);

  for (var c = 0; c < n; c++) {
    widest[c] = columns[c].length.toDouble();
  }
  for (var r = 0; r < rows.length && r < sample; r++) {
    final row = rows[r];
    for (var c = 0; c < n && c < row.length; c++) {
      // اوږد متن راټولېږي، نو ټوله اوږدوالی نه شمېرو — یوازې
      // تر یوې کچې، چې یوه اوږده یادونه ټول جدول ونه ځپي.
      final len = row[c].length.clamp(0, 34).toDouble();
      if (len > widest[c]) widest[c] = len;
    }
  }

  for (var c = 0; c < n; c++) {
    widest[c] = widest[c].clamp(4, 34);
    final w = weights?[c];
    if (w != null) widest[c] *= w;
  }

  final total = widest.fold<double>(0, (a, b) => a + b);
  return {
    for (var c = 0; c < n; c++)
      c: pw.FractionColumnWidth(widest[c] / total),
  };
}

/// **یو جدول چې تل بشپړ چاپېږي.**
///
/// سرلیک پر هره پاڼه تکرارېږي (`repeat: 1`)، هره خانه راټولېږي،
/// او پلنوالی د پاڼې برخې دي — نو نه پرېږي او نه بهر ځي.
pw.Widget pdfTable({
  required List<String> columns,
  required List<List<String>> rows,
  List<String>? totals,
  Map<int, double>? weights,
  double fontSize = 8.5,
  List<int> numericColumns = const [],
}) {
  final widths = autoWidths(
    columns: columns,
    rows: rows,
    weights: weights,
  );

  pw.Widget cell(
    String text, {
    required bool head,
    required int index,
    bool strong = false,
  }) {
    final numeric = numericColumns.contains(index);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4.5),
      child: pw.Text(
        text,
        textAlign: numeric ? pw.TextAlign.center : pw.TextAlign.right,
        // **`softWrap` هغه څه دي چې پرېدنه بندوي.**
        softWrap: true,
        style: pw.TextStyle(
          fontSize: head ? fontSize + 0.5 : fontSize,
          fontWeight: (head || strong)
              ? pw.FontWeight.bold
              : pw.FontWeight.normal,
          color: head ? pdfInk : (strong ? pdfInk : pdfInk),
        ),
      ),
    );
  }

  return pw.Table(
    border: pw.TableBorder.symmetric(
      inside: const pw.BorderSide(color: pdfLine, width: 0.4),
      outside: const pw.BorderSide(color: pdfLine, width: 0.6),
    ),
    columnWidths: widths,
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: pdfHeadBg),
        children: [
          for (var i = 0; i < columns.length; i++)
            cell(columns[i], head: true, index: i),
        ],
      ),
      for (var r = 0; r < rows.length; r++)
        pw.TableRow(
          decoration: r.isOdd
              ? const pw.BoxDecoration(color: pdfZebra)
              : null,
          children: [
            for (var i = 0; i < columns.length; i++)
              cell(
                i < rows[r].length ? rows[r][i] : '',
                head: false,
                index: i,
              ),
          ],
        ),
      if (totals != null)
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: pdfHeadBg),
          children: [
            for (var i = 0; i < columns.length; i++)
              cell(
                i < totals.length ? totals[i] : '',
                head: false,
                index: i,
                strong: true,
              ),
          ],
        ),
    ],
  );
}

/// د هرې پاڼې سرلیک — نوم، موضوع او نېټه.
pw.Widget pdfHeader({
  required String schoolName,
  required String title,
  String? subtitle,
}) => pw.Column(
  crossAxisAlignment: pw.CrossAxisAlignment.stretch,
  children: [
    pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: const pw.TextStyle(
                  fontSize: 15,
                  fontWeight: pw.FontWeight.bold,
                  color: pdfInk,
                ),
              ),
              if (subtitle != null) ...[
                pw.SizedBox(height: 3),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(fontSize: 9, color: pdfMuted),
                ),
              ],
            ],
          ),
        ),
        pw.Text(
          schoolName,
          style: const pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: pdfMuted,
          ),
        ),
      ],
    ),
    pw.SizedBox(height: 8),
    pw.Container(height: 0.8, color: pdfLine),
    pw.SizedBox(height: 10),
  ],
);

pw.Widget pdfFooter(pw.Context context, String schoolName) => pw.Padding(
  padding: const pw.EdgeInsets.only(top: 8),
  child: pw.Row(
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: [
      pw.Text(
        schoolName,
        style: const pw.TextStyle(fontSize: 8, color: pdfMuted),
      ),
      pw.Text(
        'مخ ${context.pageNumber} له ${context.pagesCount}',
        style: const pw.TextStyle(fontSize: 8, color: pdfMuted),
      ),
    ],
  ),
);

/// **یو بشپړ سند — سرلیک، محتوا، پښه.**
///
/// حاشیه له ملي‌متره راځي، نه له پکسله: یو چاپګر چې ۱۰ ملي‌متره
/// نه‌چاپېدونکې څنډه لري، په ۱۴ ملي‌متره حاشیه کې هېڅ نه پرېږي.
Future<Uint8List> buildPdfDocument({
  required String schoolName,
  required String title,
  String? subtitle,
  required PdfPageFormat format,
  required List<pw.Widget> Function(pw.Context) body,
}) async {
  final doc = pw.Document(theme: await pdfTheme());
  doc.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(14 * PdfPageFormat.mm),
      textDirection: pw.TextDirection.rtl,
      header: (c) => c.pageNumber == 1
          ? pdfHeader(
              schoolName: schoolName,
              title: title,
              subtitle: subtitle,
            )
          : pw.SizedBox(height: 6),
      footer: (c) => pdfFooter(c, schoolName),
      build: body,
    ),
  );
  return doc.save();
}
