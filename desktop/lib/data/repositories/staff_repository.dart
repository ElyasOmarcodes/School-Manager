import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../db/database.dart';
import 'student_repository.dart' show Paged;

/// هغه څانګې چې یو ښوونځی يې لري.
///
/// **ولې لیست، نه ازاد متن؟** ځکه چې «مالي»، «مالي برخه» او
/// «محاسبه» دې کمپیوټر ته درې بېلې څانګې دي — او د معاشونو رپوټ
/// به درې کرښې ښودلې. لیست دا مخنیوی کوي، خو «بل» هم پکې دی.
const List<String> staffDepartments = [
  'اداري',
  'مالي',
  'کتابتون',
  'روغتیا',
  'ساتنه',
  'پاکوالی',
  'ترانسپورت',
  'بل',
];

class StaffRow {
  final StaffMember staff;
  const StaffRow(this.staff);
}

class StaffFilter {
  final String query;
  final String? status;
  final String? department;

  const StaffFilter({
    this.query = '',
    this.status = 'active',
    this.department,
  });

  StaffFilter copyWith({
    String? query,
    String? status,
    String? department,
    bool clearStatus = false,
    bool clearDepartment = false,
  }) => StaffFilter(
    query: query ?? this.query,
    status: clearStatus ? null : (status ?? this.status),
    department: clearDepartment ? null : (department ?? this.department),
  );
}

/// د معاشونو لنډیز — د یوې څانګې لپاره.
class DepartmentPayroll {
  final String department;
  final int headcount;
  final int monthlyTotal;

  const DepartmentPayroll({
    required this.department,
    required this.headcount,
    required this.monthlyTotal,
  });
}

class StaffRepository {
  final AppDatabase db;
  StaffRepository(this.db);

  Future<Paged<StaffRow>> list({
    StaffFilter filter = const StaffFilter(),
    int limit = 50,
    int offset = 0,
  }) async {
    final where = <String>['s.deleted_at IS NULL'];
    final args = <Variable<Object>>[];

    if (filter.status != null) {
      where.add('s.status = ?');
      args.add(Variable<String>(filter.status!));
    }
    if (filter.department != null) {
      where.add('s.department = ?');
      args.add(Variable<String>(filter.department!));
    }

    final q = filter.query.trim();
    if (q.isNotEmpty) {
      // کارن ښايي نمبر په ختیځو شمېرو ولیکي — «۰۰۱۲» د «0012» پر
      // ځای. د لټون مخکې يې لاتیني کوو.
      final needle = '%${Numerals.toLatin(q)}%';
      where.add(
        '(s.employee_no LIKE ? OR s.full_name LIKE ? '
        'OR s.job_title LIKE ? OR s.phone LIKE ?)',
      );
      for (var i = 0; i < 4; i++) {
        args.add(Variable<String>(needle));
      }
    }

    final whereSql = 'WHERE ${where.join(' AND ')}';

    final countRow = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM staff_members s $whereSql',
          variables: args,
          readsFrom: {db.staffMembers},
        )
        .getSingle();

    final rows = await db
        .customSelect(
          'SELECT s.* FROM staff_members s $whereSql '
          'ORDER BY s.department, s.full_name LIMIT ? OFFSET ?',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {db.staffMembers},
        )
        .get();

    return Paged(
      rows.map((r) => StaffRow(db.staffMembers.map(r.data))).toList(),
      countRow.read<int>('c'),
    );
  }

  /// راتلونکی نمبر — «S-0001». د استادانو «T-» سره نه ګډېږي.
  Future<String> nextEmployeeNo() async {
    final row = await db
        .customSelect(
          "SELECT employee_no FROM staff_members "
          "WHERE employee_no LIKE 'S-%' "
          'ORDER BY employee_no DESC LIMIT 1',
          readsFrom: {db.staffMembers},
        )
        .getSingleOrNull();

    var next = 1;
    if (row != null) {
      final last = row.read<String>('employee_no').split('-').last;
      next = (int.tryParse(last) ?? 0) + 1;
    }
    return 'S-${next.toString().padLeft(4, '0')}';
  }

  Future<int> add({
    required StaffMembersCompanion staff,
    required int byUserId,
    required String byUserName,
  }) {
    return db.transaction(() async {
      final id = await db.into(db.staffMembers).insert(staff);
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'staff_members',
              entityId: Value(id),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );
      return id;
    });
  }

  /// ړنګول = پټول. د معاشونو تاریخچه باید پاتې شي.
  Future<void> softDelete(
    int id, {
    required int byUserId,
    required String byUserName,
  }) async {
    await db.transaction(() async {
      await (db.update(db.staffMembers)..where((s) => s.id.equals(id))).write(
        StaffMembersCompanion(
          deletedAt: Value(DateTime.now()),
          status: const Value('resigned'),
        ),
      );
      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'delete',
              entity: 'staff_members',
              entityId: Value(id),
              userId: Value(byUserId),
              userName: Value(byUserName),
            ),
          );
    });
  }

  /// د میاشتني معاش لنډیز — په څانګو ویشل شوی.
  ///
  /// **دا ولې دلته، نه د معاشونو په ماډل کې؟** ځکه چې د معاشونو
  /// ماډل (تادیه، کسرونه، رسیدونه) لا نه دی جوړ. تر هغې دا لنډیز
  /// مدیر ته د میاشتنۍ اندازې انځور ورکوي — او دا ریښتینې ډیټا ده،
  /// نه اټکل.
  Future<List<DepartmentPayroll>> payrollByDepartment() async {
    final rows = await db
        .customSelect(
          """
SELECT COALESCE(department, 'بل') AS dep,
       COUNT(*) AS headcount,
       COALESCE(SUM(monthly_salary), 0) AS total
FROM staff_members
WHERE deleted_at IS NULL AND status = 'active'
GROUP BY dep
ORDER BY total DESC
""",
          readsFrom: {db.staffMembers},
        )
        .get();

    return rows
        .map(
          (r) => DepartmentPayroll(
            department: r.read<String>('dep'),
            headcount: r.read<int>('headcount'),
            monthlyTotal: r.read<int>('total'),
          ),
        )
        .toList();
  }

  /// د ټول ښوونځي میاشتنی معاش — استادان او کارمندان یو ځای.
  Future<({int staffTotal, int teacherTotal, int headcount})>
  monthlyWageBill() async {
    final row = await db
        .customSelect(
          """
SELECT
  (SELECT COALESCE(SUM(monthly_salary), 0) FROM staff_members
     WHERE deleted_at IS NULL AND status = 'active') AS staff_total,
  (SELECT COALESCE(SUM(monthly_salary), 0) FROM teachers
     WHERE deleted_at IS NULL AND status = 'active') AS teacher_total,
  (SELECT COUNT(*) FROM staff_members
     WHERE deleted_at IS NULL AND status = 'active')
  + (SELECT COUNT(*) FROM teachers
     WHERE deleted_at IS NULL AND status = 'active') AS headcount
""",
          readsFrom: {db.staffMembers, db.teachers},
        )
        .getSingle();

    return (
      staffTotal: row.read<int>('staff_total'),
      teacherTotal: row.read<int>('teacher_total'),
      headcount: row.read<int>('headcount'),
    );
  }
}
