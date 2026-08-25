import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/csv.dart';
import '../../core/utils/numerals.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/exam_repository.dart';
import '../../data/repositories/report_repository.dart';
import 'report_pdf.dart';

/// د رپوټونو پاڼه.
///
/// **ټول رپوټونه یوه بڼه لري** (`ReportTable`) — نو چاپ، CSV او
/// جدول یو ځل جوړ شوي دي. یو نوی رپوټ یوازې یوه پوښتنه ده، نه یوه
/// نوې پاڼه.
class ReportsPage extends StatefulWidget {
  final ReportRepository reports;
  final AcademicRepository academic;
  final ExamRepository exams;
  final String schoolName;

  /// د ازموینې لپاره — چاپ او فایل ساتل نه کوو.
  final Future<void> Function(ReportTable)? onPrint;
  final Future<void> Function(ReportTable, String csv)? onExport;

  const ReportsPage({
    super.key,
    required this.reports,
    required this.academic,
    required this.exams,
    required this.schoolName,
    this.onPrint,
    this.onExport,
  });

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  ReportKind _kind = ReportKind.attendance;
  bool _loading = true;
  ReportTable? _table;

  List<SectionOption> _sections = const [];
  SectionOption? _section;
  DateTime _month = DateTime.now();

  List<ExamRow> _exams = const [];
  ExamRow? _exam;

  List<String> _periods = const [];
  String? _period;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final sections = await widget.academic.sections();
    final exams = await widget.exams.list();
    // د حاضرۍ رپوټ هغه میاشت پرانیزي چې ډیټا پکې شته — نه «نن»،
    // چې د میاشتې په لومړۍ ورځ تش نه وي.
    final latest = await widget.reports.latestAttendanceMonth();
    final periods = await widget.reports.db
        .customSelect('SELECT DISTINCT period FROM fee_invoices '
            'ORDER BY period DESC')
        .get();

