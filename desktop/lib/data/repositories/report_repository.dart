import 'package:drift/drift.dart';

import '../db/database.dart';
import 'attendance_repository.dart' show dateOnly;

/// د یوه رپوټ بشپړ محتوا — سرلیک، ستنې، کرښې او لنډیز.
///
/// **ولې ټول رپوټونه یو ډول دي؟** ځکه چې چاپ، CSV او د پردې جدول
/// درې ځله جوړول د هر رپوټ لپاره درې چنده کار و. یوه بڼه = یو
/// چاپ‌کوونکی، یو صادروونکی، یو جدول.
class ReportTable {
  final String title;
  final String subtitle;
  final List<String> columns;
  final List<List<String>> rows;

  /// د پای کرښه — «ټول». که تشه وي، نه ښکاري.
  final List<String> totals;

  /// د پورتنیو کارتونو شمېرې.
  final List<({String label, String value, bool warn})> highlights;

  const ReportTable({
    required this.title,
    required this.subtitle,
    required this.columns,
    required this.rows,
    this.totals = const [],
    this.highlights = const [],
  });

  bool get isEmpty => rows.isEmpty;
}

/// هغه رپوټونه چې سیسټم يې جوړولی شي.
enum ReportKind {
  attendance('د حاضرۍ رپوټ'),
  fees('د فیس د راټولولو رپوټ'),
  exam('د ازموینې پایلې'),
  enrollment('د شاګردانو شمېرې'),
  staff('د کارکوونکو او معاشونو');

  final String label;
  const ReportKind(this.label);
}

class ReportRepository {
  final AppDatabase db;
  ReportRepository(this.db);

  static String _n(num v) => v.toStringAsFixed(0);
  static String _pct(num v) => '${v.toStringAsFixed(0)}٪';
  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';

  /// هغه وروستۍ میاشت چې حاضري پکې ثبت شوې.
  ///
  /// **ولې دا، نه «نن»؟** ځکه چې د میاشتې په لومړۍ ورځ به رپوټ تش
  /// و او مدیر به فکر کاوه چې څه خراب دي. یا که ښوونځی د اوړي په
  /// رخصتۍ کې وي، د دوو میاشتو لپاره به تش و. دا تل هغه څه ښیي
  /// چې شته.
  Future<DateTime?> latestAttendanceMonth() async {
    final row = await db
        .customSelect(
          'SELECT MAX(date) AS d FROM attendances',
          readsFrom: {db.attendances},
        )
        .getSingleOrNull();
    final v = row?.data['d'];
    if (v == null) return null;
    final at = v is int
        ? DateTime.fromMillisecondsSinceEpoch(v * 1000)
        : DateTime.tryParse('$v');
    return at == null ? null : DateTime(at.year, at.month, 1);
  }

  // ═══════════════════════════════════════════════════════
  //  ۱. حاضري
  // ═══════════════════════════════════════════════════════

