import 'package:drift/drift.dart';

import '../db/database.dart';
import 'attendance_repository.dart' show dateOnly;

/// د رخصتۍ ډولونه — د رنګ او د ډله‌بندۍ لپاره.
const List<({String key, String label})> holidayKinds = [
  (key: 'official', label: 'رسمي'),
  (key: 'religious', label: 'دیني/اختر'),
  (key: 'weather', label: 'د هوا له امله'),
  (key: 'exam', label: 'د ازموینو رخصتي'),
  (key: 'other', label: 'بل'),
];

String holidayKindLabel(String key) =>
    holidayKinds.where((k) => k.key == key).firstOrNull?.label ?? key;

/// **د ښوونځي د رخصتیو ذخیره.**
///
/// دوه پوښتنې ځوابوي، او دواړه مهمې دي:
///
///   ۱. «آیا **نن** رخصتي ده؟» — د حاضرۍ پاڼه يې پوښتي، مخکې له
///      دې چې درې سوه نومونه ښکاره کړي.
///   ۲. «د دې میاشتې څو ورځې درسي وې؟» — رپوټونه يې پوښتي، ځکه چې
///      سلنه پرته له دې غلطه ده.
class HolidayRepository {
  final AppDatabase db;
  HolidayRepository(this.db);

  Future<List<Holiday>> all() =>
      (db.select(db.holidays)
            ..where((h) => h.deletedAt.isNull())
            ..orderBy([(h) => OrderingTerm.asc(h.fromDate)]))
          .get();

  /// د یوې مودې رخصتۍ — د کلیز د پاڼې لپاره.
  ///
  /// **کلنۍ رخصتۍ جلا راځي**، ځکه چې د هغوی کال بې‌معنا دی: یوه
  /// کرښه چې ۲۰۲۶ کې ثبت شوې، ۲۰۲۷ کې هم پلې کېږي.
  Future<List<Holiday>> between(DateTime from, DateTime to) async {
    final rows = await all();
    final a = dateOnly(from);
    final b = dateOnly(to);
    return rows.where((h) => _overlaps(h, a, b)).toList();
  }

  bool _overlaps(Holiday h, DateTime a, DateTime b) {
    if (!h.isAnnual) {
      return !h.toDate.isBefore(a) && !h.fromDate.isAfter(b);
    }
    // کلنۍ: هر کال يې پر همغو نېټو راځي. د لټون د مودې هر کال
    // ازمویو — یوه موده معمولاً یو یا دوه کاله نیسي.
    for (var y = a.year; y <= b.year; y++) {
      final from = DateTime(y, h.fromDate.month, h.fromDate.day);
      final to = DateTime(y, h.toDate.month, h.toDate.day);
      if (!to.isBefore(a) && !from.isAfter(b)) return true;
    }
    return false;
  }

  /// **آیا دا ورځ رخصتي ده؟** که وي، هغه کرښه راګرځوي.
  Future<Holiday?> on(DateTime day) async {
    final d = dateOnly(day);
    for (final h in await all()) {
      if (covers(h, d)) return h;
    }
    return null;
  }

  /// د یوې مودې د ټولو رخصت ورځو ټولګه — د رپوټونو لپاره.
  Future<Set<DateTime>> daysBetween(DateTime from, DateTime to) async {
    final a = dateOnly(from);
    final b = dateOnly(to);
    final out = <DateTime>{};
    final rows = await all();
    for (var d = a; !d.isAfter(b); d = d.add(const Duration(days: 1))) {
      if (rows.any((h) => covers(h, d))) out.add(d);
    }
    return out;
  }

  /// آیا دا رخصتي دا ورځ نیسي؟ — د کلیز پاڼه يې هم کاروي.
  static bool covers(Holiday h, DateTime d) {
    if (!h.isAnnual) {
      return !d.isBefore(dateOnly(h.fromDate)) &&
          !d.isAfter(dateOnly(h.toDate));
    }
    final from = DateTime(d.year, h.fromDate.month, h.fromDate.day);
    var to = DateTime(d.year, h.toDate.month, h.toDate.day);
    // یوه کلنۍ رخصتي چې د کال له پایه اوړي — «۲۹ کب تر ۲ حمل».
    if (to.isBefore(from)) to = DateTime(d.year + 1, to.month, to.day);
    return !d.isBefore(from) && !d.isAfter(to);
  }

