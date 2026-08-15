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

/// **راټولې پایلې — «۴۰ + ۶۰ = ۱۰۰».**
///
/// **دا ولې خپله پاڼه ده؟**
/// ځکه چې د کال وروستۍ نمره یوه ازموینه نه ده — دوه (یا ډېرې) دي.
/// څلورنیم‌میاشتنۍ تر ۴۰ او کلنۍ تر ۶۰. تر دې مخکې، مدیر به دوه
/// پاڼې پرانیستې، دواړه به يې په کاغذ لیکلې او په لاس به يې راټولې
/// کړې — او هره تېروتنه به يې د یوه شاګرد د کال پایله بدله کړه.
///
/// دلته هره ازموینه خپل وزن لري او راټولول پخپله کېږي.
class CombinedResultsPage extends StatefulWidget {
  final ExamRepository exams;
  final AcademicRepository academic;
  final VoidCallback onBack;
  final void Function(String csv, String name)? onExport;

  const CombinedResultsPage({
    super.key,
    required this.exams,
    required this.academic,
    required this.onBack,
    this.onExport,
  });

  @override
  State<CombinedResultsPage> createState() => _CombinedResultsPageState();
}

class _CombinedResultsPageState extends State<CombinedResultsPage> {
  List<ExamRow> _exams = const [];
  List<Grade> _grades = const [];
  List<CombinedResult> _rows = const [];
  bool _madrasa = false;
  bool _loading = true;

  final Set<int> _chosen = {};
  int? _gradeId;
  String _query = '';
  String _sort = 'rank';

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final exams = await widget.exams.list();
    final grades = await widget.academic.grades();
    final madrasa = await widget.academic.isMadrasa();
    if (!mounted) return;

    // **تلواله: هغه ازموینې چې وزن يې له ۱۰۰ کم دی.**
    // دا هغه دي چې د کال د راټولې نمرې برخې دي — یوه ۴۰، بله ۶۰.
    // که هېڅ داسې نه وي، ټولې غوره کوو.
    final weighted = exams.where((e) => e.exam.weightPercent < 100).toList();
    _chosen.addAll(
      (weighted.isEmpty ? exams : weighted).map((e) => e.exam.id),
    );

