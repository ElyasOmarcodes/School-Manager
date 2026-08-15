@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/config/app_config.dart';
import 'package:school_manager/core/l10n/strings.dart';
import 'package:school_manager/core/theme/app_colors.dart';
import 'package:school_manager/core/theme/app_theme.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/features/auth/auth_service.dart';
import 'package:school_manager/features/auth/login_page.dart';
import 'package:school_manager/features/dashboard/dashboard_page.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/leave_repository.dart';
import 'package:school_manager/data/repositories/teacher_repository.dart';
import 'package:school_manager/features/setup/setup_wizard.dart';
import 'package:school_manager/features/shell/app_shell.dart';
import 'package:school_manager/features/attendance/attendance_page.dart';
import 'package:school_manager/features/classes/classes_page.dart';
import 'package:school_manager/features/leave/leave_page.dart';
import 'package:school_manager/data/repositories/device_repository.dart';
import 'package:school_manager/data/repositories/message_repository.dart';
import 'package:school_manager/data/repositories/notification_repository.dart';
import 'package:school_manager/features/id_cards/id_cards_page.dart';
import 'package:school_manager/data/repositories/exam_repository.dart';
import 'package:school_manager/data/repositories/staff_repository.dart';
import 'package:school_manager/data/repositories/timetable_repository.dart';
import 'package:school_manager/data/repositories/fee_repository.dart';
import 'package:school_manager/data/repositories/payroll_repository.dart';
import 'package:school_manager/data/repositories/user_repository.dart';
import 'package:school_manager/features/exams/exams_page.dart';
import 'package:school_manager/features/fees/fees_page.dart';
import 'package:school_manager/features/payroll/payroll_page.dart';
import 'package:school_manager/features/users/users_page.dart';
import 'package:school_manager/features/exams/mark_sheet.dart';
import 'package:school_manager/features/exams/results_view.dart';
import 'package:school_manager/features/messages/messages_page.dart';
import 'package:school_manager/features/staff/staff_page.dart';
import 'package:school_manager/features/timetable/timetable_page.dart';
import 'package:school_manager/features/settings/settings_page.dart';
import 'package:school_manager/server/api_router.dart';
import 'package:school_manager/server/local_server.dart';
import 'package:school_manager/features/teachers/teachers_page.dart';
import 'package:school_manager/features/students/admission_wizard.dart';
import 'package:school_manager/features/students/students_page.dart';

