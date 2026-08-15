import 'package:drift/drift.dart';

// ═══════════════════════════════════════════════════════════
//  د ښوونځي پېژندنه — تل یوه کرښه
// ═══════════════════════════════════════════════════════════

class Schools extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get nameEn => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get logoPath => text().nullable()();

  /// `school` | `madrasa` | `both` — د حفظ ماډل پرې فعالېږي.
  TextColumn get kind => text().withDefault(const Constant('school'))();

  /// د درس د پیل او پای وخت — «HH:mm».
  TextColumn get dayStart => text().withDefault(const Constant('07:30'))();
  TextColumn get dayEnd => text().withDefault(const Constant('12:30'))();

  /// څو دقیقې وروسته «ناوخته» ګڼل کېږي، او څو وروسته «غیرحاضر».
  IntColumn get lateAfterMinutes => integer().withDefault(const Constant(15))();
  IntColumn get absentAfterMinutes =>
      integer().withDefault(const Constant(45))();

  /// د اونۍ رخصتي ورځې — د شمېرو لیست، «5,6» (جمعه، پنجشنبه).
  TextColumn get weekendDays => text().withDefault(const Constant('4,5'))();

  /// د مهالویش بڼه: `weekly` | `daily`
  ///
  /// **دا ولې دوه دي؟** مکتب هره ورځ بېل مهالویش لري — د شنبې
  /// لومړی ساعت ریاضي، د یکشنبې لومړی ساعت پښتو. مدرسه داسې نه ده:
  /// یو ځل د یوې درجې ترتیب جوړېږي او **هره ورځ هماغه** تدریسېږي.
  /// نو د مدرسې جدول «درجې × ساعتونه» دی، نه «ورځې × ساعتونه».
  TextColumn get timetableMode =>
      text().withDefault(const Constant('weekly'))();

  /// د نوي بخش تلواله ظرفیت. مدرسې لوی ټولګي لري.
  IntColumn get defaultCapacity => integer().withDefault(const Constant(40))();

  /// د ټولګیو د ښودلو بڼه: `rows` (هر ټولګی یو کتار) | `grid`
  TextColumn get classesView => text().withDefault(const Constant('rows'))();

  // ── د مهالویش جوړښت ─────────────────────────────────────
  //
  // **دا ولې په ښوونځي کې دي او نه په کوډ کې؟** ځکه چې هر ښوونځی
  // بېل دی: یو شپږ ساعته لري، بل اته؛ یو د څلورم وروسته تفریح لري،
  // بل د دریم. که ټینګ وای، هر ښوونځی به نوې نسخې ته اړ و.
  IntColumn get periodsPerDay => integer().withDefault(const Constant(6))();
  IntColumn get periodMinutes => integer().withDefault(const Constant(45))();

  /// د څو ساعتونو وروسته تفریح راځي.
  IntColumn get breakAfterPeriods =>
      integer().withDefault(const Constant(4))();
  IntColumn get breakMinutes => integer().withDefault(const Constant(15))();

  /// په ورځ کې څو تفریحې. که ۲ وي، دویمه يې د دویم بند په منځ کې ده.
  IntColumn get breaksPerDay => integer().withDefault(const Constant(1))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ═══════════════════════════════════════════════════════════
//  کاروونکي او اجازې
// ═══════════════════════════════════════════════════════════

class AppUsers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get username => text().withLength(min: 3, max: 60)();
  TextColumn get fullName => text()();

  /// PBKDF2-HMAC-SHA256، د مالګې (salt) او تکرارونو سره یو ځای.
  TextColumn get passwordHash => text()();
  TextColumn get passwordSalt => text()();
  IntColumn get passwordIterations =>
      integer().withDefault(const Constant(120000))();

  /// `admin` | `deputy` | `teacher` | `accountant` | `reception`
  TextColumn get role => text()();

  /// د هر ماډل جلا اجازې — JSON، مثلاً {"students":["view","edit"]}.
  /// که تش وي، د رول تر ټاکل شوو اجازو لاندې راځي.
  TextColumn get permissionsJson => text().nullable()();

  IntColumn get teacherId => integer().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();
  IntColumn get failedAttempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get lockedUntil => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {username},
  ];
}

// ═══════════════════════════════════════════════════════════
//  اکاډمیک جوړښت
// ═══════════════════════════════════════════════════════════

class AcademicYears extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// «۱۴۰۵» یا «2026-2027»
  TextColumn get label => text()();
  DateTimeColumn get startsOn => dateTime()();
  DateTimeColumn get endsOn => dateTime()();
  BoolColumn get isCurrent => boolean().withDefault(const Constant(false))();
}

/// د ټولګي کچه — لومړی، دویم … دوولسم.
class Grades extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get level => integer()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

