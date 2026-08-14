@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:drift/drift.dart' show Value;
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
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/features/setup/setup_wizard.dart';
import 'package:school_manager/features/shell/app_shell.dart';
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

const _session = Session(
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
  final yearId = await db.into(db.academicYears).insert(
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
        await db.into(db.sections).insert(
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

  for (var i = 0; i < names.length; i++) {
    final (first, last, father, gender) = names[i];
    final id = await db.into(db.students).insert(
          StudentsCompanion.insert(
            admissionNo: '1405-${(i + 1).toString().padLeft(4, '0')}',
            firstName: first,
            lastName: Value(last),
            fatherName: father,
            gender: gender,
            phone: Value('070${(1234567 + i * 4321)}'),
            status: Value(i == 12 ? 'suspended' : 'active'),
          ),
        );
    await db.into(db.enrollments).insert(
          EnrollmentsCompanion.insert(
            studentId: id,
            sectionId: sections[i % sections.length],
            academicYearId: yearId,
            rollNo: Value((i ~/ sections.length) + 1),
          ),
        );
  }
}
