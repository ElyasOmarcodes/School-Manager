import 'package:flutter/widgets.dart';

/// درې ژبې: پښتو (اصلي)، دري، انګلیسي.
///
/// هره کرښه دلته ده — په UI کې هېڅ متن سخت نه دی لیکل شوی،
/// نو ژبه په یوه کلیک بدلېږي او نوې ژبه زیاتول اسان دي.
enum AppLocale {
  ps('ps', 'پښتو', TextDirection.rtl),
  fa('fa', 'دری', TextDirection.rtl),
  en('en', 'English', TextDirection.ltr);

  final String code;
  final String label;
  final TextDirection direction;
  const AppLocale(this.code, this.label, this.direction);

  static AppLocale fromCode(String c) =>
      AppLocale.values.firstWhere((l) => l.code == c, orElse: () => ps);
}

class S {
  final AppLocale locale;
  const S(this.locale);

  static S of(BuildContext context) => LocaleScope.of(context).strings;

  String _pick(String ps, String fa, String en) => switch (locale) {
    AppLocale.ps => ps,
    AppLocale.fa => fa,
    AppLocale.en => en,
  };

  // ── عمومي ───────────────────────────────────────────────
  String get appName =>
      _pick('د ښوونځي مدیریت', 'مدیریت مکتب', 'School Manager');
  String get next => _pick('بل', 'بعدی', 'Next');
  String get back => _pick('شاته', 'قبلی', 'Back');
  String get finish => _pick('پای', 'پایان', 'Finish');
  String get save => _pick('ثبت', 'ذخیره', 'Save');
  String get cancel => _pick('لغوه', 'لغو', 'Cancel');
  String get browse => _pick('وګوره…', 'انتخاب…', 'Browse…');
  String get search => _pick('لټون', 'جستجو', 'Search');
  String get retry => _pick('بیا هڅه', 'تلاش دوباره', 'Retry');
  String get loading => _pick('بارېږي…', 'در حال بارگذاری…', 'Loading…');

  // ── ویزارډ ──────────────────────────────────────────────
  String get welcome => _pick('ښه راغلاست', 'خوش آمدید', 'Welcome');
  String get welcomeSub => _pick(
    'د پیل لپاره څو ګامونه — بیا سیسټم چمتو دی.',
    'چند گام تا آماده شدن سیستم.',
    'A few steps and the system is ready.',
  );
  String get chooseLanguage =>
      _pick('ژبه غوره کړئ', 'زبان را انتخاب کنید', 'Choose language');

  String get stepDatabase =>
      _pick('د ډیټابیس ځای', 'محل دیتابیس', 'Database location');
  String get stepDatabaseSub => _pick(
    'ټول معلومات په یوه فایل کې ساتل کېږي. هغه ډرایو وټاکئ چې تل شتون ولري.',
    'تمام اطلاعات در یک فایل ذخیره می‌شود. درایوی را انتخاب کنید که همیشه موجود باشد.',
    'All data lives in one file. Pick a drive that is always available.',
  );
  String get createNew =>
      _pick('نوی ډیټابیس جوړ کړه', 'دیتابیس جدید بساز', 'Create new database');
  String get openExisting => _pick(
    'موجود ډیټابیس پرانیزه',
    'دیتابیس موجود را باز کن',
    'Open existing',
  );
  String get selectedFolder =>
      _pick('ټاکل شوې پوښۍ', 'پوشه انتخاب شده', 'Selected folder');
  String get freeSpace => _pick('پاتې ځای', 'فضای خالی', 'Free space');

  String get stepSchool =>
      _pick('د ښوونځي پېژندنه', 'مشخصات مکتب', 'School details');
  String get schoolName => _pick('نوم', 'نام', 'Name');
  String get schoolKind => _pick('ډول', 'نوع', 'Type');
  String get kindSchool => _pick('ښوونځی', 'مکتب', 'School');
  String get kindMadrasa => _pick('مدرسه', 'مدرسه', 'Madrasa');
  String get kindBoth => _pick('دواړه', 'هر دو', 'Both');
  String get address => _pick('پته', 'آدرس', 'Address');
  String get phone => _pick('تلیفون', 'تلفن', 'Phone');
  String get calendar => _pick('تقویم', 'تقویم', 'Calendar');
  String get calJalali => _pick('هجري شمسي', 'هجری شمسی', 'Solar Hijri');
  String get calGregorian => _pick('میلادي', 'میلادی', 'Gregorian');
  String get dayStart => _pick('د درس پیل', 'شروع درس', 'Day starts');
  String get dayEnd => _pick('د درس پای', 'ختم درس', 'Day ends');
  String get lateAfter =>
      _pick('له څو دقیقو وروسته ناوخته', 'ناوقت بعد از', 'Late after (min)');

