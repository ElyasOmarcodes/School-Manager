import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/attendance_session_repository.dart';
import 'package:school_manager/data/repositories/staff_attendance_repository.dart';
import 'package:school_manager/data/repositories/staff_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/data/repositories/teacher_repository.dart';
import 'package:school_manager/features/attendance/live_attendance.dart';

void main() {
  late AppDatabase db;
  late StaffAttendanceRepository staff;
  late AttendanceSessionRepository sessions;
  late AttendanceRepository att;
  late TeacherRepository teachers;
  late StaffRepository staffMembers;
  late StudentRepository students;

  /// سه‌شنبه، ۱۲ می ۲۰۲۶.
  DateTime at(int h, int m) => DateTime(2026, 5, 12, h, m);

  setUp(() async {
    db = AppDatabase.memory();
    staff = StaffAttendanceRepository(db);
    sessions = AttendanceSessionRepository(db);
    att = AttendanceRepository(db);
    teachers = TeacherRepository(db);
    staffMembers = StaffRepository(db);
    students = StudentRepository(db);

    await db.into(db.schools).insert(SchoolsCompanion.insert(name: 'ازموینه'));
    await AcademicRepository(db).seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026),
      endsOn: DateTime(2026, 12, 31),
      fromLevel: 1,
      toLevel: 2,
      sectionNames: const ['الف'],
    );
  });

  tearDown(() => db.close());

  Future<int> addTeacher(String name, {String? fingerprint}) async =>
      teachers.add(
        teacher: TeachersCompanion.insert(
          employeeNo: await teachers.nextEmployeeNo(),
          fullName: name,
          gender: 'male',
          specialization: const Value('ریاضي'),
          fingerprintId: Value(fingerprint),
        ),
        byUserId: 1,
        byUserName: 'admin',
      );

  Future<int> addStaff(String name) async => staffMembers.add(
    staff: StaffMembersCompanion.insert(
      employeeNo: await staffMembers.nextEmployeeNo(),
      fullName: name,
      gender: 'male',
      jobTitle: 'محاسب',
    ),
    byUserId: 1,
    byUserName: 'admin',
  );

  Future<int> admit(String no, String name) => students.admit(
    student: StudentsCompanion.insert(
      admissionNo: no,
      firstName: name,
      fatherName: 'پلار',
      gender: 'male',
    ),
    guardians: [
      GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
    ],
    byUserId: 1,
    byUserName: 'admin',
  );

  // ═══════════════════════════════════════════════════════
  group('د کارکوونکو لیست', () {
    test('استادان او کارمندان یو لیست جوړوي', () async {
      await addTeacher('استاد احمد');
      await addStaff('محمود محاسب');

      final all = await staff.personnel();
      expect(all, hasLength(2));
      expect(all.where((p) => p.isTeacher), hasLength(1));

      final onlyTeachers = await staff.personnel(kind: 'teacher');
      expect(onlyTeachers, hasLength(1));
      expect(onlyTeachers.single.fullName, 'استاد احمد');
    });

    test('پلټنه په نوم او کارمند نمبر دواړو کار کوي', () async {
      await addTeacher('استاد احمد');
      await addStaff('محمود محاسب');

      expect(await staff.personnel(query: 'محمود'), hasLength(1));
      expect(await staff.personnel(query: 'T-0001'), hasLength(1));
      // ختیځې شمېرې هم — کارن يې په کیبورډ لیکي.
      expect(await staff.personnel(query: 'T-۰۰۰۱'), hasLength(1));
    });

    test('د ګوتې نښه هم پېژندنه ده', () async {
      await addTeacher('استاد احمد', fingerprint: 'FP-7');
      final byFinger = await staff.findByInput('FP-7');
      expect(byFinger?.fullName, 'استاد احمد');

      final byNo = await staff.findByInput('T-0001');
      expect(byNo?.kind, 'teacher');

      expect(await staff.findByInput('1405-0001'), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('ثبت', () {
    test('دوه ځله ثبت یوه کرښه پاتې کېږي', () async {
      final id = await addTeacher('استاد احمد');

      await staff.mark(
        personKind: 'teacher',
        personId: id,
        date: at(7, 10),
        status: 'present',
      );
      await staff.mark(
        personKind: 'teacher',
        personId: id,
        date: at(7, 40),
        status: 'leave',
      );

      final rows = await db.select(db.staffAttendances).get();
      expect(rows, hasLength(1));
      expect(rows.single.status, 'leave');
    });

    test('بېلې ناستې بېلې کرښې دي', () async {
      final id = await addTeacher('استاد احمد');
      await staff.mark(
        personKind: 'teacher',
        personId: id,
        date: at(7, 10),
        status: 'present',
      );
      await staff.mark(
        personKind: 'teacher',
        personId: id,
        date: at(13, 10),
        status: 'absent',
        sessionId: 3,
      );
      expect(await db.select(db.staffAttendances).get(), hasLength(2));
    });

    test('د استاد او کارمند یو id سره نه ګډېږي', () async {
      // دواړه `id = 1` دي — که `person_kind` کلي کې نه وای، دویم
      // ثبت به لومړی له منځه وړی و.
      final t = await addTeacher('استاد احمد');
      final s = await addStaff('محمود محاسب');
      expect(t, s);

      await staff.mark(
        personKind: 'teacher',
        personId: t,
        date: at(7, 10),
        status: 'present',
      );
      await staff.mark(
        personKind: 'staff',
        personId: s,
        date: at(7, 10),
        status: 'absent',
      );

      final rows = await db.select(db.staffAttendances).get();
      expect(rows, hasLength(2));
    });

    test('د ناوخته راتګ قاعده پلې کېږي', () async {
      final id = await addTeacher('استاد احمد');
      final person = (await staff.personnel()).single;
      const rules = AttendanceRules(dayStart: '07:30');

      expect(
        await staff.checkIn(person: person, now: at(7, 25), rules: rules),
        'present',
      );
      await staff.mark(
        personKind: 'teacher',
        personId: id,
        date: at(7, 25),
        status: 'present',
      );
      expect(
        await staff.checkIn(person: person, now: at(8, 15), rules: rules),
        'late',
      );
    });

    test('لنډیز یوازې خپل کسان شمېري', () async {
      await addTeacher('استاد احمد');
      await addTeacher('استاد محمود');
      await addStaff('کارمند');
      final people = await staff.personnel();

      for (final p in people.where((p) => p.isTeacher)) {
        await staff.mark(
          personKind: p.kind,
          personId: p.id,
          date: at(7, 10),
          status: 'present',
        );
      }

      final all = await staff.summary(date: at(9, 0), sessionId: 0);
      expect(all.target, 3);
      expect(all.marked, 2);

      final justStaff = await staff.summary(
        date: at(9, 0),
        sessionId: 0,
        kind: 'staff',
      );
      expect(justStaff.target, 1);
      expect(justStaff.marked, 0);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('لیست', () {
    test('نه-ثبت شوي هم په لیست کې راځي', () async {
      await addTeacher('استاد احمد');
      await addStaff('محمود محاسب');

      final rows = await staff.roster(date: at(7, 0), sessionId: 0);
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.status == null), isTrue);
    });

    test('د حالت فلټر', () async {
      final id = await addTeacher('استاد احمد');
      await addStaff('محمود محاسب');
      await staff.mark(
        personKind: 'teacher',
        personId: id,
        date: at(7, 0),
        status: 'present',
      );

      final present = await staff.roster(
        date: at(7, 0),
        sessionId: 0,
        status: 'present',
      );
      expect(present, hasLength(1));

      final unmarked = await staff.roster(
        date: at(7, 0),
        sessionId: 0,
        status: 'unmarked',
      );
      expect(unmarked.single.person.kind, 'staff');
    });
  });

  // ═══════════════════════════════════════════════════════
  // **د کارن پوښتنه:** سهار ۷ بجې د شاګردانو حاضري هم پیل کېږي او
  // د استادانو هم. ایا یو سکینر دواړه سم مدیریت کولی شي؟
  group('سهار ۷ بجې — دوه ناستې په یوه وخت', () {
    late LiveAttendance live;

    setUp(() async {
      await addTeacher('استاد احمد');
      await addStaff('محمود محاسب');
      await admit('1405-0001', 'زلمی');

      await sessions.create(
        name: 'د شاګردانو سهار',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );
      await sessions.create(
        name: 'د کارکوونکو سهار',
        target: 'personnel',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );

      live = LiveAttendance(
        sessions: sessions,
        attendance: att,
        staff: staff,
        clock: () => at(7, 10),
      );
      await live.refresh();
      expect(live.live, hasLength(2));
    });

    test('د استاد کارت د کارکوونکو ناستې ته ځي', () async {
      final r = await live.scan(input: 'T-0001', byUserId: 1);
      expect(r, isA<PersonnelScan>());
      expect((r as PersonnelScan).person.kind, 'teacher');
      expect(r.session.name, 'د کارکوونکو سهار');

      // شاګردانو جدول ته هېڅ نه دي لیکل شوي.
      expect(await db.select(db.attendances).get(), isEmpty);
      expect(await db.select(db.staffAttendances).get(), hasLength(1));
    });

    test('د شاګرد کارت د شاګردانو ناستې ته ځي', () async {
      final r = await live.scan(input: '1405-0001', byUserId: 1);
      expect(r, isA<StudentScan>());
      expect((r as StudentScan).result, isA<CheckInOk>());

      expect(await db.select(db.attendances).get(), hasLength(1));
      expect(await db.select(db.staffAttendances).get(), isEmpty);
    });

    test('درې کارتونه پرله پسې — هر یو خپل ځای ته', () async {
      await live.scan(input: 'T-0001', byUserId: 1);
      await live.scan(input: '1405-0001', byUserId: 1);
      await live.scan(input: 'S-0001', byUserId: 1);

      expect(await db.select(db.attendances).get(), hasLength(1));
      final personnel = await db.select(db.staffAttendances).get();
      expect(personnel, hasLength(2));
      expect(personnel.map((r) => r.personKind).toSet(), {'teacher', 'staff'});
    });

    test('د ناستې هدف «یوازې استادان» وي، کارمند نه مني', () async {
      // د کارکوونکو عمومي ناسته ړنګه، پر ځای يې یوازې-استادان.
      final rows = await sessions.list();
      final personnelSession = rows.firstWhere((s) => s.target == 'personnel');
      await (db.delete(
        db.attendanceSessions,
      )..where((t) => t.id.equals(personnelSession.id))).go();
      await sessions.create(
        name: 'د استادانو سهار',
        target: 'teacher',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );
      await live.refresh();

      expect(
        await live.scan(input: 'T-0001', byUserId: 1),
        isA<PersonnelScan>(),
      );
      expect(
        await live.scan(input: 'S-0001', byUserId: 1),
        isA<NoMatchingSession>(),
      );
      expect(await db.select(db.staffAttendances).get(), hasLength(1));
    });

    test('د ناستې حال د کارکوونکو له جدوله راځي', () async {
      await live.scan(input: 'T-0001', byUserId: 1);
      final personnelSession = (await sessions.list()).firstWhere(
        (s) => s.target == 'personnel',
      );
      final st = await sessions.status(
        session: personnelSession,
        now: at(7, 20),
      );
      // دوه کسان هدف دي — یو استاد، یو کارمند.
      expect(st.targetCount, 2);
      expect(st.markedCount, 1);
      expect(st.presentCount, 1);
    });
  });
}
