import 'package:drift/drift.dart';

import '../db/database.dart';

/// د اونۍ هغه ورځې چې درس پکې کېږي.
///
/// **ولې پنجشنبه او جمعه نه؟** په افغانستان کې د اونۍ رخصتي پنجشنبه
/// (۴) او جمعه (۵) ده. دا له `schools.weekend_days` څخه راځي — دلته
/// یوازې تلواله ده.
const List<int> defaultTeachingDays = [6, 7, 1, 2, 3];

/// د ورځې نوم — د Dart `weekday` له مخې (۱=دوشنبه … ۷=یکشنبه).
String weekdayNamePs(int weekday) => switch (weekday) {
  1 => 'دوشنبه',
  2 => 'سه‌شنبه',
  3 => 'چهارشنبه',
  4 => 'پنجشنبه',
  5 => 'جمعه',
  6 => 'شنبه',
  _ => 'یکشنبه',
};

/// د جدول یوه خانه — یو درس له خپلو نومونو سره.
class TimetableCell {
  final TimetableEntry entry;
  final String subjectName;
  final String? teacherName;

  /// هغه کتاب چې مضمون پرې لوستل کېږي — د مدرسې لپاره.
  ///
  /// **دا ولې د استاد نوم پر ځای ښکاري؟** ځکه چې یوه مدرسه د
  /// «فقه» پر ځای «قدوري (صلوة)» ښیي — د درجې تر منځ توپیر کتاب
  /// دی، نه فن. که یوازې فن ښودل کېده، درې درجې به یو شان ښکارېدې.
  final String? book;

  const TimetableCell({
    required this.entry,
    required this.subjectName,
    this.teacherName,
    this.book,
  });

  /// د خانې دویمه کرښه — کتاب که وي، که نه استاد.
  String? get detail => book ?? teacherName;
}

/// د یوه بخش بشپړ اونیز جدول.
class TimetableGrid {
  final List<TimeSlot> slots;
  final List<int> days;

  /// `[dayOfWeek][slotId]` → خانه.
  final Map<int, Map<int, TimetableCell>> cells;

  const TimetableGrid({
    required this.slots,
    required this.days,
    required this.cells,
  });

  TimetableCell? at(int day, int slotId) => cells[day]?[slotId];

  int get filled => cells.values.fold(0, (a, m) => a + m.length);

  /// څومره خانې باید ډکې شي — تفریح نه شمېرل کېږي.
  int get capacity => days.length * slots.where((s) => !s.isBreak).length;
}

/// **د مدرسې جدول** — درجې (کتارونه) × ساعتونه (ستنې).
///
/// **ولې دا له اونیز جدول بېل دی؟**
/// یو مکتب هره ورځ بېل مهالویش لري: د شنبې لومړی ساعت ریاضي، د
/// یکشنبې لومړی ساعت پښتو. یوه مدرسه داسې نه ده — د یوې درجې
/// ترتیب یو ځل جوړېږي او **هره ورځ هماغه** تدریسېږي. که د مدرسې
/// لپاره اونیز جدول کارېده، مدیر به یو ترتیب اوه ځله لیکه، او د
/// یوه کتاب بدلون به يې اوه ځایه سمولو ته اړ کړ.
///
/// نو د مدرسې کرښې «ورځې» نه دي — «درجې» دي. په ډیټابیس کې دا
/// د `day_of_week = 0` په بڼه ساتل کېږي، یعنې «هره ورځ».
class DailyGrid {
  final List<TimeSlot> slots;

  /// هر کتار — یوه درجه او د هغې بخش.
  final List<({int sectionId, String label, int sortOrder})> rows;

  /// `[sectionId][slotId]` → خانه.
  final Map<int, Map<int, TimetableCell>> cells;

  const DailyGrid({
    required this.slots,
    required this.rows,
    required this.cells,
  });

  TimetableCell? at(int sectionId, int slotId) => cells[sectionId]?[slotId];

  int get filled => cells.values.fold(0, (a, m) => a + m.length);