  String get stepAdmin =>
      _pick('د مدیر حساب', 'حساب مدیر', 'Administrator account');
  String get fullName => _pick('بشپړ نوم', 'نام کامل', 'Full name');
  String get username => _pick('کارن نوم', 'نام کاربری', 'Username');
  String get password => _pick('پاسورډ', 'رمز عبور', 'Password');
  String get passwordAgain =>
      _pick('پاسورډ بیا ولیکئ', 'تکرار رمز', 'Repeat password');

  String get setupDone => _pick('چمتو دی', 'آماده است', 'All set');
  String get setupDoneSub => _pick(
    'سیسټم جوړ شو. اوس کولی شئ ننوځئ.',
    'سیستم آماده شد. اکنون وارد شوید.',
    'The system is ready. You can sign in now.',
  );

  // ── ننوتل ───────────────────────────────────────────────
  String get signIn => _pick('ننوتل', 'ورود', 'Sign in');
  String get signOut => _pick('وتل', 'خروج', 'Sign out');
  String get wrongCredentials => _pick(
    'کارن نوم یا پاسورډ سم نه دی.',
    'نام کاربری یا رمز اشتباه است.',
    'Wrong username or password.',
  );
  String get accountLocked => _pick(
    'حساب د ډېرو ناسمو هڅو له امله بند دی. لږ وروسته بیا هڅه وکړئ.',
    'حساب به دلیل تلاش‌های ناموفق قفل شده است.',
    'Account locked after too many attempts. Try again shortly.',
  );

  // ── سایډبار ─────────────────────────────────────────────
  String get dashboard => _pick('ډاشبورډ', 'داشبورد', 'Dashboard');
  String get grpAcademic => _pick('اکاډمیک', 'اکادمیک', 'Academic');
  String get grpAdmin => _pick('اداري', 'اداری', 'Administration');
  String get grpFinance => _pick('مالي', 'مالی', 'Finance');
  String get grpSystem => _pick('سیسټم', 'سیستم', 'System');

  String get students => _pick('شاګردان', 'شاگردان', 'Students');
  String get attendance => _pick('حاضري', 'حاضری', 'Attendance');
  String get leaveRequests => _pick('اجازت نامې', 'اجازه‌نامه‌ها', 'Leave');
  String get exams => _pick('ازموینې', 'امتحانات', 'Exams');
  String get timetable => _pick('مهالویش', 'تقسیم اوقات', 'Timetable');
  String get classes => _pick('ټولګي', 'صنوف', 'Classes');
  String get teachers => _pick('استادان', 'استادان', 'Teachers');
  String get staff => _pick('کارمندان', 'کارمندان', 'Staff');
  String get fees => _pick('فیس', 'فیس', 'Fees');
  String get payroll => _pick('معاشات', 'معاشات', 'Payroll');
  String get reports => _pick('رپوټونه', 'گزارشات', 'Reports');
  String get messages => _pick('پیغامونه', 'پیام‌ها', 'Messages');
  String get idCards => _pick('آی‌ډي کارتونه', 'کارت‌های شناسایی', 'ID cards');
  String get users => _pick('کاروونکي', 'کاربران', 'Users');
  String get settings => _pick('تنظیمات', 'تنظیمات', 'Settings');

