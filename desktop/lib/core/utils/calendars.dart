import 'package:flutter/widgets.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'numerals.dart';
import '../l10n/strings.dart';

/// ═══════════════════════════════════════════════════════════
///  **نېټه — هجري شمسي، هجري قمري، یا میلادي.**
///
///  **ولې دا برخه پکار وه؟** ځکه چې ویزارډ کې «تقویم» ټاکنه شته
///  وه، خو **هېڅ ځای يې نه کاروله**. کارن به «هجري شمسي» ټاکله او
///  بیا به يې هرځای «2026/5/14» لیده. یو تنظیم چې هېڅ نه کوي، له
///  نشتوالي بدتر دی: هغه ژمنه کوي او بیا يې ماتوي.
///
///  **کوم کتابتونونه؟**
///
///    • **`shamsi_date`** — د هجري شمسي (جلالي) لپاره. دا په
///      Dart کې تر ټولو کارېدونکی او آزمویل شوی دی؛ د `Jalali`
///      ټولګی يې د کبیسه کلونو پېژندنه له رسمي الګوریتم سره سمه
///      کوي (نه یو ساده ۳۳-کلن اټکل).
///    • **`hijri`** — د هجري قمري لپاره. د ام‌القرا تقویم پر
///      بنسټ، چې د اسلامي نړۍ رسمي معیار دی.
///
///  دواړه سوچه Dart دي — نو د وینډوز build ته هېڅ native اضافه
///  نه راوړي، او د بې‌انټرنټه ښوونځي لپاره کار کوي.
/// ═══════════════════════════════════════════════════════════

enum CalendarSystem { jalali, hijri, gregorian }

CalendarSystem calendarOf(String? key) => switch (key) {
  'hijri' => CalendarSystem.hijri,
  'gregorian' => CalendarSystem.gregorian,
  _ => CalendarSystem.jalali,
};

String calendarKey(CalendarSystem c) => switch (c) {
  CalendarSystem.hijri => 'hijri',
  CalendarSystem.gregorian => 'gregorian',
  CalendarSystem.jalali => 'jalali',
};

/// د هجري شمسي میاشتې — افغاني نومونه (نه ایراني).
///
/// **دا توپیر مهم دی:** ایران «فروردین» وايي، افغانستان «حمل».
/// د افغان کارن لپاره «فروردین» هماغسې پردی دی لکه «April».
const List<String> jalaliMonths = [
  'حمل',
  'ثور',
  'جوزا',
  'سرطان',
  'اسد',
  'سنبله',
  'میزان',
  'عقرب',
  'قوس',
  'جدي',
  'دلوه',
  'حوت',
];

const List<String> hijriMonths = [
  'محرم',
  'صفر',
  'ربیع الاول',
  'ربیع الثاني',
  'جمادی الاول',
  'جمادی الثاني',
  'رجب',
  'شعبان',
  'رمضان',
  'شوال',
  'ذوالقعده',
  'ذوالحجه',
];

const List<String> gregorianMonths = [
  'جنوري',
  'فبروري',
  'مارچ',
  'اپریل',
  'می',
  'جون',
  'جولای',
  'اګست',
  'سپتمبر',
  'اکتوبر',
  'نومبر',
  'دسمبر',
];

/// د اونۍ ورځې — له شنبې پیل، لکه افغانستان کې.
const List<String> weekdayNames = [
  'شنبه',
  'یکشنبه',
  'دوشنبه',
  'سه‌شنبه',
  'چهارشنبه',
  'پنجشنبه',
  'جمعه',
];

/// یوه نېټه په درېیو برخو — د هر تقویم لپاره یو شان بڼه.
class DateParts {
  final int year;
  final int month;
  final int day;
  final String monthName;

  const DateParts({
    required this.year,
    required this.month,
    required this.day,
    required this.monthName,
  });
}

/// **د اپ نېټې** — یو ځای، یوه قاعده.
class AppCalendar {
  final CalendarSystem system;
  final AppLocale locale;

  const AppCalendar({required this.system, required this.locale});

