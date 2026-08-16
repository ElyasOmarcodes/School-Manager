import 'package:drift/drift.dart';

import '../../core/utils/numerals.dart';
import '../db/database.dart';

/// یو کس چې کارت ورته جوړېږي — شاګرد، استاد یا کارمند.
///
/// **ولې یو ګډ ټولګی؟** ځکه چې د کارت له نظره درې واړه یو شان دي:
/// یو نوم، یو نمبر، یو انځور، یوه نېټه. که درې بېل مسیرونه وو، د
/// «د پای نېټه» ځانګړتیا به درې ځله لیکل شوې وه.
class CardHolder {
  /// `student` | `teacher` | `staff`
  final String audience;
  final int id;
  final String idNo;
  final String fullName;
  final String fatherName;

  /// د شاګرد ټولګی، یا د کارکوونکي دنده.
  final String subtitle;
  final String? phone;
  final String? photoPath;
  final String? qrSecret;
  final int cardVersion;
  final DateTime? expiresOn;
  final String status;

  /// د ترتیب لپاره — د بخش id (شاګردان) یا صفر.
  final int groupId;

  const CardHolder({
    required this.audience,
    required this.id,
    required this.idNo,
    required this.fullName,
    required this.cardVersion,
    required this.status,
    this.fatherName = '',
    this.subtitle = '',
    this.phone,
    this.photoPath,
    this.qrSecret,
    this.expiresOn,
    this.groupId = 0,
  });

  bool get hasKey => qrSecret != null && qrSecret!.isNotEmpty;
  bool get hasCard => expiresOn != null;

  bool expiredAt(DateTime now) =>
      expiresOn != null && now.isAfter(expiresOn!);

  /// د کارت حال — د فلټر او نښې لپاره.
  ///
  /// `none` = لا نه دی چاپ شوی، `expired` = وخت يې تېر، `soon` =
  /// له دېرشو ورځو کم پاتې، `valid` = روان.
  String stateAt(DateTime now) {
    if (expiresOn == null) return 'none';
    if (now.isAfter(expiresOn!)) return 'expired';
    return expiresOn!.difference(now).inDays <= 30 ? 'soon' : 'valid';
  }
}

/// د کارتونو ذخیره — کینډۍ، خاوندان او د پای نېټې.
class CardRepository {
  final AppDatabase db;
  CardRepository(this.db);

  // ── خاوندان ─────────────────────────────────────────────

