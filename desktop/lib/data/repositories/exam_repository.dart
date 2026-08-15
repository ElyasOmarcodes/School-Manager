import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../db/database.dart';

// ═══════════════════════════════════════════════════════════
//  د نمرو کچه
// ═══════════════════════════════════════════════════════════

/// یوه درجه — «اعلی»، «ډېر ښه»…
class GradeBand {
  final double minPercent;
  final String letter;
  final String label;
  const GradeBand(this.minPercent, this.letter, this.label);
}

/// **دا کچه ولې دا شان ده؟** په افغانستان کې د پوهنې وزارت کچه له
/// ۱۰۰ څخه ده او د کامیابۍ حد ۴۰ دی — نه ۵۰ او نه د A/B/C امریکايي
/// بڼه. نو د پاس/ناکام کرښه دلته ۴۰ ده، او نومونه هغه دي چې د
/// کارنامې پر مخ لیکل کېږي.
const List<GradeBand> gradeBands = [
  GradeBand(90, 'A+', 'اعلی'),
  GradeBand(80, 'A', 'ډېر ښه'),
  GradeBand(70, 'B', 'ښه'),
  GradeBand(60, 'C', 'منځنی'),
  GradeBand(50, 'D', 'بس'),
  GradeBand(40, 'E', 'کمزوری'),
  GradeBand(0, 'F', 'ناکام'),
];

GradeBand bandFor(double percent) =>
    gradeBands.firstWhere((b) => percent >= b.minPercent);

// ═══════════════════════════════════════════════════════════
//  ماډلونه
// ═══════════════════════════════════════════════════════════

class ExamRow {
  final Exam exam;
  final int subjectCount;
  final int markedCount;
  final int expectedCount;

  const ExamRow({
    required this.exam,
    this.subjectCount = 0,
    this.markedCount = 0,
    this.expectedCount = 0,
  });

  double get progress =>
      expectedCount == 0 ? 0 : (markedCount / expectedCount) * 100;
  bool get isComplete => expectedCount > 0 && markedCount >= expectedCount;
}

/// یو مضمون د یوې ازموینې دننه، له نوم سره.
class ExamSubjectRow {
  final ExamSubject examSubject;
  final String subjectName;
  final String gradeName;

  const ExamSubjectRow({
    required this.examSubject,
    required this.subjectName,
    required this.gradeName,
  });
}

/// د نمرې د لیکلو یوه کرښه.
class MarkEntry {
  final Student student;
  final int? rollNo;
  final double? obtained;
  final bool isAbsent;
  final String? remarks;

  /// «لسم — الف». **دا ولې پکار دی؟** ځکه چې د نمرو لیست د ټولګي
  /// په کچه دی، نه د بخش — نو د «الف» او «ب» شاګردان یو ځای دي او
  /// استاد باید وپېژني چې کوم يې د کوم بخش دی.
  final String? className;

  const MarkEntry({
    required this.student,
    this.rollNo,
    this.obtained,
    this.isAbsent = false,
    this.remarks,
    this.className,
  });
}

/// د یوه مضمون پایله د یوه شاګرد لپاره.
class SubjectResult {
  final String subjectName;
  final double? obtained;
  final int fullMark;
  final int passMark;
  final bool isAbsent;

  const SubjectResult({
    required this.subjectName,
    required this.fullMark,
    required this.passMark,
    this.obtained,
    this.isAbsent = false,
  });

  bool get passed => !isAbsent && (obtained ?? 0) >= passMark;
  double get percent =>
      fullMark == 0 ? 0 : ((obtained ?? 0) / fullMark) * 100;
}

/// د یوه شاګرد بشپړه پایله.
class StudentResult {
  final Student student;
  final int? rollNo;
  final List<SubjectResult> subjects;
  final double obtainedTotal;
  final int fullTotal;
  final int rank;
  final int outOf;

  const StudentResult({
    required this.student,
    required this.subjects,
    required this.obtainedTotal,
    required this.fullTotal,
    required this.rank,
    required this.outOf,
    this.rollNo,
  });

  double get percent =>
      fullTotal == 0 ? 0 : (obtainedTotal / fullTotal) * 100;
  GradeBand get band => bandFor(percent);

  /// **پاس/ناکام د اوسط له مخې نه ټاکل کېږي.** یو شاګرد چې په
  /// ریاضي کې ۱۰ واخلي خو په نورو کې ۹۰، اوسط يې ښه دی — خو هغه
  /// مضمون ناکام دی او باید بیا ازموینه ورکړي.
  List<SubjectResult> get failed =>
      subjects.where((s) => !s.passed).toList();
  bool get passedAll => failed.isEmpty;
}

/// د یوه مضمون د ټولګي انځور — د استاد لپاره.
class SubjectStats {
  final String subjectName;
  final int fullMark;
  final double average;
  final double highest;
  final double lowest;
  final int passed;
  final int failed;
  final int absent;

  const SubjectStats({
    required this.subjectName,
    required this.fullMark,
    required this.average,
    required this.highest,
    required this.lowest,
    required this.passed,
    required this.failed,
    required this.absent,
  });

  int get total => passed + failed + absent;
  double get passPercent => total == 0 ? 0 : (passed / total) * 100;
}

// ═══════════════════════════════════════════════════════════
//  د پایلو فلټر
// ═══════════════════════════════════════════════════════════

