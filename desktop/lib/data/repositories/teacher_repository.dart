import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../db/database.dart';
import 'student_repository.dart' show Paged;

/// یو استاد له هغو بخشونو سره چې مشري يې کوي.
class TeacherRow {
  final Teacher teacher;

  /// هغه بخشونه چې دی يې مشر استاد دی — «لسم — الف، نهم — ب».
  final String homeroomOf;

  const TeacherRow({required this.teacher, required this.homeroomOf});
}

/// یو بخش چې دا استاد يې مشر دی.
class HomeroomSection {
  final int sectionId;
  final String gradeName;
  final String sectionName;
  final int students;

  const HomeroomSection({
    required this.sectionId,
    required this.gradeName,
    required this.sectionName,
    required this.students,
  });

  String get label => '$gradeName — $sectionName';
}

/// یو مضمون چې دا استاد يې ورکوي، په یوه ټولګي کې.
class TeachingLoad {
  final int subjectId;
  final String subjectName;
  final String? gradeName;
  final String? sectionName;
  final int periods;

  const TeachingLoad({
    required this.subjectId,
    required this.subjectName,
    required this.periods,
    this.gradeName,
    this.sectionName,
  });

  String get classLabel => [
    if (gradeName != null) gradeName!,
    if (sectionName != null) sectionName!,
  ].join(' — ');
}

/// د یوه استاد بشپړ پروفایل.
class TeacherProfile {
  final Teacher teacher;
  final List<HomeroomSection> homeroom;
  final List<TeachingLoad> load;
  final DateTime attendanceMonth;

  /// د میاشتې ورځ → حالت.
  final Map<int, String> attendance;

  const TeacherProfile({
    required this.teacher,
    required this.homeroom,
    required this.load,
    required this.attendanceMonth,
    required this.attendance,
  });

  int get weeklyPeriods => load.fold(0, (a, b) => a + b.periods);

  /// څو بېل مضامین ورکوي — نه څو کرښې.
  int get subjectCount => load.map((l) => l.subjectId).toSet().length;
}

class TeacherFilter {
  final String query;
  final String? status;
  final String? gender;

  /// یو ځانګړی تخصص — «ریاضي».
  final String? specialization;

  /// یوه ځانګړې زده‌کړه — «لیسانس».
  final String? qualification;

  /// `true` = یوازې هغه چې د بخش مشري کوي، `false` = یوازې هغه چې نه کوي.
  final bool? homeroom;

  /// یو ځانګړی مضمون ورکوي (د مهالویش له مخې).
  final int? subjectId;

  /// `name` | `salary` | `hired`
  final String sort;
  final bool descending;

  const TeacherFilter({
    this.query = '',
    this.status = 'active',
    this.gender,
    this.specialization,
    this.qualification,
    this.homeroom,
    this.subjectId,
    this.sort = 'name',
    this.descending = false,
  });

  /// څومره فلټرونه فعال دي — د تڼۍ د شمېرې لپاره.
  ///
  /// **`status` ولې نه شمېرل کېږي کله چې `active` وي؟** ځکه چې دا
  /// تلواله ده. که شمېرل کېده، پاڼه به تل «۱ فلټر فعال» ښودل او
  /// کارن به يې لټاوه چې کوم دی.
  int get activeCount => [
    if (status != null && status != 'active') status,
    gender,
    specialization,
    qualification,
    homeroom,
    subjectId,
  ].whereType<Object>().length;

  /// **یوازې پرمختللي فلټرونه** — تخصص پکې نشته، ځکه چې هغه پر
  /// پورتنۍ کرښه ښکاره ولاړ دی او خپل حال پخپله ښیي.
  int get advancedCount => [
    if (status != null && status != 'active') status,
    gender,
    qualification,
    homeroom,
    subjectId,
  ].whereType<Object>().length;