/// بخش — «الف»، «ب». د ټولګي دننه ویش.
class Sections extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gradeId => integer().references(Grades, #id)();
  IntColumn get academicYearId => integer().references(AcademicYears, #id)();
  TextColumn get name => text()();
  IntColumn get capacity => integer().withDefault(const Constant(40))();

  /// د ټولګي مشر استاد.
  IntColumn get headTeacherId => integer().nullable()();
  TextColumn get room => text().nullable()();
}

class Subjects extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get code => text().nullable()();
  IntColumn get gradeId => integer().nullable().references(Grades, #id)();

  /// هغه کتاب چې مضمون پرې لوستل کېږي — «قدوري (صلوة)».
  ///
  /// **دا د مدرسې لپاره اړین دی.** یوه مدرسه «فقه» نه تدریسوي؛
  /// هغه د یوې ټاکلې درجې لپاره یو ټاکلی کتاب تدریسوي. پرته له
  /// دې، د درجه ثانیه او درجه رابعه «فقه» به یو شان ښکارېدل.
  TextColumn get book => text().nullable()();

  /// `easy` | `medium` | `hard` — اختیاري، تلواله منځنی.
  TextColumn get difficulty => text().withDefault(const Constant('medium'))();

  IntColumn get fullMark => integer().withDefault(const Constant(100))();
  IntColumn get passMark => integer().withDefault(const Constant(40))();

  /// دیني مضمون دی؟ — د مدرسې د رپوټونو لپاره.
  BoolColumn get isReligious => boolean().withDefault(const Constant(false))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

// ═══════════════════════════════════════════════════════════
//  خلک
// ═══════════════════════════════════════════════════════════

class Students extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// هغه نمبر چې په آی‌ډي کارت او حاضرۍ کې کارېږي.
  TextColumn get admissionNo => text()();

  TextColumn get firstName => text()();
  TextColumn get lastName => text().nullable()();
  TextColumn get fatherName => text()();
  TextColumn get grandFatherName => text().nullable()();

  /// `male` | `female`
  TextColumn get gender => text()();
  DateTimeColumn get birthDate => dateTime().nullable()();
  TextColumn get birthPlace => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get photoPath => text().nullable()();

  TextColumn get phone => text().nullable()();

  /// **سکونت درې برخې لري.** یو ازاد «آدرس» ساحه د رپوټونو لپاره
  /// بې‌ګټې وه — «کندهار» او «قندهار ښار» به دوه بېل ځایونه ګڼل
  /// کېدل. اوس ولایت او ولسوالۍ له ثابت لیست څخه راځي.
  TextColumn get province => text().nullable()();
  TextColumn get district => text().nullable()();
  TextColumn get village => text().nullable()();

  /// زوړ ازاد آدرس — د زړو ریکارډونو لپاره پاتې دی.
  TextColumn get address => text().nullable()();

  /// `day` (نهاري) | `boarding` (لیلیه)
  TextColumn get residency => text().withDefault(const Constant('day'))();

  TextColumn get bloodGroup => text().nullable()();
  TextColumn get medicalNotes => text().nullable()();

  DateTimeColumn get admittedOn => dateTime().withDefault(currentDateAndTime)();

  /// `active` | `graduated` | `transferred` | `dropped` | `suspended`
  TextColumn get status => text().withDefault(const Constant('active'))();

  /// د QR کارت لپاره پټ کلید — د جعلي کارت مخنیوی کوي.
  /// کارت خپله نمبر نه، بلکې د دې کلید لاسلیک وړي.
  TextColumn get qrSecret => text().nullable()();
  IntColumn get cardVersion => integer().withDefault(const Constant(1))();

  /// د ګوتې نښې پېژندنه — **اختیاري**. ټول ښوونځي سکینر نه لري،
  /// نو دا هېڅکله د ثبت شرط نه دی.
  TextColumn get fingerprintId => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  /// ړنګول = پټول. ریکارډ هېڅکله له منځه نه ځي.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {admissionNo},
  ];
}

class Guardians extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get fullName => text()();

  /// `father` | `mother` | `brother` | `uncle` | `other`
  TextColumn get relation => text()();

  TextColumn get phone => text().nullable()();
  TextColumn get altPhone => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get address => text().nullable()();

  /// د والدینو اپ ته د ننوتلو لپاره.
  TextColumn get appLoginCode => text().nullable()();
  TextColumn get fcmToken => text().nullable()();

  /// کوم کانال ته پیغام ولېږل شي: `app` | `sms` | `whatsapp` | `none`
  TextColumn get preferredChannel =>
      text().withDefault(const Constant('sms'))();
}

