import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/calendars.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/holiday_repository.dart';

/// ═══════════════════════════════════════════════════════════
///  **د رخصتیو کلیز.**
///
///  **ولې دا پاڼه پکار وه؟**
///
///  رسمي رخصتي **د ورځې** ځانګړتیا ده، نه **د شاګرد**. مخکې زموږ
///  سیستم یوازې دا پوښتنه ځوابولی شوه: «دا شاګرد نن حاضر و؟» — نو
///  د اختر ورځ به یا هېڅ نه وه ثبته (او رپوټ به يې «نه‌نښه‌شوې»
///  ګڼله)، یا مدیر به درې سوه ځله «رخصت» نښه کاوه. دواړه غلط دي:
///  لومړی معلومات ورکوي، دویم د ورځې مانا شاګرد ته لېږدوي.
///
///  **د ښودنې لار — کلیز، نه لیست.**
///
///  یو لیست وايي «۲۰۲۶/۳/۲۰ تر ۲۰۲۶/۳/۲۳». یو کلیز وايي **دا** —
///  او سترګه سمدستي ویني چې څلور ورځې دي، له کومې اونۍ سره لګېږي،
///  او د جمعې سره یو ځای څو ورځې کار نه کېږي. د نېټو په اړه هره
///  پوښتنه د کلیز پر مخ ژر ځواب مومي.
/// ═══════════════════════════════════════════════════════════
class HolidaysPage extends StatefulWidget {
  final HolidayRepository holidays;
  final AcademicRepository academic;
  final bool canEdit;
  final int byUserId;

  /// د ازموینو لپاره — چې «نن» ثابته وي.
  final DateTime Function() clock;

  const HolidaysPage({
    super.key,
    required this.holidays,
    required this.academic,
    this.canEdit = true,
    this.byUserId = 1,
    this.clock = DateTime.now,
  });

  @override
  State<HolidaysPage> createState() => _HolidaysPageState();
}

