import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';

/// د مضامینو اداره — د مکتب او مدرسې دواړو لپاره.
///
/// **د دوو ډولونو توپیر دلته څرګند دی.** یو مکتب «ریاضي» تدریسوي —
/// یو نوم، بس. یوه مدرسه «اصول الفقه» تدریسوي، خو پر «اصول الشاشي»
/// کتاب، او هغه یوازې د درجه رابعه لپاره. نو کله چې ښوونځی مدرسه
/// وي، د کتاب خانه ښکاره کېږي او وړاندیزونه د هماغې درجې له رسمي
/// نصاب څخه راځي.
class SubjectsPage extends StatefulWidget {
  final AcademicRepository academic;
  final bool canEdit;

  const SubjectsPage({super.key, required this.academic, this.canEdit = true});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<Grade> _grades = const [];
  List<Subject> _subjects = const [];
  bool _madrasa = false;
  bool _loading = true;

  int? _gradeFilter;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final grades = await widget.academic.grades();
    final subjects = await widget.academic.subjects();
    final madrasa = await widget.academic.isMadrasa();
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _subjects = subjects;
      _madrasa = madrasa;
      _loading = false;
    });
  }

  String? _gradeName(int? id) {
    if (id == null) return null;
    for (final g in _grades) {
      if (g.id == id) return g.name;
    }
    return null;
  }

  List<Subject> get _visible {
    final q = _query.trim();
    return _subjects.where((s) {
      if (_gradeFilter != null && s.gradeId != _gradeFilter) return false;
      if (q.isEmpty) return true;
      return s.name.contains(q) || (s.book?.contains(q) ?? false);
    }).toList();
  }

  Future<void> _openEditor({Subject? existing, int? presetGrade}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _SubjectDialog(
        academic: widget.academic,
        grades: _grades,
        madrasa: _madrasa,
        existing: existing,
        presetGrade: presetGrade ?? _gradeFilter,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(Subject s) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('«${s.name}» ړنګ شي؟'),
        content: const Text(
          'دا کار بېرته نه ګرځي. که مضمون په ازموینو کې کارېدلی وي، '
          'ړنګېدی نه شي.',
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

    final err = await widget.academic.removeSubject(s.id);
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 460,
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
    final visible = _visible;

    // د ټولګي په کچه ډله‌بندي — «عام» مضمونونه (بې ټولګي) په سر کې.
    final groups = <int?, List<Subject>>{};
    for (final sub in visible) {
      (groups[sub.gradeId] ??= []).add(sub);
    }
    final keys = groups.keys.toList()
      ..sort((a, b) {
        if (a == null) return -1;
        if (b == null) return 1;
        return _levelOf(a).compareTo(_levelOf(b));
      });

    return Column(
      children: [
        _Toolbar(
          madrasa: _madrasa,
          grades: _grades,
          gradeFilter: _gradeFilter,
          total: _subjects.length,
          shown: visible.length,
          canEdit: widget.canEdit,
          onQuery: (v) => setState(() => _query = v),
          onGrade: (v) => setState(() => _gradeFilter = v),
          onAdd: () => _openEditor(),
        ),
        Expanded(
          child: visible.isEmpty
              ? EmptyState(
                  icon: Icons.menu_book_rounded,
                  text: _subjects.isEmpty
                      ? 'لا هېڅ مضمون نه دی ثبت شوی.'
                      : 'د دې فلټر سره هېڅ مضمون ونه موندل شو.',
                  hint: _madrasa
                      ? 'د هرې درجې فنون د پوهنې وزارت له نصاب څخه وړاندیز کېږي.'
                      : null,
                  action: widget.canEdit
                      ? FilledButton.icon(
                          onPressed: () => _openEditor(),
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: Text(s.add),
                        )
                      : null,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  children: [
                    for (var i = 0; i < keys.length; i++)
                      FadeSlideIn.staggered(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Panel(
                            title: _gradeName(keys[i]) ?? 'عام مضامین',
                            subtitle: keys[i] == null
                                ? 'ټولو ټولګیو ته ګډ'
                                : '${locale.num(groups[keys[i]]!.length)} مضمونه',
                            icon: keys[i] == null
                                ? Icons.public_rounded
                                : Icons.school_rounded,
                            color: AppColors.modSubjects,
                            padding: EdgeInsets.zero,
                            actions: [
                              if (widget.canEdit)
                                IconButton(
                                  tooltip: 'دې ټولګي ته مضمون زیات کړه',
                                  onPressed: () =>
                                      _openEditor(presetGrade: keys[i]),
                                  icon: const Icon(
                                    Icons.add_circle_outline_rounded,
                                    size: 19,
                                  ),
                                ),
                            ],
                            child: Column(
                              children: [
                                for (final sub in groups[keys[i]]!)
                                  _SubjectRow(
                                    subject: sub,
                                    madrasa: _madrasa,
                                    canEdit: widget.canEdit,
                                    onEdit: () => _openEditor(existing: sub),
                                    onDelete: () => _delete(sub),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Text(
                      'ټول: ${locale.num(_subjects.length)} مضامین',
                      style: TextStyle(fontSize: 11.5, color: p.faint),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  int _levelOf(int gradeId) {
    for (final g in _grades) {
      if (g.id == gradeId) return g.sortOrder * 1000 + g.level;
    }
    return 999999;
  }
}

// ═══════════════════════════════════════════════════════════
//  د پورتنۍ کرښې وسایل
// ═══════════════════════════════════════════════════════════

class _Toolbar extends StatelessWidget {
  final bool madrasa;
  final List<Grade> grades;
  final int? gradeFilter;
  final int total;
  final int shown;
  final bool canEdit;
  final ValueChanged<String> onQuery;
  final ValueChanged<int?> onGrade;
  final VoidCallback onAdd;

  const _Toolbar({
    required this.madrasa,
    required this.grades,
    required this.gradeFilter,
    required this.total,
    required this.shown,
    required this.canEdit,
    required this.onQuery,
    required this.onGrade,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
      child: Row(
        children: [
          SizedBox(
            width: 260,
            child: TextField(
              onChanged: onQuery,
              decoration: InputDecoration(
                hintText: '${s.search}…',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<int?>(
              initialValue: gradeFilter,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: madrasa ? 'درجه' : s.grade,
                isDense: true,
              ),
              items: [
                DropdownMenuItem(value: null, child: Text(s.all)),
                for (final g in grades)
                  DropdownMenuItem(value: g.id, child: Text(g.name)),
              ],
              onChanged: onGrade,
            ),
          ),
          const Spacer(),
          if (shown != total)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 10),
              child: Text(
                '${s.locale.num(shown)} له ${s.locale.num(total)}',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
            ),
          if (canEdit)
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: Text(s.add),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.modSubjects,
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  یوه کرښه
// ═══════════════════════════════════════════════════════════

/// د سختوالي رنګونه — یو ځای، چې پاڼه او ډیالوګ یو شان وښيي.
({Color color, String label}) difficultyStyle(String d, S s) => switch (d) {
  'easy' => (color: AppColors.success, label: s.diffEasy),
  'hard' => (color: AppColors.danger, label: s.diffHard),
  _ => (color: AppColors.warning, label: s.diffMedium),
};

class _SubjectRow extends StatefulWidget {
  final Subject subject;
  final bool madrasa;
  final bool canEdit;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectRow({
    required this.subject,
    required this.madrasa,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SubjectRow> createState() => _SubjectRowState();
}

class _SubjectRowState extends State<_SubjectRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final sub = widget.subject;
    final diff = difficultyStyle(sub.difficulty, s);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        color: _hover ? p.surfaceAlt : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: sub.isReligious
                    ? AppColors.modHifz
                    : AppColors.modTimetable,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 190,
              child: Text(
                sub.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: p.ink,
                ),
              ),
            ),
            if (widget.madrasa)
              Expanded(
                child: Text(
                  sub.book ?? '—',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              )
            else
              Expanded(
                child: Text(
                  sub.code ?? '',
                  style: AppTheme.tabular(
                    TextStyle(fontSize: 12, color: p.faint),
                  ),
                ),
              ),
            Pill(color: diff.color, text: diff.label),
            const SizedBox(width: 10),
            Text(
              '${s.locale.num(sub.passMark)} / ${s.locale.num(sub.fullMark)}',
              style: AppTheme.tabular(
                TextStyle(fontSize: 12, color: p.muted),
              ),
            ),
            const SizedBox(width: 6),
            // تڼۍ یوازې د موږک تر لاندې راځي — چې لیست ساده پاتې شي.
            AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: _hover && widget.canEdit ? 1 : 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: s.edit,
                    onPressed: widget.canEdit ? widget.onEdit : null,
                    icon: const Icon(Icons.edit_rounded, size: 16),
                  ),
                  IconButton(
                    tooltip: s.delete,
                    onPressed: widget.canEdit ? widget.onDelete : null,
                    icon: const Icon(Icons.delete_outline_rounded, size: 17),
                    color: AppColors.danger,
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

// ═══════════════════════════════════════════════════════════
//  د زیاتولو/سمون ډیالوګ
// ═══════════════════════════════════════════════════════════

class _SubjectDialog extends StatefulWidget {
  final AcademicRepository academic;
  final List<Grade> grades;
  final bool madrasa;
  final Subject? existing;
  final int? presetGrade;

  const _SubjectDialog({
    required this.academic,
    required this.grades,
    required this.madrasa,
    this.existing,
    this.presetGrade,
  });

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _book = TextEditingController(text: widget.existing?.book ?? '');
  late final _code = TextEditingController(text: widget.existing?.code ?? '');
  late final _full = TextEditingController(
    text: '${widget.existing?.fullMark ?? 100}',
  );
  late final _pass = TextEditingController(
    text: '${widget.existing?.passMark ?? 40}',
  );

  late int? _gradeId = widget.existing?.gradeId ?? widget.presetGrade;
  late String _difficulty = widget.existing?.difficulty ?? 'medium';
  late bool _religious = widget.existing?.isReligious ?? widget.madrasa;

  List<({String name, String? book, bool religious})> _suggestions = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  @override
  void dispose() {
    _name.dispose();
    _book.dispose();
    _code.dispose();
    _full.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loadSuggestions() async {
    final gradeName = _gradeId == null
        ? null
        : widget.grades.firstWhere((g) => g.id == _gradeId).name;
    final list = await widget.academic.subjectSuggestions(gradeName);
    if (!mounted) return;
    setState(() => _suggestions = list);
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    setState(() => _busy = true);

    final full = int.tryParse(Numerals.toLatin(_full.text)) ?? 100;
    final pass = int.tryParse(Numerals.toLatin(_pass.text)) ?? 40;
    final book = _book.text.trim();
    final code = _code.text.trim();

    if (widget.existing == null) {
      await widget.academic.addSubject(
        name: name,
        gradeId: _gradeId,
        book: book.isEmpty ? null : book,
        code: code.isEmpty ? null : code,
        difficulty: _difficulty,
        fullMark: full,
        passMark: pass,
        isReligious: _religious,
      );
    } else {
      await widget.academic.updateSubject(
        id: widget.existing!.id,
        name: name,
        gradeId: _gradeId,
        clearGrade: _gradeId == null,
        book: book.isEmpty ? '' : book,
        code: code.isEmpty ? '' : code,
        difficulty: _difficulty,
        fullMark: full,
        passMark: pass,
        isReligious: _religious,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return AlertDialog(
      title: Text(
        widget.existing == null ? 'نوی مضمون' : 'د مضمون سمون',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<int?>(
                initialValue: _gradeId,
                isExpanded: true,
                isDense: true,
                decoration: InputDecoration(
                  labelText: widget.madrasa ? 'درجه' : s.grade,
                  helperText: widget.madrasa
                      ? 'د درجې په ټاکلو سره، د هغې رسمي فنون وړاندیز کېږي.'
                      : null,
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('عام — ټولو ته'),
                  ),
                  for (final g in widget.grades)
                    DropdownMenuItem(value: g.id, child: Text(g.name)),
                ],
                onChanged: (v) {
                  setState(() => _gradeId = v);
                  _loadSuggestions();
                },
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'د مضمون نوم',
                  isDense: true,
                ),
              ),

              // **وړاندیزونه، نه بندیزونه.** کارن پر یوه کېکاږي او
              // نوم (او که وي، کتاب) ډکېږي؛ یا خپل نوم لیکي.
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.madrasa ? 'د دې درجې فنون:' : 'عام مضامین:',
                  style: TextStyle(fontSize: 11.5, color: p.faint),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final sug in _suggestions)
                      ActionChip(
                        label: Text(
                          sug.name,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          _name.text = sug.name;
                          if (sug.book != null) _book.text = sug.book!;
                          _religious = sug.religious;
                        }),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 14),
              if (widget.madrasa)
                TextField(
                  controller: _book,
                  decoration: InputDecoration(
                    labelText: s.book,
                    hintText: 'لکه: اصول الشاشي',
                    isDense: true,
                  ),
                )
              else
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: 'کوډ (اختیاري)',
                    hintText: 'MTH',
                    isDense: true,
                  ),
                ),

              const SizedBox(height: 16),
              Text(
                '${s.difficulty} — اختیاري',
                style: TextStyle(fontSize: 11.5, color: p.faint),
              ),
              const SizedBox(height: 7),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: SegmentedChoice<String>(
                  value: _difficulty,
                  color: difficultyStyle(_difficulty, s).color,
                  options: [
                    (value: 'easy', label: s.diffEasy, icon: null),
                    (value: 'medium', label: s.diffMedium, icon: null),
                    (value: 'hard', label: s.diffHard, icon: null),
                  ],
                  onChanged: (v) => setState(() => _difficulty = v),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _full,
                      decoration: const InputDecoration(
                        labelText: 'بشپړه نمره',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
              const SizedBox(height: 6),
              CheckboxListTile(
                value: _religious,
                onChanged: (v) => setState(() => _religious = v ?? false),
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'دیني مضمون',
                  style: TextStyle(fontSize: 13),
                ),
                subtitle: Text(
                  'د کارنامې پر مخ دیني او عصري اوسط جلا ښکاري.',
                  style: TextStyle(fontSize: 11, color: p.faint),
                ),
              ),
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
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.modSubjects,
          ),
          child: Text(s.save),
        ),
      ],
    );
  }
}
