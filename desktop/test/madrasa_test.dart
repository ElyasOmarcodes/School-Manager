import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/data/afghanistan.dart';
import 'package:school_manager/core/data/madrasa_curriculum.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/data/repositories/timetable_repository.dart';

void main() {
  late AppDatabase db;
  late AcademicRepository academic;

  setUp(() {
    db = AppDatabase.memory();
    academic = AcademicRepository(db);
  });

  tearDown(() => db.close());

  Future<void> makeSchool(String kind) => db
      .into(db.schools)
      .insert(SchoolsCompanion.insert(name: 'ازموینه', kind: Value(kind)));

  Future<void> seedMadrasa() => academic.seedMadrasaStructure(
    yearLabel: '1405',
    startsOn: DateTime(2026),
    endsOn: DateTime(2026, 12, 31),
  );

  // ═══════════════════════════════════════════════════════
  group('د مدرسې نصاب', () {
    test('درې‌ولس درجې لري، په ترتیب', () {
      expect(madrasaCurriculum, hasLength(13));
      expect(madrasaCurriculum.first.name, 'ابتدائیه');
      expect(madrasaCurriculum.first.level, 1);
      expect(madrasaCurriculum.last.level, 13);
      expect(madrasaCurriculum.last.name, contains('دورة الحدیث'));

      // کچې باید بې‌تشې او بې‌تکراره وي — که نه، د ترتیب کولو
      // پوښتنې به ناسم لیست راوړ.
      expect(
        madrasaCurriculum.map((l) => l.level).toList(),
        List.generate(13, (i) => i + 1),
      );
    });

    test('هره درجه مضامین لري او هر مضمون کتاب', () {
      for (final lvl in madrasaCurriculum) {
        expect(lvl.subjects, isNotEmpty, reason: lvl.name);
        for (final s in lvl.subjects) {
          expect(s.name.trim(), isNotEmpty, reason: lvl.name);
          expect(s.book.trim(), isNotEmpty, reason: '${lvl.name}/${s.name}');
        }
      }
    });

    test('د درجې له نامه څخه مضامین موندل کېږي', () {
      final fans = madrasaSubjectsOf('درجه رابعه');
      expect(fans, isNotEmpty);
      expect(fans.any((f) => f.name == 'اصول الفقه'), isTrue);
      expect(madrasaSubjectsOf('هېڅ داسې درجه نشته'), isEmpty);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د مدرسې جوړښت ثبتول', () {
    test('درجې، بخشونه او د هرې درجې کتابونه جوړوي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();

      final grades = await academic.grades();
      expect(grades, hasLength(13));
      expect(grades.first.name, 'ابتدائیه');

      final rabia = grades.firstWhere((g) => g.name == 'درجه رابعه');
      final subjects = await academic.subjects(gradeId: rabia.id);

      // د دې درجې مضامین — او د هغو کتابونه.
      final usool = subjects.firstWhere((s) => s.name == 'اصول الفقه');
      expect(usool.book, 'اصول الشاشي');
      expect(usool.gradeId, rabia.id);

      // هره درجه لږ تر لږه یو بخش لري — پرته له بخشه هېڅ شاګرد
      // نه ثبتېږي.
      final sections = await academic.sections();
      expect(sections, hasLength(13));
    });

    test('د مدرسې ظرفیت له مکتب لوړ دی او جدول ورځنی', () async {
      await makeSchool('madrasa');
      await seedMadrasa();

      final school = await academic.school();
      expect(school!.defaultCapacity, AcademicRepository.madrasaDefaultCapacity);
      expect(school.defaultCapacity, greaterThan(60));
      expect(school.timetableMode, 'daily');
      expect(school.classesView, 'grid');
    });

    test('دوه ځله ثبتول تکرار نه جوړوي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();
      await seedMadrasa();

      expect(await academic.grades(), hasLength(13));
      expect(await academic.sections(), hasLength(13));

      // مضامین هم — که تکرار شوي وای، هره درجه به دوه «فقه» درلودل.
      final all = await academic.subjects();
      final rabia = (await academic.grades()).firstWhere(
        (g) => g.name == 'درجه رابعه',
      );
      final fiqh = all.where(
        (s) => s.gradeId == rabia.id && s.name == 'اصول الفقه',
      );
      expect(fiqh, hasLength(1));
    });

    test('حساب او خط عصري ګڼل کېږي، پاتې دیني', () async {
      await makeSchool('madrasa');
      await seedMadrasa();

      final grades = await academic.grades();
      final ibtidaia = grades.firstWhere((g) => g.name == 'ابتدائیه');
      final subjects = await academic.subjects(gradeId: ibtidaia.id);

      expect(subjects.firstWhere((s) => s.name == 'حساب').isReligious, isFalse);
      expect(subjects.firstWhere((s) => s.name == 'خط').isReligious, isFalse);
      expect(subjects.firstWhere((s) => s.name == 'فقه').isReligious, isTrue);
    });

    test('د مکتب تلواله لار درجې نه جوړوي', () async {
      await makeSchool('school');
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026),
        endsOn: DateTime(2026, 12, 31),
      );

      final grades = await academic.grades();
      expect(grades, hasLength(12));
      expect(grades.first.name, 'لومړی');
      expect(grades.any((g) => g.name == 'درجه رابعه'), isFalse);
    });

    test('`seedDefaults(madrasa: true)` مدرسه جوړوي', () async {
      await makeSchool('madrasa');
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026),
        endsOn: DateTime(2026, 12, 31),
        madrasa: true,
      );
      expect(await academic.grades(), hasLength(13));
    });

    test('د مدرسې لپاره د مکتب مضامین نه ثبتېږي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();
      final before = (await academic.subjects()).length;

      await academic.seedDefaultSubjects();
      expect((await academic.subjects()).length, before);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د مضمون وړاندیزونه', () {
    test('مدرسه د هغې درجې فنون وړاندیز کوي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();

      final list = await academic.subjectSuggestions('درجه رابعه');
      expect(list.any((e) => e.name == 'اصول الفقه'), isTrue);
      expect(
        list.firstWhere((e) => e.name == 'اصول الفقه').book,
        'اصول الشاشي',
      );
    });

    test('مکتب عام مضامین وړاندیز کوي — پرته له کتابه', () async {
      await makeSchool('school');
      final list = await academic.subjectSuggestions(null);
      expect(list, isNotEmpty);
      expect(list.every((e) => e.book == null), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د ټولګیو او مضامینو CRUD', () {
    test('ټولګی چې شاګردان ولري، نه ړنګېږي', () async {
      await makeSchool('school');
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026),
        endsOn: DateTime(2026, 12, 31),
      );

      final grade = (await academic.grades()).first;
      final section = (await academic.sections()).firstWhere(
        (s) => s.gradeId == grade.id,
      );
      final year = await academic.currentYear();

      final sid = await StudentRepository(db).admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0001',
          firstName: 'احمد',
          fatherName: 'محمود',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'محمود', relation: 'father'),
        ],
        sectionId: section.sectionId,
        academicYearId: year!.id,
        byUserId: 1,
        byUserName: 'admin',
      );
      expect(sid, greaterThan(0));

      expect(await academic.deleteGrade(grade.id), isNotNull);
      expect(await academic.deleteSection(section.sectionId), isNotNull);

      // تش بخش ړنګېږي.
      final empty = await academic.addSection(gradeId: grade.id, name: 'ج');
      expect(await academic.deleteSection(empty), isNull);
    });

    test('نوی بخش د ښوونځي تلواله ظرفیت اخلي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();

      final grade = (await academic.grades()).first;
      final id = await academic.addSection(gradeId: grade.id, name: 'ب');
      final row = await (db.select(
        db.sections,
      )..where((s) => s.id.equals(id))).getSingle();

      expect(row.capacity, AcademicRepository.madrasaDefaultCapacity);
    });

    test('مضمون چې په ازموینه کې کارېږي، نه ړنګېږي', () async {
      await makeSchool('school');
      await academic.seedDefaults(
        yearLabel: '1405',
        startsOn: DateTime(2026),
        endsOn: DateTime(2026, 12, 31),
      );
      final grade = (await academic.grades()).first;
      final subjectId = await academic.addSubject(
        name: 'ازموینوی',
        gradeId: grade.id,
      );

      // تش مضمون ړنګېږي.
      final other = await academic.addSubject(name: 'تش');
      expect(await academic.removeSubject(other), isNull);

      final year = await academic.currentYear();
      final examId = await db
          .into(db.exams)
          .insert(
            ExamsCompanion.insert(
              name: 'ربع',
              academicYearId: year!.id,
              startsOn: DateTime(2026, 3),
              endsOn: DateTime(2026, 3, 10),
            ),
          );
      await db
          .into(db.examSubjects)
          .insert(
            ExamSubjectsCompanion.insert(
              examId: examId,
              gradeId: grade.id,
              subjectId: subjectId,
            ),
          );

      expect(await academic.removeSubject(subjectId), isNotNull);
      expect(await academic.subject(subjectId), isNotNull);
    });

    test('د مضمون سمون کتاب او سختوالی ساتي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();

      final id = await academic.addSubject(
        name: 'نوی فن',
        book: 'زوړ کتاب',
        difficulty: 'easy',
      );
      await academic.updateSubject(
        id: id,
        book: 'نوی کتاب',
        difficulty: 'hard',
      );

      final s = await academic.subject(id);
      expect(s!.book, 'نوی کتاب');
      expect(s.difficulty, 'hard');
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د مدرسې مهالویش', () {
    test('یو ترتیب چې هره ورځ تکرارېږي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();
      final timetable = TimetableRepository(db);
      await timetable.seedDefaultSlots();

      final sections = await academic.sections();
      final slots = (await timetable.slots())
          .where((s) => !s.isBreak)
          .toList();
      final grade = (await academic.grades()).firstWhere(
        (g) => g.name == 'درجه رابعه',
      );
      final section = sections.firstWhere((s) => s.gradeId == grade.id);
      final subject = (await academic.subjects(
        gradeId: grade.id,
      )).firstWhere((s) => s.name == 'اصول الفقه');

      final res = await timetable.setEntry(
        sectionId: section.sectionId,
        // **صفر یعنې «هره ورځ»** — نه یوه ورځ.
        dayOfWeek: everyDay,
        slotId: slots.first.id,
        subjectId: subject.id,
      );
      expect(res, isA<SetEntryOk>());

      final grid = await timetable.dailyGrid();
      expect(grid.rows, hasLength(13));
      expect(grid.at(section.sectionId, slots.first.id), isNotNull);
      expect(
        grid.at(section.sectionId, slots.first.id)!.subjectName,
        'اصول الفقه',
      );

      // د اونیز جدول هېڅ ورځ يې نه لري — ځکه چې د ورځې ستنه ۰ ده.
      final weekly = await timetable.grid(sectionId: section.sectionId);
      expect(weekly.filled, 0);
    });

    test('د یوې درجې کتار د بخش نوم نه تکراروي', () async {
      await makeSchool('madrasa');
      await seedMadrasa();
      await TimetableRepository(db).seedDefaultSlots();

      final grid = await TimetableRepository(db).dailyGrid();
      // یوه درجه یو بخش لري، نو «درجه رابعه» بس ده.
      expect(grid.rows.any((r) => r.label == 'درجه رابعه'), isTrue);

      // خو کله چې دوه بخشونه شي، نوم بېلېږي.
      final grade = (await academic.grades()).firstWhere(
        (g) => g.name == 'درجه رابعه',
      );
      await academic.addSection(gradeId: grade.id, name: 'ب');

      final after = await TimetableRepository(db).dailyGrid();
      expect(after.rows.where((r) => r.label.startsWith('درجه رابعه')), hasLength(2));
      expect(after.rows.any((r) => r.label == 'درجه رابعه — الف'), isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د افغانستان ولایتونه', () {
    test('۳۴ ولایتونه، هر یو ولسوالۍ لري', () {
      expect(afghanistanProvinces, hasLength(34));
      for (final p in afghanistanProvinces) {
        expect(p.districts, isNotEmpty, reason: p.name);
      }
    });

    test('ولسوالۍ د ولایت له مخې راځي', () {
      final kandahar = districtsOf('کندهار'); // بله املا — باید ومنل شي
      expect(kandahar, isNotEmpty);
      expect(districtsOf(null), isEmpty);
      expect(districtsOf('هېڅ ولایت'), isEmpty);
    });

    test('وړاندیز د منځ له لیکنې هم موندل کوي', () {
      // «مرغاب» د «بالا مرغاب» منځ کې دی — `startsWith` به يې نه موندل.
      final all = districtsOf('بادغیس');
      final hit = suggestFrom(all, 'مرغاب');
      expect(hit.any((d) => d.contains('مرغاب')), isTrue);
    });

    test('تش لټون لومړي څو راګرځوي، نه ټول', () {
      final r = suggestFrom(provinceNames, '');
      expect(r.length, lessThanOrEqualTo(8));
    });
  });
}
