import 'package:drift/drift.dart';

import '../db/database.dart';

/// یو بخش له خپل ټولګي سره — د غوره کولو لیستونو لپاره.
class SectionOption {
  final int sectionId;
  final int gradeId;
  final String gradeName;
  final int level;
  final String sectionName;
  final int capacity;
  final int enrolledCount;

  const SectionOption({
    required this.sectionId,
    required this.gradeId,
    required this.gradeName,
    required this.level,
    required this.sectionName,
    required this.capacity,
    required this.enrolledCount,
  });

  String get label => '$gradeName — $sectionName';
  bool get isFull => enrolledCount >= capacity;
  int get freeSeats => capacity - enrolledCount;
}

/// د ټولګیو، بخشونو او د زده‌کړې کلونو ذخیره.
class AcademicRepository {
  final AppDatabase db;
  AcademicRepository(this.db);

  Future<AcademicYear?> currentYear() {
    return (db.select(db.academicYears)
          ..where((y) => y.isCurrent.equals(true))
          ..limit(1))
        .getSingleOrNull();
  }

  /// د بخشونو لیست له ډک‌والي سره — چې ویزارډ وښيي «۳۲ له ۴۰ څخه».
  Future<List<SectionOption>> sections({int? academicYearId}) async {
    final year = academicYearId ?? (await currentYear())?.id;
    if (year == null) return const [];

    final rows = await db
        .customSelect(
          '''
SELECT
  sec.id            AS section_id,
  sec.name          AS section_name,
  sec.capacity      AS capacity,
  g.id              AS grade_id,
  g.name            AS grade_name,
  g.level           AS level,
  (SELECT COUNT(*) FROM enrollments e
     WHERE e.section_id = sec.id AND e.is_active = 1) AS enrolled
FROM sections sec
JOIN grades g ON g.id = sec.grade_id
WHERE sec.academic_year_id = ?
ORDER BY g.level, sec.name
''',
          variables: [Variable<int>(year)],
          readsFrom: {db.sections, db.grades, db.enrollments},
        )
        .get();

    return rows
        .map(
          (r) => SectionOption(
            sectionId: r.read<int>('section_id'),
            gradeId: r.read<int>('grade_id'),
            gradeName: r.read<String>('grade_name'),
            level: r.read<int>('level'),
            sectionName: r.read<String>('section_name'),
            capacity: r.read<int>('capacity'),
            enrolledCount: r.read<int>('enrolled'),
          ),
        )
        .toList();
  }

  /// راتلونکی د حاضرۍ نمبر (roll no) په یوه بخش کې.
  Future<int> nextRollNo(int sectionId) async {
    final row = await db
        .customSelect(
          'SELECT MAX(roll_no) AS m FROM enrollments '
          'WHERE section_id = ? AND is_active = 1',
          variables: [Variable<int>(sectionId)],
          readsFrom: {db.enrollments},
        )
        .getSingle();
    return (row.data['m'] as int? ?? 0) + 1;
  }

  /// د لومړي ران لپاره تلواله جوړښت — یو کال، ټولګي او بخشونه.
  ///
  /// پرته له دې، نوی ښوونځی به د داخلې پاڼه پرانیزي او هېڅ ټولګی به
  /// ونه ویني. دا د تنظیماتو له پاڼې څخه بدلېدی شي.
  Future<void> seedDefaults({
    required String yearLabel,
    required DateTime startsOn,
    required DateTime endsOn,
    int fromLevel = 1,
    int toLevel = 12,
    List<String> sectionNames = const ['الف', 'ب'],
  }) async {
    final existing = await db.select(db.academicYears).get();
    if (existing.isNotEmpty) return;

    await db.transaction(() async {
      final yearId = await db
          .into(db.academicYears)
          .insert(
            AcademicYearsCompanion.insert(
              label: yearLabel,
              startsOn: startsOn,
              endsOn: endsOn,
              isCurrent: const Value(true),
            ),
          );

      const names = [
        'لومړی',
        'دویم',
        'دریم',
        'څلورم',
        'پنځم',
        'شپږم',
        'اووم',
        'اتم',
        'نهم',
        'لسم',
        'یوولسم',
        'دوولسم',
      ];

      for (var level = fromLevel; level <= toLevel; level++) {
        final gradeId = await db
            .into(db.grades)
            .insert(
              GradesCompanion.insert(
                name: level <= names.length ? names[level - 1] : '$level',
                level: level,
                sortOrder: Value(level),
              ),
            );
        for (final s in sectionNames) {
          await db
              .into(db.sections)
              .insert(
                SectionsCompanion.insert(
                  gradeId: gradeId,
                  academicYearId: yearId,
                  name: s,
                ),
              );
        }
      }
    });
  }

  // ── مضمونونه ────────────────────────────────────────────

  Future<List<Subject>> subjects({int? gradeId}) {
    final q = db.select(db.subjects)
      ..orderBy([
        (s) => OrderingTerm.asc(s.sortOrder),
        (s) => OrderingTerm.asc(s.name),
      ]);
    // د یوه ټولګي مضمونونه = هغه چې ورته ټاکل شوي + هغه چې ټولو
    // ټولګیو ته عام دي (`grade_id IS NULL`).
    if (gradeId != null) {
      q.where((s) => s.gradeId.equals(gradeId) | s.gradeId.isNull());
    }
    return q.get();
  }

  Future<int> addSubject({
    required String name,
    String? code,
    int? gradeId,
    int fullMark = 100,
    int passMark = 40,
    bool isReligious = false,
  }) {
    return db
        .into(db.subjects)
        .insert(
          SubjectsCompanion.insert(
            name: name,
            code: Value(code),
            gradeId: Value(gradeId),
            fullMark: Value(fullMark),
            passMark: Value(passMark),
            isReligious: Value(isReligious),
          ),
        );
  }

  Future<void> removeSubject(int id) =>
      (db.delete(db.subjects)..where((s) => s.id.equals(id))).go();

  /// د افغانستان د ښوونځیو عام مضمونونه.
  ///
  /// **ولې دیني مضمونونه نښه شوي دي؟** ځکه چې مدرسې د دیني او
  /// عصري مضمونونو جلا اوسط غواړي — د کارنامې پر مخ دوه مجموعې
  /// ښکاري. که نښه نه وای، هغه به يې په لاس بېلولو ته اړ و.
  Future<void> seedDefaultSubjects() async {
    final existing = await db.select(db.subjects).get();
    if (existing.isNotEmpty) return;

    const list = [
      ('قرآن کریم', 'QRN', true),
      ('اسلامیات', 'ISL', true),
      ('عربي', 'ARB', true),
      ('حدیث', 'HDS', true),
      ('فقه', 'FQH', true),
      ('پښتو', 'PSH', false),
      ('دري', 'DRI', false),
      ('انګلیسي', 'ENG', false),
      ('ریاضي', 'MTH', false),
      ('فزیک', 'PHY', false),
      ('کیمیا', 'CHM', false),
      ('بیولوژي', 'BIO', false),
      ('تاریخ', 'HIS', false),
      ('جغرافیه', 'GEO', false),
      ('کمپیوټر', 'CMP', false),
      ('ورزش', 'SPT', false),
    ];

    var order = 0;
    for (final (name, code, religious) in list) {
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              name: name,
              code: Value(code),
              isReligious: Value(religious),
              sortOrder: Value(order++),
            ),
          );
    }
  }
}
