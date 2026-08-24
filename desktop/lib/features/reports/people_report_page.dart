import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/csv.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/report_repository.dart';
import 'report_table_view.dart';

/// **د کسانو راپور** — شاګردان، استادان یا کارمندان.
///
/// **درې ډلې، یوه پاڼه.** ځکه چې پوښتنه یوه ده: «کوم کسان، کومه
/// دوره، او څنګه؟» یوازې فلټرونه بدل شي. که درې پاڼې وې، د یوه نوي
/// فلټر زیاتول به درې ځله کېده — او یو ځای به تل هېر شو.
class PeopleReportPage extends StatefulWidget {
  final ReportRepository reports;
  final AcademicRepository academic;
  final String schoolName;

  /// `student` | `teacher` | `staff`
  final String audience;

  final Future<void> Function(ReportTable)? onPrint;
  final Future<void> Function(ReportTable, String csv)? onExport;

  /// د ازموینې لپاره — چې «نن» ثابت وي.
  final DateTime Function() clock;

  const PeopleReportPage({
    super.key,
    required this.reports,
    required this.academic,
    required this.schoolName,
    required this.audience,
    this.onPrint,
    this.onExport,
    this.clock = DateTime.now,
  });

  @override
  State<PeopleReportPage> createState() => _PeopleReportPageState();
}

class _PeopleReportPageState extends State<PeopleReportPage> {
  late PeopleReportFilter _filter;

  /// د کچې لنګر — ‹ › يې خوځوي.
  late DateTime _anchor;

