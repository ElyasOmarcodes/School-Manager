import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/exam_repository.dart';
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';
import 'mark_sheet.dart';
import 'results_view.dart';

/// د ازموینو پاڼه — درې حالته: لیست، د نمرو لیکل، پایلې.
class ExamsPage extends StatefulWidget {
  final ExamRepository exams;
  final AcademicRepository academic;
  final Session session;
  final String schoolName;

  const ExamsPage({
    super.key,
    required this.exams,
    required this.academic,
    required this.session,
    required this.schoolName,
  });

  @override
  State<ExamsPage> createState() => _ExamsPageState();
}

enum _View { list, marks, results }

class _ExamsPageState extends State<ExamsPage> {
  _View _view = _View.list;
  bool _loading = true;

  List<ExamRow> _exams = const [];
  List<SectionOption> _sections = const [];
  ExamRow? _selected;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await widget.academic.seedDefaultSubjects();

    final exams = await widget.exams.list();
    final sections = await widget.academic.sections();

    if (!mounted) return;
    setState(() {
      _exams = exams;
      _sections = sections;
      // که یوه ازموینه پرانیستې وه، تازه بڼه يې ونیسه.
      if (_selected != null) {
        _selected = exams
            .where((e) => e.exam.id == _selected!.exam.id)
            .firstOrNull;
        if (_selected == null) _view = _View.list;
      }
      _loading = false;
    });
  }

  Future<void> _newExam() async {
    final year = await widget.academic.currentYear();
    if (year == null || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.danger,
            content: Text('لومړی د زده‌کړې کال جوړ کړئ.'),
          ),
        );
      }
      return;
    }

    final grades = <int, String>{
      for (final s in _sections) s.gradeId: s.gradeName,
    };
    final subjects = await widget.academic.subjects();
    if (!mounted) return;

    final draft = await showDialog<_ExamDraft>(
      context: context,
      builder: (_) => _NewExamDialog(grades: grades, subjects: subjects),
    );
    if (draft == null || !mounted) return;

    final id = await widget.exams.create(
      name: draft.name,
      examType: draft.type,
      academicYearId: year.id,
      term: draft.term,
      startsOn: draft.startsOn,
      endsOn: draft.endsOn,
    );
    // هر ټاکل شوی ټولګی هماغه مضمونونه اخلي — مدیر يې وروسته
    // د هر ټولګي لپاره سمولی شي.
    for (final g in draft.gradeIds) {
      await widget.exams.addSubjects(
        examId: id,
        gradeId: g,
        subjectIds: draft.subjectIds,
        fullMark: draft.fullMark,
        passMark: draft.passMark,
      );
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.standard,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: KeyedSubtree(
        key: ValueKey('$_view/${_selected?.exam.id}'),
        child: switch (_view) {
          _View.list => _buildList(),
          _View.marks => MarkSheetView(
            exams: widget.exams,
            exam: _selected!.exam,
            sections: _sections,
            session: widget.session,
            onBack: () {
              setState(() => _view = _View.list);
              _load();
            },
          ),
          _View.results => ResultsView(
            exams: widget.exams,
            exam: _selected!.exam,
            sections: _sections,
            schoolName: widget.schoolName,
            onBack: () => setState(() => _view = _View.list),
          ),
        },
      ),
    );
  }

  Widget _buildList() {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                Text(
                  'ازموینې',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  locale.grouped(_exams.length),
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _newExam,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('نوې ازموینه'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modExams,
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
          const SizedBox(height: 18),
          Expanded(
            child: DataTableView<ExamRow>(
              loading: _loading,
              rows: _exams,
              emptyIcon: Icons.assignment_rounded,
              emptyTitle: 'لا هېڅ ازموینه نشته',
              emptyHint: '«نوې ازموینه» کېکاږئ او مضمونونه يې وټاکئ.',
              columns: [
                TableColumn(
                  title: 'ازموینه',
                  flex: 3,
                  cell: (context, r) => Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.modExams.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.assignment_rounded,
                          size: 17,
                          color: AppColors.modExams,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r.exam.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: p.ink,
                              ),
                            ),
                            Text(
                              '${examTypeLabel(r.exam.examType)}  •  '
                              '${locale.num(r.subjectCount)} مضمونه',
                              style: TextStyle(fontSize: 11.5, color: p.muted),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TableColumn(
                  title: 'نېټه',
                  flex: 2,
                  cell: (context, r) => Text(
                    '${locale.num(_iso(r.exam.startsOn))} → '
                    '${locale.num(_iso(r.exam.endsOn))}',
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12, color: p.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'د نمرو پرمختګ',
                  width: 170,
                  cell: (context, r) => _Progress(row: r),
                ),
                TableColumn(
                  title: 'حالت',
                  width: 104,
                  cell: (context, r) => StatusChip(
                    label: r.exam.isPublished ? 'خپور شوی' : 'نه دی خپور',
                    color: r.exam.isPublished
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ),
                TableColumn(
                  title: '',
                  width: 232,
                  cell: (context, r) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        onPressed: () => setState(() {
                          _selected = r;
                          _view = _View.marks;
                        }),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.modExams,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                          textStyle: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('نمرې'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => setState(() {
                          _selected = r;
                          _view = _View.results;
                        }),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 13),
                        ),
                        child: const Text('پایلې'),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        tooltip: r.exam.isPublished
                            ? 'له خپرېدو يې راوباسه'
                            : 'والدینو ته يې خپور کړه',
                        onPressed: () async {
                          await widget.exams.publish(
                            r.exam.id,
                            published: !r.exam.isPublished,
                          );
                          await _load();
                        },
                        icon: Icon(
                          r.exam.isPublished
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          size: 17,
                          color: r.exam.isPublished
                              ? AppColors.success
                              : p.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}

String examTypeLabel(String type) => switch (type) {
  'monthly' => 'میاشتنۍ',
  'midterm' => 'د ربعې',
  'final' => 'نهايي',
  _ => 'کوچنۍ',
};

class _Progress extends StatelessWidget {
  final ExamRow row;
  const _Progress({required this.row});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final v = row.progress / 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${locale.num(row.markedCount)} / ${locale.num(row.expectedCount)}',
          style: AppTheme.tabular(
            TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: p.inkSoft,
            ),
          ),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: v.clamp(0, 1)),
            duration: AppMotion.counter,
            curve: AppMotion.standard,
            builder: (_, value, __) => LinearProgressIndicator(
              value: value,
              minHeight: 5,
              backgroundColor: p.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(
                row.isComplete ? AppColors.success : AppColors.modExams,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  نوې ازموینه
// ═══════════════════════════════════════════════════════════

class _ExamDraft {
  final String name;
  final String type;
  final int term;
  final DateTime startsOn;
  final DateTime endsOn;
  final List<int> gradeIds;
  final List<int> subjectIds;
  final int fullMark;
  final int passMark;

  const _ExamDraft({
    required this.name,
    required this.type,
    required this.term,
    required this.startsOn,
    required this.endsOn,
    required this.gradeIds,
    required this.subjectIds,
    required this.fullMark,
    required this.passMark,
  });
}

class _NewExamDialog extends StatefulWidget {
  final Map<int, String> grades;
  final List<Subject> subjects;

  const _NewExamDialog({required this.grades, required this.subjects});

  @override
  State<_NewExamDialog> createState() => _NewExamDialogState();
}

class _NewExamDialogState extends State<_NewExamDialog> {
  final _name = TextEditingController(text: 'د ربعې ازموینه');
  final _full = TextEditingController(text: '100');
  final _pass = TextEditingController(text: '40');

  String _type = 'midterm';
  int _term = 1;
  DateTime _from = DateTime.now();
  DateTime _to = DateTime.now().add(const Duration(days: 7));

  final Set<int> _grades = {};
  final Set<int> _subjects = {};

  @override
  void dispose() {
    _name.dispose();
    _full.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (r != null) {
      setState(() {
      _from = r.start;
      _to = r.end;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final ready = _grades.isNotEmpty && _subjects.isNotEmpty;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: const Text(
        'نوې ازموینه',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 560,
        height: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'نوم'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _type,
                      decoration: const InputDecoration(labelText: 'ډول'),
                      items: [
                        for (final t in const [
                          'monthly',
                          'midterm',
                          'final',
                          'quiz',
                        ])
                          DropdownMenuItem(
                            value: t,
                            child: Text(
                              examTypeLabel(t),
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'midterm'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      initialValue: _term,
                      decoration: const InputDecoration(labelText: 'سمستر'),
                      items: [
                        for (final t in const [1, 2])
                          DropdownMenuItem(
                            value: t,
                            child: Text(
                              '${locale.num(t)} سمستر',
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                      ],
                      onChanged: (v) => setState(() => _term = v ?? 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: _pickRange,
                icon: const Icon(Icons.date_range_rounded, size: 17),
                label: Text(
                  '${locale.num(_iso(_from))} → ${locale.num(_iso(_to))}',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(46),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _full,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'بشپړه نمره',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _pass,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'د کامیابۍ حد',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              _SectionTitle('ټولګي', selected: _grades.length),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final e in widget.grades.entries)
                    _PickChip(
                      label: e.value,
                      on: _grades.contains(e.key),
                      onTap: () => setState(() {
                        if (!_grades.remove(e.key)) _grades.add(e.key);
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              _SectionTitle('مضمونونه', selected: _subjects.length),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in widget.subjects)
                    _PickChip(
                      label: s.name,
                      on: _subjects.contains(s.id),
                      religious: s.isReligious,
                      onTap: () => setState(() {
                        if (!_subjects.remove(s.id)) _subjects.add(s.id);
                      }),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: !ready
              ? null
              : () => Navigator.pop(
                  context,
                  _ExamDraft(
                    name: _name.text.trim().isEmpty
                        ? 'ازموینه'
                        : _name.text.trim(),
                    type: _type,
                    term: _term,
                    startsOn: _from,
                    endsOn: _to,
                    gradeIds: _grades.toList(),
                    subjectIds: _subjects.toList(),
                    fullMark: int.tryParse(_full.text) ?? 100,
                    passMark: int.tryParse(_pass.text) ?? 40,
                  ),
                ),
          child: const Text('جوړ کړه'),
        ),
      ],
    );
  }

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final int selected;
  const _SectionTitle(this.text, {this.selected = 0});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    return Row(
      children: [
        Text(
          text,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: p.ink,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          selected == 0
              ? 'هېڅ نه دي ټاکل شوي'
              : '${locale.num(selected)} ټاکل شوي',
          style: TextStyle(
            fontSize: 11.5,
            color: selected == 0 ? AppColors.warning : p.muted,
          ),
        ),
      ],
    );
  }
}

class _PickChip extends StatelessWidget {
  final String label;
  final bool on;
  final bool religious;
  final VoidCallback onTap;

  const _PickChip({
    required this.label,
    required this.on,
    required this.onTap,
    this.religious = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = religious ? AppColors.modIdCards : AppColors.modExams;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.instant,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: on ? c.withValues(alpha: 0.14) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: on ? c : Colors.transparent),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: on ? FontWeight.w700 : FontWeight.w500,
            color: on ? c : p.inkSoft,
          ),
        ),
      ),
    );
  }
}