  int get capacity => rows.length * slots.where((s) => !s.isBreak).length;
}

/// **د مدرسې جدول د «هرې ورځې» شمېره.** یو نومول شوی ثابت دی نه
/// یو خام صفر، چې د کوډ لوستونکی ونه ګڼي دا یو تېروتنی دی.
const int everyDay = 0;

/// یو ټکر — یو استاد په یوه وخت کې په دوو ځایونو کې.
class TimetableConflict {
  final int teacherId;
  final String teacherName;
  final int dayOfWeek;
  final int slotId;
  final String slotName;
  final List<String> sections;

  const TimetableConflict({
    required this.teacherId,
    required this.teacherName,
    required this.dayOfWeek,
    required this.slotId,
    required this.slotName,
    required this.sections,
  });
}

sealed class SetEntryResult {
  const SetEntryResult();
}

class SetEntryOk extends SetEntryResult {
  final int entryId;
  const SetEntryOk(this.entryId);
}

/// استاد پر هماغه وخت بل ځای بوخت دی.
class SetEntryTeacherBusy extends SetEntryResult {
  final String teacherName;
  final String otherSection;
  const SetEntryTeacherBusy({
    required this.teacherName,
    required this.otherSection,
  });
}

/// خونه پر هماغه وخت نیول شوې.
class SetEntryRoomBusy extends SetEntryResult {
  final String room;
  final String otherSection;
  const SetEntryRoomBusy({required this.room, required this.otherSection});
}

// ═══════════════════════════════════════════════════════════

class TimetableRepository {
  final AppDatabase db;
  TimetableRepository(this.db);

  // ── ساعتونه ─────────────────────────────────────────────

  Future<List<TimeSlot>> slots() =>
      (db.select(db.timeSlots)
            ..orderBy([(s) => OrderingTerm.asc(s.sortOrder)]))
          .get();

  /// د یوه عادي ښوونځي اته ساعته، له یوې تفریح سره.
  ///
  /// دا یوازې پیل دی — مدیر يې په تنظیماتو کې بدلولی شي.
  Future<void> seedDefaultSlots({
    String dayStart = '07:30',
    int lessonMinutes = 45,
    int lessons = 8,
    int breakAfter = 4,
    int breakMinutes = 20,
  }) async {
    final existing = await db.select(db.timeSlots).get();
    if (existing.isNotEmpty) return;

    final parts = dayStart.split(':');
    var minutes =
        (int.tryParse(parts.first) ?? 7) * 60 +
        (parts.length > 1 ? (int.tryParse(parts[1]) ?? 30) : 30);

    String fmt(int m) =>
        '${(m ~/ 60).toString().padLeft(2, '0')}:'
        '${(m % 60).toString().padLeft(2, '0')}';

    var order = 0;
    for (var i = 1; i <= lessons; i++) {
      await db
          .into(db.timeSlots)
          .insert(
            TimeSlotsCompanion.insert(
              name: '$i ساعت',
              startTime: fmt(minutes),
              endTime: fmt(minutes + lessonMinutes),
              sortOrder: Value(order++),
            ),
          );
      minutes += lessonMinutes;

      if (i == breakAfter) {
        await db
            .into(db.timeSlots)
            .insert(
              TimeSlotsCompanion.insert(
                name: 'تفریح',
                startTime: fmt(minutes),
                endTime: fmt(minutes + breakMinutes),
                isBreak: const Value(true),
                sortOrder: Value(order++),
              ),
            );
        minutes += breakMinutes;
      }
    }
  }

  // ── جدول ────────────────────────────────────────────────

