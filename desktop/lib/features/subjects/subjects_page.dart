import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../widgets/filter_bar.dart';

/// د مضامینو اداره — د مکتب او مدرسې دواړو لپاره.
///
/// **د دوو ډولونو توپیر دلته څرګند دی.** یو مکتب «ریاضي» تدریسوي —
/// یو نوم، بس. یوه مدرسه «اصول الفقه» تدریسوي، خو پر «اصول الشاشي»
/// کتاب، او هغه یوازې د درجه رابعه لپاره. نو کله چې ښوونځی مدرسه
/// وي، د کتاب خانه ښکاره کېږي او وړاندیزونه د هماغې درجې له رسمي
/// نصاب څخه راځي.
/// **د کتاب نوم مخکې، فن وروسته.**
///
/// یوه مدرسه «صرف» نه تدریسوي — «صرف بهایي» تدریسوي. فن یوه کورنۍ
/// ده، کتاب هغه څیز دی چې شاګرد يې په لاس کې لري او استاد يې له
/// مخې لوستل کوي. نو هرچېرې چې یو نوم ښکاري، هغه باید د کتاب وي؛
/// فن یوازې د ډله‌بندۍ لپاره ورسره پاتې کېږي.
String subjectTitle(Subject s) {
  final book = s.book?.trim() ?? '';
  return book.isEmpty ? s.name : book;
}

/// فن — یوازې هغه وخت چې له کتابه بېل وي.
String? subjectFan(Subject s) {
  final book = s.book?.trim() ?? '';
  if (book.isEmpty || book == s.name) return null;
  return s.name;
}

class SubjectsPage extends StatefulWidget {
  final AcademicRepository academic;

  /// د «مدرس استاد» ټاکنې لپاره. که `null` وي، هغه ساحه نه ښکاري.
  final TeacherRepository? teachers;
  final bool canEdit;

  const SubjectsPage({
    super.key,
    required this.academic,
    this.teachers,
    this.canEdit = true,
  });

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  List<Grade> _grades = const [];
  List<Subject> _subjects = const [];
  bool _madrasa = false;
  bool _loading = true;

  List<Teacher> _teachers = const [];

  int? _gradeFilter;
  String _query = '';
  final _search = TextEditingController();

  // پرمختللي فلټرونه
  bool _showFilters = false;
  String? _fanFilter;
  String? _difficultyFilter;
  bool? _religiousFilter;
  int? _teacherFilter;

  int get _advancedCount => [
    _fanFilter,
    _difficultyFilter,
    _religiousFilter,
    _teacherFilter,
  ].whereType<Object>().length;

  /// ټول هغه فنون چې ریښتیا کارېږي — نه یو ثابت لیست.
  List<String> get _fans {
    final set = <String>{};
    for (final x in _subjects) {
      final fan = subjectFan(x);
      if (fan != null) set.add(fan);
    }
    final out = set.toList()..sort();
    return out;
  }

