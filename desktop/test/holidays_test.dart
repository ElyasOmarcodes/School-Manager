import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/l10n/strings.dart';
import 'package:school_manager/core/utils/calendars.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/holiday_repository.dart';

void main() {
  late AppDatabase db;
  late HolidayRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = HolidayRepository(db);
  });
  tearDown(() => db.close());

  group('رخصتۍ', () {
    test('یوه څو ورځې رخصتي ټولې ورځې نیسي', () async {
      await repo.add(
        name: 'اختر',
        fromDate: DateTime(2026, 5, 6),
        toDate: DateTime(2026, 5, 9),
      );
      expect(await repo.on(DateTime(2026, 5, 5)), isNull);
      expect((await repo.on(DateTime(2026, 5, 6)))?.name, 'اختر');
      expect((await repo.on(DateTime(2026, 5, 9)))?.name, 'اختر');
      expect(await repo.on(DateTime(2026, 5, 10)), isNull);
    });

    test('کلنۍ رخصتي هر کال راځي', () async {
      await repo.add(
        name: 'استقلال',
        fromDate: DateTime(2026, 8, 19),
        toDate: DateTime(2026, 8, 19),
        isAnnual: true,
      );
      // بل کال هم — کال يې نه شمېرل کېږي.
      expect((await repo.on(DateTime(2031, 8, 19)))?.name, 'استقلال');
      expect(await repo.on(DateTime(2031, 8, 20)), isNull);
    });

    test('پیل او پای پخپله سمېږي', () async {
      final id = await repo.add(
        name: 'ناسم ترتیب',
        fromDate: DateTime(2026, 5, 9),
        toDate: DateTime(2026, 5, 6),
      );
      final row = (await repo.all()).firstWhere((h) => h.id == id);
      expect(row.fromDate.day, 6);
      expect(row.toDate.day, 9);
    });

    test('ړنګ شوې رخصتي نور نه شمېرل کېږي', () async {
      final id = await repo.add(
        name: 'لغوه شوه',
        fromDate: DateTime(2026, 5, 6),
        toDate: DateTime(2026, 5, 6),
      );
      await repo.remove(id);
      expect(await repo.on(DateTime(2026, 5, 6)), isNull);
    });

    test('د یوې مودې ټولې رخصت ورځې', () async {
      await repo.add(
        name: 'اختر',
        fromDate: DateTime(2026, 5, 6),
        toDate: DateTime(2026, 5, 9),
      );
      final days = await repo.daysBetween(
        DateTime(2026, 5, 1),
        DateTime(2026, 5, 31),
      );
      expect(days, hasLength(4));
    });
  });

  // ═══════════════════════════════════════════════════════
  group('تقویمونه', () {
    const j = AppCalendar(system: CalendarSystem.jalali, locale: AppLocale.ps);
    const h = AppCalendar(system: CalendarSystem.hijri, locale: AppLocale.ps);

    test('هجري شمسي سم اړوي', () {
      final p = j.parts(DateTime(2026, 5, 14));
      expect(p.year, 1405);
      expect(p.month, 2);
      expect(p.day, 24);
      // **افغاني نوم، نه ایراني** — «ثور» نه «اردیبهشت».
      expect(p.monthName, 'ثور');
    });

    test('هجري قمري سم اړوي', () {
      final p = h.parts(DateTime(2026, 5, 14));
      expect(p.year, 1447);
      expect(p.month, 11);
      expect(p.monthName, 'ذوالقعده');
    });

    test('بېرته میلادي ته ځي', () {
      expect(j.toGregorian(1405, 2, 24), DateTime(2026, 5, 14));
    });

    test('د میاشتې ورځې', () {
      expect(j.daysInMonth(1405, 1), 31); // حمل
      expect(j.daysInMonth(1405, 12), inInclusiveRange(29, 30)); // حوت
    });
  });
}
