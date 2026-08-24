// ═══════════════════════════════════════════════════════════
//  د ټسټ لپاره یو ډک نمونه ډیټابیس — نوعه: مدرسه
//
//  دا فایل یو ازموینه نه ده؛ یوه وسیله ده. `flutter test` يې پخپله
//  نه ځغلوي (ځکه چې د `test/` پوښه دننه نه دی). په لاس يې ځغلوه:
//
//     flutter test tool/make_demo_db.dart
//
//  پایله: build/demo/school.db — یو بشپړ ډیټابیس چې د پروګرام هره
//  برخه پکې ډیټا لري: شاګردان، استادان، کارمندان، مهالویش، حاضري،
//  اجازې، ازموینې، نمرې، فیس، معاشونه، پیغامونه، کارتونه.
//
//  **ولې ثابت تصادف (`Random(7)`)؟** ځکه چې یو ډیټابیس چې هر ځل بل
//  ډول وي، د ازموینې لپاره نه کارېږي — کله چې یوه ستونزه پیدا شي،
//  باید بیا هماغه ډیټا سره جوړه شي.
// ═══════════════════════════════════════════════════════════

import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/features/id_cards/card_layout.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_session_repository.dart';
import 'package:school_manager/data/repositories/card_repository.dart';
import 'package:school_manager/data/repositories/exam_repository.dart';
import 'package:school_manager/data/repositories/fee_repository.dart';
import 'package:school_manager/data/repositories/leave_repository.dart';
import 'package:school_manager/data/repositories/message_repository.dart';
import 'package:school_manager/data/repositories/notification_repository.dart';
import 'package:school_manager/data/repositories/payroll_repository.dart';
import 'package:school_manager/data/repositories/timetable_repository.dart';
import 'package:school_manager/data/repositories/user_repository.dart';

/// د ټول ډیټابیس «نن» — نېټې ترې حسابېږي.
///
/// **ولې نه `DateTime.now()`؟** ځکه چې بیا به هر ځل بل ډیټابیس
/// جوړ شو او د ورځې رپوټونه به يې د بلې ورځې و.
final _today = DateTime(2026, 5, 14);

final _rand = Random(7);

const _outDir = 'build/demo';

void main() {
  test('د مدرسې نمونه ډیټابیس جوړېږي', () async {
    final dir = Directory(_outDir);
    if (dir.existsSync()) dir.deleteSync(recursive: true);
    dir.createSync(recursive: true);

    const path = '$_outDir/school.db';
    final db = AppDatabase.atPath(path);

    await _school(db);
    await _users(db);
    final yearId = await _structure(db);
    final teachers = await _teachers(db);
    await _assignBooks(db, teachers);
    final staff = await _staff(db);
    final students = await _students(db);
    await _timetable(db, teachers);
    await _sessions(db);
    await _attendance(db, students);
    await _staffAttendance(db, teachers, staff);
    await _leaves(db, students);
    await _exams(db, yearId, students);
    await _fees(db, yearId);
    await _payroll(db, teachers, staff);
    await _comms(db, students);
    await _cards(db, teachers, staff, students);

    // WAL بېرته په اصلي فایل کې ننباسو — که نه، `school.db` به نیمه
    // تشه وه او `-wal` فایل به ورسره وړل کېده.
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    await db.close();

    _report(path);
  }, timeout: const Timeout(Duration(minutes: 15)));
}

// ═══════════════════════════════════════════════════════════
//  ۱ — مدرسه او تنظیمات
// ═══════════════════════════════════════════════════════════

Future<void> _school(AppDatabase db) async {
  await db
      .into(db.schools)
      .insert(
        SchoolsCompanion.insert(
          name: 'د دارالعلوم نور مدرسه',
          nameEn: const Value('Darul Uloom Noor Madrasa'),
          kind: const Value('madrasa'),
          address: const Value('کابل، لوی ده سبز، د نور جومات څنګ ته'),
          phone: const Value('0700123456'),
          email: const Value('info@darululoom-noor.af'),
          dayStart: const Value('06:30'),
          dayEnd: const Value('11:05'),
          lateAfterMinutes: const Value(10),
          absentAfterMinutes: const Value(45),
          weekendDays: const Value('4,5'),
          periodsPerDay: const Value(6),
          periodMinutes: const Value(45),
          // **د هر ساعت خپله اندازه** — سبق اوږد، تکرار لنډ.
          periodMinutesCsv: const Value('60,45,45,40,40,30'),
          breakAfterPeriods: const Value(3),
          breakMinutes: const Value(15),
          breaksPerDay: const Value(1),
          defaultCapacity: const Value(35),
          classesView: const Value('grid'),
          timetableMode: const Value('daily'),
        ),
      );
}

// ═══════════════════════════════════════════════════════════
//  ۲ — کاروونکي (هر رول یو)
// ═══════════════════════════════════════════════════════════

Future<void> _users(AppDatabase db) async {
  final users = UserRepository(db);

  const list = <(String, String, String, String)>[
    ('admin', 'مولوي عبدالرحمن نوري', 'admin', 'admin123'),
    ('deputy', 'مولوي نصرالله حقاني', 'deputy', 'deputy123'),
    ('ustad', 'قاري احمد شاه', 'teacher', 'ustad123'),
    ('hisab', 'حاجي محمد یونس', 'accountant', 'hisab123'),
    ('daftar', 'نجیب الله صافي', 'reception', 'daftar123'),
  ];

  for (final (username, name, role, pass) in list) {
    await users.create(
      username: username,
      fullName: name,
      password: pass,
      role: role,
      byUserId: 1,
      byUserName: 'سیسټم',
    );
  }

  // یو کارن چې د تلوالې څخه بهر استثنا لري — چې د اجازو پاڼه
  // ازمویل شي: مرستیال چې فیس هم لیدلی شي.
  await users.updatePermissions(
    userId: 2,
    permissions: {
      ...{
        for (final e in roleDefaults['deputy']!.entries) e.key: e.value.toSet(),
      },
      'fees': {'view'},
    },
    byUserId: 1,
    byUserName: 'مولوي عبدالرحمن نوري',
  );

  // یو غیرفعال کارن — چې «فعال/ناfعال» فلټر ډیټا ولري.
  await users.create(
    username: 'zaher',
    fullName: 'ظاهرشاه پوپل',
    password: 'zaher123',
    role: 'reception',
    byUserId: 1,
    byUserName: 'مولوي عبدالرحمن نوري',
  );
  await users.setActive(
    userId: 6,
    active: false,
    byUserId: 1,
    byUserName: 'مولوي عبدالرحمن نوري',
  );
}

