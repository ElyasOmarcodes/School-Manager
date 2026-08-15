import 'package:drift/drift.dart';

import '../db/database.dart';
import 'student_repository.dart' show Paged;

/// یو بل له خپل شاګرد او د تادیو له مجموعې سره.
class InvoiceRow {
  final FeeInvoice invoice;
  final Student student;
  final String? className;
  final String feeName;
  final int paid;

  const InvoiceRow({
    required this.invoice,
    required this.student,
    required this.feeName,
    required this.paid,
    this.className,
  });

  /// **د ورکړې وړ اندازه = بل − تخفیف.** تخفیف د بل یوه برخه ده،
  /// نه یوه جلا تادیه — که نه، رسید به يې غلط ښوده.
  int get payable => invoice.amount - invoice.discount;
  int get balance => payable - paid;
  bool get isSettled => invoice.status == 'waived' || balance <= 0;
  bool get isOverdue =>
      !isSettled && invoice.dueDate.isBefore(DateTime.now());
}

/// د یوې دورې د راټولولو انځور.
class CollectionSummary {
  final int invoiced;
  final int discounted;
  final int collected;
  final int studentCount;
  final int paidCount;
  final int partialCount;
  final int unpaidCount;

  const CollectionSummary({
    this.invoiced = 0,
    this.discounted = 0,
    this.collected = 0,
    this.studentCount = 0,
    this.paidCount = 0,
    this.partialCount = 0,
    this.unpaidCount = 0,
  });

  int get payable => invoiced - discounted;
  int get outstanding => payable - collected;
  double get percent => payable == 0 ? 0 : (collected / payable) * 100;
}

/// د یوې دورې د بلونو جوړولو پایله.
class InvoiceRunResult {
  final int created;
  final int skipped;
  const InvoiceRunResult({required this.created, required this.skipped});
}

class FeeRepository {
  final AppDatabase db;
  FeeRepository(this.db);

  // ── ډولونه ──────────────────────────────────────────────