    if (!mounted) return;
    setState(() {
      _sections = sections;
      _exams = exams;
      _exam = exams.firstOrNull;
      _periods = periods.map((r) => r.read<String>('period')).toList();
      _period = _periods.firstOrNull;
      if (latest != null) _month = latest;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final table = switch (_kind) {
      ReportKind.attendance => await widget.reports.attendance(
        month: _month,
        sectionId: _section?.sectionId,
        sectionLabel: _section?.label,
      ),
      ReportKind.fees => await widget.reports.fees(period: _period),
      ReportKind.exam => _exam == null
          ? const ReportTable(
              title: 'د ازموینې پایلې',
              subtitle: 'هېڅ ازموینه نشته',
              columns: [],
              rows: [],
            )
          : await widget.reports.exam(examId: _exam!.exam.id),
      ReportKind.enrollment => await widget.reports.enrollment(),
      ReportKind.staff => await widget.reports.staff(),
    };

    if (!mounted) return;
    setState(() {
      _table = table;
      _loading = false;
    });
  }

  Future<void> _print() async {
    final t = _table;
    if (t == null) return;
    if (widget.onPrint != null) {
      await widget.onPrint!(t);
      return;
    }
    await printReport(table: t, schoolName: widget.schoolName);
  }

  Future<void> _export() async {
    final t = _table;
    if (t == null) return;

    final csv = Csv.build(
      columns: t.columns,
      rows: t.rows,
      totals: t.totals,
    );

    if (widget.onExport != null) {
      await widget.onExport!(t, csv);
      return;
    }

    final suggestion =
        '${t.title.replaceAll(' ', '-')}-'
        '${DateTime.now().toIso8601String().substring(0, 10)}.csv';

    final location = await getSaveLocation(
      suggestedName: suggestion,
      acceptedTypeGroups: const [
        XTypeGroup(label: 'CSV', extensions: ['csv']),
      ],
    );
    if (location == null || !mounted) return;

    await File(location.path).writeAsBytes(utf8.encode(csv), flush: true);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 560,
        backgroundColor: AppColors.success,
        content: Text('فایل وساتل شو: ${location.path}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = _table;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final k in ReportKind.values) ...[
                          _Tab(
                            label: k.label,
                            selected: _kind == k,
                            onTap: () {
                              setState(() => _kind = k);
                              _load();
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                OutlinedButton.icon(
                  onPressed: t == null || t.isEmpty ? null : _export,
                  icon: const Icon(Icons.table_view_rounded, size: 17),
                  label: const Text('CSV'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: t == null || t.isEmpty ? null : _print,
                  icon: const Icon(Icons.print_rounded, size: 17),
                  label: const Text('چاپ'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modReports,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    textStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildFilters(p),
          const SizedBox(height: 16),

          if (t != null && t.highlights.isNotEmpty) ...[
            Row(
              children: [
                for (final h in t.highlights) ...[
                  Expanded(child: _Highlight(h: h)),
                  const SizedBox(width: 12),
                ],
              ],
            ),
            const SizedBox(height: 16),
          ],

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : t == null || t.isEmpty
                ? _empty(p)
                : _buildTable(t, p),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(AppPalette p) {
    final locale = S.of(context).locale;

    return Row(
      children: [
        if (_kind == ReportKind.attendance) ...[
          _Picker<SectionOption?>(
            icon: Icons.meeting_room_rounded,
            color: AppColors.modClasses,
            label: _section?.label ?? 'ټول ښوونځی',
            items: [null, ..._sections],
            labelOf: (s) => s?.label ?? 'ټول ښوونځی',
            onPicked: (s) {
              setState(() => _section = s);
              _load();
            },
          ),
          const SizedBox(width: 10),
          _MonthPicker(
            month: _month,
            onChanged: (m) {
              setState(() => _month = m);
              _load();
            },
          ),
        ],
        if (_kind == ReportKind.fees)
          _Picker<String?>(
            icon: Icons.calendar_month_rounded,
            color: AppColors.modFees,
            label: _period == null ? 'ټولې دورې' : locale.num(_period!),
            items: [null, ..._periods],
            labelOf: (v) => v == null ? 'ټولې دورې' : locale.num(v),
            onPicked: (v) {
              setState(() => _period = v);
              _load();
            },
          ),
        if (_kind == ReportKind.exam)
          _Picker<ExamRow>(
            icon: Icons.assignment_rounded,
            color: AppColors.modExams,
            label: _exam?.exam.name ?? 'ازموینه',
            items: _exams,
            labelOf: (e) => e.exam.name,
            onPicked: (e) {
              setState(() => _exam = e);
              _load();
            },
          ),
        const Spacer(),
        if (_table != null)
          Text(
            locale.num(_table!.subtitle),
            style: TextStyle(fontSize: 12.5, color: p.muted),
          ),
      ],
    );
  }

  Widget _empty(AppPalette p) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(19),
          ),
          child: Icon(Icons.insights_rounded, size: 28, color: p.faint),
        ),
        const SizedBox(height: 16),
        Text(
          'دې رپوټ ته هېڅ معلومات نشته',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: p.inkSoft,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'لومړی هغه برخه ډکه کړئ چې رپوټ يې غواړي.',
          style: TextStyle(fontSize: 12.5, color: p.muted),
        ),
      ],
    ),
  );

  Widget _buildTable(ReportTable t, AppPalette p) {
    final locale = S.of(context).locale;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // سرلیک.
          Container(
            color: p.surfaceAlt,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                for (final (i, c) in t.columns.indexed)
                  Expanded(
                    flex: i == 0 ? 3 : 1,
                    child: Text(
                      c,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: p.muted,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: t.rows.length,
              itemBuilder: (context, r) => Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: r.isOdd ? p.surfaceAlt.withValues(alpha: 0.5) : null,
                  border: Border(top: BorderSide(color: p.line)),
                ),
                child: Row(
                  children: [
                    for (final (i, c) in t.rows[r].indexed)
                      Expanded(
                        flex: i == 0 ? 3 : 1,
                        child: Text(
                          locale.num(c),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: i == 0
                              ? TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink,
                                )
                              : AppTheme.tabular(
                                  TextStyle(fontSize: 12.5, color: p.inkSoft),
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (t.totals.isNotEmpty)
            Container(
              color: p.surfaceAlt,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              child: Row(
                children: [
                  for (final (i, c) in t.totals.indexed)
                    Expanded(
                      flex: i == 0 ? 3 : 1,
                      child: Text(
                        locale.num(c),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.tabular(
                          TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: p.ink,
                          ),
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
}

// ═══════════════════════════════════════════════════════════

class _Highlight extends StatelessWidget {
  final ({String label, String value, bool warn}) h;
  const _Highlight({required this.h});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final color = h.warn ? AppColors.warning : AppColors.modReports;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: h.warn ? color.withValues(alpha: 0.4) : p.line,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              h.warn
                  ? Icons.warning_amber_rounded
                  : Icons.insights_rounded,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  locale.num(h.value),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: h.warn ? color : p.ink,
                    ),
                  ),
                ),
                Text(
                  h.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthPicker extends StatelessWidget {
  final DateTime month;
  final ValueChanged<DateTime> onChanged;

  const _MonthPicker({required this.month, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            onPressed: () =>
                onChanged(DateTime(month.year, month.month - 1, 1)),
            icon: Icon(Icons.chevron_right_rounded, color: p.muted),
          ),
          const SizedBox(width: 4),
          Text(
            locale.num(
              '${month.year}/${month.month.toString().padLeft(2, '0')}',
            ),
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            iconSize: 18,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
            onPressed: () =>
                onChanged(DateTime(month.year, month.month + 1, 1)),
            icon: Icon(Icons.chevron_left_rounded, color: p.muted),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modReports.withValues(alpha: 0.11)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: selected ? AppColors.modReports : p.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modReports : p.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _Picker<T> extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;

  const _Picker({
    required this.icon,
    required this.color,
    required this.label,
    required this.items,
    required this.labelOf,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<T>(
      tooltip: '',
      onSelected: onPicked,
      itemBuilder: (_) => [
        for (final i in items)
          PopupMenuItem(
            value: i,
            child: Text(labelOf(i), style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
            const SizedBox(width: 7),
            Icon(Icons.expand_more_rounded, size: 16, color: p.muted),
          ],
        ),
      ),
    );
  }
}