  TeacherFilter copyWith({
    String? query,
    String? status,
    String? gender,
    String? specialization,
    String? qualification,
    bool? homeroom,
    int? subjectId,
    String? sort,
    bool? descending,
    bool clearStatus = false,
    bool clearGender = false,
    bool clearSpecialization = false,
    bool clearQualification = false,
    bool clearHomeroom = false,
    bool clearSubject = false,
  }) => TeacherFilter(
    query: query ?? this.query,
    status: clearStatus ? null : (status ?? this.status),
    gender: clearGender ? null : (gender ?? this.gender),
    specialization: clearSpecialization
        ? null
        : (specialization ?? this.specialization),
    qualification: clearQualification
        ? null
        : (qualification ?? this.qualification),
    homeroom: clearHomeroom ? null : (homeroom ?? this.homeroom),
    subjectId: clearSubject ? null : (subjectId ?? this.subjectId),
    sort: sort ?? this.sort,
    descending: descending ?? this.descending,
  );
}

class TeacherRepository {
  final AppDatabase db;
  TeacherRepository(this.db);

  Future<Paged<TeacherRow>> list({
    TeacherFilter filter = const TeacherFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    final where = <String>['t.deleted_at IS NULL'];
    final args = <Variable<Object>>[];

    if (filter.status != null) {
      where.add('t.status = ?');
      args.add(Variable<String>(filter.status!));
    }
    if (filter.gender != null) {
      where.add('t.gender = ?');
      args.add(Variable<String>(filter.gender!));
    }
    if (filter.specialization != null) {
      where.add('t.specialization = ?');
      args.add(Variable<String>(filter.specialization!));
    }
    if (filter.qualification != null) {
      where.add('t.qualification = ?');
      args.add(Variable<String>(filter.qualification!));
    }
    if (filter.homeroom != null) {
      // **`EXISTS`، نه `JOIN`.** یو استاد کېدای شي د دوو بخشونو مشر
      // وي — یو `JOIN` به يې دوه ځله راوړی و او شمېره به يې خرابه
      // کړې وه.
      final not = filter.homeroom! ? '' : 'NOT ';
      where.add(
        '${not}EXISTS (SELECT 1 FROM sections sec '
        'WHERE sec.head_teacher_id = t.id)',
      );
    }
    if (filter.subjectId != null) {
      where.add(
        'EXISTS (SELECT 1 FROM timetable_entries te '
        'WHERE te.teacher_id = t.id AND te.subject_id = ?)',
      );
      args.add(Variable<int>(filter.subjectId!));
    }

    final q = filter.query.trim();
    if (q.isNotEmpty) {
      final needle = '%${Numerals.toLatin(q)}%';
      where.add(
        '(t.employee_no LIKE ? OR t.full_name LIKE ? '
        'OR t.phone LIKE ? OR t.specialization LIKE ?)',
      );
      for (var i = 0; i < 4; i++) {
        args.add(Variable<String>(needle));
      }
    }

    final whereSql = 'WHERE ${where.join(' AND ')}';

    // **د ترتیب کلمه له لیسټه راځي، نه له کارنه.** که مستقیم د
    // کارن متن دننه شوی وای، دا به د SQL انجیکشن دروازه وه.
    final dir = filter.descending ? 'DESC' : 'ASC';
    final orderSql = switch (filter.sort) {
      // NULL معاش تل وروستی — نه دا چې د صفر پر ځای وشمېرل شي.
      'salary' =>
        'ORDER BY t.monthly_salary IS NULL, t.monthly_salary $dir, t.full_name',
      'hired' => 'ORDER BY t.hired_on IS NULL, t.hired_on $dir, t.full_name',
      _ => 'ORDER BY t.full_name $dir',
    };

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM teachers t $whereSql',
          variables: args,
          readsFrom: {db.teachers},
        )
        .getSingle();

    // د مشرۍ بخشونه په یوه فرعي پوښتنه کې راټولوو — پر هر استاد
    // یوه جلا پوښتنه به د ۵۰ کرښو لپاره ۵۰ ځله ډیټابیس وهله.
    final rows = await db
        .customSelect(
          '''
SELECT t.*,
  COALESCE((
    SELECT GROUP_CONCAT(g.name || ' — ' || sec.name, '، ')
    FROM sections sec
    JOIN grades g ON g.id = sec.grade_id
    WHERE sec.head_teacher_id = t.id
  ), '') AS homeroom_of
FROM teachers t
$whereSql
$orderSql
LIMIT ? OFFSET ?
''',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {
            db.teachers,
            db.sections,
            db.grades,
            db.timetableEntries,
          },
        )
        .get();

    return Paged(
      rows
          .map(
            (r) => TeacherRow(
              teacher: db.teachers.map(r.data),
              homeroomOf: r.data['homeroom_of'] as String? ?? '',
            ),
          )
          .toList(),
      countRow.read<int>('c'),
    );
  }

