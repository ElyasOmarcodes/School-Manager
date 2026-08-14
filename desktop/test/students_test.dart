import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/l10n/strings.dart';
import 'package:school_manager/core/utils/numerals.dart';
import 'package:school_manager/core/utils/qr_token.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/student_repository.dart';

void main() {
  group('د QR کارت کوډ', () {
    final key = QrToken.newSchoolKey();

    test('جوړ شوی کوډ بېرته پېژندل کېږي', () {
      final token = QrToken.encode(
        admissionNo: '1405-0423',
        cardVersion: 1,
        schoolKey: key,
      );

      final scan = QrToken.decode(token, key);
      expect(scan, isNotNull);
      expect(scan!.admissionNo, '1405-0423');
      expect(scan.cardVersion, 1);
    });

    test('جعلي کارت نه منل کېږي', () {
      // څوک د بل شاګرد نمبر په کوډ کې بدلوي — لاسلیک نور سم نه دی.
      final token = QrToken.encode(
        admissionNo: '1405-0423',
        cardVersion: 1,
        schoolKey: key,
      );
      final forged = token.replaceFirst('0423', '0424');

      expect(QrToken.decode(forged, key), isNull);
    });

    test('د بل ښوونځي کارت دلته نه منل کېږي', () {
      final token = QrToken.encode(
        admissionNo: '1405-0423',
        cardVersion: 1,
        schoolKey: key,
      );
      expect(QrToken.decode(token, QrToken.newSchoolKey()), isNull);
    });

    test('د کارت د باطلولو وروسته زوړ کوډ بېل دی', () {
      final v1 = QrToken.encode(
        admissionNo: '1405-0423',
        cardVersion: 1,
        schoolKey: key,
      );
      final v2 = QrToken.encode(
        admissionNo: '1405-0423',
        cardVersion: 2,
        schoolKey: key,
      );

      expect(v1, isNot(equals(v2)));
      // دواړه سم دي — د پرتله کولو دنده د حاضرۍ ماشین ده، چې
      // د شاګرد اوسنۍ نسخه له سکین شوې سره پرتله کوي.
      expect(QrToken.decode(v1, key)!.cardVersion, 1);
      expect(QrToken.decode(v2, key)!.cardVersion, 2);
    });

    test('خراب یا پردی متن ردېږي', () {
      for (final bad in ['', 'hello', 'SM1.x', 'SM1.a.b.c', '1405-0423']) {
        expect(QrToken.decode(bad, key), isNull, reason: bad);
      }
    });

    test('د زموږ د کارت بڼه پېژندل کېږي', () {
      final token = QrToken.encode(
        admissionNo: '1405-0001',
        cardVersion: 1,
        schoolKey: key,
      );
      expect(QrToken.looksLikeToken(token), isTrue);
      // لاسي آی‌ډي نمبر — د QR بڼه نه لري.
      expect(QrToken.looksLikeToken('1405-0001'), isFalse);
    });
  });

  group('شمېرې', () {
    test('لاتیني ختیځو ته اوړي', () {
      expect(Numerals.toEastern('842'), '۸۴۲');
      expect(Numerals.toEastern('1405-0423'), '۱۴۰۵-۰۴۲۳');
    });

    test('ختیځې بېرته لاتینو ته اوړي', () {
      expect(Numerals.toLatin('۸۴۲'), '842');
      // عربي-هندي بڼه هم منل کېږي.
      expect(Numerals.toLatin('٨٤٢'), '842');
    });

    test('د زرګونو جلا کوونکی', () {
      expect(Numerals.grouped(842, AppLocale.en), '842');
      expect(Numerals.grouped(12450, AppLocale.en), '12,450');
      expect(Numerals.grouped(12450, AppLocale.ps), '۱۲,۴۵۰');
    });
  });

  group('د شاګردانو ذخیره', () {
    late AppDatabase db;
    late StudentRepository repo;

    setUp(() async {
      db = AppDatabase.memory();
      repo = StudentRepository(db);
    });

    tearDown(() => db.close());

    Future<int> seedStudent(
      String admissionNo,
      String first,
      String father, {
      String gender = 'male',
      String status = 'active',
      String? phone,
    }) {
      return db
          .into(db.students)
          .insert(
            StudentsCompanion.insert(
              admissionNo: admissionNo,
              firstName: first,
              fatherName: father,
              gender: gender,
              status: Value(status),
              phone: Value(phone),
            ),
          );
    }

    test('د داخلې نمبر په ترتیب زیاتېږي', () async {
      expect(await repo.nextAdmissionNo('1405'), '1405-0001');

      await seedStudent('1405-0001', 'احمد', 'محمود');
      expect(await repo.nextAdmissionNo('1405'), '1405-0002');

      await seedStudent('1405-0002', 'کریم', 'رحیم');
      expect(await repo.nextAdmissionNo('1405'), '1405-0003');
    });

    test('د کلونو نمبرونه سره نه لګېږي', () async {
      await seedStudent('1405-0007', 'احمد', 'محمود');
      // نوی کال له سره پیلېږي.
      expect(await repo.nextAdmissionNo('1406'), '1406-0001');
    });

    test('لټون په نوم، د پلار نوم او آی‌ډي کار کوي', () async {
      await seedStudent('1405-0001', 'احمد', 'محمود');
      await seedStudent('1405-0002', 'کریم', 'رحیم');

      expect(
        (await repo.list(filter: const StudentFilter(query: 'احمد'))).total,
        1,
      );
      expect(
        (await repo.list(filter: const StudentFilter(query: 'رحیم'))).total,
        1,
      );
      expect(
        (await repo.list(filter: const StudentFilter(query: '0002'))).total,
        1,
      );
    });

    test('لټون د ختیځو شمېرو سره هم کار کوي', () async {
      await seedStudent('1405-0423', 'احمد', 'محمود');

      // کارن «۰۴۲۳» لیکي — ډیټابیس لاتیني ساتي.
      final page = await repo.list(
        filter: const StudentFilter(query: '۰۴۲۳'),
      );
      expect(page.total, 1);
      expect(page.items.first.student.admissionNo, '1405-0423');
    });

    test('د جنس او حالت سرغړاوی', () async {
      await seedStudent('1405-0001', 'احمد', 'محمود');
      await seedStudent('1405-0002', 'زرغونه', 'رحیم', gender: 'female');
      await seedStudent(
        '1405-0003',
        'نور',
        'ګل',
        status: 'graduated',
      );

      expect(
        (await repo.list(filter: const StudentFilter(gender: 'female'))).total,
        1,
      );
      // تلواله سرغړاوی یوازې فعال ښیي — فارغ نه راځي.
      expect((await repo.list()).total, 2);
      expect(
        (await repo.list(filter: const StudentFilter(status: 'graduated')))
            .total,
        1,
      );
    });

    test('پټ شوی شاګرد په لیست کې نه راځي', () async {
      final id = await seedStudent('1405-0001', 'احمد', 'محمود');
      expect((await repo.list()).total, 1);

      await repo.softDelete(id, byUserId: 1, byUserName: 'admin');

      expect((await repo.list()).total, 0);
      // خو ریکارډ لا هم شته — حاضري او فیس ورپورې تړلي دي.
      final still = await db.select(db.students).get();
      expect(still, hasLength(1));
      expect(still.first.deletedAt, isNotNull);
    });

    test('د کارت باطلول نسخه زیاتوي', () async {
      final id = await seedStudent('1405-0001', 'احمد', 'محمود');
      await repo.revokeCard(id);

      final s = await (db.select(
        db.students,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(s.cardVersion, 2);
    });

    test('د داخلې راکړه‌ورکړه سرپرست او ثبت یوځای کوي', () async {
      final yearId = await db
          .into(db.academicYears)
          .insert(
            AcademicYearsCompanion.insert(
              label: '۱۴۰۵',
              startsOn: DateTime(2026, 3, 21),
              endsOn: DateTime(2026, 12, 21),
            ),
          );
      final gradeId = await db
          .into(db.grades)
          .insert(GradesCompanion.insert(name: 'لسم', level: 10));
      final sectionId = await db
          .into(db.sections)
          .insert(
            SectionsCompanion.insert(
              gradeId: gradeId,
              academicYearId: yearId,
              name: 'الف',
            ),
          );

      final id = await repo.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0001',
          firstName: 'احمد',
          fatherName: 'محمود',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'محمود خان', relation: 'father'),
          GuardiansCompanion.insert(fullName: 'مور', relation: 'mother'),
        ],
        sectionId: sectionId,
        academicYearId: yearId,
        rollNo: 1,
        byUserId: 1,
        byUserName: 'admin',
      );

      final links = await db.select(db.studentGuardians).get();
      expect(links, hasLength(2));
      // لومړی سرپرست اصلي دی — خبرتیا ده ته ځي.
      expect(links.where((l) => l.isPrimary), hasLength(1));

      final enrollments = await db.select(db.enrollments).get();
      expect(enrollments, hasLength(1));
      expect(enrollments.first.sectionId, sectionId);

      // د QR پټ کلید خپله جوړ شو.
      final student = await (db.select(
        db.students,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(student.qrSecret, isNotNull);

      // په لیست کې ټولګی هم راځي.
      final page = await repo.list();
      expect(page.items.first.className, 'لسم — الف');
    });

    test('د داخلې ناکامي هېڅ نیمګړی ریکارډ نه پرېږدي', () async {
      await seedStudent('1405-0001', 'احمد', 'محمود');

      // هماغه د داخلې نمبر — یوځلي قید يې ردوي.
      await expectLater(
        repo.admit(
          student: StudentsCompanion.insert(
            admissionNo: '1405-0001',
            firstName: 'بل',
            fatherName: 'بل پلار',
            gender: 'male',
          ),
          guardians: [
            GuardiansCompanion.insert(fullName: 'سرپرست', relation: 'father'),
          ],
          byUserId: 1,
          byUserName: 'admin',
        ),
        throwsA(isA<Exception>()),
      );

      // سرپرست نه دی ثبت شوی — راکړه‌ورکړه بېرته وګرځېده.
      expect(await db.select(db.guardians).get(), isEmpty);
    });
  });
}
