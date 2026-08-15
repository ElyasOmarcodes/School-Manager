import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../db/database.dart';
import 'attendance_repository.dart' show AttendanceRules, dateOnly;

/// **د ښوونځي یو کس چې شاګرد نه دی** — استاد یا کارمند.
///
/// **ولې یو ګډ ټولګی؟** ځکه چې د حاضرۍ له نظره دواړه یو شان دي:
/// یو نوم، یو کارمند نمبر، یوه ګوته. که دوه بېل کوډ لیکل کېده، هر
/// بدلون به دوه ځایه ته اړ و — او یو ځای به تل هېر شو.
class Personnel {
  /// `teacher` | `staff`
  final String kind;
  final int id;
  final String employeeNo;
  final String fullName;
  final String? jobTitle;
  final String? phone;
  final String? photoPath;
  final String? fingerprintId;
  final String? qrSecret;
  final int cardVersion;
  final String status;

  const Personnel({
    required this.kind,
    required this.id,
    required this.employeeNo,
    required this.fullName,
    required this.cardVersion,
    required this.status,
    this.jobTitle,
    this.phone,
    this.photoPath,
    this.fingerprintId,
    this.qrSecret,
  });

  bool get isTeacher => kind == 'teacher';
}

/// د یوه کس د ورځې حال.
class PersonnelRosterEntry {
  final Personnel person;
  final String? status;
  final DateTime? checkInAt;

  const PersonnelRosterEntry({
    required this.person,
    this.status,
    this.checkInAt,
  });
}

/// د استادانو او کارمندانو حاضري.
///
/// **د شاګردانو له حاضرۍ ولې جلا؟** ځکه چې د شاګرد حاضري د ټولګي،
/// د اجازت‌نامې، د والدینو د خبرتیا او د کارنامې پورې تړلې ده — د
/// استاد حاضري له دې هېڅ یوه سره نه ده. یو ګډ جدول به هره پوښتنه
/// `WHERE person_kind = ...` ته اړ کړې وه، او یوه هېره شوې به د
/// رپوټونو شمېرې خرابې کړې.
class StaffAttendanceRepository {
  final AppDatabase db;
  StaffAttendanceRepository(this.db);

  /// ټول استادان او کارمندان — یو لیست.
  Future<List<Personnel>> personnel({
    String? kind,
    String query = '',
    bool activeOnly = true,
  }) async {
    final where = <String>['deleted_at IS NULL'];
    if (activeOnly) where.add("status = 'active'");

    final args = <Variable<Object>>[];
    var like = '';
    final q = query.trim();
    if (q.isNotEmpty) {
      like = '%${Numerals.toLatin(q)}%';
      where.add('(full_name LIKE ? OR employee_no LIKE ?)');
    }

    final rows = <Personnel>[];

    if (kind == null || kind == 'teacher') {
      final r = await db
          .customSelect(
            '''
SELECT id, employee_no, full_name, specialization AS job_title, phone,
       photo_path, fingerprint_id, qr_secret, card_version, status
FROM teachers WHERE ${where.join(' AND ')}
ORDER BY full_name
''',
            variables: q.isEmpty
                ? args
                : [Variable<String>(like), Variable<String>(like)],
            readsFrom: {db.teachers},
          )
          .get();
      rows.addAll(r.map((x) => _map(x, 'teacher')));
    }

    if (kind == null || kind == 'staff') {
      final r = await db
          .customSelect(
            '''
SELECT id, employee_no, full_name, job_title, phone,
       photo_path, fingerprint_id, qr_secret, card_version, status
FROM staff_members WHERE ${where.join(' AND ')}
ORDER BY full_name
''',
            variables: q.isEmpty
                ? args
                : [Variable<String>(like), Variable<String>(like)],
            readsFrom: {db.staffMembers},
          )
          .get();
      rows.addAll(r.map((x) => _map(x, 'staff')));
    }

    return rows;
  }

  static Personnel _map(QueryRow r, String kind) => Personnel(
    kind: kind,
    id: r.read<int>('id'),
    employeeNo: r.read<String>('employee_no'),
    fullName: r.read<String>('full_name'),
    jobTitle: r.data['job_title'] as String?,
    phone: r.data['phone'] as String?,
    photoPath: r.data['photo_path'] as String?,
    fingerprintId: r.data['fingerprint_id'] as String?,
    qrSecret: r.data['qr_secret'] as String?,
    cardVersion: r.data['card_version'] as int? ?? 1,
    status: r.data['status'] as String? ?? 'active',
  );

  /// **یو کس د خپلې پېژندنې له مخې پیدا کوي.**
  ///
  /// دا هغه ټکی دی چې د سکینر ټوله ستونزه حلوي: کارت پخپله وايي
  /// چې د چا دی. د شاګرد کارت د داخلې نمبر وړي، د استاد کارت د
  /// کارمند نمبر — نو کله چې سهار ۷ بجې دواړه ناستې روانې وي، هېڅ
  /// تداخل نه رامنځته کېږي.
  Future<Personnel?> findByInput(String input) async {
    final text = Numerals.toLatin(input.trim());
    if (text.isEmpty) return null;

    for (final kind in const ['teacher', 'staff']) {
      final table = kind == 'teacher' ? 'teachers' : 'staff_members';
      final col = kind == 'teacher' ? 'specialization' : 'job_title';
      final rows = await db
          .customSelect(
            '''
SELECT id, employee_no, full_name, $col AS job_title, phone,
       photo_path, fingerprint_id, qr_secret, card_version, status
FROM $table
WHERE deleted_at IS NULL AND (employee_no = ? OR fingerprint_id = ?)
LIMIT 1
''',
            variables: [Variable<String>(text), Variable<String>(input.trim())],
            readsFrom: {db.teachers, db.staffMembers},
          )
          .get();
      if (rows.isNotEmpty) return _map(rows.first, kind);
    }
    return null;
  }

