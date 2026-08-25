import 'dart:convert';

import 'package:drift/drift.dart';

import 'attendance_repository.dart' show dateOnly;
import '../db/database.dart';
import 'student_repository.dart' show Paged;

// ═══════════════════════════════════════════════════════════
//  لېږونکي
// ═══════════════════════════════════════════════════════════

/// د یوه لېږد پایله.
class SendOutcome {
  final bool ok;
  final String? error;
  const SendOutcome.ok() : ok = true, error = null;
  const SendOutcome.failed(this.error) : ok = false;
}

/// یو کانال چې پیغام ورڅخه وځي.
///
/// **ولې انټرفیس؟** ښوونځی نن SMS نه لري، سبا يې لري. یو
/// ښوونځی د WhatsApp له لارې لېږي، بل د اپ له لارې. که د لېږلو
/// کوډ په ریپوزیټوري کې ټینګ وای، هر نوی کانال به يې ماتاوه.
abstract class MessageSender {
  String get channel;
  Future<SendOutcome> send({
    required String? to,
    required String body,
    Message? message,
  });
}

/// د اپ کانال — پیغام په ډیټابیس کې پاتې کېږي، والدین يې له خپل
/// اپ څخه راښکي.
///
/// **دا ولې «ولېږل شو» ګڼل کېږي؟** ځکه چې دلته لېږد نشته — پیغام
/// د ښوونځي په سرور کې دی او د والدینو اپ يې پوښتي. کله چې يې
/// اپ ولولي، حالت `read` ته اوړي. نو `sent` دلته «چمتو دی» معنا
/// لري، او دا ریښتیا ده.
class AppInboxSender implements MessageSender {
  final AppDatabase db;
  const AppInboxSender(this.db);

  @override
  String get channel => 'app';

  @override
  Future<SendOutcome> send({
    required String? to,
    required String body,
    Message? message,
  }) async {
    if (message?.guardianId == null) {
      return const SendOutcome.failed('سرپرست نه دی ټاکل شوی');
    }
    final has =
        await (db.select(db.devices)
              ..where((d) => d.guardianId.equals(message!.guardianId!))
              ..where((d) => d.revokedAt.isNull())
              ..limit(1))
            .getSingleOrNull();
    if (has == null) {
      return const SendOutcome.failed('د دې کور اپ لا نه دی تړل شوی');
    }
    return const SendOutcome.ok();
  }
}

/// د SMS دروازه — یو اندروید تلیفون چې د ښوونځي په Wi-Fi پورې تړلی
/// او د SMS د لېږلو کوچنی سرور پرې ځغلي.
///
/// **ولې دا لار، نه د انټرنټ SMS خدمت؟** په افغانستان کې د SMS
/// APIونه یا نشته یا ګران دي، او انټرنټ ټینګ نه دی. یو زوړ تلیفون
/// د ښوونځي په سیم کارت سره پرته له انټرنټه کار کوي.
class SmsGatewaySender implements MessageSender {
  /// «http://192.168.1.50:8080/send» — د تنظیماتو څخه راځي.
  final String? endpoint;
  final String? apiKey;
  final Future<SendOutcome> Function(Uri uri, Map<String, String> body)? _post;

  const SmsGatewaySender({
    this.endpoint,
    this.apiKey,
    Future<SendOutcome> Function(Uri, Map<String, String>)? post,
  }) : _post = post;

  @override
  String get channel => 'sms';

  @override
  Future<SendOutcome> send({
    required String? to,
    required String body,
    Message? message,
  }) async {
    if (endpoint == null || endpoint!.isEmpty) {
      return const SendOutcome.failed('د SMS دروازه نه ده تنظیم شوې');
    }
    if (to == null || to.trim().isEmpty) {
      return const SendOutcome.failed('د تلیفون شمېره نشته');
    }
    final poster = _post;
    if (poster == null) {
      return const SendOutcome.failed('د SMS دروازه نه ده وصل');
    }
    return poster(Uri.parse(endpoint!), {
      'to': to.trim(),
      'message': body,
      if (apiKey != null) 'key': apiKey!,
    });
  }
}

