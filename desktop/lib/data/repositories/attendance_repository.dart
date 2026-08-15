import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../../core/utils/qr_token.dart';
import '../db/database.dart';

/// یوازې نېټه، پرته له وخته.
///
/// **دا ولې مهمه ده؟** د حاضرۍ جدول `(student_id, date)` یوځلي قید
/// لري. که وخت پکې پاتې شي، «۸:۰۳ سهار» او «۸:۰۴ سهار» به دوه بېلې
/// ورځې وګڼل شي او یو شاګرد به څو ځله ثبت شي.
DateTime dateOnly(DateTime t) => DateTime(t.year, t.month, t.day);

/// د ښوونځي هغه قواعد چې د حاضرۍ پرېکړه پرې ولاړه ده.
class AttendanceRules {
  /// «HH:mm» — د درس د پیل وخت.
  final String dayStart;

  /// له پیل څخه څو دقیقې وروسته «ناوخته» ګڼل کېږي.
  final int lateAfterMinutes;

  /// له پیل څخه څو دقیقې وروسته «غیرحاضر» ګڼل کېږي (خو بیا هم ثبتېږي).
  final int absentAfterMinutes;

  const AttendanceRules({
    this.dayStart = '07:30',
    this.lateAfterMinutes = 15,
    this.absentAfterMinutes = 45,
  });

  factory AttendanceRules.fromSchool(School s) => AttendanceRules(
    dayStart: s.dayStart,
    lateAfterMinutes: s.lateAfterMinutes,
    absentAfterMinutes: s.absentAfterMinutes,
  );

  /// د راتګ له وخته حالت ټاکي.
  String statusForArrival(DateTime arrival) {
    final parts = dayStart.split(':');
    final startH = int.tryParse(parts.first) ?? 7;
    final startM = parts.length > 1 ? (int.tryParse(parts[1]) ?? 30) : 30;
    final start = DateTime(
      arrival.year,
      arrival.month,
      arrival.day,
      startH,
      startM,
    );

    final minutesLate = arrival.difference(start).inMinutes;
    if (minutesLate <= lateAfterMinutes) return 'present';
    if (minutesLate <= absentAfterMinutes) return 'late';
    // له دې وروسته راغی — غیرحاضر ګڼل کېږي، خو راتګ يې ثبتېږي چې
    // والدینو ته د «نه دی راغلی» غلط پیغام ونه ځي.
    return 'absent';
  }
}

// ═══════════════════════════════════════════════════════════
//  د سکین پایلې
// ═══════════════════════════════════════════════════════════

sealed class CheckInResult {
  const CheckInResult();
}

/// ثبت شو — `status` يې حاضر یا ناوخته دی.
class CheckInOk extends CheckInResult {
  final Student student;
  final String status;
  final DateTime at;
  const CheckInOk({
    required this.student,
    required this.status,
    required this.at,
  });
}

/// دا شاګرد نن منل‌شوې اجازه لري — «رخصت» دی، نه غیرحاضر.
class CheckInOnLeave extends CheckInResult {
  final Student student;
  final LeaveRequest leave;
  const CheckInOnLeave({required this.student, required this.leave});
}

/// نن مخکې سکین شوی. دویم سکین = د وتلو وخت.
class CheckInCheckedOut extends CheckInResult {
  final Student student;
  final DateTime at;
  const CheckInCheckedOut({required this.student, required this.at});
}

/// درېیم او له هغې وروسته سکینونه — هېڅ نه بدلوي.
class CheckInAlreadyDone extends CheckInResult {
  final Student student;
  final Attendance existing;
  const CheckInAlreadyDone({required this.student, required this.existing});
}

/// QR لاسلیک سم نه دی — جعلي یا خراب کارت.
class CheckInInvalidCard extends CheckInResult {
  const CheckInInvalidCard();
}

/// کارت باطل شوی — شاګرد نوی کارت لري.
class CheckInRevokedCard extends CheckInResult {
  final Student student;
  final int scannedVersion;
  const CheckInRevokedCard({
    required this.student,
    required this.scannedVersion,
  });
}

/// دا نمبر هېڅ شاګرد ته نه ورګرځي.
class CheckInUnknown extends CheckInResult {
  final String input;
  const CheckInUnknown(this.input);
}

/// د یوې ورځې لنډیز.
class DaySummary {
  final int total;
  final int present;
  final int late;
  final int absent;
  final int onLeave;
  final bool locked;

  const DaySummary({
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.onLeave,
    required this.locked,
  });