  /// د یوې ډلې خاوندان.
  ///
  /// `state` فلټر د `stateAt` له مخې دی، نو په SQL کې نه کېږي —
  /// «نن» د پوښتنې برخه نه ده، د پرېکړې برخه ده.
  Future<List<CardHolder>> holders({
    required String audience,
    required DateTime now,
    String query = '',
    int? groupId,
    String? state,
  }) async {
    final q = Numerals.toLatin(query.trim());
    final like = '%$q%';

    final rows = <CardHolder>[];

    if (audience == 'student') {
      final r = await db
          .customSelect(
            '''
SELECT s.id, s.admission_no AS id_no, s.first_name, s.last_name,
       s.father_name, s.photo_path, s.qr_secret, s.card_version,
       s.card_expires_on, s.status,
       COALESCE(g.name || ' — ' || sec.name, '') AS subtitle,
       COALESCE(sec.id, 0) AS group_id
FROM students s
LEFT JOIN enrollments e ON e.student_id = s.id AND e.is_active = 1
LEFT JOIN sections sec ON sec.id = e.section_id
LEFT JOIN grades g ON g.id = sec.grade_id
WHERE s.deleted_at IS NULL AND s.status = 'active'
  ${groupId == null ? '' : 'AND sec.id = ?'}
  ${q.isEmpty ? '' : "AND (s.first_name LIKE ? OR s.last_name LIKE ? OR s.admission_no LIKE ?)"}
ORDER BY g.level, sec.name, s.first_name
''',
            variables: [
              if (groupId != null) Variable<int>(groupId),
              if (q.isNotEmpty) ...[
                Variable<String>(like),
                Variable<String>(like),
                Variable<String>(like),
              ],
            ],
            readsFrom: {
              db.students,
              db.enrollments,
              db.sections,
              db.grades,
            },
          )
          .get();
      for (final x in r) {
        rows.add(
          CardHolder(
            audience: 'student',
            id: x.read<int>('id'),
            idNo: x.read<String>('id_no'),
            fullName: [
              x.read<String>('first_name'),
              if ((x.data['last_name'] as String?)?.isNotEmpty ?? false)
                x.read<String>('last_name'),
            ].join(' '),
            fatherName: x.data['father_name'] as String? ?? '',
            subtitle: x.read<String>('subtitle'),
            photoPath: x.data['photo_path'] as String?,
            qrSecret: x.data['qr_secret'] as String?,
            cardVersion: x.data['card_version'] as int? ?? 1,
            expiresOn: _date(x.data['card_expires_on']),
            status: x.data['status'] as String? ?? 'active',
            groupId: x.read<int>('group_id'),
          ),
        );
      }
    } else {
      final table = audience == 'teacher' ? 'teachers' : 'staff_members';
      final titleCol = audience == 'teacher' ? 'specialization' : 'job_title';
      final r = await db
          .customSelect(
            '''
SELECT id, employee_no AS id_no, full_name,
       COALESCE($titleCol, '') AS subtitle, phone, photo_path,
       qr_secret, card_version, card_expires_on, status
FROM $table
WHERE deleted_at IS NULL AND status = 'active'
  ${q.isEmpty ? '' : 'AND (full_name LIKE ? OR employee_no LIKE ?)'}
ORDER BY full_name
''',
            variables: [
              if (q.isNotEmpty) ...[
                Variable<String>(like),
                Variable<String>(like),
              ],
            ],
            readsFrom: {db.teachers, db.staffMembers},
          )
          .get();
      for (final x in r) {
        rows.add(
          CardHolder(
            audience: audience,
            id: x.read<int>('id'),
            idNo: x.read<String>('id_no'),
            fullName: x.read<String>('full_name'),
            subtitle: x.read<String>('subtitle'),
            phone: x.data['phone'] as String?,
            photoPath: x.data['photo_path'] as String?,
            qrSecret: x.data['qr_secret'] as String?,
            cardVersion: x.data['card_version'] as int? ?? 1,
            expiresOn: _date(x.data['card_expires_on']),
            status: x.data['status'] as String? ?? 'active',
          ),
        );
      }
    }

    if (state == null) return rows;
    return rows.where((h) => h.stateAt(now) == state).toList();
  }

  static DateTime? _date(Object? raw) => raw == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(
          (raw as int) * 1000,
          isUtc: true,
        ).toLocal();

  /// **د کارت د پای نېټه ثبتوي.**
  ///
  /// **ولې د چاپ پر مهال، نه د داخلې پر مهال؟** ځکه چې کارت د چاپ
  /// پر مهال زېږېږي. یو شاګرد چې نن داخل شوی خو کارت يې نه دی چاپ
  /// شوی، «کارت نه لري» — نه «یو باطل کارت لري».
  Future<int> issue({
    required String audience,
    required List<int> ids,
    required DateTime expiresOn,
  }) async {
    if (ids.isEmpty) return 0;
    // د جدول نوم له یوه ثابت لیسته راځي، نه له کارنه — نو د
    // نوم دننه کول دلته د انجیکشن لار نه ده.
    final name = switch (audience) {
      'teacher' => 'teachers',
      'staff' => 'staff_members',
      _ => 'students',
    };
    return db.customUpdate(
      'UPDATE $name SET card_expires_on = ? '
      'WHERE id IN (${ids.map((_) => '?').join(',')})',
      variables: [
        Variable<DateTime>(expiresOn),
        for (final id in ids) Variable<int>(id),
      ],
      updates: {db.students, db.teachers, db.staffMembers},
    );
  }

  /// **د روان درسي کال پای** — د کارت تلواله نېټه.
  ///
  /// که هېڅ کال ثبت نه وي، له نن څخه یو کال. یو کارت پرته له نېټې
  /// له کارته بدتر دی.
  Future<DateTime> defaultExpiry(DateTime now) async {
    final row = await db
        .customSelect(
          'SELECT ends_on FROM academic_years WHERE is_current = 1 LIMIT 1',
          readsFrom: {db.academicYears},
        )
        .getSingleOrNull();
    final ends = row == null ? null : _date(row.data['ends_on']);
    if (ends == null || ends.isBefore(now)) {
      return DateTime(now.year + 1, now.month, now.day);
    }
    return ends;
  }