  // ── ډاشبورډ ─────────────────────────────────────────────
  String get totalStudents => _pick('ټول شاګردان', 'مجموع شاگردان', 'Students');
  String get presentToday => _pick('نن حاضر', 'حاضر امروز', 'Present today');
  String get absentToday => _pick('نن غیرحاضر', 'غایب امروز', 'Absent today');
  String get feesCollected =>
      _pick('راټول فیس', 'فیس جمع‌آوری شده', 'Fees collected');
  String get weeklyAttendance =>
      _pick('د اونۍ حاضري', 'حاضری هفته', 'Weekly attendance');
  String get needsAttention =>
      _pick('د پاملرنې لیست', 'نیازمند توجه', 'Needs attention');
  String get quickActions => _pick('ژر لاسرسی', 'دسترسی سریع', 'Quick actions');
  String get takeAttendance =>
      _pick('حاضري ونیسه', 'حاضری بگیر', 'Take attendance');
  String get addStudent =>
      _pick('شاګرد زیات کړه', 'افزودن شاگرد', 'Add student');
  String get notifyParents =>
      _pick('والدینو ته خبر ورکړه', 'اطلاع به والدین', 'Notify parents');

  // ── تېروتنې ─────────────────────────────────────────────
  String get pathCannotCreate => _pick(
    'دا پوښۍ جوړه نه شوه. بل ځای وټاکئ.',
    'این پوشه ساخته نشد. جای دیگری انتخاب کنید.',
    'Could not create that folder. Pick another location.',
  );
  String get pathNotWritable => _pick(
    'په دې پوښۍ کې د لیکلو اجازه نشته. بل ځای وټاکئ.',
    'اجازه نوشتن در این پوشه وجود ندارد.',
    'No permission to write here. Pick another location.',
  );
  String get fieldRequired => _pick(
    'دا خانه اړینه ده.',
    'این خانه لازم است.',
    'This field is required.',
  );
  String get passwordTooShort => _pick(
    'پاسورډ باید لږ تر لږه ۸ توري ولري.',
    'رمز باید حداقل ۸ حرف باشد.',
    'Password must be at least 8 characters.',
  );
  String get passwordMismatch => _pick(
    'دواړه پاسورډونه یو شان نه دي.',
    'رمزها یکسان نیستند.',
    'Passwords do not match.',
  );

  // ── فرعي سایډبار او نوې پاڼې ────────────────────────────
  String get subjects => _pick('مضامین', 'مضامین', 'Subjects');
  String get newEnrolment =>
      _pick('نوې نوم لیکنه', 'نام‌نویسی جدید', 'New enrolment');
  String get attendanceTaking =>
      _pick('حاضري اخیستل', 'گرفتن حاضری', 'Take attendance');
  String get newSession => _pick(
    'د نوې حاضري جوړول',
    'ایجاد حاضری جدید',
    'New attendance session',
  );
  String get sessionSettings =>
      _pick('د حاضریانو تنظیمات', 'تنظیمات حاضری‌ها', 'Attendance settings');
  String get newLeave => _pick(
    'د اجازت نامې جوړول',
    'ایجاد اجازه‌نامه',
    'New leave',
  );

  String get examSettings =>
      _pick('د ازموینو تنظیمات', 'تنظیمات امتحانات', 'Exam settings');
  String get questionPapers => _pick(
    'د سوالیه پاڼې جوړول',
    'ایجاد ورقه سوالات',
    'Question papers',
  );
  String get timetableSettings =>
      _pick('د مهالویش تنظیمات', 'تنظیمات تقسیم اوقات', 'Timetable settings');
  String get settingsGeneral => _pick('عمومي', 'عمومی', 'General');
  String get settingsSchool => _pick('ښوونځی', 'مکتب', 'School');
  String get settingsDatabase => _pick('ډیټابیس', 'دیتابیس', 'Database');
  String get settingsNetwork => _pick('اړیکه', 'ارتباط', 'Network');

  // ── ازموینې ───────────────────────────────────────────
  String get marks => _pick('نمرې', 'نمرات', 'Marks');
  String get enterMarks => _pick('د نمرو ثبت', 'ثبت نمرات', 'Enter marks');
  String get results => _pick('پایلې', 'نتایج', 'Results');
  String get topStudents => _pick('ممتاز شاګردان', 'ممتازین', 'Top students');
  String get combinedResults =>
      _pick('راټولې پایلې', 'نتایج مجموعی', 'Combined results');
  String get passed => _pick('کامیاب', 'کامیاب', 'Passed');
  String get failed => _pick('ناکام', 'ناکام', 'Failed');
  String get sortByMarks => _pick('د نمرو له مخې', 'بر اساس نمره', 'By marks');
  String get sortByName => _pick('د نوم له مخې', 'بر اساس نام', 'By name');
  String get export => _pick('اکسپورټ', 'خروجی', 'Export');
  String get print => _pick('چاپ', 'چاپ', 'Print');
  String get weight => _pick('وزن', 'وزن', 'Weight');

