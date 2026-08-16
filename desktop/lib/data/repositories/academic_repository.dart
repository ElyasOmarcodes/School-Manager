import 'package:drift/drift.dart';

import '../../core/data/madrasa_curriculum.dart';
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

/// یو ټولګی/درجه له خپلو بخشونو سره — د ټولګیو د پاڼې لپاره.
class GradeWithSections {
  final Grade grade;
  final List<SectionOption> sections;
  const GradeWithSections(this.grade, this.sections);

  int get capacity => sections.fold(0, (a, b) => a + b.capacity);
  int get enrolled => sections.fold(0, (a, b) => a + b.enrolledCount);
  double get fillPercent => capacity == 0 ? 0 : (enrolled / capacity) * 100;
}

/// د ټولګیو، بخشونو او د زده‌کړې کلونو ذخیره.
class AcademicRepository {
  final AppDatabase db;
  AcademicRepository(this.db);

  Future<School?> school() => db.select(db.schools).getSingleOrNull();

  /// ایا دا مدرسه ده؟ — د نصاب، د جدول بڼې او د ظرفیت پرېکړې پرې دي.
  Future<bool> isMadrasa() async {
    final s = await school();
    return s != null && (s.kind == 'madrasa' || s.kind == 'both');
  }

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

    /// که مدرسه وي، د ټولګیو پر ځای درجې جوړېږي — او د هرې درجې
    /// خپل کتابونه. دا هغه توپیر دی چې د پوهنې وزارت نصاب ټاکي.
    bool madrasa = false,
    int? capacity,
  }) async {
    final existing = await db.select(db.academicYears).get();
    if (existing.isNotEmpty) return;

    if (madrasa) {
      return seedMadrasaStructure(
        yearLabel: yearLabel,
        startsOn: startsOn,
        endsOn: endsOn,
        sectionNames: sectionNames,
        capacity: capacity ?? madrasaDefaultCapacity,
      );
    }

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
                  capacity: Value(capacity ?? 40),
                ),
              );
        }
      }
    });
  }

  /// **د مدرسې تلواله ظرفیت له مکتب څخه لوړ دی.**
  ///
  /// یو صنف په مکتب کې ۴۰ کسه دی؛ یوه درجه په مدرسه کې ډېره وخت
  /// له شپېتو ډېره وي. که ۴۰ پاتې وای، هره درجه به د لومړۍ ورځې
  /// «ډکه» ښکارېده او مدیر به يې هره یوه په لاس لوړوله.
  static const int madrasaDefaultCapacity = 80;

  /// د مدرسې بشپړ جوړښت — درې‌ولس درجې، د هرې یوې مضامین او کتابونه.
  Future<void> seedMadrasaStructure({
    required String yearLabel,
    required DateTime startsOn,
    required DateTime endsOn,
    List<String> sectionNames = const ['الف'],
    int capacity = madrasaDefaultCapacity,
  }) async {
    await db.transaction(() async {
      var yearId = (await currentYear())?.id;
      yearId ??= await db
          .into(db.academicYears)
          .insert(
            AcademicYearsCompanion.insert(
              label: yearLabel,
              startsOn: startsOn,
              endsOn: endsOn,
              isCurrent: const Value(true),
            ),
          );

      final existingGrades = {
        for (final g in await db.select(db.grades).get()) g.name: g.id,
      };

      for (final lvl in madrasaCurriculum) {
        var gradeId = existingGrades[lvl.name];
        gradeId ??= await db
            .into(db.grades)
            .insert(
              GradesCompanion.insert(
                name: lvl.name,
                level: lvl.level,
                sortOrder: Value(lvl.level),
              ),
            );

        // یوه درجه معمولاً یو بخش لري — مدرسه «الف/ب» نه ویشي مګر
        // چې شمېر ډېر شي. نو یوازې یو جوړېږي، پاتې يې مدیر زیاتوي.
        final hasSection =
            await (db.select(db.sections)
                  ..where((s) => s.gradeId.equals(gradeId!))
                  ..limit(1))
                .getSingleOrNull() !=
            null;
        if (!hasSection) {
          for (final s in sectionNames) {
            await db
                .into(db.sections)
                .insert(
                  SectionsCompanion.insert(
                    gradeId: gradeId,
                    academicYearId: yearId,
                    name: s,
                    capacity: Value(capacity),
                  ),
                );
          }
        }

        var order = 0;
        for (final sub in lvl.subjects) {
          final already =
              await (db.select(db.subjects)
                    ..where((t) => t.gradeId.equals(gradeId!))
                    ..where((t) => t.name.equals(sub.name))
                    ..limit(1))
                  .getSingleOrNull();
          if (already != null) continue;

          await db
              .into(db.subjects)
              .insert(
                SubjectsCompanion.insert(
                  name: sub.name,
                  gradeId: Value(gradeId),
                  book: Value(sub.book),
                  // **د مدرسې ټول فنون دیني ګڼل کېږي مګر څو یو.**
                  // حساب، خط او انګلیسي عصري دي؛ پاتې ټول دیني.
                  isReligious: Value(!_worldlyFans.contains(sub.name)),
                  sortOrder: Value(order++),
                ),
              );
        }
      }

      await db
          .update(db.schools)
          .write(
            SchoolsCompanion(
              timetableMode: const Value('daily'),
              classesView: const Value('grid'),
              defaultCapacity: Value(capacity),
            ),
          );
    });
  }

  static const _worldlyFans = {
    'حساب',
    'ریاضي',
    'خط',
    'انګلیسي',
    'کمپیوټر',
    'ساینس',
    'جغرافیه',
  };

  // ── ټولګي او بخشونه ─────────────────────────────────────

  Future<List<Grade>> grades() =>
      (db.select(db.grades)..orderBy([
            (g) => OrderingTerm.asc(g.sortOrder),
            (g) => OrderingTerm.asc(g.level),
          ]))
          .get();

  /// ټولګي له بخشونو سره — د پاڼې د دواړو بڼو (کتار او ګریډ) لپاره.
  Future<List<GradeWithSections>> gradesWithSections({
    int? academicYearId,
  }) async {
    final all = await sections(academicYearId: academicYearId);
    final byGrade = <int, List<SectionOption>>{};
    for (final s in all) {
      (byGrade[s.gradeId] ??= []).add(s);
    }
    final list = await grades();
    return [
      for (final g in list) GradeWithSections(g, byGrade[g.id] ?? const []),
    ];
  }

  Future<int> addGrade({required String name, int? level}) async {
    final existing = await grades();
    final nextLevel =
        level ??
        (existing.isEmpty
            ? 1
            : existing.map((g) => g.level).reduce((a, b) => a > b ? a : b) + 1);
    return db
        .into(db.grades)
        .insert(
          GradesCompanion.insert(
            name: name,
            level: nextLevel,
            sortOrder: Value(nextLevel),
          ),
        );
  }

  Future<void> renameGrade(int id, String name) =>
      (db.update(db.grades)..where((g) => g.id.equals(id))).write(
        GradesCompanion(name: Value(name)),
      );

  /// یو ټولګی یوازې هغه وخت ړنګېږي چې تش وي.
  ///
  /// **ولې؟** ځکه چې د ټولګي ړنګول به د هغه د بخشونو، ثبتونو، نمرو
  /// او حاضرۍ تړاو مات کړ. یوه غلطه کېکاږنه به د یوه کال ډیټا
  /// له منځه وړه. نو مخکې له ړنګولو شمېر کتل کېږي.
  Future<String?> deleteGrade(int id) async {
    final secs = await (db.select(
      db.sections,
    )..where((s) => s.gradeId.equals(id))).get();

    for (final s in secs) {
      final n = await _enrolledCount(s.id);
      if (n > 0) return 'دې ټولګي کې لا شاګردان شته — لومړی يې بل ځای ته واړوه.';
    }

    await db.transaction(() async {
      for (final s in secs) {
        await (db.delete(db.sections)..where((t) => t.id.equals(s.id))).go();
      }
      await (db.delete(db.grades)..where((g) => g.id.equals(id))).go();
    });
    return null;
  }

  Future<int> _enrolledCount(int sectionId) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM enrollments '
          'WHERE section_id = ? AND is_active = 1',
          variables: [Variable<int>(sectionId)],
          readsFrom: {db.enrollments},
        )
        .getSingle();
    return row.read<int>('c');
  }

  Future<int> addSection({
    required int gradeId,
    required String name,
    int? capacity,
    String? room,
    int? headTeacherId,
  }) async {
    final year = await currentYear();
    if (year == null) throw StateError('د زده‌کړې کال نشته');
    final school = await this.school();
    return db
        .into(db.sections)
        .insert(
          SectionsCompanion.insert(
            gradeId: gradeId,
            academicYearId: year.id,
            name: name,
            capacity: Value(capacity ?? school?.defaultCapacity ?? 40),
            room: Value(room),
            headTeacherId: Value(headTeacherId),
          ),
        );
  }

  Future<void> updateSection({
    required int id,
    String? name,
    int? capacity,
    String? room,
    int? headTeacherId,
    bool clearHeadTeacher = false,
  }) {
    return (db.update(db.sections)..where((s) => s.id.equals(id))).write(
      SectionsCompanion(
        name: name == null ? const Value.absent() : Value(name),
        capacity: capacity == null ? const Value.absent() : Value(capacity),
        room: room == null ? const Value.absent() : Value(room),
        headTeacherId: clearHeadTeacher
            ? const Value(null)
            : (headTeacherId == null
                  ? const Value.absent()
                  : Value(headTeacherId)),
      ),
    );
  }

  Future<String?> deleteSection(int id) async {
    if (await _enrolledCount(id) > 0) {
      return 'دې بخش کې لا شاګردان شته — لومړی يې بل بخش ته واړوه.';
    }
    await (db.delete(db.sections)..where((s) => s.id.equals(id))).go();
    return null;
  }

  /// **د ښوونځي پېژندنه سمول — خو `kind` نه.**
  ///
  /// ډول (ښوونځی/مدرسه) قصداً نه دی سمېدونکی. په هغه پورې د نصاب
  /// جوړښت، د مهالویش بڼه، د درجو نومونه او د حفظ ماډل تړلي دي.
  /// د ډول بدلول به د دې ټولو معنا بدله کړه — او هغه معلومات چې
  /// لا دمخه ثبت شوي، بې‌ځایه شوي وای. که چا واقعاً بدلول غوښتل،
  /// نوی ډیټابیس پکار دی، نه یو ډراپ‌ډاون.
  Future<void> updateSchool({
    required String name,
    String? nameEn,
    String? address,
    String? phone,
    String? email,
    String? logoPath,
  }) => db
      .update(db.schools)
      .write(
        SchoolsCompanion(
          name: Value(name),
          nameEn: Value(nameEn),
          address: Value(address),
          phone: Value(phone),
          email: Value(email),
          logoPath: Value(logoPath),
        ),
      );

  /// د ټولګیو د پاڼې بڼه — `rows` یا `grid`. په ښوونځي کې ساتل کېږي
  /// چې د پروګرام په بیا-پرانیستو کې هماغه پاتې شي.
  Future<void> setClassesView(String view) =>
      db.update(db.schools).write(SchoolsCompanion(classesView: Value(view)));

  Future<void> setDefaultCapacity(int capacity) => db
      .update(db.schools)
      .write(SchoolsCompanion(defaultCapacity: Value(capacity)));

  Future<void> setTimetableMode(String mode) =>
      db.update(db.schools).write(SchoolsCompanion(timetableMode: Value(mode)));

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

  /// د یوه مضمون بشپړ حال — نوم، کتاب، سختوالی او ټولګی.
  Future<Subject?> subject(int id) => (db.select(
    db.subjects,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  Future<int> addSubject({
    required String name,
    String? code,
    int? gradeId,
    String? book,
    String difficulty = 'medium',
    int fullMark = 100,
    int passMark = 40,
    bool isReligious = false,
  }) async {
    // د دې ټولګي په پای کې کېښودل شي، نه په سر کې — چې د نصاب
    // ترتیب خراب نه شي.
    final row = await db
        .customSelect(
          'SELECT COALESCE(MAX(sort_order), -1) AS m FROM subjects '
          '${gradeId == null ? 'WHERE grade_id IS NULL' : 'WHERE grade_id = ?'}',
          variables: [if (gradeId != null) Variable<int>(gradeId)],
          readsFrom: {db.subjects},
        )
        .getSingle();

    return db
        .into(db.subjects)
        .insert(
          SubjectsCompanion.insert(
            name: name,
            code: Value(code),
            gradeId: Value(gradeId),
            book: Value(book),
            difficulty: Value(difficulty),
            fullMark: Value(fullMark),
            passMark: Value(passMark),
            isReligious: Value(isReligious),
            sortOrder: Value(row.read<int>('m') + 1),
          ),
        );
  }

  Future<void> updateSubject({
    required int id,
    String? name,
    String? code,
    int? gradeId,
    bool clearGrade = false,
    String? book,
    String? difficulty,
    int? fullMark,
    int? passMark,
    bool? isReligious,
  }) {
    return (db.update(db.subjects)..where((s) => s.id.equals(id))).write(
      SubjectsCompanion(
        name: name == null ? const Value.absent() : Value(name),
        code: code == null ? const Value.absent() : Value(code),
        gradeId: clearGrade
            ? const Value(null)
            : (gradeId == null ? const Value.absent() : Value(gradeId)),
        book: book == null ? const Value.absent() : Value(book),
        difficulty: difficulty == null
            ? const Value.absent()
            : Value(difficulty),
        fullMark: fullMark == null ? const Value.absent() : Value(fullMark),
        passMark: passMark == null ? const Value.absent() : Value(passMark),
        isReligious: isReligious == null
            ? const Value.absent()
            : Value(isReligious),
      ),
    );
  }

  /// **مضمون یوازې هغه وخت ړنګېږي چې نمرې ورسره نه وي تړلې.**
  ///
  /// که ړنګ شي، د تېر کال د کارنامو کرښې به بې‌نومه پاتې شوې —
  /// یو رپوټ چې «۸۷ نمرې» ښیي خو نه پوهېږي د څه. نو مخکې کتل کېږي.
  Future<String?> removeSubject(int id) async {
    final row = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM exam_subjects WHERE subject_id = ?',
          variables: [Variable<int>(id)],
          readsFrom: {db.examSubjects},
        )
        .getSingle();
    if (row.read<int>('c') > 0) {
      return 'دا مضمون په ازموینو کې کارېدلی — ړنګېدی نه شي، خو نوم يې بدلولی شې.';
    }

    await (db.delete(db.timetableEntries)..where((t) => t.subjectId.equals(id)))
        .go();
    await (db.delete(db.subjects)..where((s) => s.id.equals(id))).go();
    return null;
  }

  /// د یوه ټولګي/درجې لپاره د نوم وړاندیزونه.
  ///
  /// مدرسه: د هماغې درجې رسمي فنون له کتابونو سره. مکتب: عام
  /// مضمونونه. په دواړو حالتونو کې کارن خپل نوم هم لیکلی شي —
  /// وړاندیز دی، نه بندیز.
  Future<List<({String name, String? book, bool religious})>> subjectSuggestions(
    String? gradeName,
  ) async {
    if (await isMadrasa() && gradeName != null) {
      final fans = madrasaSubjectsOf(gradeName);
      if (fans.isNotEmpty) {
        return [
          for (final f in fans)
            (
              name: f.name,
              book: f.book,
              religious: !_worldlyFans.contains(f.name),
            ),
        ];
      }
    }
    return [
      for (final s in schoolSubjectSuggestions)
        (name: s.name, book: null, religious: s.religious),
    ];
  }

  /// د افغانستان د ښوونځیو عام مضمونونه.
  ///
  /// **ولې دیني مضمونونه نښه شوي دي؟** ځکه چې مدرسې د دیني او
  /// عصري مضمونونو جلا اوسط غواړي — د کارنامې پر مخ دوه مجموعې
  /// ښکاري. که نښه نه وای، هغه به يې په لاس بېلولو ته اړ و.
  Future<void> seedDefaultSubjects() async {
    final existing = await db.select(db.subjects).get();
    if (existing.isNotEmpty) return;

    // مدرسه خپل نصاب لري — د هرې درجې خپل کتابونه. هغه د
    // `seedMadrasaStructure` په ترڅ کې ثبتېږي، نو دلته څه نه کوو.
    if (await isMadrasa()) return;

    // **د سختۍ درجه د تلوالې برخه ده، نه یو وروسته فکر.**
    //
    // ځیرک مهالویش سخت مضمونونه سهار ږدي. که ټول «منځني» پیل
    // شوي وای، هغه ځانګړتیا به تر هغې بې‌ګټې وه چې مدیر يې د
    // شپاړسو مضمونونو درجه په لاس ټاکلې وای — او هېڅوک يې نه
    // کوي. نو د یوه معقول پیل سره راځي، او سمېدونکې ده.
    const list = [
      ('قرآن کریم', 'QRN', true, 'medium'),
      ('اسلامیات', 'ISL', true, 'medium'),
      ('عربي', 'ARB', true, 'hard'),
      ('حدیث', 'HDS', true, 'medium'),
      ('فقه', 'FQH', true, 'hard'),
      ('پښتو', 'PSH', false, 'medium'),
      ('دري', 'DRI', false, 'medium'),
      ('انګلیسي', 'ENG', false, 'hard'),
      ('ریاضي', 'MTH', false, 'hard'),
      ('فزیک', 'PHY', false, 'hard'),
      ('کیمیا', 'CHM', false, 'hard'),
      ('بیولوژي', 'BIO', false, 'medium'),
      ('تاریخ', 'HIS', false, 'easy'),
      ('جغرافیه', 'GEO', false, 'easy'),
      ('کمپیوټر', 'CMP', false, 'easy'),
      ('ورزش', 'SPT', false, 'easy'),
    ];

    var order = 0;
    for (final (name, code, religious, difficulty) in list) {
      await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              name: name,
              code: Value(code),
              isReligious: Value(religious),
              difficulty: Value(difficulty),
              sortOrder: Value(order++),
            ),
          );
    }
  }
}