/// د UI سکرین‌شاټونه — پرته له دې چې پروګرام په ویندوز کې وځغلوو.
///
/// Flutter د ازموینې دننه ریښتیني ویجیټونه رسموي او PNG ته يې لیکي.
/// دا هماغه رینډر انجن دی چې په ویندوز کې ځغلي، نو عکس ریښتینی دی.
///
/// چلول:  flutter test test/screenshots_test.dart --update-goldens
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  testWidgets('01 — د لومړي ران ویزارډ', (tester) async {
    await _shoot(
      tester,
      name: '01-setup-wizard',
      child: SetupWizard(
        config: const AppConfig(),
        onLocaleChanged: (_) {},
        onComplete: (_) async {},
      ),
    );
  });

  testWidgets('02 — د ننوتلو پاڼه', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await _shoot(
      tester,
      name: '02-login',
      child: LoginPage(
        auth: AuthService(db),
        schoolName: 'د نور لیسه',
        onSignedIn: (_) {},
      ),
    );
  });

  testWidgets('03 — ډاشبورډ (روښانه)', (tester) async {
    await _shoot(
      tester,
      name: '03-dashboard-light',
      child: AppShell(
        session: _session,
        schoolName: 'د نور لیسه',
        stats: _stats,
        themeMode: ThemeMode.light,
        onThemeChanged: (_) {},
        onSignOut: () {},
      ),
    );
  });

  testWidgets('04 — ډاشبورډ (تیاره)', (tester) async {
    await _shoot(
      tester,
      name: '04-dashboard-dark',
      brightness: Brightness.dark,
      child: AppShell(
        session: _session,
        schoolName: 'د نور لیسه',
        stats: _stats,
        themeMode: ThemeMode.dark,
        onThemeChanged: (_) {},
        onSignOut: () {},
      ),
    );
  });

  testWidgets('05 — ډاشبورډ (ټول شوی سایډبار)', (tester) async {
    await _shoot(
      tester,
      name: '05-dashboard-collapsed',
      child: AppShell(
        session: _session,
        schoolName: 'د نور لیسه',
        stats: _stats,
        themeMode: ThemeMode.light,
        onThemeChanged: (_) {},
        onSignOut: () {},
      ),
      after: (tester) async {
        // د سایډبار د ټولولو تڼۍ — تر ټولو وروستۍ InkWell په سایډبار کې.
        await tester.tap(find.byIcon(Icons.chevron_right_rounded));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('07 — د شاګردانو لیست', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);

    await _shoot(
      tester,
      name: '07-students',
      settle: const Duration(milliseconds: 400),
      child: Scaffold(body: StudentsPage(repo: StudentRepository(db))),
    );
  });

  testWidgets('08 — د شاګردانو تش لیست', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);

    await _shoot(
      tester,
      name: '08-students-empty',
      settle: const Duration(milliseconds: 400),
      child: Scaffold(body: StudentsPage(repo: StudentRepository(db))),
    );
  });

  testWidgets('09 — د داخلې ویزارډ (شاګرد)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);

    await _shoot(
      tester,
      name: '09-admission-student',
      settle: const Duration(milliseconds: 500),
      child: Scaffold(body: _wizard(db)),
    );
  });

  testWidgets('10 — د داخلې ویزارډ (ټولګی)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);

    await _shoot(
      tester,
      name: '10-admission-class',
      settle: const Duration(milliseconds: 500),
      child: Scaffold(body: _wizard(db)),
      after: (tester) async {
        // نوم او د پلار نوم ډکوو، بیا دوه ګامه مخکې ځو.
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'احمد');
        await tester.enterText(fields.at(2), 'محمود');
        await tester.pumpAndSettle();
        for (var i = 0; i < 2; i++) {
          await tester.tap(find.text('بل'));
          await tester.pumpAndSettle();
        }
      },
    );
  });

  testWidgets('11 — د داخلې ویزارډ (بیاکتنه)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);

    await _shoot(
      tester,
      name: '11-admission-review',
      settle: const Duration(milliseconds: 500),
      child: Scaffold(body: _wizard(db)),
      after: (tester) async {
        final fields = find.byType(TextField);
        await tester.enterText(fields.at(0), 'احمد');
        await tester.enterText(fields.at(1), 'ولي');
        await tester.enterText(fields.at(2), 'محمود');
        await tester.pumpAndSettle();
        await tester.tap(find.text('بل'));
        await tester.pumpAndSettle();
        // د سرپرست تلیفون، بیا ټولګي ګام ته.
        await tester.enterText(find.byType(TextField).at(1), '0701234567');
        await tester.pumpAndSettle();
        await tester.tap(find.text('بل'));
        await tester.pumpAndSettle();
        // یو بخش وټاکه، بیا بیاکتنې ته.
        await tester.tap(find.text('لسم — الف'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('بل'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('12 — د آی‌ډي کارتونه', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);

    await _shoot(
      tester,
      name: '12-id-cards',
      settle: const Duration(milliseconds: 600),
      child: Scaffold(
        body: IdCardsPage(
          students: StudentRepository(db),
          academic: AcademicRepository(db),
          schoolName: 'د نور لیسه',
        ),
      ),
    );
  });

  testWidgets('13 — استادان', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedTeachers(db);

    await _shoot(
      tester,
      name: '13-teachers',
      settle: const Duration(milliseconds: 500),
      child: Scaffold(
        body: TeachersPage(repo: TeacherRepository(db), session: _session),
      ),
    );
  });

  testWidgets('14 — ټولګي او بخشونه', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedTeachers(db);

    await _shoot(
      tester,
      name: '14-classes',
      settle: const Duration(milliseconds: 500),
      child: Scaffold(
        body: ClassesPage(
          academic: AcademicRepository(db),
          teachers: TeacherRepository(db),
        ),
      ),
    );
  });

  testWidgets('15 — حاضري (د سکین پرده)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    final att = AttendanceRepository(db);

    // څو سکینونه چې پرده ژوندۍ وښیي.
    for (final (no, h, m) in [
      ('1405-0001', 7, 32),
      ('1405-0002', 7, 41),
      ('1405-0003', 7, 58),
    ]) {
      await att.checkIn(
        input: no,
        now: DateTime(2026, 5, 12, h, m),
        byUserId: 1,
        withRules: const AttendanceRules(),
      );
    }

    await _shoot(
      tester,
      name: '15-attendance',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: AttendancePage(
          attendance: att,
          academic: AcademicRepository(db),
          session: _session,
          clock: () => DateTime(2026, 5, 12, 8, 2),
        ),
      ),
      after: (tester) async {
        // یو سکین د پردې پر مخ وکړه چې لویه پایله ښکاره شي.
        await tester.enterText(find.byType(TextField), '1405-0004');
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('16 — اجازت نامې', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedLeaves(db);

    await _shoot(
      tester,
      name: '16-leave',
      settle: const Duration(milliseconds: 500),
      child: Scaffold(
        body: LeavePage(repo: LeaveRepository(db), session: _session),
      ),
    );
  });

  testWidgets('17 — پیغامونه (د غیرحاضرۍ خبرتیا)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedAbsences(db);

    await _shoot(
      tester,
      name: '17-messages-compose',
      settle: const Duration(milliseconds: 600),
      child: Scaffold(
        body: MessagesPage(
          messages: MessageRepository(db),
          attendance: AttendanceRepository(db),
          notifications: NotificationRepository(db),
          session: _session,
          schoolName: 'د نور لیسه',
          clock: () => DateTime(2026, 5, 12, 9, 15),
        ),
      ),
    );
  });

  testWidgets('18 — د پیغامونو تاریخچه', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedAbsences(db);
    await _seedSentMessages(db);

    await _shoot(
      tester,
      name: '18-messages-log',
      settle: const Duration(milliseconds: 600),
      child: Scaffold(
        body: MessagesPage(
          messages: MessageRepository(db),
          attendance: AttendanceRepository(db),
          notifications: NotificationRepository(db),
          session: _session,
          schoolName: 'د نور لیسه',
          clock: () => DateTime(2026, 5, 12, 9, 15),
        ),
      ),
      after: (tester) async {
        await tester.tap(find.text('د لېږلو تاریخچه'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('19 — تنظیمات: اړیکه او وسایل', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedDevices(db);

    await _shoot(
      tester,
      name: '19-settings-connect',
      settle: const Duration(milliseconds: 600),
      child: Scaffold(
        body: SettingsPage(
          db: db,
          devices: DeviceRepository(db),
          server: LocalServer(ApiDeps.of(db, schoolName: () => 'د نور لیسه')),
          session: _session,
          config: const AppConfig(
            databasePath: r'D:\\SchoolData\\school.db',
            setupComplete: true,
          ),
          onConfigChanged: (_) {},
          schoolName: 'د نور لیسه',
          // ریښتینې شبکه نه پوښتو — د ازموینې دننه I/O نه ځواب کوي،
          // او عکس باید هره ورځ یو شان وي.
          lanLookup: (port) async => [
            LanEndpoint(
              interfaceName: 'Wi-Fi',
              address: '192.168.1.14',
              port: port,
            ),
            LanEndpoint(
              interfaceName: 'Ethernet',
              address: '10.0.0.7',
              port: port,
            ),
          ],
        ),
      ),
    );
  });

  testWidgets('20 — پیغامونه (تیاره)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedAbsences(db);

    await _shoot(
      tester,
      name: '20-messages-dark',
      brightness: Brightness.dark,
      settle: const Duration(milliseconds: 600),
      child: Scaffold(
        body: MessagesPage(
          messages: MessageRepository(db),
          attendance: AttendanceRepository(db),
          notifications: NotificationRepository(db),
          session: _session,
          schoolName: 'د نور لیسه',
          clock: () => DateTime(2026, 5, 12, 9, 15),
        ),
      ),
    );
  });

  testWidgets('21 — مهالویش', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedTeachers(db);
    await _seedTimetable(db);

    await _shoot(
      tester,
      name: '21-timetable',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: TimetablePage(
          timetable: TimetableRepository(db),
          academic: AcademicRepository(db),
          teachers: TeacherRepository(db),
        ),
      ),
    );
  });

  testWidgets('22 — ازموینې', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedExam(db);

    await _shoot(
      tester,
      name: '22-exams',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: ExamsPage(
          exams: ExamRepository(db),
          academic: AcademicRepository(db),
          session: _session,
          schoolName: 'د نور لیسه',
        ),
      ),
    );
  });

  testWidgets('23 — د نمرو لیکل', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    final exam = await _seedExam(db);

    await _shoot(
      tester,
      name: '23-mark-sheet',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: MarkSheetView(
          exams: ExamRepository(db),
          exam: exam,
          sections: await AcademicRepository(db).sections(),
          session: _session,
          onBack: () {},
        ),
      ),
    );
  });

  testWidgets('24 — د ازموینې پایلې', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    final exam = await _seedExam(db, withMarks: true);

    await _shoot(
      tester,
      name: '24-results',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: ResultsView(
          exams: ExamRepository(db),
          exam: exam,
          sections: await AcademicRepository(db).sections(),
          schoolName: 'د نور لیسه',
          onBack: () {},
          onPrint: (_) async {},
        ),
      ),
    );
  });

  testWidgets('25 — کارمندان', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedTeachers(db);
    await _seedStaff(db);

    await _shoot(
      tester,
      name: '25-staff',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: StaffPage(repo: StaffRepository(db), session: _session),
      ),
    );
  });

  testWidgets('26 — مهالویش (تیاره)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedTeachers(db);
    await _seedTimetable(db);

    await _shoot(
      tester,
      name: '26-timetable-dark',
      brightness: Brightness.dark,
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: TimetablePage(
          timetable: TimetableRepository(db),
          academic: AcademicRepository(db),
          teachers: TeacherRepository(db),
        ),
      ),
    );
  });

  testWidgets('27 — فیس او تادیې', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedFees(db);

    await _shoot(
      tester,
      name: '27-fees',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: FeesPage(
          fees: FeeRepository(db),
          academic: AcademicRepository(db),
          session: _session,
        ),
      ),
    );
  });

  testWidgets('28 — پوروړي', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedFees(db);

    await _shoot(
      tester,
      name: '28-fee-defaulters',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: FeesPage(
          fees: FeeRepository(db),
          academic: AcademicRepository(db),
          session: _session,
        ),
      ),
      after: (tester) async {
        await tester.tap(find.text('پوروړي'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('29 — معاشونه', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedTeachers(db);
    await _seedStaff(db);
    await _seedPayroll(db);

    await _shoot(
      tester,
      name: '29-payroll',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: PayrollPage(payroll: PayrollRepository(db), session: _session),
      ),
    );
  });

  testWidgets('30 — کاروونکي او اجازې', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedUsers(db);

    await _shoot(
      tester,
      name: '30-users',
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: UsersPage(users: UserRepository(db), session: _session),
      ),
    );
  });

  testWidgets('31 — فیس (تیاره)', (tester) async {
    final db = AppDatabase.memory();
    addTearDown(db.close);
    await _seedSchool(db);
    await _seedFees(db);

    await _shoot(
      tester,
      name: '31-fees-dark',
      brightness: Brightness.dark,
      settle: const Duration(milliseconds: 700),
      child: Scaffold(
        body: FeesPage(
          fees: FeeRepository(db),
          academic: AcademicRepository(db),
          session: _session,
        ),
      ),
    );
  });

  testWidgets('06 — ډاشبورډ په انګلیسي (LTR)', (tester) async {
    await _shoot(
      tester,
      name: '06-dashboard-english',
      locale: AppLocale.en,
      child: AppShell(
        session: _session,
        schoolName: 'Noor High School',
        stats: _stats,
        themeMode: ThemeMode.light,
        onThemeChanged: (_) {},
        onSignOut: () {},
      ),
    );
  });
}

