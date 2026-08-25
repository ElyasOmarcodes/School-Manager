import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/utils/qr_token.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/leave_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';

void main() {
  late AppDatabase db;
  late AttendanceRepository att;
  late StudentRepository students;
  late LeaveRepository leaves;
  late AcademicRepository academic;

  /// ثابت ساعت — چې ازموینې د ریښتیني وخت پورې تړلې نه وي.
  final today = DateTime(2026, 5, 12);
  DateTime at(int h, int m) => DateTime(2026, 5, 12, h, m);

  const rules = AttendanceRules(
    dayStart: '07:30',
    lateAfterMinutes: 15,
    absentAfterMinutes: 45,
  );

  setUp(() {
    db = AppDatabase.memory();
    att = AttendanceRepository(db);
    students = StudentRepository(db);
    leaves = LeaveRepository(db);
    academic = AcademicRepository(db);
  });

  tearDown(() => db.close());

  Future<Student> admit(String no, String name) async {
    final id = await students.admit(
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
    return (db.select(db.students)..where((s) => s.id.equals(id))).getSingle();
  }

  // ═════════════════════════════════════════════════════════

  group('د وخت قواعد', () {
    test('د پیل په وخت او تر ۱۵ دقیقو پورې — حاضر', () {
      expect(rules.statusForArrival(at(7, 30)), 'present');
      expect(rules.statusForArrival(at(7, 45)), 'present');
      // مخکې راغلی هم حاضر دی.
      expect(rules.statusForArrival(at(7, 0)), 'present');
    });

    test('له ۱۵ تر ۴۵ دقیقو — ناوخته', () {
      expect(rules.statusForArrival(at(7, 46)), 'late');
      expect(rules.statusForArrival(at(8, 15)), 'late');
    });

    test('له ۴۵ دقیقو وروسته — غیرحاضر، خو راتګ ثبتېږي', () {
      expect(rules.statusForArrival(at(8, 16)), 'absent');
      expect(rules.statusForArrival(at(10, 0)), 'absent');
    });
  });

  group('سکین کول', () {
    test('لاسي آی‌ډي حاضري ثبتوي', () async {
      await admit('1405-0001', 'احمد');

      final r = await att.checkIn(
        input: '1405-0001',
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );

      expect(r, isA<CheckInOk>());
      expect((r as CheckInOk).status, 'present');

      final rows = await db.select(db.attendances).get();
      expect(rows, hasLength(1));
      // نېټه باید یوازې ورځ وي — که وخت پکې پاتې شي، یوځلي قید
      // ماتېږي او یو شاګرد به څو ځله ثبت شي.
      expect(rows.first.date, today);
      expect(rows.first.checkInAt, at(7, 35));
    });

    test('د ختیځو شمېرو آی‌ډي هم منل کېږي', () async {
      await admit('1405-0001', 'احمد');
      final r = await att.checkIn(
        input: '۱۴۰۵-۰۰۰۱',
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );
      expect(r, isA<CheckInOk>());
    });

    test('سم QR کارت منل کېږي', () async {
      final s = await admit('1405-0001', 'احمد');
      final token = QrToken.encode(
        admissionNo: s.admissionNo,
        cardVersion: s.cardVersion,
        schoolKey: s.qrSecret!,
      );

      final r = await att.checkIn(
        input: token,
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );
      expect(r, isA<CheckInOk>());
    });

    test('جعلي کارت ردېږي او هېڅ نه ثبتوي', () async {
      final s = await admit('1405-0001', 'احمد');
      // د بل ښوونځي کلي سره جوړ شوی.
      final forged = QrToken.encode(
        admissionNo: s.admissionNo,
        cardVersion: 1,
        schoolKey: QrToken.newSchoolKey(),
      );

      final r = await att.checkIn(
        input: forged,
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );

      expect(r, isA<CheckInInvalidCard>());
      expect(await db.select(db.attendances).get(), isEmpty);
    });

    test('باطل شوی کارت ردېږي — نوی کارت پکار دی', () async {
      final s = await admit('1405-0001', 'احمد');
      final oldCard = QrToken.encode(
        admissionNo: s.admissionNo,
        cardVersion: 1,
        schoolKey: s.qrSecret!,
      );

      // کارت ورک شو — باطلېږي.
      await students.revokeCard(s.id);

      final r = await att.checkIn(
        input: oldCard,
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );

      expect(r, isA<CheckInRevokedCard>());
      expect(await db.select(db.attendances).get(), isEmpty);
    });

    test('نه پېژندل شوی نمبر', () async {
      final r = await att.checkIn(
        input: '9999-9999',
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );
      expect(r, isA<CheckInUnknown>());
    });

    test('دویم سکین د وتلو وخت ثبتوي', () async {
      await admit('1405-0001', 'احمد');
      await att.checkIn(
        input: '1405-0001',
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );

      final out = await att.checkIn(
        input: '1405-0001',
        now: at(12, 30),
        byUserId: 1,
        withRules: rules,
      );

      expect(out, isA<CheckInCheckedOut>());
      final row = (await db.select(db.attendances).get()).first;
      expect(row.checkInAt, at(7, 35));
      expect(row.checkOutAt, at(12, 30));
    });

    test('درېیم سکین هېڅ نه بدلوي', () async {
      await admit('1405-0001', 'احمد');
      for (final t in [at(7, 35), at(12, 30)]) {
        await att.checkIn(
          input: '1405-0001',
          now: t,
          byUserId: 1,
          withRules: rules,
        );
      }

      final third = await att.checkIn(
        input: '1405-0001',
        now: at(12, 40),
        byUserId: 1,
        withRules: rules,
      );

      expect(third, isA<CheckInAlreadyDone>());
      // د وتلو وخت باید خراب نه شي — د دروازې پر مخ دوه‌ځلی سکین
      // عادي دی.
      final row = (await db.select(db.attendances).get()).first;
      expect(row.checkOutAt, at(12, 30));
    });
  });

  // ═════════════════════════════════════════════════════════
  //  دا هغه برخه ده چې کارن په ځانګړي ډول غوښتې وه
  // ═════════════════════════════════════════════════════════

  group('اجازت نامه له حاضرۍ سره همغږې', () {
    test('د اجازې لرونکی «رخصت» ثبتېږي، نه غیرحاضر', () async {
      final s = await admit('1405-0001', 'احمد');
      final leaveId = await leaves.request(
        studentId: s.id,
        reasonType: 'sick',
        fromDate: DateTime(2026, 5, 11),
        toDate: DateTime(2026, 5, 13),
      );
      await leaves.decide(
        leaveId: leaveId,
        approve: true,
        byUserId: 1,
        byUserName: 'admin',
      );

      final r = await att.checkIn(
        input: '1405-0001',
        now: at(9, 0), // ډېر ناوخته — عادتاً غیرحاضر
        byUserId: 1,
        withRules: rules,
      );

      expect(r, isA<CheckInOnLeave>());
      final row = (await db.select(db.attendances).get()).first;
      expect(row.status, 'leave');
      expect(row.leaveRequestId, leaveId);
    });

    test('رد شوې اجازه نه شمېرل کېږي', () async {
      final s = await admit('1405-0001', 'احمد');
      final leaveId = await leaves.request(
        studentId: s.id,
        reasonType: 'sick',
        fromDate: today,
        toDate: today,
      );
      await leaves.decide(
        leaveId: leaveId,
        approve: false,
        byUserId: 1,
        byUserName: 'admin',
      );

      final r = await att.checkIn(
        input: '1405-0001',
        now: at(9, 0),
        byUserId: 1,
        withRules: rules,
      );
      expect(r, isA<CheckInOk>());
      expect((r as CheckInOk).status, 'absent');
    });

    test('د تمې په حال اجازه لا نه شمېرل کېږي', () async {
      final s = await admit('1405-0001', 'احمد');
      await leaves.request(
        studentId: s.id,
        reasonType: 'sick',
        fromDate: today,
        toDate: today,
      );

      final r = await att.checkIn(
        input: '1405-0001',
        now: at(9, 0),
        byUserId: 1,
        withRules: rules,
      );
      expect(r, isA<CheckInOk>());
    });

    test('وروسته منل شوې اجازه د غیرحاضرۍ ریکارډ سموي', () async {
      final s = await admit('1405-0001', 'احمد');

      // شاګرد نن غیرحاضر ثبت شو.
      await att.lockDay(date: today, byUserId: 1);
      expect((await db.select(db.attendances).get()).first.status, 'absent');

      // سبا يې پلار د ناروغۍ پرچه راوړه.
      final leaveId = await leaves.request(
        studentId: s.id,
        reasonType: 'sick',
        fromDate: today,
        toDate: today,
      );
      await leaves.decide(
        leaveId: leaveId,
        approve: true,
        byUserId: 1,
        byUserName: 'admin',
      );

      // پخوانی «غیرحاضر» باید «رخصت» ته واوړي — که نه، د میاشتې
      // رپوټ به غلط پاتې شي.
      final row = (await db.select(db.attendances).get()).first;
      expect(row.status, 'leave');
      expect(row.leaveRequestId, leaveId);
    });
  });

  group('د ورځې بندول', () {
    test('نه ثبت شوي غیرحاضر ګڼل کېږي', () async {
      await admit('1405-0001', 'احمد');
      await admit('1405-0002', 'کریم');
      await admit('1405-0003', 'زرغونه');

      // یوازې یو راغی.
      await att.checkIn(
        input: '1405-0001',
        now: at(7, 35),
        byUserId: 1,
        withRules: rules,
      );

      final absent = await att.lockDay(date: today, byUserId: 1);
      expect(absent, 2);

      final summary = await att.summary(today);
      expect(summary.present, 1);
      expect(summary.absent, 2);
      expect(summary.unmarked, 0);
    });

    test('د اجازې لرونکي «رخصت» پاتې کېږي، نه غیرحاضر', () async {
      final a = await admit('1405-0001', 'احمد');
      await admit('1405-0002', 'کریم');

      final leaveId = await leaves.request(
        studentId: a.id,
        reasonType: 'travel',
        fromDate: today,
        toDate: today,
      );
      await leaves.decide(
        leaveId: leaveId,
        approve: true,
        byUserId: 1,
        byUserName: 'admin',
      );

      final absent = await att.lockDay(date: today, byUserId: 1);
      // یوازې کریم غیرحاضر — احمد رخصت دی.
      expect(absent, 1);

      final summary = await att.summary(today);
      expect(summary.onLeave, 1);
      expect(summary.absent, 1);
    });

    test('دوه ځله بندول ریکارډونه نه تکراروي', () async {
      await admit('1405-0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);
      final second = await att.lockDay(date: today, byUserId: 1);

      expect(second, 0);
      expect(await db.select(db.attendances).get(), hasLength(1));
    });
  });

  group('غیرحاضران او خبرتیا', () {
    test('لیست د میاشتنۍ غیرحاضرۍ په ترتیب راځي', () async {
      final a = await admit('1405-0001', 'احمد');
      await admit('1405-0002', 'کریم');

      // احمد پخوا هم دوه ورځې غیرحاضر و.
      for (final d in [DateTime(2026, 5, 5), DateTime(2026, 5, 6)]) {
        await db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: a.id,
                date: d,
                status: 'absent',
              ),
            );
      }

      await att.lockDay(date: today, byUserId: 1);
      final list = await att.absentees(today);

      expect(list, hasLength(2));
      // احمد لومړی — درې ځله غیرحاضر، نو مدیر لومړی هغه ګوري.
      expect(list.first.student.admissionNo, '1405-0001');
      expect(list.first.monthlyAbsences, 3);
    });

    test('د پیغام له لېږلو وروسته بیا نه راځي', () async {
      final a = await admit('1405-0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);

      expect(await att.absentees(today, onlyUnnotified: true), hasLength(1));

      await att.markNotified(date: today, studentIds: [a.id]);

      // دوه ځله پیغام نه ځي.
      expect(await att.absentees(today, onlyUnnotified: true), isEmpty);
      // خو په بشپړ لیست کې لا هم شته.
      expect(await att.absentees(today), hasLength(1));
    });
  });

  group('د ټولګي لیست', () {
    Future<int> seedSection() async {
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026, 1, 1),
        endsOn: DateTime(2026, 12, 31),
        fromLevel: 10,
        toLevel: 10,
      );
      return (await academic.sections()).first.sectionId;
    }

    test('د بخش شاګردان له حالت سره راځي', () async {
      final sectionId = await seedSection();
      final year = (await academic.currentYear())!.id;

      for (var i = 1; i <= 3; i++) {
        final id = await students.admit(
          student: StudentsCompanion.insert(
            admissionNo: '1405-000$i',
            firstName: 'شاګرد$i',
            fatherName: 'پلار',
            gender: 'male',
          ),
          guardians: [
            GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
          ],
          sectionId: sectionId,
          academicYearId: year,
          rollNo: i,
          byUserId: 1,
          byUserName: 'admin',
        );
        if (i == 1) {
          await att.checkIn(
            input: '1405-000$i',
            now: at(7, 35),
            byUserId: 1,
            withRules: rules,
          );
        }
        expect(id, greaterThan(0));
      }

      final roster = await att.roster(sectionId: sectionId, date: today);
      expect(roster, hasLength(3));
      expect(roster.first.rollNo, 1);
      expect(roster.first.status, 'present');
      expect(roster[1].status, isNull);
    });

    test('ډله‌ییز ثبت د اجازې کتنه هم کوي', () async {
      final sectionId = await seedSection();
      final year = (await academic.currentYear())!.id;

      final ids = <int>[];
      for (var i = 1; i <= 2; i++) {
        ids.add(
          await students.admit(
            student: StudentsCompanion.insert(
              admissionNo: '1405-000$i',
              firstName: 'شاګرد$i',
              fatherName: 'پلار',
              gender: 'male',
            ),
            guardians: [
              GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
            ],
            sectionId: sectionId,
            academicYearId: year,
            byUserId: 1,
            byUserName: 'admin',
          ),
        );
      }

      final leaveId = await leaves.request(
        studentId: ids.first,
        reasonType: 'sick',
        fromDate: today,
        toDate: today,
      );
      await leaves.decide(
        leaveId: leaveId,
        approve: true,
        byUserId: 1,
        byUserName: 'admin',
      );

      // استاد دواړه «غیرحاضر» نښه کوي — د اجازې نه دی خبر.
      await att.markRoster(
        sectionId: sectionId,
        date: today,
        statusByStudentId: {ids[0]: 'absent', ids[1]: 'absent'},
        byUserId: 1,
      );

      final summary = await att.summary(today);
      // سیسټم پوهېږي: لومړی رخصت دی، دویم غیرحاضر.
      expect(summary.onLeave, 1);
      expect(summary.absent, 1);
    });

    test('ډله‌ییز ثبت دوه ځله ریکارډ نه جوړوي', () async {
      final sectionId = await seedSection();
      final year = (await academic.currentYear())!.id;
      final id = await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0001',
          firstName: 'احمد',
          fatherName: 'پلار',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        sectionId: sectionId,
        academicYearId: year,
        byUserId: 1,
        byUserName: 'admin',
      );

      await att.markRoster(
        sectionId: sectionId,
        date: today,
        statusByStudentId: {id: 'absent'},
        byUserId: 1,
      );
      // استاد تېروتنه سموي.
      await att.markRoster(
        sectionId: sectionId,
        date: today,
        statusByStudentId: {id: 'present'},
        byUserId: 1,
      );

      final rows = await db.select(db.attendances).get();
      expect(rows, hasLength(1));
      expect(rows.first.status, 'present');
    });
  });

  group('میاشتنی لنډیز', () {
    test('د حالتونو شمېر راګرځوي', () async {
      final s = await admit('1405-0001', 'احمد');
      final data = {
        DateTime(2026, 5, 1): 'present',
        DateTime(2026, 5, 2): 'present',
        DateTime(2026, 5, 3): 'absent',
        DateTime(2026, 5, 4): 'late',
        // بله میاشت — نه باید وشمېرل شي.
        DateTime(2026, 6, 1): 'present',
      };
      for (final e in data.entries) {
        await db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: s.id,
                date: e.key,
                status: e.value,
              ),
            );
      }

      final m = await att.monthlyBreakdown(
        studentId: s.id,
        month: DateTime(2026, 5, 1),
      );
      expect(m['present'], 2);
      expect(m['absent'], 1);
      expect(m['late'], 1);
    });
  });

  group('د اجازو لیست', () {
    test('د تمې په حال کې غوښتنې راځي، له شاګرد سره', () async {
      final s = await admit('1405-0001', 'احمد');
      await leaves.request(
        studentId: s.id,
        reasonType: 'family',
        fromDate: today,
        toDate: today.add(const Duration(days: 2)),
      );

      final page = await leaves.list(status: 'pending');
      expect(page.total, 1);

      final row = page.items.first;
      // د `JOIN` له امله د دواړو جدولونو `id` سره ګډېږي — دلته
      // ازمویو چې د شاګرد ریکارډ سم جوړ شوی، نه د اجازې.
      expect(row.student.id, s.id);
      expect(row.student.firstName, 'احمد');
      expect(row.request.studentId, s.id);
      expect(row.days, 3);
    });

    test('د تمې شمېر', () async {
      final s = await admit('1405-0001', 'احمد');
      expect(await leaves.pendingCount(), 0);

      final id = await leaves.request(
        studentId: s.id,
        reasonType: 'sick',
        fromDate: today,
        toDate: today,
      );
      expect(await leaves.pendingCount(), 1);

      await leaves.decide(
        leaveId: id,
        approve: true,
        byUserId: 1,
        byUserName: 'admin',
      );
      expect(await leaves.pendingCount(), 0);
    });
  });
}