  ReportTable? _table;
  List<ReportPerson> _people = const [];
  List<SectionOption> _sections = const [];
  List<String> _tags = const [];
  bool _loading = true;
  bool _showFilters = false;

  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _anchor = widget.clock();
    final (from, to) = PeopleReportFilter.window(ReportRange.month, _anchor);
    _filter = PeopleReportFilter(
      audience: widget.audience,
      from: from,
      to: to,
    );
    _boot();
  }

  @override
  void didUpdateWidget(PeopleReportPage old) {
    super.didUpdateWidget(old);
    if (old.audience != widget.audience) {
      // د ډلې بدلون ټول فلټرونه پاکوي — د استاد «تخصص» د شاګرد
      // لپاره معنا نه لري، او یو پاتې فلټر به تش لیست ښودلی و.
      _search.clear();
      _filter = PeopleReportFilter(
        audience: widget.audience,
        from: _filter.from,
        to: _filter.to,
        range: _filter.range,
        scope: _filter.scope,
      );
      _boot();
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final sections = widget.audience == 'student'
        ? await widget.academic.sections()
        : const <SectionOption>[];
    final tags = await widget.reports.reportTags(widget.audience);
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _tags = tags;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final people = await widget.reports.people(_filter);
    final table = await widget.reports.peopleReport(_filter);
    if (!mounted) return;
    setState(() {
      _people = people;
      _table = table;
      _loading = false;
    });
  }

  void _set(PeopleReportFilter next) {
    setState(() => _filter = next);
    _load();
  }

  /// کچه بدلوي — او د کړکۍ نېټې يې له سره حسابوي.
  void _setRange(ReportRange r) {
    if (r == ReportRange.custom) {
      _pickRange();
      return;
    }
    final (from, to) = PeopleReportFilter.window(r, _anchor);
    _set(_filter.copyWith(range: r, from: from, to: to));
  }

  /// **‹ › یوه بشپړه دوره خوځوي، نه یوه ورځ.**
  ///
  /// که تل یوه ورځ خوځېده، د میاشتنۍ کتنې لپاره به کارن دېرش ځله
  /// کېکاږلو ته اړ و.
  void _shift(int by) {
    if (_filter.range == ReportRange.custom) {
      final span = _filter.to.difference(_filter.from).inDays + 1;
      final from = _filter.from.add(Duration(days: span * by));
      _set(
        _filter.copyWith(
          from: from,
          to: from.add(Duration(days: span - 1)),
        ),
      );
      return;
    }
    _anchor = switch (_filter.range) {
      ReportRange.day => _anchor.add(Duration(days: by)),
      ReportRange.week => _anchor.add(Duration(days: 7 * by)),
      _ => DateTime(_anchor.year, _anchor.month + by, 1),
    };
    final (from, to) = PeopleReportFilter.window(_filter.range, _anchor);
    _set(_filter.copyWith(from: from, to: to));
  }

  Future<void> _pickRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2015),
      lastDate: DateTime(widget.clock().year + 2),
      initialDateRange: DateTimeRange(start: _filter.from, end: _filter.to),
    );
    if (picked == null || !mounted) return;
    _set(
      _filter.copyWith(
        range: ReportRange.custom,
        from: picked.start,
        to: picked.end,
      ),
    );
  }

  Future<void> _export() async {
    final t = _table;
    if (t == null || t.isEmpty || widget.onExport == null) return;
    await widget.onExport!(
      t,
      Csv.build(columns: t.columns, rows: t.rows, totals: t.totals),
    );
  }

  String get _title => switch (widget.audience) {
    'teacher' => 'د استادانو راپور',
    'staff' => 'د کارمندانو راپور',
    _ => 'د شاګردانو راپور',
  };

  /// **دا پاڼه څه کار کوي؟**
  ///
  /// یوه کرښه، ځکه چې یو کارن چې لومړی ځل دلته راځي، د فلټرونو له
  /// یوې قطارې سره مخ کېږي او نه پوهېږي چې پوښتنه يې څه ده.
  String get _hint => switch (widget.audience) {
    'teacher' =>
      'کوم استاد په ټاکلې موده کې څومره راغلی او څومره يې پرېښې ده؟ '
          'موده وټاکئ، بیا ډله‌ییز لیست وګورئ یا یو تن ونیسئ.',
    'staff' =>
      'کوم کارمند په ټاکلې موده کې څومره راغلی؟ '
          'موده وټاکئ، بیا ډله‌ییز لیست وګورئ یا یو تن ونیسئ.',
    _ =>
      'کوم شاګرد په ټاکلې موده کې څومره راغلی او څومره يې غیرحاضري ده؟ '
          'موده وټاکئ، بیا ډله‌ییز لیست وګورئ یا یو تن ونیسئ.',
  };

  Color get _accent => switch (widget.audience) {
    'teacher' => AppColors.modTeachers,
    'staff' => AppColors.modStaff,
    _ => AppColors.modStudents,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final t = _table;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
          child: FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Text(
                      _title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(width: 12),
                    _RangeNav(
                      label: _spanLabel(locale),
                      onPrev: () => _shift(-1),
                      onNext: () => _shift(1),
                    ),
                    const Spacer(),
                    OutlinedButton.icon(
                      onPressed: t == null || t.isEmpty ? null : _export,
                      icon: const Icon(Icons.download_rounded, size: 16),
                      label: Text(s.export),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                    const SizedBox(width: 9),
                    FilledButton.icon(
                      onPressed: t == null || t.isEmpty || widget.onPrint == null
                          ? null
                          : () => widget.onPrint!(t),
                      icon: const Icon(Icons.print_rounded, size: 16),
                      label: Text(s.print),
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        minimumSize: const Size(0, 40),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  _hint,
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
                const SizedBox(height: 14),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    SegmentedChoice<ReportRange>(
                      value: _filter.range,
                      color: _accent,
                      options: [
                        for (final r in ReportRange.values)
                          (value: r, label: r.label, icon: null),
                      ],
                      onChanged: _setRange,
                    ),
                    SegmentedChoice<ReportScope>(
                      value: _filter.scope,
                      color: _accent,
                      options: const [
                        (
                          value: ReportScope.group,
                          label: 'ډله‌ییز',
                          icon: Icons.groups_rounded,
                        ),
                        (
                          value: ReportScope.individual,
                          label: 'انفرادي',
                          icon: Icons.person_rounded,
                        ),
                      ],
                      onChanged: (v) => _set(_filter.copyWith(scope: v)),
                    ),
                    SizedBox(
                      width: 220,
                      child: TextField(
                        controller: _search,
                        onSubmitted: (v) =>
                            _set(_filter.copyWith(query: v)),
                        decoration: InputDecoration(
                          hintText: '${s.search} — نوم یا نمبر',
                          prefixIcon: const Icon(Icons.search_rounded, size: 17),
                          isDense: true,
                        ),
                      ),
                    ),
                    _FilterToggle(
                      open: _showFilters,
                      count: _filter.activeCount,
                      color: _accent,
                      onTap: () =>
                          setState(() => _showFilters = !_showFilters),
                    ),
                    // **د انفرادي حالت کې د کس ټاکنه پکار ده** — نو
                    // یوازې هلته ښکاري، چې ډله‌ییز حالت شلوغ نه شي.
                    if (_filter.scope == ReportScope.individual &&
                        _people.isNotEmpty)
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<int>(
                          initialValue: _filter.personId ?? _people.first.id,
                          isDense: true,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: 'کوم کس',
                            isDense: true,
                          ),
                          items: [
                            for (final x in _people)
                              DropdownMenuItem(
                                value: x.id,
                                child: Text(
                                  x.label,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                          onChanged: (v) =>
                              _set(_filter.copyWith(personId: v)),
                        ),
                      ),
                  ],
                ),

                AnimatedSize(
                  duration: AppMotion.normal,
                  curve: AppMotion.standard,
                  alignment: Alignment.topCenter,
                  child: _showFilters
                      ? Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _FilterPanel(
                            filter: _filter,
                            sections: _sections,
                            tags: _tags,
                            accent: _accent,
                            onChanged: _set,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : t == null || t.isEmpty
              ? EmptyState(
                  icon: Icons.summarize_rounded,
                  text: t?.subtitle ?? 'هېڅ معلومات نشته.',
                )
              : ReportTableView(table: t, accent: _accent),
        ),
      ],
    );
  }

  String _spanLabel(AppLocale locale) {
    String d(DateTime x) =>
        '${locale.num(x.year)}-${locale.num(x.month)}-${locale.num(x.day)}';
    if (_filter.range == ReportRange.day) return d(_filter.from);
    if (_filter.range == ReportRange.month) {
      return '${locale.num(_filter.from.month)}/${locale.num(_filter.from.year)}';
    }
    return '${d(_filter.from)} → ${d(_filter.to)}';
  }
}

