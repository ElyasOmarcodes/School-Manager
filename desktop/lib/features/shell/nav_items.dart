import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';

/// د یوه فرعي توکي تعریف — «شاګردان»، «نوې نوم لیکنه».
///
/// **دا ولې خپل ټولګی لري او نه بل `NavItem`؟** ځکه چې فرعي توکی
/// خپل رنګ نه لري — د مور توکي رنګ اخلي. که `NavItem` وای، هر یو
/// به رنګ او د اجازو کلی غوښت، او سایډبار به رنګارنګ شوی و.
class NavSubItem {
  final String route;
  final IconData icon;
  final String Function(S) label;

  const NavSubItem({
    required this.route,
    required this.icon,
    required this.label,
  });
}

/// د سایډبار د یوه توکي تعریف.
class NavItem {
  final String route;
  final IconData icon;
  final Color color;
  final String Function(S) label;

  /// که `null` وي، هر رول يې ویني.
  final Set<String>? roles;

  /// فرعي توکي — که وي، پر توکي کېکاږل يې خلاصوي.
  final List<NavSubItem> children;

  const NavItem({
    required this.route,
    required this.icon,
    required this.color,
    required this.label,
    this.roles,
    this.children = const [],
  });

  bool get hasChildren => children.isNotEmpty;

  /// ایا دا لار د دې توکي (یا د یوه فرعي توکي) ده؟
  bool owns(String r) => r == route || children.any((c) => c.route == r);

  /// د اجازو ماډل کلی — «/students» → «students».
  ///
  /// ځینې لارې (ډاشبورډ، آی‌ډي کارتونه) د اجازو په لیست کې نشته —
  /// هغه هر څوک ویني، ځکه چې یوازې هغه څه ښیي چې کارن يې لا وړاندې
  /// لیدلی شي.
  String get moduleKey => moduleKeyOf(route);

  /// «/students/new» → «students». فرعي لارې د مور ماډل اجازې لري —
  /// که نه، هر نوی فرعي توکی به نوې اجازې ته اړ و.
  static String moduleKeyOf(String route) =>
      route.split('/').where((e) => e.isNotEmpty).first.replaceAll('-', '_');

  bool visibleTo(Permissions perms) {
    final known = permModules.any((m) => m.key == moduleKey);
    if (known) return perms.canView(moduleKey);
    // نه‌پېژندل شوی ماډل — زوړ د رول فلټر پلی کوو.
    return roles == null || roles!.contains(perms.role);
  }
}

class NavGroup {
  final String Function(S) title;
  final List<NavItem> items;
  const NavGroup(this.title, this.items);
}

/// د سایډبار بشپړ جوړښت.
///
/// هر توکی خپل رنګ لري — دا هغه څه دي چې تعلیمي ډاشبورډ ژوندی کوي
/// او سترګې يې په یوه نظر پیدا کوي.
const _all = 'admin';
const _staffRoles = {'admin', 'deputy'};
const _financeRoles = {'admin', 'accountant'};

// د فرعي توکو نومونه — `const` لیستونه یوازې `const` فعالیتونه مني،
// نو د لامبډا پر ځای نومول شوي فعالیتونه دي.
String _lblReportStudents(S s) => 'د شاګردانو راپور';
String _lblReportTeachers(S s) => 'د استادانو راپور';
String _lblReportStaff(S s) => 'د کارمندانو راپور';
String _lblReportSummary(S s) => 'عمومي راپورونه';

String _lblStudentList(S s) => s.students;
String _lblNewEnrolment(S s) => s.newEnrolment;
String _lblTakeAttendance(S s) => s.attendanceTaking;
String _lblNewSession(S s) => s.newSession;
String _lblSessionSettings(S s) => s.sessionSettings;
String _lblLeaveList(S s) => s.leaveRequests;
String _lblNewLeave(S s) => s.newLeave;
String _lblExamList(S s) => s.exams;
String _lblExamSettings(S s) => s.examSettings;
String _lblQuestionPapers(S s) => s.questionPapers;
String _lblTimetableGrid(S s) => s.timetable;
String _lblTimetableSettings(S s) => s.timetableSettings;
String _lblCardsStudents(S s) => s.students;
String _lblCardsTeachers(S s) => s.teachers;
String _lblCardsStaff(S s) => s.staff;
String _lblSettingsGeneral(S s) => s.settingsGeneral;
String _lblSettingsSchool(S s) => s.settingsSchool;
String _lblSettingsDatabase(S s) => s.settingsDatabase;
String _lblSettingsNetwork(S s) => s.settingsNetwork;

