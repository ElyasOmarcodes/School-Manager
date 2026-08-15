import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/timetable_repository.dart';

void main() {
  late AppDatabase db;
  late TimetableRepository tt;
  late AcademicRepository academic;

  late int mathId;
  late int pashtoId;
  late int teacherA;
  late int teacherB;
  late int section10a;
  late int section10b;
  late List<TimeSlot> slots;

  setUp(() async {
    db = AppDatabase.memory();
    tt = TimetableRepository(db);
    academic = AcademicRepository(db);

    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026, 1, 1),
      endsOn: DateTime(2026, 12, 31),
    );
    await academic.seedDefaultSubjects();
    await tt.seedDefaultSlots();

    final subjects = await academic.subjects();
    mathId = subjects.firstWhere((s) => s.name == 'ریاضي').id;
    pashtoId = subjects.firstWhere((s) => s.name == 'پښتو').id;

    teacherA = await db
        .into(db.teachers)
        .insert(
          TeachersCompanion.insert(
            employeeNo: 'T-0001',
            fullName: 'استاد احمد',
            gender: 'male',
          ),
        );
    teacherB = await db
        .into(db.teachers)
        .insert(
          TeachersCompanion.insert(
            employeeNo: 'T-0002',
            fullName: 'استاد کریم',
            gender: 'male',
          ),
        );

    final sections = await academic.sections();
    final tenth = sections.where((s) => s.level == 10).toList();
    section10a = tenth[0].sectionId;
    section10b = tenth[1].sectionId;

    slots = await tt.slots();
  });

  tearDown(() => db.close());

  TimeSlot lesson(int index) =>
      slots.where((s) => !s.isBreak).elementAt(index);

  // ═════════════════════════════════════════════════════════

  group('ساعتونه', () {
    test('اته درسي ساعته او یوه تفریح جوړېږي', () {
      expect(slots.where((s) => !s.isBreak), hasLength(8));
      expect(slots.where((s) => s.isBreak), hasLength(1));
    });

    test('وختونه پرله‌پسې دي — یو د بل پر پای پیلېږي', () {
      for (var i = 1; i < slots.length; i++) {
        expect(slots[i].startTime, slots[i - 1].endTime);
      }
      expect(slots.first.startTime, '07:30');
    });

    test('تفریح د څلورم ساعت وروسته ده', () {
      final breakIndex = slots.indexWhere((s) => s.isBreak);
      expect(slots.take(breakIndex).where((s) => !s.isBreak), hasLength(4));
    });

    test('دوه ځله کرل نوي ساعتونه نه جوړوي', () async {
      await tt.seedDefaultSlots();
      expect(await tt.slots(), hasLength(slots.length));
    });
  });

  group('د جدول ډکول', () {
    test('یو درس ثبتېږي او په جدول کې ښکاري', () async {
      final r = await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
        room: '۱۰۱',
      );
      expect(r, isA<SetEntryOk>());

      final grid = await tt.grid(sectionId: section10a);
      final cell = grid.at(6, lesson(0).id);
      expect(cell, isNotNull);
      expect(cell!.subjectName, 'ریاضي');
      expect(cell.teacherName, 'استاد احمد');
    });

    test('هماغه خانه بیا لیکل — سمون، نه ټکر', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      // مدیر تېروتنه سموي — دا باید کار وکړي، نه چې مات شي.
      final r = await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: pashtoId,
        teacherId: teacherB,
      );
      expect(r, isA<SetEntryOk>());

      final grid = await tt.grid(sectionId: section10a);
      expect(grid.at(6, lesson(0).id)!.subjectName, 'پښتو');
      expect(await db.select(db.timetableEntries).get(), hasLength(1));
    });

    test('خانه پاکېږي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
      );
      await tt.clearEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
      );
      final grid = await tt.grid(sectionId: section10a);
      expect(grid.at(6, lesson(0).id), isNull);
    });
  });

  group('ټکرونه', () {
    test('یو استاد په یوه وخت کې دوه ټولګیو ته نه ورځي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );

      final r = await tt.setEntry(
        sectionId: section10b,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );

      expect(r, isA<SetEntryTeacherBusy>());
      final busy = r as SetEntryTeacherBusy;
      expect(busy.teacherName, 'استاد احمد');
      expect(busy.otherSection, contains('لسم'));

      // **مهمه:** ټکر باید هېڅ ونه لیکي.
      expect(await db.select(db.timetableEntries).get(), hasLength(1));
    });

    test('هماغه استاد په بل ساعت کې ازاد دی', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      final r = await tt.setEntry(
        sectionId: section10b,
        dayOfWeek: 6,
        slotId: lesson(1).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      expect(r, isA<SetEntryOk>());
    });

    test('هماغه استاد په بله ورځ کې ازاد دی', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      final r = await tt.setEntry(
        sectionId: section10b,
        dayOfWeek: 7,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      expect(r, isA<SetEntryOk>());
    });

    test('د خپل بخش خانه بیا لیکل ټکر نه ګڼل کېږي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      final r = await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: pashtoId,
        teacherId: teacherA,
      );
      expect(r, isA<SetEntryOk>());
    });

    test('یوه خونه په یوه وخت کې دوه ټولګیو ته نه ورکول کېږي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        room: 'لابراتوار',
      );
      final r = await tt.setEntry(
        sectionId: section10b,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: pashtoId,
        room: 'لابراتوار',
      );
      expect(r, isA<SetEntryRoomBusy>());
      expect((r as SetEntryRoomBusy).room, 'لابراتوار');
    });

    test('پرته له استاده درس ثبتېږي — ټکر نه ګڼل کېږي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
      );
      final r = await tt.setEntry(
        sectionId: section10b,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
      );
      expect(r, isA<SetEntryOk>());
    });
  });

  group('د استاد جدول', () {
    test('د استاد اونیز جدول د ورځې او ساعت له مخې ترتیب دی', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 7,
        slotId: lesson(1).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );

      final schedule = await tt.teacherSchedule(teacherA);
      expect(schedule, hasLength(2));
      expect(schedule.first.day, 6);
      expect(schedule.last.day, 7);
    });

    test('اونیز بار شمېرل کېږي', () async {
      for (final day in [6, 7, 1]) {
        await tt.setEntry(
          sectionId: section10a,
          dayOfWeek: day,
          slotId: lesson(0).id,
          subjectId: mathId,
          teacherId: teacherA,
        );
      }
      final loads = await tt.teacherLoads();
      expect(loads[teacherA], 3);
      expect(loads[teacherB], isNull);
    });
  });

  group('د ټولو ټکرونو کتنه', () {
    test('پاک جدول هېڅ ټکر نه لري', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      expect(await tt.conflicts(), isEmpty);
    });

    test('که ټکر له مخې راشي، لیست يې پیدا کوي', () async {
      // `setEntry` مخنیوی کوي — نو مستقیم لیکو، لکه چې له بهر
      // څخه راوړل شوی مهالویش وي.
      for (final s in [section10a, section10b]) {
        await db
            .into(db.timetableEntries)
            .insert(
              TimetableEntriesCompanion.insert(
                sectionId: s,
                dayOfWeek: 6,
                slotId: lesson(0).id,
                subjectId: mathId,
                teacherId: Value(teacherA),
              ),
            );
      }

      final conflicts = await tt.conflicts();
      expect(conflicts, hasLength(1));
      expect(conflicts.first.teacherName, 'استاد احمد');
      expect(conflicts.first.sections, hasLength(2));
    });
  });

  group('د جدول شمېرې', () {
    test('ډکوالی د تفریح پرته شمېرل کېږي', () async {
      final grid = await tt.grid(sectionId: section10a);
      // ۵ ورځې × ۸ درسي ساعته
      expect(grid.capacity, 40);
      expect(grid.filled, 0);
    });
  });

  group('د ورځو نومونه', () {
    test('د Dart weekday سره سم دي', () {
      expect(weekdayNamePs(DateTime(2026, 5, 16).weekday), 'شنبه');
      expect(weekdayNamePs(DateTime(2026, 5, 17).weekday), 'یکشنبه');
      expect(weekdayNamePs(DateTime(2026, 5, 15).weekday), 'جمعه');
    });

    test('درسي ورځې پنجشنبه او جمعه نه لري', () {
      expect(defaultTeachingDays, isNot(contains(4)));
      expect(defaultTeachingDays, isNot(contains(5)));
      expect(defaultTeachingDays, hasLength(5));
    });
  });
}