// ═══════════════════════════════════════════════════════════
//  نمونه ډیټا — د یوه ریښتیني ښوونځي په څېر
// ═══════════════════════════════════════════════════════════

// `Session` اوس د اجازو یو شی جوړوي، نو const نه دی.
final _session = Session(
  userId: 1,
  username: 'admin',
  fullName: 'الیاس عمر',
  role: 'admin',
);

const _stats = DashboardStats(
  totalStudents: 842,
  presentToday: 795,
  absentToday: 47,
  lateToday: 23,
  feesCollectedPercent: 78,
  weeklyAttendance: [88, 94, 91, 96, 89, 93],
  weekdayLabels: ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه'],
  attention: [
    AttentionItem(
      'احمد ولي — ۳ ورځې پرله‌پسې غیرحاضر',
      AppColors.danger,
      Icons.person_off_rounded,
    ),
    AttentionItem(
      '۵ اجازت نامې د تصویب په تمه',
      AppColors.warning,
      Icons.pending_actions_rounded,
    ),
    AttentionItem(
      '۱۲ کورنیو دا میاشت فیس نه دی ورکړی',
      AppColors.danger,
      Icons.payments_rounded,
    ),
    AttentionItem(
      'د ۹‑ب ټولګي استاد نن نشته',
      AppColors.warning,
      Icons.school_rounded,
    ),
    AttentionItem(
      'ورځنی بیک‌اپ بریالی و',
      AppColors.success,
      Icons.cloud_done_rounded,
    ),
  ],
);