class _HolidaysPageState extends State<HolidaysPage> {
  late DateTime _month = DateTime(widget.clock().year, widget.clock().month);
  List<Holiday> _all = const [];
  Set<int> _weekend = const {4, 5};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await widget.holidays.all();
    final school = await widget.academic.school();
    final weekend = (school?.weekendDays ?? '4,5')
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toSet();
    if (!mounted) return;
    setState(() {
      _all = all;
      _weekend = weekend;
      _loading = false;
    });
  }

  /// د دې میاشتې هغه ورځې چې رخصتي دي → کومه رخصتي.
  Map<int, Holiday> get _daysOfMonth {
    final out = <int, Holiday>{};
    final last = DateTime(_month.year, _month.month + 1, 0).day;
    for (var d = 1; d <= last; d++) {
      final day = DateTime(_month.year, _month.month, d);
      for (final h in _all) {
        if (HolidayRepository.covers(h, day)) {
          out[d] = h;
          break;
        }
      }
    }
    return out;
  }

  void _shift(int by) =>
      setState(() => _month = DateTime(_month.year, _month.month + by));

  Future<void> _edit({Holiday? existing, DateTime? preset}) async {
    final r = await showDialog<_HolidayDraft>(
      context: context,
      builder: (_) => _HolidayDialog(
        existing: existing,
        preset: preset,
      ),
    );
    if (r == null) return;

    if (r.delete && existing != null) {
      await widget.holidays.remove(existing.id);
    } else if (existing == null) {
      await widget.holidays.add(
        name: r.name,
        fromDate: r.from,
        toDate: r.to,
        kind: r.kind,
        note: r.note,
        isAnnual: r.isAnnual,
        byUserId: widget.byUserId,
      );
    } else {
      await widget.holidays.update(
        id: existing.id,
        name: r.name,
        fromDate: r.from,
        toDate: r.to,
        kind: r.kind,
        note: r.note ?? '',
        isAnnual: r.isAnnual,
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final marked = _daysOfMonth;

    // د دې میاشتې رخصتۍ — د څنګ لیست لپاره.
    final ofMonth = <Holiday>[];
    for (final h in marked.values) {
      if (!ofMonth.contains(h)) ofMonth.add(h);
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                Text(
                  'د رخصتیو کلیز',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: p.ink,
                  ),
                ),
                const SizedBox(width: 14),
                _MonthNav(
                  label: context.cal.monthYear(_month),
                  onPrev: () => _shift(-1),
                  onNext: () => _shift(1),
                  onToday: () => setState(() {
                    final n = widget.clock();
                    _month = DateTime(n.year, n.month);
                  }),
                ),
                const Spacer(),
                Text(
                  marked.isEmpty
                      ? 'دې میاشت کې رخصتي نشته'
                      : '${locale.num(marked.length)} ورځې رخصتي',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
                const SizedBox(width: 14),
                if (widget.canEdit)
                  FilledButton.icon(
                    onPressed: () => _edit(),
                    icon: const Icon(Icons.event_busy_rounded, size: 17),
                    label: const Text('نوې رخصتي'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.modLeave,
                      minimumSize: const Size(0, 44),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final narrow = c.maxWidth < 940;
                final calendar = FadeSlideIn.staggered(
                  index: 0,
                  child: Panel(
                    title: 'میاشت',
                    icon: Icons.calendar_month_rounded,
                    color: AppColors.modLeave,
                    subtitle: 'پر یوه ورځ کلیک — رخصتي جوړېږي یا سمېږي.',
                    child: _MonthGrid(
                      month: _month,
                      marked: marked,
                      weekend: _weekend,
                      today: widget.clock(),
                      onTapDay: !widget.canEdit
                          ? null
                          : (d) {
                              final day = DateTime(
                                _month.year,
                                _month.month,
                                d,
                              );
                              _edit(existing: marked[d], preset: day);
                            },
                    ),
                  ),
                );

                final list = FadeSlideIn.staggered(
                  index: 1,
                  child: _HolidayList(
                    holidays: ofMonth,
                    all: _all,
                    canEdit: widget.canEdit,
                    onEdit: (h) => _edit(existing: h),
                  ),
                );

                if (narrow) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [calendar, const SizedBox(height: 16), list],
                    ),
                  );
                }
                return SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: calendar),
                      const SizedBox(width: 16),
                      Expanded(flex: 2, child: list),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د میاشتې شبکه
// ═══════════════════════════════════════════════════════════

/// د اونۍ سرلیکونه — **له شنبې پیل**، لکه افغانستان کې.
const _weekLabels = ['شنبه', 'یکشنبه', 'دوشنبه', 'سه‌شنبه', 'چهارشنبه', 'پنجشنبه', 'جمعه'];

/// `DateTime.weekday` (دوشنبه=۱ … یکشنبه=۷) → زموږ ستنه (شنبه=۰).
int _column(DateTime d) => (d.weekday + 1) % 7;

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<int, Holiday> marked;
  final Set<int> weekend;
  final DateTime today;
  final ValueChanged<int>? onTapDay;

  const _MonthGrid({
    required this.month,
    required this.marked,
    required this.weekend,
    required this.today,
    this.onTapDay,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    final first = DateTime(month.year, month.month);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final lead = _column(first);
    final cells = lead + lastDay;
    final rows = (cells / 7).ceil();

    return Column(
      children: [
        Row(
          children: [
            for (final w in _weekLabels)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    w,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: p.faint,
                    ),
                  ),
                ),
              ),
          ],
        ),
        for (var r = 0; r < rows; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final n = r * 7 + c - lead + 1;
                      if (n < 1 || n > lastDay) {
                        return const SizedBox(height: 62);
                      }
                      final day = DateTime(month.year, month.month, n);
                      return _DayCell(
                        day: n,
                        label: locale.num(n),
                        holiday: marked[n],
                        isWeekend: weekend.contains(day.weekday),
                        isToday: day.year == today.year &&
                            day.month == today.month &&
                            day.day == today.day,
                        onTap: onTapDay == null ? null : () => onTapDay!(n),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatefulWidget {
  final int day;
  final String label;
  final Holiday? holiday;
  final bool isWeekend;
  final bool isToday;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.label,
    required this.holiday,
    required this.isWeekend,
    required this.isToday,
    this.onTap,
  });

  @override
  State<_DayCell> createState() => _DayCellState();
}

class _DayCellState extends State<_DayCell> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final h = widget.holiday;
    final c = h == null ? null : holidayColor(h.kind);

    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          height: 62,
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: c != null
                ? c.withValues(alpha: _hover ? 0.24 : 0.16)
                : widget.isWeekend
                // **د اونۍ رخصت لږ خړ دی، نه رنګین.** هغه هره اونۍ
                // راځي؛ که رنګ يې درلود، سترګه به له رسمي رخصتۍ سره
                // ګډ کړی و.
                ? p.surfaceAlt
                : (_hover ? p.surfaceAlt : Colors.transparent),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: widget.isToday
                  ? AppColors.primary
                  : (c != null ? c.withValues(alpha: 0.35) : p.line),
              width: widget.isToday ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: AppTheme.tabular(
                  TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: c ?? (widget.isWeekend ? p.faint : p.inkSoft),
                  ),
                ),
              ),
              if (h != null) ...[
                const SizedBox(height: 2),
                Expanded(
                  child: Text(
                    h.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                      color: c,
                    ),
                  ),
                ),
              ] else if (widget.isWeekend) ...[
                const SizedBox(height: 2),
                Text(
                  'اونیز رخصت',
                  style: TextStyle(fontSize: 9, color: p.faint),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

Color holidayColor(String kind) => switch (kind) {
  'religious' => AppColors.modHifz,
  'weather' => AppColors.info,
  'exam' => AppColors.modExams,
  'other' => AppColors.info,
  _ => AppColors.modLeave,
};

// ═══════════════════════════════════════════════════════════
//  د څنګ لیست
// ═══════════════════════════════════════════════════════════

class _HolidayList extends StatelessWidget {
  final List<Holiday> holidays;
  final List<Holiday> all;
  final bool canEdit;
  final ValueChanged<Holiday> onEdit;

  const _HolidayList({
    required this.holidays,
    required this.all,
    required this.canEdit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;

    return Panel(
      title: 'د دې میاشتې رخصتۍ',
      icon: Icons.event_busy_rounded,
      color: AppColors.modLeave,
      subtitle: '${locale.num(all.length)} رخصتۍ په ټول کلیز کې',
      child: holidays.isEmpty
          ? const SizedBox(
              height: 180,
              child: EmptyState(
                icon: Icons.event_available_rounded,
                text: 'دې میاشت کې رسمي رخصتي نشته',
                hint: 'پر یوه ورځ کلیک وکړئ چې رخصتي جوړه شي.',
              ),
            )
          : Column(
              children: [
                for (final h in holidays)
                  _HolidayRow(
                    holiday: h,
                    canEdit: canEdit,
                    onTap: () => onEdit(h),
                  ),
              ],
            ),
    );
  }
}

class _HolidayRow extends StatefulWidget {
  final Holiday holiday;
  final bool canEdit;
  final VoidCallback onTap;

  const _HolidayRow({
    required this.holiday,
    required this.canEdit,
    required this.onTap,
  });

  @override
  State<_HolidayRow> createState() => _HolidayRowState();
}

class _HolidayRowState extends State<_HolidayRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    final h = widget.holiday;
    final c = holidayColor(h.kind);
    final days = h.toDate.difference(h.fromDate).inDays + 1;

    final cal = context.cal;
    String d(DateTime x) => cal.dayMonth(x);

    return MouseRegion(
      cursor: widget.canEdit ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.canEdit ? widget.onTap : null,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: _hover ? p.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      h.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      days == 1
                          ? '${d(h.fromDate)} · یوه ورځ'
                          : '${d(h.fromDate)} – ${d(h.toDate)} · '
                                '${locale.num(days)} ورځې',
                      style: TextStyle(fontSize: 11.5, color: p.muted),
                    ),
                  ],
                ),
              ),
              if (h.isAnnual)
                Padding(
                  padding: const EdgeInsetsDirectional.only(end: 6),
                  child: Tooltip(
                    message: 'هر کال تکرارېږي',
                    child: Icon(
                      Icons.repeat_rounded,
                      size: 15,
                      color: p.faint,
                    ),
                  ),
                ),
              Pill(color: c, text: holidayKindLabel(h.kind)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MonthNav extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onToday;

  const _MonthNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
    required this.onToday,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPrev,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
          ),
          GestureDetector(
            onTap: onToday,
            child: Tooltip(
              message: 'روانې میاشتې ته',
              child: Text(
                label,
                style: AppTheme.tabular(
                  TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ډیالوګ
// ═══════════════════════════════════════════════════════════

class _HolidayDraft {
  final String name;
  final DateTime from;
  final DateTime to;
  final String kind;
  final String? note;
  final bool isAnnual;
  final bool delete;

  const _HolidayDraft({
    required this.name,
    required this.from,
    required this.to,
    required this.kind,
    required this.isAnnual,
    this.note,
    this.delete = false,
  });
}

class _HolidayDialog extends StatefulWidget {
  final Holiday? existing;
  final DateTime? preset;

  const _HolidayDialog({this.existing, this.preset});

  @override
  State<_HolidayDialog> createState() => _HolidayDialogState();
}

class _HolidayDialogState extends State<_HolidayDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _note = TextEditingController(text: widget.existing?.note ?? '');

  late DateTime _from =
      widget.existing?.fromDate ?? widget.preset ?? DateTime.now();
  late DateTime _to =
      widget.existing?.toDate ?? widget.preset ?? DateTime.now();
  late String _kind = widget.existing?.kind ?? 'official';
  late bool _annual = widget.existing?.isAnnual ?? false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick({required bool start}) async {
    final base = start ? _from : _to;
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: DateTime(base.year - 3),
      lastDate: DateTime(base.year + 3),
    );
    if (picked == null) return;
    setState(() {
      if (start) {
        _from = picked;
        // **پای پخپله ورسره ځي.** که پیل له پایه وروسته شي، کارن
        // به یوه تشه موده جوړه کړې وه او نه به پوهېده ولې رخصتي
        // هېڅ ورځ نه نیسي.
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked;
        if (_to.isBefore(_from)) _from = _to;
      }
    });
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'نوم اړین دی.');
      return;
    }
    Navigator.pop(
      context,
      _HolidayDraft(
        name: name,
        from: _from,
        to: _to,
        kind: _kind,
        note: _note.text,
        isAnnual: _annual,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final days = _to.difference(_from).inDays + 1;

    final cal = context.cal;
    String d(DateTime x) => cal.long(x);

    return AlertDialog(
      title: Text(
        widget.existing == null ? 'نوې رخصتي' : 'د رخصتۍ سمون',
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'د رخصتۍ نوم',
                  hintText: 'لکه: د کوچني اختر رخصتي',
                  isDense: true,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _DateBox(
                      label: 'له',
                      value: d(_from),
                      onTap: () => _pick(start: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateBox(
                      label: 'تر',
                      value: d(_to),
                      onTap: () => _pick(start: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                days == 1
                    ? 'یوه ورځ رخصتي.'
                    : '${locale.num(days)} ورځې رخصتي.',
                style: TextStyle(fontSize: 11.5, color: p.muted),
              ),
              const SizedBox(height: 16),
              Text(
                'ډول',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: p.muted,
                ),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final k in holidayKinds)
                    ChoiceChip(
                      label: Text(
                        k.label,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      selected: _kind == k.key,
                      showCheckmark: false,
                      selectedColor: holidayColor(
                        k.key,
                      ).withValues(alpha: 0.16),
                      onSelected: (_) => setState(() => _kind = k.key),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              CheckboxListTile(
                value: _annual,
                onChanged: (v) => setState(() => _annual = v ?? false),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'هر کال تکرارېږي',
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  'لکه د استقلال ورځ — کال يې نه شمېرل کېږي.',
                  style: TextStyle(fontSize: 11, color: p.faint),
                ),
              ),
              TextField(
                controller: _note,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'یادښت (اختیاري)',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      // **`actions` یو `OverflowBar` دی، نه یو `Row`.**
      //
      // یو `Spacer` هلته د `Flex` مور غواړي — او نه يې مومي. پایله
      // يې یوه استثنا وه چې ټول ډیالوګ يې تش پرېښود: کارن به یوه
      // سپینه پاڼه لیدله او فکر يې کاوه چې پروګرام مات دی.
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        if (widget.existing != null)
          TextButton.icon(
            onPressed: () => Navigator.pop(
              context,
              _HolidayDraft(
                name: widget.existing!.name,
                from: widget.existing!.fromDate,
                to: widget.existing!.toDate,
                kind: widget.existing!.kind,
                isAnnual: widget.existing!.isAnnual,
                delete: true,
              ),
            ),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            icon: const Icon(Icons.delete_outline_rounded, size: 17),
            label: Text(s.delete),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(s.cancel),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.modLeave,
              ),
              child: Text(s.save),
            ),
          ],
        ),
      ],
    );
  }
}

class _DateBox extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateBox({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 2, bottom: 5),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: p.muted,
            ),
          ),
        ),
        OutlinedButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.calendar_today_rounded, size: 15),
          label: Text(value, style: const TextStyle(fontSize: 12.5)),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 42),
            alignment: AlignmentDirectional.centerStart,
          ),
        ),
      ],
    );
  }
}