List<NavGroup> buildNav() => [
  NavGroup((s) => '', [
    NavItem(
      route: '/dashboard',
      icon: Icons.grid_view_rounded,
      color: AppColors.primary,
      label: (s) => s.dashboard,
    ),
  ]),
  NavGroup((s) => s.grpAcademic, [
    NavItem(
      route: '/students',
      icon: Icons.school_rounded,
      color: AppColors.modStudents,
      label: (s) => s.students,
      children: const [
        NavSubItem(
          route: '/students',
          icon: Icons.groups_rounded,
          label: _lblStudentList,
        ),
        NavSubItem(
          route: '/students/enroll',
          icon: Icons.person_add_alt_1_rounded,
          label: _lblNewEnrolment,
        ),
      ],
    ),
    NavItem(
      route: '/attendance',
      icon: Icons.fact_check_rounded,
      color: AppColors.modAttendance,
      label: (s) => s.attendance,
      children: const [
        NavSubItem(
          route: '/attendance',
          icon: Icons.how_to_reg_rounded,
          label: _lblTakeAttendance,
        ),
        NavSubItem(
          route: '/attendance/new',
          icon: Icons.add_task_rounded,
          label: _lblNewSession,
        ),
        NavSubItem(
          route: '/attendance/settings',
          icon: Icons.tune_rounded,
          label: _lblSessionSettings,
        ),
      ],
    ),
    NavItem(
      route: '/leave',
      icon: Icons.event_available_rounded,
      color: AppColors.modLeave,
      label: (s) => s.leaveRequests,
      children: const [
        NavSubItem(
          route: '/leave',
          icon: Icons.rule_folder_rounded,
          label: _lblLeaveList,
        ),
        NavSubItem(
          route: '/leave/new',
          icon: Icons.note_add_rounded,
          label: _lblNewLeave,
        ),
      ],
    ),
    NavItem(
      route: '/classes',
      icon: Icons.meeting_room_rounded,
      color: AppColors.modClasses,
      label: (s) => s.classes,
    ),
    NavItem(
      route: '/subjects',
      icon: Icons.menu_book_rounded,
      color: AppColors.modSubjects,
      label: (s) => s.subjects,
    ),
    NavItem(
      route: '/timetable',
      icon: Icons.calendar_view_week_rounded,
      color: AppColors.modTimetable,
      label: (s) => s.timetable,
      children: const [
        NavSubItem(
          route: '/timetable',
          icon: Icons.grid_on_rounded,
          label: _lblTimetableGrid,
        ),
        NavSubItem(
          route: '/timetable/settings',
          icon: Icons.tune_rounded,
          label: _lblTimetableSettings,
        ),
      ],
    ),
    NavItem(
      route: '/exams',
      icon: Icons.assignment_rounded,
      color: AppColors.modExams,
      label: (s) => s.exams,
      children: const [
        NavSubItem(
          route: '/exams',
          icon: Icons.assignment_turned_in_rounded,
          label: _lblExamList,
        ),
        NavSubItem(
          route: '/exams/settings',
          icon: Icons.tune_rounded,
          label: _lblExamSettings,
        ),
        NavSubItem(
          route: '/exams/papers',
          icon: Icons.description_rounded,
          label: _lblQuestionPapers,
        ),
      ],
    ),
  ]),
  NavGroup((s) => s.grpAdmin, [
    NavItem(
      route: '/teachers',
      icon: Icons.person_rounded,
      color: AppColors.modTeachers,
      label: (s) => s.teachers,
      roles: _staffRoles,
    ),
    NavItem(
      route: '/staff',
      icon: Icons.badge_rounded,
      color: AppColors.modStaff,
      label: (s) => s.staff,
      roles: _staffRoles,
    ),
    NavItem(
      route: '/id-cards',
      icon: Icons.qr_code_2_rounded,
      color: AppColors.modIdCards,
      label: (s) => s.idCards,
      children: const [
        NavSubItem(
          route: '/id-cards',
          icon: Icons.school_rounded,
          label: _lblCardsStudents,
        ),
        NavSubItem(
          route: '/id-cards/teachers',
          icon: Icons.person_rounded,
          label: _lblCardsTeachers,
        ),
        NavSubItem(
          route: '/id-cards/staff',
          icon: Icons.badge_rounded,
          label: _lblCardsStaff,
        ),
      ],
    ),
    NavItem(
      route: '/messages',
      icon: Icons.forum_rounded,
      color: AppColors.modMessages,
      label: (s) => s.messages,
    ),
  ]),
  NavGroup((s) => s.grpFinance, [
    NavItem(
      route: '/fees',
      icon: Icons.payments_rounded,
      color: AppColors.modFees,
      label: (s) => s.fees,
      roles: _financeRoles,
    ),
    NavItem(
      route: '/payroll',
      icon: Icons.account_balance_wallet_rounded,
      color: AppColors.modPayroll,
      label: (s) => s.payroll,
      roles: _financeRoles,
    ),
  ]),
  NavGroup((s) => s.grpSystem, [
    NavItem(
      route: '/reports',
      icon: Icons.insights_rounded,
      color: AppColors.modReports,
      label: (s) => s.reports,
      children: const [
        NavSubItem(
          route: '/reports',
          icon: Icons.school_rounded,
          label: _lblReportStudents,
        ),
        NavSubItem(
          route: '/reports/teachers',
          icon: Icons.person_rounded,
          label: _lblReportTeachers,
        ),
        NavSubItem(
          route: '/reports/staff',
          icon: Icons.badge_rounded,
          label: _lblReportStaff,
        ),
        NavSubItem(
          route: '/reports/summary',
          icon: Icons.query_stats_rounded,
          label: _lblReportSummary,
        ),
      ],
    ),
    NavItem(
      route: '/users',
      icon: Icons.manage_accounts_rounded,
      color: AppColors.modUsers,
      label: (s) => s.users,
      roles: {_all},
    ),
    NavItem(
      route: '/settings',
      icon: Icons.settings_rounded,
      color: AppColors.modSettings,
      label: (s) => s.settings,
      children: const [
        NavSubItem(
          route: '/settings',
          icon: Icons.tune_rounded,
          label: _lblSettingsGeneral,
        ),
        NavSubItem(
          route: '/settings/school',
          icon: Icons.account_balance_rounded,
          label: _lblSettingsSchool,
        ),
        NavSubItem(
          route: '/settings/database',
          icon: Icons.storage_rounded,
          label: _lblSettingsDatabase,
        ),
        NavSubItem(
          route: '/settings/network',
          icon: Icons.wifi_tethering_rounded,
          label: _lblSettingsNetwork,
        ),
      ],
    ),
  ]),
];
