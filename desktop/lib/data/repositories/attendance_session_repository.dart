import 'package:drift/drift.dart';

import '../db/database.dart';
import 'attendance_repository.dart';

/// یوه ناسته له خپل ژوندي حال سره — څو کسان يې هدف دي او څو ثبت شوي.
class SessionStatus {
  final AttendanceSession session;
  final int targetCount;
  final int markedCount;
  final int presentCount;

  /// اوس د دې ناستې د اخیستلو وخت دی؟
  final bool isLive;

  const SessionStatus({
    required this.session,
    required this.targetCount,
    required this.markedCount,
    required this.presentCount,
    required this.isLive,
  });

  int get pending => targetCount - markedCount;
  double get progress => targetCount == 0 ? 0 : markedCount / targetCount;
}

/// **د یوې ناستې هغه شمېره چې حاضري پرې ثبتېږي.**
///
/// دا تل د کرښې `id` نه دی. تلواله ناسته («د ورځې حاضري») د صفر
/// شمېره کاروي، ځکه چې:
///
///  1. د زوړ ډیټابیس هغه حاضري چې د ناستو له راتګ مخکې ثبت شوې،
///     صفر لري — او هغه واقعاً د ورځې عمومي حاضري ده؛
///  2. سکینر کله چې ځانګړې ناسته نه وي ټاکل شوې، صفر لیکي.
///
/// که دا نه وای، تلواله ناستې به تل «۰ له ۸۵۰ ثبت شوي» ښودل —
/// ټول ریکارډونه به يې د بلې شمېرې لاندې پراته وو.
extension AttendanceSessionStorage on AttendanceSession {
  int get storageId =>
      isDefault ? AttendanceSessionRepository.generalSessionId : id;
}

/// د یوې ناستې د لیست یوه کرښه — شاګرد، ټولګی او اوسنی حالت.
class SessionRosterEntry {
  final Student student;
  final String? className;
  final int? gradeId;
  final String? status;
  final DateTime? checkInAt;
  final bool hasApprovedLeave;

  const SessionRosterEntry({
    required this.student,
    this.className,
    this.gradeId,
    this.status,
    this.checkInAt,
    this.hasApprovedLeave = false,
  });
}

/// د لیست فلټر — چې مدیر ژر خپل هدف ته ورسېږي.
class RosterFilter {
  final String query;
  final int? gradeId;
  final String? residency;

  /// `present` | `late` | `absent` | `leave` | `unmarked`
  final String? status;

  const RosterFilter({
    this.query = '',
    this.gradeId,
    this.residency,
    this.status,
  });

  RosterFilter copyWith({
    String? query,
    int? gradeId,
    String? residency,
    String? status,
    bool clearGrade = false,
    bool clearResidency = false,
    bool clearStatus = false,
  }) => RosterFilter(
    query: query ?? this.query,
    gradeId: clearGrade ? null : (gradeId ?? this.gradeId),
    residency: clearResidency ? null : (residency ?? this.residency),
    status: clearStatus ? null : (status ?? this.status),
  );

  bool get isEmpty =>
      query.isEmpty && gradeId == null && residency == null && status == null;
}

/// د حاضرۍ د ناستو ذخیره.
///
/// **دا ولې جلا ذخیره ده؟** ځکه چې «ناسته» له «حاضرۍ» بېل مفهوم دی.
/// حاضري یوه پېښه ده — «احمد نن حاضر و». ناسته یو قاعده ده —
/// «د لیلیه شاګردانو حاضري هره شپه ۸:۰۰ اخیستل کېږي». که دواړه یوه
/// ذخیره وای، د قاعدې بدلول به د پېښو د لوستلو کوډ ته لار موندله.
class AttendanceSessionRepository {
  final AppDatabase db;
  AttendanceSessionRepository(this.db);

  /// **د ورځې عمومي حاضري د صفر شمېره لري.** هغه یوه ریښتینې کرښه
  /// نه ده، بلکې د «هېڅ ناسته نه ده ټاکل شوې» معنا لري — نو زوړ
  /// ډیټا او نوی ډیټا دواړه یو شان کار کوي.
  static const int generalSessionId = 0;