  /// هغه تخصصونه چې واقعاً په ډیټابیس کې شته.
  ///
  /// **ولې له ډیټابیسه، نه یو ثابت لیست؟** ځکه چې یوه مدرسه «فقه»
  /// او «تفسیر» لري، یوه لیسه «فزیک» او «کیمیا». یو ثابت لیست به
  /// یوه ته اضافي او بلې ته نیمګړی و.
  Future<List<String>> specializations() async {
    final rows = await db
        .customSelect(
          'SELECT DISTINCT specialization FROM teachers '
          'WHERE deleted_at IS NULL AND specialization IS NOT NULL '
          "AND specialization != '' ORDER BY specialization",
          readsFrom: {db.teachers},
        )
        .get();
    return rows.map((r) => r.read<String>('specialization')).toList();
  }

  Future<List<String>> qualifications() async {
    final rows = await db
        .customSelect(
          'SELECT DISTINCT qualification FROM teachers '
          'WHERE deleted_at IS NULL AND qualification IS NOT NULL '
          "AND qualification != '' ORDER BY qualification",
          readsFrom: {db.teachers},
        )
        .get();
    return rows.map((r) => r.read<String>('qualification')).toList();
  }

  Future<Teacher?> byId(int id) => (db.select(
    db.teachers,
  )..where((t) => t.id.equals(id))).getSingleOrNull();

