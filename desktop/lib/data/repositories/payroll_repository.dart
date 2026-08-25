import 'package:drift/drift.dart';

import '../db/database.dart';

/// د یوې دورې د معاشونو لنډیز.
class PayrollSummary {
  final int headcount;
  final int baseTotal;
  final int allowanceTotal;
  final int deductionTotal;
  final int netTotal;
  final int paidCount;

  const PayrollSummary({
    this.headcount = 0,
    this.baseTotal = 0,
    this.allowanceTotal = 0,
    this.deductionTotal = 0,
    this.netTotal = 0,
    this.paidCount = 0,
  });
}

class PayrollRunRow {
  final PayrollRun run;
  final PayrollSummary summary;
  const PayrollRunRow({required this.run, required this.summary});
}

class PayrollRepository {
  final AppDatabase db;
  PayrollRepository(this.db);

  Future<List<PayrollRunRow>> runs() async {
    final rows = await db
        .customSelect(
          '''
SELECT r.*,
  COUNT(i.id) AS headcount,
  COALESCE(SUM(i.base_salary), 0) AS base_total,
  COALESCE(SUM(i.allowances), 0) AS allowance_total,
  COALESCE(SUM(i.deductions + i.absence_deduction), 0) AS deduction_total,
  COALESCE(SUM(i.net_pay), 0) AS net_total,
  SUM(CASE WHEN i.paid_at IS NOT NULL THEN 1 ELSE 0 END) AS paid_count
FROM payroll_runs r
LEFT JOIN payroll_items i ON i.run_id = r.id
GROUP BY r.id
ORDER BY r.period DESC
''',
          readsFrom: {db.payrollRuns, db.payrollItems},
        )
        .get();

    return rows
        .map(
          (r) => PayrollRunRow(
            run: db.payrollRuns.map(r.data),
            summary: PayrollSummary(
              headcount: r.read<int>('headcount'),
              baseTotal: r.read<int>('base_total'),
              allowanceTotal: r.read<int>('allowance_total'),
              deductionTotal: r.read<int>('deduction_total'),
              netTotal: r.read<int>('net_total'),
              paidCount: r.data['paid_count'] as int? ?? 0,
            ),
          ),
        )
        .toList();
  }

