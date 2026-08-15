import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/exam_repository.dart';

/// **د ازموینو تنظیمات** — جوړول، سمول، ړنګول.
class ExamSettingsPage extends StatefulWidget {
  final ExamRepository exams;
  final AcademicRepository academic;
  final bool canEdit;

  /// که سم وي، پاڼه سمدستي د نوې ازموینې فورمه پرانیزي.
  final bool startWithNew;

  const ExamSettingsPage({
    super.key,
    required this.exams,
    required this.academic,
    this.canEdit = true,
    this.startWithNew = false,
  });

  @override
  State<ExamSettingsPage> createState() => _ExamSettingsPageState();
}

class _ExamSettingsPageState extends State<ExamSettingsPage> {
  List<ExamRow> _rows = const [];
  List<Grade> _grades = const [];
  bool _madrasa = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load().then((_) {
      if (widget.startWithNew && mounted) _openForm();
    });
  }

  @override
  void didUpdateWidget(ExamSettingsPage old) {
    super.didUpdateWidget(old);
    if (widget.startWithNew && !old.startWithNew) _openForm();
  }

  Future<void> _load() async {
    final rows = await widget.exams.list();
    final grades = await widget.academic.grades();
    final madrasa = await widget.academic.isMadrasa();
    if (!mounted) return;
    setState(() {
      _rows = rows;
      _grades = grades;
      _madrasa = madrasa;
      _loading = false;
    });
  }

  Future<void> _openForm({Exam? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => ExamFormDialog(
        exams: widget.exams,
        academic: widget.academic,
        grades: _grades,
        madrasa: _madrasa,
        existing: existing,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(Exam e) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('«${e.name}» ړنګه شي؟'),
        content: const Text(
          'که پکې نمرې ثبت شوې وي، ړنګېدی نه شي — دا ساتنه ده، نه بندیز.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).delete),
          ),
        ],
      ),
    );
    if (ok != true) return;

    final err = await widget.exams.remove(e.id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 500,
          backgroundColor: AppColors.warning,
          content: Text(err),
        ),
      );
      return;
    }
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    // د وزنونو مجموعه — که ۱۰۰ نه وي، مدیر باید وویني.
    final weighted = _rows.where((r) => r.exam.weightPercent != 100).toList();
    final weightSum = weighted.fold(0, (a, r) => a + r.exam.weightPercent);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: Row(
            children: [
              Text(
                s.examSettings,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'هره ازموینه خپل مضامین، خپل وزن او خپلې نېټې لري.',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ),
              if (widget.canEdit)
                FilledButton.icon(
                  onPressed: () => _openForm(),
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('نوې ازموینه'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modExams,
                  ),
                ),
            ],
          ),
        ),

        // **د وزنونو خبرداری.** که څلورنیم‌میاشتنۍ ۴۰ او کلنۍ ۵۰ وي،
        // مجموعه ۹۰ ده — او هېڅوک به يې د کال په پای کې پوه نه شي.
        if (weighted.length > 1 && weightSum != 100)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.report_problem_rounded,
                  size: 17,
                  color: AppColors.warning,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'د وزنونو مجموعه ${locale.num(weightSum)} ده، نه ۱۰۰. '
                    'د کال راټوله نمره به له ۱۰۰ څخه نه وي.',
                    style: TextStyle(fontSize: 12.5, color: p.inkSoft),
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
                  action: widget.canEdit
                      ? FilledButton.icon(
                          onPressed: () => _openForm(),
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: const Text('نوې ازموینه'),
                        )
                      : null,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  itemCount: _rows.length,
                  itemBuilder: (context, i) => FadeSlideIn.staggered(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SettingRow(
                        row: _rows[i],
                        locale: locale,
                        madrasa: _madrasa,
                        canEdit: widget.canEdit,
                        onEdit: () => _openForm(existing: _rows[i].exam),
                        onDelete: () => _delete(_rows[i].exam),
                        onPublish: (v) async {
                          await widget.exams.publish(
                            _rows[i].exam.id,
                            published: v,
                          );
                          await _load();
                        },
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SettingRow extends StatelessWidget {
  final ExamRow row;
  final AppLocale locale;
  final bool madrasa;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool> onPublish;

  const _SettingRow({
    required this.row,
    required this.locale,
    required this.madrasa,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
    required this.onPublish,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final e = row.exam;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Row(
        children: [
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
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Pill(
                      color: AppColors.modExams,
                      text: _ExamCardType.label(e.examType),
                    ),
                    const SizedBox(width: 6),
                    Pill(
                      color: e.weightPercent == 100
                          ? p.faint
                          : AppColors.modReports,
                      icon: Icons.percent_rounded,
                      text: locale.num(e.weightPercent),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    '${locale.num(row.subjectCount)} مضامین',
                    if (!madrasa) 'ربع ${locale.num(e.term)}',
                    '${locale.num(e.startsOn.year)}/'
                        '${locale.num(e.startsOn.month)}/'
                        '${locale.num(e.startsOn.day)} — '
                        '${locale.num(e.endsOn.year)}/'
                        '${locale.num(e.endsOn.month)}/'
                        '${locale.num(e.endsOn.day)}',
                  ].join('  ·  '),
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
          ),
          if (canEdit) ...[
            Tooltip(
              message: e.isPublished
                  ? 'خپره ده — والدین يې ویني'
                  : 'خپره نه ده',
              child: Switch(value: e.isPublished, onChanged: onPublish),
            ),
            IconButton(
              tooltip: s.edit,
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 17),
            ),
            IconButton(
              tooltip: s.delete,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline_rounded, size: 18),
              color: AppColors.danger,
            ),
          ],
        ],
      ),
    );
  }
}

