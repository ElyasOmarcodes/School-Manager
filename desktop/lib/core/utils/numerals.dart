import '../l10n/strings.dart';

/// د شمېرو ښودنه د ژبې له مخې.
///
/// پښتو او دري ختیځ-عربي شمېرې کاروي (۰۱۲۳۴۵۶۷۸۹). که په RTL پاڼه
/// کې لاتیني شمېرې ښکاره شي، سترګه ورباندې نښلي — نو د UI ټولې
/// شمېرې له همدې لارې تېرېږي.
///
/// **پام:** دا یوازې د *ښودنې* لپاره ده. په ډیټابیس، د ID نمبرونو،
/// او د QR کوډونو کې تل لاتیني شمېرې پاتې کېږي — که نه، لټون او
/// سکینر به ماتېږي.
class Numerals {
  const Numerals._();

  static const List<String> _eastern = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹', //
  ];

  /// لاتیني شمېرې ختیځو ته اړوي. نور توري نه بدلېږي.
  static String toEastern(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        buffer.write(_eastern[rune - 0x30]);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// ختیځې شمېرې بېرته لاتینو ته — د لټون د خانې لپاره، چې کارن
  /// د آی‌ډي نمبر په هره بڼه ولیکلی شي.
  static String toLatin(String input) {
    final buffer = StringBuffer();
    for (final rune in input.runes) {
      final idx = _eastern.indexOf(String.fromCharCode(rune));
      if (idx >= 0) {
        buffer.write(idx);
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        // عربي-هندي شمېرې (٠..٩) هم منو.
        buffer.write(rune - 0x0660);
      } else {
        buffer.writeCharCode(rune);
      }
    }
    return buffer.toString();
  }

  /// د ژبې له مخې بڼه ورکوي — انګلیسي لاتیني ساتي.
  static String forLocale(Object value, AppLocale locale) {
    final text = value.toString();
    return locale == AppLocale.en ? text : toEastern(text);
  }

  /// د زرګونو جلا کوونکي سره — «۱۲,۴۵۰».
  static String grouped(int value, AppLocale locale) {
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    final text = '${value < 0 ? '-' : ''}$buffer';
    return locale == AppLocale.en ? text : toEastern(text);
  }
}

extension NumeralsX on AppLocale {
  String num(Object value) => Numerals.forLocale(value, this);
  String grouped(int value) => Numerals.grouped(value, this);
}
