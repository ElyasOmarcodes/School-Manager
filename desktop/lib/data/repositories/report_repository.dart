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


// ═══════════════════════════════════════════════════════════
//  د کسانو راپورونه — شاګردان، استادان، کارمندان
// ═══════════════════════════════════════════════════════════

/// د راپور د وخت کچه.
enum ReportRange {
  day('ورځنی'),
  week('اونیز'),
  month('میاشتنی'),
  custom('ټاکلې دوره');

  final String label;
  const ReportRange(this.label);
}

/// ډله‌ییز که انفرادي.
///
/// **دا ولې دوه بېل راپورونه دي او نه یو؟** ځکه چې پوښتنې يې بېلې
/// دي. د ډلې پوښتنه «څوک ښه دی او څوک نه؟» ده — نو هر کس یوه کرښه
/// او شمېرې يې راټولې. د یوه کس پوښتنه «څه پېښ شول؟» ده — نو هره
/// ورځ یوه کرښه. یو ګډ جدول به دواړو ته نیمګړی و.
enum ReportScope {
  group('ډله‌ییز'),
  individual('انفرادي');

  final String label;
  const ReportScope(this.label);
}

/// د یوه کس لنډه پېژندنه — د «انفرادي» د ټاکلو لپاره.
class ReportPerson {
  final int id;
  final String name;
  final String idNo;
  final String group;

  const ReportPerson({
    required this.id,
    required this.name,
    required this.idNo,
    this.group = '',
  });

  String get label => group.isEmpty ? name : '$name — $group';
}

/// د کسانو د راپور فلټرونه.
///
/// **یو ټولګی د درې واړو ډلو لپاره.** د شاګرد فلټرونه (ټولګی،
/// استوګنه) د استاد لپاره تش پاتې کېږي او برعکس — خو یوه بڼه دا
/// معنا لري چې پاڼه، پوښتنه او اکسپورټ درې ځله نه لیکل کېږي.
class PeopleReportFilter {
  /// `student` | `teacher` | `staff`
  final String audience;

  final DateTime from;
  final DateTime to;
  final ReportRange range;
  final ReportScope scope;

  /// د «انفرادي» لپاره — که تش وي، لومړی کس اخیستل کېږي.
  final int? personId;

  final String query;
  final String? status;
  final String? gender;

  // ── د شاګردانو ───────────────────────────────────────────
  final int? sectionId;
  final String? residency;

  // ── د استادانو ───────────────────────────────────────────
  final String? specialization;

  // ── د کارمندانو ──────────────────────────────────────────
  final String? department;

  /// یوازې هغه چې حاضري يې له دې سلنې ټیټه ده — د «ستونزمنو»
  /// موندلو لپاره.
  final int? belowPercent;

  const PeopleReportFilter({
    required this.audience,
    required this.from,
    required this.to,
    this.range = ReportRange.month,
    this.scope = ReportScope.group,
    this.personId,
    this.query = '',
    this.status = 'active',
    this.gender,
    this.sectionId,
    this.residency,
    this.specialization,
    this.department,
    this.belowPercent,
  });

  /// څو فلټرونه فعال دي — د تڼۍ د شمېرې لپاره. حالت چې «فعال» وي،
  /// تلواله ده، نو نه شمېرل کېږي.
  int get activeCount => [
    if (status != null && status != 'active') status,
    gender,
    sectionId,
    residency,
    specialization,
    department,
    belowPercent,
  ].whereType<Object>().length;