  /// یوه نوې دوره جوړوي او د ټولو فعالو کارکوونکو کرښې پکې اچوي.
  ///
  /// **معاش له کارکوونکي څخه کاپي کېږي، نه تړل کېږي.** که چا معاش
  /// راتلونکې میاشت پورته شي، د تېرې میاشتې رسید باید هماغه زړه
  /// اندازه وښيي — نه نوې.
  Future<int> createRun({
    required String period,
    required int byUserId,
  }) async {
    final existing =
        await (db.select(db.payrollRuns)
              ..where((r) => r.period.equals(period))
              ..limit(1))
            .getSingleOrNull();
    if (existing != null) return existing.id;

    return db.transaction(() async {
      final runId = await db
          .into(db.payrollRuns)
          .insert(
            PayrollRunsCompanion.insert(
              period: period,
              createdByUserId: Value(byUserId),
            ),
          );

      final teachers =
          await (db.select(db.teachers)
                ..where((t) => t.deletedAt.isNull())
                ..where((t) => t.status.equals('active')))
              .get();
      for (final t in teachers) {
        final base = t.monthlySalary ?? 0;
        await db
            .into(db.payrollItems)
            .insert(
              PayrollItemsCompanion.insert(
                runId: runId,
                employeeKind: 'teacher',
                employeeId: t.id,
                employeeName: t.fullName,
                jobTitle: Value(t.specialization ?? 'استاد'),
                baseSalary: base,
                netPay: base,
              ),
            );
      }

      final staff =
          await (db.select(db.staffMembers)
                ..where((s) => s.deletedAt.isNull())
                ..where((s) => s.status.equals('active')))
              .get();
      for (final s in staff) {
        final base = s.monthlySalary ?? 0;
        await db
            .into(db.payrollItems)
            .insert(
              PayrollItemsCompanion.insert(
                runId: runId,
                employeeKind: 'staff',
                employeeId: s.id,
                employeeName: s.fullName,
                jobTitle: Value(s.jobTitle),
                baseSalary: base,
                netPay: base,
              ),
            );
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'payroll_runs',
              entityId: Value(runId),
              userId: Value(byUserId),
              changesJson: Value('{"period":"$period"}'),
            ),
          );

      return runId;
    });
  }

  Future<List<PayrollItem>> items(int runId) =>
      (db.select(db.payrollItems)
            ..where((i) => i.runId.equals(runId))
            ..orderBy([
              (i) => OrderingTerm.asc(i.employeeKind),
              (i) => OrderingTerm.asc(i.employeeName),
            ]))
          .get();

  /// یوه کرښه سموي — **خالص معاش پخپله شمېرل کېږي**.
  ///
  /// که خالص په لاس لیکل کېده، یوه د جمعې تېروتنه به د میاشتو
  /// لپاره پټه پاتې وه.
  Future<void> updateItem({
    required int itemId,
    int? allowances,
    int? deductions,
    int? absenceDeduction,
    int? absentDays,
    String? note,
  }) async {
    final item = await (db.select(
      db.payrollItems,
    )..where((i) => i.id.equals(itemId))).getSingle();

    final a = allowances ?? item.allowances;
    final d = deductions ?? item.deductions;
    final ad = absenceDeduction ?? item.absenceDeduction;
    final net = item.baseSalary + a - d - ad;

    await (db.update(db.payrollItems)..where((i) => i.id.equals(itemId)))
        .write(
          PayrollItemsCompanion(
            allowances: Value(a),
            deductions: Value(d),
            absenceDeduction: Value(ad),
            absentDays: Value(absentDays ?? item.absentDays),
            // **صفر تر کچې ښکته نه ځي.** یو کارکوونکی ښوونځي ته
            // پور نه ورکوي — که کسرونه له معاشه ډېر شي، خالص صفر
            // دی او پاتې يې د مدیر پرېکړه ده.
            netPay: Value(net < 0 ? 0 : net),
            note: Value(note ?? item.note),
          ),
        );
  }

  Future<void> approve(int runId, {required int byUserId}) =>
      (db.update(db.payrollRuns)..where((r) => r.id.equals(runId))).write(
        PayrollRunsCompanion(
          status: const Value('approved'),
          approvedAt: Value(DateTime.now()),
          approvedByUserId: Value(byUserId),
        ),
      );

  /// ټوله دوره «ورکړل شوې» نښه کوي.
  Future<int> markPaid(int runId, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final n = await (db.update(db.payrollItems)
          ..where((i) => i.runId.equals(runId))
          ..where((i) => i.paidAt.isNull()))
        .write(PayrollItemsCompanion(paidAt: Value(now)));

    await (db.update(db.payrollRuns)..where((r) => r.id.equals(runId))).write(
      const PayrollRunsCompanion(status: Value('paid')),
    );
    return n;
  }

  Future<PayrollSummary> summaryOf(int runId) async {
    final row = await db
        .customSelect(
          '''
SELECT COUNT(*) AS headcount,
  COALESCE(SUM(base_salary), 0) AS base_total,
  COALESCE(SUM(allowances), 0) AS allowance_total,
  COALESCE(SUM(deductions + absence_deduction), 0) AS deduction_total,
  COALESCE(SUM(net_pay), 0) AS net_total,
  SUM(CASE WHEN paid_at IS NOT NULL THEN 1 ELSE 0 END) AS paid_count
FROM payroll_items WHERE run_id = ?
''',
          variables: [Variable<int>(runId)],
          readsFrom: {db.payrollItems},
        )
        .getSingle();

    return PayrollSummary(
      headcount: row.read<int>('headcount'),
      baseTotal: row.read<int>('base_total'),
      allowanceTotal: row.read<int>('allowance_total'),
      deductionTotal: row.read<int>('deduction_total'),
      netTotal: row.read<int>('net_total'),
      paidCount: row.data['paid_count'] as int? ?? 0,
    );
  }
}
