import 'package:drift/drift.dart';

import '../db/database.dart';
import 'attendance_repository.dart' show dateOnly;
import 'student_repository.dart' show Paged;

class LeaveRow {
  final LeaveRequest request;
  final Student student;
  final String? className;

  const LeaveRow({
    required this.request,
    required this.student,
    this.className,
  });

  int get days => request.toDate.difference(request.fromDate).inDays + 1;
}

class LeaveRepository {
  final AppDatabase db;
  LeaveRepository(this.db);

  Future<Paged<LeaveRow>> list({
    String? status = 'pending',
    int limit = 50,
    int offset = 0,
  }) async {
    final where = <String>[];
    final args = <Variable<Object>>[];
    if (status != null) {
      where.add('l.status = ?');
      args.add(Variable<String>(status));
    }
    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM leave_requests l $whereSql',
          variables: args,
          readsFrom: {db.leaveRequests},
        )
        .getSingle();

    final rows = await db
        .customSelect(
          '''
SELECT l.*, s.id AS s_id, s.admission_no, s.first_name, s.last_name,
       s.father_name, s.gender, s.status AS s_status, s.card_version,
       s.admitted_on, s.created_at, s.updated_at,
       g.name || ' — ' || sec.name AS class_name
FROM leave_requests l
JOIN students s ON s.id = l.student_id
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
$whereSql
ORDER BY l.status = 'pending' DESC, l.from_date DESC
LIMIT ? OFFSET ?
''',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {
            db.leaveRequests,
            db.students,
            db.enrollments,
            db.sections,
            db.grades,
          },
        )
        .get();

    return Paged(
      rows.map((r) {
        // د شاګرد ستنې په لاس جوړوو — `JOIN` د دواړو جدولونو `id`
        // سره ګډوي، نو `db.students.map()` به ناسم ریکارډ جوړ کړ.
        final student = Student(
          id: r.read<int>('s_id'),
          admissionNo: r.read<String>('admission_no'),
          firstName: r.read<String>('first_name'),
          lastName: r.data['last_name'] as String?,
          fatherName: r.read<String>('father_name'),
          gender: r.read<String>('gender'),
          status: r.read<String>('s_status'),
          cardVersion: r.read<int>('card_version'),
          admittedOn: r.read<DateTime>('admitted_on'),
          createdAt: r.read<DateTime>('created_at'),
          updatedAt: r.read<DateTime>('updated_at'),
        );
        return LeaveRow(
          request: db.leaveRequests.map(r.data),
          student: student,
          className: r.data['class_name'] as String?,
        );
      }).toList(),
      countRow.read<int>('c'),
    );
  }

  Future<int> request({
    required int studentId,
    required String reasonType,
    String? reasonText,
    required DateTime fromDate,
    required DateTime toDate,
    String requestedVia = 'reception',
    int? requestedByUserId,
  }) {
    return db
        .into(db.leaveRequests)
        .insert(
          LeaveRequestsCompanion.insert(
            studentId: studentId,
            reasonType: reasonType,
            reasonText: Value(reasonText),
            fromDate: dateOnly(fromDate),
            toDate: dateOnly(toDate),
            requestedVia: Value(requestedVia),
            requestedByUserId: Value(requestedByUserId),
          ),
        );
  }

  /// تصویب یا ردول.
  ///
  /// **د تصویب پر مهال د حاضرۍ سمون هم کېږي.** که د اجازې ورځې تېرې
  /// شوې وي او شاګرد «غیرحاضر» ثبت شوی وي، هغه «رخصت» ته اوړي. پرته
  /// له دې به یوه وروسته-منل‌شوې اجازه د غیرحاضرۍ ریکارډ نه سموه او
  /// د میاشتې رپوټ به غلط و.
  Future<void> decide({
    required int leaveId,
    required bool approve,
    String? note,
    required int byUserId,
    required String byUserName,
  }) async {
    await db.transaction(() async {
      final leave = await (db.select(
        db.leaveRequests,
      )..where((l) => l.id.equals(leaveId))).getSingle();

      await (db.update(
        db.leaveRequests,
      )..where((l) => l.id.equals(leaveId))).write(
        LeaveRequestsCompanion(
          status: Value(approve ? 'approved' : 'rejected'),
          decidedByUserId: Value(byUserId),
          decidedAt: Value(DateTime.now()),
          decisionNote: Value(note),
        ),
      );

      if (approve) {
        await db.customUpdate(
          "UPDATE attendances SET status = 'leave', leave_request_id = ? "
          'WHERE student_id = ? AND date >= ? AND date <= ? '
          "AND status IN ('absent', 'late')",
          variables: [
            Variable<int>(leaveId),
            Variable<int>(leave.studentId),
            Variable<DateTime>(leave.fromDate),
            Variable<DateTime>(leave.toDate),
          ],
          updates: {db.attendances},
        );
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'update',
              entity: 'leave_requests',
              entityId: Value(leaveId),
              userId: Value(byUserId),
              userName: Value(byUserName),
              changesJson: Value(
                '{"status":"${approve ? 'approved' : 'rejected'}"}',
              ),
            ),
          );
    });
  }

  Future<int> pendingCount() async {
    final row = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM leave_requests WHERE status = 'pending'",
          readsFrom: {db.leaveRequests},
        )
        .getSingle();
    return row.read<int>('c');
  }
}
