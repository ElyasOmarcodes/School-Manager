import 'package:flutter/widgets.dart';

enum MLocale {
  ps('ps', 'پښتو', TextDirection.rtl),
  fa('fa', 'دری', TextDirection.rtl),
  en('en', 'English', TextDirection.ltr);

  final String code;
  final String label;
  final TextDirection direction;
  const MLocale(this.code, this.label, this.direction);
}

/// ختیځې شمېرې د ښودنې لپاره. ډیټا تل لاتیني پاتې کېږي.
String num_(Object v, MLocale l) {
  if (l == MLocale.en) return v.toString();
  const e = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  final b = StringBuffer();
  for (final r in v.toString().runes) {
    b.write(r >= 0x30 && r <= 0x39 ? e[r - 0x30] : String.fromCharCode(r));
  }
  return b.toString();
}

class T {
  final MLocale locale;
  const T(this.locale);

  static T of(BuildContext c) => LocaleScope.of(c).strings;

  String _p(String ps, String fa, String en) => switch (locale) {
    MLocale.ps => ps,
    MLocale.fa => fa,
    MLocale.en => en,
  };

  String get appName => _p('د ښوونځي مدیریت', 'مدیریت مکتب', 'School Manager');

  // ── تړل ─────────────────────────────────────────────────
  String get connectTitle =>
      _p('ښوونځي ته وصل شئ', 'اتصال به مکتب', 'Connect to your school');
  String get connectSub => _p(
    'هغه پته او کوډ ولیکئ چې ښوونځي درکړی. د ښوونځي Wi-Fi ته وصل اوسئ.',
    'آدرس و کدی را که مکتب داده وارد کنید.',
    'Enter the address and code your school gave you.',
  );
  String get pairCode => _p('د تړلو کوډ', 'کد اتصال', 'Pairing code');
  String get connect => _p('وصل شه', 'اتصال', 'Connect');
  String get scanQr => _p('QR سکین کړه', 'اسکن QR', 'Scan QR');

  // ── رول ─────────────────────────────────────────────────
  String get iAmManager => _p('زه مدیر یم', 'من مدیر هستم', "I'm the manager");
  String get iAmParent => _p('زه والدین یم', 'من والدین هستم', "I'm a parent");

  // ── مدیر ────────────────────────────────────────────────
  String get today => _p('نن', 'امروز', 'Today');
  String get absentToday => _p('نن غیرحاضر', 'غایب امروز', 'Absent today');
  String get presentToday => _p('نن حاضر', 'حاضر امروز', 'Present today');
  String get notifyParents =>
      _p('والدینو ته پیغام واستوه', 'اطلاع به والدین', 'Notify parents');
  String get pendingLeave =>
      _p('د تصویب په تمه اجازې', 'اجازه‌های در انتظار', 'Pending leave');

  // ── والدین ──────────────────────────────────────────────
  String get myChildren => _p('زما ماشومان', 'فرزندان من', 'My children');
  String get attendance => _p('حاضري', 'حاضری', 'Attendance');
  String get results => _p('نمرې', 'نمرات', 'Results');
  String get fees => _p('فیس', 'فیس', 'Fees');
  String get messages => _p('پیغامونه', 'پیام‌ها', 'Messages');
  String get requestLeave =>
      _p('د اجازې غوښتنه', 'درخواست اجازه', 'Request leave');

  // ── عمومي ───────────────────────────────────────────────
  String get home => _p('کور', 'خانه', 'Home');
  String get more => _p('نور', 'بیشتر', 'More');
  String get settings => _p('تنظیمات', 'تنظیمات', 'Settings');
  String get notConnected => _p(
    'لا ښوونځي ته نه یاست وصل.',
    'هنوز به مکتب وصل نیستید.',
    'Not connected to a school yet.',
  );
}

class LocaleScope extends InheritedWidget {
  final MLocale locale;
  final void Function(MLocale) setLocale;

  const LocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  T get strings => T(locale);

  static LocaleScope of(BuildContext c) {
    final s = c.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(s != null, 'LocaleScope د ونې په سر کې نشته');
    return s!;
  }

  @override
  bool updateShouldNotify(LocaleScope old) => old.locale != locale;
}