/// **د پایلو د کتنې فلټر.**
///
/// **دا ولې د یوه ساده «بخش وټاکه» پر ځای دی؟**
/// ځکه چې مدیر دوه بېلې پوښتنې لري:
///
///  1. «د دوهم ټولګي ټول مضامین راوښیه» — یو ټولګی، ټول مضامین.
///     دا کارنامه ده.
///  2. «د ریاضي نمرې په ټولو ټولګیو کې راوښیه» — یو مضمون، ټول
///     ټولګي. دا د یوه استاد یا د یوه مضمون کتنه ده.
///
/// **خو دواړه یو ځای «ټول» کېدی نه شي.** «د ټولو ټولګیو ټول
/// مضامین» یو داسې جدول جوړوي چې نه لوستل کېږي او نه معنا لري —
/// د اته سوو شاګردانو × د اتلسو مضامینو کرښې. نو یوه پرېکړه تل
/// ټاکل شوې ده.
class ResultFilter {
  /// `null` = ټول ټولګي.
  final int? gradeId;

  /// `null` = ټول مضامین.
  final int? subjectId;

  final String query;

  /// `rank` (د نمرو له مخې) | `name` | `roll`
  final String sort;

  /// `all` | `passed` | `failed` | `absent`
  final String outcome;

  const ResultFilter({
    this.gradeId,
    this.subjectId,
    this.query = '',
    this.sort = 'rank',
    this.outcome = 'all',
  });

  /// **دا هغه قاعده ده چې د دواړو «ټول» مخه نیسي.**
  ///
  /// کله چې کارن یو فلټر «ټول» کړي، بل يې پخپله یوې ټاکلې ارزښت
  /// ته ورګرځي — نه دا چې تېروتنه ورته وښودل شي. یوه پرده چې
  /// «دا کار نه شي کېدی» وايي، له هغې کمزورې ده چې پخپله سمه
  /// پرېکړه وکړي.
  ResultFilter copyWith({
    int? gradeId,
    int? subjectId,
    String? query,
    String? sort,
    String? outcome,
    bool allGrades = false,
    bool allSubjects = false,

    /// که «ټول» وټاکل شي، بل فلټر دې دې ارزښت ته ورشي.
    int? fallbackGradeId,
    int? fallbackSubjectId,
  }) {
    var g = allGrades ? null : (gradeId ?? this.gradeId);
    var s = allSubjects ? null : (subjectId ?? this.subjectId);

    if (g == null && s == null) {
      if (allGrades) {
        s = fallbackSubjectId ?? this.subjectId;
      } else {
        g = fallbackGradeId ?? this.gradeId;
      }
    }

    return ResultFilter(
      gradeId: g,
      subjectId: s,
      query: query ?? this.query,
      sort: sort ?? this.sort,
      outcome: outcome ?? this.outcome,
    );
  }

  bool get isSingleSubject => subjectId != null;
  bool get isAllGrades => gradeId == null;
}

/// د پایلو یوه کرښه — یو شاګرد، یو یا څو مضامین.
class ResultRow {
  final Student student;
  final String? gradeName;
  final String? sectionName;
  final int? rollNo;
  final List<SubjectResult> subjects;
  final double obtained;
  final int full;
  final int rank;

  const ResultRow({
    required this.student,
    required this.subjects,
    required this.obtained,
    required this.full,
    required this.rank,
    this.gradeName,
    this.sectionName,
    this.rollNo,
  });

  String get fullName => [
    student.firstName,
    if (student.lastName?.isNotEmpty ?? false) student.lastName,
  ].join(' ');

  String get className => gradeName == null
      ? '—'
      : '$gradeName${sectionName == null ? '' : ' — $sectionName'}';

  double get percent => full == 0 ? 0 : (obtained / full) * 100;
  GradeBand get band => bandFor(percent);

  List<SubjectResult> get failed => subjects.where((s) => !s.passed).toList();
  bool get passedAll => subjects.isNotEmpty && failed.isEmpty;
  bool get anyAbsent => subjects.any((s) => s.isAbsent);
}

/// یو ممتاز شاګرد — د ښوونځي یا د یوه ټولګي په کچه.
class TopStudent {
  final Student student;
  final String className;
  final int? gradeId;
  final double percent;
  final double obtained;
  final int full;
  final int position;

  const TopStudent({
    required this.student,
    required this.className,
    required this.percent,
    required this.obtained,
    required this.full,
    required this.position,
    this.gradeId,
  });

  String get fullName => [
    student.firstName,
    if (student.lastName?.isNotEmpty ?? false) student.lastName,
  ].join(' ');
}

/// د دوو ازموینو راټوله شوې پایله — «۴۰ + ۶۰ = ۱۰۰».
class CombinedResult {
  final Student student;
  final String className;
  final int? rollNo;

  /// هره ازموینه او هغه څه چې راوړي يې.
  final List<({Exam exam, double scaled, double percent, bool hasMarks})> parts;

  final double total;
  final int rank;

  const CombinedResult({
    required this.student,
    required this.className,
    required this.parts,
    required this.total,
    required this.rank,
    this.rollNo,
  });

  String get fullName => [
    student.firstName,
    if (student.lastName?.isNotEmpty ?? false) student.lastName,
  ].join(' ');

  /// ټول برخې لا نه دي بشپړې — نو مجموعه لا وروستۍ نه ده.
  bool get isPartial => parts.any((p) => !p.hasMarks);
  GradeBand get band => bandFor(total);
}

// ═══════════════════════════════════════════════════════════

class ExamRepository {
  final AppDatabase db;
  ExamRepository(this.db);

  // ── ازموینې ─────────────────────────────────────────────