// ═══════════════════════════════════════════════════════════
//  د عکس اخیستلو چوکاټ
// ═══════════════════════════════════════════════════════════

const Size _windowSize = Size(1440, 900);

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  required Widget child,
  Brightness brightness = Brightness.light,
  AppLocale locale = AppLocale.ps,
  Duration settle = const Duration(milliseconds: 50),
  Future<void> Function(WidgetTester)? after,
}) async {
  await tester.binding.setSurfaceSize(_windowSize);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  await tester.pumpWidget(
    LocaleScope(
      locale: locale,
      setLocale: (_) {},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(brightness),
        home: Directionality(textDirection: locale.direction, child: child),
      ),
    ),
  );

  // انیمیشنونه پای ته ورسوه — چې عکس د وروستي حالت وي، نه د نیمګړي.
  await tester.pumpAndSettle(settle);
  await after?.call(tester);

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screenshots/$name.png'),
  );
}

/// ریښتیني فونټونه بار کوي.
///
/// له دې پرته Flutter د ازموینې په مهال «Ahem» فونټ کاروي چې هر توری
/// يې تور چوکاټ دی — عکس به بېکاره و.
Future<void> _loadFonts() async {
  await _load('Vazirmatn', [
    'assets/fonts/Vazirmatn-Regular.ttf',
    'assets/fonts/Vazirmatn-Medium.ttf',
    'assets/fonts/Vazirmatn-SemiBold.ttf',
    'assets/fonts/Vazirmatn-Bold.ttf',
  ]);

  // د Material نښې د Flutter SDK له کیش څخه راځي.
  final iconFont = _findMaterialIcons();
  if (iconFont != null) {
    await _load('MaterialIcons', [iconFont]);
  }
}

Future<void> _load(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final file = File(path);
    if (!file.existsSync()) continue;
    final bytes = await file.readAsBytes();
    loader.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await loader.load();
}

/// د نښو فونټ پیدا کوي.
///
/// د ثابت مسیر اټکل نه کوو — د ازموینې اجرا کېدای شي `flutter_tester`
/// وي یا `dart`، او هر یو په بېل ژوروالي کې دی. نو له اجرا څخه پورته
/// ځو تر څو هغه پوښۍ ومومو چې `artifacts/material_fonts` لري.
String? _findMaterialIcons() {
  const tail = 'artifacts/material_fonts/MaterialIcons-Regular.otf';
  var dir = File(Platform.resolvedExecutable).parent;

  for (var i = 0; i < 8; i++) {
    final candidate = File('${dir.path}/$tail');
    if (candidate.existsSync()) return candidate.path;
    final parent = dir.parent;
    if (parent.path == dir.path) break; // د فایل سیسټم سر ته ورسېدو
    dir = parent;
  }
  return null;
}