  Future<List<AttendanceSession>> list({bool includeInactive = true}) {
    final q = db.select(db.attendanceSessions)
      ..where((s) => s.deletedAt.isNull())
      ..orderBy([
        (s) => OrderingTerm.desc(s.isDefault),
        (s) => OrderingTerm.asc(s.startTime),
        (s) => OrderingTerm.asc(s.id),
      ]);
    if (!includeInactive) q.where((s) => s.isActive.equals(true));
    return q.get();
  }

  Future<AttendanceSession?> byId(int id) => (db.select(
    db.attendanceSessions,
  )..where((s) => s.id.equals(id))).getSingleOrNull();

  /// د لومړي ران تلواله ناسته — «د ورځې حاضري».
  Future<void> seedDefault({String name = 'د ورځې حاضري'}) async {
    final any = await (db.select(
      db.attendanceSessions,
    )..limit(1)).getSingleOrNull();
    if (any != null) return;

    final school = await db.select(db.schools).getSingleOrNull();
    await db
        .into(db.attendanceSessions)
        .insert(
          AttendanceSessionsCompanion.insert(
            name: name,
            target: const Value('all'),
            startTime: Value(school?.dayStart ?? '07:00'),
            endTime: Value(school?.dayEnd ?? '08:30'),
            days: Value(_teachingDays(school?.weekendDays ?? '4,5')),
            isDefault: const Value(true),
          ),
        );
  }

  /// د اونۍ هغه ورځې چې رخصتي نه دي.
  static String _teachingDays(String weekend) {
    final off = weekend
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
    return [
      for (var d = 1; d <= 7; d++)
        if (!off.contains(d)) d,
    ].join(',');
  }

  Future<int> create({
    required String name,
    String target = 'all',
    int? sectionId,
    int? gradeId,
    String startTime = '07:00',
    String endTime = '08:30',
    String? days,
    int? lateAfterMinutes,
    int? absentAfterMinutes,
  }) async {
    final school = await db.select(db.schools).getSingleOrNull();
    return db
        .into(db.attendanceSessions)
        .insert(
          AttendanceSessionsCompanion.insert(
            name: name,
            target: Value(target),
            sectionId: Value(target == 'section' ? sectionId : null),
            gradeId: Value(target == 'grade' ? gradeId : null),
            startTime: Value(startTime),
            endTime: Value(endTime),
            days: Value(days ?? _teachingDays(school?.weekendDays ?? '4,5')),
            lateAfterMinutes: Value(lateAfterMinutes),
            absentAfterMinutes: Value(absentAfterMinutes),
          ),
        );
  }

  Future<void> update({
    required int id,
    String? name,
    String? target,
    int? sectionId,
    int? gradeId,
    String? startTime,
    String? endTime,
    String? days,
    int? lateAfterMinutes,
    int? absentAfterMinutes,
    bool? isActive,
  }) {
    return (db.update(db.attendanceSessions)..where((s) => s.id.equals(id)))
        .write(
          AttendanceSessionsCompanion(
            name: name == null ? const Value.absent() : Value(name),
            target: target == null ? const Value.absent() : Value(target),
            // د هدف په بدلولو سره، د پخواني هدف نښه پاکېږي — که نه،
            // یوه ناسته چې «ټول» شوې وي به لا هم زوړ بخش یاد ساته.
            sectionId: target == null
                ? const Value.absent()
                : Value(target == 'section' ? sectionId : null),
            gradeId: target == null
                ? const Value.absent()
                : Value(target == 'grade' ? gradeId : null),
            startTime: startTime == null
                ? const Value.absent()
                : Value(startTime),
            endTime: endTime == null ? const Value.absent() : Value(endTime),
            days: days == null ? const Value.absent() : Value(days),
            lateAfterMinutes: Value(lateAfterMinutes),
            absentAfterMinutes: Value(absentAfterMinutes),
            isActive: isActive == null ? const Value.absent() : Value(isActive),
          ),
        );
  }

  /// ړنګول = پټول. د تېرو ورځو حاضري د دې ناستې پورې تړلې ده، نو
  /// کرښه پاتې کېږي — که نه، رپوټ به بې‌نومه ناستې ښودلې.
  Future<void> remove(int id, {DateTime? at}) =>
      (db.update(db.attendanceSessions)..where((s) => s.id.equals(id))).write(
        AttendanceSessionsCompanion(deletedAt: Value(at ?? DateTime.now())),
      );