// ═══════════════════════════════════════════════════════════

/// د دورې پرمخ‌تګ — ‹ [دوره] ›.
class _RangeNav extends StatelessWidget {
  final String label;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const _RangeNav({
    required this.label,
    required this.onPrev,
    required this.onNext,
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
            tooltip: 'پخوانۍ دوره',
            onPressed: onPrev,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded, size: 19),
          ),
          Text(
            label,
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.inkSoft,
              ),
            ),
          ),
          IconButton(
            tooltip: 'راتلونکې دوره',
            onPressed: onNext,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded, size: 19),
          ),
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final bool open;
  final int count;
  final Color color;
  final VoidCallback onTap;

  const _FilterToggle({
    required this.open,
    required this.count,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final on = count > 0 || open;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: on ? color.withValues(alpha: 0.09) : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: on ? color.withValues(alpha: 0.4) : p.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 16, color: on ? color : p.muted),
            const SizedBox(width: 6),
            Text(
              s.filters,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: count > 0 ? FontWeight.w700 : FontWeight.w500,
                color: on ? color : p.inkSoft,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  s.locale.num(count),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// د ډلې پورې اړوند فلټرونه.
class _FilterPanel extends StatelessWidget {
  final PeopleReportFilter filter;
  final List<SectionOption> sections;
  final List<String> tags;
  final Color accent;
  final ValueChanged<PeopleReportFilter> onChanged;

  const _FilterPanel({
    required this.filter,
    required this.sections,
    required this.tags,
    required this.accent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final student = filter.audience == 'student';

    return Panel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (student && sections.isNotEmpty)
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<int?>(
                    initialValue: filter.sectionId,
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: s.classes,
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(s.all)),
                      for (final sec in sections)
                        DropdownMenuItem(
                          value: sec.sectionId,
                          child: Text('${sec.gradeName} — ${sec.sectionName}'),
                        ),
                    ],
                    onChanged: (v) => onChanged(
                      v == null
                          ? filter.copyWith(clearSection: true)
                          : filter.copyWith(sectionId: v),
                    ),
                  ),
                ),
              if (!student && tags.isNotEmpty)
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<String?>(
                    initialValue: filter.audience == 'teacher'
                        ? filter.specialization
                        : filter.department,
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: filter.audience == 'teacher'
                          ? 'تخصص'
                          : 'څانګه',
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(s.all)),
                      for (final t in tags)
                        DropdownMenuItem(value: t, child: Text(t)),
                    ],
                    onChanged: (v) => onChanged(
                      filter.audience == 'teacher'
                          ? (v == null
                                ? filter.copyWith(clearSpecialization: true)
                                : filter.copyWith(specialization: v))
                          : (v == null
                                ? filter.copyWith(clearDepartment: true)
                                : filter.copyWith(department: v)),
                    ),
                  ),
                ),

              SegmentedChoice<String?>(
                value: filter.gender,
                options: [
                  (value: null, label: s.all, icon: null),
                  (value: 'male', label: 'نارینه', icon: null),
                  (value: 'female', label: 'ښځینه', icon: null),
                ],
                onChanged: (v) => onChanged(
                  v == null
                      ? filter.copyWith(clearGender: true)
                      : filter.copyWith(gender: v),
                ),
              ),

              if (student)
                SegmentedChoice<String?>(
                  value: filter.residency,
                  options: [
                    (value: null, label: s.all, icon: null),
                    (
                      value: 'day',
                      label: s.dayScholar,
                      icon: Icons.wb_sunny_rounded,
                    ),
                    (
                      value: 'boarding',
                      label: s.boarder,
                      icon: Icons.night_shelter_rounded,
                    ),
                  ],
                  onChanged: (v) => onChanged(
                    v == null
                        ? filter.copyWith(clearResidency: true)
                        : filter.copyWith(residency: v),
                  ),
                ),

              // **«له دې سلنې ټیټ»** — د راپور اصلي پوښتنه.
              //
              // مدیر نه غواړي درې سوه کرښې ولولي؛ هغه غواړي پوه شي
              // چې **څوک ستونزه لري**. دا فلټر هماغه لیست راوړي.
              SegmentedChoice<int?>(
                value: filter.belowPercent,
                color: AppColors.warning,
                options: const [
                  (value: null, label: 'ټول', icon: null),
                  (value: 90, label: 'له ۹۰٪ ټیټ', icon: null),
                  (value: 75, label: 'له ۷۵٪ ټیټ', icon: null),
                  (value: 50, label: 'له ۵۰٪ ټیټ', icon: null),
                ],
                onChanged: (v) => onChanged(
                  v == null
                      ? filter.copyWith(clearBelow: true)
                      : filter.copyWith(belowPercent: v),
                ),
              ),
            ],
          ),
          if (filter.activeCount > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${s.locale.num(filter.activeCount)} فلټرونه فعال دي',
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => onChanged(
                    PeopleReportFilter(
                      audience: filter.audience,
                      from: filter.from,
                      to: filter.to,
                      range: filter.range,
                      scope: filter.scope,
                      personId: filter.personId,
                      query: filter.query,
                    ),
                  ),
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: Text(s.clearFilters),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
