import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/attendance_session_repository.dart';
import 'package:school_manager/data/repositories/leave_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';

void main() {
  late AppDatabase db;
  late AttendanceSessionRepository sessions;
  late AttendanceRepository att;
  late StudentRepository students;
  late AcademicRepository academic;

  /// ثابت ساعت — سه‌شنبه، ۱۲ می ۲۰۲۶.
  final today = DateTime(2026, 5, 12);
  DateTime at(int h, int m) => DateTime(2026, 5, 12, h, m);

  setUp(() async {
    db = AppDatabase.memory();
    sessions = AttendanceSessionRepository(db);
    att = AttendanceRepository(db);
    students = StudentRepository(db);
    academic = AcademicRepository(db);

    await db
        .into(db.schools)
        .insert(SchoolsCompanion.insert(name: 'ازموینه'));
    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026),
      endsOn: DateTime(2026, 12, 31),
      fromLevel: 1,
      toLevel: 3,
      sectionNames: const ['الف'],
    );
  });

  tearDown(() => db.close());

  Future<int> admit(
    String no,
    String name, {
    String residency = 'day',
    int? sectionId,
  }) async {
    final year = await academic.currentYear();
    return students.admit(
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
      sectionId: sectionId,
      academicYearId: sectionId == null ? null : year!.id,
      byUserId: 1,
      byUserName: 'admin',
    );
  }

  // ═══════════════════════════════════════════════════════
  group('د ناستې وخت', () {
    AttendanceSession make({
      String start = '07:00',
      String end = '08:30',
      String days = '1,2,3,4,5,6,7',
      bool active = true,
    }) => AttendanceSession(
      id: 1,
      name: 'ازموینه',
      target: 'all',
      startTime: start,
      endTime: end,
      days: days,
      isActive: active,
      isDefault: false,
      createdAt: today,
    );

    test('د کړکۍ دننه ژوندۍ ده، بهر نه', () {
      final s = make();
      expect(AttendanceSessionRepository.isLiveAt(s, at(7, 30)), isTrue);
      expect(AttendanceSessionRepository.isLiveAt(s, at(6, 59)), isFalse);
      expect(AttendanceSessionRepository.isLiveAt(s, at(8, 31)), isFalse);
      // پولې پخپله شاملې دي.
      expect(AttendanceSessionRepository.isLiveAt(s, at(7, 0)), isTrue);
      expect(AttendanceSessionRepository.isLiveAt(s, at(8, 30)), isTrue);
    });

    test('**د نیمې شپې تېرېدونکې کړکۍ** هم کار کوي', () {
      // د لیلیه د شپې حاضري — ۲۲:۳۰ تر ۰۰:۳۰.
      final s = make(start: '22:30', end: '00:30');
      expect(AttendanceSessionRepository.isLiveAt(s, at(23, 0)), isTrue);
      expect(AttendanceSessionRepository.isLiveAt(s, at(0, 15)), isTrue);
      expect(AttendanceSessionRepository.isLiveAt(s, at(22, 29)), isFalse);
      expect(AttendanceSessionRepository.isLiveAt(s, at(0, 31)), isFalse);
      expect(AttendanceSessionRepository.isLiveAt(s, at(12, 0)), isFalse);
    });

    test('د بندې ناستې لپاره هېڅکله ژوندۍ نه ده', () {
      expect(
        AttendanceSessionRepository.isLiveAt(make(active: false), at(7, 30)),
        isFalse,
      );
    });

    test('یوازې په ټاکل شوو ورځو کې', () {
      // ۱۲ می ۲۰۲۶ سه‌شنبه ده — د Dart په شمېر ۲.
      expect(today.weekday, 2);
      expect(
        AttendanceSessionRepository.isLiveAt(make(days: '2'), at(7, 30)),
        isTrue,
      );
      expect(
        AttendanceSessionRepository.isLiveAt(make(days: '6,7'), at(7, 30)),
        isFalse,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  group('هدف', () {
    test('یوازې لیلیه شاګردان راځي', () async {
      await admit('1405-0001', 'نهاري', residency: 'day');
      await admit('1405-0002', 'لیلیه', residency: 'boarding');

      final id = await sessions.create(
        name: 'د شپې حاضري',
        target: 'boarding',
        startTime: '20:00',
        endTime: '20:30',
      );
      final s = await sessions.byId(id);

      final roster = await sessions.roster(session: s, date: today);
      expect(roster, hasLength(1));
      expect(roster.first.student.firstName, 'لیلیه');
    });

    test('د یوې درجې هدف یوازې د هغې شاګردان راوړي', () async {
      final all = await academic.sections();
      await admit('1405-0001', 'لومړی', sectionId: all[0].sectionId);
      await admit('1405-0002', 'دویم', sectionId: all[1].sectionId);

      final id = await sessions.create(
        name: 'د دویم درجې',
        target: 'grade',
        gradeId: all[1].gradeId,
      );
      final s = await sessions.byId(id);

      final roster = await sessions.roster(session: s, date: today);
      expect(roster, hasLength(1));
      expect(roster.first.student.firstName, 'دویم');
    });

    test('**د هدف بدلون زوړ تړاو پاکوي**', () async {
      final all = await academic.sections();
      final id = await sessions.create(
        name: 'ازموینه',
        target: 'grade',
        gradeId: all[0].gradeId,
      );
      await sessions.update(id: id, target: 'all');

      final s = await sessions.byId(id);
      // که پاک شوی نه وای، «ټول» ناسته به لا هم یوه درجه یاده
      // ساتله او د بیا-بدلولو پر مهال به زوړ هدف راستون شوی و.
      expect(s!.gradeId, isNull);
      expect(s.target, 'all');
    });

    test('د یوې ناستې هدف نه دی — سکینر يې رد کوي', () async {
      final dayId = await admit('1405-0001', 'نهاري', residency: 'day');
      final boardId = await admit('1405-0002', 'لیلیه', residency: 'boarding');

      final id = await sessions.create(name: 'شپه', target: 'boarding');
      final s = await sessions.byId(id);

      expect(
        await sessions.isTargeted(session: s, studentId: boardId),
        isTrue,
      );
      expect(await sessions.isTargeted(session: s, studentId: dayId), isFalse);
      // د ورځې عمومي حاضري هر څوک مني.
      expect(
        await sessions.isTargeted(session: null, studentId: dayId),
        isTrue,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د ناستو جلاوالی', () {
    test('**سهارنۍ او ماښامنۍ حاضري یو بل نه بدلوي**', () async {
      final id = await admit('1405-0001', 'احمد', residency: 'boarding');
      final night = await sessions.create(name: 'شپه', target: 'boarding');

      // سهار — د ورځې عمومي حاضري.
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: at(7, 30),
      );
      // ماښام — د شپې ناسته، غیرحاضر.
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'absent'},
        byUserId: 1,
        sessionId: night,
        now: at(20, 10),
      );

      final rows = await db.select(db.attendances).get();
      expect(rows, hasLength(2), reason: 'دوه بېلې ناستې، دوه بېل ریکارډونه');
      expect(
        rows.firstWhere((r) => r.sessionId == 0).status,
        'present',
      );
      expect(
        rows.firstWhere((r) => r.sessionId == night).status,
        'absent',
      );
    });

    test('په یوه ناسته کې دویم ثبت زوړ سموي، نه چې نوی جوړ کړي', () async {
      final id = await admit('1405-0001', 'احمد');

      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'absent'},
        byUserId: 1,
        now: at(8, 0),
      );
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: at(8, 5),
      );

      final rows = await db.select(db.attendances).get();
      expect(rows, hasLength(1));
      expect(rows.first.status, 'present');
    });

    test('لنډیز یوازې د خپلې ناستې شمېري', () async {
      final id = await admit('1405-0001', 'احمد', residency: 'boarding');
      final night = await sessions.create(name: 'شپه', target: 'boarding');

      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: at(7, 30),
      );

      expect((await att.summary(today)).present, 1);
      expect((await att.summary(today, sessionId: night)).present, 0);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('لاسي نښه کول', () {
    test('**«رخصت» د اجازت‌نامو ډیټابیس ته هم لیکل کېږي**', () async {
      final id = await admit('1405-0001', 'احمد');

      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'leave'},
        byUserId: 3,
        recordLeave: true,
        now: at(8, 0),
      );

      final leaves = await db.select(db.leaveRequests).get();
      expect(leaves, hasLength(1));
      expect(leaves.first.status, 'approved');
      expect(leaves.first.studentId, id);
      expect(leaves.first.fromDate, today);
      expect(leaves.first.toDate, today);

      // د حاضرۍ کرښه هم ورسره تړل شوې ده — که نه، د میاشتې رپوټ
      // به «رخصت» ښوده خو سبب به يې نه درلود.
      final a = await db.select(db.attendances).getSingle();
      expect(a.status, 'leave');
      expect(a.leaveRequestId, leaves.first.id);
    });

    test('که اجازه لا شته، دویمه نه جوړېږي', () async {
      final id = await admit('1405-0001', 'احمد');
      await LeaveRepository(db).requestBulk(
        studentIds: [id],
        reasonType: 'sick',
        fromDate: today,
        toDate: today,
        autoApprove: true,
        now: at(6, 0),
      );

      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'leave'},
        byUserId: 1,
        recordLeave: true,
        now: at(8, 0),
      );

      expect(await db.select(db.leaveRequests).get(), hasLength(1));
    });

    test('پرته له `recordLeave`، اجازت‌نامه نه جوړېږي', () async {
      final id = await admit('1405-0001', 'احمد');
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'leave'},
        byUserId: 1,
        now: at(8, 0),
      );
      expect(await db.select(db.leaveRequests).get(), isEmpty);
    });

    test('**منل‌شوې اجازه د «غیرحاضر» نښه ماتوي، خو نه د «حاضر»**', () async {
      final id = await admit('1405-0001', 'احمد');
      await LeaveRepository(db).requestBulk(
        studentIds: [id],
        reasonType: 'travel',
        fromDate: today,
        toDate: today,
        autoApprove: true,
        now: at(6, 0),
      );

      // مدیر «غیرحاضر» ټاکي — خو اجازه لري، نو «رخصت» ثبتېږي.
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'absent'},
        byUserId: 1,
        now: at(8, 0),
      );
      expect((await db.select(db.attendances).getSingle()).status, 'leave');

      // خو که مدیر «حاضر» ووايي، دا يې پرېکړه ده — شاګرد د اجازې
      // سره سره راغلی.
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: at(8, 5),
      );
      expect((await db.select(db.attendances).getSingle()).status, 'present');
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د لیست فلټرونه', () {
    setUp(() async {
      final all = await academic.sections();
      await admit(
        '1405-0001',
        'احمد',
        residency: 'boarding',
        sectionId: all[0].sectionId,
      );
      await admit(
        '1405-0002',
        'محمود',
        residency: 'day',
        sectionId: all[0].sectionId,
      );
      await admit(
        '1405-0003',
        'کریم',
        residency: 'day',
        sectionId: all[1].sectionId,
      );
    });

    test('د نوم لټون', () async {
      final r = await sessions.roster(
        date: today,
        filter: const RosterFilter(query: 'کریم'),
      );
      expect(r, hasLength(1));
      expect(r.first.student.firstName, 'کریم');
    });

    test('د درجې فلټر', () async {
      final all = await academic.sections();
      final r = await sessions.roster(
        date: today,
        filter: RosterFilter(gradeId: all[0].gradeId),
      );
      expect(r, hasLength(2));
    });

    test('د استوګنې فلټر', () async {
      final r = await sessions.roster(
        date: today,
        filter: const RosterFilter(residency: 'boarding'),
      );
      expect(r, hasLength(1));
      expect(r.first.student.firstName, 'احمد');
    });

    test('«نه‌نښه‌شوي» یوازې هغه راوړي چې ریکارډ نه لري', () async {
      final rows = await sessions.roster(date: today);
      await att.markRoster(
        date: today,
        statusByStudentId: {rows.first.student.id: 'present'},
        byUserId: 1,
        now: at(8, 0),
      );

      final unmarked = await sessions.roster(
        date: today,
        filter: const RosterFilter(status: 'unmarked'),
      );
      expect(unmarked, hasLength(2));

      final present = await sessions.roster(
        date: today,
        filter: const RosterFilter(status: 'present'),
      );
      expect(present, hasLength(1));
    });

    test('لنډیز د هدف او د ثبت شویو شمېر ښیي', () async {
      final rows = await sessions.roster(date: today);
      await att.markRoster(
        date: today,
        statusByStudentId: {rows.first.student.id: 'present'},
        byUserId: 1,
        now: at(8, 0),
      );

      final st = await sessions.status(now: at(8, 30));
      expect(st.targetCount, 3);
      expect(st.markedCount, 1);
      expect(st.presentCount, 1);
      expect(st.pending, 2);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د ناستو اداره', () {
    test('تلواله ناسته یوازې یو ځل جوړېږي', () async {
      await sessions.seedDefault();
      await sessions.seedDefault();
      final list = await sessions.list();
      expect(list, hasLength(1));
      expect(list.first.isDefault, isTrue);
    });

    test('**تلواله ناسته د صفر ریکارډونه خپل ګڼي**', () async {
      // تلواله ناسته د کرښې `id` لري (۱)، خو سکینر او زوړ ډیټا
      // دواړه صفر لیکي. که دا دوه سره نه تړل کېدل، د تلوالې ناستې
      // کارت به تل «۰ له ۸۵۰ ثبت شوي» ښودل.
      await sessions.seedDefault();
      final def = (await sessions.list()).single;
      expect(def.id, isNot(0), reason: 'د کرښې id صفر نه دی');
      expect(def.storageId, 0, reason: 'خو حاضري يې پر صفر ثبتېږي');

      final id = await admit('1405-0001', 'احمد');
      await att.markRoster(
        date: today,
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: at(7, 30),
      );

      final st = await sessions.status(session: def, now: at(7, 30));
      expect(st.markedCount, 1);
      expect(st.presentCount, 1);

      final roster = await sessions.roster(session: def, date: today);
      expect(roster.single.status, 'present');
    });

    test('نورې ناستې خپل id ساتي', () async {
      final id = await sessions.create(name: 'شپه', target: 'boarding');
      final s = await sessions.byId(id);
      expect(s!.storageId, id);
    });

    test('ړنګول = پټول — تېره حاضري پاتې کېږي', () async {
      final id = await sessions.create(name: 'شپه');
      await sessions.remove(id, at: today);

      expect(await sessions.list(), isEmpty);
      // کرښه لا په ډیټابیس کې ده — که ړنګه شوې وای، د تېرو ورځو
      // رپوټ به بې‌نومه ناستې ښودلې.
      expect(await sessions.byId(id), isNotNull);
    });
  });
}