// ═══════════════════════════════════════════════════════════
//  کینډۍ
// ═══════════════════════════════════════════════════════════

/// د کینډۍ متن ډکول.
///
/// نه‌پېژندل شوی ځای‌نیوونکی **پرته له بدلون پاتې کېږي**، نه چې
/// تش شي. که کینډۍ کې د لیکلو تېروتنه وي، مدیر يې په لیدو سره
/// پېژني — نه دا چې یو تش ځای ولري او ونه پوهېږي څه ورک دي.
String renderTemplate(String body, Map<String, String> vars) {
  return body.replaceAllMapped(RegExp(r'\{(\w+)\}'), (m) {
    final key = m.group(1)!;
    return vars[key] ?? m.group(0)!;
  });
}

/// هغه کینډۍ چې هر ښوونځی ورته اړتیا لري.
const List<({String key, String title, String body, String channel})>
builtInTemplates = [
  (
    key: 'absence',
    title: 'د غیرحاضرۍ خبرتیا',
    body:
        'ښاغلی/ښاغلې {guardian}، درناوی!\n'
        'ستاسو زوی/لور {student} ({class}) نن — {date} — '
        'په {school} کې غیرحاضر و.\n'
        'که کوم عذر لرئ، مهرباني وکړئ ښوونځي ته خبر ورکړئ.',
    channel: 'any',
  ),
  (
    key: 'absence_repeat',
    title: 'د پرله‌پسې غیرحاضرۍ خبرتیا',
    body:
        'ښاغلی/ښاغلې {guardian}، درناوی!\n'
        '{student} ({class}) په دې میاشت کې {count} ورځې غیرحاضر دی.\n'
        'مهرباني وکړئ د {school} مدیریت سره اړیکه ونیسئ.',
    channel: 'any',
  ),
  (
    key: 'leave_approved',
    title: 'اجازه ومنل شوه',
    body:
        'د {student} د رخصتۍ غوښتنه له {date} څخه ومنل شوه.\n'
        '{school}',
    channel: 'any',
  ),
  (
    key: 'leave_rejected',
    title: 'اجازه رد شوه',
    body:
        'د {student} د رخصتۍ غوښتنه ونه منل شوه.\n'
        'د معلوماتو لپاره له ښوونځي سره اړیکه ونیسئ. — {school}',
    channel: 'any',
  ),
  (
    key: 'fee_due',
    title: 'د فیس یادونه',
    body:
        'ښاغلی/ښاغلې {guardian}، د {student} فیس لا نه دی ورکړل شوی.\n'
        'مهرباني وکړئ د {school} محاسبې برخې ته مراجعه وکړئ.',
    channel: 'any',
  ),
  (
    key: 'announcement',
    title: 'عمومي اعلان',
    body: '{school}\n\n…',
    channel: 'any',
  ),
];

// ═══════════════════════════════════════════════════════════
//  د لیست کرښه
// ═══════════════════════════════════════════════════════════

class MessageRow {
  final Message message;
  final String? studentName;
  final String? className;

  const MessageRow({required this.message, this.studentName, this.className});
}

class MessageStats {
  final int queued;
  final int sent;
  final int failed;
  final int read;

  const MessageStats({
    this.queued = 0,
    this.sent = 0,
    this.failed = 0,
    this.read = 0,
  });

  int get total => queued + sent + failed + read;
  /// «رسېدلي» = تللي + لوستل شوي.
  int get delivered => sent + read;
}

/// مخکې له لېږلو د لاسرسي انځور.
class Deliverability {
  final int viaApp;
  final int viaSms;
  final int unreachable;

  const Deliverability({
    this.viaApp = 0,
    this.viaSms = 0,
    this.unreachable = 0,
  });

  int get total => viaApp + viaSms + unreachable;
}

/// د یوې ډلې د لېږلو پایله.
class DispatchResult {
  final String batchId;
  final int queued;
  final int sent;
  final int failed;
  final List<int> notifiedStudentIds;

  const DispatchResult({
    required this.batchId,
    required this.queued,
    required this.sent,
    required this.failed,
    this.notifiedStudentIds = const [],
  });
}