class StudentGuardians extends Table {
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get guardianId => integer().references(Guardians, #id)();

  /// اصلي سرپرست — خبرتیا لومړی ده ته ځي.
  BoolColumn get isPrimary => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {studentId, guardianId};
}

class Teachers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get employeeNo => text()();
  TextColumn get fullName => text()();
  TextColumn get fatherName => text().nullable()();
  TextColumn get gender => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get photoPath => text().nullable()();

  TextColumn get qualification => text().nullable()();
  TextColumn get specialization => text().nullable()();
  DateTimeColumn get hiredOn => dateTime().nullable()();

  /// `active` | `on_leave` | `resigned` | `terminated`
  TextColumn get status => text().withDefault(const Constant('active'))();

  IntColumn get monthlySalary => integer().nullable()();
  TextColumn get qrSecret => text().nullable()();

  /// د ګوتې نښه — د استادانو د حاضرۍ لپاره، اختیاري.
  TextColumn get fingerprintId => text().nullable()();
  IntColumn get cardVersion => integer().withDefault(const Constant(1))();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {employeeNo},
  ];
}

/// هغه کارمندان چې استاد نه دي — سرایدار، محاسب، ساتونکی.
class StaffMembers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get employeeNo => text()();
  TextColumn get fullName => text()();
  TextColumn get jobTitle => text()();
  TextColumn get department => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get gender => text()();
  DateTimeColumn get hiredOn => dateTime().nullable()();
  IntColumn get monthlySalary => integer().nullable()();
  TextColumn get status => text().withDefault(const Constant('active'))();

  TextColumn get qrSecret => text().nullable()();
  TextColumn get fingerprintId => text().nullable()();
  IntColumn get cardVersion => integer().withDefault(const Constant(1))();
  TextColumn get photoPath => text().nullable()();

  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {employeeNo},
  ];
}

/// **د استادانو او کارمندانو حاضري — جلا جدول.**
///
/// **ولې د شاګردانو له جدول سره یو ځای نه؟**
/// ځکه چې د شاګرد حاضري د ټولګي، د اجازت‌نامې، د والدینو د خبرتیا او
/// د کارنامې پورې تړلې ده — د استاد حاضري له دې هېڅ یوه سره نه ده.
/// که یو جدول وای، هره پوښتنه به يې `WHERE person_kind = ...` ته
/// اړه درلوده او یوه هېره شوې به د رپوټونو شمېرې خرابې کړې.
class StaffAttendances extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `teacher` | `staff`
  TextColumn get personKind => text()();
  IntColumn get personId => integer()();

  DateTimeColumn get date => dateTime()();

  /// `present` | `late` | `absent` | `leave` | `holiday`
  TextColumn get status => text()();

  DateTimeColumn get checkInAt => dateTime().nullable()();
  DateTimeColumn get checkOutAt => dateTime().nullable()();

  TextColumn get method => text().withDefault(const Constant('roster'))();
  IntColumn get sessionId => integer().withDefault(const Constant(0))();

  TextColumn get note => text().nullable()();
  IntColumn get recordedByUserId => integer().nullable()();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {personKind, personId, date, sessionId},
  ];
}

/// **د آی‌ډي کارت یوه نمونه.**
///
/// د کارت جوړښت (کوم ساحې، چېرې، په کوم رنګ) په JSON کې ساتل کېږي،
/// نه په کوډ کې. **ولې؟** ځکه چې د یوه ښوونځي کارت له بل سره توپیر
/// لري — یو لوګو پورته غواړي، بل په څنګ کې؛ یو د پلار نوم ښیي، بل
/// نه. که په کوډ کې وای، هر بدلون به نوې نسخې ته اړ و.
class CardTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// `student` | `teacher` | `staff`
  TextColumn get audience => text()();

  /// د کارت اندازه په ملي‌مترو — CR80 معیار ۸۵.۶ × ۵۴ دی، خو ځینې
  /// ښوونځي لوی کارت غواړي چې له لرې ولوستل شي.
  RealColumn get widthMm => real().withDefault(const Constant(85.6))();
  RealColumn get heightMm => real().withDefault(const Constant(54.0))();

  /// `landscape` | `portrait`
  TextColumn get orientation =>
      text().withDefault(const Constant('landscape'))();

  /// د عناصرو بشپړ جوړښت — JSON.
  TextColumn get layoutJson => text()();

  /// **دا نمونه اوس کارېږي؟** هر لیدونکي (audience) لپاره یوازې یوه.
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();

  /// د پروګرام سره راغلې نمونه — ړنګېدی نه شي، خو کاپي کېدی شي.
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

