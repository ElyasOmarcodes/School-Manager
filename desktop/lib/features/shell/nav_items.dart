import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';

/// د سایډبار د یوه توکي تعریف.
class NavItem {
  final String route;
  final IconData icon;
  final Color color;
  final String Function(S) label;

  /// که `null` وي، هر رول يې ویني.
  final Set<String>? roles;

  const NavItem({
    required this.route,
    required this.icon,
    required this.color,
    required this.label,
    this.roles,
  });

  bool visibleTo(String role) => roles == null || roles!.contains(role);
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
    ),
    NavItem(
      route: '/attendance',
      icon: Icons.fact_check_rounded,
      color: AppColors.modAttendance,
      label: (s) => s.attendance,
    ),
    NavItem(
      route: '/leave',
      icon: Icons.event_available_rounded,
      color: AppColors.modLeave,
      label: (s) => s.leaveRequests,
    ),
    NavItem(
      route: '/classes',
      icon: Icons.meeting_room_rounded,
      color: AppColors.modClasses,
      label: (s) => s.classes,
    ),
    NavItem(
      route: '/timetable',
      icon: Icons.calendar_view_week_rounded,
      color: AppColors.modTimetable,
      label: (s) => s.timetable,
    ),
    NavItem(
      route: '/exams',
      icon: Icons.assignment_rounded,
      color: AppColors.modExams,
      label: (s) => s.exams,
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
    ),
  ]),
];
