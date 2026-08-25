import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/tone.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/attendance_session_repository.dart';
import '../../data/repositories/staff_attendance_repository.dart';
import '../auth/auth_service.dart';
import 'manual_roster.dart' show attendanceColor, statusText;

/// **د استادانو او کارمندانو لاسي حاضري.**
///
/// د شاګردانو له لیسټ سره ورته ښکاري — او دا قصداً دی. یو کارکوونکی
/// چې د شاګردانو لیست پېژني، باید دلته څه نوي زده کولو ته اړ نه وي.
/// توپیر یوازې دا دی چې دلته ټولګی نشته، د دندې نوم يې پر ځای دی.
class PersonnelRoster extends StatefulWidget {
  final StaffAttendanceRepository staff;
  final AttendanceSession? session;
  final Session user;
  final DateTime Function() clock;
  final VoidCallback? onChanged;

  const PersonnelRoster({
    super.key,
    required this.staff,
    required this.session,
    required this.user,
    required this.clock,
    this.onChanged,
  });

  @override
  State<PersonnelRoster> createState() => _PersonnelRosterState();
}

class _PersonnelRosterState extends State<PersonnelRoster> {
  List<PersonnelRosterEntry> _rows = const [];
  bool _loading = true;
  String _query = '';
  String? _kindFilter;
  String? _statusFilter;
  final Set<String> _selected = {};