  /// د یوې میاشتې د حاضرۍ رپوټ — یا د یوه بخش، یا د ټول ښوونځي.
  ///
  /// **سلنه د ثبت شویو ورځو له مخې شمېرل کېږي، نه د میاشتې.** که
  /// ښوونځی لس ورځې تړلی و، هغه ورځې نه شمېرل کېږي — که نه، د هر
  /// چا حاضري به غلطه ټیټه ښکاره شوه.
  Future<ReportTable> attendance({
    required DateTime month,
    int? sectionId,
    String? sectionLabel,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final rows = await db
        .customSelect(
          '''
SELECT s.first_name || COALESCE(' ' || s.last_name, '') AS name,
       s.admission_no AS adm,
       g.name || ' — ' || sec.name AS class_name,
       SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) AS present,
       SUM(CASE WHEN a.status = 'late'    THEN 1 ELSE 0 END) AS late,
       SUM(CASE WHEN a.status = 'absent'  THEN 1 ELSE 0 END) AS absent,
       SUM(CASE WHEN a.status = 'leave'   THEN 1 ELSE 0 END) AS onleave,
       COUNT(a.id) AS marked
FROM enrollments e
JOIN students s ON s.id = e.student_id AND s.deleted_at IS NULL
JOIN sections sec ON sec.id = e.section_id
JOIN grades g ON g.id = sec.grade_id
LEFT JOIN attendances a ON a.student_id = s.id
     AND a.date >= ? AND a.date <= ?
WHERE e.is_active = 1 ${sectionId == null ? '' : 'AND e.section_id = ?'}
GROUP BY s.id
ORDER BY g.level, sec.name, s.first_name
''',
          variables: [
            Variable<DateTime>(start),
            Variable<DateTime>(end),
            if (sectionId != null) Variable<int>(sectionId),
          ],
          readsFrom: {
            db.enrollments,
            db.students,
            db.sections,
            db.grades,
            db.attendances,
          },
        )
        .get();

    var tPresent = 0, tLate = 0, tAbsent = 0, tLeave = 0, tMarked = 0;
    final out = <List<String>>[];

    for (final r in rows) {
      final present = r.read<int>('present');
      final late = r.read<int>('late');
      final absent = r.read<int>('absent');
      final leave = r.read<int>('onleave');
      final marked = r.read<int>('marked');

      // رخصت نه د حاضرۍ په ګټه دی، نه په زیان — نو له کچې وځي.
      final counted = present + late + absent;
      final pct = counted == 0 ? 0.0 : ((present + late) / counted) * 100;

      tPresent += present;
      tLate += late;
      tAbsent += absent;
      tLeave += leave;
      tMarked += marked;

      out.add([
        r.read<String>('name'),
        r.read<String>('adm'),
        r.read<String>('class_name'),
        _n(present),
        _n(late),
        _n(absent),
        _n(leave),
        _pct(pct),
      ]);
    }

    final counted = tPresent + tLate + tAbsent;
    final overall = counted == 0 ? 0.0 : ((tPresent + tLate) / counted) * 100;

    return ReportTable(
      title: ReportKind.attendance.label,
      subtitle:
          '${sectionLabel ?? 'ټول ښوونځی'} — '
          '${month.year}/${month.month.toString().padLeft(2, '0')}',
      columns: const [
        'شاګرد',
        'د داخلې نمبر',
        'ټولګی',
        'حاضر',
        'ناوخته',
        'غیرحاضر',
        'رخصت',
        'سلنه',
      ],
      rows: out,
      totals: [
        'ټول',
        '${out.length} تنه',
        '',
        _n(tPresent),
        _n(tLate),
        _n(tAbsent),
        _n(tLeave),
        _pct(overall),
      ],
      highlights: [
        (label: 'شاګردان', value: _n(out.length), warn: false),
        (label: 'د حاضرۍ سلنه', value: _pct(overall), warn: overall < 85),
        (label: 'ثبت شوې ورځې', value: _n(tMarked), warn: tMarked == 0),
        (label: 'غیرحاضري', value: _n(tAbsent), warn: tAbsent > 0),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ۲. فیس
  // ═══════════════════════════════════════════════════════

  /// د یوې دورې د راټولولو رپوټ، په ټولګیو ویشل شوی.
  Future<ReportTable> fees({String? period}) async {
    final rows = await db
        .customSelect(
          '''
SELECT g.name || ' — ' || sec.name AS class_name,
       COUNT(DISTINCT i.student_id) AS students,
       COALESCE(SUM(i.amount), 0) AS invoiced,
       COALESCE(SUM(i.discount), 0) AS discount,
       COALESCE(SUM((SELECT COALESCE(SUM(p.amount), 0) FROM fee_payments p
                       WHERE p.invoice_id = i.id)), 0) AS collected,
       SUM(CASE WHEN i.status = 'waived' THEN 1 ELSE 0 END) AS waived
FROM fee_invoices i
JOIN students s ON s.id = i.student_id AND s.deleted_at IS NULL
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
${period == null ? '' : 'WHERE i.period = ?'}
GROUP BY sec.id
ORDER BY g.level, sec.name
''',
          variables: [if (period != null) Variable<String>(period)],
          readsFrom: {
            db.feeInvoices,
            db.students,
            db.enrollments,
            db.sections,
            db.grades,
            db.feePayments,
          },
        )
        .get();

    var tStudents = 0, tInvoiced = 0, tDiscount = 0, tCollected = 0;
    final out = <List<String>>[];

    for (final r in rows) {
      final invoiced = r.read<int>('invoiced');
      final discount = r.read<int>('discount');
      final collected = r.read<int>('collected');
      final payable = invoiced - discount;
      final pct = payable == 0 ? 0.0 : (collected / payable) * 100;

      tStudents += r.read<int>('students');
      tInvoiced += invoiced;
      tDiscount += discount;
      tCollected += collected;

      out.add([
        r.data['class_name'] as String? ?? '—',
        _n(r.read<int>('students')),
        _n(invoiced),
        _n(discount),
        _n(collected),
        _n(payable - collected),
        _pct(pct),
      ]);
    }

    final tPayable = tInvoiced - tDiscount;
    final tPct = tPayable == 0 ? 0.0 : (tCollected / tPayable) * 100;

    return ReportTable(
      title: ReportKind.fees.label,
      subtitle: period == null ? 'ټولې دورې' : 'دوره $period',
      columns: const [
        'ټولګی',
        'شاګردان',
        'بل شوی',
        'تخفیف',
        'راټول شوی',
        'پاتې',
        'سلنه',
      ],
      rows: out,
      totals: [
        'ټول',
        _n(tStudents),
        _n(tInvoiced),
        _n(tDiscount),
        _n(tCollected),
        _n(tPayable - tCollected),
        _pct(tPct),
      ],
      highlights: [
        (label: 'د ورکړې وړ', value: _n(tPayable), warn: false),
        (label: 'راټول شوی', value: _n(tCollected), warn: false),
        (
          label: 'پاتې',
          value: _n(tPayable - tCollected),
          warn: tPayable - tCollected > 0,
        ),
        (label: 'د راټولولو سلنه', value: _pct(tPct), warn: tPct < 70),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ۳. ازموینه
  // ═══════════════════════════════════════════════════════

  /// د یوې ازموینې د ټولګیو پرتله.
  Future<ReportTable> exam({required int examId}) async {
    final exam = await (db.select(
      db.exams,
    )..where((e) => e.id.equals(examId))).getSingleOrNull();
    if (exam == null) {
      return const ReportTable(
        title: 'د ازموینې پایلې',
        subtitle: '—',
        columns: [],
        rows: [],
      );
    }

    // د هر شاګرد مجموعه، بیا په ټولګیو راټولوو.
    final rows = await db
        .customSelect(
          '''
SELECT sec.id AS sec_id,
       g.name || ' — ' || sec.name AS class_name,
       g.level AS level,
       en.student_id AS student_id,
       SUM(es.full_mark) AS full_total,
       SUM(COALESCE(m.obtained, 0)) AS obtained_total,
       SUM(CASE WHEN m.is_absent = 1
                  OR COALESCE(m.obtained, 0) < es.pass_mark
                THEN 1 ELSE 0 END) AS failed_subjects
FROM enrollments en
JOIN sections sec ON sec.id = en.section_id
JOIN grades g ON g.id = sec.grade_id
JOIN exam_subjects es ON es.exam_id = ? AND es.grade_id = sec.grade_id
LEFT JOIN marks m ON m.exam_subject_id = es.id
     AND m.student_id = en.student_id
WHERE en.is_active = 1
GROUP BY en.student_id
''',
          variables: [Variable<int>(examId)],
          readsFrom: {
            db.enrollments,
            db.sections,
            db.grades,
            db.examSubjects,
            db.marks,
          },
        )
        .get();

    // په ټولګیو ډلبندي.
    final bySection =
        <int, ({String name, int level, List<(double, int)> students})>{};
    for (final r in rows) {
      final secId = r.read<int>('sec_id');
      final full = r.read<double>('full_total');
      final got = r.read<double>('obtained_total');
      final failed = r.read<int>('failed_subjects');

      bySection
          .putIfAbsent(
            secId,
            () => (
              name: r.read<String>('class_name'),
              level: r.read<int>('level'),
              students: <(double, int)>[],
            ),
          )
          .students
          .add((full == 0 ? 0 : (got / full) * 100, failed));
    }

    final ordered = bySection.entries.toList()
      ..sort((a, b) => a.value.level.compareTo(b.value.level));

    var tStudents = 0, tPassed = 0;
    final out = <List<String>>[];

    for (final e in ordered) {
      final list = e.value.students;
      if (list.isEmpty) continue;

      final passed = list.where((s) => s.$2 == 0).length;
      final avg = list.map((s) => s.$1).reduce((a, b) => a + b) / list.length;
      final best = list.map((s) => s.$1).reduce((a, b) => a > b ? a : b);

      tStudents += list.length;
      tPassed += passed;

      out.add([
        e.value.name,
        _n(list.length),
        _n(passed),
        _n(list.length - passed),
        _pct((passed / list.length) * 100),
        _pct(avg),
        _pct(best),
      ]);
    }

    return ReportTable(
      title: ReportKind.exam.label,
      subtitle: exam.name,
      columns: const [
        'ټولګی',
        'شاګردان',
        'کامیاب',
        'ناکام',
        'د کامیابۍ سلنه',
        'اوسط',
        'لوړه',
      ],
      rows: out,
      totals: [
        'ټول',
        _n(tStudents),
        _n(tPassed),
        _n(tStudents - tPassed),
        _pct(tStudents == 0 ? 0 : (tPassed / tStudents) * 100),
        '',
        '',
      ],
      highlights: [
        (label: 'شاګردان', value: _n(tStudents), warn: false),
        (label: 'کامیاب', value: _n(tPassed), warn: false),
        (
          label: 'ناکام',
          value: _n(tStudents - tPassed),
          warn: tStudents - tPassed > 0,
        ),
        (
          label: 'د کامیابۍ سلنه',
          value: _pct(tStudents == 0 ? 0 : (tPassed / tStudents) * 100),
          warn: tStudents > 0 && tPassed / tStudents < 0.7,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ۴. شاګردان
  // ═══════════════════════════════════════════════════════

  Future<ReportTable> enrollment() async {
    final rows = await db
        .customSelect(
          '''
SELECT g.name || ' — ' || sec.name AS class_name,
       g.level AS level,
       sec.capacity AS capacity,
       SUM(CASE WHEN s.gender = 'male'   THEN 1 ELSE 0 END) AS boys,
       SUM(CASE WHEN s.gender = 'female' THEN 1 ELSE 0 END) AS girls,
       COUNT(*) AS total
FROM enrollments e
JOIN students s ON s.id = e.student_id AND s.deleted_at IS NULL
     AND s.status = 'active'
JOIN sections sec ON sec.id = e.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE e.is_active = 1
GROUP BY sec.id
ORDER BY g.level, sec.name
''',
          readsFrom: {db.enrollments, db.students, db.sections, db.grades},
        )
        .get();

    var tBoys = 0, tGirls = 0, tCapacity = 0;
    final out = <List<String>>[];

    for (final r in rows) {
      final boys = r.read<int>('boys');
      final girls = r.read<int>('girls');
      final total = r.read<int>('total');
      final capacity = r.read<int>('capacity');

      tBoys += boys;
      tGirls += girls;
      tCapacity += capacity;

      out.add([
        r.read<String>('class_name'),
        _n(boys),
        _n(girls),
        _n(total),
        _n(capacity),
        _n(capacity - total),
        _pct(capacity == 0 ? 0 : (total / capacity) * 100),
      ]);
    }

    final tTotal = tBoys + tGirls;

    // هغه شاګردان چې ټولګي ته نه دي ټاکل شوي — دا یوه ریښتینې
    // ستونزه ده چې مدیر باید وویني.
    final orphan = await db
        .customSelect(
          '''
SELECT COUNT(*) AS c FROM students s
WHERE s.deleted_at IS NULL AND s.status = 'active'
  AND NOT EXISTS (SELECT 1 FROM enrollments e
                    WHERE e.student_id = s.id AND e.is_active = 1)
''',
          readsFrom: {db.students, db.enrollments},
        )
        .getSingle();

    return ReportTable(
      title: ReportKind.enrollment.label,
      subtitle: 'د ${_iso(dateOnly(DateTime.now()))} حالت',
      columns: const [
        'ټولګی',
        'هلکان',
        'نجونې',
        'ټول',
        'ظرفیت',
        'خالي',
        'ډکوالی',
      ],
      rows: out,
      totals: [
        'ټول',
        _n(tBoys),
        _n(tGirls),
        _n(tTotal),
        _n(tCapacity),
        _n(tCapacity - tTotal),
        _pct(tCapacity == 0 ? 0 : (tTotal / tCapacity) * 100),
      ],
      highlights: [
        (label: 'ټول شاګردان', value: _n(tTotal), warn: false),
        (label: 'هلکان', value: _n(tBoys), warn: false),
        (label: 'نجونې', value: _n(tGirls), warn: false),
        (
          label: 'بې‌ټولګي',
          value: _n(orphan.read<int>('c')),
          warn: orphan.read<int>('c') > 0,
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════
  //  ۵. کارکوونکي
  // ═══════════════════════════════════════════════════════

  Future<ReportTable> staff() async {
    final rows = await db
        .customSelect(
          """
SELECT 'استادان' AS dep, COUNT(*) AS headcount,
       COALESCE(SUM(monthly_salary), 0) AS total,
       COALESCE(AVG(monthly_salary), 0) AS avg_salary
FROM teachers WHERE deleted_at IS NULL AND status = 'active'
UNION ALL
SELECT COALESCE(department, 'بل'), COUNT(*),
       COALESCE(SUM(monthly_salary), 0),
       COALESCE(AVG(monthly_salary), 0)
FROM staff_members WHERE deleted_at IS NULL AND status = 'active'
GROUP BY department
""",
          readsFrom: {db.teachers, db.staffMembers},
        )
        .get();

    var tHead = 0, tTotal = 0;
    final out = <List<String>>[];

    for (final r in rows) {
      final head = r.read<int>('headcount');
      if (head == 0) continue;
      final total = r.read<int>('total');

      tHead += head;
      tTotal += total;

      out.add([
        r.read<String>('dep'),
        _n(head),
        _n(total),
        _n(r.read<double>('avg_salary')),
      ]);
    }

    return ReportTable(
      title: ReportKind.staff.label,
      subtitle: 'میاشتنی — د ${_iso(dateOnly(DateTime.now()))} حالت',
      columns: const ['څانګه', 'کارکوونکي', 'میاشتنی معاش', 'اوسط'],
      rows: out,
      totals: [
        'ټول',
        _n(tHead),
        _n(tTotal),
        _n(tHead == 0 ? 0 : tTotal / tHead),
      ],
      highlights: [
        (label: 'کارکوونکي', value: _n(tHead), warn: false),
        (label: 'میاشتنی معاش', value: _n(tTotal), warn: false),
        (label: 'کلنی', value: _n(tTotal * 12), warn: false),
        (
          label: 'اوسط معاش',
          value: _n(tHead == 0 ? 0 : tTotal / tHead),
          warn: false,
        ),
      ],
    );
  }
}