  Future<List<ExamRow>> list({int? academicYearId}) async {
    final rows = await db
        .customSelect(
          '''
SELECT e.*,
  (SELECT COUNT(*) FROM exam_subjects es WHERE es.exam_id = e.id)
    AS subject_count,
  (SELECT COUNT(*) FROM marks m
     JOIN exam_subjects es2 ON es2.id = m.exam_subject_id
     WHERE es2.exam_id = e.id) AS marked_count,
  -- څومره نمرې باید ولیکل شي: د هر مضمون × د هغه ټولګي شاګردان.
  (SELECT COALESCE(SUM(cnt), 0) FROM (
      SELECT (SELECT COUNT(*) FROM enrollments en
                JOIN sections sc ON sc.id = en.section_id
              WHERE sc.grade_id = es3.grade_id AND en.is_active = 1) AS cnt
      FROM exam_subjects es3 WHERE es3.exam_id = e.id
   )) AS expected_count
FROM exams e
WHERE e.deleted_at IS NULL
  ${academicYearId == null ? '' : 'AND e.academic_year_id = ?'}
ORDER BY e.starts_on DESC
''',
          variables: [
            if (academicYearId != null) Variable<int>(academicYearId),
          ],
          readsFrom: {
            db.exams,
            db.examSubjects,
            db.marks,
            db.enrollments,
            db.sections,
          },
        )
        .get();

    return rows
        .map(
          (r) => ExamRow(
            exam: db.exams.map(r.data),
            subjectCount: r.read<int>('subject_count'),
            markedCount: r.read<int>('marked_count'),
            expectedCount: r.read<int>('expected_count'),
          ),
        )
        .toList();
  }

  Future<int> create({
    required String name,
    required String examType,
    required int academicYearId,
    int term = 1,
    required DateTime startsOn,
    required DateTime endsOn,
  }) {
    return db
        .into(db.exams)
        .insert(
          ExamsCompanion.insert(
            name: name,
            examType: Value(examType),
            academicYearId: academicYearId,
            term: Value(term),
            startsOn: startsOn,
            endsOn: endsOn,
          ),
        );
  }

  /// د یوې ازموینې مضمونونه — د هر ټولګي لپاره.
  ///
  /// **ولې «ټول مضمونونه» پخپله نه اضافه کوو؟** ځکه چې د یوې میاشتنۍ
  /// ازموینې لپاره ښايي یوازې درې مضمونه وي. که ټول پخپله راغلل،
  /// مدیر به يې پاکولو ته اړ و — او د نه‌لیکل شویو نمرو شمېر به يې
  /// غلط ښوده.
  Future<void> addSubjects({
    required int examId,
    required int gradeId,
    required List<int> subjectIds,
    int fullMark = 100,
    int passMark = 40,
  }) async {
    var order = 0;
    for (final sid in subjectIds) {
      await db
          .into(db.examSubjects)
          .insert(
            ExamSubjectsCompanion.insert(
              examId: examId,
              gradeId: gradeId,
              subjectId: sid,
              fullMark: Value(fullMark),
              passMark: Value(passMark),
              sortOrder: Value(order++),
            ),
            mode: InsertMode.insertOrIgnore,
          );
    }
  }

  Future<List<ExamSubjectRow>> subjectsOf(
    int examId, {
    int? gradeId,
  }) async {
    final rows = await db
        .customSelect(
          '''
SELECT es.*, s.name AS subject_name, g.name AS grade_name
FROM exam_subjects es
JOIN subjects s ON s.id = es.subject_id
JOIN grades g ON g.id = es.grade_id
WHERE es.exam_id = ? ${gradeId == null ? '' : 'AND es.grade_id = ?'}
ORDER BY g.level, es.sort_order
''',
          variables: [
            Variable<int>(examId),
            if (gradeId != null) Variable<int>(gradeId),
          ],
          readsFrom: {db.examSubjects, db.subjects, db.grades},
        )
        .get();

    return rows
        .map(
          (r) => ExamSubjectRow(
            examSubject: db.examSubjects.map(r.data),
            subjectName: r.read<String>('subject_name'),
            gradeName: r.read<String>('grade_name'),
          ),
        )
        .toList();
  }

  Future<void> publish(int examId, {required bool published}) {
    return (db.update(db.exams)..where((e) => e.id.equals(examId))).write(
      ExamsCompanion(
        isPublished: Value(published),
        publishedAt: Value(published ? DateTime.now() : null),
      ),
    );
  }

  // ── نمرې ────────────────────────────────────────────────

  /// د یوه مضمون د یوه بخش د نمرو لیکلو لیست.
  Future<List<MarkEntry>> markSheet({
    required int examSubjectId,
    required int sectionId,
  }) async {
    final rows = await db
        .customSelect(
          '''
SELECT s.*, e.roll_no AS roll_no,
       m.obtained AS obtained, m.is_absent AS is_absent,
       m.remarks AS remarks
FROM enrollments e
JOIN students s ON s.id = e.student_id AND s.deleted_at IS NULL
LEFT JOIN marks m ON m.student_id = s.id AND m.exam_subject_id = ?
WHERE e.section_id = ? AND e.is_active = 1
ORDER BY e.roll_no, s.first_name
''',
          variables: [
            Variable<int>(examSubjectId),
            Variable<int>(sectionId),
          ],
          readsFrom: {db.enrollments, db.students, db.marks},
        )
        .get();

    return rows
        .map(
          (r) => MarkEntry(
            student: db.students.map(r.data),
            rollNo: r.data['roll_no'] as int?,
            obtained: (r.data['obtained'] as num?)?.toDouble(),
            isAbsent: (r.data['is_absent'] as int? ?? 0) == 1,
            remarks: r.data['remarks'] as String?,
          ),
        )
        .toList();
  }

