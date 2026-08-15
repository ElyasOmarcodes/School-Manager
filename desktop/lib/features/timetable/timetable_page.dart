import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/timetable_repository.dart';

/// د مهالویش پاڼه — د یوه بخش اونیز جدول.
///
/// **د خانو رنګ ولې د مضمون له نامه راځي؟** ځکه چې یو استاد باید
/// په یوه نظر وویني چې «د شنبې دویم ساعت ریاضي دی». که ټولې خانې
/// یو رنګ وای، هغه به يې لوستلو ته اړ و — او د اتو ساعتونو په پنځو
/// ورځو کې څلوېښت خانې دي.
class TimetablePage extends StatefulWidget {
  final TimetableRepository timetable;
  final AcademicRepository academic;
  final TeacherRepository teachers;

  const TimetablePage({
    super.key,
    required this.timetable,
    required this.academic,
    required this.teachers,
  });

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool _loading = true;
  List<SectionOption> _sections = const [];
  SectionOption? _section;

  TimetableGrid? _grid;
  List<Subject> _subjects = const [];
  List<Teacher> _teachers = const [];
  List<TimetableConflict> _conflicts = const [];

  /// `weekly` (مکتب) یا `daily` (مدرسه).
  String _mode = 'weekly';
  DailyGrid? _daily;

  bool get _isDaily => _mode == 'daily';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await widget.academic.seedDefaultSubjects();
    await widget.timetable.seedDefaultSlots();

