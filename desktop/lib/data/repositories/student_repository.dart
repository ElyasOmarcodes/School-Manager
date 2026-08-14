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
  final String? status;
  final String? gender;

  const StudentFilter({
    this.query = '',
    this.sectionId,
    this.status = 'active',
    this.gender,
  });

  StudentFilter copyWith({
    String? query,
    int? sectionId,
    String? status,
    String? gender,
    bool clearSection = false,
    bool clearStatus = false,
    bool clearGender = false,
  }) {
    return StudentFilter(
      query: query ?? this.query,
      sectionId: clearSection ? null : (sectionId ?? this.sectionId),
      status: clearStatus ? null : (status ?? this.status),
      gender: clearGender ? null : (gender ?? this.gender),
    );
  }
}

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

  /// د ورک شوي کارت باطلول — نسخه یو زیاتوي نو زوړ QR نور نه منل کېږي.
  Future<int> revokeCard(int studentId) async {
    return db.customUpdate(
      'UPDATE students SET card_version = card_version + 1 WHERE id = ?',
      variables: [Variable<int>(studentId)],
      updates: {db.students},
    );
  }
}
