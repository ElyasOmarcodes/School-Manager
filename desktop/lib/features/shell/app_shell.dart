import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/fee_repository.dart';
import '../../data/repositories/leave_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/timetable_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../../server/local_server.dart';
import '../auth/auth_service.dart';
import '../dashboard/dashboard_page.dart';
import '../students/admission_wizard.dart';
import '../attendance/attendance_page.dart';
import '../classes/classes_page.dart';
import '../leave/leave_page.dart';
import '../exams/exams_page.dart';
import '../fees/fees_page.dart';
import '../id_cards/id_cards_page.dart';
import '../messages/messages_page.dart';
import '../payroll/payroll_page.dart';
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
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _route = '/dashboard';
  bool _expanded = true;

  /// د شاګردانو پاڼه دوه حالته لري: لیست او د داخلې ویزارډ.
  /// دا حالت دلته دی نه په پاڼه کې، چې د سایډبار بدلون يې پاک کړي.
  bool _admitting = false;

  /// د لیست د بیا-بارولو لپاره — کله چې نوی شاګرد ثبت شي.
  int _studentsRevision = 0;

  NavItem? get _currentItem {
    for (final g in buildNav()) {
      for (final i in g.items) {
        if (i.route == _route) return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.ground,
      body: Row(
        children: [
          Sidebar(
            currentRoute: _route,
            permissions: widget.session.permissions,
            expanded: _expanded,
            schoolName: widget.schoolName,
            onToggle: () => setState(() => _expanded = !_expanded),
            onNavigate: (r) => setState(() {
              _route = r;
              _admitting = false;
            }),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  item: _currentItem,
                  session: widget.session,
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
                      key: ValueKey('$_route/$_admitting'),
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
  }

  Widget _buildPage() {
    if (_route == '/dashboard') {
      return DashboardPage(stats: widget.stats);
    }
    if (_route == '/students' && widget.studentRepo != null) {
      if (_admitting && widget.academicRepo != null) {
        return AdmissionWizard(
          students: widget.studentRepo!,
          academic: widget.academicRepo!,
          session: widget.session,
          onCancel: () => setState(() => _admitting = false),
          onAdmitted: (id, admissionNo) {
            setState(() {
              _admitting = false;
              _studentsRevision++;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                behavior: SnackBarBehavior.floating,
                width: 420,
                backgroundColor: AppColors.success,
                content: Text('شاګرد ثبت شو — د داخلې نمبر $admissionNo'),
              ),
            );
          },
        );
      }
      return StudentsPage(
        key: ValueKey('students-$_studentsRevision'),
        repo: widget.studentRepo!,
        onAddStudent: widget.academicRepo == null
            ? null
            : () => setState(() => _admitting = true),
      );
    }
    final academic = widget.academicRepo;
    final teachers = widget.teacherRepo;
    final students = widget.studentRepo;

    if (_route == '/id-cards' && students != null && academic != null) {
      return IdCardsPage(
        students: students,
        academic: academic,
        schoolName: widget.schoolName,
      );
    }
    if (_route == '/attendance' &&
        widget.attendanceRepo != null &&
        academic != null) {
      return AttendancePage(
        attendance: widget.attendanceRepo!,
        academic: academic,
        session: widget.session,
      );
    }
    if (_route == '/leave' && widget.leaveRepo != null) {
      return LeavePage(repo: widget.leaveRepo!, session: widget.session);
    }
    if (_route == '/teachers' && teachers != null) {
      return TeachersPage(repo: teachers, session: widget.session);
    }
    if (_route == '/classes' && academic != null && teachers != null) {
      return ClassesPage(academic: academic, teachers: teachers);
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
    if (_route == '/exams' && widget.examRepo != null && academic != null) {
      return ExamsPage(
        exams: widget.examRepo!,
        academic: academic,
        session: widget.session,
        schoolName: widget.schoolName,
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
  final Session session;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onSignOut;

  const _TopBar({
    required this.item,
    required this.session,
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
          ],
          const Spacer(),

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
