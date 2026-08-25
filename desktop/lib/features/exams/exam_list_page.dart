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
import '../../data/repositories/exam_repository.dart';

/// **د ازموینو کوره پاڼه — یو لیست، دوه لارې.**
///
/// د پخوانۍ پاڼې ستونزه دا وه چې د نمرو ثبت، د پایلو کتنه او د
/// ازموینې جوړول ټول یوه پاڼه کې ګډ وو. دلته لیست یوازې دوه شیان
/// وايي: «څومره بشپړه شوې» او «څه کول غواړې؟»
class ExamListPage extends StatefulWidget {
  final ExamRepository exams;
  final AcademicRepository academic;

  final ValueChanged<Exam> onEnterMarks;
  final ValueChanged<Exam> onResults;
  final ValueChanged<Exam>? onTopStudents;
  final VoidCallback? onCombined;
  final VoidCallback? onSettings;

  const ExamListPage({
    super.key,
    required this.exams,
    required this.academic,
    required this.onEnterMarks,
    required this.onResults,
    this.onTopStudents,
    this.onCombined,
    this.onSettings,
  });

  @override
  State<ExamListPage> createState() => _ExamListPageState();
}

class _ExamListPageState extends State<ExamListPage> {
  List<ExamRow> _rows = const [];
  bool _madrasa = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rows = await widget.exams.list();
    final madrasa = await widget.academic.isMadrasa();
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _madrasa = madrasa;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: Row(
            children: [
              Text(
                s.exams,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'پر یوه ازموینه کېکاږئ چې نمرې ولیکئ، یا «${s.results}» ووهئ.',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ),
              if (widget.onCombined != null && _rows.length > 1) ...[
                OutlinedButton.icon(
                  onPressed: widget.onCombined,
                  icon: const Icon(Icons.calculate_rounded, size: 16),
                  label: Text(s.combinedResults),
                ),
                const SizedBox(width: 8),
              ],
              if (widget.onSettings != null)
                FilledButton.icon(
                  onPressed: widget.onSettings,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('نوې ازموینه'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modExams,
                  ),
                ),
            ],
          ),
        ),

        Expanded(
          child: _rows.isEmpty
              ? EmptyState(
                  icon: Icons.assignment_rounded,
                  text: 'لا هېڅ ازموینه نه ده جوړه شوې.',
                  hint: 'له «${s.examSettings}» څخه يې جوړه کړئ.',
                  action: widget.onSettings == null
                      ? null
                      : FilledButton.icon(
                          onPressed: widget.onSettings,
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: const Text('نوې ازموینه'),
                        ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  itemCount: _rows.length,
                  itemBuilder: (context, i) => FadeSlideIn.staggered(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ExamCard(
                        row: _rows[i],
                        locale: locale,
                        madrasa: _madrasa,
                        onEnterMarks: () => widget.onEnterMarks(_rows[i].exam),
                        onResults: () => widget.onResults(_rows[i].exam),
                        onTop: widget.onTopStudents == null
                            ? null
                            : () => widget.onTopStudents!(_rows[i].exam),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _ExamCard extends StatefulWidget {
  final ExamRow row;
  final AppLocale locale;
  final bool madrasa;
  final VoidCallback onEnterMarks;
  final VoidCallback onResults;
  final VoidCallback? onTop;

  const _ExamCard({
    required this.row,
    required this.locale,
    required this.madrasa,
    required this.onEnterMarks,
    required this.onResults,
    this.onTop,
  });

  @override
  State<_ExamCard> createState() => _ExamCardState();
}

class _ExamCardState extends State<_ExamCard> {
  bool _hover = false;

  static String typeLabel(String t) => switch (t) {
    'monthly' => 'میاشتنۍ',
    'midterm' => 'څلورنیم‌میاشتنۍ',
    'final' => 'کلنۍ',
    'quiz' => 'کوچنۍ',
    _ => t,
  };

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final locale = widget.locale;
    final e = widget.row.exam;
    final r = widget.row;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onEnterMarks,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: _hover
                  ? AppColors.modExams.withValues(alpha: 0.5)
                  : p.line,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.modExams.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.assignment_rounded,
                      size: 19,
                      color: AppColors.modExams,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              e.name,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: p.ink,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Pill(
                              color: AppColors.modExams,
                              text: typeLabel(e.examType),
                            ),
                            if (e.weightPercent != 100) ...[
                              const SizedBox(width: 6),
                              Pill(
                                color: AppColors.modReports,
                                icon: Icons.percent_rounded,
                                text:
                                    '${s.weight} ${locale.num(e.weightPercent)}',
                              ),
                            ],
                            if (e.isPublished) ...[
                              const SizedBox(width: 6),
                              const Pill(
                                color: AppColors.success,
                                icon: Icons.public_rounded,
                                text: 'خپره شوې',
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          [
                            '${locale.num(r.subjectCount)} مضامین',
                            if (!widget.madrasa) 'ربع ${locale.num(e.term)}',
                            '${locale.num(e.startsOn.year)}/'
                                '${context.cal.dayMonth(e.startsOn)}'
                                ' — '
                                '${locale.num(e.startsOn.day)}',
                          ].join('  ·  '),
                          style: TextStyle(fontSize: 12, color: p.muted),
                        ),
                      ],
                    ),
                  ),
                  // **دوه څرګندې تڼۍ.** د پخوانۍ پاڼې ستونزه دا وه چې
                  // کارن نه پوهېده له کوم ځایه نمرې لیکل کېږي او له
                  // کوم ځایه پایلې لیدل کېږي.
                  FilledButton.icon(
                    onPressed: widget.onEnterMarks,
                    icon: const Icon(Icons.edit_note_rounded, size: 16),
                    label: Text(s.enterMarks),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.modExams,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: widget.onResults,
                    icon: const Icon(Icons.leaderboard_rounded, size: 16),
                    label: Text(s.results),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                    ),
                  ),
                  if (widget.onTop != null) ...[
                    const SizedBox(width: 6),
                    IconButton(
                      tooltip: s.topStudents,
                      onPressed: widget.onTop,
                      icon: const Icon(Icons.emoji_events_rounded, size: 18),
                      color: const Color(0xFFD4A017),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${locale.num(r.markedCount)} له '
                    '${locale.num(r.expectedCount)} نمرو ثبت شوې',
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12, color: p.muted),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${locale.num(r.progress.round())}٪',
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: r.isComplete
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: (r.progress / 100).clamp(0.0, 1.0),
                  ),
                  duration: AppMotion.slow,
                  curve: AppMotion.emphasized,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 5,
                    backgroundColor: p.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(
                      r.isComplete ? AppColors.success : AppColors.modExams,
                    ),
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