  Future<TimetableGrid> grid({
    required int sectionId,
    List<int>? days,
  }) async {
    final allSlots = await slots();

    final rows = await db
        .customSelect(
          '''
SELECT t.*, sub.name AS subject_name, sub.book AS book,
       tea.full_name AS teacher_name
FROM timetable_entries t
JOIN subjects sub ON sub.id = t.subject_id
LEFT JOIN teachers tea ON tea.id = t.teacher_id
WHERE t.section_id = ? AND t.day_of_week <> ?
''',
          // **د مدرسې کرښې (`day_of_week = 0`) دلته نه راځي.**
          // که راغلې وای، اونیز جدول به يې په هېڅ ستنه کې نه ښودلې
          // خو په «څو خانې ډکې دي» شمېر کې به شمېرل شوې وې — یو
          // شمېر چې له هغه څه سره نه برابرېده چې سترګه يې ویني.
          variables: [Variable<int>(sectionId), const Variable<int>(everyDay)],
          readsFrom: {db.timetableEntries, db.subjects, db.teachers},
        )
        .get();

    final cells = <int, Map<int, TimetableCell>>{};
    for (final r in rows) {
      final entry = db.timetableEntries.map(r.data);
      cells
          .putIfAbsent(entry.dayOfWeek, () => {})
          .putIfAbsent(
            entry.slotId,
            () => TimetableCell(
              entry: entry,
              subjectName: r.read<String>('subject_name'),
              teacherName: r.data['teacher_name'] as String?,
              book: r.data['book'] as String?,
            ),
          );
    }

    return TimetableGrid(
      slots: allSlots,
      days: days ?? defaultTeachingDays,
      cells: cells,
    );
  }

  /// د مدرسې جدول — ټولې درجې په یوه پاڼه کې.
  Future<DailyGrid> dailyGrid({int? academicYearId}) async {
    final allSlots = await slots();

    final sectionRows = await db
        .customSelect(
          '''
SELECT sec.id AS section_id, sec.name AS section_name,
       g.name AS grade_name, g.sort_order AS sort_order, g.level AS level
FROM sections sec
JOIN grades g ON g.id = sec.grade_id
${academicYearId == null ? '' : 'WHERE sec.academic_year_id = ?'}
ORDER BY g.sort_order, g.level, sec.name
''',
          variables: [
            if (academicYearId != null) Variable<int>(academicYearId),
          ],
          readsFrom: {db.sections, db.grades},
        )
        .get();

    final rows = [
      for (final r in sectionRows)
        (
          sectionId: r.read<int>('section_id'),
          // که یوه درجه یوازې یو بخش ولري، د بخش نوم بې‌ګټې تکرار
          // دی — «درجه رابعه — الف» له «درجه رابعه» څخه اوږد دی او
          // څه نه زیاتوي. خو کله چې دوه بخشونه وي، توپیر پکار دی.
          label: sectionRows
                          .where(
                            (x) =>
                                x.read<String>('grade_name') ==
                                r.read<String>('grade_name'),
                          )
                          .length >
                      1
              ? '${r.read<String>('grade_name')} — '
                    '${r.read<String>('section_name')}'
              : r.read<String>('grade_name'),
          sortOrder: r.read<int>('sort_order') * 1000 + r.read<int>('level'),
        ),
    ];

    final entryRows = await db
        .customSelect(
          '''
SELECT t.*, sub.name AS subject_name, sub.book AS book,
       tea.full_name AS teacher_name
FROM timetable_entries t
JOIN subjects sub ON sub.id = t.subject_id
LEFT JOIN teachers tea ON tea.id = t.teacher_id
WHERE t.day_of_week = ?
''',
          variables: [const Variable<int>(everyDay)],
          readsFrom: {db.timetableEntries, db.subjects, db.teachers},
        )
        .get();

    final cells = <int, Map<int, TimetableCell>>{};
    for (final r in entryRows) {
      final entry = db.timetableEntries.map(r.data);
      cells
          .putIfAbsent(entry.sectionId, () => {})
          .putIfAbsent(
            entry.slotId,
            () => TimetableCell(
              entry: entry,
              subjectName: r.read<String>('subject_name'),
              teacherName: r.data['teacher_name'] as String?,
              book: r.data['book'] as String?,
            ),
          );
    }

    return DailyGrid(slots: allSlots, rows: rows, cells: cells);
  }