// ═══════════════════════════════════════════════════════════
//  ریپوزیټوري
// ═══════════════════════════════════════════════════════════

class MessageRepository {
  final AppDatabase db;

  /// د کانال په نامه — `app`، `sms`. که کانال ونه موندل شي،
  /// پیغام د روښانه لامل سره ناکام ثبتېږي، نه چې غلی ورک شي.
  final Map<String, MessageSender> senders;

  MessageRepository(this.db, {Map<String, MessageSender>? senders})
    : senders = senders ?? {'app': AppInboxSender(db)};

  // ── کینډۍ ───────────────────────────────────────────────

  Future<void> ensureDefaultTemplates() async {
    final existing = await db.select(db.messageTemplates).get();
    final have = existing.map((t) => t.templateKey).toSet();

    for (final t in builtInTemplates) {
      if (have.contains(t.key)) continue;
      await db
          .into(db.messageTemplates)
          .insert(
            MessageTemplatesCompanion.insert(
              templateKey: t.key,
              title: t.title,
              body: t.body,
              channel: Value(t.channel),
              isBuiltIn: const Value(true),
            ),
          );
    }
  }

  Future<List<MessageTemplate>> templates() =>
      (db.select(db.messageTemplates)
            ..orderBy([(t) => OrderingTerm.asc(t.id)]))
          .get();

  Future<MessageTemplate?> templateByKey(String key) =>
      (db.select(db.messageTemplates)
            ..where((t) => t.templateKey.equals(key))
            ..limit(1))
          .getSingleOrNull();

  Future<void> saveTemplateBody(String key, String body) =>
      (db.update(db.messageTemplates)
            ..where((t) => t.templateKey.equals(key)))
          .write(MessageTemplatesCompanion(body: Value(body)));

  // ── د غیرحاضرۍ پیغامونه ─────────────────────────────────

  /// د یوې ورځې غیرحاضرو شاګردانو والدینو ته پیغام قطار ته اچوي
  /// او سمدلاسه يې لېږي.
  ///
  /// **دا لار ولې یوه ده؟** که «قطار» او «لېږل» دوه بېلې بلنې وای،
  /// مدیر به تڼۍ کېکاږله، پیغامونه به قطار کې پاتې و، او هغه به
  /// فکر کاوه چې تللي دي. یوه بلنه = یوه پرېکړه.
  ///
  /// د حاضرۍ کرښه یوازې هغه وخت `parent_notified` نښه کېږي چې
  /// **لږ تر لږه یو** پیغام يې بریالی شوی وي — که نه، سبا به بیا
  /// هڅه وشي.
  Future<DispatchResult> notifyAbsentees({
    required DateTime date,
    required List<int> studentIds,
    String templateKey = 'absence',
    required int byUserId,
    String? schoolName,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final day = dateOnly(date);
    final batchId = 'b${at.millisecondsSinceEpoch}';

    if (studentIds.isEmpty) {
      return DispatchResult(
        batchId: batchId,
        queued: 0,
        sent: 0,
        failed: 0,
      );
    }

    final tpl = await templateByKey(templateKey);
    final body =
        tpl?.body ??
        builtInTemplates.firstWhere((t) => t.key == templateKey).body;

    final recipients = await _recipientsFor(studentIds, day);

    var queued = 0;
    var sent = 0;
    var failed = 0;
    final okStudents = <int>{};

    for (final r in recipients) {
      final text = renderTemplate(body, {
        'student': r.studentName,
        'guardian': r.guardianName ?? 'سرپرست',
        'class': r.className ?? '—',
        'date': _isoDate(day),
        'school': schoolName ?? '',
        'count': '${r.monthlyAbsences}',
      });

      final id = await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              batchId: Value(batchId),
              kind: 'absence',
              studentId: Value(r.studentId),
              guardianId: Value(r.guardianId),
              toName: Value(r.guardianName),
              toPhone: Value(r.phone),
              channel: Value(r.channel),
              body: text,
              relatedDate: Value(day),
              createdByUserId: Value(byUserId),
              // **دا وخت باید ورکړل شوی وي، نه `DateTime.now()`.**
              // که نه، د تاریخچې کرښه د ریښتیني ساعت وخت ښیي او د
              // لېږلو وخت سره سمون نه خوري.
              createdAt: Value(at),
            ),
          );
      queued++;

      final outcome = await _deliver(id, at: at);
      if (outcome) {
        sent++;
        okStudents.add(r.studentId);
      } else {
        failed++;
      }
    }

