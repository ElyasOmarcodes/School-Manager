import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/tone.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_session_repository.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/fee_repository.dart';
import '../../data/repositories/leave_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/timetable_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../server/local_server.dart';
import '../auth/auth_service.dart';
import '../dashboard/dashboard_page.dart';
import '../attendance/attendance_page.dart';
import '../attendance/live_attendance.dart';
import '../attendance/live_badge.dart';
import '../attendance/session_settings_page.dart';
import '../attendance/sessions_page.dart';
import '../classes/classes_page.dart';
import '../leave/leave_create_page.dart';
import '../leave/leave_page.dart';
import '../students/enroll_page.dart';
import '../students/student_profile_page.dart';
import '../subjects/subjects_page.dart';
import '../exams/combined_results_page.dart';
import '../exams/exam_list_page.dart';
import '../exams/exam_settings_page.dart';
import '../exams/mark_entry_page.dart';
import '../exams/question_papers_page.dart';
import '../exams/results_page.dart';
import '../exams/top_students_page.dart';
import '../fees/fees_page.dart';
import '../id_cards/id_cards_page.dart';
import '../messages/messages_page.dart';
import '../payroll/payroll_page.dart';
import '../reports/reports_page.dart';
import '../settings/settings_page.dart';
import '../staff/staff_page.dart';
import '../students/students_page.dart';
import '../teachers/teachers_page.dart';
import '../timetable/timetable_page.dart';
import '../users/users_page.dart';
import 'nav_items.dart';
import 'sidebar.dart';

/// د پروګرام اصلي چوکاټ — سایډبار، پورتنۍ کرښه، او د منځ پاڼه.
class AppShell extends StatefulWidget {
  final Session session;
  final String schoolName;
  final DashboardStats stats;
  final VoidCallback onSignOut;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode themeMode;
  final StudentRepository? studentRepo;
  final AcademicRepository? academicRepo;
  final TeacherRepository? teacherRepo;
  final AttendanceRepository? attendanceRepo;
  final LeaveRepository? leaveRepo;

  // ── څلورم پړاو ────────────────────────────────────────
  final MessageRepository? messageRepo;
  final NotificationRepository? notificationRepo;
  final DeviceRepository? deviceRepo;
  final LocalServer? server;
  final AppDatabase? db;
  final AppConfig? config;
  final ValueChanged<AppConfig>? onConfigChanged;

  // ── پنځم/شپږم/اووم پړاو ───────────────────────────────
  final TimetableRepository? timetableRepo;
  final ExamRepository? examRepo;
  final StaffRepository? staffRepo;

  // ── اتم/نهم/لسم پړاو ──────────────────────────────────
  final FeeRepository? feeRepo;
  final PayrollRepository? payrollRepo;
  final UserRepository? userRepo;
  final ReportRepository? reportRepo;

  /// د حاضرۍ ناستې — که `null` وي، یوازې د ورځې عمومي حاضري ښکاري.
  final AttendanceSessionRepository? sessionRepo;

