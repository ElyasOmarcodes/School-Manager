import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/utils/csv.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/exam_repository.dart';
import 'package:school_manager/data/repositories/fee_repository.dart';
import 'package:school_manager/data/repositories/report_repository.dart';
import 'package:school_manager/data/repositories/staff_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';

void main() {
  late AppDatabase db;
  late ReportRepository reports;
  late AcademicRepository academic;
  late StudentRepository students;
  late AttendanceRepository attendance;

  late int yearId;
  late int sectionId;
  late int gradeId;
  late Map<String, int> byName;

  final month = DateTime(2026, 5, 1);

  setUp(() async {
    db = AppDatabase.memory();
    reports = ReportRepository(db);
    academic = AcademicRepository(db);
    students = StudentRepository(db);
    attendance = AttendanceRepository(db);

    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026, 1, 1),
      endsOn: DateTime(2026, 12, 31),
    );
    await academic.seedDefaultSubjects();

    yearId = (await academic.currentYear())!.id;
    final first = (await academic.sections()).first;
    sectionId = first.sectionId;
    gradeId = first.gradeId;

    byName = {};
    var i = 1;
    for (final (name, gender) in [
      ('احمد', 'male'),
      ('کریم', 'male'),
      ('زرغونه', 'female'),
    ]) {
      byName[name] = await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-000$i',
          firstName: name,
          fatherName: 'پلار',
          gender: gender,
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        sectionId: sectionId,
        academicYearId: yearId,
        rollNo: i,
        byUserId: 1,
        byUserName: 'admin',
      );
      i++;
    }
  });

  tearDown(() => db.close());

  // ═════════════════════════════════════════════════════════

  group('د حاضرۍ رپوټ', () {
    test('د میاشتې شمېرې او سلنه سمې دي', () async {
      // احمد: ۸ حاضر، ۲ غیرحاضر → ۸۰٪
      for (var d = 1; d <= 10; d++) {
        await attendance.markRoster(
          sectionId: sectionId,
          date: DateTime(2026, 5, d),
          statusByStudentId: {
            byName['احمد']!: d <= 8 ? 'present' : 'absent',
            byName['کریم']!: 'present',
            byName['زرغونه']!: 'present',
          },
          byUserId: 1,
        );
      }

      final t = await reports.attendance(month: month);
      final ahmad = t.rows.firstWhere((r) => r.first == 'احمد');

      expect(ahmad[3], '8'); // حاضر
      expect(ahmad[5], '2'); // غیرحاضر
      expect(ahmad[7], '80٪');
    });

    test('رخصت د سلنې په حساب کې نه راځي', () async {
      // کریم: ۵ حاضر، ۵ رخصت → ۱۰۰٪ (نه ۵۰٪).
      for (var d = 1; d <= 10; d++) {
        await attendance.markRoster(
          sectionId: sectionId,
          date: DateTime(2026, 5, d),
          statusByStudentId: {
            byName['کریم']!: d <= 5 ? 'present' : 'leave',
          },
          byUserId: 1,
        );
      }

      final t = await reports.attendance(month: month);
      final karim = t.rows.firstWhere((r) => r.first == 'کریم');
      expect(karim[6], '5'); // رخصت
      expect(karim[7], '100٪');
    });

    test('که هېڅ ثبت نه وي، سلنه صفر ده — نه ماتېږي', () async {
      final t = await reports.attendance(month: month);
      expect(t.rows, hasLength(3));
      expect(t.rows.first[7], '0٪');
      expect(t.highlights.any((h) => h.label == 'ثبت شوې ورځې'), isTrue);
    });

    test('د یوه بخش فلټر یوازې هغه بخش راوړي', () async {
      final other = (await academic.sections())[1];
      await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0099',
          firstName: 'بلال',
          fatherName: 'پلار',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        sectionId: other.sectionId,
        academicYearId: yearId,
        byUserId: 1,
        byUserName: 'admin',
      );

      final all = await reports.attendance(month: month);
      final one = await reports.attendance(
        month: month,
        sectionId: sectionId,
        sectionLabel: 'لومړی — الف',
      );

      expect(all.rows, hasLength(4));
      expect(one.rows, hasLength(3));
      expect(one.subtitle, contains('لومړی'));
    });

    test('د پای کرښه د کرښو مجموعه ده', () async {
      await attendance.markRoster(
        sectionId: sectionId,
        date: DateTime(2026, 5, 4),
        statusByStudentId: {
          byName['احمد']!: 'present',
          byName['کریم']!: 'absent',
          byName['زرغونه']!: 'late',
        },
        byUserId: 1,
      );

      final t = await reports.attendance(month: month);
      expect(t.totals[3], '1'); // حاضر
      expect(t.totals[4], '1'); // ناوخته
      expect(t.totals[5], '1'); // غیرحاضر
    });
  });

  group('د فیس رپوټ', () {
    test('په ټولګیو ویشل شوی، له سلنې سره', () async {
      final fees = FeeRepository(db);
      await fees.seedDefaultTypes();
      final monthly = (await fees.types())
          .firstWhere((t) => t.name == 'میاشتنی فیس');

      await fees.generate(
        feeTypeId: monthly.id,
        period: '1405-05',
        dueDate: DateTime(2026, 5, 20),
        academicYearId: yearId,
        byUserId: 1,
      );

      final invoices = await db.select(db.feeInvoices).get();
      await fees.pay(invoiceId: invoices.first.id, amount: 500, byUserId: 1);

      final t = await reports.fees(period: '1405-05');
      expect(t.rows, hasLength(1));
      // ۳ شاګردان × ۵۰۰ = ۱۵۰۰، ۵۰۰ راټول شوی → ۳۳٪
      expect(t.totals[2], '1500');
      expect(t.totals[4], '500');
      expect(t.totals[5], '1000');
      expect(t.totals[6], '33٪');
    });

    test('تخفیف د ورکړې وړ اندازه کموي', () async {
      final fees = FeeRepository(db);
      await fees.seedDefaultTypes();
      final monthly = (await fees.types())
          .firstWhere((t) => t.name == 'میاشتنی فیس');

      await fees.generate(
        feeTypeId: monthly.id,
        period: '1405-05',
        dueDate: DateTime(2026, 5, 20),
        academicYearId: yearId,
        byUserId: 1,
      );
      final invoices = await db.select(db.feeInvoices).get();
      await fees.setDiscount(invoiceId: invoices.first.id, discount: 500);

      final t = await reports.fees(period: '1405-05');
      expect(t.totals[3], '500'); // تخفیف
      expect(t.totals[5], '1000'); // پاتې = ۱۵۰۰ − ۵۰۰
    });
  });

  group('د ازموینې رپوټ', () {
    test('د ټولګي د کامیابۍ سلنه او اوسط', () async {
      final exams = ExamRepository(db);
      final examId = await exams.create(
        name: 'ازموینه',
        examType: 'midterm',
        academicYearId: yearId,
        startsOn: DateTime(2026, 5, 10),
        endsOn: DateTime(2026, 5, 12),
      );
      final subjects = await academic.subjects();
      await exams.addSubjects(
        examId: examId,
        gradeId: gradeId,
        subjectIds: [subjects.firstWhere((s) => s.name == 'ریاضي').id],
      );

      final sub = (await exams.subjectsOf(examId, gradeId: gradeId)).first;
      await exams.saveMarks(
        examSubjectId: sub.examSubject.id,
        byStudent: {
          byName['احمد']!: (obtained: 90.0, isAbsent: false),
          byName['کریم']!: (obtained: 60.0, isAbsent: false),
          byName['زرغونه']!: (obtained: 30.0, isAbsent: false),
        },
        byUserId: 1,
      );

      final t = await reports.exam(examId: examId);
      expect(t.rows, hasLength(1));
      expect(t.rows.first[1], '3'); // شاګردان
      expect(t.rows.first[2], '2'); // کامیاب (۹۰ او ۶۰)
      expect(t.rows.first[3], '1'); // ناکام (۳۰ < ۴۰)
      expect(t.rows.first[5], '60٪'); // اوسط
      expect(t.rows.first[6], '90٪'); // لوړه
    });

    test('نه‌پېژندل شوې ازموینه تشه بڼه راګرځوي، نه استثنا', () async {
      final t = await reports.exam(examId: 9999);
      expect(t.isEmpty, isTrue);
    });
  });

  group('د شاګردانو رپوټ', () {
    test('هلکان، نجونې او ډکوالی', () async {
      final t = await reports.enrollment();
      final row = t.rows.first;

      expect(row[1], '2'); // هلکان
      expect(row[2], '1'); // نجونې
      expect(row[3], '3'); // ټول
      expect(row[4], '40'); // ظرفیت
      expect(row[6], '8٪');
    });

    test('بې‌ټولګي شاګردان په ګوته کېږي', () async {
      // یو شاګرد پرته له بخشه ثبتوو.
      await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0500',
          firstName: 'ورک',
          fatherName: 'پلار',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
        ],
        byUserId: 1,
        byUserName: 'admin',
      );

      final t = await reports.enrollment();
      final orphan = t.highlights.firstWhere((h) => h.label == 'بې‌ټولګي');
      expect(orphan.value, '1');
      expect(orphan.warn, isTrue);
    });
  });

  group('د کارکوونکو رپوټ', () {
    test('استادان او څانګې سره جلا، مجموعه سمه', () async {
      await db
          .into(db.teachers)
          .insert(
            TeachersCompanion.insert(
              employeeNo: 'T-0001',
              fullName: 'استاد',
              gender: 'male',
              monthlySalary: const Value(20000),
            ),
          );
      await StaffRepository(db).add(
        staff: StaffMembersCompanion.insert(
          employeeNo: 'S-0001',
          fullName: 'محاسب',
          jobTitle: 'محاسب',
          gender: 'male',
          department: const Value('مالي'),
          monthlySalary: const Value(15000),
        ),
        byUserId: 1,
        byUserName: 'admin',
      );

      final t = await reports.staff();
      expect(t.rows, hasLength(2));
      expect(t.totals[1], '2'); // کارکوونکي
      expect(t.totals[2], '35000');

      final yearly = t.highlights.firstWhere((h) => h.label == 'کلنی');
      expect(yearly.value, '420000');
    });
  });

  group('CSV', () {
    test('BOM لري — که نه، Excel پښتو خځلې ښیي', () {
      final csv = Csv.build(columns: const ['نوم'], rows: const []);
      expect(csv.startsWith(Csv.bom), isTrue);
    });

    test('د ویندوز د کرښې پای (CRLF) کاروي', () {
      final csv = Csv.build(
        columns: const ['a', 'b'],
        rows: const [
          ['1', '2'],
        ],
      );
      expect(csv, contains('a,b\r\n'));
      expect(csv, contains('1,2\r\n'));
    });

    test('د لاتیني کامې لرونکې خانه په کوتو کې ځي', () {
      final csv = Csv.build(
        columns: const ['x'],
        rows: const [
          ['Wali, Ahmad'],
        ],
      );
      expect(csv, contains('"Wali, Ahmad"'));
    });

    test('پښتو کامه «،» جلاکوونکې نه ده — نو کوتې نه غواړي', () {
      // دا د CSV جلاکوونکې نه ده، یوازې یو توری دی. که يې په کوتو
      // کې اچولی، هره پښتو کرښه به بې‌ځایه اوږده شوې وای.
      final csv = Csv.build(
        columns: const ['x'],
        rows: const [
          ['احمد، ولي'],
        ],
      );
      expect(csv, contains('احمد، ولي'));
      expect(csv, isNot(contains('"')));
    });

    test('نرۍ کوتې دوه‌چنده کېږي', () {
      final csv = Csv.build(
        columns: const ['x'],
        rows: const [
          ['د "الف" ټولګی'],
        ],
      );
      expect(csv, contains('"د ""الف"" ټولګی"'));
    });

    test('د پای کرښه وروستۍ ده', () {
      final csv = Csv.build(
        columns: const ['a'],
        rows: const [
          ['1'],
        ],
        totals: const ['ټول'],
      );
      expect(csv.trimRight().split('\r\n').last, 'ټول');
    });

    test('یو رپوټ سیده CSV ته اوړي', () async {
      final t = await reports.enrollment();
      final csv = Csv.build(
        columns: t.columns,
        rows: t.rows,
        totals: t.totals,
      );
      // سرلیک + یوه کرښه + مجموعه.
      expect(csv.trimRight().split('\r\n'), hasLength(t.rows.length + 2));
      expect(csv, contains('ټولګی'));
    });
  });
}
