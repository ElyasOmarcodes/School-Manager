import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/timetable_repository.dart';

void main() {
  _proposalTests();
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

  // ═════════════════════════════════════════════════════════
  group('ځیرک ترتیب', () {
    test('سخت مضمونونه سهار، اسانه ماښام', () async {
      final plan = await tt.arrange(daily: false, sectionId: section10a);
      expect(plan.cells, isNotEmpty);
      expect(plan.placed, plan.capacity);

      final subjects = {for (final x in await academic.subjects()) x.id: x};
      final lessons = slots.where((x) => !x.isBreak).toList();
      final index = {
        for (var i = 0; i < lessons.length; i++) lessons[i].id: i,
      };

      // د هرې سختۍ اوسط ځای — سخت باید تر منځني، منځنی تر اسانه
      // مخکې وي.
      final sum = <String, int>{};
      final n = <String, int>{};
      for (final c in plan.cells) {
        final d = subjects[c.subjectId]!.difficulty;
        sum[d] = (sum[d] ?? 0) + index[c.slotId]!;
        n[d] = (n[d] ?? 0) + 1;
      }
      double avg(String d) => n[d] == null ? -1 : sum[d]! / n[d]!;

      expect(n['hard'], isNotNull, reason: 'نصاب سخت مضمون لري');
      expect(n['easy'], isNotNull, reason: 'نصاب اسانه مضمون لري');
      expect(avg('hard'), lessThan(avg('easy')));
    });

    test('یو مضمون په یوه ورځ کې دوه ځله نه راځي', () async {
      final plan = await tt.arrange(daily: false, sectionId: section10a);
      final perDay = <int, List<int>>{};
      for (final c in plan.cells) {
        perDay.putIfAbsent(c.dayOfWeek, () => []).add(c.subjectId);
      }
      for (final e in perDay.entries) {
        expect(
          e.value.toSet().length,
          e.value.length,
          reason: 'ورځ ${e.key} تکرار لري',
        );
      }
    });

    test('بدیلونه سره توپیر لري، خو هر یو خپل ځان ته ثابت دی', () async {
      final a = await tt.arrange(daily: false, sectionId: section10a);
      final b = await tt.arrange(
        daily: false,
        sectionId: section10a,
        variant: 1,
      );
      final aAgain = await tt.arrange(daily: false, sectionId: section10a);

      String sig(ArrangementPlan p) => (p.cells
              .map((c) => '${c.dayOfWeek}/${c.slotId}/${c.subjectId}')
              .toList()
            ..sort())
          .join('|');

      // **هماغه بدیل تل هماغه ترتیب** — که نه، د › بیا ‹ وهل به
      // یو نوی ترتیب راوړی و، نه پخوانی.
      expect(sig(aAgain), sig(a));
      expect(sig(b), isNot(sig(a)));
    });

    test('د یوې درجې کتابونه بلې ته نه ځي', () async {
      // درجه-ځانګړي مضمونونه جوړوو — هر یو یوې درجې پورې تړلی.
      final grades = await academic.grades();
      final g10 = grades.firstWhere((g) => g.level == 10);
      final g11 = grades.firstWhere((g) => g.level == 11);

      final only10 = await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              name: 'قدوري (صلوة)',
              gradeId: Value(g10.id),
              difficulty: const Value('hard'),
            ),
          );
      final only11 = await db
          .into(db.subjects)
          .insert(
            SubjectsCompanion.insert(
              name: 'هدایه',
              gradeId: Value(g11.id),
              difficulty: const Value('hard'),
            ),
          );

      // ټول بخشونه یو ځای ترتیبوو — دا هغه حالت دی چې تېروتنه به
      // پکې ښکاره شوې وای.
      final plan = await tt.arrange(daily: true);
      final sections = await academic.sections();
      final gradeOf = {
        for (final x in sections) x.sectionId: x.gradeId,
      };

      for (final c in plan.cells) {
        if (c.subjectId == only10) {
          expect(gradeOf[c.sectionId], g10.id, reason: 'قدوري بله درجه ته تللی');
        }
        if (c.subjectId == only11) {
          expect(gradeOf[c.sectionId], g11.id, reason: 'هدایه بله درجه ته تللې');
        }
      }
      // او لږ تر لږه یو ځل خپلې درجې ته ورکړل شوی وي.
      expect(plan.cells.any((c) => c.subjectId == only10), isTrue);
    });

    test('ترتیب ذخیره کېږي او زاړه خانې پاکېږي', () async {
      // یو زوړ درس چې نوی ترتیب يې نه لري.
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );

      final plan = await tt.arrange(daily: false, sectionId: section10a);
      await tt.applyPlan(plan);

      final grid = await tt.grid(sectionId: section10a);
      expect(grid.filled, plan.placed);
      // هېڅ خانه دوه ځله نه ده لیکل شوې.
      final all = await db.select(db.timetableEntries).get();
      final keys = all.map((e) => '${e.sectionId}/${e.dayOfWeek}/${e.slotId}');
      expect(keys.toSet().length, all.length);
    });

    test('د استاد ټکر څومره چې کېدی شي مخنیوی کېږي', () async {
      // دواړه بخشونه ترتیبوو — یو استاد نه شي دواړه ځایه.
      final plan = await tt.arrange(daily: false);
      final seen = <String>{};
      var actual = 0;
      for (final c in plan.cells) {
        if (c.teacherId == null) continue;
        final k = '${c.dayOfWeek}/${c.slotId}/${c.teacherId}';
        if (!seen.add(k)) actual++;
      }
      // راپور شوې شمېره باید له ریښتینې سره سمون ولري.
      expect(actual, plan.teacherClashes);
    });
  });

  // ═════════════════════════════════════════════════════════
  group('کش کول (drag & drop)', () {
    test('تشې خانې ته لېږدول', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
      );

      final r = await tt.moveEntry(
        sectionId: section10a,
        fromDay: 6,
        fromSlotId: lesson(0).id,
        toDay: 6,
        toSlotId: lesson(3).id,
      );
      expect(r, MoveResult.ok);

      final grid = await tt.grid(sectionId: section10a);
      expect(grid.at(6, lesson(0).id), isNull);
      expect(grid.at(6, lesson(3).id)!.entry.subjectId, mathId);
    });

    test('ډکې خانې ته لېږدول دواړه سره بدلوي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
      );
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 7,
        slotId: lesson(2).id,
        subjectId: pashtoId,
      );

      expect(
        await tt.moveEntry(
          sectionId: section10a,
          fromDay: 6,
          fromSlotId: lesson(0).id,
          toDay: 7,
          toSlotId: lesson(2).id,
        ),
        MoveResult.swapped,
      );

      final grid = await tt.grid(sectionId: section10a);
      expect(grid.at(7, lesson(2).id)!.entry.subjectId, mathId);
      expect(grid.at(6, lesson(0).id)!.entry.subjectId, pashtoId);
    });

    test('بل بخش ته کش کول رد کېږي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
      );

      expect(
        await tt.moveEntry(
          sectionId: section10a,
          fromDay: 6,
          fromSlotId: lesson(0).id,
          toDay: 6,
          toSlotId: lesson(1).id,
          toSectionId: section10b,
        ),
        MoveResult.crossSection,
      );
      // هېڅ يې ونه خوځېد.
      final grid = await tt.grid(sectionId: section10a);
      expect(grid.at(6, lesson(0).id)!.entry.subjectId, mathId);
    });

    test('تشه سرچینه هېڅ نه کوي', () async {
      expect(
        await tt.moveEntry(
          sectionId: section10a,
          fromDay: 6,
          fromSlotId: lesson(0).id,
          toDay: 6,
          toSlotId: lesson(1).id,
        ),
        MoveResult.emptySource,
      );
    });
  });

  // ═════════════════════════════════════════════════════════
  group('انډو او ریډو', () {
    test('انځور بېرته راوړل ټول جدول بیا جوړوي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      final before = await tt.snapshot();
      expect(before, hasLength(1));

      final plan = await tt.arrange(daily: false, sectionId: section10a);
      await tt.applyPlan(plan);
      expect(await tt.snapshot(), hasLength(plan.placed));

      await tt.restore(before);
      final after = await tt.snapshot();
      expect(after, hasLength(1));
      expect(after.single.subjectId, mathId);
      expect(after.single.teacherId, teacherA);
    });
  });

  // ═════════════════════════════════════════════════════════
  group('د ساعتونو له سره جوړول', () {
    test('د پای وخت حساب — له تفریح سره', () {
      expect(
        TimetableRepository.computeDayEnd(
          dayStart: '07:00',
          periodsPerDay: 6,
          periodMinutes: 45,
          breakAfterPeriods: 4,
          breakMinutes: 15,
          breaksPerDay: 1,
        ),
        // ۶×۴۵ = ۲۷۰ + ۱۵ تفریح = ۲۸۵ دقیقې → ۱۱:۴۵
        '11:45',
      );
    });

    test('د ورځې په پای کې تفریح نه ورکول کېږي', () {
      // که د تفریح ځای د وروستي ساعت وروسته راشي، معنا نه لري.
      expect(
        TimetableRepository.computeDayEnd(
          dayStart: '07:00',
          periodsPerDay: 4,
          periodMinutes: 45,
          breakAfterPeriods: 4,
          breakMinutes: 15,
          breaksPerDay: 1,
        ),
        '10:00',
      );
    });

    test('نوي ساعتونه جوړېږي او زاړه درسونه خپل ځای ساتي', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(0).id,
        subjectId: mathId,
        teacherId: teacherA,
      );
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(2).id,
        subjectId: pashtoId,
      );

      final dropped = await tt.rebuildSlots(
        dayStart: '07:00',
        periodsPerDay: 6,
        periodMinutes: 45,
        breakAfterPeriods: 4,
        breakMinutes: 15,
        breaksPerDay: 1,
      );
      expect(dropped, 0);

      final fresh = await tt.slots();
      final teaching = fresh.where((s) => !s.isBreak).toList();
      expect(teaching, hasLength(6));
      expect(fresh.where((s) => s.isBreak), hasLength(1));
      expect(teaching.first.startTime, '07:00');
      expect(teaching.first.endTime, '07:45');
      expect(teaching.last.endTime, '11:45');

      // درسونه هماغه ځایونه ساتي — لومړی او دریم.
      final grid = await tt.grid(sectionId: section10a);
      expect(grid.at(6, teaching[0].id)!.entry.subjectId, mathId);
      expect(grid.at(6, teaching[2].id)!.entry.subjectId, pashtoId);
      expect(grid.at(6, teaching[0].id)!.entry.teacherId, teacherA);
    });

    test('لنډېدل هغه درسونه ړنګوي چې ځای نه لري — او شمېري يې', () async {
      await tt.setEntry(
        sectionId: section10a,
        dayOfWeek: 6,
        slotId: lesson(7).id,
        subjectId: mathId,
      );

      final dropped = await tt.rebuildSlots(
        dayStart: '07:30',
        periodsPerDay: 4,
        periodMinutes: 40,
        breakAfterPeriods: 2,
        breakMinutes: 10,
        breaksPerDay: 1,
      );
      expect(dropped, 1);
      expect(await db.select(db.timetableEntries).get(), isEmpty);
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

// ═══════════════════════════════════════════════════════════
//  د ځیرک ترتیب وړاندیزونه
// ═══════════════════════════════════════════════════════════

void _proposalTests() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.memory());
  tearDown(() => db.close());

  Future<void> seed() async {
    await db
        .into(db.schools)
        .insert(SchoolsCompanion.insert(name: 'ازموینه'));
    await AcademicRepository(db).seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026),
      endsOn: DateTime(2026, 12, 31),
      fromLevel: 1,
      toLevel: 2,
      sectionNames: const ['الف', 'ب'],
    );
    await AcademicRepository(db).seedDefaultSubjects();
    await TimetableRepository(db).seedDefaultSlots();
  }

  group('ځیرک وړاندیزونه', () {
    test('ټول وړاندیزونه بې‌ټکره دي', () async {
      await seed();
      final list = await TimetableRepository(db).proposals(daily: false);
      expect(list, isNotEmpty);
      for (final p in list) {
        // **دا هغه ژمنه ده چې کارن وغوښته.** یو استاد هېڅکله په
        // یوه وخت کې دوه ځایه نه شي.
        expect(p.teacherClashes, 0, reason: 'وړاندیز ${p.variant}');
        expect(p.sameDayRepeats, 0, reason: 'وړاندیز ${p.variant}');
      }
    });

    test('غوره وړاندیز لومړی راځي', () async {
      await seed();
      final list = await TimetableRepository(db).proposals(daily: false);
      for (var i = 1; i < list.length; i++) {
        expect(list[i - 1].rank >= list[i].rank, isTrue);
      }
    });

    test('وړاندیزونه یو له بله بېل دي', () async {
      await seed();
      final list = await TimetableRepository(db).proposals(daily: false);
      final keys = list
          .map(
            (p) => p.cells
                .map((c) => '${c.dayOfWeek}.${c.slotId}.${c.subjectId}')
                .join('|'),
          )
          .toSet();
      expect(keys, hasLength(list.length));
    });

    test('سخت کتابونه سهار ته ځي', () async {
      await seed();
      // درې کتابونه: یو سخت، یو منځنی، یو اسان.
      final subs = await AcademicRepository(db).subjects();
      await (db.update(db.subjects)
            ..where((s) => s.id.equals(subs[0].id)))
          .write(const SubjectsCompanion(difficulty: Value('hard')));
      await (db.update(db.subjects)
            ..where((s) => s.id.equals(subs.last.id)))
          .write(const SubjectsCompanion(difficulty: Value('easy')));

      final list = await TimetableRepository(db).proposals(daily: false);
      // یو غوره ترتیب باید له نیمايي ښه وي — که نه، د سختوالي
      // ویش يې هېڅ نه کاوه.
      expect(list.first.difficultyScore, greaterThan(50));
    });
  });
}
