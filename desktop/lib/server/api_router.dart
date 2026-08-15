import 'dart:convert';

import 'dart:io' show HttpConnectionInfo;

import 'package:drift/drift.dart' show Variable;
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../data/db/database.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/device_repository.dart';
import '../data/repositories/exam_repository.dart';
import '../data/repositories/leave_repository.dart';
import '../data/repositories/message_repository.dart';
import '../data/repositories/notification_repository.dart';

/// د API نسخه — اپ يې ګوري چې پوه شي ډیسکټاپ زوړ خو نه دی.
const String apiVersion = '1';

/// د سرور ټول لارې.
///
/// **ولې `Handler` جلا فایل کې دی؟** ځکه چې د ازموینې لپاره
/// اړتیا نشته چې ریښتینې پورټ ونیول شي. ازموینه پخپله `Request`
/// جوړوي او همدې فنکشن ته يې ورکوي — چټک، ټینګ، او د CI په
/// محدود شبکه کې کار کوي.
class ApiDeps {
  final AppDatabase db;
  final DeviceRepository devices;
  final AttendanceRepository attendance;
  final LeaveRepository leave;
  final ExamRepository exams;
  final MessageRepository messages;
  final NotificationRepository notifications;

  /// د ښوونځي نوم — په پیغامونو او د اپ په سرلیک کې ښکاري.
  final String Function() schoolName;

  ApiDeps({
    required this.db,
    required this.devices,
    required this.attendance,
    required this.leave,
    required this.exams,
    required this.messages,
    required this.notifications,
    required this.schoolName,
  });

  factory ApiDeps.of(AppDatabase db, {String Function()? schoolName}) => ApiDeps(
    db: db,
    devices: DeviceRepository(db),
    attendance: AttendanceRepository(db),
    leave: LeaveRepository(db),
    exams: ExamRepository(db),
    messages: MessageRepository(db),
    notifications: NotificationRepository(db),
    schoolName: schoolName ?? () => '',
  );
}

Response _json(Object? body, {int status = 200}) => Response(
  status,
  body: jsonEncode(body),
  headers: {'content-type': 'application/json; charset=utf-8'},
);

Response _err(int status, String message) =>
    _json({'error': message}, status: status);

String _iso(DateTime t) =>
    '${t.year}-${t.month.toString().padLeft(2, '0')}'
    '-${t.day.toString().padLeft(2, '0')}';

DateTime _parseDate(String? s, {DateTime? fallback}) {
  if (s == null || s.isEmpty) return dateOnly(fallback ?? DateTime.now());
  return dateOnly(DateTime.tryParse(s) ?? (fallback ?? DateTime.now()));
}

Future<Map<String, dynamic>> _body(Request r) async {
  final raw = await r.readAsString();
  if (raw.trim().isEmpty) return {};
  final decoded = jsonDecode(raw);
  return decoded is Map<String, dynamic> ? decoded : {};
}

const _identityKey = 'sm.identity';

DeviceIdentity _me(Request r) => r.context[_identityKey]! as DeviceIdentity;

/// د توکن کتنه. هره خوندي لار ورڅخه تېرېږي.
Middleware _requireDevice(ApiDeps d, {String? role}) {
  return (Handler inner) {
    return (Request req) async {
      final header = req.headers['authorization'] ?? '';
      final token = header.toLowerCase().startsWith('bearer ')
          ? header.substring(7).trim()
          : null;

      final id = await d.devices.authenticate(token, ip: _clientIp(req));
      if (id == null) return _err(401, 'توکن نه دی سم یا باطل شوی');
      if (role != null && id.role != role) {
        return _err(403, 'دې برخې ته اجازه نشته');
      }
      return inner(req.change(context: {_identityKey: id}));
    };
  };
}