/// د ازموینې ډول نوم — له `ExamListPage` سره ګډ.
class _ExamCardType {
  static String label(String t) => switch (t) {
    'monthly' => 'میاشتنۍ',
    'midterm' => 'څلورنیم‌میاشتنۍ',
    'final' => 'کلنۍ',
    'quiz' => 'کوچنۍ',
    _ => t,
  };
}

// ═══════════════════════════════════════════════════════════
//  د ازموینې فورمه
// ═══════════════════════════════════════════════════════════

class ExamFormDialog extends StatefulWidget {
  final ExamRepository exams;
  final AcademicRepository academic;
  final List<Grade> grades;
  final bool madrasa;
  final Exam? existing;

  const ExamFormDialog({
    super.key,
    required this.exams,
    required this.academic,
    required this.grades,
    required this.madrasa,
    this.existing,
  });

  @override
  State<ExamFormDialog> createState() => _ExamFormDialogState();
}

class _ExamFormDialogState extends State<ExamFormDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _weight = TextEditingController(
    text: '${widget.existing?.weightPercent ?? 100}',
  );
  late final _full = TextEditingController(text: '100');
  late final _pass = TextEditingController(text: '40');

  late String _type = widget.existing?.examType ?? 'midterm';
  late int _term = widget.existing?.term ?? 1;
  late DateTime _from = widget.existing?.startsOn ?? DateTime.now();
  late DateTime _to =
      widget.existing?.endsOn ?? DateTime.now().add(const Duration(days: 7));

  /// **تلواله: ټول ټولګي، ټول مضامین ټاکل شوي.**
  ///
  /// یو مدیر چې کلنۍ ازموینه جوړوي، تقریباً تل ټول غواړي. که تشه
  /// پیل شوې وای، هغه به دوولس ټولګي × اتلس مضامین په لاس نښه کول.
  final Map<int, Set<int>> _selected = {};
  final Map<int, List<Subject>> _subjectsByGrade = {};
  bool _loading = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _full.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loadSubjects() async {
    final existing = widget.existing;
    final chosen = <int, Set<int>>{};
    if (existing != null) {
      for (final es in await widget.exams.subjectsOf(existing.id)) {
        chosen
            .putIfAbsent(es.examSubject.gradeId, () => {})
            .add(es.examSubject.subjectId);
      }
    }

    for (final g in widget.grades) {
      final subs = await widget.academic.subjects(gradeId: g.id);
      _subjectsByGrade[g.id] = subs;
      // نوې ازموینه: ټول ټاکل شوي. سمون: هغه چې لا ثبت دي.
      _selected[g.id] = existing == null
          ? subs.map((s) => s.id).toSet()
          : (chosen[g.id] ?? <int>{});
    }

    if (!mounted) return;
    setState(() => _loading = false);
  }

  int get _totalSelected =>
      _selected.values.fold(0, (a, s) => a + s.length);

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _from : _to,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _from = picked;
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked.isBefore(_from) ? _from : picked;
      }
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'نوم اړین دی.');
      return;
    }
    if (_totalSelected == 0) {
      setState(() => _error = 'لږ تر لږه یو مضمون وټاکئ.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    final weight = (int.tryParse(Numerals.toLatin(_weight.text)) ?? 100).clamp(
      1,
      100,
    );
    final full = int.tryParse(Numerals.toLatin(_full.text)) ?? 100;
    final pass = int.tryParse(Numerals.toLatin(_pass.text)) ?? 40;

    int examId;
    if (widget.existing == null) {
      final year = await widget.academic.currentYear();
      if (year == null) {
        setState(() {
          _busy = false;
          _error = 'د زده‌کړې کال نشته.';
        });
        return;
      }
      examId = await widget.exams.create(
        name: name,
        examType: _type,
        academicYearId: year.id,
        // مدرسه سمستر نه لري — تل ۱.
        term: widget.madrasa ? 1 : _term,
        startsOn: _from,
        endsOn: _to,
      );
      await widget.exams.update(id: examId, weightPercent: weight);
    } else {
      examId = widget.existing!.id;
      await widget.exams.update(
        id: examId,
        name: name,
        examType: _type,
        term: widget.madrasa ? 1 : _term,
        weightPercent: weight,
        startsOn: _from,
        endsOn: _to,
      );
    }

    final err = await widget.exams.setSubjects(
      examId: examId,
      subjectsByGrade: {
        for (final e in _selected.entries)
          if (e.value.isNotEmpty) e.key: e.value.toList(),
      },
      fullMark: full,
      passMark: pass,
    );

    if (!mounted) return;
    if (err != null) {
      setState(() {
        _busy = false;
        _error = err;
      });
      return;
    }
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    return AlertDialog(
      title: Text(
        widget.existing == null ? 'نوې ازموینه' : 'د ازموینې سمون',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 640,
        height: 560,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _name,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'د ازموینې نوم',
                        hintText: 'د کال پای ازموینه',
                        isDense: true,
                      ),
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _type,
                            isDense: true,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: 'ډول',
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'monthly',
                                child: Text('میاشتنۍ'),
                              ),
                              DropdownMenuItem(
                                value: 'midterm',
                                child: Text('څلورنیم‌میاشتنۍ'),
                              ),
                              DropdownMenuItem(
                                value: 'final',
                                child: Text('کلنۍ'),
                              ),
                              DropdownMenuItem(
                                value: 'quiz',
                                child: Text('کوچنۍ'),
                              ),
                            ],
                            onChanged: (v) => setState(() {
                              _type = v ?? 'midterm';
                              // د ډول له مخې د وزن وړاندیز — خو کارن
                              // يې بدلولی شي.
                              _weight.text = switch (_type) {
                                'midterm' => '40',
                                'final' => '60',
                                _ => '100',
                              };
                            }),
                          ),
                        ),
                        // **مدرسه سمستر نه لري.** یوه ساحه چې معنا نه
                        // لري، یوازې د تېروتنې لار ده.
                        if (!widget.madrasa) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              initialValue: _term,
                              isDense: true,
                              decoration: const InputDecoration(
                                labelText: 'ربع / سمستر',
                                isDense: true,
                              ),
                              items: const [
                                DropdownMenuItem(value: 1, child: Text('۱')),
                                DropdownMenuItem(value: 2, child: Text('۲')),
                              ],
                              onChanged: (v) => setState(() => _term = v ?? 1),
                            ),
                          ),
                        ],
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _weight,
                            decoration: InputDecoration(
                              labelText: '${s.weight} (٪)',
                              helperText: 'د کال په ۱۰۰ کې برخه',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: _DateBtn(
                            label: 'له',
                            date: _from,
                            onTap: () => _pickDate(true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateBtn(
                            label: 'تر',
                            date: _to,
                            onTap: () => _pickDate(false),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _full,
                            decoration: const InputDecoration(
                              labelText: 'بشپړه نمره',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _pass,
                            decoration: const InputDecoration(
                              labelText: 'د بریا نمره',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          widget.madrasa
                              ? 'درجې او فنون'
                              : 'ټولګي او مضامین',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: p.ink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Pill(
                          color: AppColors.modExams,
                          text: '${locale.num(_totalSelected)} ټاکل شوي',
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => setState(() {
                            for (final g in widget.grades) {
                              _selected[g.id] = _subjectsByGrade[g.id]!
                                  .map((x) => x.id)
                                  .toSet();
                            }
                          }),
                          child: Text(s.all),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            for (final g in widget.grades) {
                              _selected[g.id] = {};
                            }
                          }),
                          child: const Text('هېڅ یو'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    for (final g in widget.grades)
                      _GradeSubjects(
                        grade: g,
                        subjects: _subjectsByGrade[g.id] ?? const [],
                        selected: _selected[g.id] ?? {},
                        onToggle: (id) => setState(() {
                          final set = _selected[g.id]!;
                          if (!set.remove(id)) set.add(id);
                        }),
                        onAll: (on) => setState(() {
                          _selected[g.id] = on
                              ? _subjectsByGrade[g.id]!
                                    .map((x) => x.id)
                                    .toSet()
                              : {};
                        }),
                      ),

                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _error!,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.danger,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.modExams),
          child: Text(s.save),
        ),
      ],
    );
  }
}

class _GradeSubjects extends StatelessWidget {
  final Grade grade;
  final List<Subject> subjects;
  final Set<int> selected;
  final ValueChanged<int> onToggle;
  final ValueChanged<bool> onAll;

  const _GradeSubjects({
    required this.grade,
    required this.subjects,
    required this.selected,
    required this.onToggle,
    required this.onAll,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (subjects.isEmpty) return const SizedBox.shrink();

    final all = selected.length == subjects.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Checkbox(
                value: all,
                tristate: true,
                onChanged: (_) => onAll(!all),
                visualDensity: VisualDensity.compact,
              ),
              Text(
                grade.name,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: p.inkSoft,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 34, top: 2),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final sub in subjects)
                  FilterChip(
                    label: Text(
                      sub.name,
                      style: const TextStyle(fontSize: 11.5),
                    ),
                    selected: selected.contains(sub.id),
                    visualDensity: VisualDensity.compact,
                    onSelected: (_) => onToggle(sub.id),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBtn extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateBtn({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 10.5, color: p.faint)),
            Text(
              locale.num(
                '${date.year}-${date.month.toString().padLeft(2, '0')}'
                '-${date.day.toString().padLeft(2, '0')}',
              ),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
