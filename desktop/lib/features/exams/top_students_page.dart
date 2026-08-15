import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/csv.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/exam_repository.dart';
import 'exam_filters.dart';

/// **ممتاز شاګردان — پنځه د ښوونځي، درې د هر ټولګي.**
///
/// **ولې دوه کچې؟** ځکه چې دوه بېل مراسم دي. د کال په پای کې د ټول
/// ښوونځي لومړي پنځه کسان جایزه اخلي — هغه یو لیست دی. خو هر استاد
/// د خپل ټولګي لومړي درې غواړي، ځکه چې د ټول ښوونځي لیست کې ښايي د
/// هغه له ټولګي هېڅوک نه وي.
class TopStudentsPage extends StatefulWidget {
  final Exam exam;
  final ExamRepository exams;
  final AcademicRepository academic;
  final VoidCallback onBack;
  final void Function(String csv, String name)? onExport;

  /// څو کسان — د ښوونځي په کچه او د ټولګي په کچه.
  final int overallLimit;
  final int perGradeLimit;

  const TopStudentsPage({
    super.key,
    required this.exam,
    required this.exams,
    required this.academic,
    required this.onBack,
    this.onExport,
    this.overallLimit = 5,
    this.perGradeLimit = 3,
  });

  @override
  State<TopStudentsPage> createState() => _TopStudentsPageState();
}

class _TopStudentsPageState extends State<TopStudentsPage> {
  List<TopStudent> _overall = const [];
  Map<int, List<TopStudent>> _perGrade = const {};
  List<Grade> _grades = const [];
  bool _madrasa = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final grades = await widget.academic.grades();
    final madrasa = await widget.academic.isMadrasa();
    final overall = await widget.exams.topOverall(
      examId: widget.exam.id,
      limit: widget.overallLimit,
    );
    final perGrade = await widget.exams.topPerGrade(
      examId: widget.exam.id,
      limit: widget.perGradeLimit,
    );
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _madrasa = madrasa;
      _overall = overall;
      _perGrade = perGrade;
      _loading = false;
    });
  }

  String _gradeName(int id) =>
      _grades.where((g) => g.id == id).firstOrNull?.name ?? '—';

  void _exportCsv() {
    final rows = <List<String>>[
      for (final t in _overall)
        [
          'ټول ښوونځی',
          t.position.toString(),
          t.student.admissionNo,
          t.fullName,
          t.student.fatherName,
          t.className,
          t.obtained.toStringAsFixed(1),
          t.full.toString(),
          '${t.percent.toStringAsFixed(1)}%',
        ],
      for (final e in _perGrade.entries)
        for (final t in e.value)
          [
            _gradeName(e.key),
            t.position.toString(),
            t.student.admissionNo,
            t.fullName,
            t.student.fatherName,
            t.className,
            t.obtained.toStringAsFixed(1),
            t.full.toString(),
            '${t.percent.toStringAsFixed(1)}%',
          ],
    ];

    widget.onExport?.call(
      Csv.build(
        columns: const [
          'کچه',
          'ځای',
          'د داخلې نمبر',
          'نوم',
          'د پلار نوم',
          'ټولګی',
          'ترلاسه',
          'مجموعه',
          'سلنه',
        ],
        rows: rows,
      ),
      '${widget.exam.name}-ممتازین.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    if (_loading) return const Center(child: CircularProgressIndicator());

    final hasAny = _overall.isNotEmpty;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 24, 14),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'بېرته',
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_forward_rounded, size: 19),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.topStudents,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    widget.exam.name,
                    style: TextStyle(fontSize: 12, color: p.muted),
                  ),
                ],
              ),
              const Spacer(),
              ExportButton(onCsv: hasAny ? _exportCsv : null),
            ],
          ),
        ),

        Expanded(
          child: !hasAny
              ? const EmptyState(
                  icon: Icons.emoji_events_rounded,
                  text: 'لا هېڅ نمره نه ده ثبت شوې.',
                  hint: 'کله چې نمرې ثبت شي، ممتازین پخپله راښکاره کېږي.',
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 30),
                  children: [
                    // ── د ښوونځي په کچه ───────────────────────
                    FadeSlideIn(
                      child: Panel(
                        title: 'د ټول ${_madrasa ? 'مدرسې' : 'ښوونځي'} ممتازین',
                        subtitle:
                            'لومړي ${locale.num(widget.overallLimit)} کسان — '
                            'د سلنې له مخې، نه د خامو نمرو.',
                        icon: Icons.emoji_events_rounded,
                        color: const Color(0xFFD4A017),
                        child: Column(
                          children: [
                            for (var i = 0; i < _overall.length; i++)
                              _TopRow(
                                top: _overall[i],
                                locale: locale,
                                big: true,
                                showClass: true,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    Text(
                      _madrasa ? 'د هرې درجې ممتازین' : 'د هر ټولګي ممتازین',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── د هر ټولګي په کچه ─────────────────────
                    LayoutBuilder(
                      builder: (context, c) {
                        final perRow = c.maxWidth < 900
                            ? 1
                            : (c.maxWidth < 1300 ? 2 : 3);
                        const gap = 14.0;
                        final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
                        final entries = _perGrade.entries.toList()
                          ..sort((a, b) => _order(a.key).compareTo(_order(b.key)));

                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: [
                            for (var i = 0; i < entries.length; i++)
                              SizedBox(
                                width: w,
                                child: FadeSlideIn.staggered(
                                  index: i,
                                  child: Panel(
                                    title: _gradeName(entries[i].key),
                                    icon: Icons.workspace_premium_rounded,
                                    color: AppColors.modExams,
                                    child: Column(
                                      children: [
                                        for (final t in entries[i].value)
                                          _TopRow(
                                            top: t,
                                            locale: locale,
                                            big: false,
                                            showClass: false,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  int _order(int gradeId) {
    final g = _grades.where((x) => x.id == gradeId).firstOrNull;
    return g == null ? 9999 : g.sortOrder * 1000 + g.level;
  }
}

class _TopRow extends StatelessWidget {
  final TopStudent top;
  final AppLocale locale;
  final bool big;
  final bool showClass;

  const _TopRow({
    required this.top,
    required this.locale,
    required this.big,
    required this.showClass,
  });

  /// سرو زرو، سپینو زرو، مسو — بیا خړ.
  static const _medals = [
    Color(0xFFD4A017),
    Color(0xFF9AA0B4),
    Color(0xFFB87333),
  ];

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = top.position <= 3 ? _medals[top.position - 1] : p.faint;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: big ? 7 : 5),
      child: Row(
        children: [
          Container(
            width: big ? 34 : 26,
            height: big ? 34 : 26,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            alignment: Alignment.center,
            child: Text(
              locale.num(top.position),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: big ? 13 : 11,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: big ? 13 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  top.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: big ? 14 : 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                Text(
                  showClass
                      ? '${top.className}  ·  ولد ${top.student.fatherName}'
                      : 'ولد ${top.student.fatherName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: p.faint),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${locale.num(top.percent.round())}٪',
                style: AppTheme.tabular(
                  TextStyle(
                    fontSize: big ? 15 : 13,
                    fontWeight: FontWeight.w800,
                    color: markColor(top.percent),
                  ),
                ),
              ),
              Text(
                '${locale.num(top.obtained.round())} / ${locale.num(top.full)}',
                style: AppTheme.tabular(
                  TextStyle(fontSize: 10.5, color: p.faint),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
