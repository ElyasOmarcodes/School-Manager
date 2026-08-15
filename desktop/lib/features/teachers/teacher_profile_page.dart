import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/repositories/staff_attendance_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../widgets/data_table_view.dart' show StatusChip;
import '../auth/auth_service.dart';
import '../students/student_profile_page.dart' show statusColor, statusLabelOf;

/// **د یوه استاد پروفایل.**
///
/// د شاګرد له پروفایله بېل دی، ځکه چې پوښتنې يې بېلې دي. د شاګرد
/// په اړه پوښتنه دا وي «څنګه روان دی؟»؛ د استاد په اړه دا وي «څه
/// ورکوي او څومره؟» — کوم مضامین، کوم ټولګي، څو ساعته، او د بخش
/// مشري يې کوي که نه.
class TeacherProfilePage extends StatefulWidget {
  final int teacherId;
  final TeacherRepository repo;
  final StaffAttendanceRepository? staff;
  final Session session;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;
  final DateTime Function() clock;

  const TeacherProfilePage({
    super.key,
    required this.teacherId,
    required this.repo,
    required this.session,
    this.staff,
    this.onBack,
    this.onEdit,
    this.clock = DateTime.now,
  });

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  TeacherProfile? _profile;
  bool _loading = true;
  late DateTime _month = DateTime(widget.clock().year, widget.clock().month);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(TeacherProfilePage old) {
    super.didUpdateWidget(old);
    if (old.teacherId != widget.teacherId) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final p = await widget.repo.profile(widget.teacherId, month: _month);
    if (!mounted) return;
    setState(() {
      _profile = p;
      _loading = false;
    });
  }

  void _shiftMonth(int by) {
    setState(() => _month = DateTime(_month.year, _month.month + by));
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    final profile = _profile;
    if (profile == null) {
      return const EmptyState(
        icon: Icons.person_off_rounded,
        text: 'دا استاد ونه موندل شو.',
      );
    }

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        FadeSlideIn(
          child: _Header(
            profile: profile,
            onBack: widget.onBack,
            onEdit: widget.onEdit,
          ),
        ),
        const SizedBox(height: 16),

        // ── درې شمېرې ─────────────────────────────────────
        FadeSlideIn.staggered(
          index: 1,
          child: Row(
            children: [
              _Stat(
                icon: Icons.menu_book_rounded,
                label: 'مضامین',
                value: locale.num(profile.subjectCount),
                color: AppColors.modSubjects,
              ),
              const SizedBox(width: 12),
              _Stat(
                icon: Icons.schedule_rounded,
                label: 'اوونیز ساعتونه',
                value: locale.num(profile.weeklyPeriods),
                color: AppColors.modTimetable,
              ),
              const SizedBox(width: 12),
              _Stat(
                icon: Icons.meeting_room_rounded,
                label: 'د بخش مشري',
                value: locale.num(profile.homeroom.length),
                color: AppColors.modClasses,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: FadeSlideIn.staggered(
                index: 2,
                child: _LoadPanel(profile: profile),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  FadeSlideIn.staggered(
                    index: 3,
                    child: _InfoPanel(profile: profile),
                  ),
                  const SizedBox(height: 16),
                  FadeSlideIn.staggered(
                    index: 4,
                    child: _HomeroomPanel(profile: profile),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        FadeSlideIn.staggered(
          index: 5,
          child: Panel(
            title: 'حاضري',
            actions: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'تېره میاشت',
                    onPressed: () => _shiftMonth(-1),
                    icon: const Icon(Icons.chevron_right_rounded, size: 20),
                  ),
                  Text(
                    '${locale.num(_month.month)}/${locale.num(_month.year)}',
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.inkSoft,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'راتلونکې میاشت',
                    onPressed: () => _shiftMonth(1),
                    icon: const Icon(Icons.chevron_left_rounded, size: 20),
                  ),
                ],
              ),
            ],
            child: _MonthStrip(
              month: profile.attendanceMonth,
              grid: profile.attendance,
              locale: locale,
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final TeacherProfile profile;
  final VoidCallback? onBack;
  final VoidCallback? onEdit;

  const _Header({required this.profile, this.onBack, this.onEdit});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final t = profile.teacher;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              tooltip: 'بېرته',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            ),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.modTeachers.withValues(alpha: 0.13),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              t.fullName.characters.first,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.w800,
                color: AppColors.modTeachers,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      t.fullName,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusChip(
                      label: teacherStatusLabel(t.status),
                      color: teacherStatusColor(t.status),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  [
                    locale.num(t.employeeNo),
                    if (t.specialization != null) t.specialization!,
                    if (t.qualification != null) t.qualification!,
                  ].join('  ·  '),
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ],
            ),
          ),
          if (onEdit != null)
            OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(s.edit),
            ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: p.line),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 13),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                ),
                Text(label, style: TextStyle(fontSize: 11.5, color: p.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// **د تدریس بار** — کوم مضمون، په کوم ټولګي کې، څو ساعته.
///
/// دا هغه پوښتنه ده چې د مهالویش د جوړولو پر مهال پکار ده: که یو
/// استاد لا دمخه ۲۴ ساعته لري، پنځه‌ویشتم ساعت ورکول تېروتنه ده.
class _LoadPanel extends StatelessWidget {
  final TeacherProfile profile;

  const _LoadPanel({required this.profile});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return Panel(
      title: 'د تدریس بار',
      actions: [
        Text(
          '${locale.num(profile.weeklyPeriods)} ساعته',
          style: AppTheme.tabular(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.muted,
            ),
          ),
        ),
      ],
      child: profile.load.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 22),
              child: Center(
                child: Text(
                  'لا په مهالویش کې هېڅ ساعت نه دی ورکړل شوی.',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < profile.load.length; i++) ...[
                  if (i > 0) Divider(height: 15, color: p.line),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.modSubjects,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        flex: 3,
                        child: Text(
                          profile.load[i].subjectName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          profile.load[i].classLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: p.inkSoft),
                        ),
                      ),
                      Pill(
                        color: AppColors.modTimetable,
                        text: '${locale.num(profile.load[i].periods)} ساعته',
                      ),
                    ],
                  ),
                ],
              ],
            ),
    );
  }
}