  /// یوه خانه ډکوي — **مخکې له ذخیره کولو ټکر ګوري**.
  ///
  /// **ولې دا په ریپوزیټوري کې دی، نه په پاڼه کې؟** ځکه چې ټکر یو
  /// د ډیټا قاعده ده، نه د پردې. سبا که مهالویش له API څخه راشي،
  /// هماغه قاعده باید پلې شي — نه دا چې یوازې هغه څوک يې مراعات
  /// کړي چې د پاڼې له لارې راځي.
  Future<SetEntryResult> setEntry({
    required int sectionId,
    required int dayOfWeek,
    required int slotId,
    required int subjectId,
    int? teacherId,
    String? room,
  }) async {
    if (teacherId != null) {
      final clash = await _teacherClash(
        teacherId: teacherId,
        dayOfWeek: dayOfWeek,
        slotId: slotId,
        exceptSectionId: sectionId,
      );
      if (clash != null) {
        return SetEntryTeacherBusy(
          teacherName: clash.$1,
          otherSection: clash.$2,
        );
      }
    }

    if (room != null && room.trim().isNotEmpty) {
      final clash = await _roomClash(
        room: room.trim(),
        dayOfWeek: dayOfWeek,
        slotId: slotId,
        exceptSectionId: sectionId,
      );
      if (clash != null) {
        return SetEntryRoomBusy(room: room.trim(), otherSection: clash);
      }
    }

    final id = await db
        .into(db.timetableEntries)
        .insert(
          TimetableEntriesCompanion.insert(
            sectionId: sectionId,
            dayOfWeek: dayOfWeek,
            slotId: slotId,
            subjectId: subjectId,
            teacherId: Value(teacherId),
            room: Value(room?.trim().isEmpty ?? true ? null : room!.trim()),
          ),
          // د حاضرۍ په څېر: ټکر پر لومړني کلي نه، پر زموږ پر یوځلي
          // کلي دی. پرته له `target` به سمول مات شوی و.
          onConflict: DoUpdate(
            (_) => TimetableEntriesCompanion(
              subjectId: Value(subjectId),
              teacherId: Value(teacherId),
              room: Value(
                room?.trim().isEmpty ?? true ? null : room!.trim(),
              ),
              updatedAt: Value(DateTime.now()),
            ),
            target: [
              db.timetableEntries.sectionId,
              db.timetableEntries.dayOfWeek,
              db.timetableEntries.slotId,
            ],
          ),
        );

    return SetEntryOk(id);
  }

  Future<void> clearEntry({
    required int sectionId,
    required int dayOfWeek,
    required int slotId,
  }) {
    return (db.delete(db.timetableEntries)
          ..where((t) => t.sectionId.equals(sectionId))
          ..where((t) => t.dayOfWeek.equals(dayOfWeek))
          ..where((t) => t.slotId.equals(slotId)))
        .go();
  }

  Future<(String, String)?> _teacherClash({
    required int teacherId,
    required int dayOfWeek,
    required int slotId,
    required int exceptSectionId,
  }) async {
    final row = await db
        .customSelect(
          '''
SELECT tea.full_name AS teacher_name,
       g.name || ' — ' || sec.name AS section_label
FROM timetable_entries t
JOIN teachers tea ON tea.id = t.teacher_id
JOIN sections sec ON sec.id = t.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE t.teacher_id = ? AND t.day_of_week = ? AND t.slot_id = ?
  AND t.section_id <> ?
LIMIT 1
''',
          variables: [
            Variable<int>(teacherId),
            Variable<int>(dayOfWeek),
            Variable<int>(slotId),
            Variable<int>(exceptSectionId),
          ],
          readsFrom: {
            db.timetableEntries,
            db.teachers,
            db.sections,
            db.grades,
          },
        )
        .getSingleOrNull();

    return row == null
        ? null
        : (row.read<String>('teacher_name'), row.read<String>('section_label'));
  }

