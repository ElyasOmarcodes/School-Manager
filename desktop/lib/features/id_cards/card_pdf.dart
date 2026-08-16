import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/l10n/strings.dart';
import 'card_canvas.dart';
import 'card_layout.dart';

/// **د آی‌ډي کارتونو چاپ — له ډیزاینه.**
///
/// **ولې د پردې د عکس اخیستل نه؟** ځکه چې د پردې رینډر د پکسلونو
/// دی — چاپ يې خځلن کوي. دلته PDF ویکټور دی، نو QR په هره کچه
/// روښانه چاپېږي او سکینر يې اسانه لولي.
///
/// **او ولې د کارت اندازه دلته پورته کېږي؟** ځکه چې د ډیزاینر یوه
/// کوچنۍ اندازه (چې په یوه پاڼه کې زیات کارتونه ځای شي) به یو
/// بې‌ګټې کارت جوړ کړ: په هېڅ کارت‌ساتونکي کې به نه ځایېده او QR
/// به يې د سکینر لپاره ډېر کوچنی و. نو **چاپ تل لږ تر لږه CR80
/// دی** — نسبت ساتل کېږي، نو ډیزاین نه ماتېږي.
class CardPdf {
  const CardPdf._();

  static Future<pw.Font> _font(String weight) async {
    final data = await rootBundle.load('assets/fonts/Vazirmatn-$weight.ttf');
    return pw.Font.ttf(data);
  }

  static Future<Uint8List> build({
    required List<CardValues> cards,
    required CardLayout layout,
    required AppLocale locale,
    double widthMm = cr80WidthMm,
    double heightMm = cr80HeightMm,
  }) async {
    final regular = await _font('Regular');
    final bold = await _font('Bold');

    // **همدلته تضمین پلې کېږي.**
    final size = printSize(widthMm: widthMm, heightMm: heightMm);
    final cardW = size.width * PdfPageFormat.mm;
    final cardH = size.height * PdfPageFormat.mm;

    // په یوه A4 کې څو کارتونه ځایېږي — د اندازې له مخې، نه ټینګ.
    const margin = 8 * PdfPageFormat.mm;
    const gap = 4 * PdfPageFormat.mm;
    final usableW = PdfPageFormat.a4.width - margin * 2;
    final usableH = PdfPageFormat.a4.height - margin * 2;
    final perRow = ((usableW + gap) / (cardW + gap)).floor().clamp(1, 6);
    final rows = ((usableH + gap) / (cardH + gap)).floor().clamp(1, 12);
    final perPage = perRow * rows;

    final doc = pw.Document(
      theme: pw.ThemeData.withFont(base: regular, bold: bold),
    );

    for (var start = 0; start < cards.length; start += perPage) {
      final slice = cards.skip(start).take(perPage).toList();
      doc.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(margin),
          textDirection: pw.TextDirection.rtl,
          build: (context) => pw.Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final c in slice)
                _card(c, layout, locale, cardW, cardH),
            ],
          ),
        ),
      );
    }

    return doc.save();
  }

  static pw.Widget _card(
    CardValues v,
    CardLayout layout,
    AppLocale locale,
    double w,
    double h,
  ) {
    return pw.Container(
      width: w,
      height: h,
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(layout.background),
        borderRadius: pw.BorderRadius.circular(layout.cornerRadius * h),
        // **د پرې کولو کرښه** — پرته له دې، څوک نه پوهېږي چېرې
        // قیچي وکړي، او یو کج پرې شوی کارت بېرته نه جوړېږي.
        border: pw.Border.all(color: PdfColors.grey400, width: 0.4),
      ),
      child: pw.Stack(
        children: [
          if (layout.bandHeight > 0)
            pw.Positioned(
              top: 0,
              right: 0,
              child: pw.Container(
                width: w,
                height: layout.bandHeight * h,
                color: PdfColor.fromInt(layout.bandColor),
              ),
            ),
          for (final f in layout.fields)
            if (f.visible) _field(f, v, locale, w, h),
        ],
      ),
    );
  }

  static pw.Widget _field(
    CardField f,
    CardValues v,
    AppLocale locale,
    double w,
    double h,
  ) {
    final boxW = fieldWidth(f, w);
    final boxH = f.kind.isBox ? fieldHeight(f, h) : null;

    pw.Widget child;
    switch (f.kind) {
      case CardFieldKind.box:
        child = pw.Container(color: PdfColor.fromInt(f.color));

      case CardFieldKind.qr:
        child = v.qrPayload.isEmpty
            ? pw.Container(
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                ),
              )
            : pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: v.qrPayload,
                color: PdfColor.fromInt(f.color),
                drawText: false,
              );

      case CardFieldKind.photo:
      case CardFieldKind.logo:
        final path = f.kind == CardFieldKind.photo
            ? v.photoPath
            : v.logoPath;
        final bytes = _read(path);
        child = bytes == null
            ? pw.Container(color: PdfColors.grey200)
            : pw.Image(
                pw.MemoryImage(bytes),
                fit: f.kind == CardFieldKind.logo
                    ? pw.BoxFit.contain
                    : pw.BoxFit.cover,
              );

      default:
        final text = v.textFor(f.kind, locale, staticText: f.text);
        if (text.isEmpty) return pw.SizedBox.shrink();
        child = pw.Text(
          text,
          maxLines: 1,
          overflow: pw.TextOverflow.clip,
          textAlign: switch (f.align) {
            'center' => pw.TextAlign.center,
            'end' => pw.TextAlign.left,
            _ => pw.TextAlign.right,
          },
          style: pw.TextStyle(
            fontSize: f.fontScale * h,
            fontWeight: f.bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: PdfColor.fromInt(f.color),
          ),
        );
    }

    return pw.Positioned(
      right: f.x * w,
      top: f.y * h,
      child: pw.SizedBox(width: boxW, height: boxH, child: child),
    );
  }

  /// **یو ورک انځور چاپ نه ودروي.**
  ///
  /// د ۳۰۰ شاګردانو په چاپ کې، یو انځور چې له ډیسکه ورک شوی، باید
  /// یوازې خپله خانه تشه پرېږدي — نه دا چې ټول چاپ ناکام شي.
  static Uint8List? _read(String? path) {
    if (path == null || path.isEmpty) return null;
    try {
      final f = File(path);
      return f.existsSync() ? f.readAsBytesSync() : null;
    } on Object {
      return null;
    }
  }
}
