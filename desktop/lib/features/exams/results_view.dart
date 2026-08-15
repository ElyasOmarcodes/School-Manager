import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/exam_repository.dart';
import '../../widgets/data_table_view.dart';
import 'report_card.dart';

/// د پایلو پرده — د ټولګي درجه‌بندي او د مضمونونو انځور.
class ResultsView extends StatefulWidget {
  final ExamRepository exams;
  final Exam exam;
  final List<SectionOption> sections;
  final String schoolName;
  final VoidCallback onBack;

  /// د ازموینې لپاره — چاپ نه کوو.
  final Future<void> Function(List<StudentResult>)? onPrint;

  const ResultsView({
    super.key,
    required this.exams,
    required this.exam,
    required this.sections,
    required this.schoolName,
    required this.onBack,
    this.onPrint,
  });

  @override
  State<ResultsView> createState() => _ResultsViewState();
}

class _ResultsViewState extends State<ResultsView> {
  SectionOption? _section;
  List<StudentResult> _results = const [];
  List<SubjectStats> _stats = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _section = widget.sections.isEmpty ? null : widget.sections.first;
    _load();
  }

  Future<void> _load() async {
    final s = _section;
    if (s == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);

    final results = await widget.exams.sectionResults(
      examId: widget.exam.id,
      sectionId: s.sectionId,
    );
    final stats = await widget.exams.subjectStats(
      examId: widget.exam.id,
      sectionId: s.sectionId,
    );

    if (!mounted) return;
    setState(() {
      _results = results;
      _stats = stats;
      _loading = false;
    });
  }

  Future<void> _print() async {
    if (_results.isEmpty) return;
    if (widget.onPrint != null) {
      await widget.onPrint!(_results);
      return;
    }
    await printReportCards(
      results: _results,
      exam: widget.exam,
      schoolName: widget.schoolName,
      className: _section?.label ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    final passed = _results.where((r) => r.passedAll).length;
    final average = _results.isEmpty
        ? 0.0
        : _results.map((r) => r.percent).reduce((a, b) => a + b) /
              _results.length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  tooltip: 'بېرته',
                ),
                const SizedBox(width: 6),
                Text(
                  widget.exam.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const SizedBox(width: 14),
                _SectionChip(
                  sections: widget.sections,
                  selected: _section,
                  onPicked: (s) {
                    setState(() => _section = s);
                    _load();
                  },
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _results.isEmpty ? null : _print,
                  icon: const Icon(Icons.print_rounded, size: 17),
                  label: const Text('کارنامې چاپ کړه'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // لنډیز.
          Row(
            children: [
              _Stat(
                label: 'شاګردان',
                value: locale.num(_results.length),
                color: AppColors.modStudents,
                icon: Icons.groups_rounded,
              ),
              const SizedBox(width: 12),
              _Stat(
                label: 'کامیاب',
                value: locale.num(passed),
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
              ),
              const SizedBox(width: 12),
              _Stat(
                label: 'ناکام',
                value: locale.num(_results.length - passed),
                color: AppColors.danger,
                icon: Icons.cancel_rounded,
              ),
              const SizedBox(width: 12),
              _Stat(
                label: 'د ټولګي اوسط',
                value: '٪${locale.num(average.round())}',
                color: AppColors.modExams,
                icon: Icons.insights_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildTable()),
                const SizedBox(width: 18),
                SizedBox(width: 320, child: _buildSubjectStats()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable() {
    final p = context.palette;
    final locale = S.of(context).locale;

    return DataTableView<StudentResult>(
      loading: _loading,
      rows: _results,
      emptyIcon: Icons.assignment_rounded,
      emptyTitle: 'لا هېڅ نمره نه ده لیکل شوې',
      emptyHint: 'د «نمرې» له برخې څخه يې ولیکئ.',
      columns: [
        TableColumn(
          title: 'درجه',
          width: 66,
          cell: (context, r) => _RankBadge(rank: r.rank),
        ),
        TableColumn(
          title: 'شاګرد',
          flex: 3,
          cell: (context, r) => Row(
            children: [
              AvatarCell(
                name: r.student.firstName,
                color: AppColors.modExams,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      [
                        r.student.firstName,
                        if (r.student.lastName?.isNotEmpty ?? false)
                          r.student.lastName,
                      ].join(' '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      locale.num(r.student.admissionNo),
                      style: AppTheme.tabular(
                        TextStyle(fontSize: 11, color: p.faint),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableColumn(
          title: 'مجموعه',
          width: 118,
          cell: (context, r) => Text(
            '${locale.num(_fmt(r.obtainedTotal))} / '
            '${locale.num(r.fullTotal)}',
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
          ),
        ),
        TableColumn(
          title: 'سلنه',
          width: 82,
          cell: (context, r) => Text(
            '٪${locale.num(r.percent.round())}',
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: r.passedAll ? AppColors.success : AppColors.danger,
              ),
            ),
          ),
        ),
        TableColumn(
          title: 'پایله',
          width: 138,
          cell: (context, r) => StatusChip(
            label: r.passedAll
                ? r.band.label
                : '${locale.num(r.failed.length)} مضمون ناکام',
            color: r.passedAll
                ? (r.percent >= 80 ? AppColors.success : AppColors.modAttendance)
                : AppColors.danger,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectStats() {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'د مضمونونو انځور',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'کوم مضمون ټولګی ستړی کوي؟ هغه چې د پاس سلنه يې ټیټه ده.',
            style: TextStyle(fontSize: 11.5, height: 1.7, color: p.muted),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _stats.isEmpty
                ? Center(
                    child: Text(
                      '—',
                      style: TextStyle(fontSize: 13, color: p.faint),
                    ),
                  )
                : ListView.separated(
                    itemCount: _stats.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final s = _stats[i];
                      final ratio = s.passPercent / 100;
                      final color = s.passPercent >= 80
                          ? AppColors.success
                          : s.passPercent >= 50
                          ? AppColors.warning
                          : AppColors.danger;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  s.subjectName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: p.ink,
                                  ),
                                ),
                              ),
                              Text(
                                'اوسط ${locale.num(s.average.round())}',
                                style: AppTheme.tabular(
                                  TextStyle(fontSize: 11.5, color: p.muted),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: ratio),
                              duration: AppMotion.counter,
                              curve: AppMotion.standard,
                              builder: (_, v, __) => LinearProgressIndicator(
                                value: v,
                                minHeight: 6,
                                backgroundColor: p.surfaceAlt,
                                valueColor: AlwaysStoppedAnimation(color),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${locale.num(s.passed)} کامیاب  •  '
                            '${locale.num(s.failed)} ناکام'
                            '${s.absent == 0 ? '' : '  •  '
                                '${locale.num(s.absent)} غیرحاضر'}',
                            style: TextStyle(fontSize: 11, color: p.faint),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}

// ═══════════════════════════════════════════════════════════

class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    // لومړي درې طلایي/سپین‌زر/مسي — نور ساده.
    final color = switch (rank) {
      1 => AppColors.accent,
      2 => AppColors.modReports,
      3 => AppColors.modIdCards,
      _ => null,
    };

    return Container(
      width: 34,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: (color ?? p.surfaceAlt).withValues(
          alpha: color == null ? 1 : 0.15,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        locale.num(rank),
        style: AppTheme.tabular(
          TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: color ?? p.muted,
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: p.line),
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
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value,
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final List<SectionOption> sections;
  final SectionOption? selected;
  final ValueChanged<SectionOption> onPicked;

  const _SectionChip({
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
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.modClasses.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selected?.label ?? 'ټولګی',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.modClasses,
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