  Future<String?> _roomClash({
    required String room,
    required int dayOfWeek,
    required int slotId,
    required int exceptSectionId,
  }) async {
    final row = await db
        .customSelect(
          '''
SELECT g.name || ' — ' || sec.name AS section_label
FROM timetable_entries t
JOIN sections sec ON sec.id = t.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE t.room = ? AND t.day_of_week = ? AND t.slot_id = ?
  AND t.section_id <> ?
LIMIT 1
''',
          variables: [
            Variable<String>(room),
            Variable<int>(dayOfWeek),
            Variable<int>(slotId),
            Variable<int>(exceptSectionId),
          ],
          readsFrom: {db.timetableEntries, db.sections, db.grades},
        )
        .getSingleOrNull();

    return row?.read<String>('section_label');
  }

  /// د یوه استاد اونیز جدول — «زه چېرې او کله یم؟».
  Future<List<({int day, TimeSlot slot, String subject, String section})>>
  teacherSchedule(int teacherId) async {
    final rows = await db
        .customSelect(
          '''
SELECT t.day_of_week AS day, t.slot_id AS slot_id,
       sub.name AS subject,
       g.name || ' — ' || sec.name AS section
FROM timetable_entries t
JOIN subjects sub ON sub.id = t.subject_id
JOIN sections sec ON sec.id = t.section_id
JOIN grades g ON g.id = sec.grade_id
WHERE t.teacher_id = ?
''',
          variables: [Variable<int>(teacherId)],
          readsFrom: {
            db.timetableEntries,
            db.subjects,
            db.sections,
            db.grades,
          },
        )
        .get();

    final allSlots = {for (final s in await slots()) s.id: s};
    final out = <({int day, TimeSlot slot, String subject, String section})>[];
    for (final r in rows) {
      final slot = allSlots[r.read<int>('slot_id')];
      if (slot == null) continue;
      out.add((
        day: r.read<int>('day'),
        slot: slot,
        subject: r.read<String>('subject'),
        section: r.read<String>('section'),
      ));
    }
    out.sort((a, b) {
      final d = a.day.compareTo(b.day);
      return d != 0 ? d : a.slot.sortOrder.compareTo(b.slot.sortOrder);
    });
    return out;
  }

  /// د ټول ښوونځي ټکرونه — که مهالویش له بهر څخه راوړل شوی وي.
  Future<List<TimetableConflict>> conflicts() async {
    final rows = await db
        .customSelect(
          '''
SELECT t.teacher_id AS teacher_id, t.day_of_week AS day,
       t.slot_id AS slot_id,
       tea.full_name AS teacher_name,
       sl.name AS slot_name,
       GROUP_CONCAT(g.name || ' — ' || sec.name, ' / ') AS sections,
       COUNT(*) AS c
FROM timetable_entries t
JOIN teachers tea ON tea.id = t.teacher_id
JOIN sections sec ON sec.id = t.section_id
JOIN grades g ON g.id = sec.grade_id
JOIN time_slots sl ON sl.id = t.slot_id
WHERE t.teacher_id IS NOT NULL
GROUP BY t.teacher_id, t.day_of_week, t.slot_id
HAVING c > 1
ORDER BY t.day_of_week, sl.sort_order
''',
          readsFrom: {
            db.timetableEntries,
            db.teachers,
            db.sections,
            db.grades,
            db.timeSlots,
          },
        )
        .get();

    return rows
        .map(
          (r) => TimetableConflict(
            teacherId: r.read<int>('teacher_id'),
            teacherName: r.read<String>('teacher_name'),
            dayOfWeek: r.read<int>('day'),
            slotId: r.read<int>('slot_id'),
            slotName: r.read<String>('slot_name'),
            sections: (r.read<String>('sections')).split(' / '),
          ),
        )
        .toList();
  }

  /// د یوه استاد اونیز بار — د عادلانه ویش لپاره.
  Future<Map<int, int>> teacherLoads() async {
    final rows = await db
        .customSelect(
          'SELECT teacher_id, COUNT(*) AS c FROM timetable_entries '
          'WHERE teacher_id IS NOT NULL GROUP BY teacher_id',
          readsFrom: {db.timetableEntries},
        )
        .get();
    return {
      for (final r in rows) r.read<int>('teacher_id'): r.read<int>('c'),
    };
  }
}