  // ── کینډۍ ───────────────────────────────────────────────

  Future<List<CardTemplate>> templates(String audience) => (db.select(
    db.cardTemplates,
  )
        ..where((t) => t.audience.equals(audience) & t.deletedAt.isNull())
        ..orderBy([
          (t) => OrderingTerm.desc(t.isActive),
          (t) => OrderingTerm.asc(t.name),
        ]))
      .get();

  /// هغه کینډۍ چې اوس کارېږي — که هېڅ نه وي، `null`.
  Future<CardTemplate?> active(String audience) => (db.select(
    db.cardTemplates,
  )..where(
        (t) =>
            t.audience.equals(audience) &
            t.isActive.equals(true) &
            t.deletedAt.isNull(),
      ))
      .getSingleOrNull();

  Future<int> saveTemplate({
    int? id,
    required String name,
    required String audience,
    required String layoutJson,
    double widthMm = 85.6,
    double heightMm = 54.0,
    String orientation = 'landscape',
    bool activate = false,
  }) async {
    return db.transaction(() async {
      final newId = id == null
          ? await db
                .into(db.cardTemplates)
                .insert(
                  CardTemplatesCompanion.insert(
                    name: name,
                    audience: audience,
                    layoutJson: layoutJson,
                    widthMm: Value(widthMm),
                    heightMm: Value(heightMm),
                    orientation: Value(orientation),
                  ),
                )
          : await (db.update(db.cardTemplates)
                      ..where((t) => t.id.equals(id)))
                    .write(
                      CardTemplatesCompanion(
                        name: Value(name),
                        layoutJson: Value(layoutJson),
                        widthMm: Value(widthMm),
                        heightMm: Value(heightMm),
                        orientation: Value(orientation),
                        updatedAt: Value(DateTime.now()),
                      ),
                    ).then((_) => id);

      if (activate) await _activate(newId, audience);
      return newId;
    });
  }

  /// یوه کینډۍ فعالوي — **او نورې غیرفعالوي**.
  ///
  /// یو ښوونځی په یوه وخت کې یوه کینډۍ کاروي. که دوه فعالې وې،
  /// چاپ به نه پوهېده چې کومه واخلي.
  Future<void> activate(int id, String audience) =>
      db.transaction(() => _activate(id, audience));

  Future<void> _activate(int id, String audience) async {
    await (db.update(db.cardTemplates)
          ..where((t) => t.audience.equals(audience)))
        .write(const CardTemplatesCompanion(isActive: Value(false)));
    await (db.update(db.cardTemplates)..where((t) => t.id.equals(id))).write(
      const CardTemplatesCompanion(isActive: Value(true)),
    );
  }

  /// یوه کینډۍ پټوي. **فعاله کینډۍ نه ړنګېږي** — که ړنګه شوې وای،
  /// چاپ به بې‌ډیزاینه پاتې و.
  Future<bool> removeTemplate(int id) async {
    final t = await (db.select(
      db.cardTemplates,
    )..where((x) => x.id.equals(id))).getSingleOrNull();
    if (t == null || t.isActive) return false;
    await (db.update(db.cardTemplates)..where((x) => x.id.equals(id))).write(
      CardTemplatesCompanion(deletedAt: Value(DateTime.now())),
    );
    return true;
  }

  /// یوه کینډۍ کاپي کوي — د «له دې څخه پیل وکړه» لپاره.
  Future<int> duplicate(int id, String newName) async {
    final t = await (db.select(
      db.cardTemplates,
    )..where((x) => x.id.equals(id))).getSingle();
    return db
        .into(db.cardTemplates)
        .insert(
          CardTemplatesCompanion.insert(
            name: newName,
            audience: t.audience,
            layoutJson: t.layoutJson,
            widthMm: Value(t.widthMm),
            heightMm: Value(t.heightMm),
            orientation: Value(t.orientation),
          ),
        );
  }
}
