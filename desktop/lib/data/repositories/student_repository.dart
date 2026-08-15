import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../../core/utils/qr_token.dart';
import '../db/database.dart';

/// د یوې کرښې لپاره هغه څه چې جدول ښیي — د شاګرد له ټولګي سره یوځای.
class StudentRow {
  final Student student;
  final String? gradeName;
  final String? sectionName;
  final int? rollNo;

  const StudentRow({
    required this.student,
    this.gradeName,
    this.sectionName,
    this.rollNo,
  });

  String get fullName => [
    student.firstName,
    if (student.lastName != null && student.lastName!.isNotEmpty)
      student.lastName,
  ].join(' ');

  String get className => gradeName == null
      ? '—'
      : '$gradeName${sectionName == null ? '' : ' — $sectionName'}';
}

/// د پاڼې پایله — د جدول د «۱۲۰ له ۸۴۲ څخه» ښودنې لپاره.
class Paged<T> {
  final List<T> items;
  final int total;
  const Paged(this.items, this.total);
}

class StudentFilter {
  final String query;
  final int? sectionId;
  final int? gradeId;
  final String? status;
  final String? gender;
  final String? province;
  final String? district;

  /// `day` | `boarding`
  final String? residency;

  /// یوازې هغه چې پروفایل يې نیمګړی دی.
  ///
  /// **دا ولې پکار دی؟** ځکه چې د ډله‌ییزې نوم‌لیکنې پر مهال یوازې
  /// نوم، د پلار نوم او درجه ثبتېږي. مدیر باید وروسته پیدا کړي چې
  /// کوم پروفایلونه لا تشې لري — که نه، هغه به تل نیمګړي پاتې و.
  final bool onlyIncomplete;

  const StudentFilter({
    this.query = '',
    this.sectionId,
    this.gradeId,
    this.status = 'active',
    this.gender,
    this.province,
    this.district,
    this.residency,
    this.onlyIncomplete = false,
  });

  StudentFilter copyWith({
    String? query,
    int? sectionId,
    int? gradeId,
    String? status,
    String? gender,
    String? province,
    String? district,
    String? residency,
    bool? onlyIncomplete,
    bool clearSection = false,
    bool clearGrade = false,
    bool clearStatus = false,
    bool clearGender = false,
    bool clearProvince = false,
    bool clearDistrict = false,
    bool clearResidency = false,
  }) {
    final nextProvince = clearProvince ? null : (province ?? this.province);

    // **ولایت چې بدل شي، ولسوالۍ پخپله پاکېږي.**
    //
    // دا قاعده دلته ده نه په پاڼه کې، ځکه چې یو ځای يې هېرول بس
    // دي: د کندهار ولسوالۍ به د هرات سره پاتې وه او لیست به تل
    // تش و — یوه تېروتنه چې کارن يې سبب نه شي موندلی.
    final provinceChanged = nextProvince != this.province;

    return StudentFilter(
      query: query ?? this.query,
      sectionId: clearSection ? null : (sectionId ?? this.sectionId),
      gradeId: clearGrade ? null : (gradeId ?? this.gradeId),
      status: clearStatus ? null : (status ?? this.status),
      gender: clearGender ? null : (gender ?? this.gender),
      province: nextProvince,
      district: (clearDistrict || provinceChanged)
          ? district
          : (district ?? this.district),
      residency: clearResidency ? null : (residency ?? this.residency),
      onlyIncomplete: onlyIncomplete ?? this.onlyIncomplete,
    );
  }

  /// څو فلټرونه فعال دي — د «پاک کړه» تڼۍ يې ښیي.
  int get activeCount => [
    sectionId != null,
    gradeId != null,
    gender != null,
    province != null,
    district != null,
    residency != null,
    onlyIncomplete,
    status != 'active',
  ].where((v) => v).length;
}

