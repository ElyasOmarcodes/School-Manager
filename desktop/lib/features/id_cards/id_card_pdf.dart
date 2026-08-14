import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/l10n/strings.dart';
import '../../core/utils/numerals.dart';
import 'id_card.dart';

/// د آی‌ډي کارتونو چاپي پاڼه.
///
/// کارتونه د CR80 (۸۵.۶ × ۵۴mm) په ریښتیني اندازه چاپېږي، نو چې
/// وروسته پرې شي، معیاري کارت‌ساتونکي ورسره برابر وي. په یوه A4
/// پاڼه کې **۱۰ کارتونه** ځایېږي (۲ ستنې × ۵ کرښې).
///
/// **ولې د پردې د عکس اخیستل نه؟** ځکه چې د پردې رینډر د پکسلونو
/// دی — چاپ يې خځلن کوي. دلته PDF ویکټور دی، نو QR په هره کچه
/// روښانه چاپېږي او سکینر يې اسانه لولي.
class IdCardPdf {
  const IdCardPdf._();

  static const double cardW = 85.6 * PdfPageFormat.mm;
  static const double cardH = 54.0 * PdfPageFormat.mm;
  static const int perRow = 2;
  static const int rowsPerPage = 5;
  static const int perPage = perRow * rowsPerPage;

  /// د پښتو فونټ باید په PDF کې ځای پر ځای شي — که نه، عربي توري
  /// نه ښکاري. له همدې assets څخه راځي چې پروګرام يې کاروي.
  static Future<pw.Font> _font(String weight) async {
    final data = await rootBundle.load('assets/fonts/Vazirmatn-$weight.ttf');
    return pw.Font.ttf(data);
  }

  static Future<Uint8List> build({
    required List<CardData> cards,
    required AppLocale locale,
  }) async {
    final regular = await _font('Regular');
    final bold = await _font('Bold');

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    for (var start = 0; start < cards.length; start += perPage) {
      final slice = cards.skip(start).take(perPage).toList();

      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(8 * PdfPageFormat.mm),
          textDirection: pw.TextDirection.rtl,
          build: (context) => pw.Wrap(
            spacing: 4 * PdfPageFormat.mm,
            runSpacing: 4 * PdfPageFormat.mm,
            children: [for (final c in slice) _card(c, locale)],
          ),
        ),
      );
    }

    return doc.save();
  }

  static pw.Widget _card(CardData c, AppLocale locale) {
    return pw.Container(
      width: cardW,
      height: cardH,
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400, width: 0.4),
        borderRadius: pw.BorderRadius.circular(3 * PdfPageFormat.mm),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: [
          // سرلیک
          pw.Container(
            height: 10 * PdfPageFormat.mm,
            padding: const pw.EdgeInsets.symmetric(
              horizontal: 3 * PdfPageFormat.mm,
            ),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF5B4BE8),
              borderRadius: pw.BorderRadius.only(
                topLeft: pw.Radius.circular(3 * PdfPageFormat.mm),
                topRight: pw.Radius.circular(3 * PdfPageFormat.mm),
              ),
            ),
            child: pw.Row(
              children: [
                pw.Expanded(
                  child: pw.Text(
                    c.schoolName,
                    maxLines: 1,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.Text(
                  locale.num(c.yearLabel),
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: PdfColors.white,
                  ),
                ),
              ],
            ),
          ),

          // بدنه
          pw.Expanded(
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(3 * PdfPageFormat.mm),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // د عکس ځای
                  pw.Container(
                    width: 16 * PdfPageFormat.mm,
                    height: 20 * PdfPageFormat.mm,
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey200,
                      border: pw.Border.all(
                        color: PdfColors.grey400,
                        width: 0.3,
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 3 * PdfPageFormat.mm),

                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          c.studentName,
                          maxLines: 1,
                          style: const pw.TextStyle(
                            fontSize: 10,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.Text(
                          'ولد ${c.fatherName}',
                          maxLines: 1,
                          style: const pw.TextStyle(
                            fontSize: 7.5,
                            color: PdfColors.grey700,
                          ),
                        ),
                        pw.SizedBox(height: 2 * PdfPageFormat.mm),
                        _kv('ټولګی', c.className),
                        _kv('آی‌ډي', locale.num(c.admissionNo)),
                      ],
                    ),
                  ),

                  // QR — ویکټور، نو په هره کچه روښانه چاپېږي.
                  if (c.qrPayload.isNotEmpty)
                    pw.BarcodeWidget(
                      barcode: pw.Barcode.qrCode(
                        errorCorrectLevel: pw.BarcodeQRCorrectionLevel.medium,
                      ),
                      data: c.qrPayload,
                      width: 17 * PdfPageFormat.mm,
                      height: 17 * PdfPageFormat.mm,
                      drawText: false,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _kv(String k, String v) => pw.Padding(
    padding: const pw.EdgeInsets.only(top: 1),
    child: pw.Row(
      children: [
        pw.SizedBox(
          width: 11 * PdfPageFormat.mm,
          child: pw.Text(
            k,
            style: const pw.TextStyle(fontSize: 6.5, color: PdfColors.grey600),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            v,
            maxLines: 1,
            style: const pw.TextStyle(
              fontSize: 7.5,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}