  int get marked => present + late + absent + onLeave;
  int get unmarked => total - marked;
  double get presentPercent =>
      total == 0 ? 0 : ((present + late) / total) * 100;
}

/// د یوې کرښې د حاضرۍ حالت — د ټولګي لیست لپاره.
class RosterEntry {
  final Student student;
  final int? rollNo;
  final String? status;
  final DateTime? checkInAt;
  final bool hasApprovedLeave;

  const RosterEntry({
    required this.student,
    this.rollNo,
    this.status,
    this.checkInAt,
    this.hasApprovedLeave = false,
  });
}

// ═══════════════════════════════════════════════════════════
//  ماشین
// ═══════════════════════════════════════════════════════════

class AttendanceRepository {
  final AppDatabase db;
  AttendanceRepository(this.db);

  Future<AttendanceRules> rules() async {
    final school = await db.select(db.schools).getSingleOrNull();
    return school == null
        ? const AttendanceRules()
        : AttendanceRules.fromSchool(school);
  }

  /// یوازې پیدا کوي — **هېڅ نه ثبتوي**.
  ///
  /// **دا ولې پکار ده؟** د شالید سکینر باید مخکې له ثبتولو وپوهېږي
  /// چې دا شاګرد د کومې ژوندۍ ناستې هدف دی. که مستقیم `checkIn`
  /// وهل کېده، لومړۍ ناسته به يې نیوله — او د لیلیه شاګرد به د
  /// نهاریانو په ناسته کې ثبت شوی و.
  ///
  /// لاسلیک دلته نه کتل کېږي؛ هغه د `checkIn` کار دی.
  Future<Student?> findByInput(String input) async {
    final text = input.trim();
    if (text.isEmpty) return null;

    if (QrToken.looksLikeToken(text)) {
      final byNo = _admissionNoFromToken(text);
      return byNo == null ? null : _findByAdmissionNo(byNo);
    }
    return _findByAdmissionNo(Numerals.toLatin(text));
  }

  /// د سکین یا لاسي آی‌ډي د ثبتولو اصلي لار.
  ///
  /// دواړه یوې خانې ته ځي: که متن د کارت بڼه ولري، لاسلیک پرې کتل
  /// کېږي؛ که نه، د داخلې نمبر ګڼل کېږي. نو د دروازې کارکوونکی د
  /// حالت بدلولو ته اړ نه دی.
  Future<CheckInResult> checkIn({
    required String input,
    required DateTime now,
    required int byUserId,
    AttendanceRules? withRules,
    int sessionId = 0,
    String method = 'qr',
  }) async {
    final text = input.trim();
    if (text.isEmpty) return CheckInUnknown(text);

    Student? student;
    int? scannedVersion;

    if (QrToken.looksLikeToken(text)) {
      // د کارت بڼه ده — باید لاسلیک سم وي.
      final byNo = _admissionNoFromToken(text);
      if (byNo == null) return const CheckInInvalidCard();

      student = await _findByAdmissionNo(byNo);
      if (student == null) return CheckInUnknown(byNo);

      final secret = student.qrSecret;
      if (secret == null) return const CheckInInvalidCard();

      final scan = QrToken.decode(text, secret);
      if (scan == null) return const CheckInInvalidCard();

      // د کارت نسخه باید له اوسنۍ سره برابره وي — که نه، دا یو
      // ورک شوی کارت دی چې باطل شوی.
      if (scan.cardVersion != student.cardVersion) {
        return CheckInRevokedCard(
          student: student,
          scannedVersion: scan.cardVersion,
        );
      }
    } else {
      // لاسي آی‌ډي — کارن يې ښايي په ختیځو شمېرو ولیکي.
      student = await _findByAdmissionNo(Numerals.toLatin(text));
      if (student == null) return CheckInUnknown(text);
    }

    return _record(
      student: student,
      now: now,
      byUserId: byUserId,
      rules: withRules ?? await rules(),
      scannedVersion: scannedVersion,
      sessionId: sessionId,
      method: method,
    );
  }

