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

class TeacherFilter {
  final String query;
  final String? status;
  final String? gender;

  const TeacherFilter({this.query = '', this.status = 'active', this.gender});

  TeacherFilter copyWith({
    String? query,
    String? status,
    String? gender,
    bool clearStatus = false,
    bool clearGender = false,
  }) => TeacherFilter(
    query: query ?? this.query,
    status: clearStatus ? null : (status ?? this.status),
    gender: clearGender ? null : (gender ?? this.gender),
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
ORDER BY t.full_name
LIMIT ? OFFSET ?
''',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {db.teachers, db.sections, db.grades},
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