    final sections = await widget.academic.sections();
    final school = await widget.academic.school();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _section = sections.isEmpty ? null : sections.first;
      _mode = school?.timetableMode ?? 'weekly';
    });
    await _load();
  }

  Future<void> _setMode(String v) async {
    setState(() => _mode = v);
    await widget.academic.setTimetableMode(v);
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final teachers = await widget.teachers.activeTeachers();

    if (_isDaily) {
      // د مدرسې حالت: یو جدول، ټولې درجې. د مضمونونو لیست دلته
      // ټول دی، ځکه چې هر کتار خپله درجه ده — د خانې ډیالوګ يې
      // بیا د هغه کتار له مخې تنګوي.
      final daily = await widget.timetable.dailyGrid();
      final subjects = await widget.academic.subjects();
      if (!mounted) return;
      setState(() {
        _daily = daily;
        _subjects = subjects;
        _teachers = teachers;
        _conflicts = const [];
        _loading = false;
      });
      return;
    }

    final s = _section;
    if (s == null) {
      setState(() => _loading = false);
      return;
    }

    final grid = await widget.timetable.grid(sectionId: s.sectionId);
    final subjects = await widget.academic.subjects(gradeId: s.gradeId);
    final conflicts = await widget.timetable.conflicts();

    if (!mounted) return;
    setState(() {
      _grid = grid;
      _subjects = subjects;
      _teachers = teachers;
      _conflicts = conflicts;
      _loading = false;
    });
  }

  /// د مدرسې د یوې خانې سمون — کتار یوه درجه ده، نه یوه ورځ.
  Future<void> _editDailyCell(int sectionId, TimeSlot slot) async {
    final existing = _daily?.at(sectionId, slot.id);
    final row = _sections.where((x) => x.sectionId == sectionId).firstOrNull;

    // یوازې د هماغې درجې مضمونونه — یوه درجه د بلې کتابونه نه لري.
    final subjects = row == null
        ? _subjects
        : await widget.academic.subjects(gradeId: row.gradeId);
    if (!mounted) return;

    final result = await showDialog<_CellEdit>(
      context: context,
      builder: (_) => _CellDialog(
        day: everyDay,
        slot: slot,
        subjects: subjects,
        teachers: _teachers,
        current: existing,
      ),
    );
    if (result == null || !mounted) return;

    if (result.clear) {
      await widget.timetable.clearEntry(
        sectionId: sectionId,
        dayOfWeek: everyDay,
        slotId: slot.id,
      );
      await _load();
      return;
    }

    final outcome = await widget.timetable.setEntry(
      sectionId: sectionId,
      dayOfWeek: everyDay,
      slotId: slot.id,
      subjectId: result.subjectId!,
      teacherId: result.teacherId,
      room: result.room,
    );
    if (!mounted) return;

    switch (outcome) {
      case SetEntryOk():
        await _load();
      case SetEntryTeacherBusy(
        teacherName: final t,
        otherSection: final other,
      ):
        _warn('$t پر همدې ساعت په «$other» کې بوخت دی.');
      case SetEntryRoomBusy(room: final r, otherSection: final other):
        _warn('خونه «$r» پر همدې ساعت «$other» نیولې ده.');
    }
  }

  Future<void> _editCell(int day, TimeSlot slot) async {
    final s = _section;
    if (s == null) return;

    final existing = _grid?.at(day, slot.id);
    final result = await showDialog<_CellEdit>(
      context: context,
      builder: (_) => _CellDialog(
        day: day,
        slot: slot,
        subjects: _subjects,
        teachers: _teachers,
        current: existing,
      ),
    );
    if (result == null || !mounted) return;

    if (result.clear) {
      await widget.timetable.clearEntry(
        sectionId: s.sectionId,
        dayOfWeek: day,
        slotId: slot.id,
      );
      await _load();
      return;
    }

    final outcome = await widget.timetable.setEntry(
      sectionId: s.sectionId,
      dayOfWeek: day,
      slotId: slot.id,
      subjectId: result.subjectId!,
      teacherId: result.teacherId,
      room: result.room,
    );
    if (!mounted) return;

    switch (outcome) {
      case SetEntryOk():
        await _load();
      case SetEntryTeacherBusy(
        teacherName: final t,
        otherSection: final other,
      ):
        _warn('$t پر همدې وخت په «$other» کې بوخت دی.');
      case SetEntryRoomBusy(room: final r, otherSection: final other):
        _warn('خونه «$r» پر همدې وخت «$other» نیولې ده.');
    }
  }

  void _warn(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 520,
        backgroundColor: AppColors.danger,
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final grid = _grid;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                if (!_isDaily) ...[
                  _SectionPicker(
                    sections: _sections,
                    selected: _section,
                    onPicked: (s) {
                      setState(() => _section = s);
                      _load();
                    },
                  ),
                  const SizedBox(width: 14),
                ],
                if (_isDaily && _daily != null)
                  Text(
                    '${locale.num(_daily!.filled)} له '
                    '${locale.num(_daily!.capacity)} خانو ډکې  ·  '
                    'یو ترتیب چې هره ورځ تکرارېږي',
                    style: TextStyle(fontSize: 12.5, color: p.muted),
                  )
                else if (grid != null)
                  Text(
                    '${locale.num(grid.filled)} له '
                    '${locale.num(grid.capacity)} خانو ډکې',
                    style: TextStyle(fontSize: 12.5, color: p.muted),
                  ),
                const SizedBox(width: 14),
                SegmentedChoice<String>(
                  value: _mode,
                  color: AppColors.modTimetable,
                  options: const [
                    (
                      value: 'weekly',
                      label: 'اونیز (مکتب)',
                      icon: Icons.calendar_view_week_rounded,
                    ),
                    (
                      value: 'daily',
                      label: 'درجې (مدرسه)',
                      icon: Icons.table_rows_rounded,
                    ),
                  ],
                  onChanged: _setMode,
                ),
                const Spacer(),
                if (_conflicts.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.11),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          size: 16,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${locale.num(_conflicts.length)} ټکرونه',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _sections.isEmpty
                ? Center(
                    child: Text(
                      'لومړی ټولګي جوړ کړئ.',
                      style: TextStyle(fontSize: 13, color: p.muted),
                    ),
                  )
                : _isDaily
                ? (_daily == null
                      ? const SizedBox.shrink()
                      : _buildDaily(_daily!))
                : (grid == null
                      ? const SizedBox.shrink()
                      : _buildGrid(grid)),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(TimetableGrid grid) {
    final p = context.palette;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: p.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // سرلیک — د ورځو نومونه.
            Container(
              color: p.surfaceAlt,
              child: Row(
                children: [
                  const SizedBox(width: 118),
                  for (final day in grid.days)
                    Expanded(
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: p.line),
                          ),
                        ),
                        child: Text(
                          weekdayNamePs(day),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.inkSoft,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            for (final slot in grid.slots)
              _SlotRow(
                slot: slot,
                days: grid.days,
                grid: grid,
                onTap: slot.isBreak ? null : _editCell,
              ),
          ],
        ),
      ),
    );
  }

  /// **د مدرسې جدول** — کتارونه درجې دي، ستنې ساعتونه (له تفریح سره).
  ///
  /// دلته تفریح یوه **ستنه** ده، نه یو کتار — ځکه چې د ټولو درجو
  /// تفریح په یوه وخت کې ده، نو یوه نرۍ ستنه بس ده او د هرې درجې
  /// د ورځې ټول ترتیب په یوه کتار کې لیدل کېږي.
  Widget _buildDaily(DailyGrid daily) {
    final p = context.palette;
    final locale = S.of(context).locale;

    if (daily.rows.isEmpty) {
      return Center(
        child: Text(
          'لومړی درجې جوړې کړئ.',
          style: TextStyle(fontSize: 13, color: p.muted),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: p.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // سرلیک — د ساعتونو نومونه او وختونه.
              Container(
                color: p.surfaceAlt,
                child: Row(
                  children: [
                    const SizedBox(width: 150),
                    for (final slot in daily.slots)
                      Container(
                        width: slot.isBreak ? 62 : 150,
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: slot.isBreak
                              ? AppColors.warning.withValues(alpha: 0.07)
                              : null,
                          border: Border(right: BorderSide(color: p.line)),
                        ),
                        // د تفریح ستنه نرۍ ده — یوازې نوم پکې ځایېږي.
                        // وخت يې په tooltip کې دی.
                        child: slot.isBreak
                            ? Tooltip(
                                message:
                                    '${locale.num(slot.startTime)}–'
                                    '${locale.num(slot.endTime)}',
                                child: Text(
                                  locale.num(slot.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    locale.num(slot.name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                  Text(
                                    '${locale.num(slot.startTime)}–'
                                    '${locale.num(slot.endTime)}',
                                    style: AppTheme.tabular(
                                      TextStyle(fontSize: 9.5, color: p.faint),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                  ],
                ),
              ),
              for (final row in daily.rows)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: p.line)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: AlignmentDirectional.centerStart,
                          decoration: BoxDecoration(
                            color: p.surfaceAlt,
                            border: Border(left: BorderSide(color: p.line)),
                          ),
                          child: Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: p.ink,
                            ),
                          ),
                        ),
                        for (final slot in daily.slots)
                          SizedBox(
                            width: slot.isBreak ? 62 : 150,
                            child: slot.isBreak
                                ? Container(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.05,
                                    ),
                                  )
                                : _Cell(
                                    cell: daily.at(row.sectionId, slot.id),
                                    onTap: () => _editDailyCell(
                                      row.sectionId,
                                      slot,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _SlotRow extends StatelessWidget {
  final TimeSlot slot;
  final List<int> days;
  final TimetableGrid grid;
  final void Function(int day, TimeSlot slot)? onTap;

  const _SlotRow({
    required this.slot,
    required this.days,
    required this.grid,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    if (slot.isBreak) {
      return Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.07),
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: Text(
          '${locale.num(slot.name)}  •  ${locale.num(slot.startTime)}–'
          '${locale.num(slot.endTime)}',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.warning,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 118,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                border: Border(left: BorderSide(color: p.line)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.num(slot.name),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    '${locale.num(slot.startTime)}–${locale.num(slot.endTime)}',
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 10.5, color: p.faint),
                    ),
                  ),
                ],
              ),
            ),
            for (final day in days)
              Expanded(
                child: _Cell(
                  cell: grid.at(day, slot.id),
                  onTap: onTap == null ? null : () => onTap!(day, slot),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatefulWidget {
  final TimetableCell? cell;
  final VoidCallback? onTap;

  const _Cell({this.cell, this.onTap});

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell> {
  bool _hover = false;

  /// **د مضمون رنګ د نامه له مخې.** یو ثابت نقشه به هر ښوونځي ته
  /// نه برابرېده — ځینې «فزیک» لري، ځینې «حدیث». نو د نامه له
  /// hash څخه رنګ اخلو: هماغه مضمون تل هماغه رنګ لري.
  static const List<Color> _palette = [
    AppColors.modStudents,
    AppColors.modAttendance,
    AppColors.modLeave,
    AppColors.modClasses,
    AppColors.modExams,
    AppColors.modTeachers,
    AppColors.modIdCards,
    AppColors.modReports,
  ];

  Color _colorFor(String name) =>
      _palette[name.hashCode.abs() % _palette.length];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cell = widget.cell;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.instant,
          curve: AppMotion.standard,
          // درې کرښې: مضمون، استاد، خونه. ۵۸ پکسله يې نه نیول —
          // د خونې کرښه به بهر پاتې شوه.
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: cell == null
                ? (_hover ? p.surfaceAlt : Colors.transparent)
                : _colorFor(
                    cell.subjectName,
                  ).withValues(alpha: _hover ? 0.18 : 0.11),
            border: Border(right: BorderSide(color: p.line)),
          ),
          child: cell == null
              ? Center(
                  child: AnimatedOpacity(
                    duration: AppMotion.instant,
                    opacity: _hover ? 1 : 0,
                    child: Icon(Icons.add_rounded, size: 17, color: p.faint),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      cell.subjectName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _colorFor(cell.subjectName),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // کتاب لومړیتوب لري — د مدرسې د جدول ارزښت
                    // همدا دی. که کتاب نه وي (مکتب)، استاد ښیي.
                    Text(
                      cell.detail ?? 'استاد نه دی ټاکل شوی',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        color: cell.detail == null
                            ? AppColors.warning
                            : p.muted,
                      ),
                    ),
                    if (cell.entry.room != null)
                      Text(
                        S.of(context).locale.num(cell.entry.room!),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: p.faint),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _CellEdit {
  final int? subjectId;
  final int? teacherId;
  final String? room;
  final bool clear;

  const _CellEdit({this.subjectId, this.teacherId, this.room})
    : clear = false;
  const _CellEdit.clear()
    : subjectId = null,
      teacherId = null,
      room = null,
      clear = true;
}

class _CellDialog extends StatefulWidget {
  final int day;
  final TimeSlot slot;
  final List<Subject> subjects;
  final List<Teacher> teachers;
  final TimetableCell? current;

  const _CellDialog({
    required this.day,
    required this.slot,
    required this.subjects,
    required this.teachers,
    this.current,
  });

  @override
  State<_CellDialog> createState() => _CellDialogState();
}

class _CellDialogState extends State<_CellDialog> {
  late int? _subjectId = widget.current?.entry.subjectId;
  late int? _teacherId = widget.current?.entry.teacherId;
  late final _room = TextEditingController(
    text: widget.current?.entry.room ?? '',
  );

  @override
  void dispose() {
    _room.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Text(
        '${weekdayNamePs(widget.day)} — ${locale.num(widget.slot.name)}'
        '  (${locale.num(widget.slot.startTime)})',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Label('مضمون'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _subjectId,
              isExpanded: true,
              items: [
                for (final s in widget.subjects)
                  DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name, style: const TextStyle(fontSize: 13)),
                  ),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            const SizedBox(height: 16),
            const _Label('استاد'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: _teacherId,
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text(
                    'نه دی ټاکل شوی',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                for (final t in widget.teachers)
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(
                      t.fullName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _teacherId = v),
            ),
            const SizedBox(height: 16),
            const _Label('خونه (اختیاري)'),
            const SizedBox(height: 8),
            TextField(
              controller: _room,
              decoration: const InputDecoration(hintText: 'لکه ۱۰۱'),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.current != null)
          TextButton(
            onPressed: () => Navigator.pop(context, const _CellEdit.clear()),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('پاک کړه'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: _subjectId == null
              ? null
              : () => Navigator.pop(
                  context,
                  _CellEdit(
                    subjectId: _subjectId,
                    teacherId: _teacherId,
                    room: _room.text,
                  ),
                ),
          child: const Text('وساتـه'),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: context.palette.muted,
    ),
  );
}

class _SectionPicker extends StatelessWidget {
  final List<SectionOption> sections;
  final SectionOption? selected;
  final ValueChanged<SectionOption> onPicked;

  const _SectionPicker({
    required this.sections,
    required this.selected,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<SectionOption>(
      tooltip: '',
      onSelected: onPicked,
      itemBuilder: (_) => [
        for (final s in sections)
          PopupMenuItem(
            value: s,
            child: Text(s.label, style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              size: 17,
              color: AppColors.modTimetable,
            ),
            const SizedBox(width: 9),
            Text(
              selected?.label ?? 'ټولګی وټاکئ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more_rounded, size: 17, color: p.muted),
          ],
        ),
      ),
    );
  }
}