  /// د یوه استاد سمون.
  Future<void> update({
    required int id,
    required TeachersCompanion patch,
    required int byUserId,
    required String byUserName,
  }) async {
    await db.transaction(() async {
      await (db.update(db.teachers)..where((t) => t.id.equals(id))).write(
        patch,
      );
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'update',
              entity: 'teachers',
              entityId: Value(id),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );
    });
  }

  /// د یوه استاد بشپړ پروفایل — مضامین، مهالویش، مشري، حاضري.
  Future<TeacherProfile?> profile(int id, {DateTime? month}) async {
    final teacher = await byId(id);
    if (teacher == null) return null;

    final homeroom = await db
        .customSelect(
          '''
SELECT g.name AS grade_name, sec.name AS section_name, sec.id AS section_id,
  (SELECT COUNT(*) FROM enrollments e
   WHERE e.section_id = sec.id AND e.is_active = 1) AS students
FROM sections sec
JOIN grades g ON g.id = sec.grade_id
WHERE sec.head_teacher_id = ?
ORDER BY g.level, sec.name
''',
          variables: [Variable<int>(id)],
          readsFrom: {db.sections, db.grades, db.enrollments},
        )
        .get();

    // د مهالویش له مخې — کوم مضامین، په کومو ټولګیو کې، څو ساعته.
    final load = await db
        .customSelect(
          '''
SELECT sub.name AS subject_name, sub.id AS subject_id,
  g.name AS grade_name, sec.name AS section_name,
  COUNT(*) AS periods
FROM timetable_entries te
JOIN subjects sub ON sub.id = te.subject_id
JOIN sections sec ON sec.id = te.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE te.teacher_id = ?
GROUP BY sub.id, sec.id, g.id
ORDER BY sub.name, g.level, sec.name
''',
          variables: [Variable<int>(id)],
          readsFrom: {
            db.timetableEntries,
            db.subjects,
            db.sections,
            db.grades,
          },
        )
        .get();

    final at = month ?? DateTime.now();
    final start = DateTime(at.year, at.month, 1);
    final end = DateTime(at.year, at.month + 1, 0);
    final marks = await db
        .customSelect(
          'SELECT date, status FROM staff_attendances '
          "WHERE person_kind = 'teacher' AND person_id = ? "
          'AND date >= ? AND date <= ?',
          variables: [
            Variable<int>(id),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
          ],
          readsFrom: {db.staffAttendances},
        )
        .get();

    return TeacherProfile(
      teacher: teacher,
      homeroom: [
        for (final r in homeroom)
          HomeroomSection(
            sectionId: r.read<int>('section_id'),
            gradeName: r.read<String>('grade_name'),
            sectionName: r.read<String>('section_name'),
            students: r.read<int>('students'),
          ),
      ],
      load: [
        for (final r in load)
          TeachingLoad(
            subjectId: r.read<int>('subject_id'),
            subjectName: r.read<String>('subject_name'),
            gradeName: r.data['grade_name'] as String?,
            sectionName: r.data['section_name'] as String?,
            periods: r.read<int>('periods'),
          ),
      ],
      attendanceMonth: DateTime(at.year, at.month),
      attendance: {
        for (final r in marks)
          DateTime.fromMillisecondsSinceEpoch(
            r.read<int>('date') * 1000,
            isUtc: true,
          ).toLocal().day: r.read<String>('status'),
      },
    );
  }

  /// راتلونکی د کارمند نمبر — «T-0001».
  Future<String> nextEmployeeNo() async {
    final row = await db
        .customSelect(
          "SELECT employee_no FROM teachers WHERE employee_no LIKE 'T-%' "
          'ORDER BY employee_no DESC LIMIT 1',
          readsFrom: {db.teachers},
        )
        .getSingleOrNull();

    var next = 1;
    if (row != null) {
      final last = row.read<String>('employee_no').split('-').last;
      next = (int.tryParse(last) ?? 0) + 1;
    }
    return 'T-${next.toString().padLeft(4, '0')}';
  }

  Future<int> add({
    required TeachersCompanion teacher,
    required int byUserId,
    required String byUserName,
  }) {
    return db.transaction(() async {
      final id = await db.into(db.teachers).insert(teacher);
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'teachers',
              entityId: Value(id),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );
      return id;
    });
  }

  Future<void> softDelete(
    int id, {
    required int byUserId,
    required String byUserName,
  }) async {
    await db.transaction(() async {
      // مخکې له پټولو، د مشرۍ تړاو پرې کوو — که نه، بخش به یوه
      // پټ استاد ته اشاره کوله او د ټولګیو پاڼه به تشه ښودله.
      await db.customUpdate(
        'UPDATE sections SET head_teacher_id = NULL WHERE head_teacher_id = ?',
        variables: [Variable<int>(id)],
        updates: {db.sections},
      );
      await (db.update(db.teachers)..where((t) => t.id.equals(id))).write(
        TeachersCompanion(deletedAt: Value(DateTime.now())),
      );
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'delete',
              entity: 'teachers',
              entityId: Value(id),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );
    });
  }

  /// د یوه بخش مشر استاد ټاکل (یا پرې کول، که `teacherId` تش وي).
  Future<void> assignHomeroom({
    required int sectionId,
    required int? teacherId,
  }) async {
    await (db.update(db.sections)..where((s) => s.id.equals(sectionId))).write(
      SectionsCompanion(headTeacherId: Value(teacherId)),
    );
  }

  /// د غوره کولو لیستونو لپاره — یوازې فعال استادان.
  Future<List<Teacher>> activeTeachers() {
    return (db.select(db.teachers)
          ..where((t) => t.deletedAt.isNull())
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm(expression: t.fullName)]))
        .get();
  }
}
