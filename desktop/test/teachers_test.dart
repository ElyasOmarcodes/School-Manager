import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/teacher_repository.dart';

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