/// هغه ساحې چې یو بشپړ پروفایل يې غواړي.
///
/// **ولې دا لیست، نه «ټولې ساحې»؟** ځکه چې د وینې ډول یا د روغتیا
/// یادښت هېڅکله د ټولو لپاره نه ډکېږي. دا هغه اته دي چې یو ښوونځی
/// واقعاً ورته اړتیا لري — د آی‌ډي کارت، د والدینو اړیکې، او د
/// رپوټونو لپاره.
const List<String> requiredProfileFields = [
  'birth_date',
  'gender',
  'province',
  'district',
  'phone',
  'photo_path',
  'father_name',
  'guardian',
];

/// د نیمګړي پروفایل SQL شرط — په څو ځایونو کې کارېږي، نو یو ځای.
const String incompleteProfileSql = '''
(s.birth_date IS NULL OR s.province IS NULL OR s.district IS NULL
 OR s.photo_path IS NULL
 OR NOT EXISTS (SELECT 1 FROM student_guardians sg2
                  JOIN guardians gu2 ON gu2.id = sg2.guardian_id
                WHERE sg2.student_id = s.id
                  AND gu2.phone IS NOT NULL AND gu2.phone <> ''))
''';

class StudentRepository {
  final AppDatabase db;
  StudentRepository(this.db);

  /// د شاګردانو لیست له لټون، سرغړاوي او پاڼو سره.
  ///
  /// دلته خام SQL کاروو نه د drift جوړونکی — ځکه چې درې جدولونه
  /// (شاګرد، ثبت، بخش، ټولګی) سره تړل کېږي او لټون په څو ستنو دی.
  /// خام SQL دلته لوستل اسانه دی او پلان يې څرګند.
  Future<Paged<StudentRow>> list({
    StudentFilter filter = const StudentFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    final where = <String>['s.deleted_at IS NULL'];
    final args = <Variable<Object>>[];

    if (filter.status != null) {
      where.add('s.status = ?');
      args.add(Variable<String>(filter.status!));
    }
    if (filter.gender != null) {
      where.add('s.gender = ?');
      args.add(Variable<String>(filter.gender!));
    }
    if (filter.sectionId != null) {
      where.add('e.section_id = ?');
      args.add(Variable<int>(filter.sectionId!));
    }
    if (filter.gradeId != null) {
      where.add('sec.grade_id = ?');
      args.add(Variable<int>(filter.gradeId!));
    }
    if (filter.province != null) {
      where.add('s.province = ?');
      args.add(Variable<String>(filter.province!));
    }
    if (filter.district != null) {
      where.add('s.district = ?');
      args.add(Variable<String>(filter.district!));
    }
    if (filter.residency != null) {
      where.add('s.residency = ?');
      args.add(Variable<String>(filter.residency!));
    }
    if (filter.onlyIncomplete) {
      where.add(incompleteProfileSql);
    }

    final q = filter.query.trim();
    if (q.isNotEmpty) {
      // کارن ښايي د آی‌ډي نمبر په ختیځو شمېرو ولیکي (۰۴۲۳) —
      // ډیټابیس لاتیني ساتي، نو مخکې يې اړوو.
      final needle = '%${Numerals.toLatin(q)}%';
      where.add(
        '(s.admission_no LIKE ? OR s.first_name LIKE ? '
        'OR s.last_name LIKE ? OR s.father_name LIKE ? OR s.phone LIKE ?)',
      );
      for (var i = 0; i < 5; i++) {
        args.add(Variable<String>(needle));
      }
    }

    const from = '''
FROM students s
LEFT JOIN enrollments e
  ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
''';
    final whereSql = 'WHERE ${where.join(' AND ')}';

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c $from $whereSql',
          variables: args,
          readsFrom: {db.students, db.enrollments, db.sections, db.grades},
        )
        .getSingle();
    final total = countRow.read<int>('c');

    final rows = await db
        .customSelect(
          '''
SELECT s.*, g.name AS grade_name, sec.name AS section_name, e.roll_no AS roll_no
$from
$whereSql
ORDER BY g.level, sec.name, e.roll_no, s.first_name
LIMIT ? OFFSET ?
''',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {db.students, db.enrollments, db.sections, db.grades},
        )
        .get();

    return Paged(
      rows
          .map(
            (r) => StudentRow(
              student: db.students.map(r.data),
              gradeName: r.data['grade_name'] as String?,
              sectionName: r.data['section_name'] as String?,
              rollNo: r.data['roll_no'] as int?,
            ),
          )
          .toList(),
      total,
    );
  }