/// ټول API جوړوي.
Handler buildApi(ApiDeps d) {
  final root = Router();

  // ── عامه ──────────────────────────────────────────────
  // د اپ «ښوونځی پیدا کړه» پرده دې ته اړتیا لري — پرته له
  // توکنه، چې کارن پوه شي پته سمه ده که نه.
  root.get('/api/ping', (Request r) async {
    return _json({
      'ok': true,
      'app': 'school-manager',
      'api': apiVersion,
      'school': d.schoolName(),
      'time': DateTime.now().toIso8601String(),
    });
  });

  root.post('/api/pair', (Request r) async {
    final b = await _body(r);
    final code = (b['code'] as String?)?.trim() ?? '';
    if (code.isEmpty) return _err(400, 'کوډ ولیکئ');

    final result = await d.devices.redeem(
      code: code,
      deviceName: (b['deviceName'] as String?) ?? 'وسیله',
      platform: (b['platform'] as String?) ?? 'android',
      pushToken: b['pushToken'] as String?,
    );

    return switch (result) {
      RedeemOk(pair: final p) => _json({
        'token': p.token,
        'role': p.device.role,
        'deviceId': p.device.id,
        'deviceName': p.device.name,
        'guardianId': p.device.guardianId,
        'guardianName': p.guardianName,
        'school': d.schoolName(),
        'api': apiVersion,
      }),
      RedeemExpired(expiredAt: final at) => _err(
        410,
        'کوډ ختم شوی (${at.hour}:${at.minute.toString().padLeft(2, '0')}). '
        'له مدیر څخه نوی وغواړئ.',
      ),
      RedeemUnknown() => _err(404, 'دا کوډ نه پېژندل کېږي یا کارول شوی'),
    };
  });

  // ── هر تړل شوی وسیله ──────────────────────────────────
  final common = Router();

  common.get('/me', (Request r) async {
    final me = _me(r);
    return _json({
      'role': me.role,
      'deviceName': me.device.name,
      'guardianId': me.guardianId,
      'school': d.schoolName(),
      'api': apiVersion,
    });
  });

  common.post('/push-token', (Request r) async {
    final me = _me(r);
    final b = await _body(r);
    final t = (b['pushToken'] as String?)?.trim();
    if (t == null || t.isEmpty) return _err(400, 'pushToken تش دی');
    await d.devices.setPushToken(me.device.id, t);
    return _json({'ok': true});
  });

  root.mount(
    '/api/device',
    const Pipeline().addMiddleware(_requireDevice(d)).addHandler(common.call),
  );

  // ── مدیر ──────────────────────────────────────────────
  final manager = Router();

  manager.get('/summary', (Request r) async {
    final date = _parseDate(r.url.queryParameters['date']);
    final s = await d.attendance.summary(date);

    // **دلته خبرتیا هم تازه کېږي.** ولې؟ ځکه چې مدیر ښايي
    // ډیسکټاپ ته لاس هم نه وي وروړی — تلیفون يې هر څو دقیقې
    // پوښتنه کوي، نو همدلته پوهېږو چې نن څوک غیرحاضر دی.
    final digest = await d.notifications.syncAbsenceDigest(
      date: date,
      schoolName: d.schoolName(),
    );

    return _json({
      'date': _iso(date),
      'total': s.total,
      'present': s.present,
      'late': s.late,
      'absent': s.absent,
      'onLeave': s.onLeave,
      'unmarked': s.unmarked,
      'presentPercent': s.presentPercent.round(),
      'pendingLeave': await d.leave.pendingCount(),
      'unnotifiedAbsent': digest?.total ?? 0,
      'unreadNotifications': await d.notifications.unreadCount(),
    });
  });

  manager.get('/absentees', (Request r) async {
    final date = _parseDate(r.url.queryParameters['date']);
    final onlyNew = r.url.queryParameters['onlyUnnotified'] == '1';
    final rows = await d.attendance.absentees(date, onlyUnnotified: onlyNew);

    return _json({
      'date': _iso(date),
      'items': [
        for (final a in rows)
          {
            'studentId': a.student.id,
            'admissionNo': a.student.admissionNo,
            'name': [
              a.student.firstName,
              if (a.student.lastName?.isNotEmpty ?? false) a.student.lastName,
            ].join(' '),
            'fatherName': a.student.fatherName,
            'class': a.className,
            'monthlyAbsences': a.monthlyAbsences,
          },
      ],
    });
  });

  /// **د پروژې اصلي غوښتنه.** مدیر په تلیفون کې تڼۍ کېکاږي او
  /// د ټولو یا د یوه شاګرد والدینو ته پیغام ځي.
  manager.post('/notify', (Request r) async {
    final me = _me(r);
    final b = await _body(r);
    final date = _parseDate(b['date'] as String?);

    var ids = (b['studentIds'] as List?)?.cast<num>().map((n) => n.toInt())
        .toList();

    // `all` = نن ټول هغه غیرحاضران چې لا پیغام نه دی ورته تللی.
    if (ids == null || ids.isEmpty) {
      final rows = await d.attendance.absentees(date, onlyUnnotified: true);
      ids = rows.map((a) => a.student.id).toList();
    }

    final result = await d.messages.notifyAbsentees(
      date: date,
      studentIds: ids,
      templateKey: (b['templateKey'] as String?) ?? 'absence',
      byUserId: me.userId ?? 0,
      schoolName: d.schoolName(),
    );

    // هغه خبرتیا چې دا کار يې وغوښت — اوس «شوې» ده.
    await d.notifications.syncAbsenceDigest(
      date: date,
      schoolName: d.schoolName(),
    );

    return _json({
      'batchId': result.batchId,
      'queued': result.queued,
      'sent': result.sent,
      'failed': result.failed,
      'notified': result.notifiedStudentIds,
    });
  });

  manager.get('/notifications', (Request r) async {
    final rows = await d.notifications.inbox();
    return _json({
      'items': [
        for (final n in rows)
          {
            'id': n.id,
            'kind': n.kind,
            'title': n.title,
            'body': n.body,
            'payload': n.payloadJson == null
                ? null
                : jsonDecode(n.payloadJson!),
            'createdAt': n.createdAt.toIso8601String(),
            'read': n.readAt != null,
            'acted': n.actedAt != null,
          },
      ],
    });
  });

  manager.post('/notifications/<id|[0-9]+>/read', (Request r, String id) async {
    await d.notifications.markRead(int.parse(id));
    return _json({'ok': true});
  });

  manager.get('/leave', (Request r) async {
    final page = await d.leave.list(
      status: r.url.queryParameters['status'] ?? 'pending',
      limit: 50,
    );
    return _json({
      'total': page.total,
      'items': [
        for (final row in page.items)
          {
            'id': row.request.id,
            'studentId': row.student.id,
            'student': [
              row.student.firstName,
              if (row.student.lastName?.isNotEmpty ?? false)
                row.student.lastName,
            ].join(' '),
            'class': row.className,
            'reasonType': row.request.reasonType,
            'reasonText': row.request.reasonText,
            'fromDate': _iso(row.request.fromDate),
            'toDate': _iso(row.request.toDate),
            'days': row.days,
            'status': row.request.status,
            'via': row.request.requestedVia,
          },
      ],
    });
  });

  manager.post('/leave/<id|[0-9]+>/decide', (Request r, String id) async {
    final me = _me(r);
    final b = await _body(r);
    final approve = b['approve'] == true;

    await d.leave.decide(
      leaveId: int.parse(id),
      approve: approve,
      note: b['note'] as String?,
      byUserId: me.userId ?? 0,
      byUserName: me.device.name,
    );
    return _json({'ok': true, 'status': approve ? 'approved' : 'rejected'});
  });

  manager.get('/messages', (Request r) async {
    final page = await d.messages.list(
      status: r.url.queryParameters['status'],
      limit: int.tryParse(r.url.queryParameters['limit'] ?? '') ?? 40,
    );
    return _json({
      'total': page.total,
      'items': [
        for (final row in page.items)
          {
            'id': row.message.id,
            'kind': row.message.kind,
            'student': row.studentName,
            'to': row.message.toName,
            'phone': row.message.toPhone,
            'channel': row.message.channel,
            'status': row.message.status,
            'error': row.message.error,
            'body': row.message.body,
            'createdAt': row.message.createdAt.toIso8601String(),
          },
      ],
    });
  });

  root.mount(
    '/api/manager',
    const Pipeline()
        .addMiddleware(_requireDevice(d, role: 'manager'))
        .addHandler(manager.call),
  );

  // ── والدین ────────────────────────────────────────────
  final parent = Router();

  parent.get('/children', (Request r) async {
    final me = _me(r);
    final gid = me.guardianId;
    if (gid == null) return _err(403, 'دا وسیله سرپرست ته نه ده تړل شوې');

    final rows = await d.db
        .customSelect(
          '''
SELECT s.id AS id, s.admission_no, s.first_name, s.last_name,
       s.father_name, s.status,
       g.name || ' — ' || sec.name AS class_name
FROM student_guardians sg
JOIN students s ON s.id = sg.student_id AND s.deleted_at IS NULL
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
WHERE sg.guardian_id = ?
ORDER BY s.first_name
''',
          variables: [Variable<int>(gid)],
          readsFrom: {
            d.db.studentGuardians,
            d.db.students,
            d.db.enrollments,
            d.db.sections,
            d.db.grades,
          },
        )
        .get();

    final today = dateOnly(DateTime.now());
    final items = <Map<String, Object?>>[];
    for (final row in rows) {
      final sid = row.read<int>('id');
      final month = await d.attendance.monthlyBreakdown(
        studentId: sid,
        month: today,
      );
      final present = (month['present'] ?? 0) + (month['late'] ?? 0);
      final counted = present + (month['absent'] ?? 0);

      items.add({
        'id': sid,
        'admissionNo': row.read<String>('admission_no'),
        'name': [
          row.read<String>('first_name'),
          if ((row.data['last_name'] as String?)?.isNotEmpty ?? false)
            row.data['last_name'],
        ].join(' '),
        'fatherName': row.read<String>('father_name'),
        'class': row.data['class_name'],
        'monthPresent': present,
        'monthAbsent': month['absent'] ?? 0,
        'monthLeave': month['leave'] ?? 0,
        'attendancePercent': counted == 0
            ? 100
            : ((present / counted) * 100).round(),
      });
    }

    return _json({'items': items});
  });

  parent.get('/children/<id|[0-9]+>/attendance', (Request r, String id) async {
    final me = _me(r);
    final sid = int.parse(id);
    if (!await _guardianOwns(d, me.guardianId, sid)) {
      return _err(403, 'دا شاګرد ستاسو نه دی');
    }

    final q = r.url.queryParameters['month'];
    final month = q == null
        ? DateTime.now()
        : DateTime.tryParse('$q-01') ?? DateTime.now();

    final rows = await d.db
        .customSelect(
          'SELECT date, status, check_in_at FROM attendances '
          'WHERE student_id = ? AND date >= ? AND date <= ? ORDER BY date',
          variables: [
            Variable<int>(sid),
            Variable<DateTime>(DateTime(month.year, month.month, 1)),
            Variable<DateTime>(DateTime(month.year, month.month + 1, 0)),
          ],
          readsFrom: {d.db.attendances},
        )
        .get();

    return _json({
      'month':
          '${month.year}-${month.month.toString().padLeft(2, '0')}',
      'summary': await d.attendance.monthlyBreakdown(
        studentId: sid,
        month: month,
      ),
      'days': [
        for (final row in rows)
          {
            'date': _iso(row.read<DateTime>('date')),
            'status': row.read<String>('status'),
          },
      ],
    });
  });

  parent.get('/children/<id|[0-9]+>/results', (Request r, String id) async {
    final me = _me(r);
    final sid = int.parse(id);
    if (!await _guardianOwns(d, me.guardianId, sid)) {
      return _err(403, 'دا شاګرد ستاسو نه دی');
    }

    final results = await d.exams.publishedResultsFor(sid);
    return _json({
      'items': [
        for (final e in results)
          {
            'examId': e.exam.id,
            'exam': e.exam.name,
            'examType': e.exam.examType,
            'date': _iso(e.exam.startsOn),
            'obtained': e.result.obtainedTotal,
            'full': e.result.fullTotal,
            'percent': e.result.percent.round(),
            'grade': e.result.band.letter,
            'gradeLabel': e.result.band.label,
            'rank': e.result.rank,
            'outOf': e.result.outOf,
            'passed': e.result.passedAll,
            'subjects': [
              for (final s in e.result.subjects)
                {
                  'name': s.subjectName,
                  'obtained': s.obtained,
                  'full': s.fullMark,
                  'pass': s.passMark,
                  'absent': s.isAbsent,
                  'passed': s.passed,
                },
            ],
          },
      ],
    });
  });

  parent.get('/messages', (Request r) async {
    final me = _me(r);
    final gid = me.guardianId;
    if (gid == null) return _err(403, 'دا وسیله سرپرست ته نه ده تړل شوې');

    final rows = await d.messages.inboxFor(gid);
    // د لوستلو نښه دلته نه ږدو — اپ يې پخپله د پرانیستلو پر مهال
    // بېرته لېږي. که دلته يې کېښودو، یوه ساده تازه‌کول به ټول
    // پیغامونه «لوستل شوي» کړل او مدیر ته به غلط راپور ورغی.
    return _json({
      'items': [
        for (final m in rows)
          {
            'id': m.id,
            'kind': m.kind,
            'body': m.body,
            'channel': m.channel,
            'status': m.status,
            'createdAt': m.createdAt.toIso8601String(),
            'read': m.status == 'read',
          },
      ],
    });
  });

  parent.post('/messages/read', (Request r) async {
    final b = await _body(r);
    final ids = (b['ids'] as List?)?.cast<num>().map((n) => n.toInt()).toList();
    return _json({'updated': await d.messages.markRead(ids ?? const [])});
  });

  parent.post('/leave', (Request r) async {
    final me = _me(r);
    final b = await _body(r);
    final sid = (b['studentId'] as num?)?.toInt();
    if (sid == null) return _err(400, 'شاګرد نه دی ټاکل شوی');
    if (!await _guardianOwns(d, me.guardianId, sid)) {
      return _err(403, 'دا شاګرد ستاسو نه دی');
    }

    final from = _parseDate(b['fromDate'] as String?);
    final to = _parseDate(b['toDate'] as String?, fallback: from);

    final leaveId = await d.leave.request(
      studentId: sid,
      reasonType: (b['reasonType'] as String?) ?? 'other',
      reasonText: b['reasonText'] as String?,
      fromDate: from,
      toDate: to,
      requestedVia: 'parent_app',
    );

    final student = await (d.db.select(
      d.db.students,
    )..where((s) => s.id.equals(sid))).getSingle();

    // مدیر باید خبر شي — که نه، غوښتنه به په ډیټابیس کې ویده وه.
    await d.notifications.leaveRequested(
      leaveId: leaveId,
      studentName: student.firstName,
      fromDate: from,
      toDate: to,
    );

    return _json({'ok': true, 'id': leaveId, 'status': 'pending'});
  });

  root.mount(
    '/api/parent',
    const Pipeline()
        .addMiddleware(_requireDevice(d, role: 'parent'))
        .addHandler(parent.call),
  );

  root.all('/<ignored|.*>', (Request r) => _err(404, 'دا لار نشته'));

  return const Pipeline()
      .addMiddleware(_jsonErrors())
      .addMiddleware(_noCache())
      .addHandler(root.call);
}

