import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3/sqlite3.dart';

import 'tables/comm_tables.dart';
import 'tables/core_tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Schools,
    AppUsers,
    AcademicYears,
    Grades,
    Sections,
    Subjects,
    Students,
    Guardians,
    StudentGuardians,
    Teachers,
    StaffMembers,
    Enrollments,
    Attendances,
    LeaveRequests,
    AuditLogs,
    // ── څلورم پړاو: اړیکه ─────────────────────────────────
    Devices,
    PairingCodes,
    MessageTemplates,
    Messages,
    AppNotifications,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// د ټاکل شوي مسیر څخه ډیټابیس پرانیزي.
  ///
  /// دلته یو مهم تنظیم دی: **WAL**. له هغې پرته، کله چې د حاضرۍ
  /// پاڼه لیکي، رپوټ نه شي لوستلی. له WAL سره دواړه یو ځای کار کوي.
  factory AppDatabase.atPath(String dbPath) {
    return AppDatabase(
      NativeDatabase(
        File(dbPath),
        setup: (raw) {
          raw.execute('PRAGMA journal_mode = WAL;');
          raw.execute('PRAGMA foreign_keys = ON;');
          // د ډیسک لیکل لږ ځله — د حاضرۍ د ډله‌ییز ثبت لپاره ګړندی.
          raw.execute('PRAGMA synchronous = NORMAL;');
          // ۶۴MB کیش — د زرګونو کرښو د جدولونو لپاره.
          raw.execute('PRAGMA cache_size = -64000;');
          raw.execute('PRAGMA busy_timeout = 5000;');
        },
      ),
    );
  }

  /// د یادښت دننه ډیټابیس — یوازې د ازموینو لپاره.
  factory AppDatabase.memory() => AppDatabase(
    NativeDatabase.memory(
      setup: (raw) {
        raw.execute('PRAGMA foreign_keys = ON;');
      },
    ),
  );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createIndexes();
    },
    onUpgrade: (m, from, to) async {
      // ── ۱ → ۲: د اړیکې جدولونه ──────────────────────────
      // دا ښوونځی ښايي نیم کال کار کړی وي؛ د شاګردانو او حاضرۍ
      // ډیټا باید سالمه پاتې شي. نو یوازې نوي جدولونه زیاتوو —
      // زاړه نه لمسوو.
      if (from < 2) {
        await m.createTable(devices);
        await m.createTable(pairingCodes);
        await m.createTable(messageTemplates);
        await m.createTable(messages);
        await m.createTable(appNotifications);
      }
      await _createIndexes();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON;');
    },
  );

  /// **دا هغه برخه ده چې د سرعت پرېکړه کوي** — نه ژبه.
  ///
  /// د ۸۵۰ شاګردانو په یوه کال کې ~۱۷۰,۰۰۰ د حاضرۍ کرښې جوړېږي.
  /// له دې index څخه پرته، «د احمد د میاشتې حاضري» ټول جدول لټوي.
  /// له index سره، ځواب په څو ملي‌ثانیو کې راځي.
  Future<void> _createIndexes() async {
    const stmts = [
      // حاضري — تر ټولو دروند جدول.
      'CREATE INDEX IF NOT EXISTS ix_att_student_date '
          'ON attendances (student_id, date DESC)',
      'CREATE INDEX IF NOT EXISTS ix_att_date_status '
          'ON attendances (date, status)',
      'CREATE INDEX IF NOT EXISTS ix_att_section_date '
          'ON attendances (section_id, date)',
      // هغه غیرحاضران چې لا خبر نه دي شوي — د خبرتیا لپاره.
      'CREATE INDEX IF NOT EXISTS ix_att_pending_notify '
          'ON attendances (date, parent_notified) '
          'WHERE status = \'absent\'',

      // شاګردان — لټون او لیستونه.
      'CREATE INDEX IF NOT EXISTS ix_students_admission '
          'ON students (admission_no)',
      'CREATE INDEX IF NOT EXISTS ix_students_status '
          'ON students (status) WHERE deleted_at IS NULL',
      'CREATE INDEX IF NOT EXISTS ix_students_name '
          'ON students (first_name, last_name)',

      // ثبت — «د دې بخش شاګردان» تر ټولو ډېر پوښتل کېږي.
      'CREATE INDEX IF NOT EXISTS ix_enroll_section '
          'ON enrollments (section_id, is_active)',
      'CREATE INDEX IF NOT EXISTS ix_enroll_student '
          'ON enrollments (student_id, academic_year_id)',

      // اجازت نامې — د حاضرۍ ماشین دا په هره سکین کې پوښتي،
      // نو باید ډېر ګړندی وي.
      'CREATE INDEX IF NOT EXISTS ix_leave_student_range '
          'ON leave_requests (student_id, from_date, to_date, status)',
      'CREATE INDEX IF NOT EXISTS ix_leave_status '
          'ON leave_requests (status, from_date)',

      // سرپرستان.
      'CREATE INDEX IF NOT EXISTS ix_sg_student '
          'ON student_guardians (student_id)',

      // تفتیش.
      'CREATE INDEX IF NOT EXISTS ix_audit_at ON audit_logs (at DESC)',
      'CREATE INDEX IF NOT EXISTS ix_audit_entity '
          'ON audit_logs (entity, entity_id)',

      // ── اړیکه ─────────────────────────────────────────────
      // هر API غوښتنه له توکن سره راځي — دا لټون باید فوري وي.
      'CREATE INDEX IF NOT EXISTS ix_devices_token '
          'ON devices (token_hash) WHERE revoked_at IS NULL',
      'CREATE INDEX IF NOT EXISTS ix_devices_guardian '
          'ON devices (guardian_id)',
      'CREATE INDEX IF NOT EXISTS ix_pairing_code '
          'ON pairing_codes (code) WHERE used_at IS NULL',

      // د پیغامونو لیست او د بیا-هڅې قطار.
      'CREATE INDEX IF NOT EXISTS ix_msg_created '
          'ON messages (created_at DESC)',
      'CREATE INDEX IF NOT EXISTS ix_msg_status '
          'ON messages (status, created_at)',
      'CREATE INDEX IF NOT EXISTS ix_msg_guardian '
          'ON messages (guardian_id, created_at DESC)',
      'CREATE INDEX IF NOT EXISTS ix_msg_student_date '
          'ON messages (student_id, related_date)',

      // د مدیر د اپ صندوق.
      'CREATE INDEX IF NOT EXISTS ix_notif_inbox '
          'ON app_notifications (audience, created_at DESC)',
    ];
    for (final s in stmts) {
      await customStatement(s);
    }
  }

  /// د ډیټابیس روغتیا کتنه — د مسیر بدلولو مخکې او وروسته کارېږي.
  Future<bool> integrityOk() async {
    final rows = await customSelect('PRAGMA integrity_check').get();
    if (rows.isEmpty) return false;
    return rows.first.data.values.first.toString().toLowerCase() == 'ok';
  }

  /// د WAL فایل اصلي ډیټابیس ته ننباسي — مخکې له بیک‌اپ یا کاپي.
  Future<void> checkpoint() async {
    await customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
  }
}

/// د ډیټابیس د فایل جوړول/کتل — پرته له دې چې drift پرانیزي.
///
/// د ویزارډ لپاره پکار دی: مخکې له دې چې کارن «جوړ کړه» ووهي،
/// باید وګورو چې دا فایل لا موجود دی که نه.
class DatabaseFile {
  static const fileName = 'school.db';

  /// ازمويي چې دا فایل ریښتیا یو SQLite ډیټابیس دی —
  /// چې کارن تېروتنې سره کوم بل فایل ونه ټاکي.
  static bool isValidSqlite(String path) {
    final f = File(path);
    if (!f.existsSync()) return false;
    try {
      final db = sqlite3.open(path, mode: OpenMode.readOnly);
      try {
        final r = db.select('PRAGMA integrity_check');
        return r.isNotEmpty &&
            r.first.values.first.toString().toLowerCase() == 'ok';
      } finally {
        db.dispose();
      }
    } catch (_) {
      return false;
    }
  }
}
