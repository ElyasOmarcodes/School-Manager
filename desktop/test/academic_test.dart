import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/features/students/admission_wizard.dart';

void main() {
  late AppDatabase db;
  late AcademicRepository academic;
  late StudentRepository students;

  setUp(() {
    db = AppDatabase.memory();
    academic = AcademicRepository(db);
    students = StudentRepository(db);
  });

  tearDown(() => db.close());

  Future<void> seed({int from = 1, int to = 3}) => academic.seedDefaults(
    yearLabel: '1405',
    startsOn: DateTime(2026, 3, 21),
    endsOn: DateTime(2026, 12, 21),
    fromLevel: from,
    toLevel: to,
  );

  group('د داخلې نمبر مختاړی', () {
    test('ختیځې شمېرې د کال په نښه کې منل کېږي', () {
      // دا هغه تېروتنه ده چې سکرین‌شاټ راوسپړله: تلواله ژبه پښتو ده،
      // نو د کال نښه «۱۴۰۵» ده. که مستقیم `[^0-9]` سره پاکه شي، تشه
      // پاتې کېږي او هر شاګرد `0000-xxxx` نمبر اخلي.
      expect(admissionPrefix('۱۴۰۵'), '1405');
      expect(admissionPrefix('1405'), '1405');
      expect(admissionPrefix('۱۴۰۵-۱۴۰۶'), '14051406');
      expect(admissionPrefix('2026-2027'), '20262027');
    });

    test('تشه یا بې‌شمېرې نښه پر تلواله راځي', () {
      expect(admissionPrefix(null), '0000');
      expect(admissionPrefix(''), '0000');
      expect(admissionPrefix('کال'), '0000');
    });
  });

  group('د تلواله جوړښت زېږون', () {
    test('کال، ټولګي او بخشونه جوړوي', () async {
      await seed(from: 1, to: 3);

      final year = await academic.currentYear();
      expect(year, isNotNull);
      expect(year!.label, '1405');
      expect(year.isCurrent, isTrue);

      final grades = await db.select(db.grades).get();
      expect(grades, hasLength(3));
      expect(grades.first.name, 'لومړی');

      // هر ټولګی دوه بخشونه لري.
      final sections = await db.select(db.sections).get();
      expect(sections, hasLength(6));
    });

    test('دوه ځله زېږون نه کوي', () async {
      await seed(from: 1, to: 3);
      await seed(from: 1, to: 12); // باید هېڅ ونه کړي

      expect(await db.select(db.academicYears).get(), hasLength(1));
      expect(await db.select(db.grades).get(), hasLength(3));
    });
  });

  group('د بخشونو لیست', () {
    test('د ټولګي په ترتیب راځي، له خالي ځایونو سره', () async {
      await seed(from: 1, to: 2);
      final opts = await academic.sections();

      expect(opts, hasLength(4));
      // ترتیب: د ټولګي کچه، بیا د بخش نوم.
      expect(opts.first.label, 'لومړی — الف');
      expect(opts.last.label, 'دویم — ب');

      // لا څوک نه دی ثبت شوی.
      expect(opts.first.enrolledCount, 0);
      expect(opts.first.freeSeats, 40);
      expect(opts.first.isFull, isFalse);
    });

    test('د ثبت شویو شمېر سم راځي', () async {
      await seed(from: 1, to: 1);
      final section = (await academic.sections()).first;
      final year = await academic.currentYear();

      for (var i = 1; i <= 3; i++) {
        await students.admit(
          student: StudentsCompanion.insert(
            admissionNo: '1405-000$i',
            firstName: 'شاګرد$i',
            fatherName: 'پلار',
            gender: 'male',
          ),
          guardians: [
            GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
          ],
          sectionId: section.sectionId,
          academicYearId: year!.id,
          byUserId: 1,
          byUserName: 'admin',
        );
      }

      final after = (await academic.sections()).first;
      expect(after.enrolledCount, 3);
      expect(after.freeSeats, 37);
    });

    test('ډک بخش په ګوته کېږي', () async {
      await seed(from: 1, to: 1);
      final section = (await academic.sections()).first;

      // ظرفیت ۲ ته راټیټوو چې ازموینه ګړندۍ وي.
      await (db.update(db.sections)
            ..where((s) => s.id.equals(section.sectionId)))
          .write(const SectionsCompanion(capacity: Value(2)));

      final year = await academic.currentYear();
      for (var i = 1; i <= 2; i++) {
        await students.admit(
          student: StudentsCompanion.insert(
            admissionNo: '1405-000$i',
            firstName: 'شاګرد$i',
            fatherName: 'پلار',
            gender: 'male',
          ),
          guardians: [
            GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
          ],
          sectionId: section.sectionId,
          academicYearId: year!.id,
          byUserId: 1,
          byUserName: 'admin',
        );
      }

      final after = (await academic.sections()).first;
      expect(after.isFull, isTrue);
      expect(after.freeSeats, 0);
    });
  });

  group('د حاضرۍ نمبر (roll no)', () {
    test('په هر بخش کې جلا او په ترتیب زیاتېږي', () async {
      await seed(from: 1, to: 1);
      final opts = await academic.sections();
      final a = opts[0].sectionId;
      final b = opts[1].sectionId;
      final year = (await academic.currentYear())!.id;

      expect(await academic.nextRollNo(a), 1);

      await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0001',
          firstName: 'احمد',
          fatherName: 'محمود',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'محمود', relation: 'father'),
        ],
        sectionId: a,
        academicYearId: year,
        rollNo: 1,
        byUserId: 1,
        byUserName: 'admin',
      );

      expect(await academic.nextRollNo(a), 2);
      // بل بخش خپل شمېرل لري.
      expect(await academic.nextRollNo(b), 1);
    });
  });

  group('د داخلې بشپړ جریان', () {
    test('د ویزارډ په څېر: نمبر → داخله → لیست کې ښکارېدل', () async {
      await seed(from: 10, to: 10);
      final section = (await academic.sections()).first;
      final year = (await academic.currentYear())!;

      // ۱. ویزارډ راتلونکی نمبر اخلي.
      final no = await students.nextAdmissionNo('1405');
      expect(no, '1405-0001');

      // ۲. ثبتوي يې.
      final rollNo = await academic.nextRollNo(section.sectionId);
      final id = await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: no,
          firstName: 'احمد',
          lastName: const Value('ولي'),
          fatherName: 'محمود',
          gender: 'male',
          phone: const Value('0701234567'),
        ),
        guardians: [
          GuardiansCompanion.insert(
            fullName: 'محمود خان',
            relation: 'father',
            phone: const Value('0701234567'),
            preferredChannel: const Value('sms'),
          ),
        ],
        sectionId: section.sectionId,
        academicYearId: year.id,
        rollNo: rollNo,
        byUserId: 1,
        byUserName: 'admin',
      );

      // ۳. په لیست کې له ټولګي سره ښکاري.
      final page = await students.list();
      expect(page.total, 1);
      final row = page.items.first;
      expect(row.student.id, id);
      expect(row.fullName, 'احمد ولي');
      expect(row.className, 'لسم — الف');
      expect(row.rollNo, 1);

      // ۴. د QR پټ کلید پخپله جوړ شو — کارت چاپېدی شي.
      expect(row.student.qrSecret, isNotNull);
      expect(row.student.cardVersion, 1);

      // ۵. سرپرست تړل شوی او اصلي دی.
      final links = await db.select(db.studentGuardians).get();
      expect(links, hasLength(1));
      expect(links.first.isPrimary, isTrue);

      // ۶. راتلونکی نمبر مخکې تللی.
      expect(await students.nextAdmissionNo('1405'), '1405-0002');
    });
  });
}
