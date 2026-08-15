/// د CSV فایل جوړول.
///
/// **ولې یو پیکج نه؟** ځکه چې دا دېرش کرښې دي، او هغه دوه شیان چې
/// دلته مهم دي هېڅ عام پیکج نه کوي:
///
///   ۱. **BOM.** پرته له هغه، Excel په ویندوز کې پښتو متن د خځلو په
///      بڼه ښیي — «Ø¯ Ù†Ù�Ø±». مدیر به فکر کاوه چې فایل خراب دی.
///   ۲. **CRLF.** د ویندوز Excel د یوازې `\n` کرښې سره ځینې وختونه
///      ټول متن په یوه خانه کې اچوي.
class Csv {
  const Csv._();

  /// د UTF-8 د بایټ ترتیب نښه — Excel پرې پوهېږي چې فایل یونیکوډ دی.
  static const String bom = '﻿';

  static String build({
    required List<String> columns,
    required List<List<String>> rows,
    List<String> totals = const [],
  }) {
    final b = StringBuffer(bom);
    b.write(_line(columns));
    for (final r in rows) {
      b.write(_line(r));
    }
    if (totals.isNotEmpty) b.write(_line(totals));
    return b.toString();
  }

  static String _line(List<String> cells) =>
      '${cells.map(_cell).join(',')}\r\n';

  /// یوه خانه — که کامه، نرۍ کوتې یا کرښه ولري، په کوتو کې ځي.
  static String _cell(String v) {
    final needsQuotes =
        v.contains(',') ||
        v.contains('"') ||
        v.contains('\n') ||
        v.contains('\r');
    if (!needsQuotes) return v;
    return '"${v.replaceAll('"', '""')}"';
  }
}