  PeopleReportFilter copyWith({
    String? audience,
    DateTime? from,
    DateTime? to,
    ReportRange? range,
    ReportScope? scope,
    int? personId,
    String? query,
    String? status,
    String? gender,
    int? sectionId,
    String? residency,
    String? specialization,
    String? department,
    int? belowPercent,
    bool clearPerson = false,
    bool clearStatus = false,
    bool clearGender = false,
    bool clearSection = false,
    bool clearResidency = false,
    bool clearSpecialization = false,
    bool clearDepartment = false,
    bool clearBelow = false,
  }) => PeopleReportFilter(
    audience: audience ?? this.audience,
    from: from ?? this.from,
    to: to ?? this.to,
    range: range ?? this.range,
    scope: scope ?? this.scope,
    personId: clearPerson ? null : (personId ?? this.personId),
    query: query ?? this.query,
    status: clearStatus ? null : (status ?? this.status),
    gender: clearGender ? null : (gender ?? this.gender),
    sectionId: clearSection ? null : (sectionId ?? this.sectionId),
    residency: clearResidency ? null : (residency ?? this.residency),
    specialization: clearSpecialization
        ? null
        : (specialization ?? this.specialization),
    department: clearDepartment ? null : (department ?? this.department),
    belowPercent: clearBelow ? null : (belowPercent ?? this.belowPercent),
  );

  /// د یوې کچې لپاره د نېټو کړکۍ — د یوې لنګر نېټې له مخې.
  static (DateTime, DateTime) window(ReportRange range, DateTime anchor) {
    final d = DateTime(anchor.year, anchor.month, anchor.day);
    return switch (range) {
      ReportRange.day => (d, d),
      // اونۍ له شنبې پیلېږي — د افغانستان درسي اونۍ همداسې ده.
      ReportRange.week => () {
        final back = (d.weekday - DateTime.saturday + 7) % 7;
        final start = d.subtract(Duration(days: back));
        return (start, start.add(const Duration(days: 6)));
      }(),
      ReportRange.month => (
        DateTime(d.year, d.month, 1),
        DateTime(d.year, d.month + 1, 0),
      ),
      ReportRange.custom => (d, d),
    };
  }
}

class ReportRepository {
  final AppDatabase db;

  /// **«نن» له بهره راځي.**
  ///
  /// رپوټونه خپله نېټه په سرلیک کې لیکي — او هغه نېټه د عکس د
  /// ازموینې لپاره باید ثابته وي. که مستقیم `DateTime.now()` وای،
  /// د رپوټ عکس به هره ورځ بدل شوی و او ازموینه به سبا ماته وه.
  final DateTime Function() clock;

  ReportRepository(this.db, {this.clock = DateTime.now});

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
      subtitle: 'د ${_iso(dateOnly(clock()))} حالت',
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
      subtitle: 'میاشتنی — د ${_iso(dateOnly(clock()))} حالت',
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

  // ═══════════════════════════════════════════════════════
  //  ۶. د کسانو راپورونه
  // ═══════════════════════════════════════════════════════