class _HomeroomPanel extends StatelessWidget {
  final TeacherProfile profile;

  const _HomeroomPanel({required this.profile});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return Panel(
      title: 'د بخش مشري',
      child: profile.homeroom.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                'د هېڅ بخش مشري نه کوي.',
                style: TextStyle(fontSize: 12.5, color: p.muted),
              ),
            )
          : Column(
              children: [
                for (final h in profile.homeroom)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.meeting_room_rounded,
                          size: 16,
                          color: AppColors.modClasses,
                        ),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            h.label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: p.ink,
                            ),
                          ),
                        ),
                        Text(
                          '${locale.num(h.students)} شاګردان',
                          style: AppTheme.tabular(
                            TextStyle(fontSize: 12, color: p.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  final TeacherProfile profile;

  const _InfoPanel({required this.profile});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final t = profile.teacher;

    return Panel(
      title: 'شخصي معلومات',
      child: Column(
        children: [
          _Row(label: 'د پلار نوم', value: t.fatherName),
          _Row(label: s.phone, value: t.phone, numeric: true),
          _Row(label: 'برېښنالیک', value: t.email),
          _Row(label: s.address, value: t.address),
          _Row(
            label: 'د دندې پیل',
            value: t.hiredOn == null
                ? null
                : '${locale.num(t.hiredOn!.year)}/'
                      '${locale.num(t.hiredOn!.month)}/'
                      '${locale.num(t.hiredOn!.day)}',
            numeric: true,
          ),
          _Row(
            label: 'میاشتنی معاش',
            value: t.monthlySalary == null
                ? null
                : '${locale.grouped(t.monthlySalary!)} افغانۍ',
            numeric: true,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String? value;
  final bool numeric;

  const _Row({required this.label, this.value, this.numeric = false});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    final text = value == null || value!.isEmpty
        ? '—'
        : (numeric ? locale.num(value!) : value!);

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(label, style: TextStyle(fontSize: 12, color: p.muted)),
          ),
          Expanded(
            child: Text(
              text,
              style: numeric
                  ? AppTheme.tabular(
                      TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: p.inkSoft,
                      ),
                    )
                  : TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: p.inkSoft,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// د میاشتې د حاضرۍ کرښه — د شاګرد له جدول سره یو شان ښکاري، نو
/// مدیر ته نوې بڼه نه ده.
class _MonthStrip extends StatelessWidget {
  final DateTime month;
  final Map<int, String> grid;
  final AppLocale locale;

  const _MonthStrip({
    required this.month,
    required this.grid,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final days = DateTime(month.year, month.month + 1, 0).day;

    final counts = <String, int>{};
    for (final v in grid.values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var d = 1; d <= days; d++)
              _Day(day: d, status: grid[d], locale: locale),
          ],
        ),
        const SizedBox(height: 14),
        Divider(height: 1, color: p.line),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in const ['present', 'late', 'absent', 'leave'])
              Pill(
                color: statusColor(key),
                text:
                    '${statusLabelOf(key, s)}: ${locale.num(counts[key] ?? 0)}',
              ),
            Pill(
              color: p.faint,
              text: '${s.unmarked}: ${locale.num(days - grid.length)}',
            ),
          ],
        ),
      ],
    );
  }
}

class _Day extends StatelessWidget {
  final int day;
  final String? status;
  final AppLocale locale;

  const _Day({required this.day, required this.status, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = statusColor(status);
    final marked = status != null;

    return Tooltip(
      message: '${locale.num(day)} — ${statusLabelOf(status, S.of(context))}',
      child: AnimatedContainer(
        duration: AppMotion.fast,
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: marked ? c.withValues(alpha: 0.15) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: marked ? c.withValues(alpha: 0.45) : Colors.transparent,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          locale.num(day),
          style: AppTheme.tabular(
            TextStyle(
              fontSize: 11,
              fontWeight: marked ? FontWeight.w700 : FontWeight.w500,
              color: marked ? c : p.faint,
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

String teacherStatusLabel(String status) => switch (status) {
  'active' => 'فعال',
  'on_leave' => 'په رخصتۍ',
  'resigned' => 'استعفا',
  _ => 'ګوښه شوی',
};

Color teacherStatusColor(String status) => switch (status) {
  'active' => AppColors.success,
  'on_leave' => AppColors.warning,
  _ => AppColors.danger,
};