  /// د ناستې خپل هدف تل غالب دی — که ناسته «یوازې استادان» وي،
  /// کارن يې کارمندانو ته نه شي اړولی.
  String? get _kind => widget.session?.personnelKind ?? _kindFilter;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await widget.staff.roster(
      date: widget.clock(),
      sessionId: widget.session?.storageId ?? 0,
      kind: _kind,
      query: _query,
      status: _statusFilter,
    );
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
      _selected.retainWhere(
        (k) => rows.any((r) => '${r.person.kind}:${r.person.id}' == k),
      );
    });
  }

  Future<void> _mark(Iterable<Personnel> people, String status) async {
    final now = widget.clock();
    for (final p in people) {
      await widget.staff.mark(
        personKind: p.kind,
        personId: p.id,
        date: now,
        status: status,
        sessionId: widget.session?.storageId ?? 0,
        method: 'manual',
        byUserId: widget.user.userId,
        checkInAt: status == 'present' || status == 'late' ? now : null,
        now: now,
      );
    }
    await Tone.play(Tone.accept);
    if (!mounted) return;
    setState(_selected.clear);
    await _load();
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    final counts = <String, int>{};
    for (final r in _rows) {
      final k = r.status ?? 'unmarked';
      counts[k] = (counts[k] ?? 0) + 1;
    }

    final chosen = _rows
        .where((r) => _selected.contains('${r.person.kind}:${r.person.id}'))
        .map((r) => r.person)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: 9,
          runSpacing: 9,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: TextField(
                onChanged: (v) {
                  setState(() => _query = v);
                  _load();
                },
                decoration: InputDecoration(
                  hintText: '${s.search}…',
                  isDense: true,
                  prefixIcon: const Icon(Icons.search_rounded, size: 17),
                ),
              ),
            ),
            // که ناسته يې خپله ټاکلې وي، دا ټاکنه بنده ده.
            if (widget.session?.personnelKind == null)
              SegmentedChoice<String?>(
                value: _kindFilter,
                options: [
                  (value: null, label: s.all, icon: null),
                  (value: 'teacher', label: s.teachers, icon: null),
                  (value: 'staff', label: s.staff, icon: null),
                ],
                onChanged: (v) {
                  setState(() => _kindFilter = v);
                  _load();
                },
              ),
            for (final st in const ['unmarked', 'present', 'absent', 'leave'])
              _CountChip(
                label: statusText(st, s),
                count: counts[st] ?? 0,
                color: st == 'unmarked' ? p.faint : attendanceColor(st),
                selected: _statusFilter == st,
                onTap: () {
                  setState(
                    () => _statusFilter = _statusFilter == st ? null : st,
                  );
                  _load();
                },
              ),
            Text(
              '${locale.num(_rows.length)} کسان',
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
          ],
        ),
        const SizedBox(height: 10),

        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: chosen.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.modAttendance.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${locale.num(chosen.length)} کسان ټاکل شوي',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.inkSoft,
                          ),
                        ),
                        const Spacer(),
                        for (final st in const [
                          'present',
                          'absent',
                          'leave',
                        ]) ...[
                          OutlinedButton(
                            onPressed: () => _mark(chosen, st),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: attendanceColor(st),
                              minimumSize: const Size(0, 34),
                            ),
                            child: Text(statusText(st, s)),
                          ),
                          const SizedBox(width: 7),
                        ],
                        TextButton(
                          onPressed: () => setState(_selected.clear),
                          child: Text(s.cancel),
                        ),
                      ],
                    ),
                  ),
                ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _rows.isEmpty
              ? const EmptyState(
                  icon: Icons.groups_2_rounded,
                  text: 'هېڅ استاد یا کارمند ونه موندل شو.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _rows.length,
                  itemBuilder: (context, i) {
                    final key =
                        '${_rows[i].person.kind}:${_rows[i].person.id}';
                    return _PersonRow(
                      entry: _rows[i],
                      locale: locale,
                      selected: _selected.contains(key),
                      onSelect: () => setState(() {
                        if (!_selected.remove(key)) _selected.add(key);
                      }),
                      onMark: (st) => _mark([_rows[i].person], st),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _CountChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _CountChip({
    required this.label,
    required this.count,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.14) : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: selected ? color.withValues(alpha: 0.5) : p.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : p.inkSoft,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              locale.num(count),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: p.faint,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonRow extends StatefulWidget {
  final PersonnelRosterEntry entry;
  final AppLocale locale;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<String> onMark;

  const _PersonRow({
    required this.entry,
    required this.locale,
    required this.selected,
    required this.onSelect,
    required this.onMark,
  });

  @override
  State<_PersonRow> createState() => _PersonRowState();
}

class _PersonRowState extends State<_PersonRow> {
  bool _hover = false;

  static const _icons = {
    'present': Icons.check_rounded,
    'absent': Icons.close_rounded,
    'leave': Icons.event_available_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final e = widget.entry;
    final c = e.status == null ? p.faint : attendanceColor(e.status);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsetsDirectional.fromSTEB(4, 6, 10, 6),
        decoration: BoxDecoration(
          color: widget.selected
              ? AppColors.modAttendance.withValues(alpha: 0.08)
              : _hover
              ? p.surfaceAlt
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          children: [
            Checkbox(
              value: widget.selected,
              onChanged: (_) => widget.onSelect(),
              visualDensity: VisualDensity.compact,
            ),
            Container(
              width: 4,
              height: 30,
              margin: const EdgeInsetsDirectional.only(end: 10),
              decoration: BoxDecoration(
                color: c,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Icon(
              e.person.isTeacher
                  ? Icons.person_rounded
                  : Icons.badge_rounded,
              size: 15,
              color: e.person.isTeacher
                  ? AppColors.modTeachers
                  : AppColors.modStaff,
            ),
            const SizedBox(width: 9),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    e.person.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    e.person.jobTitle ??
                        (e.person.isTeacher ? 'استاد' : 'کارمند'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: p.faint),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                widget.locale.num(e.person.employeeNo),
                style: AppTheme.tabular(
                  TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ),
            ),
            SizedBox(
              width: 96,
              child: Text(
                statusText(e.status, s),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ),
            for (final st in const ['present', 'absent', 'leave']) ...[
              Tooltip(
                message: statusText(st, s),
                child: GestureDetector(
                  onTap: () => widget.onMark(st),
                  child: AnimatedContainer(
                    duration: AppMotion.fast,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: e.status == st
                          ? attendanceColor(st)
                          : attendanceColor(st).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Icon(
                      _icons[st],
                      size: 15,
                      color: e.status == st
                          ? Colors.white
                          : attendanceColor(st),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
            ],
          ],
        ),
      ),
    );
  }
}