  // ── ګډ ────────────────────────────────────────────────
  String get edit => _pick('سمون', 'ویرایش', 'Edit');
  String get delete => _pick('ړنګول', 'حذف', 'Delete');
  String get add => _pick('زیاتول', 'افزودن', 'Add');
  String get close => _pick('بندول', 'بستن', 'Close');
  String get filters => _pick('فلټرونه', 'فیلترها', 'Filters');
  String get clearFilters => _pick('پاک کړه', 'پاک کن', 'Clear');
  String get all => _pick('ټول', 'همه', 'All');
  String get individual => _pick('فردي', 'فردی', 'Individual');
  String get bulk => _pick('ډله ایز', 'گروهی', 'Bulk');
  String get profile => _pick('پروفایل', 'پروفایل', 'Profile');
  String get grade => _pick('درجه/ټولګی', 'درجه/صنف', 'Grade');
  String get section => _pick('بخش', 'بخش', 'Section');
  String get province => _pick('ولایت', 'ولایت', 'Province');
  String get district => _pick('ولسوالۍ', 'ولسوالی', 'District');
  String get village => _pick('کلی / ناحیه', 'قریه / ناحیه', 'Village');
  String get residency => _pick('استوګنه', 'اقامت', 'Residency');
  String get dayScholar => _pick('نهاري', 'نهاری', 'Day scholar');
  String get boarder => _pick('لیلیه', 'لیلیه', 'Boarder');
  String get photo => _pick('انځور', 'عکس', 'Photo');
  String get fromFile => _pick('له فایل څخه', 'از فایل', 'From file');
  String get fromCamera => _pick('له کیمرې څخه', 'از دوربین', 'From camera');
  String get fingerprint => _pick('د ګوتې نښه', 'اثر انگشت', 'Fingerprint');
  String get incompleteProfile =>
      _pick('نیمګړی پروفایل', 'پروفایل ناقص', 'Incomplete profile');
  String get completeProfile =>
      _pick('بشپړ پروفایل', 'پروفایل کامل', 'Complete profile');
  String get book => _pick('کتاب', 'کتاب', 'Book');
  String get difficulty => _pick('سختوالی', 'سختی', 'Difficulty');
  String get diffEasy => _pick('اسان', 'آسان', 'Easy');
  String get diffMedium => _pick('متوسط', 'متوسط', 'Medium');
  String get diffHard => _pick('سخت', 'سخت', 'Hard');
  String get capacity => _pick('ظرفیت', 'ظرفیت', 'Capacity');
  String get viewRows => _pick('کتاري بڼه', 'نمای سطری', 'Rows');
  String get viewGrid => _pick('ګریډ بڼه', 'نمای شبکه‌ای', 'Grid');
  String get present => _pick('حاضر', 'حاضر', 'Present');
  String get absent => _pick('غیرحاضر', 'غایب', 'Absent');
  String get late => _pick('ناوخته', 'تأخیر', 'Late');
  String get onLeave => _pick('رخصت', 'رخصت', 'On leave');
  String get unmarked => _pick('نه‌نښه‌شوی', 'ثبت‌نشده', 'Unmarked');
  String get live => _pick('ژوندی', 'زنده', 'Live');
  String get nothingHere =>
      _pick('دلته لا هېڅ نشته.', 'هنوز چیزی اینجا نیست.', 'Nothing here yet.');

  String errorFor(String key) => switch (key) {
    'pathCannotCreate' => pathCannotCreate,
    'pathNotWritable' => pathNotWritable,
    _ => key,
  };
}

/// ژبه ټول ونې ته رسوي.
class LocaleScope extends InheritedWidget {
  final AppLocale locale;
  final void Function(AppLocale) setLocale;

  const LocaleScope({
    super.key,
    required this.locale,
    required this.setLocale,
    required super.child,
  });

  S get strings => S(locale);

  static LocaleScope of(BuildContext context) {
    final s = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(s != null, 'LocaleScope د ونې په سر کې نشته');
    return s!;
  }

  @override
  bool updateShouldNotify(LocaleScope old) => old.locale != locale;
}