  /// یوه میلادي نېټه د ټاکل شوي تقویم برخو ته اړوي.
  DateParts parts(DateTime g) {
    switch (system) {
      case CalendarSystem.jalali:
        final j = Jalali.fromDateTime(g);
        return DateParts(
          year: j.year,
          month: j.month,
          day: j.day,
          monthName: jalaliMonths[j.month - 1],
        );
      case CalendarSystem.hijri:
        final h = HijriCalendar.fromDate(g);
        return DateParts(
          year: h.hYear,
          month: h.hMonth,
          day: h.hDay,
          monthName: hijriMonths[(h.hMonth - 1).clamp(0, 11)],
        );
      case CalendarSystem.gregorian:
        return DateParts(
          year: g.year,
          month: g.month,
          day: g.day,
          monthName: gregorianMonths[g.month - 1],
        );
    }
  }

  /// له برخو بېرته میلادي — د کلیز د پاڼو لپاره.
  DateTime toGregorian(int year, int month, int day) {
    switch (system) {
      case CalendarSystem.jalali:
        return Jalali(year, month, day).toDateTime();
      case CalendarSystem.hijri:
        final h = HijriCalendar()
          ..hYear = year
          ..hMonth = month
          ..hDay = day;
        return h.hijriToGregorian(year, month, day);
      case CalendarSystem.gregorian:
        return DateTime(year, month, day);
    }
  }

  /// په یوه میاشت کې څو ورځې دي.
  int daysInMonth(int year, int month) {
    switch (system) {
      case CalendarSystem.jalali:
        return Jalali(year, month).monthLength;
      case CalendarSystem.hijri:
        return HijriCalendar().getDaysInMonth(year, month);
      case CalendarSystem.gregorian:
        return DateTime(year, month + 1, 0).day;
    }
  }

  // ── بڼې ─────────────────────────────────────────────────

  /// «۱۴ ثور ۱۴۰۵» — د لوستلو لپاره.
  String long(DateTime g) {
    final p = parts(g);
    return '${locale.num(p.day)} ${p.monthName} ${locale.num(p.year)}';
  }

  /// «۱۴۰۵/۰۲/۱۴» — د جدولونو لپاره، برابر پلنوالی.
  String short(DateTime g) {
    final p = parts(g);
    final m = p.month.toString().padLeft(2, '0');
    final d = p.day.toString().padLeft(2, '0');
    return locale.num('${p.year}/$m/$d');
  }

  /// «۱۴ ثور» — کله چې کال معلوم وي.
  String dayMonth(DateTime g) {
    final p = parts(g);
    return '${locale.num(p.day)} ${p.monthName}';
  }

  /// «ثور ۱۴۰۵» — د میاشتني رپوټ سرلیک.
  String monthYear(DateTime g) {
    final p = parts(g);
    return '${p.monthName} ${locale.num(p.year)}';
  }

  /// د اونۍ ورځ — «دوشنبه».
  String weekday(DateTime g) => weekdayNames[(g.weekday + 1) % 7];

  /// «۱۴ ثور، دوشنبه»
  String full(DateTime g) => '${long(g)}، ${weekday(g)}';

  /// د یوې مودې بڼه — «۱ ثور – ۳۱ ثور ۱۴۰۵».
  String range(DateTime from, DateTime to) {
    final a = parts(from);
    final b = parts(to);
    if (a.year == b.year && a.month == b.month && a.day == b.day) {
      return long(from);
    }
    if (a.year == b.year) {
      return '${locale.num(a.day)} ${a.monthName} – '
          '${locale.num(b.day)} ${b.monthName} ${locale.num(b.year)}';
    }
    return '${long(from)} – ${long(to)}';
  }

  /// د تقویم نوم — د تنظیماتو لپاره.
  String get label => switch (system) {
    CalendarSystem.jalali => 'هجري شمسي',
    CalendarSystem.hijri => 'هجري قمري',
    CalendarSystem.gregorian => 'میلادي',
  };
}

/// ═══════════════════════════════════════════════════════════
///  د ونې دننه لاسرسی — لکه `LocaleScope`.
/// ═══════════════════════════════════════════════════════════

class CalendarScope extends InheritedWidget {
  final CalendarSystem system;

  const CalendarScope({
    super.key,
    required this.system,
    required super.child,
  });

  static CalendarSystem of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CalendarScope>()
          ?.system ??
      CalendarSystem.jalali;

  @override
  bool updateShouldNotify(CalendarScope old) => old.system != system;
}

extension CalendarX on BuildContext {
  /// د اوسني تقویم نېټه‌جوړوونکی — `context.cal.long(date)`.
  AppCalendar get cal => AppCalendar(
    system: CalendarScope.of(this),
    locale: S.of(this).locale,
  );
}
