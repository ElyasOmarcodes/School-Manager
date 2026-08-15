import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/attendance_session_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/features/attendance/live_attendance.dart';

void main() {
  late AppDatabase db;
  late AttendanceSessionRepository sessions;
  late AttendanceRepository att;
  late StudentRepository students;

  /// سه‌شنبه، ۱۲ می ۲۰۲۶.
  DateTime at(int h, int m) => DateTime(2026, 5, 12, h, m);

  setUp(() async {
    db = AppDatabase.memory();
    sessions = AttendanceSessionRepository(db);
    att = AttendanceRepository(db);
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

  Future<int> admit(String no, String name, {String residency = 'day'}) =>
      students.admit(
        student: StudentsCompanion.insert(
          admissionNo: no,
          firstName: name,
          fatherName: 'پلار',
          gender: 'male',
          residency: Value(residency),
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        byUserId: 1,
        byUserName: 'admin',
      );

  LiveAttendance make(DateTime now) => LiveAttendance(
    sessions: sessions,
    attendance: att,
    clock: () => now,
  );

  // ═══════════════════════════════════════════════════════
  group('د ژوندیو ناستو پېژندل', () {
    test('د کړکۍ دننه ژوندۍ، بهر نه', () async {
      await sessions.create(
        name: 'سهار',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );

      final morning = make(at(7, 30));
      await morning.refresh();
      expect(morning.isLive, isTrue);
      expect(morning.live.single.name, 'سهار');

      final noon = make(at(12, 0));
      await noon.refresh();
      expect(noon.isLive, isFalse);
    });

    test('دوه ناستې کولی شي یو ځای روانې وي', () async {
      await sessions.create(
        name: 'د لیلیه شپه',
        target: 'boarding',
        startTime: '20:00',
        endTime: '21:00',
        days: '1,2,3,4,5,6,7',
      );
      await sessions.create(
        name: 'د ټولو شپه',
        startTime: '20:30',
        endTime: '20:45',
        days: '1,2,3,4,5,6,7',
      );

      final live = make(at(20, 40));
      await live.refresh();
      expect(live.live, hasLength(2));
    });

    test('بنده ناسته نه راځي', () async {
      final id = await sessions.create(
        name: 'سهار',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );
      await sessions.update(id: id, isActive: false);

      final live = make(at(7, 30));
      await live.refresh();
      expect(live.isLive, isFalse);
    });

    test('ټولټال د ټولو ژوندیو ناستو راټولوي', () async {
      await admit('1405-0001', 'احمد');
      await admit('1405-0002', 'کریم');
      await sessions.create(
        name: 'سهار',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );

      final live = make(at(7, 30));
      await live.refresh();
      expect(live.totals.target, 2);
      expect(live.totals.marked, 0);

      final all = await db.select(db.students).get();
      await att.markRoster(
        date: at(7, 30),
        statusByStudentId: {all.first.id: 'present'},
        byUserId: 1,
        sessionId: live.live.single.id,
        now: at(7, 30),
      );
      await live.refresh();
      expect(live.totals.marked, 1);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('خبرول', () {
    test('**یوازې د بدلون پر مهال خبروي**', () async {
      await admit('1405-0001', 'احمد');
      await sessions.create(
        name: 'سهار',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );

      final live = make(at(7, 30));
      var pings = 0;
      live.addListener(() => pings++);

      await live.refresh();
      expect(pings, 1, reason: 'لومړی ځل — حال بدل شو');

      await live.refresh();
      await live.refresh();
      // که هره کتنه خبرول کول، ټوله پرده به هره دقیقه له سره رسمېده
      // او د فیس پاڼه به د لیکلو پر مهال ټوپ وهه.
      expect(pings, 1, reason: 'هېڅ بدلون نه دی راغلی');

      await att.markRoster(
        date: at(7, 30),
        statusByStudentId: {
          (await db.select(db.students).get()).first.id: 'present',
        },
        byUserId: 1,
        sessionId: live.live.single.id,
        now: at(7, 35),
      );
      await live.refresh();
      expect(pings, 2, reason: 'پرمختګ بدل شو');
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د شالید سکین', () {
    test('**سکین هغې ناستې ته ځي چې شاګرد يې هدف دی**', () async {
      final dayId = await admit('1405-0001', 'نهاري', residency: 'day');
      final boardId = await admit(
        '1405-0002',
        'لیلیه',
        residency: 'boarding',
      );

      // دوه ناستې یو وخت روانې — یوه یوازې د لیلیه، بله یوازې د نهاري.
      final boarding = await sessions.create(
        name: 'د لیلیه شپه',
        target: 'boarding',
        startTime: '20:00',
        endTime: '21:00',
        days: '1,2,3,4,5,6,7',
      );
      final dayOnly = await sessions.create(
        name: 'د نهاري شپه',
        target: 'day',
        startTime: '20:00',
        endTime: '21:00',
        days: '1,2,3,4,5,6,7',
      );

      final live = make(at(20, 15));
      await live.refresh();
      expect(live.live, hasLength(2));

      await live.scan(input: '1405-0002', byUserId: 1);
      await live.scan(input: '1405-0001', byUserId: 1);

      final rows = await db.select(db.attendances).get();
      expect(rows, hasLength(2));
      // که کوره لومړۍ ناسته ټاکل کېده، دواړه به په یوه کې لوېدلي وو.
      expect(
        rows.firstWhere((r) => r.studentId == boardId).sessionId,
        boarding,
      );
      expect(rows.firstWhere((r) => r.studentId == dayId).sessionId, dayOnly);
    });

    test('که هېڅ ناسته يې هدف نه ګڼي، `null` راګرځي', () async {
      await admit('1405-0001', 'نهاري', residency: 'day');
      await sessions.create(
        name: 'د لیلیه شپه',
        target: 'boarding',
        startTime: '20:00',
        endTime: '21:00',
        days: '1,2,3,4,5,6,7',
      );

      final live = make(at(20, 15));
      await live.refresh();
      expect(await live.scan(input: '1405-0001', byUserId: 1), isNull);
      expect(await db.select(db.attendances).get(), isEmpty);
    });

    test('پرته له ژوندۍ ناستې، سکین هېڅ نه کوي', () async {
      await admit('1405-0001', 'احمد');
      final live = make(at(12, 0));
      await live.refresh();
      expect(await live.scan(input: '1405-0001', byUserId: 1), isNull);
      expect(await db.select(db.attendances).get(), isEmpty);
    });

    test('ناپېژندلی نمبر د ژوندۍ ناستې پر مهال هم پایله راګرځوي', () async {
      await sessions.create(
        name: 'سهار',
        startTime: '07:00',
        endTime: '08:30',
        days: '1,2,3,4,5,6,7',
      );
      final live = make(at(7, 30));
      await live.refresh();

      // شاګرد نشته، خو ناسته «ټول» ده — نو `isTargeted` نه پلې کېږي
      // او `checkIn` خپله «ونه پېژندل شو» راګرځوي.
      final r = await live.scan(input: '9999-9999', byUserId: 1);
      expect(r, isA<CheckInUnknown>());
    });
  });
}
