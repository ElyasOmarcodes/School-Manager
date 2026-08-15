import 'package:drift/drift.dart';

import 'core_tables.dart';

// ═══════════════════════════════════════════════════════════
//  فیس
// ═══════════════════════════════════════════════════════════

/// د فیس یو ډول — «میاشتنی فیس»، «د داخلې فیس»، «د کتابونو پیسې».
class FeeTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// د یوې دورې اندازه — افغانۍ.
  IntColumn get amount => integer()();

  /// `monthly` | `term` | `annual` | `one_time`
  TextColumn get frequency => text().withDefault(const Constant('monthly'))();

  /// که یوه ټاکلي ټولګي پورې اړه لري. `null` = ټول ټولګي.
  IntColumn get gradeId => integer().nullable().references(Grades, #id)();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// د یوه شاګرد د یوې دورې بل.
///
/// **ولې «دوره» یو متن دی، نه نېټه؟** ځکه چې د میاشتني فیس دوره
/// «۱۴۰۵-۰۵» ده، خو د سمستر دوره «۱۴۰۵-ت۱». که نېټه وای، دوه ډوله
/// دورې به يې یو ځای نه شوې څرګندولی — او د دوه‌ځلي بل مخنیوی به
/// ناشونی و.
class FeeInvoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get feeTypeId => integer().references(FeeTypes, #id)();
  IntColumn get academicYearId => integer().references(AcademicYears, #id)();

  /// «۱۴۰۵-۰۵» یا «1405-t1»
  TextColumn get period => text()();

  IntColumn get amount => integer()();

  /// تخفیف — د یتیم، د استاد د اولاد، یا د ډېرو وروڼو لپاره.
  IntColumn get discount => integer().withDefault(const Constant(0))();
  TextColumn get discountReason => text().nullable()();

  DateTimeColumn get dueDate => dateTime()();

  /// `unpaid` | `partial` | `paid` | `waived`
  TextColumn get status => text().withDefault(const Constant('unpaid'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get createdByUserId => integer().nullable()();

  /// یو شاګرد د یوې دورې لپاره د یوه ډول یو بل لري.
  @override
  List<Set<Column>> get uniqueKeys => [
    {studentId, feeTypeId, period},
  ];
}

/// یوه تادیه — یو بل ښايي څو تادیې ولري.
///
/// **ولې څو؟** ځکه چې کورنۍ ډېر ځله نیمه ورکوي: «اوس ۵۰۰، پاتې
/// راتلونکې اونۍ». که یوازې «ورکړل شوی/نه دی ورکړل شوی» وای، هغه
/// ۵۰۰ به هېڅ ځای نه درلود.
class FeePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId => integer().references(FeeInvoices, #id)();

  IntColumn get amount => integer()();

  /// `cash` | `bank` | `mobile`
  TextColumn get method => text().withDefault(const Constant('cash'))();

  /// د رسید نمبر — کورنۍ يې کاغذ اخلي.
  TextColumn get receiptNo => text()();

  DateTimeColumn get paidOn => dateTime().withDefault(currentDateAndTime)();
  IntColumn get receivedByUserId => integer().nullable()();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {receiptNo},
  ];
}

// ═══════════════════════════════════════════════════════════
//  معاشونه
// ═══════════════════════════════════════════════════════════

/// د یوې میاشتې د معاشونو دوره.
///
/// **ولې «دوره» یو ریکارډ دی؟** ځکه چې معاش یوه پرېکړه ده چې
/// تصویبېږي. که یوازې تادیې وې، هېڅوک به نه پوهېده چې د ثور میاشت
/// بشپړه شوې که نیمه پاتې ده.
class PayrollRuns extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// «۱۴۰۵-۰۵»
  TextColumn get period => text()();

  /// `draft` | `approved` | `paid`
  TextColumn get status => text().withDefault(const Constant('draft'))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get createdByUserId => integer().nullable()();
  DateTimeColumn get approvedAt => dateTime().nullable()();
  IntColumn get approvedByUserId => integer().nullable()();
  TextColumn get note => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {period},
  ];
}

/// د یوه کارکوونکي د یوې میاشتې معاش.
class PayrollItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get runId => integer().references(PayrollRuns, #id)();

  /// `teacher` | `staff` — دوه بېل جدولونه دي، نو ډول پکار دی.
  TextColumn get employeeKind => text()();
  IntColumn get employeeId => integer()();

  /// نوم په دې کرښه کې کاپي کېږي — **په قصد**. که کارکوونکی
  /// وروسته ړنګ شي، د تېرې میاشتې رسید باید نوم ولري.
  TextColumn get employeeName => text()();
  TextColumn get jobTitle => text().nullable()();

  IntColumn get baseSalary => integer()();
  IntColumn get allowances => integer().withDefault(const Constant(0))();
  IntColumn get deductions => integer().withDefault(const Constant(0))();

  /// د غیرحاضرۍ کسر — جلا ساتل کېږي چې کارکوونکی پوه شي ولې.
  IntColumn get absenceDeduction => integer().withDefault(const Constant(0))();
  IntColumn get absentDays => integer().withDefault(const Constant(0))();

  IntColumn get netPay => integer()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get paidAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {runId, employeeKind, employeeId},
  ];
}