  const AppShell({
    super.key,
    required this.session,
    required this.schoolName,
    required this.stats,
    required this.onSignOut,
    required this.onThemeChanged,
    required this.themeMode,
    this.studentRepo,
    this.academicRepo,
    this.teacherRepo,
    this.attendanceRepo,
    this.leaveRepo,
    this.messageRepo,
    this.notificationRepo,
    this.deviceRepo,
    this.server,
    this.db,
    this.config,
    this.onConfigChanged,
    this.timetableRepo,
    this.examRepo,
    this.staffRepo,
    this.feeRepo,
    this.payrollRepo,
    this.userRepo,
    this.reportRepo,
    this.sessionRepo,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _route = '/dashboard';
  bool _expanded = true;

  /// د لیست د بیا-بارولو لپاره — کله چې نوی شاګرد ثبت شي.
  int _studentsRevision = 0;

  /// کوم شاګرد پرانیستل شوی — `null` یعنې لیست ښکاري.
  ///
  /// **دا ولې په shell کې دی؟** ځکه چې د سایډبار هر کلیک يې باید
  /// پاک کړي. که د پاڼې دننه وای، له «مضامین» څخه بېرته راتګ به
  /// هماغه زوړ پروفایل بیا پرانیستی و.
  int? _openStudentId;

  /// کومه د حاضرۍ ناسته پرانیستل شوې — `null` یعنې لیست ښکاري.
  AttendanceSession? _openSession;

  /// کومه ازموینه پرانیستل شوې، او کومه کتنه يې ښکاري.
  Exam? _openExam;

  /// `marks` | `results` | `top` | `combined`
  String _examView = 'marks';

  /// **د شالید حاضري.** د ناستو کړکۍ ګوري او د پورتنۍ کرښې نښه
  /// خبروي — نو مدیر که د فیس پاڼه هم پرانیستې وي، پوهېږي چې د
  /// لیلیه د شپې حاضري پیل شوه.
  LiveAttendance? _live;

  @override
  void initState() {
    super.initState();
    final sessions = widget.sessionRepo;
    final attendance = widget.attendanceRepo;
    if (sessions != null && attendance != null) {
      _live = LiveAttendance(sessions: sessions, attendance: attendance)
        // **چوکاټ پخپله هم اورېدونکی دی**، نه یوازې د `Scope` ماشومان.
        // `GlobalScanListener.enabled` د همدې حال پورې تړلی دی، نو که
        // چوکاټ نه رسمېده، د ناستې پیل به يې سکینر نه و ژوندی کړی.
        ..addListener(_onLiveChanged)
        ..start();
    }
  }

  void _onLiveChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _live?..removeListener(_onLiveChanged)..dispose();
    super.dispose();
  }

  /// د توکي هغه لار چې سرلیک ترې راځي — فرعي لار د مور لار ته ځي.
  NavItem? get _currentItem {
    for (final g in buildNav()) {
      for (final i in g.items) {
        if (i.owns(_route)) return i;
      }
    }
    return null;
  }

  NavSubItem? get _currentSub {
    for (final g in buildNav()) {
      for (final i in g.items) {
        for (final c in i.children) {
          if (c.route == _route) return c;
        }
      }
    }
    return null;
  }

  void _go(String route) {
    setState(() {
      _route = route;
      _openStudentId = null;
      _openSession = null;
      _openExam = null;
      _examView = 'marks';
    });
  }

  /// یو CSV د کارن ټاکلي ځای ته ساتي.
  ///
  /// **ولې دلته او نه په هره پاڼه کې؟** ځکه چې د فایل ساتل د پردې
  /// کار نه دی — هره پاڼه چې يې خپله کوله، هره یوه به بېل چلند
  /// درلود او د تېروتنې پیغامونه به يې سره توپیر درلود.
  Future<void> _saveCsv(String csv, String suggestedName) async {
    final location = await getSaveLocation(suggestedName: suggestedName);
    if (location == null) return;
    await File(location.path).writeAsString(csv);
    if (!mounted) return;
    _toast('فایل وساتل شو: ${location.path}', AppColors.success);
  }

  void _toast(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: color,
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final live = _live;

    final shell = Scaffold(
      backgroundColor: p.ground,
      body: Row(
        children: [
          Sidebar(
            currentRoute: _route,
            permissions: widget.session.permissions,
            expanded: _expanded,
            schoolName: widget.schoolName,
            onToggle: () => setState(() => _expanded = !_expanded),
            onNavigate: _go,
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  item: _currentItem,
                  sub: _currentSub,
                  session: widget.session,
                  onOpenLive: () => _go('/attendance'),
                  themeMode: widget.themeMode,
                  onThemeChanged: widget.onThemeChanged,
                  onSignOut: widget.onSignOut,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.normal,
                    switchInCurve: AppMotion.standard,
                    // د تلواله layoutBuilder ماشومانو ته سست (loose) قیدونه
                    // ورکوي، نو د ډاشبورډ د سکرول پاڼې لوړوالی نامعلوم
                    // پاتې کېږي او رسمېږي نه. `StackFit.expand` قیدونه
                    // ټینګوي — پاڼه د خپل ځای اندازه اخلي او سکرول کوي.
                    layoutBuilder: (current, previous) => Stack(
                      fit: StackFit.expand,
                      children: [...previous, if (current != null) current],
                    ),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.014),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(
                        '$_route/$_openStudentId/${_openSession?.id}',
                      ),
                      child: _buildPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // که د ناستو ذخیره نه وي (زوړ حالت یا ازموینه)، نښه هېڅ نه ښیي —
    // نو د scope نغښتل هم پکار نه دي.
    if (live == null) return shell;

    return LiveAttendanceScope(
      notifier: live,
      child: GlobalScanListener(
        // **یوازې کله چې یوه ناسته روانه وي.** که تل اورېده، د
        // شاګرد د نوم لیکل به يې «سکین» ګڼل او د حاضرۍ ماشین به
        // پرې لګېده.
        enabled: live.isLive && _route != '/attendance',
        onScan: _onBackgroundScan,
        child: shell,
      ),
    );
  }

  /// د شالید یو سکین — پایله يې د پردې پر سر د یوې لنډې پیغام
  /// کرښې په بڼه ښکاري، ځکه چې مدیر بله پاڼه ګوري.
  Future<void> _onBackgroundScan(String input) async {
    final live = _live;
    if (live == null) return;

    final result = await live.scan(
      input: input,
      byUserId: widget.session.userId,
    );
    if (!mounted) return;

    if (result == null) {
      await Tone.play(Tone.error);
      if (!mounted) return;
      _toast('دا شاګرد د روانې ناستې هدف نه دی.', AppColors.warning);
      return;
    }

    await Tone.play(switch (result) {
      CheckInOk() || CheckInCheckedOut() => Tone.accept,
      CheckInOnLeave() || CheckInAlreadyDone() => Tone.warn,
      _ => Tone.error,
    });
    if (!mounted) return;

    _toast(switch (result) {
      CheckInOk(student: final s, status: final st) =>
        '${s.firstName} — ${st == 'late' ? 'ناوخته' : 'حاضر'}',
      CheckInAlreadyDone(student: final s) => '${s.firstName} — مخکې ثبت شوی',
      CheckInOnLeave(student: final s) => '${s.firstName} — رخصت دی',
      CheckInCheckedOut(student: final s) => '${s.firstName} — وتلی',
      CheckInRevokedCard(student: final s) => '${s.firstName} — کارت باطل دی',
      CheckInInvalidCard() => 'ناسم کارت',
      CheckInUnknown(input: final i) => 'ونه پېژندل شو: $i',
    }, switch (result) {
      CheckInOk() || CheckInCheckedOut() => AppColors.success,
      CheckInOnLeave() || CheckInAlreadyDone() => AppColors.info,
      _ => AppColors.danger,
    });
  }

  Widget _buildPage() {
    if (_route == '/dashboard') {
      return DashboardPage(stats: widget.stats);
    }
    final academic = widget.academicRepo;
    final teachers = widget.teacherRepo;
    final students = widget.studentRepo;
    final dbPath = widget.config?.databasePath;

    // ── شاګردان ─────────────────────────────────────────
    if (_route == '/students' && students != null) {
      if (_openStudentId != null && academic != null) {
        return StudentProfilePage(
          studentId: _openStudentId!,
          students: students,
          academic: academic,
          session: widget.session,
          databasePath: dbPath,
          onBack: () => setState(() {
            _openStudentId = null;
            _studentsRevision++;
          }),
        );
      }
      return StudentsPage(
        key: ValueKey('students-$_studentsRevision'),
        repo: students,
        academic: academic,
        onOpenStudent: academic == null
            ? null
            : (id) => setState(() => _openStudentId = id),
        onAddStudent: academic == null
            ? null
            : () => _go('/students/enroll'),
      );
    }

    if (_route == '/students/enroll' &&
        students != null &&
        academic != null) {
      return EnrollPage(
        students: students,
        academic: academic,
        session: widget.session,
        databasePath: dbPath,
        onDone: ({String? message}) {
          setState(() {
            _route = '/students';
            _studentsRevision++;
          });
          if (message != null) _toast(message, AppColors.success);
        },
      );
    }

    if (_route == '/subjects' && academic != null) {
      return SubjectsPage(
        academic: academic,
        canEdit: widget.session.permissions.can('classes', Perm.edit),
      );
    }

    if (_route == '/id-cards' && students != null && academic != null) {
      return IdCardsPage(
        students: students,
        academic: academic,
        schoolName: widget.schoolName,
      );
    }
    // ── حاضري ───────────────────────────────────────────
    final attendance = widget.attendanceRepo;
    final sessions = widget.sessionRepo;

    if (_route == '/attendance' && attendance != null && academic != null) {
      // د ناستو لیست لومړی — بیا سکینر. که ناستې شتون ونه لري
      // (زوړ حالت)، مستقیم سکینر ښکاري.
      if (sessions == null) {
        return AttendancePage(
          attendance: attendance,
          academic: academic,
          session: widget.session,
        );
      }
      if (_openSession != null) {
        return AttendancePage(
          attendance: attendance,
          academic: academic,
          session: widget.session,
          sessions: sessions,
          attendanceSession: _openSession,
          onBack: () => setState(() => _openSession = null),
        );
      }
      return SessionsPage(
        sessions: sessions,
        onOpen: (s) => setState(() => _openSession = s),
        onCreate: widget.session.permissions.can('attendance', Perm.create)
            ? () => _go('/attendance/new')
            : null,
      );
    }

    if ((_route == '/attendance/new' || _route == '/attendance/settings') &&
        sessions != null &&
        academic != null) {
      return SessionSettingsPage(
        key: ValueKey(_route),
        sessions: sessions,
        academic: academic,
        startWithNew: _route == '/attendance/new',
        canEdit: widget.session.permissions.can('attendance', Perm.edit),
      );
    }

    // ── اجازت نامې ──────────────────────────────────────
    if (_route == '/leave' && widget.leaveRepo != null) {
      return LeavePage(repo: widget.leaveRepo!, session: widget.session);
    }
    if (_route == '/leave/new' &&
        widget.leaveRepo != null &&
        students != null &&
        academic != null) {
      return LeaveCreatePage(
        students: students,
        academic: academic,
        leave: widget.leaveRepo!,
        session: widget.session,
        onDone: () => _go('/leave'),
      );
    }
    if (_route == '/teachers' && teachers != null) {
      return TeachersPage(repo: teachers, session: widget.session);
    }
    if (_route == '/classes' && academic != null && teachers != null) {
      return ClassesPage(
        academic: academic,
        teachers: teachers,
        canEdit: widget.session.permissions.can('classes', Perm.edit),
      );
    }
    if (_route == '/messages' &&
        widget.messageRepo != null &&
        widget.attendanceRepo != null &&
        widget.notificationRepo != null) {
      return MessagesPage(
        messages: widget.messageRepo!,
        attendance: widget.attendanceRepo!,
        notifications: widget.notificationRepo!,
        session: widget.session,
        schoolName: widget.schoolName,
      );
    }
    if (_route == '/timetable' &&
        widget.timetableRepo != null &&
        academic != null &&
        teachers != null) {
      return TimetablePage(
        timetable: widget.timetableRepo!,
        academic: academic,
        teachers: teachers,
      );
    }
    // ── ازموینې ─────────────────────────────────────────
    final examRepo = widget.examRepo;
    if (_route.startsWith('/exams') && examRepo != null && academic != null) {
      if (_route == '/exams/papers') return const QuestionPapersPage();

      if (_route == '/exams/settings' || _route == '/exams/new') {
        return ExamSettingsPage(
          key: ValueKey(_route),
          exams: examRepo,
          academic: academic,
          startWithNew: _route == '/exams/new',
          canEdit: widget.session.permissions.can('exams', Perm.edit),
        );
      }

      // د یوې ازموینې دننه — نمرې، پایلې، ممتازین.
      final open = _openExam;
      if (open != null) {
        return switch (_examView) {
          'results' => ResultsPage(
            exam: open,
            exams: examRepo,
            academic: academic,
            onBack: () => setState(() => _openExam = null),
            onTopStudents: () => setState(() => _examView = 'top'),
            onExport: _saveCsv,
          ),
          'top' => TopStudentsPage(
            exam: open,
            exams: examRepo,
            academic: academic,
            onBack: () => setState(() => _examView = 'results'),
            onExport: _saveCsv,
          ),
          _ => MarkEntryPage(
            exam: open,
            exams: examRepo,
            academic: academic,
            session: widget.session,
            onBack: () => setState(() => _openExam = null),
            onExport: _saveCsv,
          ),
        };
      }

      if (_examView == 'combined') {
        return CombinedResultsPage(
          exams: examRepo,
          academic: academic,
          onBack: () => setState(() => _examView = 'marks'),
          onExport: _saveCsv,
        );
      }

      return ExamListPage(
        exams: examRepo,
        academic: academic,
        onEnterMarks: (e) => setState(() {
          _openExam = e;
          _examView = 'marks';
        }),
        onResults: (e) => setState(() {
          _openExam = e;
          _examView = 'results';
        }),
        onTopStudents: (e) => setState(() {
          _openExam = e;
          _examView = 'top';
        }),
        onCombined: () => setState(() => _examView = 'combined'),
        onSettings: widget.session.permissions.can('exams', Perm.create)
            ? () => _go('/exams/new')
            : null,
      );
    }
    if (_route == '/staff' && widget.staffRepo != null) {
      return StaffPage(repo: widget.staffRepo!, session: widget.session);
    }
    if (_route == '/fees' && widget.feeRepo != null && academic != null) {
      return FeesPage(
        fees: widget.feeRepo!,
        academic: academic,
        session: widget.session,
      );
    }
    if (_route == '/payroll' && widget.payrollRepo != null) {
      return PayrollPage(
        payroll: widget.payrollRepo!,
        session: widget.session,
      );
    }
    if (_route == '/users' && widget.userRepo != null) {
      return UsersPage(users: widget.userRepo!, session: widget.session);
    }
    if (_route == '/reports' &&
        widget.reportRepo != null &&
        academic != null &&
        widget.examRepo != null) {
      return ReportsPage(
        reports: widget.reportRepo!,
        academic: academic,
        exams: widget.examRepo!,
        schoolName: widget.schoolName,
      );
    }
    if (_route == '/settings' &&
        widget.db != null &&
        widget.deviceRepo != null &&
        widget.server != null &&
        widget.config != null) {
      return SettingsPage(
        db: widget.db!,
        devices: widget.deviceRepo!,
        server: widget.server!,
        session: widget.session,
        config: widget.config!,
        onConfigChanged: widget.onConfigChanged ?? (_) {},
        schoolName: widget.schoolName,
      );
    }

    // پاتې ماډلونه په راتلونکو پړاوونو کې جوړېږي — خو سایډبار
    // اوس هم ټول ښیي، چې د پرمختګ لار څرګنده وي.
    return _ComingSoon(item: _currentItem);
  }
}

class _TopBar extends StatelessWidget {
  final NavItem? item;
  final NavSubItem? sub;
  final Session session;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onSignOut;

  /// د ژوندۍ نښې پر کېکاږلو — د حاضرۍ پاڼې ته.
  final VoidCallback? onOpenLive;

  const _TopBar({
    required this.item,
    required this.sub,
    required this.session,
    this.onOpenLive,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final scope = LocaleScope.of(context);

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          if (item != null) ...[
            Icon(item!.icon, size: 18, color: item!.color),
            const SizedBox(width: 9),
            Text(
              item!.label(s),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            // فرعي پاڼه — د «شاګردان › نوې نوم لیکنه» په بڼه، چې
            // کارن پوه شي په کوم ژور ځای کې دی.
            if (sub != null && sub!.route != item!.route) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_left_rounded, size: 17, color: p.faint),
              const SizedBox(width: 4),
              Text(
                sub!.label(s),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: p.muted,
                ),
              ),
            ],
          ],
          const Spacer(),

          // **د ژوندۍ حاضرۍ نښه** — هره پاڼه يې ویني، ځکه چې د
          // ناستې وخت مدیر ته نه انتظار کوي.
          LiveBadge(compact: true, onTap: onOpenLive),
          const SizedBox(width: 10),

          // ژبه
          PopupMenuButton<AppLocale>(
            tooltip: '',
            onSelected: scope.setLocale,
            itemBuilder: (_) => [
              for (final l in AppLocale.values)
                PopupMenuItem(value: l, child: Text(l.label)),
            ],
            child: _IconSlot(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded, size: 17, color: p.muted),
                  const SizedBox(width: 5),
                  Text(
                    scope.locale.label,
                    style: TextStyle(fontSize: 12, color: p.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // تیاره / روښانه
          Tooltip(
            message: themeMode == ThemeMode.dark ? 'روښانه' : 'تیاره',
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onThemeChanged(
                themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              ),
              child: _IconSlot(
                child: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 17,
                  color: p.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: p.line),
          const SizedBox(width: 12),

          // کارن
          PopupMenuButton<String>(
            tooltip: '',
            onSelected: (v) {
              if (v == 'signout') onSignOut();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 16),
                    const SizedBox(width: 9),
                    Text(s.signOut),
                  ],
                ),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                  child: Text(
                    session.fullName.characters.first,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.fullName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      session.role,
                      style: TextStyle(fontSize: 10.5, color: p.faint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSlot extends StatelessWidget {
  final Widget child;
  const _IconSlot({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    child: child,
  );
}

class _ComingSoon extends StatelessWidget {
  final NavItem? item;
  const _ComingSoon({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final c = item?.color ?? AppColors.primary;

    return Center(
      child: FadeSlideIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(17),
              ),
              child: Icon(
                item?.icon ?? Icons.widgets_rounded,
                size: 29,
                color: c,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              item?.label(s) ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'دا ماډل په راتلونکي پړاو کې جوړېږي.',
              style: TextStyle(fontSize: 13, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}