/// نمونه ښوونځی — ټولګي، بخشونه او ۱۴ شاګردان.
Future<void> _seedSchool(AppDatabase db) async {
  final yearId = await db
      .into(db.academicYears)
      .insert(
        AcademicYearsCompanion.insert(
          label: '۱۴۰۵',
          startsOn: DateTime(2026, 3, 21),
          endsOn: DateTime(2026, 12, 21),
          isCurrent: const Value(true),
        ),
      );

  final sections = <int>[];
  for (final (name, level) in [('نهم', 9), ('لسم', 10), ('یوولسم', 11)]) {
    final gradeId = await db
        .into(db.grades)
        .insert(GradesCompanion.insert(name: name, level: level));
    for (final sec in ['الف', 'ب']) {
      sections.add(
        await db
            .into(db.sections)
            .insert(
              SectionsCompanion.insert(
                gradeId: gradeId,
                academicYearId: yearId,
                name: sec,
              ),
            ),
      );
    }
  }

  const names = [
    ('احمد', 'ولي', 'محمود', 'male'),
    ('زرغونه', 'نوري', 'عبدالرحمن', 'female'),
    ('کریم', 'الله', 'رحیم', 'male'),
    ('مرسل', 'احمدي', 'نجیب', 'female'),
    ('بلال', 'خان', 'شیرخان', 'male'),
    ('حبیبه', 'صافي', 'ګل احمد', 'female'),
    ('نصرت', 'الله', 'عزیز', 'male'),
    ('پلوشه', 'کریمي', 'محمد نبي', 'female'),
    ('عمران', 'زدران', 'دولت', 'male'),
    ('شکریه', 'رحیمي', 'فضل', 'female'),
    ('سمیع', 'الله', 'نور محمد', 'male'),
    ('ملالۍ', 'ټوخي', 'اسدالله', 'female'),
    ('فیصل', 'یوسفزی', 'یوسف', 'male'),
    ('عایشه', 'حیدري', 'حیدر', 'female'),
  ];

  // د `admit()` له لارې ثبتوو، نه مستقیم — چې د QR پټ کلی جوړ شي
  // او کارتونه ریښتینی QR وښیي، نه تش چوکاټ.
  final repo = StudentRepository(db);
  for (var i = 0; i < names.length; i++) {
    final (first, last, father, gender) = names[i];
    await repo.admit(
      student: StudentsCompanion.insert(
        admissionNo: '1405-${(i + 1).toString().padLeft(4, '0')}',
        firstName: first,
        lastName: Value(last),
        fatherName: father,
        gender: gender,
        phone: Value('070${(1234567 + i * 4321)}'),
        status: Value(i == 12 ? 'suspended' : 'active'),
      ),
      guardians: [
        GuardiansCompanion.insert(fullName: father, relation: 'father'),
      ],
      sectionId: sections[i % sections.length],
      academicYearId: yearId,
      rollNo: (i ~/ sections.length) + 1,
      byUserId: 1,
      byUserName: 'admin',
    );
  }

  // **د QR کلي ثابتول.** `admit()` هر شاګرد ته تصادفي کلید ورکوي —
  // هغه په تولید کې سم دی، خو دلته د گولډن عکس هر ځل بدلوي او
  // پرتله يې بې‌ځایه سره کوي. نو د عکسونو لپاره ثابت کلي ورکوو.
  await db.customUpdate(
    "UPDATE students SET qr_secret = 'demo-key-' || admission_no",
    updates: {db.students},
  );
}

Widget _wizard(AppDatabase db) => AdmissionWizard(
  students: StudentRepository(db),
  academic: AcademicRepository(db),
  session: _session,
  onAdmitted: (_, __) {},
  onCancel: () {},
);

/// نمونه استادان — یو يې د لومړي بخش مشر.
Future<void> _seedTeachers(AppDatabase db) async {
  final repo = TeacherRepository(db);
  const people = [
    ('محمد نعیم صافي', 'ریاضي', 'male'),
    ('زرغونه احمدي', 'بیولوژي', 'female'),
    ('عبدالباري کریمي', 'فزیک', 'male'),
    ('حبیبه نوري', 'پښتو', 'female'),
    ('نصرالله زدران', 'کیمیا', 'male'),
    ('مرسل حیدري', 'انګلیسي', 'female'),
  ];

  final ids = <int>[];
  for (var i = 0; i < people.length; i++) {
    final (name, spec, gender) = people[i];
    ids.add(
      await repo.add(
        teacher: TeachersCompanion.insert(
          employeeNo: await repo.nextEmployeeNo(),
          fullName: name,
          gender: gender,
          specialization: Value(spec),
          phone: Value('070${3216549 + i * 1111}'),
          qualification: const Value('لیسانس'),
          monthlySalary: Value(12000 + i * 500),
        ),
        byUserId: 1,
        byUserName: 'admin',
      ),
    );
  }

  // لومړیو دریو بخشونو ته مشر استادان وټاکه.
  final sections = await AcademicRepository(db).sections();
  for (var i = 0; i < 3 && i < sections.length; i++) {
    await repo.assignHomeroom(
      sectionId: sections[i].sectionId,
      teacherId: ids[i],
    );
  }
}