  String? _teacherName(int? id) {
    if (id == null) return null;
    for (final t in _teachers) {
      if (t.id == id) return t.fullName;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final grades = await widget.academic.grades();
    final subjects = await widget.academic.subjects();
    final madrasa = await widget.academic.isMadrasa();
    final teachers = await widget.teachers?.activeTeachers() ?? const <Teacher>[];
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _subjects = subjects;
      _madrasa = madrasa;
      _teachers = teachers;
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
      if (_fanFilter != null && subjectFan(s) != _fanFilter) return false;
      if (_difficultyFilter != null && s.difficulty != _difficultyFilter) {
        return false;
      }
      if (_religiousFilter != null && s.isReligious != _religiousFilter) {
        return false;
      }
      if (_teacherFilter != null && s.teacherId != _teacherFilter) return false;
      if (q.isEmpty) return true;
      return s.name.contains(q) ||
          (s.book?.contains(q) ?? false) ||
          (_teacherName(s.teacherId)?.contains(q) ?? false);
    }).toList();
  }

  Future<void> _openEditor({Subject? existing, int? presetGrade}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => _SubjectDialog(
        academic: widget.academic,
        grades: _grades,
        teachers: _teachers,
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
        title: Text('«${subjectTitle(s)}» ړنګ شي؟'),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilterBar(
                searchController: _search,
                onSearchChanged: (v) => setState(() => _query = v),
                searchHint: 'د کتاب نوم، فن یا استاد…',
                searchWidth: 280,
                primary: [
                  if (_grades.isNotEmpty)
                    QuickFilter<int>(
                      label: _madrasa ? 'ټولې درجې' : 'ټول ټولګي',
                      icon: Icons.class_rounded,
                      value: _gradeFilter,
                      options: [
                        for (final g in _grades) (value: g.id, label: g.name),
                      ],
                      onChanged: (v) => setState(() => _gradeFilter = v),
                    ),
                ],
                activeCount: _advancedCount,
                open: _showFilters,
                onToggle: () => setState(() => _showFilters = !_showFilters),
                countLabel: visible.length == _subjects.length
                    ? '${locale.num(_subjects.length)} کتابونه'
                    : '${locale.num(visible.length)} له '
                          '${locale.num(_subjects.length)}',
                actions: [
                  if (widget.canEdit)
                    FilledButton.icon(
                      onPressed: () => _openEditor(),
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: Text(s.add),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.modSubjects,
                        minimumSize: const Size(0, 44),
                      ),
                    ),
                ],
              ),
              FilterSheet(
                open: _showFilters,
                activeCount: _advancedCount,
                onClear: () => setState(() {
                  _fanFilter = null;
                  _difficultyFilter = null;
                  _religiousFilter = null;
                  _teacherFilter = null;
                }),
                children: [
                  FilterDropdown<String>(
                    label: 'فن',
                    allLabel: 'ټول فنون',
                    value: _fanFilter,
                    options: [for (final f in _fans) (value: f, label: f)],
                    onChanged: (v) => setState(() => _fanFilter = v),
                  ),
                  FilterDropdown<String>(
                    label: s.difficulty,
                    allLabel: 'هر سختوالی',
                    value: _difficultyFilter,
                    options: [
                      (value: 'easy', label: s.diffEasy),
                      (value: 'medium', label: s.diffMedium),
                      (value: 'hard', label: s.diffHard),
                    ],
                    onChanged: (v) => setState(() => _difficultyFilter = v),
                  ),
                  if (_teachers.isNotEmpty)
                    FilterDropdown<int>(
                      label: 'مدرس استاد',
                      allLabel: 'ټول استادان',
                      value: _teacherFilter,
                      options: [
                        for (final t in _teachers)
                          (value: t.id, label: t.fullName),
                      ],
                      onChanged: (v) => setState(() => _teacherFilter = v),
                    ),
                  FilterDropdown<bool>(
                    label: 'ډول',
                    allLabel: 'دیني او عصري',
                    icon: Icons.auto_stories_rounded,
                    value: _religiousFilter,
                    options: const [
                      (value: true, label: 'دیني'),
                      (value: false, label: 'عصري'),
                    ],
                    onChanged: (v) => setState(() => _religiousFilter = v),
                  ),
                ],
              ),
              const SizedBox(height: 14),
            ],
          ),
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
                                : '${locale.num(groups[keys[i]]!.length)} کتابونه',
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
                                    teacherName: _teacherName(sub.teacherId),
                                    onEdit: () => _openEditor(existing: sub),
                                    onDelete: () => _delete(sub),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    Text(
                      'ټول: ${locale.num(_subjects.length)} کتابونه',
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
  final String? teacherName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SubjectRow({
    required this.subject,
    required this.madrasa,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
    this.teacherName,
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
    final fan = subjectFan(sub);
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
            // **مخکې د کتاب نوم** — هغه څه چې شاګرد يې په لاس کې لري.
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    subjectTitle(sub),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  if (fan != null || widget.teacherName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [
                        if (fan != null) fan,
                        if (widget.teacherName != null) widget.teacherName!,
                      ].join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11.5, color: p.muted),
                    ),
                  ],
                ],
              ),
            ),
            if (sub.pages != null) ...[
              Text(
                '${s.locale.num(sub.pages!)} مخه',
                style: AppTheme.tabular(
                  TextStyle(fontSize: 11.5, color: p.faint),
                ),
              ),
              const SizedBox(width: 12),
            ],
            if (!widget.madrasa && (sub.code?.isNotEmpty ?? false)) ...[
              Text(
                sub.code!,
                style: AppTheme.tabular(
                  TextStyle(fontSize: 12, color: p.faint),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Pill(color: diff.color, text: diff.label),
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
  final List<Teacher> teachers;
  final bool madrasa;
  final Subject? existing;
  final int? presetGrade;

  const _SubjectDialog({
    required this.academic,
    required this.grades,
    required this.teachers,
    required this.madrasa,
    this.existing,
    this.presetGrade,
  });

  @override
  State<_SubjectDialog> createState() => _SubjectDialogState();
}

class _SubjectDialogState extends State<_SubjectDialog> {
  /// **فن** — اختیاري. که تش پاتې شي، د کتاب نوم پکې لیکل کېږي،
  /// ځکه چې د ډیټابیس `name` تش نه مني او هرچېرې فالبیک دی.
  late final _fan = TextEditingController(
    text: widget.existing == null ? '' : (subjectFan(widget.existing!) ?? ''),
  );
  late final _book = TextEditingController(
    text: widget.existing == null ? '' : subjectTitle(widget.existing!),
  );
  late final _pages = TextEditingController(
    text: widget.existing?.pages == null ? '' : '${widget.existing!.pages}',
  );
  int? _teacherId;
  late final _code = TextEditingController(text: widget.existing?.code ?? '');
  late int? _gradeId = widget.existing?.gradeId ?? widget.presetGrade;
  late String _difficulty = widget.existing?.difficulty ?? 'medium';
  late bool _religious = widget.existing?.isReligious ?? widget.madrasa;

  List<({String name, String? book, bool religious})> _suggestions = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _teacherId = widget.existing?.teacherId;
    _loadSuggestions();
  }

  @override
  void dispose() {
    _fan.dispose();
    _book.dispose();
    _pages.dispose();
    _code.dispose();
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
    final book = _book.text.trim();
    if (book.isEmpty) return;
    setState(() => _busy = true);

    // **فن اختیاري دی، خو `name` تش نه مني.** که کارن فن ونه لیکي،
    // د کتاب نوم پکې کېږي — نو هرې پوښتنې ته یو ځواب شته او هېڅ
    // کرښه بې‌نومه نه پاتې کېږي.
    final fan = _fan.text.trim();
    final name = fan.isEmpty ? book : fan;

    final code = _code.text.trim();
    final pages = int.tryParse(Numerals.toLatin(_pages.text));

    if (widget.existing == null) {
      await widget.academic.addSubject(
        name: name,
        gradeId: _gradeId,
        book: book,
        code: code.isEmpty ? null : code,
        difficulty: _difficulty,
        isReligious: _religious,
        teacherId: _teacherId,
        pages: pages,
      );
    } else {
      await widget.academic.updateSubject(
        id: widget.existing!.id,
        name: name,
        gradeId: _gradeId,
        clearGrade: _gradeId == null,
        book: book,
        code: code.isEmpty ? '' : code,
        difficulty: _difficulty,
        isReligious: _religious,
        teacherId: _teacherId,
        clearTeacher: _teacherId == null,
        pages: pages,
        clearPages: pages == null,
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
        widget.existing == null ? 'نوی کتاب' : 'د کتاب سمون',
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

              // **۱ — د کتاب نوم.** دا هغه څه دي چې شاګرد يې په لاس
              // کې لري، نو لومړی او اړین دی.
              TextField(
                controller: _book,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'د کتاب نوم',
                  hintText: widget.madrasa ? 'لکه: اصول الشاشي' : 'لکه: ریاضي',
                  isDense: true,
                  prefixIcon: const Icon(Icons.menu_book_rounded, size: 18),
                ),
              ),

              // **وړاندیزونه، نه بندیزونه.** کارن پر یوه کېکاږي او
              // کتاب او فن دواړه ډکېږي؛ یا خپل نوم لیکي.
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  widget.madrasa ? 'د دې درجې نصاب:' : 'عام مضامین:',
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
                          sug.book ?? sug.name,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          _book.text = sug.book ?? sug.name;
                          _fan.text = sug.name;
                          _religious = sug.religious;
                        }),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 14),

              // **۲ — فن.** اختیاري: یوه کورنۍ چې کتاب پکې راځي.
              TextField(
                controller: _fan,
                decoration: const InputDecoration(
                  labelText: 'د مضمون فن (اختیاري)',
                  hintText: 'لکه: اصول فقه',
                  isDense: true,
                  prefixIcon: Icon(Icons.category_rounded, size: 18),
                ),
              ),

              if (!widget.madrasa) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _code,
                  decoration: const InputDecoration(
                    labelText: 'کوډ (اختیاري)',
                    hintText: 'MTH',
                    isDense: true,
                  ),
                ),
              ],

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

              // **۴ — مدرس استاد.** اختیاري: د مهالویش له ټاکنې بېل.
              // هلته یو ساعت یو استاد لري؛ دلته کتاب یو استاد لري.
              if (widget.teachers.isNotEmpty) ...[
                DropdownButtonFormField<int?>(
                  initialValue: _teacherId,
                  isExpanded: true,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'مدرس استاد (اختیاري)',
                    isDense: true,
                    prefixIcon: Icon(Icons.person_rounded, size: 18),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('نه دی ټاکل شوی'),
                    ),
                    for (final t in widget.teachers)
                      DropdownMenuItem(value: t.id, child: Text(t.fullName)),
                  ],
                  onChanged: (v) => setState(() => _teacherId = v),
                ),
                const SizedBox(height: 14),
              ],

              // **۵ — د پاڼو شمېر.** اختیاري: د نصاب د وېش لپاره —
              // «۱۲۰ مخه په اووه میاشتو کې» یوه ریښتینې پوښتنه ده.
              TextField(
                controller: _pages,
                decoration: const InputDecoration(
                  labelText: 'د صفحو تعداد (اختیاري)',
                  isDense: true,
                  prefixIcon: Icon(Icons.description_rounded, size: 18),
                ),
              ),

              // **نمرې دلته نشته — او دا په قصد دی.**
              //
              // یو کتاب په څلورنیمې میاشتنۍ ازموینه کې ۵۰ نمرې لري
              // او په کلنۍ کې ۱۰۰. یوه ثابته نمره چې د کتاب سره
              // وتړل شي، په هره ازموینه کې غلطه ده — نو هغه ځای
              // ټاکل کېږي چې ریښتیا پکې معنا لري: **د ازموینې
              // تنظیمات**، د هرې ازموینې لپاره جلا.
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
