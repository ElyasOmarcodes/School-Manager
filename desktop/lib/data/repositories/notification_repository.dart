import 'dart:convert';

import 'package:drift/drift.dart';

import '../db/database.dart';
import 'attendance_repository.dart' show dateOnly;

/// د خبرتیا هغه برخه چې تڼۍ ورباندې ولاړه ده.
class AbsenceDigest {
  final AppNotification notification;
  final DateTime date;
  final List<int> studentIds;
  final int total;

  const AbsenceDigest({
    required this.notification,
    required this.date,
    required this.studentIds,
    required this.total,
  });
}

/// د اپونو د خبرتیا صندوق.
///
/// **دا د پیغام څخه څه توپیر لري؟** پیغام د ښوونځي څخه والدینو ته
/// ځي — هغه یو تللی شی دی. خبرتیا مدیر ته ځي او **پرېکړې ته بلنه**
/// ده: «نن ۴۷ تنه غیرحاضر دي — ایا والدینو ته پیغام ولېږم؟» نو
/// خبرتیا `actedAt` لري، پیغام يې نه لري.
class NotificationRepository {
  final AppDatabase db;
  NotificationRepository(this.db);

  /// خبرتیا زیاتوي، یا که هماغه `dedupeKey` مخکې شته وي، تازه يې کوي.
  ///
  /// **ولې تازه، نه نوې؟** د ورځې په اوږدو کې د غیرحاضرو شمېر
  /// بدلېږي — ساعت ۸ کې ۶۰ تنه، ساعت ۱۰ کې ۴۷ (نور ناوخته راغلل).
  /// که هره کتنه نوې خبرتیا جوړه کړي، د مدیر تلیفون به د یوې ورځې
  /// لپاره لسګونه خبرتیاوې وښیي.
  Future<AppNotification> push({
    required String kind,
    required String title,
    required String body,
    String audience = 'manager',
    int? guardianId,
    Map<String, Object?>? payload,
    String? dedupeKey,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final json = payload == null ? null : jsonEncode(payload);

    if (dedupeKey != null) {
      final existing =
          await (db.select(db.appNotifications)
                ..where((n) => n.dedupeKey.equals(dedupeKey))
                ..limit(1))
              .getSingleOrNull();

      if (existing != null) {
        await (db.update(
          db.appNotifications,
        )..where((n) => n.id.equals(existing.id))).write(
          AppNotificationsCompanion(
            title: Value(title),
            body: Value(body),
            payloadJson: Value(json),
            updatedAt: Value(at),
            // که متن بدل شو، بیا يې نالوستې ګڼو — خو که مدیر
            // مخکې پرې کار کړی وي (`actedAt`)، نو بیا يې نه راپاروو.
            readAt: Value(existing.actedAt != null ? existing.readAt : null),
          ),
        );
        return (db.select(
          db.appNotifications,
        )..where((n) => n.id.equals(existing.id))).getSingle();
      }
    }

    final id = await db
        .into(db.appNotifications)
        .insert(
          AppNotificationsCompanion.insert(
            kind: kind,
            title: title,
            body: body,
            audience: Value(audience),
            guardianId: Value(guardianId),
            payloadJson: Value(json),
            dedupeKey: Value(dedupeKey),
            createdAt: Value(at),
            updatedAt: Value(at),
          ),
        );

    return (db.select(
      db.appNotifications,
    )..where((n) => n.id.equals(id))).getSingle();
  }

  /// **د څلورم پړاو زړه.**
  ///
  /// د ورځې غیرحاضران شمېري او که څوک وي چې لا يې والدینو ته پیغام
  /// نه دی تللی، د مدیر اپ ته خبرتیا جوړوي. که هېڅوک نه وي، هغه
  /// خبرتیا چې مخکې جوړه شوې وه، «شوې» نښه کېږي — چې د مدیر په
  /// تلیفون کې زړه خبرتیا پاتې نه شي.
  Future<AbsenceDigest?> syncAbsenceDigest({
    required DateTime date,
    String? schoolName,
    DateTime? now,
  }) async {
    final day = dateOnly(date);
    final key = 'absence_digest:${_iso(day)}';

    final rows = await db
        .customSelect(
          '''
SELECT a.student_id AS student_id,
  s.first_name || COALESCE(' ' || s.last_name, '') AS name
FROM attendances a
JOIN students s ON s.id = a.student_id AND s.deleted_at IS NULL
WHERE a.date = ? AND a.status = 'absent' AND a.parent_notified = 0
ORDER BY s.first_name
''',
          variables: [Variable<DateTime>(day)],
          readsFrom: {db.attendances, db.students},
        )
        .get();

    if (rows.isEmpty) {
      await (db.update(db.appNotifications)
            ..where((n) => n.dedupeKey.equals(key))
            ..where((n) => n.actedAt.isNull()))
          .write(AppNotificationsCompanion(actedAt: Value(now ?? DateTime.now())));
      return null;
    }

    final ids = rows.map((r) => r.read<int>('student_id')).toList();
    final names = rows.map((r) => r.read<String>('name')).toList();

    // متن باید یو نظر کې پوه شي — نو تر دریو نومونو، بیا «او نور».
    final preview = names.take(3).join('، ');
    final body = names.length <= 3
        ? '$preview غیرحاضر ${names.length == 1 ? 'دی' : 'دي'}. '
              'ایا غواړئ والدینو ته پیغام ولېږئ؟'
        : '$preview او ${names.length - 3} نور نور غیرحاضر دي. '
              'ایا غواړئ والدینو ته پیغام ولېږئ؟';

    final n = await push(
      kind: 'absence_digest',
      title: '${names.length} تنه نن غیرحاضر دي',
      body: body,
      dedupeKey: key,
      payload: {
        'date': _iso(day),
        'studentIds': ids,
        'count': ids.length,
        if (schoolName != null) 'school': schoolName,
      },
      now: now,
    );

    return AbsenceDigest(
      notification: n,
      date: day,
      studentIds: ids,
      total: ids.length,
    );
  }

  /// د یوې نوې اجازې غوښتنې خبرتیا — د والدینو له اپ څخه راځي.
  Future<AppNotification> leaveRequested({
    required int leaveId,
    required String studentName,
    required DateTime fromDate,
    required DateTime toDate,
  }) {
    return push(
      kind: 'leave_request',
      title: 'د رخصتۍ نوې غوښتنه',
      body:
          'د $studentName لپاره له ${_iso(fromDate)} تر ${_iso(toDate)} '
          'د رخصتۍ غوښتنه راغلې.',
      dedupeKey: 'leave_request:$leaveId',
      payload: {'leaveId': leaveId, 'student': studentName},
    );
  }

  Future<List<AppNotification>> inbox({
    String audience = 'manager',
    int? guardianId,
    bool unreadOnly = false,
    int limit = 60,
  }) {
    final q = db.select(db.appNotifications)
      ..where((n) => n.audience.equals(audience))
      ..orderBy([
        // نالوستې لومړی — مدیر باید سکرول ونه کړي چې نوې پیدا کړي.
        (n) => OrderingTerm.asc(n.readAt),
        (n) => OrderingTerm.desc(n.updatedAt),
      ])
      ..limit(limit);
    if (guardianId != null) q.where((n) => n.guardianId.equals(guardianId));
    if (unreadOnly) q.where((n) => n.readAt.isNull());
    return q.get();
  }

  Future<int> unreadCount({String audience = 'manager'}) async {
    final r = await db
        .customSelect(
          'SELECT COUNT(*) AS c FROM app_notifications '
          'WHERE audience = ? AND read_at IS NULL',
          variables: [Variable<String>(audience)],
          readsFrom: {db.appNotifications},
        )
        .getSingle();
    return r.read<int>('c');
  }

  Future<void> markRead(int id) =>
      (db.update(db.appNotifications)..where((n) => n.id.equals(id))).write(
        AppNotificationsCompanion(readAt: Value(DateTime.now())),
      );

  Future<void> markActed(int id) =>
      (db.update(db.appNotifications)..where((n) => n.id.equals(id))).write(
        AppNotificationsCompanion(
          actedAt: Value(DateTime.now()),
          readAt: Value(DateTime.now()),
        ),
      );

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}