  // ── لیکل ────────────────────────────────────────────────

  Future<int> add({
    required String name,
    required DateTime fromDate,
    required DateTime toDate,
    String kind = 'official',
    String? note,
    bool isAnnual = false,
    int? byUserId,
  }) {
    // **پیل او پای پخپله سمېږي.** که کارن پای مخکې له پیله وټاکي،
    // یوه تشه موده به جوړه شوې وای چې هېڅ ورځ يې نه نیوله — او
    // کارن به نه پوهېده ولې رخصتي کار نه کوي.
    final a = dateOnly(fromDate);
    final b = dateOnly(toDate);
    return db
        .into(db.holidays)
        .insert(
          HolidaysCompanion.insert(
            name: name.trim(),
            fromDate: a.isAfter(b) ? b : a,
            toDate: a.isAfter(b) ? a : b,
            kind: Value(kind),
            note: Value(note?.trim().isEmpty ?? true ? null : note!.trim()),
            isAnnual: Value(isAnnual),
            createdByUserId: Value(byUserId),
          ),
        );
  }

  Future<void> update({
    required int id,
    String? name,
    DateTime? fromDate,
    DateTime? toDate,
    String? kind,
    String? note,
    bool? isAnnual,
  }) {
    DateTime? a = fromDate == null ? null : dateOnly(fromDate);
    DateTime? b = toDate == null ? null : dateOnly(toDate);
    if (a != null && b != null && a.isAfter(b)) {
      final t = a;
      a = b;
      b = t;
    }
    return (db.update(db.holidays)..where((h) => h.id.equals(id))).write(
      HolidaysCompanion(
        name: name == null ? const Value.absent() : Value(name.trim()),
        fromDate: a == null ? const Value.absent() : Value(a),
        toDate: b == null ? const Value.absent() : Value(b),
        kind: kind == null ? const Value.absent() : Value(kind),
        note: note == null
            ? const Value.absent()
            : Value(note.trim().isEmpty ? null : note.trim()),
        isAnnual: isAnnual == null ? const Value.absent() : Value(isAnnual),
      ),
    );
  }

  /// ړنګول = پټول، چې زاړه رپوټونه خپل حال ونه بایلي.
  Future<void> remove(int id) =>
      (db.update(db.holidays)..where((h) => h.id.equals(id))).write(
        HolidaysCompanion(deletedAt: Value(DateTime.now())),
      );

  /// **د افغانستان عام رخصتۍ** — یو ځل، د لومړي ران لپاره.
  ///
  /// وړاندیز دی، نه بندیز: مدیر يې سموي یا ړنګوي. خو یو تش کلیز
  /// له یوه ډک کلیز څخه بدتر دی — هغه کارن ته نه وايي چې دلته څه
  /// کېږي.
  Future<void> seedDefaults() async {
    if ((await db.select(db.holidays).get()).isNotEmpty) return;

    const list = <(String, int, int, int, int, String)>[
      ('د کوچني اختر رخصتي', 3, 20, 3, 23, 'religious'),
      ('د لوی اختر رخصتي', 5, 27, 5, 31, 'religious'),
      ('د استقلال ورځ', 8, 19, 8, 19, 'official'),
      ('د عاشورا ورځ', 6, 26, 6, 26, 'religious'),
      ('د میلاد النبي ﷺ ورځ', 9, 4, 9, 4, 'religious'),
      ('د ژمي رخصتۍ', 12, 21, 12, 31, 'official'),
    ];

    final year = DateTime.now().year;
    for (final (name, m1, d1, m2, d2, kind) in list) {
      await db
          .into(db.holidays)
          .insert(
            HolidaysCompanion.insert(
              name: name,
              fromDate: DateTime(year, m1, d1),
              toDate: DateTime(year, m2, d2),
              kind: Value(kind),
              isAnnual: const Value(true),
            ),
          );
    }
  }
}
