import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:school_manager/data/db/backup.dart';
import 'package:school_manager/data/db/database.dart';

void main() {
  late Directory work;
  late String dbPath;
  late String backupDir;
  late AppDatabase db;

  setUp(() async {
    work = await Directory.systemTemp.createTemp('sm-backup-');
    dbPath = p.join(work.path, 'school.db');
    backupDir = p.join(work.path, 'backups');
    db = AppDatabase.atPath(dbPath);

    // یو ریکارډ لیکو چې ډیټابیس واقعاً جوړ شي.
    await db
        .into(db.schools)
        .insert(SchoolsCompanion.insert(name: 'د نور لیسه'));
  });

  tearDown(() async {
    await db.close();
    if (await work.exists()) await work.delete(recursive: true);
  });

  // ═════════════════════════════════════════════════════════

  test('بیک‌اپ جوړېږي او سالم SQLite فایل دی', () async {
    final r = await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: backupDir,
    );

    expect(r, isA<BackupOk>());
    final file = (r as BackupOk).file;
    expect(File(file.path).existsSync(), isTrue);
    expect(DatabaseFile.isValidSqlite(file.path), isTrue);
    expect(file.bytes, greaterThan(0));
  });

  test('**وروستي بدلونونه پکې دي** — WAL چیک‌پاینټ کار کوي', () async {
    // دا هغه ازموینه ده چې زما اصلي اندېښنه ازمويي: که WAL
    // چیک‌پاینټ نه وای، دا کرښه به له بیک‌اپ څخه بهر پاتې وه.
    await db
        .into(db.students)
        .insert(
          StudentsCompanion.insert(
            admissionNo: '1405-0001',
            firstName: 'احمد',
            fatherName: 'پلار',
            gender: 'male',
          ),
        );

    final r = await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: backupDir,
    );
    final path = (r as BackupOk).file.path;

    // بیک‌اپ پرانیزو او ګورو چې شاګرد پکې شته.
    final restored = AppDatabase.atPath(path);
    addTearDown(restored.close);

    final students = await restored.select(restored.students).get();
    expect(students, hasLength(1));
    expect(students.first.firstName, 'احمد');
  });

  test('د ښوونځي نوم هم په بیک‌اپ کې دی', () async {
    final r = await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: backupDir,
    );
    final restored = AppDatabase.atPath((r as BackupOk).file.path);
    addTearDown(restored.close);

    final school = await restored.select(restored.schools).getSingle();
    expect(school.name, 'د نور لیسه');
  });

  test('نه‌موجود ډیټابیس روښانه پیغام راکوي، نه استثنا', () async {
    final r = await DatabaseBackup.create(
      db: db,
      databasePath: p.join(work.path, 'nope.db'),
      targetDir: backupDir,
    );
    expect(r, isA<BackupFailed>());
    expect((r as BackupFailed).reason, contains('ونه موندل'));
  });

  test('د بیک‌اپونو لیست نوی مخکې ترتیبوي', () async {
    for (var i = 0; i < 3; i++) {
      await DatabaseBackup.create(
        db: db,
        databasePath: dbPath,
        targetDir: backupDir,
        now: DateTime(2026, 5, 10 + i, 8),
      );
    }

    final list = await DatabaseBackup.list(backupDir);
    expect(list, hasLength(3));
    for (var i = 1; i < list.length; i++) {
      expect(
        list[i - 1].takenAt.isAfter(list[i].takenAt) ||
            list[i - 1].takenAt.isAtSameMomentAs(list[i].takenAt),
        isTrue,
      );
    }
  });

  test('د نوم بڼه د نېټې له مخې ده', () async {
    final r = await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: backupDir,
      now: DateTime(2026, 5, 12, 9, 30, 5),
    );
    expect((r as BackupOk).file.name, 'school-backup-20260512-093005.db');
  });

  test('زاړه بیک‌اپونه پاکېږي، وروستي پاتې کېږي', () async {
    for (var i = 0; i < 8; i++) {
      await DatabaseBackup.create(
        db: db,
        databasePath: dbPath,
        targetDir: backupDir,
        now: DateTime(2026, 5, 1 + i, 8),
      );
    }

    final removed = await DatabaseBackup.prune(backupDir, keep: 5);
    expect(removed, 3);

    final left = await DatabaseBackup.list(backupDir);
    expect(left, hasLength(5));
    // وروستی باید پاتې وي.
    expect(left.first.name, contains('20260508'));
  });

  test('که شمېر تر کچې لږ وي، هېڅ نه پاکېږي', () async {
    await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: backupDir,
    );
    expect(await DatabaseBackup.prune(backupDir, keep: 30), 0);
    expect(await DatabaseBackup.list(backupDir), hasLength(1));
  });

  test('نه‌موجوده پوښۍ تشه لیسټ راګرځوي، نه ماتېږي', () async {
    final list = await DatabaseBackup.list(p.join(work.path, 'nowhere'));
    expect(list, isEmpty);
  });

  test('بې‌ربطه فایلونه له لیسټ څخه بهر پاتې کېږي', () async {
    await Directory(backupDir).create(recursive: true);
    await File(p.join(backupDir, 'notes.txt')).writeAsString('سلام');
    await File(p.join(backupDir, 'other.db')).writeAsString('x');

    await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: backupDir,
    );

    final list = await DatabaseBackup.list(backupDir);
    expect(list, hasLength(1));
    expect(list.first.name.startsWith(DatabaseBackup.prefix), isTrue);
  });

  test('د پوښۍ نه‌شتون خپله جوړېږي', () async {
    final deep = p.join(work.path, 'a', 'b', 'c');
    final r = await DatabaseBackup.create(
      db: db,
      databasePath: dbPath,
      targetDir: deep,
    );
    expect(r, isA<BackupOk>());
    expect(Directory(deep).existsSync(), isTrue);
  });

  test('اندازه د لوستلو وړ بڼه لري', () {
    final at = DateTime(2026, 5, 12);
    expect(BackupFile(path: 'x', takenAt: at, bytes: 512).sizeLabel, '512 B');
    expect(BackupFile(path: 'x', takenAt: at, bytes: 4096).sizeLabel, '4 KB');
    expect(
      BackupFile(path: 'x', takenAt: at, bytes: 3 * 1024 * 1024).sizeLabel,
      '3.0 MB',
    );
  });
}