    if (okStudents.isNotEmpty) {
      await db.customUpdate(
        'UPDATE attendances SET parent_notified = 1, parent_notified_at = ? '
        'WHERE date = ? AND student_id IN '
        '(${List.filled(okStudents.length, '?').join(',')})',
        variables: [
          Variable<DateTime>(at),
          Variable<DateTime>(day),
          ...okStudents.map(Variable<int>.new),
        ],
        updates: {db.attendances},
      );
    }

    await db
        .into(db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            action: 'create',
            entity: 'messages',
            userId: Value(byUserId),
            changesJson: Value(
              jsonEncode({
                'batch': batchId,
                'date': _isoDate(day),
                'queued': queued,
                'sent': sent,
                'failed': failed,
              }),
            ),
          ),
        );

    return DispatchResult(
      batchId: batchId,
      queued: queued,
      sent: sent,
      failed: failed,
      notifiedStudentIds: okStudents.toList()..sort(),
    );
  }

  /// یو آزاد پیغام — اعلان، د فیس یادونه، یا هر څه.
  Future<DispatchResult> sendCustom({
    required String kind,
    required List<({int? studentId, int? guardianId, String? phone, String channel, String? name})>
    to,
    required String body,
    required int byUserId,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final batchId = 'b${at.millisecondsSinceEpoch}';
    var sent = 0;
    var failed = 0;

    for (final r in to) {
      final id = await db
          .into(db.messages)
          .insert(
            MessagesCompanion.insert(
              batchId: Value(batchId),
              kind: kind,
              studentId: Value(r.studentId),
              guardianId: Value(r.guardianId),
              toName: Value(r.name),
              toPhone: Value(r.phone),
              channel: Value(r.channel),
              body: body,
              createdByUserId: Value(byUserId),
              createdAt: Value(at),
            ),
          );
      if (await _deliver(id, at: at)) {
        sent++;
      } else {
        failed++;
      }
    }

    return DispatchResult(
      batchId: batchId,
      queued: to.length,
      sent: sent,
      failed: failed,
    );
  }

  /// یو پیغام لېږي او حالت يې تازه کوي. `true` = بریالی.
  Future<bool> _deliver(int messageId, {DateTime? at}) async {
    final now = at ?? DateTime.now();
    final msg = await (db.select(
      db.messages,
    )..where((m) => m.id.equals(messageId))).getSingle();

    final sender = senders[msg.channel];
    final outcome = sender == null
        ? SendOutcome.failed('د «${msg.channel}» کانال نه دی تنظیم شوی')
        : await sender.send(to: msg.toPhone, body: msg.body, message: msg);

    await (db.update(db.messages)..where((m) => m.id.equals(messageId))).write(
      MessagesCompanion(
        status: Value(outcome.ok ? 'sent' : 'failed'),
        attempts: Value(msg.attempts + 1),
        error: Value(outcome.error),
        sentAt: Value(outcome.ok ? now : null),
      ),
    );

    return outcome.ok;
  }

  /// ناکام پیغامونه بیا هڅه کوي — کله چې د SMS دروازه بېرته راشي.
  Future<DispatchResult> retryFailed({int limit = 200}) async {
    final rows =
        await (db.select(db.messages)
              ..where((m) => m.status.equals('failed'))
              ..orderBy([(m) => OrderingTerm.asc(m.createdAt)])
              ..limit(limit))
            .get();

    var sent = 0;
    var failed = 0;
    for (final m in rows) {
      if (await _deliver(m.id)) {
        sent++;
      } else {
        failed++;
      }
    }
    return DispatchResult(
      batchId: 'retry',
      queued: rows.length,
      sent: sent,
      failed: failed,
    );
  }

  /// مخکې له لېږلو: څو کورونه واقعاً لاسرسي وړ دي؟
  ///
  /// **ولې دا مهمه ده؟** مدیر تڼۍ کېکاږي او فکر کوي چې ټول پیغامونه
  /// ولاړل. که شپږ کورونه نه اپ لري نه شمېره، هغه باید **مخکې** پوه
  /// شي — نه وروسته د ناکامۍ په لیست کې.
  Future<Deliverability> deliverability(
    List<int> studentIds,
    DateTime date,
  ) async {
    if (studentIds.isEmpty) return const Deliverability();
    final recipients = await _recipientsFor(studentIds, dateOnly(date));

    final paired = <int>{};
    final rows = await db
        .customSelect(
          'SELECT DISTINCT guardian_id FROM devices '
          'WHERE revoked_at IS NULL AND guardian_id IS NOT NULL',
          readsFrom: {db.devices},
        )
        .get();
    for (final r in rows) {
      paired.add(r.read<int>('guardian_id'));
    }

    var viaApp = 0;
    var viaSms = 0;
    var unreachable = 0;
    for (final r in recipients) {
      final hasApp = r.guardianId != null && paired.contains(r.guardianId);
      final hasPhone = (r.phone ?? '').trim().isNotEmpty;

      if (r.channel == 'sms' && hasPhone) {
        viaSms++;
      } else if (hasApp) {
        viaApp++;
      } else if (hasPhone) {
        viaSms++;
      } else {
        unreachable++;
      }
    }
    return Deliverability(
      viaApp: viaApp,
      viaSms: viaSms,
      unreachable: unreachable,
    );
  }

  // ── لوستل ───────────────────────────────────────────────

  Future<Paged<MessageRow>> list({
    String? status,
    String? kind,
    int limit = 50,
    int offset = 0,
  }) async {
    final where = <String>[];
    final args = <Variable<Object>>[];
    if (status != null) {
      where.add('m.status = ?');
      args.add(Variable<String>(status));
    }
    if (kind != null) {
      where.add('m.kind = ?');
      args.add(Variable<String>(kind));
    }
    final whereSql = where.isEmpty ? '' : 'WHERE ${where.join(' AND ')}';

    final count = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM messages m $whereSql',
          variables: args,
          readsFrom: {db.messages},
        )
        .getSingle();

    final rows = await db
        .customSelect(
          '''
SELECT m.*,
  s.first_name || COALESCE(' ' || s.last_name, '') AS student_name,
  g.name || ' — ' || sec.name AS class_name
FROM messages m
LEFT JOIN students s ON s.id = m.student_id
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
$whereSql
ORDER BY m.created_at DESC, m.id DESC
LIMIT ? OFFSET ?
''',
          variables: [...args, Variable<int>(limit), Variable<int>(offset)],
          readsFrom: {
            db.messages,
            db.students,
            db.enrollments,
            db.sections,
            db.grades,
          },
        )
        .get();

    return Paged(
      rows
          .map(
            (r) => MessageRow(
              message: db.messages.map(r.data),
              studentName: r.data['student_name'] as String?,
              className: r.data['class_name'] as String?,
            ),
          )
          .toList(),
      count.read<int>('c'),
    );
  }

  Future<MessageStats> stats() async {
    final rows = await db
        .customSelect(
          'SELECT status, COUNT(*) AS c FROM messages GROUP BY status',
          readsFrom: {db.messages},
        )
        .get();
    final m = {
      for (final r in rows) r.read<String>('status'): r.read<int>('c'),
    };
    return MessageStats(
      queued: m['queued'] ?? 0,
      sent: m['sent'] ?? 0,
      failed: m['failed'] ?? 0,
      read: m['read'] ?? 0,
    );
  }

  /// د یوه سرپرست صندوق — د والدینو اپ يې راښکي.
  Future<List<Message>> inboxFor(int guardianId, {int limit = 60}) {
    return (db.select(db.messages)
          ..where((m) => m.guardianId.equals(guardianId))
          ..where((m) => m.status.isIn(['sent', 'read']))
          ..orderBy([(m) => OrderingTerm.desc(m.createdAt)])
          ..limit(limit))
        .get();
  }

  Future<int> markRead(List<int> ids) async {
    if (ids.isEmpty) return 0;
    return db.customUpdate(
      "UPDATE messages SET status = 'read', read_at = ? "
      'WHERE id IN (${List.filled(ids.length, '?').join(',')}) '
      "AND status = 'sent'",
      variables: [
        Variable<DateTime>(DateTime.now()),
        ...ids.map(Variable<int>.new),
      ],
      updates: {db.messages},
    );
  }

  // ── داخلي ───────────────────────────────────────────────

  /// هر شاګرد ته يې اصلي سرپرست پیدا کوي.
  ///
  /// **که اصلي سرپرست نه وي ټاکل شوی؟** لومړی موجود اخلو. که هېڅ
  /// سرپرست نه وي، یوه ناکامه کرښه ثبتوو چې مدیر وویني — دا د هغه
  /// شاګرد د ریکارډ نیمګړتیا ده او باید سمه شي، نه چې پټه پاتې شي.
  Future<List<_Recipient>> _recipientsFor(
    List<int> studentIds,
    DateTime day,
  ) async {
    final monthStart = DateTime(day.year, day.month, 1);
    final ph = List.filled(studentIds.length, '?').join(',');

    final rows = await db
        .customSelect(
          '''
SELECT s.id AS student_id,
  s.first_name || COALESCE(' ' || s.last_name, '') AS student_name,
  g.name || ' — ' || sec.name AS class_name,
  gu.id           AS guardian_id,
  gu.full_name    AS guardian_name,
  gu.phone        AS guardian_phone,
  gu.preferred_channel AS channel,
  (SELECT COUNT(*) FROM attendances m
     WHERE m.student_id = s.id AND m.status = 'absent'
       AND m.date >= ? AND m.date <= ?) AS monthly_absences
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
LEFT JOIN student_guardians sg ON sg.student_id = s.id
LEFT JOIN guardians gu ON gu.id = sg.guardian_id
WHERE s.id IN ($ph) AND s.deleted_at IS NULL
ORDER BY s.id, sg.is_primary DESC, gu.id
''',
          variables: [
            Variable<DateTime>(monthStart),
            Variable<DateTime>(day),
            ...studentIds.map(Variable<int>.new),
          ],
          readsFrom: {
            db.students,
            db.enrollments,
            db.sections,
            db.grades,
            db.studentGuardians,
            db.guardians,
            db.attendances,
          },
        )
        .get();

    // د `ORDER BY … is_primary DESC` له امله، د هر شاګرد لومړۍ
    // کرښه يې اصلي سرپرست دی.
    final seen = <int>{};
    final out = <_Recipient>[];
    for (final r in rows) {
      final sid = r.read<int>('student_id');
      if (!seen.add(sid)) continue;

      final gid = r.data['guardian_id'] as int?;
      final phone = r.data['guardian_phone'] as String?;
      var channel = (r.data['channel'] as String?) ?? 'sms';
      // که کانال SMS وي خو شمېره نشته، اپ ته اوړو — که هغه هم نه
      // وي، `_deliver` يې د روښانه لامل سره ناکام ثبتوي.
      if (channel == 'sms' && (phone == null || phone.trim().isEmpty)) {
        channel = 'app';
      }

      out.add(
        _Recipient(
          studentId: sid,
          studentName: r.read<String>('student_name'),
          className: r.data['class_name'] as String?,
          guardianId: gid,
          guardianName: r.data['guardian_name'] as String?,
          phone: phone,
          channel: channel,
          monthlyAbsences: r.data['monthly_absences'] as int? ?? 0,
        ),
      );
    }
    return out;
  }

  static String _isoDate(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}

class _Recipient {
  final int studentId;
  final String studentName;
  final String? className;
  final int? guardianId;
  final String? guardianName;
  final String? phone;
  final String channel;
  final int monthlyAbsences;

  const _Recipient({
    required this.studentId,
    required this.studentName,
    this.className,
    this.guardianId,
    this.guardianName,
    this.phone,
    required this.channel,
    this.monthlyAbsences = 0,
  });
}