    setState(() {
      _exams = exams;
      _grades = grades;
      _madrasa = madrasa;
      _gradeId = grades.firstOrNull?.id;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await widget.exams.combined(
      examIds: _chosen.toList(),
      gradeId: _gradeId,
      query: _query,
      sort: _sort,
    );
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  List<Exam> get _chosenExams => [
    for (final e in _exams)
      if (_chosen.contains(e.exam.id)) e.exam,
  ];

  int get _weightSum =>
      _chosenExams.fold(0, (a, e) => a + e.weightPercent);

  void _exportCsv() {
    final exams = _chosenExams;
    widget.onExport?.call(
      Csv.build(
        columns: [
          'درجه',
          'د داخلې نمبر',
          'نوم',
          'د پلار نوم',
          'ټولګی',
          for (final e in exams) '${e.name} (${e.weightPercent}٪)',
          'مجموعه',
          'پایله',
        ],
        rows: [
          for (final r in _rows)
            [
              r.rank.toString(),
              r.student.admissionNo,
              r.fullName,
              r.student.fatherName,
              r.className,
              for (final p in r.parts) p.scaled.toStringAsFixed(1),
              r.total.toStringAsFixed(1),
              r.band.label,
            ],
        ],
      ),
      'راټولې-پایلې.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final exams = _chosenExams;

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
                    s.combinedResults,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    'د هرې ازموینې سلنه پر خپل وزن ضربېږي، بیا راټولېږي.',
                    style: TextStyle(fontSize: 12, color: p.muted),
                  ),
                ],
              ),
              const Spacer(),
              Pill(
                color: _weightSum == 100 ? AppColors.success : AppColors.warning,
                icon: Icons.percent_rounded,
                text: 'د وزنونو مجموعه ${locale.num(_weightSum)}',
              ),
              const SizedBox(width: 12),
              ExportButton(onCsv: _rows.isEmpty ? null : _exportCsv),
            ],
          ),
        ),

        // ── کومې ازموینې راټولېږي ─────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'ازموینې:',
                style: TextStyle(fontSize: 12, color: p.faint),
              ),
              for (final e in _exams)
                FilterChip(
                  label: Text(
                    '${e.exam.name} · ${locale.num(e.exam.weightPercent)}٪',
                    style: const TextStyle(fontSize: 11.5),
                  ),
                  selected: _chosen.contains(e.exam.id),
                  visualDensity: VisualDensity.compact,
                  onSelected: (on) {
                    setState(() {
                      if (on) {
                        _chosen.add(e.exam.id);
                      } else {
                        _chosen.remove(e.exam.id);
                      }
                    });
                    _load();
                  },
                ),
            ],
          ),
        ),

        // ── فلټرونه ───────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<int?>(
                  initialValue: _gradeId,
                  isDense: true,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: _madrasa ? 'درجه' : s.grade,
                    isDense: true,
                  ),
                  items: [
                    DropdownMenuItem(value: null, child: Text(s.all)),
                    for (final g in _grades)
                      DropdownMenuItem(value: g.id, child: Text(g.name)),
                  ],
                  onChanged: (v) {
                    setState(() => _gradeId = v);
                    _load();
                  },
                ),
              ),
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
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                  ),
                ),
              ),
              SegmentedChoice<String>(
                value: _sort,
                color: AppColors.modExams,
                options: [
                  (value: 'rank', label: s.sortByMarks, icon: null),
                  (value: 'name', label: s.sortByName, icon: null),
                ],
                onChanged: (v) {
                  setState(() => _sort = v);
                  _load();
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : exams.isEmpty
              ? const EmptyState(
                  icon: Icons.calculate_rounded,
                  text: 'لږ تر لږه یوه ازموینه وټاکئ.',
                )
              : _rows.isEmpty
              ? const EmptyState(
                  icon: Icons.calculate_rounded,
                  text: 'هېڅ پایله ونه موندل شوه.',
                )
              : Column(
                  children: [
                    _Head(exams: exams, locale: locale),
                    Divider(height: 1, color: p.line),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 24),
                        itemCount: _rows.length,
                        itemBuilder: (context, i) =>
                            _Row(row: _rows[i], locale: locale),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  final List<Exam> exams;
  final AppLocale locale;

  const _Head({required this.exams, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      color: p.faint,
    );

    return Container(
      color: p.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Row(
        children: [
          SizedBox(width: 48, child: Text('#', style: style)),
          Expanded(flex: 3, child: Text('نوم', style: style)),
          Expanded(flex: 2, child: Text('ټولګی', style: style)),
          for (final e in exams)
            SizedBox(
              width: 120,
              child: Text(
                '${e.name}\n(${locale.num(e.weightPercent)}٪)',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          SizedBox(
            width: 170,
            child: Text('د کال نمره', textAlign: TextAlign.end, style: style),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  final CombinedResult row;
  final AppLocale locale;

  const _Row({required this.row, required this.locale});

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = widget.locale;
    final r = widget.row;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        color: _hover ? p.surfaceAlt : Colors.transparent,
        padding: const EdgeInsets.fromLTRB(24, 9, 24, 9),
        child: Row(
          children: [
            SizedBox(
              width: 48,
              child: Text(
                locale.num(r.rank),
                style: AppTheme.tabular(
                  TextStyle(
                    fontSize: 12,
                    fontWeight: r.rank <= 3 ? FontWeight.w800 : FontWeight.w400,
                    color: r.rank <= 3 ? AppColors.modExams : p.faint,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    r.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    'ولد ${r.student.fatherName}',
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
                r.className,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
            ),
            for (final part in r.parts)
              SizedBox(
                width: 120,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      part.hasMarks
                          ? locale.num(part.scaled.toStringAsFixed(1))
                          : '—',
                      textAlign: TextAlign.center,
                      style: AppTheme.tabular(
                        TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: part.hasMarks
                              ? markColor(part.percent)
                              : p.faint,
                        ),
                      ),
                    ),
                    if (part.hasMarks)
                      Text(
                        'له ${locale.num(part.exam.weightPercent)}',
                        style: TextStyle(fontSize: 9.5, color: p.faint),
                      ),
                  ],
                ),
              ),
            SizedBox(
              width: 170,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // **نیمګړې مجموعه څرګنده ده.** که یوه ازموینه لا
                  // نمرې نه لري، «۳۸» به د «ناکام» په څېر ښکارېده —
                  // حال دا چې لا نیمه لار پاتې ده.
                  if (r.isPartial)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Tooltip(
                        message: 'یوه یا څو ازموینې لا نمرې نه لري',
                        child: Icon(
                          Icons.hourglass_bottom_rounded,
                          size: 14,
                          color: p.faint,
                        ),
                      ),
                    ),
                  Text(
                    locale.num(r.total.toStringAsFixed(1)),
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: r.isPartial ? p.muted : markColor(r.total),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Pill(
                    color: r.isPartial
                        ? p.faint
                        : (r.total >= 40 ? AppColors.success : AppColors.danger),
                    text: r.isPartial ? 'نیمګړې' : r.band.label,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