/// نمونه اجازت نامې — درې د تمې په حال، یوه منل شوې.
Future<void> _seedLeaves(AppDatabase db) async {
  final repo = LeaveRepository(db);
  final students = await db.select(db.students).get();

  const cases = [
    ('sick', 0, 2),
    ('family', 1, 1),
    ('travel', 3, 7),
    ('official', 0, 0),
  ];

  for (var i = 0; i < cases.length && i < students.length; i++) {
    final (reason, fromOffset, toOffset) = cases[i];
    final id = await repo.request(
      studentId: students[i].id,
      reasonType: reason,
      fromDate: DateTime(2026, 5, 12).add(Duration(days: fromOffset)),
      toDate: DateTime(2026, 5, 12).add(Duration(days: toOffset)),
    );
    if (i == 3) {
      await repo.decide(
        leaveId: id,
        approve: true,
        byUserId: 1,
        byUserName: 'admin',
      );
    }
  }
}

/// د غیرحاضرۍ ورځ — چې د پیغامونو پاڼه څه ولري چې وښیي.
Future<void> _seedAbsences(AppDatabase db) async {
  final att = AttendanceRepository(db);
  final day = DateTime(2026, 5, 12);

  // ځینې راغلي، ځینې نه — بیا ورځ تړو چې پاتې غیرحاضر شي.
  for (final no in ['1405-0001', '1405-0002', '1405-0005', '1405-0007']) {
    await att.checkIn(
      input: no,
      now: DateTime(2026, 5, 12, 7, 35),
      byUserId: 1,
      withRules: const AttendanceRules(),
    );
  }

  // د تېرو ورځو غیرحاضري — چې «د میاشتې غیرحاضري» ستنه ژوندۍ وي.
  final students = await db.select(db.students).get();
  for (var back = 1; back <= 6; back++) {
    final d = day.subtract(Duration(days: back));
    await att.markRoster(
      sectionId: 1,
      date: d,
      statusByStudentId: {
        for (var i = 0; i < students.length; i++)
          students[i].id: (i + back) % 4 == 0 ? 'absent' : 'present',
      },
      byUserId: 1,
    );
  }

  await att.lockDay(date: day, byUserId: 1);
}

/// څو تللي پیغامونه — چې «تاریخچه» ټب تش نه وي.
Future<void> _seedSentMessages(AppDatabase db) async {
  final repo = MessageRepository(db);
  await repo.ensureDefaultTemplates();

  final absent = await AttendanceRepository(
    db,
  ).absentees(DateTime(2026, 5, 12));

  // د لومړیو دریو کورونو اپ تړل شوی — نو هغه بریالي دي، پاتې ناکام.
  final devices = DeviceRepository(db);
  final links = await db.select(db.studentGuardians).get();
  for (final a in absent.take(3)) {
    final link = links.firstWhere((l) => l.studentId == a.student.id);
    final code = await devices.createCode(
      role: 'parent',
      guardianId: link.guardianId,
    );
    await devices.redeem(
      code: code.code,
      deviceName: 'د ${a.student.firstName} کور',
      now: DateTime(2026, 5, 12, 8, 0),
    );
  }

  await repo.notifyAbsentees(
    date: DateTime(2026, 5, 12),
    studentIds: absent.map((a) => a.student.id).toList(),
    byUserId: 1,
    schoolName: 'د نور لیسه',
    now: DateTime(2026, 5, 12, 9, 5),
  );
}

/// څو تړل شوي تلیفونونه — د تنظیماتو د پاڼې لپاره.
Future<void> _seedDevices(AppDatabase db) async {
  final devices = DeviceRepository(db);
  final links = await db.select(db.studentGuardians).get();

  final manager = await devices.createCode(
    role: 'manager',
    userId: 1,
    now: DateTime(2026, 5, 12, 8, 0),
  );
  await devices.redeem(
    code: manager.code,
    deviceName: 'د مدیر Samsung A54',
    now: DateTime(2026, 5, 12, 8, 1),
  );

  // **هر وسیلې ته جلا وخت.** لیست د `paired_at` له مخې ترتیبېږي؛
  // که دوه وسیلې هماغه وخت ولري، SQLite يې ترتیب خپله ټاکي او د
  // گولډن عکس هر ځل بدلېږي.
  for (final (i, link) in links.take(2).indexed) {
    final c = await devices.createCode(
      role: 'parent',
      guardianId: link.guardianId,
      now: DateTime(2026, 5, 12, 8, 0),
    );
    await devices.redeem(
      code: c.code,
      deviceName: i == 0 ? 'د احمد پلار — Infinix' : 'د زرغونې پلار — Nokia',
      now: DateTime(2026, 5, 12, 8, 3 + i),
    );
  }

  // یو ژوندی کوډ چې لا نه دی کارول شوی — پرده يې ښیي.
  await devices.createCode(role: 'parent', guardianId: links.last.guardianId);

  // **د کوډ ثابتول.** `createCode()` تصادفي شپږ توري جوړوي — هغه په
  // تولید کې سم دی، خو د گولډن عکس يې هر ځل بدلوي. نو د عکس لپاره
  // ثابت کوډ او ثابت وخت ورکوو.
  // پای‌وخت لرې راتلونکي ته — که نه، د ریښتیني ساعت په تېرېدو سره
  // کوډ «ختم شوی» ګڼل کېږي او له پردې ورکېږي.
  await db.customUpdate(
    "UPDATE pairing_codes SET code = 'KX7M4D', expires_at = ? "
    'WHERE used_at IS NULL',
    variables: [Variable<DateTime>(DateTime(2099, 1, 1, 8, 20))],
    updates: {db.pairingCodes},
  );
}

