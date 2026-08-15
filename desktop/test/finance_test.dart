import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/fee_repository.dart';
import 'package:school_manager/data/repositories/payroll_repository.dart';
import 'package:school_manager/data/repositories/staff_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/data/repositories/user_repository.dart';

void main() {
  late AppDatabase db;
  late FeeRepository fees;
  late PayrollRepository payroll;
  late AcademicRepository academic;
  late StudentRepository students;

  late int yearId;
  late int sectionId;
  late int monthlyFeeId;
  late Map<String, int> studentByName;

  setUp(() async {
    db = AppDatabase.memory();
    fees = FeeRepository(db);
    payroll = PayrollRepository(db);
    academic = AcademicRepository(db);
    students = StudentRepository(db);

    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026, 1, 1),
      endsOn: DateTime(2026, 12, 31),
    );
    await fees.seedDefaultTypes();

    yearId = (await academic.currentYear())!.id;
    sectionId = (await academic.sections()).first.sectionId;
    monthlyFeeId = (await fees.types())
        .firstWhere((t) => t.name == 'میاشتنی فیس')
        .id;

    studentByName = {};
    var i = 1;
    for (final name in ['احمد', 'کریم', 'زرغونه']) {
      studentByName[name] = await students.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-000$i',
          firstName: name,
          fatherName: 'پلار',
          gender: 'male',
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

  Future<InvoiceRunResult> generate({String period = '1405-05'}) => fees.generate(
    feeTypeId: monthlyFeeId,
    period: period,
    dueDate: DateTime(2026, 5, 20),
    academicYearId: yearId,
    byUserId: 1,
  );

  Future<InvoiceRow> invoiceOf(String name, {String period = '1405-05'}) async {
    final page = await fees.list(period: period);
    return page.items.firstWhere(
      (r) => r.student.firstName == name,
    );
  }

  // ═════════════════════════════════════════════════════════

  group('د فیس بلونه', () {
    test('د یوې دورې بلونه د ټولو فعالو شاګردانو لپاره جوړېږي', () async {
      final r = await generate();
      expect(r.created, 3);
      expect(r.skipped, 0);

      final page = await fees.list(period: '1405-05');
      expect(page.total, 3);
      expect(page.items.every((i) => i.invoice.amount == 500), isTrue);
    });

    test('دوه ځله ځغلول دوهڅنده بلونه نه جوړوي', () async {
      await generate();
      final second = await generate();

      expect(second.created, 0);
      expect(second.skipped, 3);
      expect(await db.select(db.feeInvoices).get(), hasLength(3));
    });

    test('بېلې دورې بېل بلونه دي', () async {
      await generate(period: '1405-05');
      await generate(period: '1405-06');

      expect(await db.select(db.feeInvoices).get(), hasLength(6));
      expect((await fees.periods()), ['1405-06', '1405-05']);
    });
  });

  group('تادیه', () {
    test('بشپړه تادیه حالت «ورکړل شوی» ته اړوي', () async {
      await generate();
      final inv = await invoiceOf('احمد');

      await fees.pay(invoiceId: inv.invoice.id, amount: 500, byUserId: 1);

      final after = await invoiceOf('احمد');
      expect(after.invoice.status, 'paid');
      expect(after.paid, 500);
      expect(after.balance, 0);
      expect(after.isSettled, isTrue);
    });

    test('نیمه تادیه «نیمګړی» ده — نه ورکړل شوی، نه نه‌ورکړل شوی', () async {
      await generate();
      final inv = await invoiceOf('احمد');

      await fees.pay(invoiceId: inv.invoice.id, amount: 200, byUserId: 1);

      final after = await invoiceOf('احمد');
      expect(after.invoice.status, 'partial');
      expect(after.paid, 200);
      expect(after.balance, 300);
    });

    test('څو تادیې راټولېږي او بل بشپړوي', () async {
      await generate();
      final inv = await invoiceOf('احمد');

      await fees.pay(invoiceId: inv.invoice.id, amount: 200, byUserId: 1);
      await fees.pay(invoiceId: inv.invoice.id, amount: 300, byUserId: 1);

      final after = await invoiceOf('احمد');
      expect(after.paid, 500);
      expect(after.invoice.status, 'paid');
      expect(await fees.paymentsOf(inv.invoice.id), hasLength(2));
    });

    test('د رسید نمبرونه یو په بل پسې دي او تکرار نه شي', () async {
      await generate();
      final inv = await invoiceOf('احمد');

      await fees.pay(invoiceId: inv.invoice.id, amount: 100, byUserId: 1);
      await fees.pay(invoiceId: inv.invoice.id, amount: 100, byUserId: 1);

      final payments = await fees.paymentsOf(inv.invoice.id);
      final numbers = payments.map((p) => p.receiptNo).toSet();
      expect(numbers, hasLength(2));
      expect(numbers, contains('R-000001'));
      expect(numbers, contains('R-000002'));
    });

    test('تخفیف د ورکړې وړ اندازه کموي', () async {
      await generate();
      final inv = await invoiceOf('احمد');

      await fees.setDiscount(
        invoiceId: inv.invoice.id,
        discount: 200,
        reason: 'یتیم',
      );
      await fees.pay(invoiceId: inv.invoice.id, amount: 300, byUserId: 1);

      final after = await invoiceOf('احمد');
      expect(after.payable, 300);
      expect(after.balance, 0);
      expect(after.invoice.status, 'paid');
    });

    test('بښل شوی بل تادیه نه غواړي', () async {
      await generate();
      final inv = await invoiceOf('احمد');

      await fees.waive(inv.invoice.id, reason: 'بېوزله کورنۍ', byUserId: 1);

      final after = await invoiceOf('احمد');
      expect(after.invoice.status, 'waived');
      expect(after.isSettled, isTrue);
    });

    test('د بښل شوي بل حالت د تادیې په ثبت سره نه بدلېږي', () async {
      await generate();
      final inv = await invoiceOf('احمد');
      await fees.waive(inv.invoice.id, byUserId: 1);

      await fees.pay(invoiceId: inv.invoice.id, amount: 100, byUserId: 1);

      final after = await invoiceOf('احمد');
      expect(after.invoice.status, 'waived');
    });
  });

  group('د راټولولو لنډیز', () {
    test('د دورې شمېرې سمې دي', () async {
      await generate();
      final a = await invoiceOf('احمد');
      final k = await invoiceOf('کریم');

      await fees.pay(invoiceId: a.invoice.id, amount: 500, byUserId: 1);
      await fees.pay(invoiceId: k.invoice.id, amount: 200, byUserId: 1);

      final s = await fees.summary(period: '1405-05');
      expect(s.invoiced, 1500);
      expect(s.collected, 700);
      expect(s.outstanding, 800);
      expect(s.paidCount, 1);
      expect(s.partialCount, 1);
      expect(s.unpaidCount, 1);
    });

    test('بښل شوی بل د پاتې پور په حساب کې نه راځي', () async {
      await generate();
      final a = await invoiceOf('احمد');
      await fees.waive(a.invoice.id, byUserId: 1);

      final s = await fees.summary(period: '1405-05');
      // ۱۵۰۰ بل، ۵۰۰ يې بښل شوی → ۱۰۰۰ د ورکړې وړ.
      expect(s.payable, 1000);
      expect(s.outstanding, 1000);
    });

    test('پوروړي د پور له مخې ترتیب دي', () async {
      await generate(period: '1405-05');
      await generate(period: '1405-06');

      // احمد یوه میاشت ورکړه، کریم هېڅ.
      final a = await invoiceOf('احمد', period: '1405-05');
      await fees.pay(invoiceId: a.invoice.id, amount: 500, byUserId: 1);

      final list = await fees.defaulters();
      final ahmad = list.firstWhere((d) => d.student.firstName == 'احمد');
      final karim = list.firstWhere((d) => d.student.firstName == 'کریم');

      expect(ahmad.balance, 500);
      expect(karim.balance, 1000);
      expect(karim.months, 2);
      // ډېر پور مخکې.
      expect(list.first.balance, greaterThanOrEqualTo(list.last.balance));
    });

    test('د یوه شاګرد پاتې پور ټولې دورې راټولوي', () async {
      await generate(period: '1405-05');
      await generate(period: '1405-06');

      expect(await fees.balanceOf(studentByName['کریم']!), 1000);
    });
  });

  group('معاشونه', () {
    Future<void> seedEmployees() async {
      await db
          .into(db.teachers)
          .insert(
            TeachersCompanion.insert(
              employeeNo: 'T-0001',
              fullName: 'استاد احمد',
              gender: 'male',
              monthlySalary: const Value(20000),
            ),
          );
      await StaffRepository(db).add(
        staff: StaffMembersCompanion.insert(
          employeeNo: 'S-0001',
          fullName: 'نور محمد',
          jobTitle: 'سرایدار',
          gender: 'male',
          monthlySalary: const Value(9000),
        ),
        byUserId: 1,
        byUserName: 'admin',
      );
    }

    test('دوره د ټولو فعالو کارکوونکو کرښې جوړوي', () async {
      await seedEmployees();
      final runId = await payroll.createRun(period: '1405-05', byUserId: 1);

      final items = await payroll.items(runId);
      expect(items, hasLength(2));
      expect(items.map((i) => i.employeeKind).toSet(), {'teacher', 'staff'});

      final s = await payroll.summaryOf(runId);
      expect(s.baseTotal, 29000);
      expect(s.netTotal, 29000);
    });

    test('هماغه دوره دوه ځله نه جوړېږي', () async {
      await seedEmployees();
      final first = await payroll.createRun(period: '1405-05', byUserId: 1);
      final second = await payroll.createRun(period: '1405-05', byUserId: 1);

      expect(second, first);
      expect(await payroll.items(first), hasLength(2));
    });

    test('خالص معاش پخپله شمېرل کېږي', () async {
      await seedEmployees();
      final runId = await payroll.createRun(period: '1405-05', byUserId: 1);
      final item = (await payroll.items(runId)).first;

      await payroll.updateItem(
        itemId: item.id,
        allowances: 2000,
        deductions: 500,
        absenceDeduction: 1000,
        absentDays: 2,
      );

      final after = (await payroll.items(runId))
          .firstWhere((i) => i.id == item.id);
      expect(after.netPay, after.baseSalary + 2000 - 500 - 1000);
    });

    test('کسرونه خالص معاش تر صفر ښکته نه کوي', () async {
      await seedEmployees();
      final runId = await payroll.createRun(period: '1405-05', byUserId: 1);
      final item = (await payroll.items(runId)).firstWhere(
        (i) => i.employeeName == 'نور محمد',
      );

      await payroll.updateItem(itemId: item.id, deductions: 999999);

      final after = (await payroll.items(runId))
          .firstWhere((i) => i.id == item.id);
      expect(after.netPay, 0);
    });

    test('د معاش اندازه له کارکوونکي کاپي کېږي، نه تړل کېږي', () async {
      await seedEmployees();
      final runId = await payroll.createRun(period: '1405-05', byUserId: 1);

      // استاد ته معاش پورته شو.
      await (db.update(db.teachers)
            ..where((t) => t.employeeNo.equals('T-0001')))
          .write(const TeachersCompanion(monthlySalary: Value(25000)));

      // تېره میاشت باید هماغه زړه اندازه وښيي.
      final item = (await payroll.items(runId))
          .firstWhere((i) => i.employeeKind == 'teacher');
      expect(item.baseSalary, 20000);
    });

    test('تصویب او ورکړه حالت بدلوي', () async {
      await seedEmployees();
      final runId = await payroll.createRun(period: '1405-05', byUserId: 1);

      await payroll.approve(runId, byUserId: 1);
      expect((await payroll.runs()).first.run.status, 'approved');

      final n = await payroll.markPaid(runId);
      expect(n, 2);
      final row = (await payroll.runs()).first;
      expect(row.run.status, 'paid');
      expect(row.summary.paidCount, 2);
    });
  });

  group('کاروونکي او اجازې', () {
    late UserRepository users;

    setUp(() {
      users = UserRepository(db);
    });

    Future<int> makeAdmin() => users.create(
      username: 'admin',
      fullName: 'مدیر صاحب',
      password: 'secret123',
      role: 'admin',
      byUserId: 0,
      byUserName: 'system',
    );

    test('مدیر هرڅه کولی شي — حتی که هېڅ اجازه ورنکړل شي', () {
      final p = Permissions(role: 'admin');
      for (final m in permModules) {
        expect(p.can(m.key, Perm.delete), isTrue, reason: m.key);
      }
    });

    test('محاسب فیس سموي خو شاګرد نه شي ړنګولی', () {
      final p = Permissions(role: 'accountant');
      expect(p.can('fees', Perm.edit), isTrue);
      expect(p.can('students', Perm.view), isTrue);
      expect(p.can('students', Perm.delete), isFalse);
      expect(p.can('payroll', Perm.create), isTrue);
      expect(p.can('settings', Perm.view), isFalse);
    });

    test('استاد یوازې خپلې برخې ویني', () {
      final p = Permissions(role: 'teacher');
      expect(p.visibleModules, contains('attendance'));
      expect(p.visibleModules, contains('exams'));
      expect(p.visibleModules, isNot(contains('payroll')));
      expect(p.visibleModules, isNot(contains('users')));
    });

    test('شخصي استثنا د رول پر تلواله بریالۍ کېږي', () {
      final p = Permissions(
        role: 'teacher',
        explicit: {
          'fees': {'view'},
        },
      );
      expect(p.can('fees', Perm.view), isTrue);
      expect(p.can('fees', Perm.edit), isFalse);
      // پاتې ماډلونه لا هم د رول له مخې دي.
      expect(p.can('attendance', Perm.create), isTrue);
    });

    test('اجازې ثبتېږي او بیرته لوستل کېږي', () async {
      final id = await users.create(
        username: 'karim',
        fullName: 'کریم',
        password: 'pass1234',
        role: 'teacher',
        permissions: {
          'fees': {'view', 'create'},
        },
        byUserId: 1,
        byUserName: 'admin',
      );

      final row = (await users.list()).firstWhere((u) => u.user.id == id);
      expect(row.permissions.can('fees', Perm.create), isTrue);
      expect(row.permissions.can('fees', Perm.delete), isFalse);
    });

    test('د رول بدلون شخصي استثناوې پاکوي', () async {
      final id = await users.create(
        username: 'karim',
        fullName: 'کریم',
        password: 'pass1234',
        role: 'teacher',
        permissions: {
          'fees': {'view'},
        },
        byUserId: 1,
        byUserName: 'admin',
      );

      await users.setRole(
        userId: id,
        role: 'accountant',
        byUserId: 1,
        byUserName: 'admin',
      );

      final row = (await users.list()).firstWhere((u) => u.user.id == id);
      expect(row.user.permissionsJson, isNull);
      // اوس د محاسب تلوالې پلې دي.
      expect(row.permissions.can('fees', Perm.edit), isTrue);
    });

    test('خراب JSON کارن له سیسټمه نه بندوي', () {
      final p = Permissions(role: 'teacher', explicit: Permissions.decode('{['));
      expect(p.can('attendance', Perm.view), isTrue);
    });

    test('وروستی فعال مدیر پېژندل کېږي', () async {
      final adminId = await makeAdmin();
      expect(await users.isLastActiveAdmin(adminId), isTrue);

      final second = await users.create(
        username: 'admin2',
        fullName: 'دویم مدیر',
        password: 'pass1234',
        role: 'admin',
        byUserId: 1,
        byUserName: 'admin',
      );
      expect(await users.isLastActiveAdmin(adminId), isFalse);

      // دویم بند شو — لومړی بیا وروستی دی.
      await users.setActive(
        userId: second,
        active: false,
        byUserId: 1,
        byUserName: 'admin',
      );
      expect(await users.isLastActiveAdmin(adminId), isTrue);
    });

    test('کارن نوم دوه ځله نه منل کېږي', () async {
      await makeAdmin();
      expect(await users.usernameTaken('admin'), isTrue);
      expect(await users.usernameTaken('nobody'), isFalse);
    });

    test('پاسورډ په تفتیش کې نه لیکل کېږي', () async {
      final id = await makeAdmin();
      await users.resetPassword(
        userId: id,
        newPassword: 'brand-new-secret',
        byUserId: 1,
        byUserName: 'admin',
      );

      final logs = await users.recentActivity();
      for (final l in logs) {
        expect(l.changesJson ?? '', isNot(contains('brand-new-secret')));
      }
    });
  });
}