  /// **هغه کسان چې فلټر يې مني** — د راپور بنسټ او د «انفرادي» لیست.
  ///
  /// **ولې د راپور جوړولو څخه جلا؟** ځکه چې همدا لیست د «انفرادي»
  /// د کس ټاکلو لپاره هم پکار دی. که دننه پټ و، پاڼې به بله ورته
  /// پوښتنه لیکلې وه — او دوه پوښتنې چې یو شی راوړي، یوه ورځ سره
  /// توپیر کوي.
  Future<List<ReportPerson>> people(PeopleReportFilter f) async {
    final q = f.query.trim();
    final like = '%$q%';

    if (f.audience == 'student') {
      final where = <String>['s.deleted_at IS NULL', 'e.is_active = 1'];
      final args = <Variable<Object>>[];
      if (f.status != null) {
        where.add('s.status = ?');
        args.add(Variable<String>(f.status!));
      }
      if (f.gender != null) {
        where.add('s.gender = ?');
        args.add(Variable<String>(f.gender!));
      }
      if (f.residency != null) {
        where.add('s.residency = ?');
        args.add(Variable<String>(f.residency!));
      }
      if (f.sectionId != null) {
        where.add('e.section_id = ?');
        args.add(Variable<int>(f.sectionId!));
      }
      if (q.isNotEmpty) {
        where.add('(s.first_name LIKE ? OR s.last_name LIKE ? '
            'OR s.admission_no LIKE ?)');
        args
          ..add(Variable<String>(like))
          ..add(Variable<String>(like))
          ..add(Variable<String>(like));
      }

      final rows = await db
          .customSelect(
            '''
SELECT s.id, s.admission_no AS id_no,
       s.first_name || COALESCE(' ' || s.last_name, '') AS name,
       g.name || ' — ' || sec.name AS grp
FROM students s
JOIN enrollments e ON e.student_id = s.id
JOIN sections sec ON sec.id = e.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE ${where.join(' AND ')}
ORDER BY g.level, sec.name, s.first_name
''',
            variables: args,
            readsFrom: {db.students, db.enrollments, db.sections, db.grades},
          )
          .get();
      return [
        for (final r in rows)
          ReportPerson(
            id: r.read<int>('id'),
            name: r.read<String>('name'),
            idNo: r.read<String>('id_no'),
            group: r.read<String>('grp'),
          ),
      ];
    }

    final teacher = f.audience == 'teacher';
    final table = teacher ? 'teachers' : 'staff_members';
    final grpCol = teacher ? 'specialization' : 'department';
    final where = <String>['deleted_at IS NULL'];
    final args = <Variable<Object>>[];
    if (f.status != null) {
      where.add('status = ?');
      args.add(Variable<String>(f.status!));
    }
    if (f.gender != null) {
      where.add('gender = ?');
      args.add(Variable<String>(f.gender!));
    }
    final tag = teacher ? f.specialization : f.department;
    if (tag != null) {
      where.add('$grpCol = ?');
      args.add(Variable<String>(tag));
    }
    if (q.isNotEmpty) {
      where.add('(full_name LIKE ? OR employee_no LIKE ?)');
      args
        ..add(Variable<String>(like))
        ..add(Variable<String>(like));
    }

    final rows = await db
        .customSelect(
          '''
SELECT id, employee_no AS id_no, full_name AS name,
       COALESCE($grpCol, '') AS grp
FROM $table
WHERE ${where.join(' AND ')}
ORDER BY full_name
''',
          variables: args,
          readsFrom: {db.teachers, db.staffMembers},
        )
        .get();
    return [
      for (final r in rows)
        ReportPerson(
          id: r.read<int>('id'),
          name: r.read<String>('name'),
          idNo: r.read<String>('id_no'),
          group: r.read<String>('grp'),
        ),
    ];
  }

  /// هغه ارزښتونه چې د فلټر ډراپ‌ډاونونو ته ځي — له ډیټابیسه، نه
  /// یو ثابت لیست، چې هر ښوونځی خپل وویني.
  Future<List<String>> reportTags(String audience) async {
    if (audience == 'student') return const [];
    final teacher = audience == 'teacher';
    final table = teacher ? 'teachers' : 'staff_members';
    final col = teacher ? 'specialization' : 'department';
    final rows = await db
        .customSelect(
          "SELECT DISTINCT $col AS v FROM $table WHERE deleted_at IS NULL "
          "AND $col IS NOT NULL AND $col != '' ORDER BY $col",
          readsFrom: {db.teachers, db.staffMembers},
        )
        .get();
    return rows.map((r) => r.read<String>('v')).toList();
  }

  /// **د کسانو راپور** — ډله‌ییز یا انفرادي.
  Future<ReportTable> peopleReport(PeopleReportFilter f) async {
    final title = switch (f.audience) {
      'teacher' => 'د استادانو راپور',
      'staff' => 'د کارمندانو راپور',
      _ => 'د شاګردانو راپور',
    };
    final span = f.from == f.to
        ? _iso(f.from)
        : '${_iso(f.from)} → ${_iso(f.to)}';

    final roster = await people(f);
    if (roster.isEmpty) {
      return ReportTable(
        title: title,
        subtitle: '$span — هېڅ کس ونه موندل شو',
        columns: const [],
        rows: const [],
      );
    }

    return f.scope == ReportScope.individual
        ? _individual(f, roster, title, span)
        : _group(f, roster, title, span);
  }