/// د لومړي بخش لپاره یو ډک اونیز مهالویش.
Future<void> _seedTimetable(AppDatabase db) async {
  final academic = AcademicRepository(db);
  final tt = TimetableRepository(db);
  await academic.seedDefaultSubjects();
  await tt.seedDefaultSlots();

  final sections = await academic.sections();
  final section = sections.first;
  final subjects = await academic.subjects();
  final teachers = await db.select(db.teachers).get();
  final slots = (await tt.slots()).where((s) => !s.isBreak).toList();

  // یو منظم جدول — هره ورځ بېل مضمونونه، خو یو استاد دوه ځای نه.
  var pick = 0;
  for (final day in defaultTeachingDays) {
    for (var i = 0; i < slots.length - 2; i++) {
      await tt.setEntry(
        sectionId: section.sectionId,
        dayOfWeek: day,
        slotId: slots[i].id,
        subjectId: subjects[pick % subjects.length].id,
        teacherId: teachers.isEmpty
            ? null
            : teachers[pick % teachers.length].id,
        room: i.isEven ? null : '${101 + (pick % 4)}',
      );
      pick++;
    }
  }
}

/// یوه ازموینه — که `withMarks` سم وي، نمرې يې هم ډکې دي.
Future<Exam> _seedExam(AppDatabase db, {bool withMarks = false}) async {
  final academic = AcademicRepository(db);
  final exams = ExamRepository(db);
  await academic.seedDefaultSubjects();

  final year = (await academic.currentYear())!;
  final sections = await academic.sections();
  final subjects = await academic.subjects();
  final chosen = [
    subjects.firstWhere((s) => s.name == 'ریاضي').id,
    subjects.firstWhere((s) => s.name == 'پښتو').id,
    subjects.firstWhere((s) => s.name == 'انګلیسي').id,
    subjects.firstWhere((s) => s.name == 'اسلامیات').id,
  ];

  final id = await exams.create(
    name: 'د لومړۍ ربعې ازموینه',
    examType: 'midterm',
    academicYearId: year.id,
    startsOn: DateTime(2026, 5, 10),
    endsOn: DateTime(2026, 5, 20),
  );
  for (final gradeId in sections.map((s) => s.gradeId).toSet()) {
    await exams.addSubjects(
      examId: id,
      gradeId: gradeId,
      subjectIds: chosen,
    );
  }

  // یوه دویمه ازموینه چې لیست تش نه وي.
  await exams.create(
    name: 'د میاشتنۍ ازموینه — ثور',
    examType: 'monthly',
    academicYearId: year.id,
    startsOn: DateTime(2026, 4, 12),
    endsOn: DateTime(2026, 4, 14),
  );

  if (withMarks) {
    final section = sections.first;
    final subs = await exams.subjectsOf(id, gradeId: section.gradeId);
    final roster = await db
        .customSelect(
          'SELECT student_id FROM enrollments '
          'WHERE section_id = ? AND is_active = 1',
          variables: [Variable<int>(section.sectionId)],
          readsFrom: {db.enrollments},
        )
        .get();
    final ids = roster.map((r) => r.read<int>('student_id')).toList();

    // **ثابتې نمرې.** تصادفي به د گولډن عکس هر ځل بدل کړ.
    const pattern = [92, 78, 55, 34, 88, 61, 45, 97, 70, 39];
    for (var s = 0; s < subs.length; s++) {
      await exams.saveMarks(
        examSubjectId: subs[s].examSubject.id,
        byStudent: {
          for (var i = 0; i < ids.length; i++)
            ids[i]: (
              obtained: (pattern[(i + s * 3) % pattern.length]).toDouble(),
              isAbsent: i == 2 && s == 1,
            ),
        },
        byUserId: 1,
      );
    }
  }

  return (db.select(db.exams)..where((e) => e.id.equals(id))).getSingle();
}

