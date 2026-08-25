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

/// **د پایلو پاڼه — دوه بېلې پوښتنې، یو جدول.**
///
///  * «د دوهم ټولګي ټول مضامین» → هر شاګرد یوه کرښه، هر مضمون یوه
///    ستنه. دا کارنامه ده.
///  * «د ریاضي نمرې په ټولو ټولګیو کې» → هر شاګرد یوه کرښه، یوه
///    نمره، او د ټولګي ستنه. دا د یوه مضمون کتنه ده.
///
/// جدول پخپله اوړي — کارن یوازې فلټر بدلوي.
class ResultsPage extends StatefulWidget {
  final Exam exam;
  final ExamRepository exams;
  final AcademicRepository academic;
  final VoidCallback onBack;
  final VoidCallback? onTopStudents;
  final void Function(String csv, String name)? onExport;

  const ResultsPage({
    super.key,
    required this.exam,
    required this.exams,
    required this.academic,
    required this.onBack,
    this.onTopStudents,
    this.onExport,
  });

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Grade> _grades = const [];
  List<Subject> _subjects = const [];
  List<ResultRow> _rows = const [];
  bool _madrasa = false;
  bool _loading = true;

  late ResultFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = const ResultFilter();
    _boot();
  }

  Future<void> _boot() async {
    final grades = await widget.academic.grades();
    final madrasa = await widget.academic.isMadrasa();
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _madrasa = madrasa;
      // **تلواله: لومړی ټولګی، ټول مضامین.** دا هغه پوښتنه ده چې
      // مدیر ۹۰٪ وخت کوي — «د دې ټولګي کارنامه راوښیه».
      _filter = ResultFilter(gradeId: grades.firstOrNull?.id);
    });
    await _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final subjects = await widget.academic.subjects(gradeId: _filter.gradeId);
    if (!mounted) return;
    setState(() => _subjects = subjects);
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final rows = await widget.exams.results(
      examId: widget.exam.id,
      filter: _filter,
    );
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _loading = false;
    });
  }

  /// د جدول ستنې — د فلټر له مخې.
  List<String> get _subjectColumns {
    if (_filter.subjectId != null) {
      return _rows.isEmpty ? const [] : [_rows.first.subjects.first.subjectName];
    }
    // ټول مضامین: د لومړي شاګرد ترتیب کافي دی، ځکه چې د یوه ټولګي
    // ټول شاګردان هماغه مضامین لري.
    return _rows.isEmpty
        ? const []
        : _rows.first.subjects.map((s) => s.subjectName).toList();
  }

  void _exportCsv() {
    final cols = _subjectColumns;
    final csv = Csv.build(
      columns: [
        'درجه',
        'د داخلې نمبر',
        'نوم',
        'د پلار نوم',
        'ټولګی',
        ...cols,
        'مجموعه',
        'سلنه',
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
            for (final name in cols)
              () {
                final sub = r.subjects
                    .where((s) => s.subjectName == name)
                    .firstOrNull;
                if (sub == null) return '';
                return sub.isAbsent
                    ? 'غ'
                    : (sub.obtained?.toString() ?? '');
              }(),
            r.obtained.toString(),
            '${r.percent.toStringAsFixed(1)}%',
            r.passedAll ? 'کامیاب' : 'ناکام',
          ],
      ],
    );
    widget.onExport?.call(csv, '${widget.exam.name}-پایلې.csv');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        content: Text(
          '${S.of(context).locale.num(_rows.length)} کرښې اکسپورټ شوې.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final cols = _subjectColumns;

    final passed = _rows.where((r) => r.passedAll).length;

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
                    widget.exam.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    s.results,
                    style: TextStyle(fontSize: 12, color: p.muted),
                  ),
                ],
              ),
              const Spacer(),
              if (_rows.isNotEmpty) ...[
                Pill(
                  color: AppColors.success,
                  text: '${s.passed}: ${locale.num(passed)}',
                ),
                const SizedBox(width: 6),
                Pill(
                  color: AppColors.danger,
                  text: '${s.failed}: ${locale.num(_rows.length - passed)}',
                ),
                const SizedBox(width: 12),
              ],
              if (widget.onTopStudents != null)
                OutlinedButton.icon(
                  onPressed: widget.onTopStudents,
                  icon: const Icon(Icons.emoji_events_rounded, size: 16),
                  label: Text(s.topStudents),
                ),
            ],
          ),
        ),

        ExamFilterBar(
          grades: _grades,
          subjects: _subjects,
          filter: _filter,
          madrasa: _madrasa,
          allowAll: true,
          showSortAndOutcome: true,
          trailing: [ExportButton(onCsv: _exportCsv)],
          onChanged: (f) {
            final gradeChanged = f.gradeId != _filter.gradeId;
            setState(() => _filter = f);
            if (gradeChanged) {
              _loadSubjects();
            } else {
              _load();
            }
          },
        ),

        // د اوسني فلټر یوه کرښه توضیح — کارن باید پوه شي څه ګوري.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          color: p.surfaceAlt,
          child: Text(
            _filter.subjectId == null
                ? 'د یوه ټولګي ټول مضامین — کارنامه.'
                : (_filter.gradeId == null
                      ? 'یو مضمون په ټولو ټولګیو کې — د مضمون کتنه.'
                      : 'یو ټولګی، یو مضمون.'),
            style: TextStyle(fontSize: 11.5, color: p.muted),
          ),
        ),

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _rows.isEmpty
              ? const EmptyState(
                  icon: Icons.assignment_rounded,
                  text: 'د دې فلټر سره هېڅ پایله نشته.',
                  hint: 'ښايي نمرې لا نه وي ثبت شوې.',
                )
              : Scrollbar(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _tableWidth(cols.length),
                      child: Column(
                        children: [
                          _Head(
                            columns: cols,
                            showClass: _filter.gradeId == null,
                          ),
                          Divider(height: 1, color: p.line),
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              itemCount: _rows.length,
                              itemBuilder: (context, i) => _Row(
                                row: _rows[i],
                                columns: cols,
                                showClass: _filter.gradeId == null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  /// د ستنو له مخې پلن‌والی — که ډېر مضامین وي، جدول پلن کېږي او
  /// افقي سکرول راځي، نه دا چې نومونه سره ولګېږي.
  double _tableWidth(int subjectCount) {
    // **د کرښې پلن‌والی هم شمېرل کېږي.** پرته له دې، سرلیک به له
    // خپل چوکاټه ۴۸ پکسله بهر ووت — او هغه څو مضامین چې د پولې تر
    // شا وو، بېخي نه لیدل کېدل.
    const padding = 48.0;
    final base =
        padding +
        _kRank +
        _kName +
        _kAdmission +
        (_filter.gradeId == null ? _kClass : 0) +
        _kTail;
    final w = base + subjectCount * _kSubject;
    final screen = MediaQuery.of(context).size.width - 300;
    return w < screen ? screen : w;
  }
}

const double _kRank = 48;
const double _kName = 220;
const double _kAdmission = 110;
const double _kClass = 130;
const double _kSubject = 92;
const double _kTail = 200;

class _Head extends StatelessWidget {
  final List<String> columns;
  final bool showClass;

  const _Head({required this.columns, required this.showClass});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = TextStyle(
      fontSize: 10.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
      color: p.faint,
    );

    return Container(
      color: p.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
      child: Row(
        children: [
          SizedBox(width: _kRank, child: Text('#', style: style)),
          SizedBox(width: _kName, child: Text('نوم', style: style)),
          SizedBox(
            width: _kAdmission,
            child: Text('د داخلې نمبر', style: style),
          ),
          if (showClass)
            SizedBox(width: _kClass, child: Text('ټولګی', style: style)),
          for (final c in columns)
            SizedBox(
              width: _kSubject,
              child: Text(
                c,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: style,
              ),
            ),
          SizedBox(
            width: _kTail,
            child: Text('مجموعه · سلنه · پایله', style: style),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatefulWidget {
  final ResultRow row;
  final List<String> columns;
  final bool showClass;

  const _Row({
    required this.row,
    required this.columns,
    required this.showClass,
  });

  @override
  State<_Row> createState() => _RowState();
}

class _RowState extends State<_Row> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
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
              width: _kRank,
              child: _RankChip(rank: r.rank, locale: locale),
            ),
            SizedBox(
              width: _kName,
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
            SizedBox(
              width: _kAdmission,
              child: Text(
                locale.num(r.student.admissionNo),
                style: AppTheme.tabular(
                  TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ),
            ),
            if (widget.showClass)
              SizedBox(
                width: _kClass,
                child: Text(
                  r.className,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
              ),
            for (final name in widget.columns)
              SizedBox(
                width: _kSubject,
                child: _MarkCell(
                  sub: r.subjects.where((s) => s.subjectName == name).firstOrNull,
                  locale: locale,
                ),
              ),
            SizedBox(
              width: _kTail,
              child: Row(
                children: [
                  Text(
                    '${locale.num(r.obtained.round())}/${locale.num(r.full)}',
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: p.inkSoft,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${locale.num(r.percent.round())}٪',
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: markColor(r.percent),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Pill(
                    color: r.passedAll ? AppColors.success : AppColors.danger,
                    text: r.passedAll ? r.band.label : 'ناکام',
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

class _MarkCell extends StatelessWidget {
  final SubjectResult? sub;
  final AppLocale locale;

  const _MarkCell({required this.sub, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = sub;

    if (s == null) {
      return Text(
        '—',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12, color: p.faint),
      );
    }
    if (s.isAbsent) {
      return const Text(
        'غ',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.warning,
        ),
      );
    }
    if (s.obtained == null) {
      return Text(
        '·',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 14, color: p.faint),
      );
    }

    return Text(
      locale.num(
        s.obtained! == s.obtained!.roundToDouble()
            ? s.obtained!.round().toString()
            : s.obtained!.toStringAsFixed(1),
      ),
      textAlign: TextAlign.center,
      style: AppTheme.tabular(
        TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          // ناکامه نمره سره ده — نه یوازې د سلنې له مخې، بلکې د
          // همدې مضمون د کامیابۍ حد له مخې.
          color: s.passed ? markColor(s.percent) : AppColors.danger,
        ),
      ),
    );
  }
}

/// لومړی درې ځایونه رنګ لري — پاتې خړ.
class _RankChip extends StatelessWidget {
  final int rank;
  final AppLocale locale;

  const _RankChip({required this.rank, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = switch (rank) {
      1 => const Color(0xFFD4A017),
      2 => const Color(0xFF9AA0B4),
      3 => const Color(0xFFB87333),
      _ => null,
    };

    if (color == null) {
      return Text(
        locale.num(rank),
        style: AppTheme.tabular(TextStyle(fontSize: 11.5, color: p.faint)),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        locale.num(rank),
        style: AppTheme.tabular(
          TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
        ),
      ),
    );
  }
}
