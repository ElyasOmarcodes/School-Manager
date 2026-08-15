import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/teacher_repository.dart';
import 'package:school_manager/data/repositories/timetable_repository.dart';

void main() {
  late AppDatabase db;
  late TeacherRepository repo;
  late AcademicRepository academic;

  setUp(() {
    db = AppDatabase.memory();
    repo = TeacherRepository(db);
    academic = AcademicRepository(db);
  });

  tearDown(() => db.close());

  Future<int> addTeacher(
    String name, {
    String? spec,
    String? phone,
    String status = 'active',
    String gender = 'male',
  }) async {
    return repo.add(
      teacher: TeachersCompanion.insert(
        employeeNo: await repo.nextEmployeeNo(),
        fullName: name,
        gender: gender,
        specialization: Value(spec),
        phone: Value(phone),
        status: Value(status),
      ),
      byUserId: 1,
      byUserName: 'admin',
    );
  }

  group('د کارمند نمبر', () {
    test('په ترتیب زیاتېږي', () async {
      expect(await repo.nextEmployeeNo(), 'T-0001');
      await addTeacher('احمد');
      expect(await repo.nextEmployeeNo(), 'T-0002');
      await addTeacher('کریم');
      expect(await repo.nextEmployeeNo(), 'T-0003');
    });
  });

  group('لټون او سرغړاوی', () {
    test('په نوم، تخصص او تلیفون لټون', () async {
      await addTeacher('احمد ولي', spec: 'ریاضي', phone: '0701234567');
      await addTeacher('کریمه نوري', spec: 'بیولوژي', gender: 'female');

      expect(
        (await repo.list(filter: const TeacherFilter(query: 'ریاضي'))).total,
        1,
      );
      expect(
        (await repo.list(filter: const TeacherFilter(query: 'نوري'))).total,
        1,
      );
      expect(
        (await repo.list(filter: const TeacherFilter(query: '070'))).total,
        1,
      );
    });

    test('لټون د ختیځو شمېرو سره کار کوي', () async {
      await addTeacher('احمد', phone: '0701234567');
      // کارن «۰۷۰۱» لیکي — ډیټابیس لاتیني ساتي.
      final page = await repo.list(filter: const TeacherFilter(query: '۰۷۰۱'));
      expect(page.total, 1);
    });

    test('تلواله یوازې فعال ښیي', () async {
      await addTeacher('احمد');
      await addTeacher('کریم', status: 'resigned');

      expect((await repo.list()).total, 1);
      expect(
        (await repo.list(
          filter: const TeacherFilter(status: 'resigned'),
        )).total,
        1,
      );
    });
  });

  group('د ټولګي مشري', () {
    Future<List<SectionOption>> seedSections() async {
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026, 3, 21),
        endsOn: DateTime(2026, 12, 21),
        fromLevel: 10,
        toLevel: 10,
      );
      return academic.sections();
    }

    test('ټاکل او په لیست کې ښکارېدل', () async {
      final id = await addTeacher('احمد ولي');
      final sections = await seedSections();

      await repo.assignHomeroom(
        sectionId: sections.first.sectionId,
        teacherId: id,
      );

      final row = (await repo.list()).items.first;
      expect(row.homeroomOf, 'لسم — الف');
    });

    test('د څو بخشونو مشري یوځای ښکاري', () async {
      final id = await addTeacher('احمد ولي');
      final sections = await seedSections();

      for (final s in sections) {
        await repo.assignHomeroom(sectionId: s.sectionId, teacherId: id);
      }

      final row = (await repo.list()).items.first;
      expect(row.homeroomOf, 'لسم — الف، لسم — ب');
    });

    test('مشري پرې کېدی شي', () async {
      final id = await addTeacher('احمد');
      final sections = await seedSections();
      await repo.assignHomeroom(
        sectionId: sections.first.sectionId,
        teacherId: id,
      );
      await repo.assignHomeroom(
        sectionId: sections.first.sectionId,
        teacherId: null,
      );

      expect((await repo.list()).items.first.homeroomOf, isEmpty);
    });

    test('د استاد پټول د بخش مشري هم پرې کوي', () async {
      final id = await addTeacher('احمد');
      final sections = await seedSections();
      await repo.assignHomeroom(
        sectionId: sections.first.sectionId,
        teacherId: id,
      );

      await repo.softDelete(id, byUserId: 1, byUserName: 'admin');

      // که تړاو پاتې وای، د ټولګیو پاڼه به یوه پټ استاد ته اشاره
      // کوله او تشه به يې ښودله.
      final section = await (db.select(
        db.sections,
      )..where((s) => s.id.equals(sections.first.sectionId))).getSingle();
      expect(section.headTeacherId, isNull);

      expect((await repo.list()).total, 0);
      // ریکارډ پاتې دی — د معاش تاریخچه ورپورې تړلې ده.
      expect(await db.select(db.teachers).get(), hasLength(1));
    });
  });

  // ═══════════════════════════════════════════════════════
  group('پرمختللي فلټرونه', () {
    test('تخصص او تحصیل', () async {
      await repo.add(
        teacher: TeachersCompanion.insert(
          employeeNo: await repo.nextEmployeeNo(),
          fullName: 'احمد',
          gender: 'male',
          specialization: const Value('ریاضي'),
          qualification: const Value('ماسټر'),
        ),
        byUserId: 1,
        byUserName: 'admin',
      );
      await addTeacher('کریم', spec: 'فزیک');

      expect(await repo.specializations(), ['ریاضي', 'فزیک']);
      expect(await repo.qualifications(), ['ماسټر']);

      final byS = await repo.list(
        filter: const TeacherFilter(specialization: 'ریاضي'),
      );
      expect(byS.items.single.teacher.fullName, 'احمد');

      final byQ = await repo.list(
        filter: const TeacherFilter(qualification: 'ماسټر'),
      );
      expect(byQ.total, 1);
    });

    test('د مشرۍ فلټر دواړه لوري لري', () async {
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026),
        endsOn: DateTime(2026, 12, 31),
        fromLevel: 1,
        toLevel: 2,
        sectionNames: const ['الف', 'ب'],
      );
      final head = await addTeacher('مشر');
      await addTeacher('عادي');

      final sections = await academic.sections();
      // دوه بخشونه یوه استاد ته — چې د دوه‌ځلي راوړلو ستونزه وازمویو.
      await repo.assignHomeroom(
        sectionId: sections[0].sectionId,
        teacherId: head,
      );
      await repo.assignHomeroom(
        sectionId: sections[1].sectionId,
        teacherId: head,
      );

      final withHome = await repo.list(
        filter: const TeacherFilter(homeroom: true),
      );
      expect(withHome.total, 1);
      expect(withHome.items, hasLength(1));
      expect(withHome.items.single.teacher.fullName, 'مشر');

      final without = await repo.list(
        filter: const TeacherFilter(homeroom: false),
      );
      expect(without.items.single.teacher.fullName, 'عادي');
    });

    test('د معاش ترتیب — تش معاش تل وروستی', () async {
      await repo.add(
        teacher: TeachersCompanion.insert(
          employeeNo: await repo.nextEmployeeNo(),
          fullName: 'لوړ',
          gender: 'male',
          monthlySalary: const Value(30000),
        ),
        byUserId: 1,
        byUserName: 'admin',
      );
      await repo.add(
        teacher: TeachersCompanion.insert(
          employeeNo: await repo.nextEmployeeNo(),
          fullName: 'ټیټ',
          gender: 'male',
          monthlySalary: const Value(10000),
        ),
        byUserId: 1,
        byUserName: 'admin',
      );
      await addTeacher('بې‌معاشه');

      final asc = await repo.list(
        filter: const TeacherFilter(sort: 'salary'),
      );
      expect(asc.items.map((r) => r.teacher.fullName), [
        'ټیټ',
        'لوړ',
        'بې‌معاشه',
      ]);

      final desc = await repo.list(
        filter: const TeacherFilter(sort: 'salary', descending: true),
      );
      expect(desc.items.map((r) => r.teacher.fullName), [
        'لوړ',
        'ټیټ',
        'بې‌معاشه',
      ]);
    });

    test('د فلټرونو شمېره تلواله نه شمېري', () async {
      const base = TeacherFilter();
      expect(base.activeCount, 0);
      expect(base.copyWith(gender: 'male').activeCount, 1);
      expect(base.copyWith(status: 'resigned').activeCount, 1);
      // د ترتیب بدلون فلټر نه دی — کارن يې د شمېرې په څېر نه ګوري.
      expect(base.copyWith(sort: 'salary').activeCount, 0);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('سمون او پروفایل', () {
    test('سمون یوازې ورکړل شوې ساحې بدلوي', () async {
      final id = await addTeacher('احمد', spec: 'ریاضي', phone: '0700000000');

      await repo.update(
        id: id,
        patch: const TeachersCompanion(fullName: Value('احمد کریمي')),
        byUserId: 1,
        byUserName: 'admin',
      );

      final t = await repo.byId(id);
      expect(t!.fullName, 'احمد کریمي');
      // نور ساحې لا هماغه دي.
      expect(t.specialization, 'ریاضي');
      expect(t.phone, '0700000000');
    });

    test('پروفایل مشري، بار او حاضري راوړي', () async {
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026),
        endsOn: DateTime(2026, 12, 31),
        fromLevel: 1,
        toLevel: 1,
        sectionNames: const ['الف'],
      );
      final id = await addTeacher('احمد', spec: 'ریاضي');
      final sections = await academic.sections();
      await repo.assignHomeroom(
        sectionId: sections.first.sectionId,
        teacherId: id,
      );

      // دوه ساعته ریاضي په هماغه بخش کې.
      final subjectId = await db
          .into(db.subjects)
          .insert(SubjectsCompanion.insert(name: 'ریاضي'));
      final timetable = TimetableRepository(db);
      await timetable.seedDefaultSlots();
      final slots = await timetable.slots();
      for (var i = 0; i < 2; i++) {
        await db
            .into(db.timetableEntries)
            .insert(
              TimetableEntriesCompanion.insert(
                sectionId: sections.first.sectionId,
                dayOfWeek: 1 + i,
                slotId: slots.first.id,
                subjectId: subjectId,
                teacherId: Value(id),
              ),
            );
      }

      await db
          .into(db.staffAttendances)
          .insert(
            StaffAttendancesCompanion.insert(
              personKind: 'teacher',
              personId: id,
              date: DateTime(2026, 5, 12),
              status: 'present',
            ),
          );

      final p = await repo.profile(id, month: DateTime(2026, 5));
      expect(p, isNotNull);
      expect(p!.homeroom.single.students, isNonNegative);
      expect(p.weeklyPeriods, 2);
      expect(p.subjectCount, 1);
      expect(p.attendance[12], 'present');
    });

    test('د نشتوالي پروفایل `null` دی', () async {
      expect(await repo.profile(999), isNull);
    });
  });

  group('فعال استادان', () {
    test('یوازې فعال، په الفبا ترتیب', () async {
      await addTeacher('یوسف');
      await addTeacher('احمد');
      await addTeacher('کریم', status: 'resigned');

      final list = await repo.activeTeachers();
      expect(list.map((t) => t.fullName), ['احمد', 'یوسف']);
    });
  });
}
