import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/l10n/strings.dart';
import 'core/theme/app_theme.dart';
import 'data/db/database.dart';
import 'data/repositories/academic_repository.dart';
import 'data/repositories/student_repository.dart';
import 'data/repositories/teacher_repository.dart';
import 'features/auth/auth_service.dart';
import 'features/auth/login_page.dart';
import 'features/dashboard/dashboard_page.dart';
import 'features/setup/setup_wizard.dart';
import 'features/shell/app_shell.dart';

/// د پروګرام درې حالته: ویزارډ ← ننوتل ← چوکاټ.
enum _Stage { loading, setup, login, ready }

class SchoolManagerApp extends StatefulWidget {
  final ConfigStore store;
  final AppConfig initialConfig;

  const SchoolManagerApp({
    super.key,
    required this.store,
    required this.initialConfig,
  });

  @override
  State<SchoolManagerApp> createState() => _SchoolManagerAppState();
}

class _SchoolManagerAppState extends State<SchoolManagerApp> {
  late AppConfig _config = widget.initialConfig;
  late AppLocale _locale = AppLocale.fromCode(_config.locale);

  _Stage _stage = _Stage.loading;
  AppDatabase? _db;
  AuthService? _auth;
  Session? _session;
  String _schoolName = '';
  DashboardStats _stats = DashboardStats.empty;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _db?.close();
    super.dispose();
  }

  ThemeMode get _themeMode => switch (_config.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  /// پیل: که تنظیمات بشپړ وي او ډیټابیس شتون ولري، ننوتلو ته ځو.
  /// که ډیټابیس نه وي (مثلاً USB ایستل شوی)، بېرته ویزارډ ته.
  Future<void> _boot() async {
    final path = _config.databasePath;

    if (!_config.setupComplete || path == null) {
      setState(() => _stage = _Stage.setup);
      return;
    }

    if (!DatabaseFile.isValidSqlite(path)) {
      // مسیر ورک دی — کارن باید بیا وټاکي، خو تنظیمات نه ورکېږي.
      setState(() => _stage = _Stage.setup);
      return;
    }

    await _openDatabase(path);
    if (!mounted) return;
    setState(() => _stage = _Stage.login);
  }

  Future<void> _openDatabase(String path) async {
    final db = AppDatabase.atPath(path);
    final school = await db.select(db.schools).getSingleOrNull();
    _db = db;
    _auth = AuthService(db);
    _schoolName = school?.name ?? '';
  }

  /// د ویزارډ پای — ډیټابیس جوړوي، ښوونځی ثبتوي، مدیر جوړوي.
  Future<void> _completeSetup(SetupResult r) async {
    final db = AppDatabase.atPath(r.databasePath);
    // لومړی لوستل، چې migrations وځغلي او جدولونه جوړ شي.
    var school = await db.select(db.schools).getSingleOrNull();

    if (school == null) {
      await db
          .into(db.schools)
          .insert(
            SchoolsCompanion.insert(
              name: r.schoolName,
              kind: Value(r.schoolKind),
              address: Value(r.address),
              phone: Value(r.phone),
              dayStart: Value(r.dayStart),
              dayEnd: Value(r.dayEnd),
              lateAfterMinutes: Value(r.lateAfterMinutes),
            ),
          );
      school = await db.select(db.schools).getSingleOrNull();
    }

    // تلواله ټولګي (۱–۱۲، هر یو دوه بخشونه) او روان کال جوړوو.
    // پرته له دې به نوی ښوونځی د داخلې پاڼه پرانیزي او هېڅ ټولګی
    // ونه ویني. له تنظیماتو څخه بدلېدی شي.
    final now = DateTime.now();
    await AcademicRepository(db).seedDefaults(
      yearLabel: '${now.year}',
      startsOn: DateTime(now.year, 1, 1),
      endsOn: DateTime(now.year, 12, 31),
    );

    final auth = AuthService(db);
    // که موجود ډیټابیس پرانیستل شوی وي، مدیر لا شته — دوه ځله يې نه جوړوو.
    final existing = await db.select(db.appUsers).get();
    if (existing.isEmpty) {
      await auth.createUser(
        username: r.adminUsername,
        fullName: r.adminFullName,
        password: r.adminPassword,
        role: 'admin',
      );
    }

    final cfg = _config.copyWith(
      databasePath: r.databasePath,
      calendar: r.calendar,
      locale: _locale.code,
      setupComplete: true,
    );
    await widget.store.save(cfg);

    if (!mounted) return;
    setState(() {
      _config = cfg;
      _db = db;
      _auth = auth;
      _schoolName = school?.name ?? r.schoolName;
      _stage = _Stage.login;
    });
  }

  Future<void> _setLocale(AppLocale l) async {
    final cfg = _config.copyWith(locale: l.code);
    await widget.store.save(cfg);
    if (!mounted) return;
    setState(() {
      _locale = l;
      _config = cfg;
    });
  }

  Future<void> _setTheme(ThemeMode m) async {
    final cfg = _config.copyWith(
      themeMode: switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
    await widget.store.save(cfg);
    if (!mounted) return;
    setState(() => _config = cfg);
  }

  Future<void> _onSignedIn(Session s) async {
    final stats = await _loadStats();
    if (!mounted) return;
    setState(() {
      _session = s;
      _stats = stats;
      _stage = _Stage.ready;
    });
  }

  Future<void> _signOut() async {
    final s = _session;
    if (s != null) await _auth?.signOut(s);
    if (!mounted) return;
    setState(() {
      _session = null;
      _stage = _Stage.login;
    });
  }

  /// د ډاشبورډ شمېرې. اوس یوازې د شاګردانو شمېر ریښتینی دی —
  /// پاتې د دریم پړاو (حاضري) سره ژوندي کېږي.
  Future<DashboardStats> _loadStats() async {
    final db = _db;
    if (db == null) return DashboardStats.empty;

    final students =
        await (db.select(db.students)
              ..where((s) => s.deletedAt.isNull())
              ..where((s) => s.status.equals('active')))
            .get();

    return DashboardStats(
      totalStudents: students.length,
      presentToday: 0,
      absentToday: 0,
      lateToday: 0,
      feesCollectedPercent: 0,
      weeklyAttendance: const [0, 0, 0, 0, 0, 0],
      weekdayLabels: const ['ش', 'ی', 'د', 'س', 'چ', 'پ'],
      attention: const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      locale: _locale,
      setLocale: _setLocale,
      child: MaterialApp(
        title: 'School Manager',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.build(Brightness.light),
        darkTheme: AppTheme.build(Brightness.dark),
        themeMode: _themeMode,
        builder: (context, child) =>
            Directionality(textDirection: _locale.direction, child: child!),
        home: Builder(builder: (context) => _buildStage()),
      ),
    );
  }

  Widget _buildStage() => switch (_stage) {
    _Stage.loading => const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    ),
    _Stage.setup => SetupWizard(
      config: _config,
      onLocaleChanged: _setLocale,
      onComplete: _completeSetup,
    ),
    _Stage.login => LoginPage(
      auth: _auth!,
      schoolName: _schoolName,
      onSignedIn: _onSignedIn,
    ),
    _Stage.ready => AppShell(
      session: _session!,
      schoolName: _schoolName,
      stats: _stats,
      studentRepo: StudentRepository(_db!),
      academicRepo: AcademicRepository(_db!),
      teacherRepo: TeacherRepository(_db!),
      themeMode: _themeMode,
      onThemeChanged: _setTheme,
      onSignOut: _signOut,
    ),
  };
}