  /// د هر کس یوه کرښه — د دورې راټولې شمېرې.
  Future<ReportTable> _group(
    PeopleReportFilter f,
    List<ReportPerson> roster,
    String title,
    String span,
  ) async {
    final marks = await _marks(f, [for (final p in roster) p.id]);

    final rows = <List<String>>[];
    var tPresent = 0, tLate = 0, tAbsent = 0, tLeave = 0;
    var flagged = 0;

    for (final p in roster) {
      final m = marks[p.id] ?? const _Tally();
      final marked = m.marked;
      // **سلنه د ثبت شویو ورځو له مخې ده، نه د دورې.** که ښوونځی
      // تړلی و یا حاضري نه وه اخیستل شوې، هغه ورځې د چا په حساب
      // کې نه راځي — که نه، د هر چا حاضري به غلطه ټیټه ښکارېده.
      final pct = marked == 0 ? 0.0 : (m.present + m.late) / marked * 100;
      if (f.belowPercent != null && (marked == 0 || pct >= f.belowPercent!)) {
        continue;
      }
      if (f.belowPercent != null) flagged++;

      tPresent += m.present;
      tLate += m.late;
      tAbsent += m.absent;
      tLeave += m.leave;

      rows.add([
        p.name,
        p.idNo,
        p.group,
        _n(m.present),
        _n(m.late),
        _n(m.absent),
        _n(m.leave),
        marked == 0 ? '—' : _pct(pct),
      ]);
    }

    final totalMarked = tPresent + tLate + tAbsent + tLeave;
    return ReportTable(
      title: title,
      subtitle: '$span  ·  ${f.range.label}  ·  ${f.scope.label}',
      columns: [
        'نوم',
        'نمبر',
        f.audience == 'student' ? 'ټولګی' : 'څانګه',
        'حاضر',
        'ناوخته',
        'غیرحاضر',
        'رخصت',
        'سلنه',
      ],
      rows: rows,
      totals: [
        'ټول (${_n(rows.length)})',
        '',
        '',
        _n(tPresent),
        _n(tLate),
        _n(tAbsent),
        _n(tLeave),
        totalMarked == 0
            ? '—'
            : _pct((tPresent + tLate) / totalMarked * 100),
      ],
      highlights: [
        (label: 'کسان', value: _n(rows.length), warn: false),
        (label: 'حاضر', value: _n(tPresent), warn: false),
        (label: 'غیرحاضر', value: _n(tAbsent), warn: tAbsent > 0),
        (
          label: 'اوسط حاضري',
          value: totalMarked == 0
              ? '—'
              : _pct((tPresent + tLate) / totalMarked * 100),
          warn: totalMarked > 0 && (tPresent + tLate) / totalMarked < 0.85,
        ),
        if (f.belowPercent != null)
          (label: 'ښودل شوي', value: _n(flagged), warn: flagged > 0),
      ],
    );
  }

