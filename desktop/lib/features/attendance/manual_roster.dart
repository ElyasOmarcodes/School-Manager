import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/tone.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_session_repository.dart';
import '../auth/auth_service.dart';

/// **په لاس نښه کول — پرته له سکینه.**
///
/// سکینر هر څه نه شي کولی. یو شاګرد کارت هېر کړی، بل ناروغ دی او
/// راغلی نه دی، دریم د اجازې سره تللی. د دې درې واړو لپاره باید
/// مدیر په لاس ونښلوي — او هغه هم ژر، له فلټر سره، نه د اته سوو
/// نومونو په سکرول کولو کې.
///
/// **د «رخصت» نښه کول د اجازت‌نامو ډیټابیس ته هم لیکل کېږي.** که
/// نه وای، د میاشتې د اجازو رپوټ به له حاضرۍ سره ټکر خوړ.
class ManualRoster extends StatefulWidget {
  final AttendanceSessionRepository sessions;
  final AttendanceRepository attendance;
  final AcademicRepository academic;
  final AttendanceSession? session;
  final Session user;
  final DateTime Function() clock;
  final VoidCallback? onChanged;

  const ManualRoster({
    super.key,
    required this.sessions,
    required this.attendance,
    required this.academic,
    required this.session,
    required this.user,
    required this.clock,
    this.onChanged,
  });

  @override
  State<ManualRoster> createState() => _ManualRosterState();
}

class _ManualRosterState extends State<ManualRoster> {
  RosterFilter _filter = const RosterFilter();
  List<SessionRosterEntry> _rows = const [];
  List<Grade> _grades = const [];
  bool _loading = true;
  final Set<int> _selected = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(ManualRoster old) {
    super.didUpdateWidget(old);
    if (old.session?.id != widget.session?.id) _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await widget.sessions.roster(
      session: widget.session,
      date: widget.clock(),
      filter: _filter,
    );
    final grades = _grades.isEmpty ? await widget.academic.grades() : _grades;
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _grades = grades;
      _loading = false;
      // هغه ټاکنې چې نور په لیسټ کې نشته، پاکېږي — که نه، د یوه
      // پټ شوي شاګرد حالت به په پټه بدل شوی و.
      _selected.retainWhere((id) => rows.any((r) => r.student.id == id));
    });
  }

  void _setFilter(RosterFilter f) {
    setState(() => _filter = f);
    _load();
  }

  Future<void> _mark(Map<int, String> statuses) async {
    if (statuses.isEmpty) return;

    await widget.attendance.markRoster(
      date: widget.clock(),
      statusByStudentId: statuses,
      byUserId: widget.user.userId,
      sessionId: widget.session?.storageId ?? 0,
      method: 'manual',
      // **دا هغه ټکی دی چې رخصت له حاضرۍ ډیټابیس ته ورځي.**
      recordLeave: true,
      now: widget.clock(),
    );

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterRow(
          filter: _filter,
          grades: _grades,
          counts: counts,
          total: _rows.length,
          onChanged: _setFilter,
        ),
        const SizedBox(height: 10),

        // ── د ډله‌ییز نښه کولو کرښه ────────────────────────
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: _selected.isEmpty
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
                          '${locale.num(_selected.length)} کسان ټاکل شوي',
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
                          _MarkButton(
                            status: st,
                            onTap: () => _mark({
                              for (final id in _selected) id: st,
                            }),
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
              ? EmptyState(
                  icon: Icons.groups_rounded,
                  text: _filter.isEmpty
                      ? 'د دې ناستې لپاره هېڅ شاګرد نه دی ټاکل شوی.'
                      : 'د دې فلټر سره هېڅوک ونه موندل شو.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _rows.length,
                  itemBuilder: (context, i) => _RosterTile(
                    entry: _rows[i],
                    locale: locale,
                    selected: _selected.contains(_rows[i].student.id),
                    onSelect: () => setState(() {
                      final id = _rows[i].student.id;
                      if (!_selected.remove(id)) _selected.add(id);
                    }),
                    onMark: (st) => _mark({_rows[i].student.id: st}),
                  ),
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _FilterRow extends StatelessWidget {
  final RosterFilter filter;
  final List<Grade> grades;
  final Map<String, int> counts;
  final int total;
  final ValueChanged<RosterFilter> onChanged;

  const _FilterRow({
    required this.filter,
    required this.grades,
    required this.counts,
    required this.total,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            onChanged: (v) => onChanged(filter.copyWith(query: v)),
            decoration: InputDecoration(
              hintText: '${s.search}…',
              isDense: true,
              prefixIcon: const Icon(Icons.search_rounded, size: 17),
            ),
          ),
        ),
        if (grades.isNotEmpty)
          SizedBox(
            width: 165,
            child: DropdownButtonFormField<int?>(
              initialValue: filter.gradeId,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(labelText: s.grade, isDense: true),
              items: [
                DropdownMenuItem(value: null, child: Text(s.all)),
                for (final g in grades)
                  DropdownMenuItem(value: g.id, child: Text(g.name)),
              ],
              onChanged: (v) => onChanged(
                v == null
                    ? filter.copyWith(clearGrade: true)
                    : filter.copyWith(gradeId: v),
              ),
            ),
          ),
        SegmentedChoice<String?>(
          value: filter.residency,
          options: [
            (value: null, label: s.all, icon: null),
            (value: 'day', label: s.dayScholar, icon: null),
            (value: 'boarding', label: s.boarder, icon: null),
          ],
          onChanged: (v) => onChanged(
            v == null
                ? filter.copyWith(clearResidency: true)
                : filter.copyWith(residency: v),
          ),
        ),

        // د حالت فلټرونه خپل شمېر وړي — نو مدیر پوهېږي څو نه‌نښه‌شوي
        // پاتې دي، پرته له دې چې پرې کېکاږي.
        for (final st in const ['unmarked', 'present', 'absent', 'leave'])
          _CountChip(
            label: statusText(st, s),
            count: counts[st] ?? 0,
            color: st == 'unmarked'
                ? context.palette.faint
                : attendanceColor(st),
            selected: filter.status == st,
            onTap: () => onChanged(
              filter.status == st
                  ? filter.copyWith(clearStatus: true)
                  : filter.copyWith(status: st),
            ),
          ),
        Text(
          '${locale.num(total)} کسان',
          style: TextStyle(fontSize: 12, color: context.palette.muted),
        ),
      ],
    );
  }
}

