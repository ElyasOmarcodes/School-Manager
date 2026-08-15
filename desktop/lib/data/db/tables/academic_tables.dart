import 'package:drift/drift.dart';

import 'core_tables.dart';

// ═══════════════════════════════════════════════════════════
//  مهالویش
// ═══════════════════════════════════════════════════════════

/// د ورځې یو ساعت — «لومړی ساعت ۷:۳۰–۸:۱۵».
///
/// **ولې جلا جدول، نه یوازې شمېره؟** ځکه چې ښوونځي سره توپیر لري:
/// یو ښوونځی شپږ ساعته لري، بل اته؛ یو د دوهم ساعت وروسته تفریح
/// لري، بل د دریم وروسته. که ساعتونه په کوډ کې ټینګ وای، هر ښوونځی
/// به نوې نسخې ته اړ و.
class TimeSlots extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// «HH:mm»
  TextColumn get startTime => text()();
  TextColumn get endTime => text()();

  /// تفریح دی؟ — د مهالویش په جدول کې بېل رنګ اخلي او مضمون نه مني.
  BoolColumn get isBreak => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// د یوه بخش د یوې ورځې د یوه ساعت درس.
class TimetableEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sectionId => integer().references(Sections, #id)();

  /// ۱ = دوشنبه … ۷ = یکشنبه (د Dart `DateTime.weekday` په څېر).
  ///
  /// **د مدرسې په حالت کې دا تل `0` دی** — «هره ورځ». مدرسه یو
  /// ترتیب لري چې هره ورځ تکرارېږي، نو د ورځې ستنه معنا نه لري.
  /// یوه جلا کرښه د اوونۍ د اوو ورځو لپاره اوه ځله لیکل بې‌ګټې
  /// تکرار و، او د یوه بدلون سره به اوه ځایه سمون ته اړتیا وه.
  IntColumn get dayOfWeek => integer()();
  IntColumn get slotId => integer().references(TimeSlots, #id)();

  IntColumn get subjectId => integer().references(Subjects, #id)();
  IntColumn get teacherId => integer().nullable().references(Teachers, #id)();
  TextColumn get room => text().nullable()();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// یو بخش په یوه ورځ کې په یوه ساعت کې یوازې یو درس لري.
  @override
  List<Set<Column>> get uniqueKeys => [
    {sectionId, dayOfWeek, slotId},
  ];
}

// ═══════════════════════════════════════════════════════════
//  د حاضرۍ ناستې
// ═══════════════════════════════════════════════════════════

/// یوه د حاضرۍ ناسته — «د لیلیه شاګردانو د شپې حاضري».
///
/// **دا ولې پکار ده؟** ځکه چې یو ښوونځی یوه حاضري نه لري. مدرسه
/// سهار د ټولو حاضري اخلي، بیا د شپې ۸:۰۰ بجې یوازې د لیلیه
/// شاګردانو. که یوه حاضري وای، د شپې سکین به د سهار ریکارډ بدل
/// کړ — او د لیلیه شاګرد به دوه ځله شمېرل کېده.
class AttendanceSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// څوک يې هدف دی: `all` | `day` (نهاري) | `boarding` (لیلیه)
  /// | `section` | `grade`
  TextColumn get target => text().withDefault(const Constant('all'))();

  /// که `target` بخش یا ټولګی وي — کوم یو.
  IntColumn get sectionId => integer().nullable().references(Sections, #id)();
  IntColumn get gradeId => integer().nullable().references(Grades, #id)();

  /// د اخیستلو کړکۍ — «HH:mm». له `startTime` مخکې او له `endTime`
  /// وروسته سکینر د دې ناستې لپاره نه کار کوي.
  TextColumn get startTime => text().withDefault(const Constant('07:00'))();
  TextColumn get endTime => text().withDefault(const Constant('08:30'))();

  /// د اونۍ کومې ورځې — «6,7,1,2,3».
  TextColumn get days => text().withDefault(const Constant('6,7,1,2,3'))();

  /// د دې ناستې خپل قواعد — که تش وي، د ښوونځي عام قواعد.
  IntColumn get lateAfterMinutes => integer().nullable()();
  IntColumn get absentAfterMinutes => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// **تلواله ناسته** — هغه چې د ورځې عمومي حاضري ده. یوه ښوونځی
  /// تل لږ تر لږه یوه لري، نو د لومړي ران پر مهال پخپله جوړېږي.
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ═══════════════════════════════════════════════════════════
//  ازموینې او نمرې
// ═══════════════════════════════════════════════════════════

/// یوه ازموینه — «د لومړۍ ربعې ازموینه».
class Exams extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// `monthly` | `midterm` | `final` | `quiz`
  TextColumn get examType => text().withDefault(const Constant('midterm'))();

  IntColumn get academicYearId => integer().references(AcademicYears, #id)();

  /// ربع/سمستر — ۱ یا ۲. د کلني نتیجې لپاره پکار دی.
  IntColumn get term => integer().withDefault(const Constant(1))();

  DateTimeColumn get startsOn => dateTime()();
  DateTimeColumn get endsOn => dateTime()();

  /// **خپرول یوه پرېکړه ده، نه یو حالت.** تر څو چې خپره نه شي،
  /// نمرې یوازې استادان ویني — نه والدین. که نه، یوه نیمګړې لیکل
  /// شوې نمره به د کور خوا ته د اندېښنې لامل شوه.
  BoolColumn get isPublished => boolean().withDefault(const Constant(false))();
  DateTimeColumn get publishedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// د یوې ازموینې یو مضمون، د یوه ټولګي لپاره.
///
/// **ولې د ټولګي په کچه؟** ځکه چې د لسم ټولګي «فزیک» له نهم سره
/// توپیر لري — د نمرې بشپړه او د ازموینې نېټه دواړه بېل دي.
class ExamSubjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examId => integer().references(Exams, #id)();
  IntColumn get gradeId => integer().references(Grades, #id)();
  IntColumn get subjectId => integer().references(Subjects, #id)();

  IntColumn get fullMark => integer().withDefault(const Constant(100))();
  IntColumn get passMark => integer().withDefault(const Constant(40))();
  DateTimeColumn get examDate => dateTime().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {examId, gradeId, subjectId},
  ];
}

/// د یوه شاګرد د یوه مضمون نمره.
class Marks extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get examSubjectId => integer().references(ExamSubjects, #id)();
  IntColumn get studentId => integer().references(Students, #id)();

  /// **ولې `real` نه `int`؟** ځینې ښوونځي نیمې نمرې ورکوي —
  /// «۱۷.۵ له ۲۰ څخه». که پوره عدد وای، استاد به يې ګردول ته اړ و
  /// او د کال په پای کې به توپیر راټول شوی و.
  RealColumn get obtained => real().nullable()();

  /// **دا ولې له صفر نمرې څخه بېل دی؟** ځکه چې «راغلی نه و» او
  /// «راغی خو څه يې ونه لیکل» دوه بېل شیان دي. که دواړه صفر وای،
  /// د اوسط شمېرل به غلط وو.
  BoolColumn get isAbsent => boolean().withDefault(const Constant(false))();

  TextColumn get remarks => text().nullable()();

  IntColumn get enteredByUserId => integer().nullable()();
  DateTimeColumn get enteredAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {examSubjectId, studentId},
  ];
}