/// یوه استثنا باید د JSON غلطي شي، نه د HTML پاڼه.
///
/// **ولې دا مهمه ده؟** د دروازې پر مخ د تلیفون کارن یوازې دومره
/// ویني چې «نه کېږي». که سرور یوه HTML صفحه ورولېږي، اپ به يې
/// د تجزیې پر مهال مات شو. دلته هر څه JSON دي.
Middleware _jsonErrors() => (inner) => (req) async {
  try {
    return await inner(req);
  } catch (e) {
    return _err(500, 'د سرور تېروتنه: $e');
  }
};

Middleware _noCache() => (inner) => (req) async {
  final res = await inner(req);
  return res.change(headers: {'cache-control': 'no-store'});
};

Future<bool> _guardianOwns(ApiDeps d, int? guardianId, int studentId) async {
  if (guardianId == null) return false;
  final row =
      await (d.db.select(d.db.studentGuardians)
            ..where((sg) => sg.guardianId.equals(guardianId))
            ..where((sg) => sg.studentId.equals(studentId))
            ..limit(1))
          .getSingleOrNull();
  return row != null;
}

/// د تلیفون پته — د تنظیماتو په پاڼه کې ښکاري، چې مدیر وپېژني
/// کوم وسیله اوس فعاله ده.
String? _clientIp(Request req) {
  final info = req.context['shelf.io.connection_info'];
  if (info is HttpConnectionInfo) return info.remoteAddress.address;
  return null;
}