// ═══════════════════════════════════════════════════════════
//  ۳ — درجې، بخشونه، فنون
// ═══════════════════════════════════════════════════════════

Future<int> _structure(AppDatabase db) async {
  final academic = AcademicRepository(db);
  await academic.seedMadrasaStructure(
    yearLabel: '۱۴۴۷ هـ ق',
    startsOn: DateTime(2026, 3, 21),
    endsOn: DateTime(2026, 12, 20),
    capacity: 35,
  );

  // درې لومړۍ درجې دوه اجزا لري — چې د اجزاوو فلټر ډیټا ولري.
  // پاتې يې بې‌نومه (یوه بشپړه درجه) پاتې کېږي، لکه یوه ریښتینې
  // مدرسه.
  final grades = await academic.grades();
  final year = (await academic.currentYear())!;
  for (final g in grades.take(3)) {
    await academic.addSection(gradeId: g.id, name: 'ب', capacity: 35);
  }
  return year.id;
}

/// هر کتاب خپل مدرس او خپلې پاڼې واخلي — چې نوي ساحې تشې نه وي.
Future<void> _assignBooks(AppDatabase db, List<int> teachers) async {
  final academic = AcademicRepository(db);
  final subjects = await academic.subjects();
  for (var i = 0; i < subjects.length; i++) {
    await academic.updateSubject(
      id: subjects[i].id,
      teacherId: teachers[i % teachers.length],
      pages: 60 + (i * 17) % 260,
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ۴ — استادان
// ═══════════════════════════════════════════════════════════

const _teacherRows = <(String, String, String, String, int)>[
  ('مولوي عبدالباري حقاني', 'حاجي عبدالغني', 'دورهٔ حدیث', 'حدیث او فقه', 18000),
  ('مفتي شمس الرحمن', 'محمدنبي', 'تخصص فی الافتاء', 'فقه او فتوا', 20000),
  ('قاري حبیب الله', 'عبدالحق', 'قرات عشره', 'تجوید او قرات', 15000),
  ('مولوي سیف الرحمن', 'گل محمد', 'دورهٔ حدیث', 'تفسیر', 16000),
  ('مولوي عزیزالرحمن', 'شیرخان', 'دورهٔ حدیث', 'نحو او صرف', 15500),
  ('استاد نصرالله ژوند', 'میرویس', 'لیسانس ریاضي', 'حساب', 13000),
  ('استاد فرید احمد', 'دلاور', 'لیسانس انګلیسي', 'انګلیسي', 13500),
  ('مولوي رحمت الله', 'نورمحمد', 'دورهٔ حدیث', 'منطق او فلسفه', 14500),
  ('قاري بلال احمد', 'سردارمحمد', 'حفظ او تجوید', 'حفظ', 12000),
  ('مولوي اجمل خان', 'اکبرخان', 'دورهٔ حدیث', 'اصول فقه', 15000),
  ('استاد وحیدالله', 'پاینده محمد', 'لیسانس کمپیوټر', 'کمپیوټر', 12500),
  ('مولوي هدایت الله', 'محمدعمر', 'دورهٔ حدیث', 'سیرت او تاریخ', 14000),
  ('قاریه صفیه نور', 'عبدالوهاب', 'حفظ او تجوید', 'حفظ (انجونې)', 11000),
  ('مولوي ذبیح الله', 'جمعه خان', 'دورهٔ حدیث', 'ادب عربي', 14500),
];

Future<List<int>> _teachers(AppDatabase db) async {
  final ids = <int>[];
  var n = 1;

  for (final (name, father, qual, spec, salary) in _teacherRows) {
    final id = await db
        .into(db.teachers)
        .insert(
          TeachersCompanion.insert(
            employeeNo: 'T-${n.toString().padLeft(3, '0')}',
            fullName: name,
            fatherName: Value(father),
            gender: name.startsWith('قاریه') ? 'female' : 'male',
            phone: Value('07${(70000000 + n * 131711)}'.substring(0, 10)),
            address: Value('کابل، ${n.isEven ? 'خیرخانه' : 'ده سبز'}'),
            qualification: Value(qual),
            specialization: Value(spec),
            hiredOn: Value(DateTime(2019 + n % 6, 1 + n % 11, 1 + n % 27)),
            monthlySalary: Value(salary),
            status: const Value('active'),
          ),
        );
    ids.add(id);
    n++;
  }

  // یو استاد چې رخصت دی او یو چې ړنګ شوی — د حالت فلټر لپاره.
  await (db.update(db.teachers)..where((t) => t.id.equals(ids[10]))).write(
    const TeachersCompanion(status: Value('leave')),
  );
  final gone = await db
      .into(db.teachers)
      .insert(
        TeachersCompanion.insert(
          employeeNo: 'T-015',
          fullName: 'مولوي شرافت الله',
          gender: 'male',
          monthlySalary: const Value(13000),
          status: const Value('inactive'),
          deletedAt: Value(DateTime(2026, 2, 11)),
        ),
      );
  assert(gone > 0);

  // د درجو مشر استادان.
  final sections = await db.select(db.sections).get();
  for (var i = 0; i < sections.length; i++) {
    await (db.update(db.sections)..where((s) => s.id.equals(sections[i].id)))
        .write(SectionsCompanion(headTeacherId: Value(ids[i % ids.length])));
  }

  return ids;
}

// ═══════════════════════════════════════════════════════════
//  ۵ — کارمندان
// ═══════════════════════════════════════════════════════════

const _staffRows = <(String, String, String, int, String)>[
  ('حاجي محمد یونس', 'محاسب', 'اداري', 12000, 'male'),
  ('نجیب الله صافي', 'د دفتر مدیر', 'اداري', 11000, 'male'),
  ('ګل احمد نظري', 'ساتونکی', 'خدمات', 7000, 'male'),
  ('سیدال خان', 'پخلی', 'خدمات', 7500, 'male'),
  ('عبدالقدوس', 'خدمتګار', 'خدمات', 6500, 'male'),
  ('محمدآصف', 'ډرایور', 'ترانسپورت', 9000, 'male'),
  ('نورالله باغوان', 'باغوان', 'خدمات', 6000, 'male'),
  ('ډاکټر زرغونه', 'نرس', 'روغتیا', 10000, 'female'),
  ('احسان الله', 'کتابدار', 'اداري', 8500, 'male'),
];

Future<List<int>> _staff(AppDatabase db) async {
  final ids = <int>[];
  var n = 1;

  for (final (name, job, dept, salary, gender) in _staffRows) {
    final id = await db
        .into(db.staffMembers)
        .insert(
          StaffMembersCompanion.insert(
            employeeNo: 'S-${n.toString().padLeft(3, '0')}',
            fullName: name,
            jobTitle: job,
            department: Value(dept),
            gender: gender,
            phone: Value('07${(80000000 + n * 217319)}'.substring(0, 10)),
            hiredOn: Value(DateTime(2020 + n % 5, 1 + n % 11, 2 + n % 26)),
            monthlySalary: Value(salary),
            status: Value(n == 7 ? 'leave' : 'active'),
          ),
        );
    ids.add(id);
    n++;
  }
  return ids;
}

// ═══════════════════════════════════════════════════════════
//  ۶ — شاګردان، کوروالي او نوم‌لیکنه
// ═══════════════════════════════════════════════════════════

const _boyNames = [
  'احمد', 'محمود', 'عبدالله', 'اسامه', 'بلال', 'حمزه', 'زبیر', 'طلحه',
  'عمار', 'انس', 'معاذ', 'سلمان', 'صهیب', 'خالد', 'سعد', 'ابوبکر',
  'عثمان', 'علي', 'حسن', 'حسین', 'ادریس', 'یوسف', 'ابراهیم', 'اسحاق',
  'یعقوب', 'الیاس', 'شعیب', 'صالح', 'هارون', 'زکریا', 'ایوب', 'داوود',
];

const _girlNames = [
  'عایشه', 'فاطمه', 'خدیجه', 'مریم', 'زینب', 'حفصه', 'صفیه', 'رقیه',
  'ام کلثوم', 'اسماء', 'سمیه', 'رملة', 'جویریه', 'میمونه',
];

const _familyNames = [
  'احمدزی', 'نوري', 'حقاني', 'صافي', 'پوپل', 'کاکړ', 'ستانکزی', 'اڅکزی',
  'مومند', 'شینواری', 'بارکزی', 'الکوزی', 'وردګ', 'لوګري', 'پنجشیري',
  'بلخي', 'هراتي', 'کندهاري', 'ننګرهاري', 'غزنوي',
];

const _fatherNames = [
  'محمدګل', 'عبدالغفور', 'نورمحمد', 'گل احمد', 'سیدمحمد', 'شیرمحمد',
  'عبدالرزاق', 'محمدنعیم', 'دلاورخان', 'جمعه خان', 'پاینده محمد',
  'حاجي زلمی', 'عبدالوکیل', 'میرویس', 'اکبرخان', 'سردارمحمد',
];

const _bloods = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];

const _places = <(String, String, String)>[
  ('کابل', 'ده سبز', 'قلعه زمانخان'),
  ('کابل', 'بگرامي', 'شیوکي'),
  ('ننگرهار', 'جلال آباد', 'سرخ رود'),
  ('لوگر', 'محمد آغه', 'کلنګار'),
  ('پکتیا', 'گردیز', 'زرمت'),
  ('کندهار', 'کندهار', 'دند'),
  ('هرات', 'انجیل', 'گذره'),
  ('بلخ', 'مزار شریف', 'خلم'),
  ('کندز', 'کندز', 'خان آباد'),
  ('غزني', 'غزني', 'قره باغ'),
  ('پروان', 'چاریکار', 'بگرام'),
  ('وردګ', 'میدان شهر', 'سیدآباد'),
];

Future<List<({int id, int sectionId, int gradeId})>> _students(
  AppDatabase db,
) async {
  final academic = AcademicRepository(db);
  final year = (await academic.currentYear())!;
  final sections = await academic.sections();
  final out = <({int id, int sectionId, int gradeId})>[];

  var n = 0;
  for (final sec in sections) {
    // لوړې درجې لږ شاګردان لري — لکه یوه ریښتینې مدرسه.
    final count = 8 + _rand.nextInt(14);

    for (var i = 0; i < count; i++) {
      n++;
      final female = _rand.nextInt(10) == 0;
      final first = female
          ? _girlNames[_rand.nextInt(_girlNames.length)]
          : _boyNames[_rand.nextInt(_boyNames.length)];
      final family = _familyNames[_rand.nextInt(_familyNames.length)];
      final father = _fatherNames[_rand.nextInt(_fatherNames.length)];
      final place = _places[_rand.nextInt(_places.length)];
      final boarding = _rand.nextInt(3) == 0;

      // ۹۰٪ فعال — پاتې د حالت فلټر لپاره.
      final status = switch (n % 37) {
        3 => 'graduated',
        11 => 'transferred',
        19 => 'dropped',
        29 => 'suspended',
        _ => 'active',
      };

      final id = await db
          .into(db.students)
          .insert(
            StudentsCompanion.insert(
              admissionNo: '1447-${n.toString().padLeft(4, '0')}',
              firstName: first,
              lastName: Value(family),
              fatherName: father,
              grandFatherName: Value(
                _fatherNames[_rand.nextInt(_fatherNames.length)],
              ),
              gender: female ? 'female' : 'male',
              birthDate: Value(
                DateTime(
                  2004 + _rand.nextInt(16),
                  1 + _rand.nextInt(12),
                  1 + _rand.nextInt(28),
                ),
              ),
              birthPlace: Value(place.$1),
              nationalId: Value('14${1000000 + n * 7919}'),
              phone: Value('07${(60000000 + n * 41)}'.substring(0, 10)),
              province: Value(place.$1),
              district: Value(place.$2),
              village: Value(place.$3),
              address: Value('${place.$3}، ${place.$2}'),
              residency: Value(boarding ? 'boarding' : 'day'),
              bloodGroup: Value(_bloods[_rand.nextInt(_bloods.length)]),
              medicalNotes: Value(
                _rand.nextInt(12) == 0 ? 'د سترګو کمزوري — عینکې کاروي' : null,
              ),
              admittedOn: Value(
                DateTime(2026, 3, 21).subtract(
                  Duration(days: 365 * _rand.nextInt(5) + _rand.nextInt(60)),
                ),
              ),
              status: Value(status),
              qrSecret: Value('DEMO${n.toString().padLeft(5, '0')}KEY'),
              cardVersion: const Value(1),
              // یوازې څو تنه ګوته لري — چې «ثبت شوی/نه‌دی» ډیټا ولري.
              fingerprintId: Value(
                _rand.nextInt(4) == 0 ? 'FP-${1000 + n}' : null,
              ),
            ),
          );

      // پلار = لومړی سرپرست؛ ځینې مور یا ورور هم لري.
      final gid = await db
          .into(db.guardians)
          .insert(
            GuardiansCompanion.insert(
              fullName: father,
              relation: 'پلار',
              phone: Value('07${(50000000 + n * 97)}'.substring(0, 10)),
              altPhone: Value(
                _rand.nextInt(3) == 0
                    ? '07${(90000000 + n * 53)}'.substring(0, 10)
                    : null,
              ),
              occupation: Value(
                ['کروندګر', 'دوکاندار', 'ښوونکی', 'ډرایور', 'کارګر',
                  'مامور'][_rand.nextInt(6)],
              ),
              nationalId: Value('14${2000000 + n * 3121}'),
              address: Value('${place.$3}، ${place.$2}، ${place.$1}'),
              preferredChannel: Value(_rand.nextInt(2) == 0 ? 'app' : 'sms'),
            ),
          );
      await db
          .into(db.studentGuardians)
          .insert(
            StudentGuardiansCompanion.insert(
              studentId: id,
              guardianId: gid,
              isPrimary: const Value(true),
            ),
          );

      if (_rand.nextInt(3) == 0) {
        final gid2 = await db
            .into(db.guardians)
            .insert(
              GuardiansCompanion.insert(
                fullName: 'ورور ${_boyNames[_rand.nextInt(_boyNames.length)]}',
                relation: 'ورور',
                phone: Value('07${(40000000 + n * 71)}'.substring(0, 10)),
                preferredChannel: const Value('sms'),
              ),
            );
        await db
            .into(db.studentGuardians)
            .insert(
              StudentGuardiansCompanion.insert(
                studentId: id,
                guardianId: gid2,
              ),
            );
      }

      await db
          .into(db.enrollments)
          .insert(
            EnrollmentsCompanion.insert(
              studentId: id,
              sectionId: sec.sectionId,
              academicYearId: year.id,
              rollNo: Value(i + 1),
              isActive: Value(status == 'active'),
            ),
          );

      out.add((id: id, sectionId: sec.sectionId, gradeId: sec.gradeId));
    }
  }
  return out;
}

// ═══════════════════════════════════════════════════════════
//  ۷ — درسي ساعتونه او مهالویش
// ═══════════════════════════════════════════════════════════

Future<void> _timetable(AppDatabase db, List<int> teachers) async {
  final tt = TimetableRepository(db);

  // د مدرسې ساعتونه — هر یو خپله اندازه لري.
  await tt.rebuildSlots(
    dayStart: '06:30',
    periodsPerDay: 6,
    periodMinutes: 45,
    breakAfterPeriods: 3,
    breakMinutes: 15,
    breaksPerDay: 1,
    perPeriodMinutes: const [60, 45, 45, 40, 40, 30],
  );

  // ځیرک ترتیب — ټول بخشونه، ټولې ورځې.
  final plan = await tt.arrange(daily: true);
  await tt.applyPlan(plan);

  // چې د استادانو رپوټ خالي نه وي، هغه کوټې چې استاد يې نشته
  // په وار سره استادانو ته ورکوو.
  final rows = await db.select(db.timetableEntries).get();
  var i = 0;
  for (final r in rows) {
    if (r.teacherId != null) continue;
    await (db.update(db.timetableEntries)..where((t) => t.id.equals(r.id)))
        .write(
          TimetableEntriesCompanion(
            teacherId: Value(teachers[i++ % teachers.length]),
            room: Value('کوټه ${1 + (r.sectionId % 12)}'),
          ),
        );
  }
}

// ═══════════════════════════════════════════════════════════
//  ۸ — د حاضرۍ ناستې
// ═══════════════════════════════════════════════════════════

Future<void> _sessions(AppDatabase db) async {
  final s = AttendanceSessionRepository(db);
  await s.seedDefault(name: 'سهارنۍ حاضري');

  await s.create(
    name: 'د ماسپښین تکرار',
    target: 'all',
    startTime: '13:00',
    endTime: '14:00',
    days: '6,7,1,2,3',
    lateAfterMinutes: 10,
  );

  // یوه ناسته چې یوازې یوې درجې پورې اړه لري — د «هدف» ازموینې لپاره.
  final grade = (await db.select(db.grades).get()).first;
  await s.create(
    name: 'د حفظ ناسته',
    target: 'grade',
    gradeId: grade.id,
    startTime: '16:30',
    endTime: '17:30',
    days: '6,7,1,2,3',
  );
}

// ═══════════════════════════════════════════════════════════
//  ۹ — حاضري (درې میاشتې)
// ═══════════════════════════════════════════════════════════

/// د درسي ورځو لیست — پنجشنبه او جمعه رخصت.
List<DateTime> _schoolDays(int back) {
  final out = <DateTime>[];
  for (var i = back; i >= 0; i--) {
    final d = _today.subtract(Duration(days: i));
    if (d.weekday == DateTime.thursday || d.weekday == DateTime.friday) {
      continue;
    }
    out.add(DateTime(d.year, d.month, d.day));
  }
  return out;
}

Future<void> _attendance(
  AppDatabase db,
  List<({int id, int sectionId, int gradeId})> students,
) async {
  final days = _schoolDays(95);

  // **هر شاګرد خپل عادت لري.** که ټول یو شان وي، رپوټ به بې‌مانا و:
  // «څوک ستونزه لري؟» ته به يې ځواب نه درلود. نو څو تنه جوړوو چې
  // ډېر غیرحاضرېږي، څو تنه چې ناوخته راځي، او پاتې منظم.
  final habit = <int, double>{};
  for (var i = 0; i < students.length; i++) {
    habit[students[i].id] = switch (i % 17) {
      0 => 0.55, // ډېر ستونزمن
      1 => 0.75,
      2 || 3 => 0.88,
      _ => 0.96,
    };
  }

  var batch = <AttendancesCompanion>[];

  Future<void> flush() async {
    if (batch.isEmpty) return;
    final rows = batch;
    batch = [];
    await db.batch((b) => b.insertAll(db.attendances, rows));
  }

  for (final day in days) {
    for (final s in students) {
      final p = habit[s.id]!;
      final roll = _rand.nextDouble();
      final status = roll < p
          ? (_rand.nextInt(9) == 0 ? 'late' : 'present')
          : (_rand.nextInt(3) == 0 ? 'leave' : 'absent');

      final checkIn = status == 'present' || status == 'late'
          ? DateTime(
              day.year,
              day.month,
              day.day,
              6,
              (status == 'late' ? 35 : 5) + _rand.nextInt(18),
            )
          : null;

      batch.add(
        AttendancesCompanion.insert(
          studentId: s.id,
          sectionId: Value(s.sectionId),
          date: day,
          status: status,
          checkInAt: Value(checkIn),
          // ډېری يې د QR له لارې، ځینې په لاس — چې «طریقه» ډیټا ولري.
          method: Value(
            checkIn == null
                ? 'roster'
                : (_rand.nextInt(5) == 0 ? 'fingerprint' : 'qr'),
          ),
          sessionId: const Value(1),
          recordedByUserId: const Value(1),
          recordedAt: Value(checkIn ?? day),
        ),
      );

      if (batch.length >= 2000) await flush();
    }
  }
  await flush();

  // وروستۍ ورځ د دویمې ناستې حاضري هم لري — چې د ناستو پرتله وشي.
  final last = days.last;
  await db.batch(
    (b) => b.insertAll(db.attendances, [
      for (final s in students.take(60))
        AttendancesCompanion.insert(
          studentId: s.id,
          sectionId: Value(s.sectionId),
          date: last,
          status: _rand.nextInt(6) == 0 ? 'absent' : 'present',
          sessionId: const Value(2),
          method: const Value('roster'),
          recordedByUserId: const Value(2),
        ),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════
//  ۱۰ — د استادانو او کارمندانو حاضري
// ═══════════════════════════════════════════════════════════

Future<void> _staffAttendance(
  AppDatabase db,
  List<int> teachers,
  List<int> staff,
) async {
  final days = _schoolDays(60);
  final rows = <StaffAttendancesCompanion>[];

  void add(String kind, int id, DateTime day, double good) {
    final status = _rand.nextDouble() < good
        ? (_rand.nextInt(12) == 0 ? 'late' : 'present')
        : (_rand.nextInt(2) == 0 ? 'leave' : 'absent');
    rows.add(
      StaffAttendancesCompanion.insert(
        personKind: kind,
        personId: id,
        date: day,
        status: status,
        method: Value(_rand.nextInt(3) == 0 ? 'qr' : 'roster'),
        checkInAt: Value(
          status == 'present' || status == 'late'
              ? DateTime(day.year, day.month, day.day, 6, 10 + _rand.nextInt(30))
              : null,
        ),
        recordedByUserId: const Value(1),
      ),
    );
  }

  for (final day in days) {
    for (var i = 0; i < teachers.length; i++) {
      add('teacher', teachers[i], day, i == 3 ? 0.72 : 0.95);
    }
    for (var i = 0; i < staff.length; i++) {
      add('staff', staff[i], day, i == 4 ? 0.80 : 0.97);
    }
  }

  await db.batch((b) => b.insertAll(db.staffAttendances, rows));
}

// ═══════════════════════════════════════════════════════════
//  ۱۱ — اجازت‌نامې
// ═══════════════════════════════════════════════════════════

Future<void> _leaves(
  AppDatabase db,
  List<({int id, int sectionId, int gradeId})> students,
) async {
  final leave = LeaveRepository(db);

  const reasons = <(String, String)>[
    ('sick', 'تبه او ټوخی — ډاکټر دوه ورځې استراحت ورکړی'),
    ('family', 'د ورور واده'),
    ('travel', 'کلي ته سفر'),
    ('official', 'د امتحان لپاره کابل ته تګ'),
    ('other', 'شخصي چاره'),
  ];

  // ۳۶ فردي غوښتنې — یو ثلث نوې (د تصویب په تمه)، پاتې پرېکړه شوې.
  for (var i = 0; i < 36; i++) {
    final s = students[_rand.nextInt(students.length)];
    final (kind, text) = reasons[i % reasons.length];
    final from = _today.subtract(Duration(days: _rand.nextInt(70)));

    final id = await leave.request(
      studentId: s.id,
      reasonType: kind,
      reasonText: text,
      fromDate: from,
      toDate: from.add(Duration(days: _rand.nextInt(3))),
      requestedVia: i.isEven ? 'app' : 'reception',
      requestedByUserId: i.isEven ? null : 5,
    );

    if (i % 3 == 0) continue; // پاتې کېږي: pending
    await leave.decide(
      leaveId: id,
      approve: i % 7 != 0,
      note: i % 7 != 0 ? 'ومنل شوه' : 'سبب بسنه نه کوي',
      byUserId: 1,
      byUserName: 'مولوي عبدالرحمن نوري',
    );
  }

  // یوه ډله‌ییزه اجازه — د یوه کلي شاګردان یوه ورځ ځي.
  await leave.requestBulk(
    studentIds: [for (final s in students.take(14)) s.id],
    reasonType: 'travel',
    reasonText: 'د کلي د جرګې لپاره یوه ورځ رخصت',
    fromDate: _today.subtract(const Duration(days: 9)),
    toDate: _today.subtract(const Duration(days: 9)),
    requestedVia: 'reception',
    requestedByUserId: 2,
  );
}

// ═══════════════════════════════════════════════════════════
//  ۱۲ — ازموینې او نمرې
// ═══════════════════════════════════════════════════════════

Future<void> _exams(
  AppDatabase db,
  int yearId,
  List<({int id, int sectionId, int gradeId})> students,
) async {
  final exams = ExamRepository(db);
  final academic = AcademicRepository(db);
  final grades = await academic.grades();

  final defs = <(String, String, int, DateTime, DateTime)>[
    (
      'د لومړۍ ثلثې ازموینه',
      'midterm',
      1,
      DateTime(2026, 6, 20),
      DateTime(2026, 6, 27),
    ),
    (
      'د دویمې ثلثې ازموینه',
      'midterm',
      2,
      DateTime(2026, 9, 12),
      DateTime(2026, 9, 19),
    ),
    (
      'کلنۍ (سالانه) ازموینه',
      'final',
      3,
      DateTime(2026, 12, 5),
      DateTime(2026, 12, 14),
    ),
    (
      'میاشتنۍ ازموینه — ثور',
      'monthly',
      1,
      DateTime(2026, 5, 4),
      DateTime(2026, 5, 6),
    ),
  ];

  for (var e = 0; e < defs.length; e++) {
    final (name, kind, term, from, to) = defs[e];
    final examId = await exams.create(
      name: name,
      examType: kind,
      academicYearId: yearId,
      term: term,
      startsOn: from,
      endsOn: to,
    );

    for (final g in grades) {
      final subs = await academic.subjects(gradeId: g.id);
      if (subs.isEmpty) continue;
      // میاشتنۍ ازموینه یوازې درې فنون لري — لکه ریښتیا.
      final chosen = kind == 'monthly' ? subs.take(3).toList() : subs;
      await exams.addSubjects(
        examId: examId,
        gradeId: g.id,
        subjectIds: [for (final s in chosen) s.id],
        fullMark: kind == 'monthly' ? 20 : 100,
        passMark: kind == 'monthly' ? 8 : 40,
      );
    }

    // وروستۍ ازموینه لا نمرې نه لري — چې «نه‌دي ثبت شوي» حالت وښکاري.
    if (e == 2) continue;

    final subjectRows = await db.select(db.examSubjects).get()
      ..removeWhere((r) => r.examId != examId);

    for (final row in subjectRows) {
      final inGrade = students.where((s) => s.gradeId == row.gradeId);
      if (inGrade.isEmpty) continue;

      final marks = <int, ({double? obtained, bool isAbsent})>{};
      for (final s in inGrade) {
        // ۴٪ غیرحاضر؛ پاتې يې نمرې د یوې نورمالې څپې په څېر.
        if (_rand.nextInt(25) == 0) {
          marks[s.id] = (obtained: null, isAbsent: true);
          continue;
        }
        final base = row.fullMark * (0.45 + _rand.nextDouble() * 0.53);
        marks[s.id] = (
          obtained: base.clamp(0, row.fullMark.toDouble()).roundToDouble(),
          isAbsent: false,
        );
      }
      await exams.saveMarks(
        examSubjectId: row.id,
        byStudent: marks,
        byUserId: 3,
      );
    }

    // لومړۍ دوه خپرې شوې دي، میاشتنۍ نه — چې دواړه حالتونه شته وي.
    await exams.publish(examId, published: e < 2);
  }
}

// ═══════════════════════════════════════════════════════════
//  ۱۳ — فیس: بلونه، ورکړې، تخفیف، معافي
// ═══════════════════════════════════════════════════════════

Future<void> _fees(AppDatabase db, int yearId) async {
  final fees = FeeRepository(db);
  await fees.seedDefaultTypes();

  // یو ځانګړی ډول — د لیلیې (بورډنګ) فیس.
  final hostel = await fees.addType(
    name: 'د لیلیې فیس',
    amount: 1200,
    frequency: 'monthly',
  );

  final types = await db.select(db.feeTypes).get();
  final monthly = types.firstWhere((t) => t.name == 'میاشتنی فیس');
  final admission = types.firstWhere((t) => t.name == 'د داخلې فیس');
  final books = types.firstWhere((t) => t.name == 'د کتابونو پیسې');

  // درې میاشتې میاشتنی فیس + یو ځل داخله + کتابونه.
  for (final (m, label) in [(3, '1447-03'), (4, '1447-04'), (5, '1447-05')]) {
    await fees.generate(
      feeTypeId: monthly.id,
      period: label,
      dueDate: DateTime(2026, m, 10),
      academicYearId: yearId,
      byUserId: 4,
    );
    await fees.generate(
      feeTypeId: hostel,
      period: label,
      dueDate: DateTime(2026, m, 10),
      academicYearId: yearId,
      byUserId: 4,
    );
  }
  await fees.generate(
    feeTypeId: admission.id,
    period: '1447',
    dueDate: DateTime(2026, 4, 1),
    academicYearId: yearId,
    byUserId: 4,
  );
  await fees.generate(
    feeTypeId: books.id,
    period: '1447',
    dueDate: DateTime(2026, 4, 15),
    academicYearId: yearId,
    byUserId: 4,
  );

  final invoices = await db.select(db.feeInvoices).get();

  for (var i = 0; i < invoices.length; i++) {
    final inv = invoices[i];

    // ۶٪ معاف — یتیم یا بې‌وزله.
    if (i % 17 == 0) {
      await fees.waive(inv.id, reason: 'یتیم — د مدرسې پرېکړه', byUserId: 1);
      continue;
    }

    // ۹٪ تخفیف لري — د ورونو تخفیف.
    if (i % 11 == 0) {
      await fees.setDiscount(
        invoiceId: inv.id,
        discount: (inv.amount * 0.25).round(),
        reason: 'د ورونو تخفیف (۲۵٪)',
      );
    }

    final owed = inv.amount - (i % 11 == 0 ? (inv.amount * 0.25).round() : 0);
    final roll = _rand.nextDouble();

    if (roll < 0.62) {
      // بشپړ ورکړل شوی
      await fees.pay(
        invoiceId: inv.id,
        amount: owed,
        method: ['cash', 'bank', 'mobile'][_rand.nextInt(3)],
        byUserId: 4,
        now: inv.dueDate.subtract(Duration(days: _rand.nextInt(6))),
      );
    } else if (roll < 0.80) {
      // نیمګړی — دوه برخې
      final part = (owed * 0.4).round();
      await fees.pay(
        invoiceId: inv.id,
        amount: part,
        method: 'cash',
        byUserId: 4,
        now: inv.dueDate.subtract(const Duration(days: 2)),
      );
    }
    // پاتې: نه‌ورکړل شوی
  }
}

// ═══════════════════════════════════════════════════════════
//  ۱۴ — معاشونه
// ═══════════════════════════════════════════════════════════

Future<void> _payroll(
  AppDatabase db,
  List<int> teachers,
  List<int> staff,
) async {
  final pay = PayrollRepository(db);

  // درې میاشتې: دوه ورکړل شوې، وروستۍ لا مسوده.
  for (final (period, state) in [
    ('1447-03', 'paid'),
    ('1447-04', 'paid'),
    ('1447-05', 'draft'),
  ]) {
    final runId = await pay.createRun(period: period, byUserId: 4);

    final items = await (db.select(
      db.payrollItems,
    )..where((i) => i.runId.equals(runId))).get();

    for (var i = 0; i < items.length; i++) {
      await pay.updateItem(
        itemId: items[i].id,
        allowances: i % 4 == 0 ? 1500 : (i % 3 == 0 ? 800 : 0),
        deductions: i % 9 == 0 ? 500 : 0,
        absenceDeduction: i % 5 == 0 ? 400 : 0,
        absentDays: i % 5 == 0 ? 2 : 0,
        note: i % 4 == 0 ? 'د اضافي ساعتونو حق' : null,
      );
    }

    if (state == 'paid') {
      await pay.approve(runId, byUserId: 1);
      await pay.markPaid(
        runId,
        at: DateTime(2026, int.parse(period.split('-').last), 28),
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  ۱۵ — پیغامونه، خبرتیاوې، وسیلې
// ═══════════════════════════════════════════════════════════

Future<void> _comms(
  AppDatabase db,
  List<({int id, int sectionId, int gradeId})> students,
) async {
  await MessageRepository(db).ensureDefaultTemplates();

  // یوه خپله کینډۍ — سربېره پر تلوالو.
  await db
      .into(db.messageTemplates)
      .insert(
        MessageTemplatesCompanion.insert(
          templateKey: 'ramadan',
          title: 'د رمضان مهالویش',
          body: 'د {school} په مدرسه کې د رمضان درسونه {time} پیلېږي.',
          channel: const Value('any'),
        ),
      );

  final guardians = await db.select(db.guardians).get();

  const bodies = [
    'ستاسو زوی {name} نن غیرحاضر و. مهرباني وکړئ خبر راکړئ.',
    'د میاشتنۍ ازموینې پایلې خپرې شوې — راشئ او واخلئ.',
    'د میاشتنی فیس وروستۍ نېټه ۱۰مه ده.',
    'سبا د مولود شریف غونډه ده — والدین رابلل کېږي.',
    'ستاسو د زوی د اجازې غوښتنه ومنل شوه.',
  ];

  final rows = <MessagesCompanion>[];
  for (var i = 0; i < 140; i++) {
    final s = students[_rand.nextInt(students.length)];
    final g = guardians[_rand.nextInt(guardians.length)];
    final at = _today.subtract(Duration(days: _rand.nextInt(45)));

    // د حالتونو ګډوله — چې «بیا لېږل» او د ناکامو فلټر ډیټا ولري.
    final status = switch (i % 10) {
      0 => 'failed',
      1 => 'queued',
      2 || 3 => 'read',
      _ => 'sent',
    };

    rows.add(
      MessagesCompanion.insert(
        batchId: Value('b${at.millisecondsSinceEpoch ~/ 86400000}'),
        kind: ['absence', 'fee', 'announcement', 'leave',
          'custom'][i % 5],
        studentId: Value(s.id),
        guardianId: Value(g.id),
        toName: Value(g.fullName),
        toPhone: Value(g.phone),
        channel: Value(['app', 'sms', 'whatsapp'][i % 3]),
        body: bodies[i % bodies.length],
        status: Value(status),
        attempts: Value(status == 'failed' ? 3 : 1),
        error: Value(status == 'failed' ? 'د شبکې تېروتنه' : null),
        relatedDate: Value(at),
        createdByUserId: const Value(1),
        createdAt: Value(at),
        sentAt: Value(status == 'queued' ? null : at),
        readAt: Value(status == 'read' ? at.add(const Duration(hours: 3)) : null),
      ),
    );
  }
  await db.batch((b) => b.insertAll(db.messages, rows));

  // خبرتیاوې — مدیر ته.
  final notes = NotificationRepository(db);
  await notes.push(
    kind: 'absence_digest',
    title: 'نن ۲۳ شاګردان غیرحاضر دي',
    body: 'د سهارنۍ حاضرۍ لنډیز — ۲۳ غیرحاضر، ۹ ناوخته.',
    dedupeKey: 'digest-2026-05-14',
    now: _today,
  );
  await notes.push(
    kind: 'leave_requested',
    title: 'نوې اجازت‌نامه',
    body: 'د احمد نوري لپاره د دوو ورځو رخصت غوښتنه شوې.',
    now: _today.subtract(const Duration(days: 1)),
  );
  await notes.push(
    kind: 'fee_due',
    title: 'د فیس یادونه',
    body: '۳۸ کورنیو د ثور میاشتې فیس نه دی ورکړی.',
    now: _today.subtract(const Duration(days: 3)),
  );
  await notes.push(
    kind: 'backup',
    title: 'ورځنی بیک‌اپ بریالی و',
    body: 'د ۱۴ ثور بیک‌اپ په بریالیتوب سره ترسره شو.',
    now: _today.subtract(const Duration(days: 4)),
  );

  // وسیلې او د جوړېدو کوډونه.
  await db
      .into(db.devices)
      .insert(
        DevicesCompanion.insert(
          name: 'د مدیر ټیلیفون (Samsung A54)',
          platform: const Value('android'),
          role: 'manager',
          userId: const Value(1),
          tokenHash: 'demo-hash-manager-01',
          pushToken: const Value('demo-push-manager'),
          pairedAt: Value(_today.subtract(const Duration(days: 40))),
          lastSeenAt: Value(_today),
          lastIp: const Value('192.168.1.24'),
        ),
      );
  await db
      .into(db.devices)
      .insert(
        DevicesCompanion.insert(
          name: 'د والد ټیلیفون',
          platform: const Value('android'),
          role: 'guardian',
          guardianId: Value(guardians.first.id),
          tokenHash: 'demo-hash-guardian-01',
          pairedAt: Value(_today.subtract(const Duration(days: 12))),
          lastSeenAt: Value(_today.subtract(const Duration(days: 1))),
          lastIp: const Value('192.168.1.55'),
        ),
      );
  await db
      .into(db.pairingCodes)
      .insert(
        PairingCodesCompanion.insert(
          code: '482913',
          role: 'guardian',
          guardianId: Value(guardians[3].id),
          expiresAt: _today.add(const Duration(days: 2)),
          createdByUserId: const Value(1),
        ),
      );
}

// ═══════════════════════════════════════════════════════════
//  ۱۶ — د آی‌ډي کارتونه
// ═══════════════════════════════════════════════════════════

Future<void> _cards(
  AppDatabase db,
  List<int> teachers,
  List<int> staff,
  List<({int id, int sectionId, int gradeId})> students,
) async {
  final cards = CardRepository(db);

  // د هرې ډلې یوه کینډۍ ذخیره او فعالوو.
  for (final audience in ['student', 'teacher', 'staff']) {
    final built = builtInCardTemplates(audience);
    for (var i = 0; i < built.length; i++) {
      await cards.saveTemplate(
        name: built[i].name,
        audience: audience,
        layoutJson: built[i].layout.encode(),
        widthMm: built[i].widthMm,
        heightMm: built[i].heightMm,
        orientation: built[i].isPortrait ? 'portrait' : 'landscape',
        activate: i == 0,
      );
    }
  }

  // کارتونه صادر شوي — ځینې تر ۱۴۴۷ پورې، ځینې تېر شوي.
  await cards.issue(
    audience: 'student',
    ids: [for (final s in students.take(students.length ~/ 2)) s.id],
    expiresOn: DateTime(2026, 12, 20),
  );
  await cards.issue(
    audience: 'student',
    ids: [for (final s in students.skip(students.length ~/ 2).take(20)) s.id],
    expiresOn: DateTime(2026, 3, 20), // تېر شوی
  );
  await cards.issue(
    audience: 'teacher',
    ids: teachers,
    expiresOn: DateTime(2027, 3, 20),
  );
  await cards.issue(
    audience: 'staff',
    ids: staff.take(6).toList(),
    expiresOn: DateTime(2026, 12, 20),
  );
}

// ═══════════════════════════════════════════════════════════
//  ۱۷ — لنډیز
// ═══════════════════════════════════════════════════════════

void _report(String path) {
  final f = File(path);
  final mb = (f.lengthSync() / (1024 * 1024)).toStringAsFixed(2);

  File('$_outDir/لومړی-دا-ولولئ.txt').writeAsStringSync(_readme);

  // ignore: avoid_print
  print('\n✔ ډیټابیس جوړ شو: ${f.absolute.path}  ($mb MB)\n');
}

const _readme = '''
د ټسټ ډیټابیس — د دارالعلوم نور مدرسه
════════════════════════════════════════════════════════════

دا فایل «school.db» یو بشپړ نمونه ډیټابیس دی. نوعه يې **مدرسه**
ده او د پروګرام هره برخه پکې ډیټا لري.


۱. څنګه يې وکاروم؟
────────────────────────────────────────────────────────────
۱) زیپ پرانیزئ او «school.db» یوې پوښې ته وباسئ.
   (مثلاً:  D:\\مدرسه\\school.db)

۲) پروګرام پرانیزئ. که مخکې يې تنظیم کړی وي، له
   «تنظیمات ← ډیټابیس» څخه نوی مسیر وټاکئ.
   که د لومړي ځل لپاره وي، ویزارډ به راشي:
       • د مدرسې نوم:   د دارالعلوم نور مدرسه
       • **نوعه: مدرسه** — دا مهم دی. که «مکتب» وټاکئ،
         پروګرام به د ۱–۱۲ صنفونه هم ورزیات کړي.
       • د ډیټابیس ځای: هماغه پوښه چې «school.db» پکې دی.

۳) ننوتل — لاندې نومونه او پټ‌نومونه کار کوي.


۲. کاروونکي (هر رول یو)
────────────────────────────────────────────────────────────
   نوم         پټ‌نوم        رول
   ─────────────────────────────────────────────
   admin       admin123     مدیر (ټول واک)
   deputy      deputy123    مرستیال (+ د فیس لیدل)
   ustad       ustad123     استاد (حاضري او نمرې)
   hisab       hisab123     محاسب (فیس او معاشونه)
   daftar      daftar123    ریسیپشن
   zaher       zaher123     ← **نافعال** — د ازموینې لپاره


۳. څه پکې شته؟
────────────────────────────────────────────────────────────
   • ۱۳ درجې (ابتدائیه → دورة الحدیث)، ۱۶ بخشونه، ۸۲ فنون
     له کتابونو سره.
   • ۲۰۵ شاګردان — هلکان او انجونې، ورځني او لیلیه‌وال،
     له ۱۲ ولایتونو، له سرپرستانو سره. ځینې فارغ، لېږدېدلي،
     پرېښي یا ځنډول شوي — چې د حالت فلټر وازمویئ.
   • ۱۵ استادان (یو ړنګ شوی، یو رخصت) او ۹ کارمندان.
   • مهالویش: ۶ ساعته، **هر یو خپله اندازه**
     (۶۰/۴۵/۴۵/۴۰/۴۰/۳۰ دقیقې) + یوه تفریح.
   • حاضري: ۳ میاشتې، ۱۴٫۲۰۰ کرښې. ځینې شاګردان
     په قصد ډېر غیرحاضر دي — چې رپوټ کې څرګند شي.
   • د استادانو/کارمندانو حاضري: ۱٫۰۰۰ کرښې.
   • ۵۰ اجازت‌نامې — ځینې د تصویب په تمه، ځینې منل شوې،
     ځینې ردې شوې، او یوه ډله‌ییزه.
   • ۴ ازموینې: دوه خپرې شوې، یوه لا نمرې نه لري،
     یوه میاشتنۍ (۲۰ نمرې). ټولې ۳٫۱۷۵ نمرې.
   • فیس: ۵ ډولونه، ۱٫۴۵۶ بلونه — بشپړ ورکړل شوي، نیمګړي،
     نه‌ورکړل شوي، تخفیف لرونکي او معاف شوي.
   • معاشونه: ۳ دورې — دوه ورکړل شوې، یوه لا مسوده.
   • ۱۴۰ پیغامونه (لېږل شوي، ناکام، په کتار کې، لوستل شوي)،
     ۷ کینډۍ، ۴ خبرتیاوې، ۲ وسیلې.
   • ۱۸ د کارت کینډۍ (هرې ډلې ته ۶) او صادر شوي کارتونه —
     ځینې يې نېټه تېره ده.


۴. یادونه
────────────────────────────────────────────────────────────
دا ډیټا جوړه شوې (ساختګي) ده. نومونه، شمېرې او پته
ریښتیني نه دي — یوازې د ازموینې لپاره.

د ډیټابیس «نن» ۱۴ ثور ۱۴۰۵ (۲۰۲۶/۵/۱۴) دی. که ستاسو کمپیوټر
بله نېټه ولري، «نننۍ حاضري» به تشه ښکاري — دا سمه ده.
د رپوټونو په برخه کې نېټه بدله کړئ او ډیټا به راښکاره شي.
''';