  /// ډله‌ییز ثبت — استاد ټوله کرښه ډکوي بیا یو ځل ساتي.
  Future<int> saveMarks({
    required int examSubjectId,
    required Map<int, ({double? obtained, bool isAbsent})> byStudent,
    required int byUserId,
  }) async {
    final subject = await (db.select(
      db.examSubjects,
    )..where((e) => e.id.equals(examSubjectId))).getSingle();

    var written = 0;
    await db.transaction(() async {
      for (final e in byStudent.entries) {
        final v = e.value;
        // **د بشپړې نمرې تر پورته نه منل کېږي.** یوه اضافي صفر
        // («۹۵۰» د «۹۵» پر ځای) به ټول اوسط خراب کړ او څوک به يې
        // نه پېژانده.
        final clamped = v.obtained?.clamp(0, subject.fullMark.toDouble()).toDouble();

        await db
            .into(db.marks)
            .insert(
              MarksCompanion.insert(
                examSubjectId: examSubjectId,
                studentId: e.key,
                obtained: Value(v.isAbsent ? null : clamped),
                isAbsent: Value(v.isAbsent),
                enteredByUserId: Value(byUserId),
                enteredAt: Value(DateTime.now()),
              ),
              onConflict: DoUpdate(
                (_) => MarksCompanion(
                  obtained: Value(v.isAbsent ? null : clamped),
                  isAbsent: Value(v.isAbsent),
                  enteredByUserId: Value(byUserId),
                  enteredAt: Value(DateTime.now()),
                ),
                target: [db.marks.examSubjectId, db.marks.studentId],
              ),
            );
        written++;
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'update',
              entity: 'marks',
              entityId: Value(examSubjectId),
              userId: Value(byUserId),
              changesJson: Value('{"count":$written}'),
            ),
          );
    });

