import 'dart:io';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/utils/photo_store.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';

void main() {
  late AppDatabase db;
  late StudentRepository students;
  late AcademicRepository academic;

  final today = DateTime(2026, 5, 12);

  setUp(() async {
    db = AppDatabase.memory();
    students = StudentRepository(db);
    academic = AcademicRepository(db);

    await db.into(db.schools).insert(SchoolsCompanion.insert(name: 'ازموینه'));
    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026),
      endsOn: DateTime(2026, 12, 31),
      fromLevel: 1,
      toLevel: 2,
      sectionNames: const ['الف', 'ب'],
    );
  });

  tearDown(() => db.close());

  // ═══════════════════════════════════════════════════════
  group('ډله‌ییزه نوم لیکنه', () {
    test('درې خانې بس دي — نمبرونه پرله‌پسې ورکوي', () async {
      final year = await academic.currentYear();
      final made = await students.bulkAdmit(
        rows: const [
          (firstName: 'احمد', fatherName: 'محمود', sectionId: null),
          (firstName: 'کریم', fatherName: 'رحیم', sectionId: null),
          (firstName: 'زلمی', fatherName: 'ګل', sectionId: null),
        ],
        academicYearId: year!.id,
        yearPrefix: '1405',
        byUserId: 1,
        byUserName: 'admin',
      );

      expect(made, 3);
      final all = await db.select(db.students).get();
      expect(all.map((s) => s.admissionNo).toList(), [
        '1405-0001',
        '1405-0002',
        '1405-0003',
      ]);
    });

    test('**د موجودو نمبرونو وروسته دوام کوي**', () async {
      final year = await academic.currentYear();
      await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0007',
          firstName: 'زوړ',
          fatherName: 'پلار',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        byUserId: 1,
        byUserName: 'admin',
      );

      await students.bulkAdmit(
        rows: const [
          (firstName: 'نوی', fatherName: 'پلار', sectionId: null),
        ],
        academicYearId: year!.id,
        yearPrefix: '1405',
        byUserId: 1,
        byUserName: 'admin',
      );

      final fresh = await students.byAdmissionNo('1405-0008');
      expect(fresh, isNotNull, reason: 'د زاړه وروسته، نه پرې باندې');
    });

    test('نیمګړې کرښې پرېښودل کېږي', () async {
      final year = await academic.currentYear();
      final made = await students.bulkAdmit(
        rows: const [
          (firstName: 'احمد', fatherName: 'محمود', sectionId: null),
          (firstName: '', fatherName: 'رحیم', sectionId: null),
          (firstName: 'زلمی', fatherName: '  ', sectionId: null),
          (firstName: '  ', fatherName: '  ', sectionId: null),
        ],
        academicYearId: year!.id,
        yearPrefix: '1405',
        byUserId: 1,
        byUserName: 'admin',
      );
      expect(made, 1);
      expect(await db.select(db.students).get(), hasLength(1));
    });

    test('سرپرست پخپله جوړېږي — یوازې ټیلیفون پاتې وي', () async {
      final year = await academic.currentYear();
      await students.bulkAdmit(
        rows: const [
          (firstName: 'احمد', fatherName: 'محمود', sectionId: null),
        ],
        academicYearId: year!.id,
        yearPrefix: '1405',
        byUserId: 1,
        byUserName: 'admin',
      );

      final g = await db.select(db.guardians).getSingle();
      expect(g.fullName, 'محمود');
      expect(g.relation, 'father');
      expect(g.phone, isNull);

      final link = await db.select(db.studentGuardians).getSingle();
      expect(link.isPrimary, isTrue);
    });

    test('د ټولګي ثبت هم کېږي', () async {
      final year = await academic.currentYear();
      final section = (await academic.sections()).first;

      await students.bulkAdmit(
        rows: [
          (
            firstName: 'احمد',
            fatherName: 'محمود',
            sectionId: section.sectionId,
          ),
        ],
        academicYearId: year!.id,
        yearPrefix: '1405',
        byUserId: 1,
        byUserName: 'admin',
      );

      final e = await db.select(db.enrollments).getSingle();
      expect(e.sectionId, section.sectionId);
      expect(e.isActive, isTrue);
    });

    test('هر شاګرد خپل QR کلید اخلي', () async {
      final year = await academic.currentYear();
      await students.bulkAdmit(
        rows: const [
          (firstName: 'یو', fatherName: 'پلار', sectionId: null),
          (firstName: 'دوه', fatherName: 'پلار', sectionId: null),
        ],
        academicYearId: year!.id,
        yearPrefix: '1405',
        byUserId: 1,
        byUserName: 'admin',
      );

      final all = await db.select(db.students).get();
      expect(all.every((s) => s.qrSecret != null), isTrue);
      expect(all.map((s) => s.qrSecret).toSet(), hasLength(2));
    });

    test('تشه لیسټ هېڅ نه جوړوي', () async {
      final year = await academic.currentYear();
      expect(
        await students.bulkAdmit(
          rows: const [],
          academicYearId: year!.id,
          yearPrefix: '1405',
          byUserId: 1,
          byUserName: 'admin',
        ),
        0,
      );
      expect(await db.select(db.auditLogs).get(), isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('نیمګړی پروفایل', () {
    Future<int> plain(String no, String name) async {
      final year = await academic.currentYear();
      return students.bulkAdmit(
        rows: [(firstName: name, fatherName: 'پلار', sectionId: null)],
        academicYearId: year!.id,
        yearPrefix: no,
        byUserId: 1,
        byUserName: 'admin',
      );
    }

    test('**ډله‌ییز ثبت شوی شاګرد نیمګړی دی**', () async {
      await plain('1405', 'احمد');
      final page = await students.list(
        filter: const StudentFilter(onlyIncomplete: true),
      );
      expect(page.total, 1);
    });

    test('بشپړ شوی پروفایل له فلټر څخه وځي', () async {
      await plain('1405', 'احمد');
      final s = (await db.select(db.students).get()).single;

      await students.updateProfile(
        id: s.id,
        byUserId: 1,
        byUserName: 'admin',
        patch: StudentsCompanion(
          birthDate: Value(DateTime(2012, 5, 14)),
          province: const Value('قندهار'),
          district: const Value('دامان'),
          photoPath: const Value('/tmp/x.jpg'),
        ),
      );
      await students.upsertPrimaryGuardian(
        studentId: s.id,
        fullName: 'پلار',
        relation: 'father',
        phone: '0701234567',
      );

      final page = await students.list(
        filter: const StudentFilter(onlyIncomplete: true),
      );
      expect(page.total, 0);

      final profile = await students.profile(s.id);
      expect(profile!.isComplete, isTrue);
      expect(profile.missingFields, isEmpty);
    });

    test('د سرپرست تش ټیلیفون بشپړ نه ګڼل کېږي', () async {
      await plain('1405', 'احمد');
      final s = (await db.select(db.students).get()).single;

      await students.updateProfile(
        id: s.id,
        byUserId: 1,
        byUserName: 'admin',
        patch: StudentsCompanion(
          birthDate: Value(DateTime(2012)),
          province: const Value('قندهار'),
          district: const Value('دامان'),
          photoPath: const Value('/tmp/x.jpg'),
        ),
      );
      // ټیلیفون تش پرېږدو.
      await students.upsertPrimaryGuardian(
        studentId: s.id,
        fullName: 'پلار',
        relation: 'father',
        phone: '',
      );

      final page = await students.list(
        filter: const StudentFilter(onlyIncomplete: true),
      );
      expect(page.total, 1);
      expect(
        (await students.profile(s.id))!.missingFields,
        contains('د سرپرست ټیلیفون'),
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د سکونت فلټرونه', () {
    setUp(() async {
      Future<void> add(
        String no,
        String name, {
        String? province,
        String? district,
        String residency = 'day',
      }) => students.admit(
        student: StudentsCompanion.insert(
          admissionNo: no,
          firstName: name,
          fatherName: 'پلار',
          gender: 'male',
          province: Value(province),
          district: Value(district),
          residency: Value(residency),
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        byUserId: 1,
        byUserName: 'admin',
      );

      await add(
        '1405-0001',
        'احمد',
        province: 'پکتیا',
        district: 'زرمت',
        residency: 'boarding',
      );
      await add('1405-0002', 'کریم', province: 'پکتیا', district: 'ګردیز');
      await add('1405-0003', 'زلمی', province: 'قندهار', district: 'دامان');
    });

    test('د ولایت فلټر', () async {
      final page = await students.list(
        filter: const StudentFilter(province: 'پکتیا'),
      );
      expect(page.total, 2);
    });

    test('د ولسوالۍ فلټر', () async {
      final page = await students.list(
        filter: const StudentFilter(province: 'پکتیا', district: 'زرمت'),
      );
      expect(page.total, 1);
      expect(page.items.first.student.firstName, 'احمد');
    });

    test('د استوګنې فلټر', () async {
      final page = await students.list(
        filter: const StudentFilter(residency: 'boarding'),
      );
      expect(page.total, 1);
    });

    test('**د ولایت بدلون ولسوالۍ پاکوي**', () {
      const f = StudentFilter(province: 'پکتیا', district: 'زرمت');
      // که پاکه شوې نه وای، د قندهار سره به «زرمت» پاتې و او
      // لیسټ به تل تش و.
      expect(f.copyWith(province: 'قندهار').district, isNull);
      expect(f.copyWith(clearProvince: true).district, isNull);
    });

    test('د فلټرونو شمېر د «پاک کړه» تڼۍ ښیي', () {
      const f = StudentFilter();
      expect(f.activeCount, 0);
      expect(
        f.copyWith(province: 'پکتیا', residency: 'boarding').activeCount,
        2,
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د پروفایل حاضري', () {
    test('د میاشتې جدول ورځ‌په‌ورځ حالت راوړي', () async {
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
        byUserId: 1,
        byUserName: 'admin',
      );

      final att = AttendanceRepository(db);
      await att.markRoster(
        date: DateTime(2026, 5, 3),
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: today,
      );
      await att.markRoster(
        date: DateTime(2026, 5, 4),
        statusByStudentId: {id: 'absent'},
        byUserId: 1,
        now: today,
      );
      // بله میاشت — باید په دې جدول کې ونه ښکاري.
      await att.markRoster(
        date: DateTime(2026, 6, 3),
        statusByStudentId: {id: 'present'},
        byUserId: 1,
        now: today,
      );

      final grid = await students.attendanceGrid(
        studentId: id,
        month: DateTime(2026, 5),
      );
      expect(grid, {3: 'present', 4: 'absent'});
    });

    test('لاسي سمون زوړ ریکارډ بدلوي او تفتیش لیکي', () async {
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
        byUserId: 1,
        byUserName: 'admin',
      );

      await students.setAttendance(
        studentId: id,
        date: DateTime(2026, 5, 3),
        status: 'absent',
        byUserId: 4,
        now: today,
      );
      await students.setAttendance(
        studentId: id,
        date: DateTime(2026, 5, 3),
        status: 'present',
        byUserId: 4,
        now: today,
      );

      final rows = await db.select(db.attendances).get();
      expect(rows, hasLength(1));
      expect(rows.first.status, 'present');
      expect(rows.first.method, 'manual');

      final audit = await (db.select(
        db.auditLogs,
      )..where((a) => a.entity.equals('attendance'))).get();
      expect(audit, hasLength(2));
      expect(audit.first.userId, 4);
    });

    test('کلنی لنډیز میاشت‌په‌میاشت راټولوي', () async {
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
        byUserId: 1,
        byUserName: 'admin',
      );

      for (var d = 1; d <= 5; d++) {
        await students.setAttendance(
          studentId: id,
          date: DateTime(2026, 5, d),
          status: d <= 3 ? 'present' : 'absent',
          byUserId: 1,
          now: today,
        );
      }

      final rollup = await students.yearlyRollup(studentId: id, year: 2026);
      final may = rollup.firstWhere((r) => r.month == 5);
      expect(may.present, 3);
      expect(may.absent, 2);
      expect(may.leave, 0);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د بخش لېږد', () {
    test('**زوړ ثبت بندېږي، نه ړنګېږي**', () async {
      final year = await academic.currentYear();
      final sections = await academic.sections();

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
        sectionId: sections[0].sectionId,
        academicYearId: year!.id,
        byUserId: 1,
        byUserName: 'admin',
      );

      await students.transferSection(
        studentId: id,
        sectionId: sections[1].sectionId,
        academicYearId: year.id,
        at: today,
      );

      final all = await db.select(db.enrollments).get();
      // دواړه کرښې پاتې دي — د تېرو میاشتو نمرې او حاضري د زاړه
      // بخش پورې تړلې دي.
      expect(all, hasLength(2));
      expect(all.where((e) => e.isActive), hasLength(1));
      expect(all.firstWhere((e) => e.isActive).sectionId, sections[1].sectionId);
      expect(all.firstWhere((e) => !e.isActive).leftOn, today);

      final profile = await students.profile(id);
      expect(profile!.sectionId, sections[1].sectionId);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د انځورونو ذخیره', () {
    late Directory tmp;
    late PhotoStore store;

    setUp(() {
      tmp = Directory.systemTemp.createTempSync('photostore');
      store = PhotoStore('${tmp.path}/school.db');
    });

    tearDown(() => tmp.deleteSync(recursive: true));

    test('انځور د ډیټابیس تر څنګ ساتل کېږي', () async {
      final path = await store.saveBytes(
        '1405-0001',
        Uint8List.fromList([1, 2, 3]),
      );
      expect(path, contains('photos'));
      expect(path, contains('1405-0001.jpg'));
      expect(File(path).existsSync(), isTrue);
      expect(store.find('1405-0001')!.path, path);
    });

    test('بهرنی فایل کاپي کېږي، نه یوازې تړل', () async {
      final src = File('${tmp.path}/desktop-photo.png')
        ..writeAsBytesSync([9, 9, 9]);

      final path = await store.saveFile('1405-0002', src);
      // اصلي فایل ړنګوو — پروفایل باید بشپړ پاتې شي.
      src.deleteSync();

      expect(File(path).existsSync(), isTrue);
      expect(File(path).readAsBytesSync(), [9, 9, 9]);
    });

    test('**نوې بڼه زړه پاکوي — یو شاګرد یو انځور**', () async {
      await store.saveBytes(
        '1405-0003',
        Uint8List.fromList([1]),
        ext: 'png',
      );
      await store.saveBytes('1405-0003', Uint8List.fromList([2]));

      final files = store.root.listSync().whereType<File>().toList();
      expect(files, hasLength(1));
      expect(files.first.path, endsWith('.jpg'));
    });

    test('د نمبر بدلون سره انځور هم ځي', () async {
      await store.saveBytes('1405-0004', Uint8List.fromList([1]));
      final moved = await store.rename('1405-0004', '1406-0004');

      expect(moved, contains('1406-0004'));
      expect(store.find('1405-0004'), isNull);
      expect(store.find('1406-0004'), isNotNull);
    });

    test('نشتوالی تېروتنه نه ده', () async {
      expect(store.find('نشته'), isNull);
      expect(await store.rename('نشته', 'بل'), isNull);
      await store.remove('نشته');
    });
  });
}