  Future<Student?> byAdmissionNo(String admissionNo) {
    return (db.select(db.students)
          ..where((s) => s.admissionNo.equals(admissionNo))
          ..where((s) => s.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  /// راتلونکی د داخلې نمبر — د روان کال د مختاړي سره.
  ///
  /// بڼه: `<کال>-<۴ ګنې>`، لکه `1405-0043`. د کال مختاړی ځکه دی
  /// چې د کلونو ترمنځ نمبرونه ونه لګېږي.
  Future<String> nextAdmissionNo(String yearPrefix) async {
    final row = await db
        .customSelect(
          '''
SELECT admission_no FROM students
WHERE admission_no LIKE ?
ORDER BY admission_no DESC LIMIT 1
''',
          variables: [Variable<String>('$yearPrefix-%')],
          readsFrom: {db.students},
        )
        .getSingleOrNull();

    var next = 1;
    if (row != null) {
      final last = row.read<String>('admission_no').split('-').last;
      next = (int.tryParse(last) ?? 0) + 1;
    }
    return '$yearPrefix-${next.toString().padLeft(4, '0')}';
  }

  /// نوی شاګرد ثبتوي: دوسیه + سرپرست + د ټولګي ثبت — ټول په یوه
  /// راکړه‌ورکړه کې، چې که پر منځ کې څه خراب شي، نیمګړی ریکارډ
  /// پاتې نه شي.
  Future<int> admit({
    required StudentsCompanion student,
    required List<GuardiansCompanion> guardians,
    int? sectionId,
    int? academicYearId,
    int? rollNo,
    required int byUserId,
    required String byUserName,
  }) async {
    return db.transaction(() async {
      final studentId = await db
          .into(db.students)
          .insert(student.copyWith(qrSecret: Value(QrToken.newSchoolKey())));

      for (var i = 0; i < guardians.length; i++) {
        final gid = await db.into(db.guardians).insert(guardians[i]);
        await db
            .into(db.studentGuardians)
            .insert(
              StudentGuardiansCompanion.insert(
                studentId: studentId,
                guardianId: gid,
                isPrimary: Value(i == 0),
              ),
            );
      }

      if (sectionId != null && academicYearId != null) {
        await db
            .into(db.enrollments)
            .insert(
              EnrollmentsCompanion.insert(
                studentId: studentId,
                sectionId: sectionId,
                academicYearId: academicYearId,
                rollNo: Value(rollNo),
              ),
            );
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'students',
              entityId: Value(studentId),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );

      return studentId;
    });
  }

  /// ړنګول = پټول. ریکارډ پاتې کېږي ځکه چې حاضري او فیس ورپورې تړلي دي.
  Future<void> softDelete(
    int studentId, {
    required int byUserId,
    required String byUserName,
  }) async {
    await db.transaction(() async {
      await (db.update(db.students)..where((s) => s.id.equals(studentId)))
          .write(StudentsCompanion(deletedAt: Value(DateTime.now())));
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'delete',
              entity: 'students',
              entityId: Value(studentId),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );
    });
  }

  /// هغو شاګردانو ته پټ کلي ورکوي چې نه يې لري.
  ///
  /// **دا ولې پکار ده؟** `admit()` پټ کلید پخپله جوړوي، خو ریکارډونه
  /// له بلې لارې هم راتلای شي — د زاړه سیسټم واردول، یا هغه شاګردان
  /// چې د دې خاصیت له راتګ مخکې ثبت شوي. پرته له کلي، د هغوی کارت
  /// QR نه لري او سکینر يې نه پېژني.
  ///
  /// د بدل شویو ریکارډونو شمېر راګرځوي.
  Future<int> backfillQrSecrets() async {
    final missing =
        await (db.select(db.students)
              ..where((s) => s.qrSecret.isNull())
              ..where((s) => s.deletedAt.isNull()))
            .get();
    if (missing.isEmpty) return 0;

    await db.transaction(() async {
      for (final s in missing) {
        // هر شاګرد خپل کلید اخلي — نه یو ګډ. که ګډ وای، د یوه
        // کارت له مخې به د ټولو جوړېدل ممکن وو.
        await (db.update(db.students)..where((t) => t.id.equals(s.id))).write(
          StudentsCompanion(qrSecret: Value(QrToken.newSchoolKey())),
        );
      }
    });
    return missing.length;
  }

  /// د ورک شوي کارت باطلول — نسخه یو زیاتوي نو زوړ QR نور نه منل کېږي.
  Future<int> revokeCard(int studentId) async {
    return db.customUpdate(
      'UPDATE students SET card_version = card_version + 1 WHERE id = ?',
      variables: [Variable<int>(studentId)],
      updates: {db.students},
    );
  }

  // ═════════════════════════════════════════════════════════
  //  ډله‌ییزه نوم‌لیکنه
  // ═════════════════════════════════════════════════════════

  /// د یوې کرښې لږ تر لږه ډیټا — د بیړنۍ نوم‌لیکنې لپاره.
  ///
  /// **ولې درې ساحې؟** ځکه چې د کال په پیل کې دوه سوه کسان په یوه
  /// ورځ راځي. که هر یو ته بشپړ ویزارډ ډکېده، مدیر به تر ماښامه
  /// شل کسه ثبت کړي وای. درې ساحې بس دي چې شاګرد په سیسټم کې شي؛
  /// پاتې يې وروسته د پروفایل له لارې بشپړېږي.
  Future<int> bulkAdmit({
    required List<({String firstName, String fatherName, int? sectionId})> rows,
    required int academicYearId,
    required String yearPrefix,
    required int byUserId,
    required String byUserName,
    String defaultGender = 'male',
    String defaultResidency = 'day',
  }) async {
    final clean = rows
        .where(
          (r) => r.firstName.trim().isNotEmpty && r.fatherName.trim().isNotEmpty,
        )
        .toList();
    if (clean.isEmpty) return 0;

    return db.transaction(() async {
      // یو ځل شمېره اخلو، بیا يې پخپله زیاتوو — که هره کرښه جلا
      // پوښتنه کوله، د دوو سوو کسانو ثبت به دوه سوه ځله جدول لټاوه.
      var next = int.parse(
        (await nextAdmissionNo(yearPrefix)).split('-').last,
      );
      var made = 0;

      for (final r in clean) {
        final admissionNo =
            '$yearPrefix-${next.toString().padLeft(4, '0')}';
        next++;

        final studentId = await db
            .into(db.students)
            .insert(
              StudentsCompanion.insert(
                admissionNo: admissionNo,
                firstName: r.firstName.trim(),
                fatherName: r.fatherName.trim(),
                gender: defaultGender,
                residency: Value(defaultResidency),
                qrSecret: Value(QrToken.newSchoolKey()),
              ),
            );

        // **سرپرست هم جوړېږي، که څه هم تش دی.** د پلار نوم لا
        // وړاندې لرو، نو یوه کرښه ورته جوړوو چې وروسته يې یوازې
        // ټیلیفون ډکول پاتې وي — نه له سره جوړول.
        final gid = await db
            .into(db.guardians)
            .insert(
              GuardiansCompanion.insert(
                fullName: r.fatherName.trim(),
                relation: 'father',
              ),
            );
        await db
            .into(db.studentGuardians)
            .insert(
              StudentGuardiansCompanion.insert(
                studentId: studentId,
                guardianId: gid,
                isPrimary: const Value(true),
              ),
            );

        if (r.sectionId != null) {
          await db
              .into(db.enrollments)
              .insert(
                EnrollmentsCompanion.insert(
                  studentId: studentId,
                  sectionId: r.sectionId!,
                  academicYearId: academicYearId,
                ),
              );
        }
        made++;
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'students',
              userId: Value(byUserId),
              userName: Value(byUserName),
              changesJson: Value('{"bulk":$made}'),
            ),
          );

      return made;
    });
  }

  // ═════════════════════════════════════════════════════════
  //  پروفایل
  // ═════════════════════════════════════════════════════════

  Future<Student?> byId(int id) => (db.select(
    db.students,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  /// د یوه شاګرد بشپړ حال — دوسیه، ټولګی، سرپرستان.
  Future<StudentProfile?> profile(int id) async {
    final student = await byId(id);
    if (student == null) return null;

    final row = await db
        .customSelect(
          '''
SELECT g.name AS grade_name, sec.name AS section_name,
       sec.id AS section_id, g.id AS grade_id, e.roll_no AS roll_no
FROM enrollments e
JOIN sections sec ON sec.id = e.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE e.student_id = ? AND e.is_active = 1
LIMIT 1
''',
          variables: [Variable<int>(id)],
          readsFrom: {db.enrollments, db.sections, db.grades},
        )
        .getSingleOrNull();

    final guardians = await db
        .customSelect(
          '''
SELECT gu.*, sg.is_primary AS is_primary
FROM student_guardians sg
JOIN guardians gu ON gu.id = sg.guardian_id
WHERE sg.student_id = ?
ORDER BY sg.is_primary DESC, gu.id
''',
          variables: [Variable<int>(id)],
          readsFrom: {db.studentGuardians, db.guardians},
        )
        .get();

    return StudentProfile(
      student: student,
      gradeId: row?.data['grade_id'] as int?,
      sectionId: row?.data['section_id'] as int?,
      gradeName: row?.data['grade_name'] as String?,
      sectionName: row?.data['section_name'] as String?,
      rollNo: row?.data['roll_no'] as int?,
      guardians: [
        for (final g in guardians)
          (
            guardian: db.guardians.map(g.data),
            isPrimary: (g.data['is_primary'] as int? ?? 0) == 1,
          ),
      ],
    );
  }

  /// د پروفایل سمون — یوازې هغه ساحې چې ورکړل شوې.
  ///
  /// د تفتیش کرښه هم لیکل کېږي، چې وروسته څرګنده وي چا څه بدل کړل.
  Future<void> updateProfile({
    required int id,
    required StudentsCompanion patch,
    required int byUserId,
    required String byUserName,
    String? changesJson,
  }) async {
    await db.transaction(() async {
      await (db.update(db.students)..where((s) => s.id.equals(id))).write(
        patch.copyWith(updatedAt: Value(DateTime.now())),
      );
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'update',
              entity: 'students',
              entityId: Value(id),
              userId: Value(byUserId),
              userName: Value(byUserName),
              changesJson: Value(changesJson),
            ),
          );
    });
  }

  /// د اصلي سرپرست سمون — که نه وي، جوړېږي.
  Future<void> upsertPrimaryGuardian({
    required int studentId,
    required String fullName,
    required String relation,
    String? phone,
    String? occupation,
  }) async {
    await db.transaction(() async {
      final existing = await db
          .customSelect(
            'SELECT guardian_id FROM student_guardians '
            'WHERE student_id = ? ORDER BY is_primary DESC LIMIT 1',
            variables: [Variable<int>(studentId)],
            readsFrom: {db.studentGuardians},
          )
          .getSingleOrNull();

      if (existing == null) {
        final gid = await db
            .into(db.guardians)
            .insert(
              GuardiansCompanion.insert(
                fullName: fullName,
                relation: relation,
                phone: Value(phone),
                occupation: Value(occupation),
              ),
            );
        await db
            .into(db.studentGuardians)
            .insert(
              StudentGuardiansCompanion.insert(
                studentId: studentId,
                guardianId: gid,
                isPrimary: const Value(true),
              ),
            );
        return;
      }

      await (db.update(
        db.guardians,
      )..where((g) => g.id.equals(existing.read<int>('guardian_id')))).write(
        GuardiansCompanion(
          fullName: Value(fullName),
          relation: Value(relation),
          phone: Value(phone),
          occupation: Value(occupation),
        ),
      );
    });
  }

  /// شاګرد بل بخش ته لېږدوي — زوړ ثبت بندېږي، نوی پرانیستل کېږي.
  ///
  /// **ولې زوړ نه ړنګوو؟** ځکه چې د تېرو میاشتو حاضري او نمرې د
  /// هغه بخش پورې تړلې دي. که ړنګ شوی وای، د کال رپوټ به مات و.
  Future<void> transferSection({
    required int studentId,
    required int sectionId,
    required int academicYearId,
    int? rollNo,
    DateTime? at,
  }) async {
    final now = at ?? DateTime.now();
    await db.transaction(() async {
      await (db.update(db.enrollments)
            ..where((e) => e.studentId.equals(studentId))
            ..where((e) => e.isActive.equals(true)))
          .write(
            EnrollmentsCompanion(
              isActive: const Value(false),
              leftOn: Value(now),
            ),
          );
      await db
          .into(db.enrollments)
          .insert(
            EnrollmentsCompanion.insert(
              studentId: studentId,
              sectionId: sectionId,
              academicYearId: academicYearId,
              rollNo: Value(rollNo),
              enrolledOn: Value(now),
            ),
          );
    });
  }

  /// **هغه میاشت چې پروفایل يې پرانیزي.**
  ///
  /// نه «نن» — ځکه چې د تېر کال یو فارغ شاګرد پروفایل به تل تش
  /// جدول ښود، او مدیر به يې د میاشتو په شا کولو کې لټاوه. د
  /// وروستي ریکارډ میاشت هغه ده چې څه پکې شته.
  Future<DateTime?> latestAttendanceMonth(int studentId) async {
    final row = await db
        .customSelect(
          'SELECT MAX(date) AS d FROM attendances WHERE student_id = ?',
          variables: [Variable<int>(studentId)],
          readsFrom: {db.attendances},
        )
        .getSingleOrNull();
    final raw = row?.data['d'] as int?;
    if (raw == null) return null;
    final d = DateTime.fromMillisecondsSinceEpoch(
      raw * 1000,
      isUtc: true,
    ).toLocal();
    return DateTime(d.year, d.month);
  }

  /// د یوې میاشتې ورځ‌په‌ورځ حاضري — د پروفایل د جدول لپاره.
  ///
  /// کلی د میاشتې ورځ ده (۱…۳۱)، ارزښت يې حالت.
  Future<Map<int, String>> attendanceGrid({
    required int studentId,
    required DateTime month,
    int sessionId = 0,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final rows = await db
        .customSelect(
          'SELECT date, status FROM attendances '
          'WHERE student_id = ? AND session_id = ? '
          'AND date >= ? AND date <= ?',
          variables: [
            Variable<int>(studentId),
            Variable<int>(sessionId),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
          ],
          readsFrom: {db.attendances},
        )
        .get();

    return {
      for (final r in rows)
        DateTime.fromMillisecondsSinceEpoch(
          r.read<int>('date') * 1000,
          isUtc: true,
        ).toLocal().day: r.read<String>('status'),
    };
  }

  /// د یوه کال میاشت‌په‌میاشت لنډیز — «حاضر / غیرحاضر / رخصت».
  Future<List<({int month, int present, int absent, int leave})>> yearlyRollup({
    required int studentId,
    required int year,
    int sessionId = 0,
  }) async {
    final rows = await db
        .customSelect(
          '''
SELECT CAST(strftime('%m', date, 'unixepoch') AS INTEGER) AS m,
       SUM(CASE WHEN status IN ('present','late') THEN 1 ELSE 0 END) AS p,
       SUM(CASE WHEN status = 'absent' THEN 1 ELSE 0 END) AS a,
       SUM(CASE WHEN status = 'leave'  THEN 1 ELSE 0 END) AS l
FROM attendances
WHERE student_id = ? AND session_id = ?
  AND CAST(strftime('%Y', date, 'unixepoch') AS INTEGER) = ?
GROUP BY m ORDER BY m
''',
          variables: [
            Variable<int>(studentId),
            Variable<int>(sessionId),
            Variable<int>(year),
          ],
          readsFrom: {db.attendances},
        )
        .get();

    return [
      for (final r in rows)
        (
          month: r.read<int>('m'),
          present: r.data['p'] as int? ?? 0,
          absent: r.data['a'] as int? ?? 0,
          leave: r.data['l'] as int? ?? 0,
        ),
    ];
  }

  /// د یوې ورځې د حاضرۍ لاسي سمون — **د پروفایل له پاڼې**.
  ///
  /// دا هغه کار دی چې هر کارن يې نه شي کولی؛ پاڼه يې د
  /// `attendance:edit` اجازې تر شا ساتي. دلته یوازې ماشین دی.
  Future<void> setAttendance({
    required int studentId,
    required DateTime date,
    required String status,
    required int byUserId,
    int sessionId = 0,
    String? note,
    DateTime? now,
  }) async {
    final day = DateTime(date.year, date.month, date.day);
    final stamp = now ?? DateTime.now();

    await db.transaction(() async {
      await db
          .into(db.attendances)
          .insert(
            AttendancesCompanion.insert(
              studentId: studentId,
              date: day,
              status: status,
              sessionId: Value(sessionId),
              method: const Value('manual'),
              note: Value(note),
              recordedByUserId: Value(byUserId),
              recordedAt: Value(stamp),
            ),
            onConflict: DoUpdate(
              (_) => AttendancesCompanion(
                status: Value(status),
                method: const Value('manual'),
                note: Value(note),
                recordedByUserId: Value(byUserId),
                recordedAt: Value(stamp),
              ),
              target: [
                db.attendances.studentId,
                db.attendances.date,
                db.attendances.sessionId,
              ],
            ),
          );

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'update',
              entity: 'attendance',
              entityId: Value(studentId),
              userId: Value(byUserId),
              at: Value(stamp),
              changesJson: Value(
                '{"date":"${day.toIso8601String()}","status":"$status"}',
              ),
            ),
          );
    });
  }
}

