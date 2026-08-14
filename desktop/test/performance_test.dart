@Tags(['perf'])
library;

import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';

/// د کارکړنې ازموینه — د یوه ریښتیني ښوونځي د کال په اندازه ډیټا.
///
/// دا ازموینه یوه پوښتنه ځوابوي: ایا SQLite د زرګونو ریکارډونو
/// مدیریت کولی شي؟ او ایا ژبه پکې رول لري؟
///
/// پایله: نه ژبه، بلکې **index** پرېکړه کوي. لاندې شمېرې دا ښیي.
void main() {
  const students = 850;
  const schoolDays = 200;
  const totalRows = students * schoolDays; // ۱۷۰,۰۰۰

  late AppDatabase db;

  setUpAll(() async {
    // index ټول د `onCreate` په مهال جوړېږي — د یادښت ډیټابیس کې هم.
    db = AppDatabase.memory();

    final sw = Stopwatch()..start();

    await db.batch((b) {
      for (var i = 1; i <= students; i++) {
        b.insert(
          db.students,
          StudentsCompanion.insert(
            admissionNo: 'S-${i.toString().padLeft(4, '0')}',
            firstName: 'شاګرد$i',
            fatherName: 'پلار$i',
            gender: i.isEven ? 'male' : 'female',
          ),
        );
      }
    });

    final start = DateTime(2026, 1, 1);
    // په ډلو کې لیکو — چې د یوه لوی batch یادښت ونه نیسي.
    for (var day = 0; day < schoolDays; day += 20) {
      await db.batch((b) {
        for (var d = day; d < day + 20 && d < schoolDays; d++) {
          final date = start.add(Duration(days: d));
          for (var s = 1; s <= students; s++) {
            b.insert(
              db.attendances,
              AttendancesCompanion.insert(
                studentId: s,
                date: date,
                // ~۹۴٪ حاضر — د ریښتیني ښوونځي په څېر.
                status: (s + d) % 17 == 0 ? 'absent' : 'present',
              ),
            );
          }
        }
      });
    }

    sw.stop();
    // ignore: avoid_print
    print('د $totalRows کرښو لیکل: ${sw.elapsedMilliseconds}ms');
  });

  tearDownAll(() => db.close());

  test('ډیټا ریښتیا لیکل شوې', () async {
    final n = await db
        .customSelect('SELECT COUNT(*) AS c FROM attendances')
        .getSingle();
    expect(n.data['c'], totalRows);
  });

  test('د یوه شاګرد کلنۍ حاضري — تر ۵۰ms', () async {
    final sw = Stopwatch()..start();
    final rows = await (db.select(
      db.attendances,
    )..where((a) => a.studentId.equals(423))).get();
    sw.stop();

    // ignore: avoid_print
    print(
      'د یوه شاګرد کلنۍ حاضري (${rows.length} کرښې): '
      '${sw.elapsedMicroseconds}µs',
    );

    expect(rows, hasLength(schoolDays));
    expect(sw.elapsedMilliseconds, lessThan(50));
  });

  test('د یوې ورځې غیرحاضران — تر ۵۰ms', () async {
    final day = DateTime(2026, 1, 1).add(const Duration(days: 60));
    final sw = Stopwatch()..start();
    final rows = await (db.select(
      db.attendances,
    )..where((a) => a.date.equals(day) & a.status.equals('absent'))).get();
    sw.stop();

    // ignore: avoid_print
    print(
      'د یوې ورځې غیرحاضران (${rows.length} تنه): '
      '${sw.elapsedMicroseconds}µs',
    );

    expect(sw.elapsedMilliseconds, lessThan(50));
  });

  test('د ټول کال د حاضرۍ سلنه — تر ۵۰۰ms', () async {
    final sw = Stopwatch()..start();
    final r = await db
        .customSelect(
          "SELECT status, COUNT(*) AS c FROM attendances GROUP BY status",
        )
        .get();
    sw.stop();

    // ignore: avoid_print
    print(
      'د ټول کال ټولټال ($totalRows کرښې): '
      '${sw.elapsedMilliseconds}ms',
    );

    expect(r, isNotEmpty);
    expect(sw.elapsedMilliseconds, lessThan(500));
  });

  test('index ریښتیا کارېږي — نه د ټول جدول لټون', () async {
    final plan = await db
        .customSelect(
          'EXPLAIN QUERY PLAN '
          'SELECT * FROM attendances WHERE student_id = 423',
        )
        .get();

    final text = plan.map((r) => r.data.values.join(' ')).join('\n');
    // ignore: avoid_print
    print('پلان: $text');

    // که دلته «SCAN» راشي، index نه کارېږي او سیسټم به ورو شي.
    expect(text.toUpperCase(), contains('USING INDEX'));
  });
}