    return written;
  }

  // ── پایلې ───────────────────────────────────────────────

  /// د یوه بخش بشپړه نتیجه، د درجې له مخې ترتیب شوې.
  ///
  /// **درجه‌بندي (rank) دلته کېږي، نه په SQL کې.** ولې؟ ځکه چې
  /// مساوي مجموعې باید **مساوي درجه** ولري — دوه شاګردان چې دواړه
  /// ۴۵۰ ولري، دواړه دویم دي، او راتلونکی څلورم. یوه ساده
  /// `ROW_NUMBER()` به يې دویم او دریم کړي، چې ناسمه ده.
  Future<List<StudentResult>> sectionResults({
    required int examId,
    required int sectionId,
  }) async {
    final rows = await db
        .customSelect(
          '''
SELECT s.id AS s_id, s.admission_no, s.first_name, s.last_name,
       s.father_name, s.gender, s.status AS s_status, s.card_version,
       s.admitted_on, s.created_at, s.updated_at,
       en.roll_no AS roll_no,
       sub.name AS subject_name,
       es.full_mark AS full_mark, es.pass_mark AS pass_mark,
       es.sort_order AS sort_order,
       m.obtained AS obtained, m.is_absent AS is_absent
FROM enrollments en
JOIN students s ON s.id = en.student_id AND s.deleted_at IS NULL
JOIN sections sec ON sec.id = en.section_id
JOIN exam_subjects es ON es.exam_id = ? AND es.grade_id = sec.grade_id
JOIN subjects sub ON sub.id = es.subject_id
LEFT JOIN marks m ON m.exam_subject_id = es.id AND m.student_id = s.id
WHERE en.section_id = ? AND en.is_active = 1
ORDER BY s.id, es.sort_order
''',
          variables: [Variable<int>(examId), Variable<int>(sectionId)],
          readsFrom: {
            db.enrollments,
            db.students,
            db.sections,
            db.examSubjects,
            db.subjects,
            db.marks,
          },
        )
        .get();

    // په شاګردانو ډلبندي.
    final byStudent = <int, List<QueryRow>>{};
    for (final r in rows) {
      byStudent.putIfAbsent(r.read<int>('s_id'), () => []).add(r);
    }

    final drafts = <({Student student, int? rollNo, List<SubjectResult> subs,
        double obtained, int full})>[];

    for (final entry in byStudent.entries) {
      final first = entry.value.first;
      final student = Student(
        id: first.read<int>('s_id'),
        admissionNo: first.read<String>('admission_no'),
        firstName: first.read<String>('first_name'),
        lastName: first.data['last_name'] as String?,
        fatherName: first.read<String>('father_name'),
        gender: first.read<String>('gender'),
        residency: 'day',
        status: first.read<String>('s_status'),
        cardVersion: first.read<int>('card_version'),
        admittedOn: first.read<DateTime>('admitted_on'),
        createdAt: first.read<DateTime>('created_at'),
        updatedAt: first.read<DateTime>('updated_at'),
      );

      final subs = <SubjectResult>[];
      var obtained = 0.0;
      var full = 0;
      for (final r in entry.value) {
        final mark = (r.data['obtained'] as num?)?.toDouble();
        final absent = (r.data['is_absent'] as int? ?? 0) == 1;
        final fm = r.read<int>('full_mark');

        subs.add(
          SubjectResult(
            subjectName: r.read<String>('subject_name'),
            fullMark: fm,
            passMark: r.read<int>('pass_mark'),
            obtained: mark,
            isAbsent: absent,
          ),
        );
        obtained += mark ?? 0;
        full += fm;
      }

      drafts.add((
        student: student,
        rollNo: first.data['roll_no'] as int?,
        subs: subs,
        obtained: obtained,
        full: full,
      ));
    }

    drafts.sort((a, b) => b.obtained.compareTo(a.obtained));

    final out = <StudentResult>[];
    var rank = 0;
    double? lastTotal;
    for (var i = 0; i < drafts.length; i++) {
      final d = drafts[i];
      // مساوي مجموعه = مساوي درجه.
      if (lastTotal == null || d.obtained != lastTotal) {
        rank = i + 1;
        lastTotal = d.obtained;
      }
      out.add(
        StudentResult(
          student: d.student,
          rollNo: d.rollNo,
          subjects: d.subs,
          obtainedTotal: d.obtained,
          fullTotal: d.full,
          rank: rank,
          outOf: drafts.length,
        ),
      );
    }
    return out;
  }

  /// د یوه شاګرد کارنامه.
  Future<StudentResult?> studentResult({
    required int examId,
    required int studentId,
  }) async {
    final enrollment =
        await (db.select(db.enrollments)
              ..where((e) => e.studentId.equals(studentId))
              ..where((e) => e.isActive.equals(true))
              ..limit(1))
            .getSingleOrNull();
    if (enrollment == null) return null;

    final all = await sectionResults(
      examId: examId,
      sectionId: enrollment.sectionId,
    );
    for (final r in all) {
      if (r.student.id == studentId) return r;
    }
    return null;
  }

  /// د یوه شاګرد ټولې **خپرې شوې** پایلې — د والدینو اپ يې راښکي.
  ///
  /// **ولې یوازې خپرې شوې؟** ځکه چې یوه نیمګړې لیکل شوې نمره د کور
  /// خوا ته د اندېښنې لامل کېږي. مدیر پرېکړه کوي چې کله يې وګوري.
  Future<List<({Exam exam, StudentResult result})>> publishedResultsFor(
    int studentId,
  ) async {
    final rows = await db
        .customSelect(
          '''
SELECT DISTINCT e.id AS exam_id
FROM exams e
JOIN exam_subjects es ON es.exam_id = e.id
JOIN marks m ON m.exam_subject_id = es.id AND m.student_id = ?
WHERE e.is_published = 1 AND e.deleted_at IS NULL
ORDER BY e.starts_on DESC
''',
          variables: [Variable<int>(studentId)],
          readsFrom: {db.exams, db.examSubjects, db.marks},
        )
        .get();

    final out = <({Exam exam, StudentResult result})>[];
    for (final r in rows) {
      final examId = r.read<int>('exam_id');
      final result = await studentResult(examId: examId, studentId: studentId);
      if (result == null) continue;
      final exam = await (db.select(
        db.exams,
      )..where((e) => e.id.equals(examId))).getSingle();
      out.add((exam: exam, result: result));
    }
    return out;
  }

  /// د یوه مضمون د ټولګي انځور.
  Future<List<SubjectStats>> subjectStats({
    required int examId,
    required int sectionId,
  }) async {
    final rows = await db
        .customSelect(
          '''
SELECT sub.name AS subject_name, es.full_mark AS full_mark,
       AVG(CASE WHEN m.is_absent = 0 THEN m.obtained END) AS avg_mark,
       MAX(CASE WHEN m.is_absent = 0 THEN m.obtained END) AS max_mark,
       MIN(CASE WHEN m.is_absent = 0 THEN m.obtained END) AS min_mark,
       SUM(CASE WHEN m.is_absent = 0 AND m.obtained >= es.pass_mark
                THEN 1 ELSE 0 END) AS passed,
       SUM(CASE WHEN m.is_absent = 0 AND m.obtained < es.pass_mark
                THEN 1 ELSE 0 END) AS failed,
       SUM(CASE WHEN m.is_absent = 1 THEN 1 ELSE 0 END) AS absent
FROM enrollments en
JOIN sections sec ON sec.id = en.section_id
JOIN exam_subjects es ON es.exam_id = ? AND es.grade_id = sec.grade_id
JOIN subjects sub ON sub.id = es.subject_id
LEFT JOIN marks m ON m.exam_subject_id = es.id AND m.student_id = en.student_id
WHERE en.section_id = ? AND en.is_active = 1
GROUP BY es.id
ORDER BY es.sort_order
''',
          variables: [Variable<int>(examId), Variable<int>(sectionId)],
          readsFrom: {
            db.enrollments,
            db.sections,
            db.examSubjects,
            db.subjects,
            db.marks,
          },
        )
        .get();

    return rows
        .map(
          (r) => SubjectStats(
            subjectName: r.read<String>('subject_name'),
            fullMark: r.read<int>('full_mark'),
            average: (r.data['avg_mark'] as num?)?.toDouble() ?? 0,
            highest: (r.data['max_mark'] as num?)?.toDouble() ?? 0,
            lowest: (r.data['min_mark'] as num?)?.toDouble() ?? 0,
            passed: r.read<int>('passed'),
            failed: r.read<int>('failed'),
            absent: r.read<int>('absent'),
          ),
        )
        .toList();
  }

  // ═════════════════════════════════════════════════════════
  //  د پایلو انجن — یو فلټر، څو پوښتنې
  // ═════════════════════════════════════════════════════════

  /// **د پایلو نرمه پوښتنه.** د `ResultFilter` له مخې یا یو ټولګی
  /// له ټولو مضامینو سره راوړي، یا یو مضمون له ټولو ټولګیو سره.
  Future<List<ResultRow>> results({
    required int examId,
    ResultFilter filter = const ResultFilter(),
  }) async {
    final where = <String>['en.is_active = 1', 's.deleted_at IS NULL'];
    final args = <Variable<Object>>[Variable<int>(examId)];

    if (filter.gradeId != null) {
      where.add('sec.grade_id = ?');
      args.add(Variable<int>(filter.gradeId!));
    }
    if (filter.subjectId != null) {
      where.add('es.subject_id = ?');
      args.add(Variable<int>(filter.subjectId!));
    }
    final q = filter.query.trim();
    if (q.isNotEmpty) {
      where.add(
        '(s.first_name LIKE ? OR s.last_name LIKE ? '
        'OR s.father_name LIKE ? OR s.admission_no LIKE ?)',
      );
      final like = '%${Numerals.toLatin(q)}%';
      args.addAll(List.filled(4, Variable<String>(like)));
    }

    final rows = await db
        .customSelect(
          '''
SELECT s.*, en.roll_no AS roll_no,
       g.name AS grade_name, sec.name AS section_name,
       sub.name AS subject_name,
       es.full_mark AS full_mark, es.pass_mark AS pass_mark,
       es.sort_order AS sort_order,
       m.obtained AS obtained, m.is_absent AS is_absent
FROM enrollments en
JOIN students s ON s.id = en.student_id
JOIN sections sec ON sec.id = en.section_id
JOIN grades g ON g.id = sec.grade_id
JOIN exam_subjects es ON es.exam_id = ? AND es.grade_id = sec.grade_id
JOIN subjects sub ON sub.id = es.subject_id
LEFT JOIN marks m ON m.exam_subject_id = es.id AND m.student_id = s.id
WHERE ${where.join(' AND ')}
ORDER BY g.sort_order, g.level, sec.name, s.id, es.sort_order
''',
          variables: args,
          readsFrom: {
            db.enrollments,
            db.students,
            db.sections,
            db.grades,
            db.examSubjects,
            db.subjects,
            db.marks,
          },
        )
        .get();

    // په شاګردانو ډلبندي — د SQL کرښې یو شاګرد څو ځله راوړي،
    // د هر مضمون لپاره یوه.
    final order = <int>[];
    final byStudent = <int, List<QueryRow>>{};
    for (final r in rows) {
      final id = r.read<int>('id');
      if (!byStudent.containsKey(id)) order.add(id);
      byStudent.putIfAbsent(id, () => []).add(r);
    }

    final drafts = <ResultRow>[];
    for (final id in order) {
      final group = byStudent[id]!;
      final first = group.first;

      final subs = <SubjectResult>[];
      var obtained = 0.0;
      var full = 0;
      for (final r in group) {
        final mark = (r.data['obtained'] as num?)?.toDouble();
        final fm = r.read<int>('full_mark');
        subs.add(
          SubjectResult(
            subjectName: r.read<String>('subject_name'),
            fullMark: fm,
            passMark: r.read<int>('pass_mark'),
            obtained: mark,
            isAbsent: (r.data['is_absent'] as int? ?? 0) == 1,
          ),
        );
        obtained += mark ?? 0;
        full += fm;
      }

      drafts.add(
        ResultRow(
          student: db.students.map(first.data),
          gradeName: first.data['grade_name'] as String?,
          sectionName: first.data['section_name'] as String?,
          rollNo: first.data['roll_no'] as int?,
          subjects: subs,
          obtained: obtained,
          full: full,
          rank: 0,
        ),
      );
    }

    // د پایلې فلټر **له راټولولو وروسته** پلی کېږي — ځکه چې
    // «ناکام» د ټولو مضامینو له مخې ټاکل کېږي، نه د یوې کرښې.
    final filtered = drafts
        .where(
          (d) => switch (filter.outcome) {
            'passed' => d.passedAll,
            'failed' => d.failed.isNotEmpty && !d.anyAbsent,
            'absent' => d.anyAbsent,
            _ => true,
          },
        )
        .toList();

    // **درجه‌بندي تل د نمرو له مخې ده**، که څه هم لیست بیا په نامه
    // ترتیب شي. که نه، «دویم» به د ترتیب په بدلولو سره بدلېده.
    final ranked = [...filtered]
      ..sort((a, b) => b.obtained.compareTo(a.obtained));
    final rankOf = <int, int>{};
    var rank = 0;
    double? last;
    for (var i = 0; i < ranked.length; i++) {
      if (last == null || ranked[i].obtained != last) {
        rank = i + 1;
        last = ranked[i].obtained;
      }
      rankOf[ranked[i].student.id] = rank;
    }

    final out = [
      for (final d in filtered)
        ResultRow(
          student: d.student,
          gradeName: d.gradeName,
          sectionName: d.sectionName,
          rollNo: d.rollNo,
          subjects: d.subjects,
          obtained: d.obtained,
          full: d.full,
          rank: rankOf[d.student.id] ?? 0,
        ),
    ];

    switch (filter.sort) {
      case 'name':
        out.sort((a, b) => a.fullName.compareTo(b.fullName));
      case 'roll':
        out.sort((a, b) => (a.rollNo ?? 9999).compareTo(b.rollNo ?? 9999));
      default:
        out.sort((a, b) => a.rank.compareTo(b.rank));
    }
    return out;
  }

  /// د نمرو د ثبت لیست — یو مضمون، یو ټولګی (ټول بخشونه).
  ///
  /// **ولې د بخش پر ځای ټولګی؟** ځکه چې د «لسم — الف» او «لسم — ب»
  /// ریاضي یوه ازموینه ده. که هر بخش جلا ډکېده، استاد به دوه ځله
  /// هماغه پاڼه پرانیستله.
  Future<List<MarkEntry>> markSheetForGrade({
    required int examId,
    required int gradeId,
    required int subjectId,
    String query = '',
  }) async {
    final es = await examSubjectFor(
      examId: examId,
      gradeId: gradeId,
      subjectId: subjectId,
    );
    if (es == null) return const [];

    final where = <String>['en.is_active = 1', 's.deleted_at IS NULL'];
    final args = <Variable<Object>>[
      Variable<int>(es.id),
      Variable<int>(gradeId),
    ];
    final q = query.trim();
    if (q.isNotEmpty) {
      where.add(
        '(s.first_name LIKE ? OR s.last_name LIKE ? '
        'OR s.father_name LIKE ? OR s.admission_no LIKE ?)',
      );
      final like = '%${Numerals.toLatin(q)}%';
      args.addAll(List.filled(4, Variable<String>(like)));
    }

    final rows = await db
        .customSelect(
          '''
SELECT s.*, en.roll_no AS roll_no,
       g.name || ' — ' || sec.name AS class_name,
       m.obtained AS obtained, m.is_absent AS is_absent, m.remarks AS remarks
FROM enrollments en
JOIN students s ON s.id = en.student_id
JOIN sections sec ON sec.id = en.section_id
JOIN grades g ON g.id = sec.grade_id
LEFT JOIN marks m ON m.student_id = s.id AND m.exam_subject_id = ?
WHERE sec.grade_id = ? AND ${where.join(' AND ')}
ORDER BY sec.name, en.roll_no, s.first_name
''',
          variables: args,
          readsFrom: {
            db.enrollments,
            db.students,
            db.sections,
            db.grades,
            db.marks,
          },
        )
        .get();

    return rows
        .map(
          (r) => MarkEntry(
            student: db.students.map(r.data),
            rollNo: r.data['roll_no'] as int?,
            obtained: (r.data['obtained'] as num?)?.toDouble(),
            isAbsent: (r.data['is_absent'] as int? ?? 0) == 1,
            remarks: r.data['remarks'] as String?,
            className: r.data['class_name'] as String?,
          ),
        )
        .toList();
  }

  /// د یوه ټولګي/مضمون د `exam_subjects` کرښه — د ثبت لپاره پکار ده.
  Future<ExamSubject?> examSubjectFor({
    required int examId,
    required int gradeId,
    required int subjectId,
  }) {
    return (db.select(db.examSubjects)
          ..where((e) => e.examId.equals(examId))
          ..where((e) => e.gradeId.equals(gradeId))
          ..where((e) => e.subjectId.equals(subjectId))
          ..limit(1))
        .getSingleOrNull();
  }

  // ═════════════════════════════════════════════════════════
  //  ممتاز شاګردان
  // ═════════════════════════════════════════════════════════

  /// **د ښوونځي په کچه لومړي کسان.**
  ///
  /// دلته «سلنه» پرتله کېږي، نه خامې نمرې — ځکه چې یو ټولګی ښايي
  /// شپږ مضامین ولري او بل اته. که خامې مجموعې پرتله کېدلې، د اتو
  /// مضامینو ټولګی به تل ګټلې وه.
  Future<List<TopStudent>> topOverall({
    required int examId,
    int limit = 5,
  }) async {
    final all = await results(examId: examId);
    return _rankTop(all, limit);
  }

  /// د هر ټولګي لومړي کسان — کلی د ټولګي `id` دی.
  Future<Map<int, List<TopStudent>>> topPerGrade({
    required int examId,
    int limit = 3,
  }) async {
    final grades = await db.select(db.grades).get();
    final out = <int, List<TopStudent>>{};
    for (final g in grades) {
      final rows = await results(
        examId: examId,
        filter: ResultFilter(gradeId: g.id),
      );
      final top = _rankTop(rows, limit, gradeId: g.id);
      if (top.isNotEmpty) out[g.id] = top;
    }
    return out;
  }

  static List<TopStudent> _rankTop(
    List<ResultRow> rows,
    int limit, {
    int? gradeId,
  }) {
    // یوازې هغه چې لږ تر لږه یوه نمره لري — تش ریکارډونه «لومړی»
    // نه کېږي.
    final scored =
        rows
            .where(
              (r) => r.full > 0 && r.subjects.any((s) => s.obtained != null),
            )
            .toList()
          ..sort((a, b) => b.percent.compareTo(a.percent));

    final out = <TopStudent>[];
    var position = 0;
    double? last;
    for (var i = 0; i < scored.length; i++) {
      // **مساوي سلنه = مساوي ځای**، نو که دوه کسان دواړه پنځم وي،
      // دواړه ښکاري — یو يې د لیست د پولې له امله نه غورځي.
      if (out.length >= limit && scored[i].percent != last) break;
      if (last == null || scored[i].percent != last) {
        position = i + 1;
        last = scored[i].percent;
      }
      out.add(
        TopStudent(
          student: scored[i].student,
          className: scored[i].className,
          gradeId: gradeId,
          percent: scored[i].percent,
          obtained: scored[i].obtained,
          full: scored[i].full,
          position: position,
        ),
      );
    }
    return out;
  }

  // ═════════════════════════════════════════════════════════
  //  د دواړو ازموینو جمع
  // ═════════════════════════════════════════════════════════

  /// **د څو ازموینو راټوله شوې پایله.**
  ///
  /// په ډېرو ښوونځیو کې د کال نمره ۱۰۰ ده: څلورنیم‌میاشتنۍ ازموینه
  /// تر ۴۰ او کلنۍ تر ۶۰. دلته هره ازموینه خپل `weightPercent` لري،
  /// او د شاګرد سلنه پر هغه وزن ضربېږي:
  ///
  /// ```
  /// د کال نمره = Σ (د ازموینې سلنه ÷ ۱۰۰ × د ازموینې وزن)
  /// ```
  ///
  /// **ولې سلنه او نه خامه نمره؟** ځکه چې یوه ازموینه ښايي له ۳۰۰
  /// وي او بله له ۶۰۰. خامې مجموعې راټولول به دویمې ته دوه ځله وزن
  /// ورکړی و — پرته له دې چې چا يې غوښتي وي.
  Future<List<CombinedResult>> combined({
    required List<int> examIds,
    int? gradeId,
    String query = '',
    String sort = 'rank',
  }) async {
    if (examIds.isEmpty) return const [];

    final exams = <Exam>[];
    for (final id in examIds) {
      final e = await byId(id);
      if (e != null) exams.add(e);
    }
    if (exams.isEmpty) return const [];

    // هره ازموینه یو ځل لوستل کېږي، بیا په شاګردانو ډلبندي.
    final byStudent = <int, Map<int, ResultRow>>{};
    final meta = <int, ({String className, int? rollNo, Student student})>{};

    for (final e in exams) {
      final rows = await results(
        examId: e.id,
        filter: ResultFilter(gradeId: gradeId, query: query),
      );
      for (final r in rows) {
        byStudent.putIfAbsent(r.student.id, () => {})[e.id] = r;
        meta[r.student.id] = (
          className: r.className,
          rollNo: r.rollNo,
          student: r.student,
        );
      }
    }

    final drafts = <CombinedResult>[];
    for (final entry in byStudent.entries) {
      final m = meta[entry.key]!;
      final parts =
          <({Exam exam, double scaled, double percent, bool hasMarks})>[];
      var total = 0.0;

      for (final e in exams) {
        final r = entry.value[e.id];
        final has = r != null && r.subjects.any((s) => s.obtained != null);
        final percent = r?.percent ?? 0;
        final scaled = percent / 100 * e.weightPercent;
        parts.add((exam: e, scaled: scaled, percent: percent, hasMarks: has));
        total += scaled;
      }

      drafts.add(
        CombinedResult(
          student: m.student,
          className: m.className,
          rollNo: m.rollNo,
          parts: parts,
          total: total,
          rank: 0,
        ),
      );
    }

    drafts.sort((a, b) => b.total.compareTo(a.total));
    final out = <CombinedResult>[];
    var rank = 0;
    double? last;
    for (var i = 0; i < drafts.length; i++) {
      if (last == null || drafts[i].total != last) {
        rank = i + 1;
        last = drafts[i].total;
      }
      out.add(
        CombinedResult(
          student: drafts[i].student,
          className: drafts[i].className,
          rollNo: drafts[i].rollNo,
          parts: drafts[i].parts,
          total: drafts[i].total,
          rank: rank,
        ),
      );
    }

    if (sort == 'name') {
      out.sort((a, b) => a.fullName.compareTo(b.fullName));
    }
    return out;
  }

  // ═════════════════════════════════════════════════════════
  //  د ازموینې اداره
  // ═════════════════════════════════════════════════════════

  Future<Exam?> byId(int id) =>
      (db.select(db.exams)..where((e) => e.id.equals(id))).getSingleOrNull();

  Future<void> update({
    required int id,
    String? name,
    String? examType,
    int? term,
    int? weightPercent,
    DateTime? startsOn,
    DateTime? endsOn,
  }) {
    return (db.update(db.exams)..where((e) => e.id.equals(id))).write(
      ExamsCompanion(
        name: name == null ? const Value.absent() : Value(name),
        examType: examType == null ? const Value.absent() : Value(examType),
        term: term == null ? const Value.absent() : Value(term),
        weightPercent: weightPercent == null
            ? const Value.absent()
            : Value(weightPercent),
        startsOn: startsOn == null ? const Value.absent() : Value(startsOn),
        endsOn: endsOn == null ? const Value.absent() : Value(endsOn),
      ),
    );
  }

  /// **ازموینه چې نمرې ولري، نه ړنګېږي.**
  ///
  /// که ړنګه شوې وای، د یوې غلطې کېکاږنې سره به د سلګونو شاګردانو
  /// نمرې له منځه تللې وې — او هېڅ بېرته راګرځېدل يې نه و. نو
  /// مخکې شمېر کتل کېږي؛ پرته له نمرو خو ړنګېږي.
  Future<String?> remove(int examId) async {
    final row = await db
        .customSelect(
          '''
SELECT COUNT(*) AS c FROM marks
WHERE exam_subject_id IN (SELECT id FROM exam_subjects WHERE exam_id = ?)
''',
          variables: [Variable<int>(examId)],
          readsFrom: {db.marks, db.examSubjects},
        )
        .getSingle();

    if (row.read<int>('c') > 0) {
      return 'دې ازموینې کې نمرې ثبت شوې — ړنګېدی نه شي. '
          'پر ځای يې نوم او نېټې بدلولی شئ.';
    }

    await db.transaction(() async {
      await (db.delete(db.examSubjects)..where((e) => e.examId.equals(examId)))
          .go();
      await (db.delete(db.exams)..where((e) => e.id.equals(examId))).go();
    });
    return null;
  }

  /// د یوې ازموینې مضامین له سره ټاکي — زاړه چې نمرې نه لري، ځي.
  Future<String?> setSubjects({
    required int examId,
    required Map<int, List<int>> subjectsByGrade,
    int fullMark = 100,
    int passMark = 40,
  }) async {
    final existing = await (db.select(
      db.examSubjects,
    )..where((e) => e.examId.equals(examId))).get();

    final wanted = <String>{
      for (final e in subjectsByGrade.entries)
        for (final s in e.value) '${e.key}:$s',
    };

    for (final e in existing) {
      if (wanted.contains('${e.gradeId}:${e.subjectId}')) continue;
      final marks = await (db.select(
        db.marks,
      )..where((m) => m.examSubjectId.equals(e.id))).get();
      if (marks.isNotEmpty) {
        return 'یو مضمون چې نمرې لري، له ازموینې نه ایستل کېږي.';
      }
      await (db.delete(db.examSubjects)..where((x) => x.id.equals(e.id))).go();
    }

    for (final entry in subjectsByGrade.entries) {
      await addSubjects(
        examId: examId,
        gradeId: entry.key,
        subjectIds: entry.value,
        fullMark: fullMark,
        passMark: passMark,
      );
    }
    return null;
  }
}