  Future<CheckInResult> _record({
    required Student student,
    required DateTime now,
    required int byUserId,
    required AttendanceRules rules,
    int? scannedVersion,
    int sessionId = 0,
    String method = 'qr',
  }) async {
    final day = dateOnly(now);

    final existing =
        await (db.select(db.attendances)
              ..where((a) => a.studentId.equals(student.id))
              ..where((a) => a.date.equals(day))
              ..where((a) => a.sessionId.equals(sessionId))
              ..limit(1))
            .getSingleOrNull();

    // ── تر ټولو مهم ګام: د اجازې کتنه ─────────────────────
    // مخکې له دې چې څه ثبت شي، ګورو چې نن منل‌شوې اجازه لري که نه.
    // که ولري، «رخصت» ثبتېږي — نه غیرحاضر، نو والدینو ته به بې‌ځایه
    // پیغام ونه ځي.
    final leave = await approvedLeaveOn(student.id, day);
    if (leave != null) {
      if (existing == null) {
        await db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: student.id,
                date: day,
                status: 'leave',
                method: const Value('auto'),
                sessionId: Value(sessionId),
                leaveRequestId: Value(leave.id),
                recordedByUserId: Value(byUserId),
              ),
            );
      }
      return CheckInOnLeave(student: student, leave: leave);
    }

    if (existing == null) {
      final status = rules.statusForArrival(now);
      await db
          .into(db.attendances)
          .insert(
            AttendancesCompanion.insert(
              studentId: student.id,
              date: day,
              status: status,
              method: Value(method),
              sessionId: Value(sessionId),
              checkInAt: Value(now),
              recordedByUserId: Value(byUserId),
            ),
          );
      return CheckInOk(student: student, status: status, at: now);
    }

    // دویم سکین = وتل.
    if (existing.checkOutAt == null && existing.checkInAt != null) {
      await (db.update(db.attendances)..where((a) => a.id.equals(existing.id)))
          .write(AttendancesCompanion(checkOutAt: Value(now)));
      return CheckInCheckedOut(student: student, at: now);
    }

    // درېیم او وروسته — هېڅ نه بدلوو. د دروازې پر مخ تېروتنې سره
    // دوه ځله سکین عادي دی؛ نه غواړو چې د وتلو وخت پرې خراب شي.
    return CheckInAlreadyDone(student: student, existing: existing);
  }

  String? _admissionNoFromToken(String token) {
    final parts = token.split('.');
    return parts.length == 4 ? parts[1] : null;
  }

  Future<Student?> _findByAdmissionNo(String no) {
    return (db.select(db.students)
          ..where((s) => s.admissionNo.equals(no))
          ..where((s) => s.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
  }

  /// ایا دې شاګرد ته پر دې ورځ منل‌شوې اجازه شته؟
  Future<LeaveRequest?> approvedLeaveOn(int studentId, DateTime day) {
    final d = dateOnly(day);
    return (db.select(db.leaveRequests)
          ..where((l) => l.studentId.equals(studentId))
          ..where((l) => l.status.equals('approved'))
          ..where((l) => l.fromDate.isSmallerOrEqualValue(d))
          ..where((l) => l.toDate.isBiggerOrEqualValue(d))
          ..limit(1))
        .getSingleOrNull();
  }

  /// د یوه بخش د ورځې لیست — د لاسي نښه کولو لپاره.
  Future<List<RosterEntry>> roster({
    required int sectionId,
    required DateTime date,
    int sessionId = 0,
  }) async {
    final day = dateOnly(date);

    final rows = await db
        .customSelect(
          '''
SELECT s.*,
  e.roll_no        AS roll_no,
  a.status         AS att_status,
  a.check_in_at    AS att_in,
  (SELECT COUNT(*) FROM leave_requests l
     WHERE l.student_id = s.id AND l.status = 'approved'
       AND l.from_date <= ? AND l.to_date >= ?) AS leave_count
FROM enrollments e
JOIN students s ON s.id = e.student_id AND s.deleted_at IS NULL
LEFT JOIN attendances a ON a.student_id = s.id AND a.date = ?
                       AND a.session_id = ?
WHERE e.section_id = ? AND e.is_active = 1
ORDER BY e.roll_no, s.first_name
''',
          variables: [
            Variable<DateTime>(day),
            Variable<DateTime>(day),
            Variable<DateTime>(day),
            Variable<int>(sessionId),
            Variable<int>(sectionId),
          ],
          readsFrom: {
            db.enrollments,
            db.students,
            db.attendances,
            db.leaveRequests,
          },
        )
        .get();

    return rows
        .map(
          (r) => RosterEntry(
            student: db.students.map(r.data),
            rollNo: r.data['roll_no'] as int?,
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

  /// د ټولګي لیست له مخې ډله‌ییز ثبت.
  ///
  /// د اجازې کتنه دلته هم کېږي — که استاد یو شاګرد «غیرحاضر» نښه
  /// کړي خو اجازه ولري، «رخصت» ثبتېږي. استاد ښايي د اجازې نه وي
  /// خبر؛ سیسټم دی چې پوهېږي.
  Future<int> markRoster({
    int? sectionId,
    required DateTime date,
    required Map<int, String> statusByStudentId,
    required int byUserId,
    int sessionId = 0,
    String method = 'roster',

    /// کله چې مدیر په لاس «رخصت» نښه کړي، هغه باید د اجازت‌نامو په
    /// ډیټابیس کې هم ولیکل شي. که نه وای، د میاشتې د اجازو رپوټ به
    /// له حاضرۍ سره ټکر خوړ — یو ځای «رخصت»، بل ځای هېڅ.
    bool recordLeave = false,
    DateTime? now,
  }) async {
    final day = dateOnly(date);
    final stamp = now ?? DateTime.now();
    var written = 0;

    await db.transaction(() async {
      for (final entry in statusByStudentId.entries) {
        var leave = await approvedLeaveOn(entry.key, day);
        final wanted = entry.value;

        // د منل‌شوې اجازې لومړیتوب — پرته له یوې استثنا: که مدیر
        // په څرګنده بل حالت وټاکي، د هغه پرېکړه منل کېږي، ځکه چې
        // ښايي شاګرد د اجازې سره سره راغلی وي.
        final status = (leave != null && wanted == 'absent') ? 'leave' : wanted;

        if (status == 'leave' && leave == null && recordLeave) {
          final leaveId = await db
              .into(db.leaveRequests)
              .insert(
                LeaveRequestsCompanion.insert(
                  studentId: entry.key,
                  reasonType: 'other',
                  reasonText: const Value('له حاضرۍ څخه په لاس نښه شوې'),
                  fromDate: day,
                  toDate: day,
                  status: const Value('approved'),
                  requestedVia: const Value('reception'),
                  requestedByUserId: Value(byUserId),
                  decidedByUserId: Value(byUserId),
                  decidedAt: Value(stamp),
                  createdAt: Value(stamp),
                ),
              );
          leave = await (db.select(
            db.leaveRequests,
          )..where((l) => l.id.equals(leaveId))).getSingle();
        }

        await db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: entry.key,
                date: day,
                status: status,
                sectionId: Value(sectionId),
                sessionId: Value(sessionId),
                method: Value(method),
                leaveRequestId: Value(status == 'leave' ? leave?.id : null),
                recordedByUserId: Value(byUserId),
              ),
              // **`target` دلته اړین دی.** `insertOnConflictUpdate`
              // پر لومړني کلي (`id`) ټکر ګوري، نه پر زموږ یوځلي
              // کلي. پرته له دې، کله چې استاد یوه تېروتنه سموي،
              // دویم ثبت د UNIQUE قید سره مات شي.
              onConflict: DoUpdate(
                (_) => AttendancesCompanion(
                  status: Value(status),
                  sectionId: Value(sectionId),
                  method: Value(method),
                  leaveRequestId: Value(status == 'leave' ? leave?.id : null),
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
        written++;
      }
    });

    return written;
  }

  /// د ورځې بندول — هغه چې نه دي ثبت شوي، غیرحاضر ګڼل کېږي.
  ///
  /// د غیرحاضرو شمېر راګرځوي — هماغه چې د مدیر اپ ته خبرتیا کې ځي.
  Future<int> lockDay({
    required DateTime date,
    required int byUserId,
    int sessionId = 0,
  }) async {
    final day = dateOnly(date);
    var marked = 0;

    await db.transaction(() async {
      // هغه فعال شاګردان چې نن هېڅ ریکارډ نه لري.
      final missing = await db
          .customSelect(
            '''
SELECT s.id AS id, e.section_id AS section_id
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
WHERE s.deleted_at IS NULL AND s.status = 'active'
  AND NOT EXISTS (
    SELECT 1 FROM attendances a WHERE a.student_id = s.id AND a.date = ?
      AND a.session_id = ?
  )
''',
            variables: [Variable<DateTime>(day), Variable<int>(sessionId)],
            readsFrom: {db.students, db.enrollments, db.attendances},
          )
          .get();

      for (final row in missing) {
        final id = row.read<int>('id');
        final leave = await approvedLeaveOn(id, day);

        await db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: id,
                date: day,
                status: leave != null ? 'leave' : 'absent',
                sectionId: Value(row.data['section_id'] as int?),
                sessionId: Value(sessionId),
                method: const Value('auto'),
                leaveRequestId: Value(leave?.id),
                recordedByUserId: Value(byUserId),
              ),
            );
        if (leave == null) marked++;
      }

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'update',
              entity: 'attendance_lock',
              userId: Value(byUserId),
              changesJson: Value('{"date":"${day.toIso8601String()}"}'),
            ),
          );
    });

    return marked;
  }

  /// د یوې ورځې لنډیز.
  Future<DaySummary> summary(DateTime date, {int sessionId = 0}) async {
    final day = dateOnly(date);

    final totalRow = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM students "
          "WHERE deleted_at IS NULL AND status = 'active'",
          readsFrom: {db.students},
        )
        .getSingle();

    final rows = await db
        .customSelect(
          'SELECT status, COUNT(*) AS c FROM attendances '
          'WHERE date = ? AND session_id = ? GROUP BY status',
          variables: [Variable<DateTime>(day), Variable<int>(sessionId)],
          readsFrom: {db.attendances},
        )
        .get();

    final byStatus = {
      for (final r in rows) r.read<String>('status'): r.read<int>('c'),
    };

    return DaySummary(
      total: totalRow.read<int>('c'),
      present: byStatus['present'] ?? 0,
      late: byStatus['late'] ?? 0,
      absent: byStatus['absent'] ?? 0,
      onLeave: byStatus['leave'] ?? 0,
      locked: false,
    );
  }

  /// د یوې ورځې غیرحاضران — د خبرتیا لپاره.
  ///
  /// یوازې هغه چې لا يې والدینو ته پیغام نه دی تللی، که
  /// `onlyUnnotified` سم وي — چې دوه ځله پیغام ونه ځي.
  Future<List<({Student student, String? className, int monthlyAbsences})>>
  absentees(DateTime date, {bool onlyUnnotified = false}) async {
    final day = dateOnly(date);
    final monthStart = DateTime(day.year, day.month, 1);

    final rows = await db
        .customSelect(
          '''
SELECT s.*,
  g.name || ' — ' || sec.name AS class_name,
  (SELECT COUNT(*) FROM attendances m
     WHERE m.student_id = s.id AND m.status = 'absent'
       AND m.date >= ? AND m.date <= ?) AS monthly_absences
FROM attendances a
JOIN students s ON s.id = a.student_id
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
WHERE a.date = ? AND a.status = 'absent'
  ${onlyUnnotified ? 'AND a.parent_notified = 0' : ''}
ORDER BY monthly_absences DESC, s.first_name
''',
          variables: [
            Variable<DateTime>(monthStart),
            Variable<DateTime>(day),
            Variable<DateTime>(day),
          ],
          readsFrom: {
            db.attendances,
            db.students,
            db.enrollments,
            db.sections,
            db.grades,
          },
        )
        .get();

    return rows
        .map(
          (r) => (
            student: db.students.map(r.data),
            className: r.data['class_name'] as String?,
            monthlyAbsences: r.data['monthly_absences'] as int? ?? 0,
          ),
        )
        .toList();
  }

  /// د پیغام له لېږلو وروسته نښه کول — چې دوه ځله ونه لېږل شي.
  Future<int> markNotified({
    required DateTime date,
    required List<int> studentIds,
  }) async {
    if (studentIds.isEmpty) return 0;
    final day = dateOnly(date);
    final placeholders = List.filled(studentIds.length, '?').join(',');

    return db.customUpdate(
      'UPDATE attendances SET parent_notified = 1, parent_notified_at = ? '
      'WHERE date = ? AND student_id IN ($placeholders)',
      variables: [
        Variable<DateTime>(DateTime.now()),
        Variable<DateTime>(day),
        ...studentIds.map(Variable<int>.new),
      ],
      updates: {db.attendances},
    );
  }

  /// د یوه شاګرد میاشتنۍ حاضري — د والدینو د اپ او رپوټ لپاره.
  Future<Map<String, int>> monthlyBreakdown({
    required int studentId,
    required DateTime month,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final rows = await db
        .customSelect(
          'SELECT status, COUNT(*) AS c FROM attendances '
          'WHERE student_id = ? AND date >= ? AND date <= ? GROUP BY status',
          variables: [
            Variable<int>(studentId),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
          ],
          readsFrom: {db.attendances},
        )
        .get();

    return {for (final r in rows) r.read<String>('status'): r.read<int>('c')};
  }
}