  // ── وخت ─────────────────────────────────────────────────

  static int _minutes(String hhmm) {
    final p = hhmm.split(':');
    return (int.tryParse(p.first) ?? 0) * 60 +
        (p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0);
  }

  /// ایا په دې شېبه کې د دې ناستې د اخیستلو وخت دی؟
  static bool isLiveAt(AttendanceSession s, DateTime now) {
    if (!s.isActive) return false;

    final days = s.days
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
    if (days.isNotEmpty && !days.contains(now.weekday)) return false;

    final start = _minutes(s.startTime);
    final end = _minutes(s.endTime);
    final at = now.hour * 60 + now.minute;

    // **د نیمې شپې تېرېدونکې کړکۍ.** د لیلیه د شپې حاضري ښايي
    // ۲۲:۳۰ پیل او ۰۰:۳۰ پای ته ورسېږي. که ساده پرتله کړو، دا
    // کړکۍ به هېڅکله ژوندۍ نه شوه.
    return end >= start ? (at >= start && at <= end) : (at >= start || at <= end);
  }

  /// هغه ناستې چې اوس ژوندۍ دي — د ډاشبورډ د «Live» نښې لپاره.
  Future<List<AttendanceSession>> liveAt(DateTime now) async {
    final all = await list(includeInactive: false);
    return all.where((s) => isLiveAt(s, now)).toList();
  }

  // ── هدف ─────────────────────────────────────────────────

  /// د یوې ناستې د هدف SQL شرط — پر `students s` باندې پلی کېږي.
  static ({String where, List<Variable> vars}) targetClause(
    AttendanceSession? s,
  ) {
    if (s == null || s.target == 'all') {
      return (where: '1 = 1', vars: const []);
    }
    switch (s.target) {
      case 'day':
        return (where: "s.residency = 'day'", vars: const []);
      case 'boarding':
        return (where: "s.residency = 'boarding'", vars: const []);
      case 'section':
        return (
          where: 'e.section_id = ?',
          vars: [Variable<int>(s.sectionId ?? -1)],
        );
      case 'grade':
        return (
          where: 'sec.grade_id = ?',
          vars: [Variable<int>(s.gradeId ?? -1)],
        );
      default:
        return (where: '1 = 1', vars: const []);
    }
  }