/// څو کارمندان — د معاشونو ستنه چې تشه نه وي.
Future<void> _seedStaff(AppDatabase db) async {
  const people = [
    ('عبدالغفار', 'محاسب', 'مالي', 18000),
    ('نور محمد', 'سرایدار', 'پاکوالی', 9000),
    ('شیرخان', 'ساتونکی', 'ساتنه', 11000),
    ('حبیب الله', 'د کتابتون مسوول', 'کتابتون', 14000),
    ('زلمی', 'ډرایور', 'ترانسپورت', 12000),
    ('فریده', 'نرس', 'روغتیا', 16000),
    ('اجمل', 'د دفتر مدیر', 'اداري', 22000),
  ];

  final repo = StaffRepository(db);
  for (final (name, job, dep, salary) in people) {
    await repo.add(
      staff: StaffMembersCompanion.insert(
        employeeNo: await repo.nextEmployeeNo(),
        fullName: name,
        jobTitle: job,
        gender: name == 'فریده' ? 'female' : 'male',
        department: Value(dep),
        phone: Value('070${1234567 + salary}'),
        monthlySalary: Value(salary),
      ),
      byUserId: 1,
      byUserName: 'admin',
    );
  }
}

/// دوه میاشتې بلونه، ځینې ورکړل شوي، ځینې نیمګړي.
Future<void> _seedFees(AppDatabase db) async {
  final fees = FeeRepository(db);
  final academic = AcademicRepository(db);
  await fees.seedDefaultTypes();

  final year = (await academic.currentYear())!;
  final monthly = (await fees.types())
      .firstWhere((t) => t.name == 'میاشتنی فیس');

  // **د ورکړې نېټې په قصد یوه تېره او یوه راتلونکې ده.**
  // `isOverdue` د ریښتیني ساعت سره پرتله کوي — که دواړه یوه نېټه
  // وای، عکس به سبا بدل شو. اوس تل یوه دوره «وخت تېر» ښیي او بله
  // «نه دی ورکړل».
  for (final (period, due) in [
    ('1405-04', DateTime(2020, 5, 20)),
    ('1405-05', DateTime(2099, 5, 20)),
  ]) {
    await fees.generate(
      feeTypeId: monthly.id,
      period: period,
      dueDate: due,
      academicYearId: year.id,
      byUserId: 1,
    );
  }

  // **ثابت الګو.** تصادفي به د گولډن عکس هر ځل بدل کړ.
  final invoices = await db.select(db.feeInvoices).get()
    ..sort((a, b) => a.id.compareTo(b.id));
  for (final (i, inv) in invoices.indexed) {
    switch (i % 4) {
      case 0:
        await fees.pay(
          invoiceId: inv.id,
          amount: 500,
          byUserId: 1,
          now: DateTime(2026, 5, 12, 9),
        );
      case 1:
        await fees.pay(
          invoiceId: inv.id,
          amount: 200,
          byUserId: 1,
          now: DateTime(2026, 5, 12, 10),
        );
      case 2:
        if (i == 2) {
          await fees.waive(inv.id, reason: 'یتیم', byUserId: 1);
        }
      default:
        break; // نه‌ورکړل شوی پاتې کېږي.
    }
  }
}

/// یوه د معاشونو دوره، له څو کسرونو سره.
Future<void> _seedPayroll(AppDatabase db) async {
  final payroll = PayrollRepository(db);
  final runId = await payroll.createRun(period: '1405-05', byUserId: 1);

  final items = await payroll.items(runId);
  for (final (i, item) in items.indexed) {
    if (i % 3 == 0) {
      await payroll.updateItem(
        itemId: item.id,
        allowances: 2000,
      );
    } else if (i % 3 == 1) {
      await payroll.updateItem(
        itemId: item.id,
        absenceDeduction: 800,
        absentDays: 2,
      );
    }
  }

  // یوه تېره دوره چې ورکړل شوې — لیست تش نه وي.
  final old = await payroll.createRun(period: '1405-04', byUserId: 1);
  await payroll.approve(old, byUserId: 1);
  await payroll.markPaid(old, at: DateTime(2026, 4, 30));
}

/// څو کاروونکي په بېلو رولونو.
Future<void> _seedUsers(AppDatabase db) async {
  final users = UserRepository(db);
  const people = [
    ('admin', 'الیاس عمر', 'admin'),
    ('naeem', 'محمد نعیم صافي', 'deputy'),
    ('zarghuna', 'زرغونه احمدي', 'teacher'),
    ('ghaffar', 'عبدالغفار', 'accountant'),
    ('reception', 'سمیع الله', 'reception'),
  ];

  for (final (username, name, role) in people) {
    await users.create(
      username: username,
      fullName: name,
      password: 'temporary-pass',
      role: role,
      byUserId: 1,
      byUserName: 'admin',
    );
  }

  // یو غیرفعال حساب — چې پرده دواړه حالتونه وښيي.
  final all = await users.list();
  await users.setActive(
    userId: all.firstWhere((u) => u.user.username == 'reception').user.id,
    active: false,
    byUserId: 1,
    byUserName: 'admin',
  );

  // یوه شخصي اجازه — «*» نښه پرې راځي.
  await users.updatePermissions(
    userId: all.firstWhere((u) => u.user.username == 'zarghuna').user.id,
    permissions: {
      'fees': {'view'},
    },
    byUserId: 1,
    byUserName: 'admin',
  );
}