  /// د یوه کس هره ورځ یوه کرښه.
  Future<ReportTable> _individual(
    PeopleReportFilter f,
    List<ReportPerson> roster,
    String title,
    String span,
  ) async {
    final person = roster.firstWhere(
      (p) => p.id == f.personId,
      orElse: () => roster.first,
    );

    final student = f.audience == 'student';
    final rows = await db
        .customSelect(
          student
              ? 'SELECT date, status, check_in_at FROM attendances '
                    'WHERE student_id = ? AND date >= ? AND date <= ? '
                    'ORDER BY date'
              : 'SELECT date, status, check_in_at FROM staff_attendances '
                    'WHERE person_kind = ? AND person_id = ? '
                    'AND date >= ? AND date <= ? ORDER BY date',
          variables: [
            if (!student) Variable<String>(f.audience),
            Variable<int>(person.id),
            Variable<DateTime>(dateOnly(f.from)),
            Variable<DateTime>(dateOnly(f.to)),
          ],
          readsFrom: {db.attendances, db.staffAttendances},
        )
        .get();

    const names = {
      'present': 'حاضر',
      'late': 'ناوخته',
      'absent': 'غیرحاضر',
      'leave': 'رخصت',
    };
    final counts = <String, int>{};
    final out = <List<String>>[];

    for (final r in rows) {
      final at = DateTime.fromMillisecondsSinceEpoch(
        r.read<int>('date') * 1000,
        isUtc: true,
      ).toLocal();
      final status = r.read<String>('status');
      counts[status] = (counts[status] ?? 0) + 1;

      final inAt = r.data['check_in_at'] as int?;
      out.add([
        _iso(at),
        _weekday(at),
        names[status] ?? status,
        inAt == null
            ? '—'
            : () {
                final t = DateTime.fromMillisecondsSinceEpoch(
                  inAt * 1000,
                ).toLocal();
                return '${t.hour.toString().padLeft(2, '0')}:'
                    '${t.minute.toString().padLeft(2, '0')}';
              }(),
      ]);
    }

    final marked = out.length;
    final ok = (counts['present'] ?? 0) + (counts['late'] ?? 0);

    return ReportTable(
      title: '$title — ${person.name}',
      subtitle: '$span  ·  ${person.idNo}'
          '${person.group.isEmpty ? '' : '  ·  ${person.group}'}',
      columns: const ['نېټه', 'ورځ', 'حالت', 'د راتګ وخت'],
      rows: out,
      totals: [
        'ثبت شوې ورځې',
        _n(marked),
        marked == 0 ? '—' : _pct(ok / marked * 100),
        '',
      ],
      highlights: [
        for (final e in const ['present', 'late', 'absent', 'leave'])
          (
            label: names[e]!,
            value: _n(counts[e] ?? 0),
            warn: e == 'absent' && (counts[e] ?? 0) > 0,
          ),
      ],
    );
  }

  /// د ټولو کسانو د دورې شمېرې — یوه پوښتنه، نه پر هر کس یوه.
  Future<Map<int, _Tally>> _marks(
    PeopleReportFilter f,
    List<int> ids,
  ) async {
    if (ids.isEmpty) return const {};
    final student = f.audience == 'student';
    final holes = ids.map((_) => '?').join(',');

    final rows = await db
        .customSelect(
          student
              ? '''
SELECT student_id AS pid, status, COUNT(*) AS c FROM attendances
WHERE date >= ? AND date <= ? AND student_id IN ($holes)
GROUP BY student_id, status
'''
              : '''
SELECT person_id AS pid, status, COUNT(*) AS c FROM staff_attendances
WHERE person_kind = ? AND date >= ? AND date <= ? AND person_id IN ($holes)
GROUP BY person_id, status
''',
          variables: [
            if (!student) Variable<String>(f.audience),
            Variable<DateTime>(dateOnly(f.from)),
            Variable<DateTime>(dateOnly(f.to)),
            for (final id in ids) Variable<int>(id),
          ],
          readsFrom: {db.attendances, db.staffAttendances},
        )
        .get();

    final out = <int, _Tally>{};
    for (final r in rows) {
      final id = r.read<int>('pid');
      final c = r.read<int>('c');
      final t = out[id] ?? const _Tally();
      out[id] = switch (r.read<String>('status')) {
        'present' => t.copyWith(present: t.present + c),
        'late' => t.copyWith(late: t.late + c),
        'absent' => t.copyWith(absent: t.absent + c),
        'leave' => t.copyWith(leave: t.leave + c),
        _ => t,
      };
    }
    return out;
  }

  static String _weekday(DateTime d) => const {
    1: 'دوشنبه',
    2: 'سه‌شنبه',
    3: 'چهارشنبه',
    4: 'پنجشنبه',
    5: 'جمعه',
    6: 'شنبه',
    7: 'یکشنبه',
  }[d.weekday]!;

}

/// د یوه کس د حالتونو شمېرې — یوه ساده جمع کوونکې.
class _Tally {
  final int present;
  final int late;
  final int absent;
  final int leave;

  const _Tally({
    this.present = 0,
    this.late = 0,
    this.absent = 0,
    this.leave = 0,
  });

  int get marked => present + late + absent + leave;

  _Tally copyWith({int? present, int? late, int? absent, int? leave}) =>
      _Tally(
        present: present ?? this.present,
        late: late ?? this.late,
        absent: absent ?? this.absent,
        leave: leave ?? this.leave,
      );
}