  /// د یوې ناستې لیست — هدف شاګردان له خپل نننۍ حالت سره.
  Future<List<SessionRosterEntry>> roster({
    AttendanceSession? session,
    required DateTime date,
    RosterFilter filter = const RosterFilter(),
  }) async {
    final day = dateOnly(date);
    final sid = session?.storageId ?? generalSessionId;
    final target = targetClause(session);

    final where = <String>[
      's.deleted_at IS NULL',
      "s.status = 'active'",
      target.where,
    ];
    final vars = <Variable>[
      Variable<DateTime>(day),
      Variable<DateTime>(day),
      Variable<DateTime>(day),
      Variable<int>(sid),
      ...target.vars,
    ];

    if (filter.gradeId != null) {
      where.add('sec.grade_id = ?');
      vars.add(Variable<int>(filter.gradeId!));
    }
    if (filter.residency != null) {
      where.add('s.residency = ?');
      vars.add(Variable<String>(filter.residency!));
    }
    if (filter.query.trim().isNotEmpty) {
      where.add(
        '(s.first_name LIKE ? OR s.last_name LIKE ? '
        'OR s.father_name LIKE ? OR s.admission_no LIKE ?)',
      );
      final like = '%${filter.query.trim()}%';
      vars.addAll(List.filled(4, Variable<String>(like)));
    }

    // د حالت فلټر د `LEFT JOIN` له پایلې وروسته پلی کېږي، نو
    // `HAVING` نه بلکې د بهرنۍ پوښتنې شرط دی — «نه‌نښه‌شوی» یعنې
    // هېڅ کرښه نه ده موندل شوې.
    var statusHaving = '';
    if (filter.status == 'unmarked') {
      statusHaving = 'HAVING att_status IS NULL';
    } else if (filter.status != null) {
      statusHaving = 'HAVING att_status = ?';
      vars.add(Variable<String>(filter.status!));
    }

    final rows = await db
        .customSelect(
          '''
SELECT s.*,
  g.name || ' — ' || sec.name AS class_name,
  sec.grade_id                AS grade_id,
  a.status                    AS att_status,
  a.check_in_at               AS att_in,
  (SELECT COUNT(*) FROM leave_requests l
     WHERE l.student_id = s.id AND l.status = 'approved'
       AND l.from_date <= ? AND l.to_date >= ?) AS leave_count
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
LEFT JOIN attendances a ON a.student_id = s.id AND a.date = ?
                       AND a.session_id = ?
WHERE ${where.join(' AND ')}
GROUP BY s.id
$statusHaving
ORDER BY g.sort_order, sec.name, e.roll_no, s.first_name
''',
          variables: vars,
          readsFrom: {
            db.students,
            db.enrollments,
            db.sections,
            db.grades,
            db.attendances,
            db.leaveRequests,
          },
        )
        .get();

    return rows
        .map(
          (r) => SessionRosterEntry(
            student: db.students.map(r.data),
            className: r.data['class_name'] as String?,
            gradeId: r.data['grade_id'] as int?,
            status: r.data['att_status'] as String?,
            checkInAt: r.data['att_in'] == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    (r.data['att_in'] as int) * 1000,
                  ),
            hasApprovedLeave: (r.data['leave_count'] as int? ?? 0) > 0,
          ),
        )
        .toList();
  }

  /// د یوې ناستې لنډیز — د لیست پاڼې د کارتونو لپاره.
  Future<SessionStatus> status({
    AttendanceSession? session,
    required DateTime now,
  }) async {
    final day = dateOnly(now);
    final sid = session?.storageId ?? generalSessionId;
    final target = targetClause(session);

    final row = await db
        .customSelect(
          '''
SELECT
  COUNT(*) AS target_count,
  SUM(CASE WHEN a.status IS NOT NULL THEN 1 ELSE 0 END) AS marked,
  SUM(CASE WHEN a.status IN ('present','late') THEN 1 ELSE 0 END) AS present
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN attendances a ON a.student_id = s.id AND a.date = ?
                       AND a.session_id = ?
WHERE s.deleted_at IS NULL AND s.status = 'active' AND ${target.where}
''',
          variables: [
            Variable<DateTime>(day),
            Variable<int>(sid),
            ...target.vars,
          ],
          readsFrom: {
            db.students,
            db.enrollments,
            db.sections,
            db.attendances,
          },
        )
        .getSingle();

    return SessionStatus(
      session:
          session ??
          AttendanceSession(
            id: generalSessionId,
            name: 'د ورځې حاضري',
            target: 'all',
            startTime: '07:00',
            endTime: '08:30',
            days: '1,2,3,4,5,6,7',
            isActive: true,
            isDefault: true,
            createdAt: day,
          ),
      targetCount: row.read<int>('target_count'),
      markedCount: row.data['marked'] as int? ?? 0,
      presentCount: row.data['present'] as int? ?? 0,
      isLive: session == null ? true : isLiveAt(session, now),
    );
  }

  /// ایا دا شاګرد د دې ناستې هدف دی؟
  ///
  /// **دا د سکینر لپاره ده.** که د لیلیه د شپې حاضرۍ پر مهال یو
  /// نهاري شاګرد کارت ووهي، باید تېروتنه ورته وښودل شي — نه دا چې
  /// بې‌ځایه ثبت شي.
  Future<bool> isTargeted({
    required AttendanceSession? session,
    required int studentId,
  }) async {
    if (session == null || session.target == 'all') return true;
    final target = targetClause(session);

    final row = await db
        .customSelect(
          '''
SELECT COUNT(*) AS c
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
WHERE s.id = ? AND ${target.where}
''',
          variables: [Variable<int>(studentId), ...target.vars],
          readsFrom: {db.students, db.enrollments, db.sections},
        )
        .getSingle();
    return row.read<int>('c') > 0;
  }
}
