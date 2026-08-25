import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/exam_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';

void main() {
  late AppDatabase db;
  late ExamRepository exams;
  late AcademicRepository academic;
  late StudentRepository students;

  late int examId;
  late int gradeId;
  late int sectionId;
  late int yearId;
  late List<int> subjectIds;
  late Map<String, int> studentByName;

  setUp(() async {
    db = AppDatabase.memory();
    exams = ExamRepository(db);
    academic = AcademicRepository(db);
    students = StudentRepository(db);

    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026, 1, 1),
      endsOn: DateTime(2026, 12, 31),
    );
    await academic.seedDefaultSubjects();

    yearId = (await academic.currentYear())!.id;
    final sections = await academic.sections();
    final tenth = sections.firstWhere((s) => s.level == 10);
    gradeId = tenth.gradeId;
    sectionId = tenth.sectionId;

    final all = await academic.subjects();
    subjectIds = [
      all.firstWhere((s) => s.name == 'ریاضي').id,
      all.firstWhere((s) => s.name == 'پښتو').id,
      all.firstWhere((s) => s.name == 'انګلیسي').id,
    ];

    examId = await exams.create(
      name: 'د لومړۍ ربعې ازموینه',
      examType: 'midterm',
      academicYearId: yearId,
      startsOn: DateTime(2026, 5, 10),
      endsOn: DateTime(2026, 5, 20),
    );
    await exams.addSubjects(
      examId: examId,
      gradeId: gradeId,
      subjectIds: subjectIds,
    );

    studentByName = {};
    var i = 1;
    for (final name in ['احمد', 'کریم', 'زرغونه', 'بلال']) {
      final id = await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-000$i',
          firstName: name,
          fatherName: 'پلار',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        sectionId: sectionId,
        academicYearId: yearId,
        rollNo: i,
        byUserId: 1,
        byUserName: 'admin',
      );
      studentByName[name] = id;
      i++;
    }
  });

  tearDown(() => db.close());

  Future<List<ExamSubjectRow>> examSubjects() =>
      exams.subjectsOf(examId, gradeId: gradeId);

  /// د یوه مضمون نمرې لیکي.
  Future<void> mark(int subjectIndex, Map<String, double?> byName,
      {Set<String> absent = const {}}) async {
    final subs = await examSubjects();
    await exams.saveMarks(
      examSubjectId: subs[subjectIndex].examSubject.id,
      byStudent: {
        for (final e in byName.entries)
          studentByName[e.key]!: (
            obtained: e.value,
            isAbsent: absent.contains(e.key),
          ),
      },
      byUserId: 1,
    );
  }

  // ═════════════════════════════════════════════════════════

  group('د ازموینې جوړول', () {
    test('ازموینه له مضمونونو سره ثبتېږي', () async {
      final list = await exams.list();
      expect(list, hasLength(1));
      expect(list.first.exam.name, 'د لومړۍ ربعې ازموینه');
      expect(list.first.subjectCount, 3);
    });

    test('د لیکلو پرمختګ له صفر څخه پیلېږي', () async {
      final row = (await exams.list()).first;
      // ۳ مضمونه × ۴ شاګردان = ۱۲ نمرې پکار دي.
      expect(row.expectedCount, 12);
      expect(row.markedCount, 0);
      expect(row.isComplete, isFalse);
    });

    test('هماغه مضمون دوه ځله نه زیاتېږي', () async {
      await exams.addSubjects(
        examId: examId,
        gradeId: gradeId,
        subjectIds: subjectIds,
      );
      expect(await examSubjects(), hasLength(3));
    });

    test('خپرول یوه جلا پرېکړه ده', () async {
      expect((await exams.list()).first.exam.isPublished, isFalse);
      await exams.publish(examId, published: true);
      final after = (await exams.list()).first.exam;
      expect(after.isPublished, isTrue);
      expect(after.publishedAt, isNotNull);
    });
  });

  group('د نمرو لیکل', () {
    test('د نمرو پاڼه ټول شاګردان ښیي، حتی هغه چې نمره نه لري', () async {
      final subs = await examSubjects();
      final sheet = await exams.markSheet(
        examSubjectId: subs.first.examSubject.id,
        sectionId: sectionId,
      );
      expect(sheet, hasLength(4));
      expect(sheet.every((e) => e.obtained == null), isTrue);
    });

    test('نمرې ثبتېږي او بیرته راځي', () async {
      await mark(0, {'احمد': 85, 'کریم': 42});

      final subs = await examSubjects();
      final sheet = await exams.markSheet(
        examSubjectId: subs.first.examSubject.id,
        sectionId: sectionId,
      );
      final ahmad = sheet.firstWhere((e) => e.student.firstName == 'احمد');
      expect(ahmad.obtained, 85);
    });

    test('سمول کار کوي — دویم ثبت نه ماتېږي', () async {
      await mark(0, {'احمد': 85});
      await mark(0, {'احمد': 90});

      final subs = await examSubjects();
      final sheet = await exams.markSheet(
        examSubjectId: subs.first.examSubject.id,
        sectionId: sectionId,
      );
      expect(
        sheet.firstWhere((e) => e.student.firstName == 'احمد').obtained,
        90,
      );
      expect(await db.select(db.marks).get(), hasLength(1));
    });

    test('له بشپړې نمرې پورته نمره ټکنۍ کېږي', () async {
      // استاد «۹۵۰» ولیکل — یو اضافي صفر. باید ۱۰۰ شي، نه ۹۵۰.
      await mark(0, {'احمد': 950});

      final subs = await examSubjects();
      final sheet = await exams.markSheet(
        examSubjectId: subs.first.examSubject.id,
        sectionId: sectionId,
      );
      expect(
        sheet.firstWhere((e) => e.student.firstName == 'احمد').obtained,
        100,
      );
    });

    test('غیرحاضر له صفر نمرې بېل دی', () async {
      await mark(0, {'احمد': null, 'کریم': 0}, absent: {'احمد'});

      final subs = await examSubjects();
      final sheet = await exams.markSheet(
        examSubjectId: subs.first.examSubject.id,
        sectionId: sectionId,
      );
      final ahmad = sheet.firstWhere((e) => e.student.firstName == 'احمد');
      final karim = sheet.firstWhere((e) => e.student.firstName == 'کریم');

      expect(ahmad.isAbsent, isTrue);
      expect(ahmad.obtained, isNull);
      expect(karim.isAbsent, isFalse);
      expect(karim.obtained, 0);
    });

    test('پرمختګ د لیکلو سره پورته ځي', () async {
      await mark(0, {'احمد': 85, 'کریم': 42, 'زرغونه': 90, 'بلال': 30});
      final row = (await exams.list()).first;
      expect(row.markedCount, 4);
      expect(row.progress, closeTo(33.3, 0.5));
    });
  });

  group('پایلې او درجه', () {
    Future<void> markAll() async {
      await mark(0, {'احمد': 90, 'کریم': 70, 'زرغونه': 90, 'بلال': 30});
      await mark(1, {'احمد': 80, 'کریم': 75, 'زرغونه': 80, 'بلال': 50});
      await mark(2, {'احمد': 70, 'کریم': 65, 'زرغونه': 70, 'بلال': 60});
    }

    test('مجموعه او سلنه سمې دي', () async {
      await markAll();
      final results = await exams.sectionResults(
        examId: examId,
        sectionId: sectionId,
      );
      final ahmad = results.firstWhere((r) => r.student.firstName == 'احمد');

      expect(ahmad.obtainedTotal, 240);
      expect(ahmad.fullTotal, 300);
      expect(ahmad.percent, 80);
      expect(ahmad.band.letter, 'A');
    });

    test('مساوي مجموعه = مساوي درجه، او راتلونکی يې پرېږدي', () async {
      await markAll();
      final results = await exams.sectionResults(
        examId: examId,
        sectionId: sectionId,
      );

      final ahmad = results.firstWhere((r) => r.student.firstName == 'احمد');
      final zarghuna = results.firstWhere(
        (r) => r.student.firstName == 'زرغونه',
      );
      final karim = results.firstWhere((r) => r.student.firstName == 'کریم');

      // دواړه ۲۴۰ لري — دواړه لومړی.
      expect(ahmad.obtainedTotal, zarghuna.obtainedTotal);
      expect(ahmad.rank, 1);
      expect(zarghuna.rank, 1);
      // راتلونکی دویم نه، درېیم دی.
      expect(karim.rank, 3);
    });

    test('یو ناکام مضمون د ښه اوسط سره هم ناکام دی', () async {
      // بلال په ریاضي کې ۳۰ — د ۴۰ تر کچې ښکته.
      await markAll();
      final results = await exams.sectionResults(
        examId: examId,
        sectionId: sectionId,
      );
      final bilal = results.firstWhere((r) => r.student.firstName == 'بلال');

      expect(bilal.percent, closeTo(46.7, 0.2));
      expect(bilal.passedAll, isFalse);
      expect(bilal.failed, hasLength(1));
      expect(bilal.failed.first.subjectName, 'ریاضي');
    });

    test('غیرحاضر مضمون ناکام ګڼل کېږي', () async {
      await mark(0, {'احمد': null}, absent: {'احمد'});
      await mark(1, {'احمد': 90});
      await mark(2, {'احمد': 90});

      final r = await exams.studentResult(
        examId: examId,
        studentId: studentByName['احمد']!,
      );
      expect(r!.failed, hasLength(1));
      expect(r.failed.first.isAbsent, isTrue);
    });

    test('د یوه شاګرد کارنامه له درجې سره راځي', () async {
      await markAll();
      final r = await exams.studentResult(
        examId: examId,
        studentId: studentByName['کریم']!,
      );
      expect(r, isNotNull);
      expect(r!.subjects, hasLength(3));
      expect(r.outOf, 4);
      expect(r.rank, 3);
    });

    test('نه‌لیکل شوې نمره صفر ګڼل کېږي، نه چې کرښه ورکه شي', () async {
      // یوازې یو مضمون لیکل شوی — پاتې دوه تش دي.
      await mark(0, {'احمد': 90});
      final r = await exams.studentResult(
        examId: examId,
        studentId: studentByName['احمد']!,
      );
      expect(r!.subjects, hasLength(3));
      expect(r.obtainedTotal, 90);
      expect(r.fullTotal, 300);
    });
  });

  group('د درجې کچه', () {
    test('هره سلنه خپله درجه مومي', () {
      expect(bandFor(95).letter, 'A+');
      expect(bandFor(90).letter, 'A+');
      expect(bandFor(89.9).letter, 'A');
      expect(bandFor(40).letter, 'E');
      expect(bandFor(39.9).letter, 'F');
      expect(bandFor(0).letter, 'F');
    });
  });

  group('د مضمون انځور', () {
    test('اوسط، لوړه، ټیټه او د پاس شمېر', () async {
      await mark(0, {'احمد': 90, 'کریم': 70, 'زرغونه': 50, 'بلال': 30});

      final stats = await exams.subjectStats(
        examId: examId,
        sectionId: sectionId,
      );
      final math = stats.firstWhere((s) => s.subjectName == 'ریاضي');

      expect(math.average, 60);
      expect(math.highest, 90);
      expect(math.lowest, 30);
      expect(math.passed, 3);
      expect(math.failed, 1);
      expect(math.passPercent, 75);
    });

    test('غیرحاضر نه په اوسط کې راځي نه په ناکامو کې', () async {
      await mark(
        0,
        {'احمد': 100, 'کریم': 50, 'زرغونه': null, 'بلال': null},
        absent: {'زرغونه', 'بلال'},
      );

      final stats = await exams.subjectStats(
        examId: examId,
        sectionId: sectionId,
      );
      final math = stats.firstWhere((s) => s.subjectName == 'ریاضي');

      expect(math.average, 75);
      expect(math.absent, 2);
      expect(math.failed, 0);
      expect(math.passed, 2);
    });
  });

  group('مضمونونه', () {
    test('تلواله مضمونونه دیني او عصري دواړه لري', () async {
      final all = await academic.subjects();
      expect(all.where((s) => s.isReligious).length, greaterThanOrEqualTo(4));
      expect(all.where((s) => !s.isReligious).length, greaterThanOrEqualTo(8));
    });

    test('د یوه ټولګي مضمونونه عام مضمونونه هم لري', () async {
      final special = await academic.addSubject(
        name: 'اقتصاد',
        gradeId: gradeId,
      );
      final forGrade = await academic.subjects(gradeId: gradeId);

      expect(forGrade.map((s) => s.id), contains(special));
      expect(forGrade.map((s) => s.name), contains('ریاضي'));
    });

    test('دوه ځله کرل مضمونونه نه دوهڅنده کوي', () async {
      final before = (await academic.subjects()).length;
      await academic.seedDefaultSubjects();
      expect(await academic.subjects(), hasLength(before));
    });
  });
}