Color attendanceColor(String? status) => switch (status) {
  'present' => AppColors.success,
  'late' => AppColors.warning,
  'absent' => AppColors.danger,
  'leave' => AppColors.info,
  'holiday' => AppColors.modSettings,
  _ => AppColors.modSettings,
};

String statusText(String? status, S s) => switch (status) {
  'present' => s.present,
  'late' => s.late,
  'absent' => s.absent,
  'leave' => s.onLeave,
  'holiday' => 'رخصتي',
  _ => s.unmarked,
};

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

class _RosterTile extends StatefulWidget {
  final SessionRosterEntry entry;
  final AppLocale locale;
  final bool selected;
  final VoidCallback onSelect;
  final ValueChanged<String> onMark;

  const _RosterTile({
    required this.entry,
    required this.locale,
    required this.selected,
    required this.onSelect,
    required this.onMark,
  });

  @override
  State<_RosterTile> createState() => _RosterTileState();
}

class _RosterTileState extends State<_RosterTile> {
  bool _hover = false;

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
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          [
                            e.student.firstName,
                            if (e.student.lastName?.isNotEmpty ?? false)
                              e.student.lastName,
                          ].join(' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: p.ink,
                          ),
                        ),
                      ),
                      if (e.hasApprovedLeave)
                        const Padding(
                          padding: EdgeInsetsDirectional.only(start: 6),
                          child: Icon(
                            Icons.event_available_rounded,
                            size: 13,
                            color: AppColors.info,
                          ),
                        ),
                      if (e.student.residency == 'boarding')
                        const Padding(
                          padding: EdgeInsetsDirectional.only(start: 6),
                          child: Icon(
                            Icons.night_shelter_rounded,
                            size: 13,
                            color: AppColors.modHostel,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    'ولد ${e.student.fatherName}',
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
                e.className ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: p.muted),
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
            // د نښې تڼۍ تل ښکاري — د دروازې پر مخ د موږک ښویېدل
            // یو بې‌ځایه ګام دی.
            for (final st in const ['present', 'absent', 'leave']) ...[
              _MarkButton(
                status: st,
                active: e.status == st,
                compact: true,
                onTap: () => widget.onMark(st),
              ),
              const SizedBox(width: 5),
            ],
          ],
        ),
      ),
    );
  }
}

class _MarkButton extends StatelessWidget {
  final String status;
  final bool active;
  final bool compact;
  final VoidCallback onTap;

  const _MarkButton({
    required this.status,
    required this.onTap,
    this.active = false,
    this.compact = false,
  });

  static const _icons = {
    'present': Icons.check_rounded,
    'absent': Icons.close_rounded,
    'leave': Icons.event_available_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final c = attendanceColor(status);

    return Tooltip(
      message: statusText(status, s),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 9 : 12,
            vertical: compact ? 6 : 8,
          ),
          decoration: BoxDecoration(
            color: active ? c : c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(7),
          ),
          child: compact
              ? Icon(
                  _icons[status],
                  size: 15,
                  color: active ? Colors.white : c,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _icons[status],
                      size: 14,
                      color: active ? Colors.white : c,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      statusText(status, s),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? Colors.white : c,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