/// شاګرد په کوم کال او کوم بخش کې دی — تاریخچه ساتي.
class Enrollments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get sectionId => integer().references(Sections, #id)();
  IntColumn get academicYearId => integer().references(AcademicYears, #id)();

  /// د حاضرۍ لیست کې د ترتیب لپاره.
  IntColumn get rollNo => integer().nullable()();

  DateTimeColumn get enrolledOn => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get leftOn => dateTime().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

// ═══════════════════════════════════════════════════════════
//  حاضري او اجازت نامې
// ═══════════════════════════════════════════════════════════

class Attendances extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();
  IntColumn get sectionId => integer().nullable().references(Sections, #id)();

  /// یوازې نېټه — بې وخته. د ورځې د یووالي لپاره.
  DateTimeColumn get date => dateTime()();

  /// `present` | `late` | `absent` | `leave` | `holiday`
  TextColumn get status => text()();

  DateTimeColumn get checkInAt => dateTime().nullable()();
  DateTimeColumn get checkOutAt => dateTime().nullable()();

  /// څنګه ثبت شو: `qr` | `manual_id` | `roster` | `auto`
  /// | `manual` (له لیسټ څخه په لاس) | `finger` | `face`
  TextColumn get method => text().withDefault(const Constant('roster'))();

  /// کومې ناستې پورې اړه لري. **`0` = د ورځې عمومي حاضري.**
  ///
  /// **ولې صفر او نه `null`؟** ځکه چې SQLite په یوځلي کلي کې `NULL`
  /// له بل `NULL` سره برابر نه ګڼي. که دا ستنه تشېدلی وای، د ورځې
  /// عمومي حاضري به يې هېڅ نه ساتله — یو شاګرد به سل ځله ثبتېده او
  /// قید به نه ماتېده. صفر یو ریښتینی ارزښت دی، نو کلی کار کوي.
  IntColumn get sessionId => integer().withDefault(const Constant(0))();

  /// که د اجازت‌نامې له امله «رخصت» شوی وي، دلته يې تړاو دی.
  IntColumn get leaveRequestId => integer().nullable()();

  TextColumn get note => text().nullable()();
  IntColumn get recordedByUserId => integer().nullable()();
  DateTimeColumn get recordedAt => dateTime().withDefault(currentDateAndTime)();

  /// ایا والدینو ته پیغام تللی؟ — چې دوه ځله ونه لېږل شي.
  BoolColumn get parentNotified =>
      boolean().withDefault(const Constant(false))();
  DateTimeColumn get parentNotifiedAt => dateTime().nullable()();

  /// **یوځلي کلی اوس ناسته هم لري.** پرته له دې، د شپې حاضري به
  /// د سهار ریکارډ بدل کړ — یو شاګرد چې سهار حاضر و او ماښام
  /// غیرحاضر، به یوازې یو حالت درلود.
  @override
  List<Set<Column>> get uniqueKeys => [
    {studentId, date, sessionId},
  ];
}

class LeaveRequests extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get studentId => integer().references(Students, #id)();

  /// `sick` | `family` | `travel` | `official` | `other`
  TextColumn get reasonType => text()();
  TextColumn get reasonText => text().nullable()();

  DateTimeColumn get fromDate => dateTime()();
  DateTimeColumn get toDate => dateTime()();

  /// د ورځې دننه وتل — «HH:mm»، که ټوله ورځ نه وي.
  TextColumn get fromTime => text().nullable()();
  TextColumn get toTime => text().nullable()();

  /// `pending` | `approved` | `rejected` | `cancelled`
  TextColumn get status => text().withDefault(const Constant('pending'))();

  /// چا غوښتنه وکړه: `reception` | `parent_app` | `teacher`
  TextColumn get requestedVia =>
      text().withDefault(const Constant('reception'))();
  IntColumn get requestedByUserId => integer().nullable()();

  IntColumn get decidedByUserId => integer().nullable()();
  DateTimeColumn get decidedAt => dateTime().nullable()();
  TextColumn get decisionNote => text().nullable()();

  /// د ډاکټر پرچه یا نور سند.
  TextColumn get attachmentPath => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

// ═══════════════════════════════════════════════════════════
//  تفتیش — څوک، کله، څه بدل کړل
// ═══════════════════════════════════════════════════════════

class AuditLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().nullable()();
  TextColumn get userName => text().nullable()();

  /// `create` | `update` | `delete` | `login` | `logout` | `export`
  TextColumn get action => text()();

  /// کوم جدول یا ماډل — «students»، «attendance».
  TextColumn get entity => text()();
  IntColumn get entityId => integer().nullable()();

  /// د بدلون توپیر — JSON {"field": {"from": …, "to": …}}
  TextColumn get changesJson => text().nullable()();

  DateTimeColumn get at => dateTime().withDefault(currentDateAndTime)();
}