/// د یوه شاګرد بشپړ پروفایل — هغه څه چې د پروفایل پاڼه غواړي.
class StudentProfile {
  final Student student;
  final int? gradeId;
  final int? sectionId;
  final String? gradeName;
  final String? sectionName;
  final int? rollNo;
  final List<({Guardian guardian, bool isPrimary})> guardians;

  const StudentProfile({
    required this.student,
    this.gradeId,
    this.sectionId,
    this.gradeName,
    this.sectionName,
    this.rollNo,
    this.guardians = const [],
  });

  String get fullName => [
    student.firstName,
    if (student.lastName != null && student.lastName!.isNotEmpty)
      student.lastName,
  ].join(' ');

  String get className => gradeName == null
      ? '—'
      : '$gradeName${sectionName == null ? '' : ' — $sectionName'}';

  Guardian? get primaryGuardian => guardians.isEmpty
      ? null
      : guardians.firstWhere((g) => g.isPrimary, orElse: () => guardians.first)
            .guardian;

  String get residenceLine => [
    student.province,
    student.district,
    student.village,
  ].whereType<String>().where((e) => e.isNotEmpty).join(' — ');

  /// کومې ساحې لا تشې دي — د «نیمګړی پروفایل» نښې لپاره.
  List<String> get missingFields => [
    if (student.birthDate == null) 'د زېږېدو نېټه',
    if (student.province == null || student.province!.isEmpty) 'ولایت',
    if (student.district == null || student.district!.isEmpty) 'ولسوالۍ',
    if (student.photoPath == null || student.photoPath!.isEmpty) 'انځور',
    if (primaryGuardian?.phone == null || primaryGuardian!.phone!.isEmpty)
      'د سرپرست ټیلیفون',
  ];

  bool get isComplete => missingFields.isEmpty;
}