  /// د یوې ناستې لیست — استادان، کارمندان، یا دواړه.
  Future<List<PersonnelRosterEntry>> roster({
    required DateTime date,
    required int sessionId,
    String? kind,
    String query = '',
    String? status,
  }) async {
    final day = dateOnly(date);
    final people = await personnel(kind: kind, query: query);

    final marks = await db
        .customSelect(
          'SELECT person_kind, person_id, status, check_in_at '
          'FROM staff_attendances WHERE date = ? AND session_id = ?',
          variables: [Variable<DateTime>(day), Variable<int>(sessionId)],
          readsFrom: {db.staffAttendances},
        )
        .get();

    final byKey = {
      for (final m in marks)
        '${m.read<String>('person_kind')}:${m.read<int>('person_id')}': m,
    };

    final out = <PersonnelRosterEntry>[];
    for (final p in people) {
      final m = byKey['${p.kind}:${p.id}'];
      final st = m?.data['status'] as String?;
      if (status != null) {
        if (status == 'unmarked' && st != null) continue;
        if (status != 'unmarked' && st != status) continue;
      }
      out.add(
        PersonnelRosterEntry(
          person: p,
          status: st,
          checkInAt: m?.data['check_in_at'] == null
              ? null
              : DateTime.fromMillisecondsSinceEpoch(
                  (m!.data['check_in_at'] as int) * 1000,
                ),
        ),
      );
    }
    return out;
  }

  /// یو ثبت — له سکینه یا په لاس.
  Future<void> mark({
    required String personKind,
    required int personId,
    required DateTime date,
    required String status,
    int sessionId = 0,
    String method = 'roster',
    int? byUserId,
    DateTime? checkInAt,
    DateTime? now,
  }) async {
    final day = dateOnly(date);
    final stamp = now ?? DateTime.now();

    await db
        .into(db.staffAttendances)
        .insert(
          StaffAttendancesCompanion.insert(
            personKind: personKind,
            personId: personId,
            date: day,
            status: status,
            sessionId: Value(sessionId),
            method: Value(method),
            checkInAt: Value(checkInAt),
            recordedByUserId: Value(byUserId),
            recordedAt: Value(stamp),
          ),
          onConflict: DoUpdate(
            (_) => StaffAttendancesCompanion(
              status: Value(status),
              method: Value(method),
              checkInAt: Value(checkInAt),
              recordedByUserId: Value(byUserId),
              recordedAt: Value(stamp),
            ),
            target: [
              db.staffAttendances.personKind,
              db.staffAttendances.personId,
              db.staffAttendances.date,
              db.staffAttendances.sessionId,
            ],
          ),
        );
  }

  /// د سکین ثبت — د ناوخته/غیرحاضرۍ قواعد پلي کوي.
  Future<String> checkIn({
    required Personnel person,
    required DateTime now,
    required AttendanceRules rules,
    int sessionId = 0,
    int? byUserId,
    String method = 'qr',
  }) async {
    final status = rules.statusForArrival(now);
    await mark(
      personKind: person.kind,
      personId: person.id,
      date: now,
      status: status,
      sessionId: sessionId,
      method: method,
      byUserId: byUserId,
      checkInAt: now,
      now: now,
    );
    return status;
  }

  /// د یوې ورځې لنډیز — د ناستې د کارت لپاره.
  Future<({int target, int marked, int present})> summary({
    required DateTime date,
    required int sessionId,
    String? kind,
  }) async {
    final day = dateOnly(date);
    final people = await personnel(kind: kind);

    final rows = await db
        .customSelect(
          'SELECT person_kind, person_id, status FROM staff_attendances '
          'WHERE date = ? AND session_id = ?',
          variables: [Variable<DateTime>(day), Variable<int>(sessionId)],
          readsFrom: {db.staffAttendances},
        )
        .get();

    final keys = {for (final p in people) '${p.kind}:${p.id}'};
    var marked = 0;
    var present = 0;
    for (final r in rows) {
      final key =
          '${r.read<String>('person_kind')}:${r.read<int>('person_id')}';
      if (!keys.contains(key)) continue;
      marked++;
      final st = r.read<String>('status');
      if (st == 'present' || st == 'late') present++;
    }

    return (target: people.length, marked: marked, present: present);
  }

  /// د یوه کس د میاشتې حاضري — د پروفایل لپاره.
  Future<Map<int, String>> monthGrid({
    required String personKind,
    required int personId,
    required DateTime month,
    int sessionId = 0,
  }) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    final rows = await db
        .customSelect(
          'SELECT date, status FROM staff_attendances '
          'WHERE person_kind = ? AND person_id = ? AND session_id = ? '
          'AND date >= ? AND date <= ?',
          variables: [
            Variable<String>(personKind),
            Variable<int>(personId),
            Variable<int>(sessionId),
            Variable<DateTime>(start),
            Variable<DateTime>(end),
          ],
          readsFrom: {db.staffAttendances},
        )
        .get();

    return {
      for (final r in rows)
        DateTime.fromMillisecondsSinceEpoch(
          r.read<int>('date') * 1000,
          isUtc: true,
        ).toLocal().day: r.read<String>('status'),
    };
  }
}