  Future<List<FeeType>> types({bool activeOnly = true}) {
    final q = db.select(db.feeTypes)
      ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]);
    if (activeOnly) q.where((t) => t.isActive.equals(true));
    return q.get();
  }

  Future<int> addType({
    required String name,
    required int amount,
    String frequency = 'monthly',
    int? gradeId,
  }) {
    return db
        .into(db.feeTypes)
        .insert(
          FeeTypesCompanion.insert(
            name: name,
            amount: amount,
            frequency: Value(frequency),
            gradeId: Value(gradeId),
          ),
        );
  }

  Future<void> setTypeActive(int id, bool active) =>
      (db.update(db.feeTypes)..where((t) => t.id.equals(id))).write(
        FeeTypesCompanion(isActive: Value(active)),
      );

  /// د یوه عادي ښوونځي عام فیسونه.
  Future<void> seedDefaultTypes() async {
    if ((await db.select(db.feeTypes).get()).isNotEmpty) return;
    const list = [
      ('میاشتنی فیس', 500, 'monthly'),
      ('د داخلې فیس', 1000, 'one_time'),
      ('د کتابونو پیسې', 800, 'annual'),
      ('د ازموینې فیس', 200, 'term'),
    ];
    var order = 0;
    for (final (name, amount, freq) in list) {
      await db
          .into(db.feeTypes)
          .insert(
            FeeTypesCompanion.insert(
              name: name,
              amount: amount,
              frequency: Value(freq),
              sortOrder: Value(order++),
            ),
          );
    }
  }

  // ── بلونه ───────────────────────────────────────────────

  /// د یوې دورې لپاره د ټولو فعالو شاګردانو بلونه جوړوي.
  ///
  /// **دوه ځله ځغلول خوندي دي.** که مدیر تڼۍ دوه ځله کېکاږي، هغه
  /// بلونه چې شته دي پرېښودل کېږي — نه چې د یوې میاشتې دوه فیسونه
  /// جوړ شي او کورنۍ ته دوه ځله ورکړه ورسېږي.
  Future<InvoiceRunResult> generate({
    required int feeTypeId,
    required String period,
    required DateTime dueDate,
    required int academicYearId,
    int? gradeId,
    int? byUserId,
  }) async {
    final type = await (db.select(
      db.feeTypes,
    )..where((t) => t.id.equals(feeTypeId))).getSingle();

    final targetGrade = gradeId ?? type.gradeId;

    final rows = await db
        .customSelect(
          '''
SELECT s.id AS id
FROM students s
JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
JOIN sections sec ON sec.id = e.section_id
WHERE s.deleted_at IS NULL AND s.status = 'active'
  ${targetGrade == null ? '' : 'AND sec.grade_id = ?'}
''',
          variables: [
            if (targetGrade != null) Variable<int>(targetGrade),
          ],
          readsFrom: {db.students, db.enrollments, db.sections},
        )
        .get();

    var created = 0;
    var skipped = 0;

    await db.transaction(() async {
      for (final r in rows) {
        final sid = r.read<int>('id');
        final exists =
            await (db.select(db.feeInvoices)
                  ..where((i) => i.studentId.equals(sid))
                  ..where((i) => i.feeTypeId.equals(feeTypeId))
                  ..where((i) => i.period.equals(period))
                  ..limit(1))
                .getSingleOrNull();
        if (exists != null) {
          skipped++;
          continue;
        }

        await db
            .into(db.feeInvoices)
            .insert(
              FeeInvoicesCompanion.insert(
                studentId: sid,
                feeTypeId: feeTypeId,
                academicYearId: academicYearId,
                period: period,
                amount: type.amount,
                dueDate: dueDate,
                createdByUserId: Value(byUserId),
              ),
            );
        created++;
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'fee_invoices',
              userId: Value(byUserId),
              changesJson: Value(
                '{"period":"$period","created":$created,"skipped":$skipped}',
              ),
            ),
          );
    });

    return InvoiceRunResult(created: created, skipped: skipped);
  }

  Future<Paged<InvoiceRow>> list({
    String? period,
    String? status,
    String query = '',
    int? sectionId,
    int limit = 50,
    int offset = 0,
  }) async {
    final where = <String>['s.deleted_at IS NULL'];
    final args = <Variable<Object>>[];

    if (period != null) {
      where.add('i.period = ?');
      args.add(Variable<String>(period));
    }
    if (status != null) {
      where.add('i.status = ?');
      args.add(Variable<String>(status));
    }
    if (sectionId != null) {
      where.add('e.section_id = ?');
      args.add(Variable<int>(sectionId));
    }
    if (query.trim().isNotEmpty) {
      where.add('(s.first_name LIKE ? OR s.admission_no LIKE ?)');
      args
        ..add(Variable<String>('%${query.trim()}%'))
        ..add(Variable<String>('%${query.trim()}%'));
    }

    final whereSql = 'WHERE ${where.join(' AND ')}';
    const joins = '''
FROM fee_invoices i
JOIN students s ON s.id = i.student_id
JOIN fee_types ft ON ft.id = i.fee_type_id
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
''';

    final count = await db
        .customSelect(
          'SELECT COUNT(*) AS c $joins $whereSql',
          variables: args,
          readsFrom: {
            db.feeInvoices,
            db.students,
            db.feeTypes,
            db.enrollments,
            db.sections,
          },
        )
        .getSingle();

    final rows = await db
        .customSelect(
          '''
SELECT i.*, s.id AS s_id, s.admission_no, s.first_name, s.last_name,
       s.father_name, s.gender, s.status AS s_status, s.card_version,
       s.admitted_on, s.created_at AS s_created, s.updated_at AS s_updated,
       ft.name AS fee_name,
       g.name || ' — ' || sec.name AS class_name,
       COALESCE((SELECT SUM(p.amount) FROM fee_payments p
                   WHERE p.invoice_id = i.id), 0) AS paid
$joins
$whereSql
ORDER BY i.status = 'unpaid' DESC, i.due_date, s.first_name
LIMIT ? OFFSET ?
''',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {
            db.feeInvoices,
            db.students,
            db.feeTypes,
            db.feePayments,
            db.enrollments,
            db.sections,
            db.grades,
          },
        )
        .get();

    return Paged(
      rows.map((r) {
        // د JOIN له امله `id` او `created_at` دواړو جدولونو کې دي —
        // نو د شاګرد ستنې په لاس جوړوو.
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
          createdAt: r.read<DateTime>('s_created'),
          updatedAt: r.read<DateTime>('s_updated'),
        );
        return InvoiceRow(
          invoice: db.feeInvoices.map(r.data),
          student: student,
          className: r.data['class_name'] as String?,
          feeName: r.read<String>('fee_name'),
          paid: r.read<int>('paid'),
        );
      }).toList(),
      count.read<int>('c'),
    );
  }

  // ── تادیه ───────────────────────────────────────────────

  /// راتلونکی د رسید نمبر — «R-000123».
  Future<String> nextReceiptNo() async {
    final row = await db
        .customSelect(
          "SELECT receipt_no FROM fee_payments WHERE receipt_no LIKE 'R-%' "
          'ORDER BY receipt_no DESC LIMIT 1',
          readsFrom: {db.feePayments},
        )
        .getSingleOrNull();

    var next = 1;
    if (row != null) {
      next = (int.tryParse(row.read<String>('receipt_no').split('-').last) ?? 0) + 1;
    }
    return 'R-${next.toString().padLeft(6, '0')}';
  }

  /// تادیه ثبتوي او د بل حالت پخپله تازه کوي.
  ///
  /// **حالت لاسي نه ټاکل کېږي.** که ریسیپشن يې په لاس «ورکړل شوی»
  /// کاوه، یوه تېروتنه به يې د پور کرښه پټه کړه. حالت تل د تادیو
  /// له مجموعې راځي.
  Future<int> pay({
    required int invoiceId,
    required int amount,
    String method = 'cash',
    String? receiptNo,
    int? byUserId,
    String? note,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    return db.transaction(() async {
      final id = await db
          .into(db.feePayments)
          .insert(
            FeePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: amount,
              method: Value(method),
              receiptNo: receiptNo ?? await nextReceiptNo(),
              paidOn: Value(at),
              receivedByUserId: Value(byUserId),
              note: Value(note),
            ),
          );
      await _refreshStatus(invoiceId);
      return id;
    });
  }

  Future<void> setDiscount({
    required int invoiceId,
    required int discount,
    String? reason,
  }) async {
    await (db.update(db.feeInvoices)..where((i) => i.id.equals(invoiceId)))
        .write(
          FeeInvoicesCompanion(
            discount: Value(discount),
            discountReason: Value(reason),
          ),
        );
    await _refreshStatus(invoiceId);
  }

  /// بل بښل — د یتیم یا د بېوزلې کورنۍ لپاره.
  Future<void> waive(int invoiceId, {String? reason, int? byUserId}) async {
    await (db.update(db.feeInvoices)..where((i) => i.id.equals(invoiceId)))
        .write(
          FeeInvoicesCompanion(
            status: const Value('waived'),
            discountReason: Value(reason),
          ),
        );
    await db
        .into(db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            action: 'update',
            entity: 'fee_invoices',
            entityId: Value(invoiceId),
            userId: Value(byUserId),
            changesJson: const Value('{"status":"waived"}'),
          ),
        );
  }

  Future<void> _refreshStatus(int invoiceId) async {
    final invoice = await (db.select(
      db.feeInvoices,
    )..where((i) => i.id.equals(invoiceId))).getSingle();
    if (invoice.status == 'waived') return;

    final row = await db
        .customSelect(
          'SELECT COALESCE(SUM(amount), 0) AS paid FROM fee_payments '
          'WHERE invoice_id = ?',
          variables: [Variable<int>(invoiceId)],
          readsFrom: {db.feePayments},
        )
        .getSingle();

    final paid = row.read<int>('paid');
    final payable = invoice.amount - invoice.discount;

    await (db.update(db.feeInvoices)..where((i) => i.id.equals(invoiceId)))
        .write(
          FeeInvoicesCompanion(
            status: Value(
              paid <= 0
                  ? 'unpaid'
                  : paid >= payable
                  ? 'paid'
                  : 'partial',
            ),
          ),
        );
  }

  Future<List<FeePayment>> paymentsOf(int invoiceId) =>
      (db.select(db.feePayments)
            ..where((p) => p.invoiceId.equals(invoiceId))
            ..orderBy([(p) => OrderingTerm.desc(p.paidOn)]))
          .get();

  // ── رپوټونه ─────────────────────────────────────────────

  Future<CollectionSummary> summary({String? period}) async {
    final row = await db
        .customSelect(
          '''
SELECT
  COALESCE(SUM(i.amount), 0) AS invoiced,
  COALESCE(SUM(CASE WHEN i.status = 'waived' THEN i.amount - i.discount
                    ELSE i.discount END), 0) AS discounted,
  COALESCE(SUM((SELECT COALESCE(SUM(p.amount), 0) FROM fee_payments p
                  WHERE p.invoice_id = i.id)), 0) AS collected,
  COUNT(DISTINCT i.student_id) AS students,
  SUM(CASE WHEN i.status IN ('paid', 'waived') THEN 1 ELSE 0 END) AS paid_c,
  SUM(CASE WHEN i.status = 'partial' THEN 1 ELSE 0 END) AS partial_c,
  SUM(CASE WHEN i.status = 'unpaid' THEN 1 ELSE 0 END) AS unpaid_c
FROM fee_invoices i
${period == null ? '' : 'WHERE i.period = ?'}
''',
          variables: [if (period != null) Variable<String>(period)],
          readsFrom: {db.feeInvoices, db.feePayments},
        )
        .getSingle();

    return CollectionSummary(
      invoiced: row.read<int>('invoiced'),
      discounted: row.read<int>('discounted'),
      collected: row.read<int>('collected'),
      studentCount: row.read<int>('students'),
      paidCount: row.data['paid_c'] as int? ?? 0,
      partialCount: row.data['partial_c'] as int? ?? 0,
      unpaidCount: row.data['unpaid_c'] as int? ?? 0,
    );
  }

  /// هغه کورونه چې تر ټولو ډېر پور لري — مدیر باید زنګ ورته ووهي.
  Future<List<({Student student, String? className, int balance, int months})>>
  defaulters({int limit = 20}) async {
    final rows = await db
        .customSelect(
          '''
SELECT s.id AS s_id, s.admission_no, s.first_name, s.last_name,
       s.father_name, s.gender, s.status AS s_status, s.card_version,
       s.admitted_on, s.created_at AS s_created, s.updated_at AS s_updated,
       g.name || ' — ' || sec.name AS class_name,
       SUM(i.amount - i.discount
           - COALESCE((SELECT SUM(p.amount) FROM fee_payments p
                        WHERE p.invoice_id = i.id), 0)) AS balance,
       COUNT(*) AS months
FROM fee_invoices i
JOIN students s ON s.id = i.student_id AND s.deleted_at IS NULL
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
WHERE i.status IN ('unpaid', 'partial')
GROUP BY s.id
HAVING balance > 0
ORDER BY balance DESC
LIMIT ?
''',
          variables: [Variable<int>(limit)],
          readsFrom: {
            db.feeInvoices,
            db.students,
            db.feePayments,
            db.enrollments,
            db.sections,
            db.grades,
          },
        )
        .get();

    return rows
        .map(
          (r) => (
            student: Student(
              id: r.read<int>('s_id'),
              admissionNo: r.read<String>('admission_no'),
              firstName: r.read<String>('first_name'),
              lastName: r.data['last_name'] as String?,
              fatherName: r.read<String>('father_name'),
              gender: r.read<String>('gender'),
              status: r.read<String>('s_status'),
              cardVersion: r.read<int>('card_version'),
              admittedOn: r.read<DateTime>('admitted_on'),
              createdAt: r.read<DateTime>('s_created'),
              updatedAt: r.read<DateTime>('s_updated'),
            ),
            className: r.data['class_name'] as String?,
            balance: r.read<int>('balance'),
            months: r.read<int>('months'),
          ),
        )
        .toList();
  }

  /// د یوه شاګرد ټول پاتې پور — د والدینو اپ او ریسیپشن يې پوښتي.
  Future<int> balanceOf(int studentId) async {
    final row = await db
        .customSelect(
          '''
SELECT COALESCE(SUM(i.amount - i.discount
       - COALESCE((SELECT SUM(p.amount) FROM fee_payments p
                    WHERE p.invoice_id = i.id), 0)), 0) AS balance
FROM fee_invoices i
WHERE i.student_id = ? AND i.status IN ('unpaid', 'partial')
''',
          variables: [Variable<int>(studentId)],
          readsFrom: {db.feeInvoices, db.feePayments},
        )
        .getSingle();
    return row.read<int>('balance');
  }

  /// هغه دورې چې بلونه پکې شته — د ټاکلو لیست لپاره.
  Future<List<String>> periods() async {
    final rows = await db
        .customSelect(
          'SELECT DISTINCT period FROM fee_invoices ORDER BY period DESC',
          readsFrom: {db.feeInvoices},
        )
        .get();
    return rows.map((r) => r.read<String>('period')).toList();
  }
}
