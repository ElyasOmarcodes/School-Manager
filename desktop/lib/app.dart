import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/l10n/strings.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'data/db/database.dart';
import 'data/repositories/academic_repository.dart';
import 'data/repositories/attendance_repository.dart';
import 'data/repositories/device_repository.dart';
import 'data/repositories/leave_repository.dart';
import 'data/repositories/message_repository.dart';
import 'data/repositories/notification_repository.dart';
import 'data/repositories/student_repository.dart';
import 'data/repositories/teacher_repository.dart';
import 'server/api_router.dart';
import 'server/local_server.dart';
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

  /// د ښوونځي محلي سرور — د موبایل اپ لپاره.
  ///
  /// **ولې پخپله نه چالانېږي؟** ځکه چې یو سرور د شبکې پورټ نیسي.
  /// که پروګرام هر ځل پرته له پوښتنې پورټ ونیسي، د ویندوز فایروال
  /// به هر ځل پوښتنه وکړي او مدیر به ونه پوهېږي ولې. نو تر هغې
  /// ولاړ دی چې مدیر يې په تنظیماتو کې چالان کړي.
  LocalServer? _server;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _server?.stop();
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
    await _prepareServer(db);
  }

  /// سرور جوړوي (خو نه يې چالانوي) او تلوالې کینډۍ کېږدي.
  Future<void> _prepareServer(AppDatabase db) async {
    await MessageRepository(db).ensureDefaultTemplates();
    _server = LocalServer(
      ApiDeps.of(db, schoolName: () => _schoolName),
    );
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

    _schoolName = school?.name ?? r.schoolName;
    await _prepareServer(db);

    if (!mounted) return;
    setState(() {
      _config = cfg;
      _db = db;
      _auth = auth;
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

  /// د ډاشبورډ شمېرې — اوس د حاضرۍ له ریښتیني جدول څخه راځي.
  Future<DashboardStats> _loadStats() async {
    final db = _db;
    if (db == null) return DashboardStats.empty;

    final att = AttendanceRepository(db);
    final today = DateTime.now();
    final summary = await att.summary(today);

    // د تېرو شپږو ورځو سلنه — د ډاشبورډ د کرښې چارټ لپاره.
    final weekly = <double>[];
    final labels = <String>[];
    const dayNames = ['د', 'س', 'چ', 'پ', 'ج', 'ش', 'ی'];
    for (var i = 5; i >= 0; i--) {
      final d = today.subtract(Duration(days: i));
      final s = await att.summary(d);
      weekly.add(s.total == 0 ? 0 : s.presentPercent);
      labels.add(dayNames[d.weekday - 1]);
    }

    // هغه شاګردان چې دې میاشت کې درې یا ډېرې ورځې غیرحاضر دي —
    // مدیر باید له سکرول کولو پرته يې وویني.
    final attention = await att.absentees(today);

    return DashboardStats(
      totalStudents: summary.total,
      presentToday: summary.present,
      absentToday: summary.absent,
      lateToday: summary.late,
      feesCollectedPercent: 0,
      weeklyAttendance: weekly,
      weekdayLabels: labels,
      attention: [
        for (final a in attention.where((a) => a.monthlyAbsences >= 3).take(5))
          AttentionItem(
            '${a.student.firstName} — ${a.className ?? '—'} — '
                'دې میاشت کې ${a.monthlyAbsences} ورځې غیرحاضر',
            a.monthlyAbsences >= 5 ? AppColors.danger : AppColors.warning,
            Icons.event_busy_rounded,
          ),
      ],
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
      attendanceRepo: AttendanceRepository(_db!),
      leaveRepo: LeaveRepository(_db!),
      messageRepo: MessageRepository(_db!),
      notificationRepo: NotificationRepository(_db!),
      deviceRepo: DeviceRepository(_db!),
      server: _server,
      db: _db,
      config: _config,
      onConfigChanged: (c) async {
        await widget.store.save(c);
        if (mounted) setState(() => _config = c);
      },
      themeMode: _themeMode,
      onThemeChanged: _setTheme,
      onSignOut: _signOut,
    ),
  };
}
