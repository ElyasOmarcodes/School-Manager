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

/// د ټولګیو او بخشونو اداره.
///
/// **دوه بڼې لري، او دا اتفاقي نه ده.** یو مکتب دوولس ټولګي لري چې
/// هر یو څو بخشونه لري — هلته «هر ټولګی یو کتار» سم دی، ځکه چې د
/// یوه ټولګي بخشونه سره پرتله کېږي. یوه مدرسه درې‌ولس درجې لري چې
/// هره یوه یو بخش لري — هلته د کتارونو بڼه یوه اوږده تشه پاڼه جوړوي.
/// نو مدرسه ګریډ ته ځي، مکتب کتارونو ته، او دواړه بدلېدی شي.
class ClassesPage extends StatefulWidget {
  final AcademicRepository academic;
  final TeacherRepository teachers;
  final bool canEdit;

  const ClassesPage({
    super.key,
    required this.academic,
    required this.teachers,
    this.canEdit = true,
  });

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  List<GradeWithSections> _grades = const [];
  List<Teacher> _teacherList = const [];
  Map<int, int?> _homeroom = {};
  bool _loading = true;
  bool _madrasa = false;
  String _yearLabel = '';
  String _view = 'rows';
  int _defaultCapacity = 40;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final year = await widget.academic.currentYear();
    final grades = await widget.academic.gradesWithSections();
    final teachers = await widget.teachers.activeTeachers();
    final school = await widget.academic.school();

    final rows = await widget.academic.db
        .select(widget.academic.db.sections)
        .get();

    if (!mounted) return;
    setState(() {
      _yearLabel = year?.label ?? '';
      _grades = grades;
      _teacherList = teachers;
      _homeroom = {for (final r in rows) r.id: r.headTeacherId};
      _madrasa = school?.kind == 'madrasa' || school?.kind == 'both';
      _view = school?.classesView ?? (_madrasa ? 'grid' : 'rows');
      _defaultCapacity = school?.defaultCapacity ?? 40;
      _loading = false;
    });
  }

  Future<void> _assign(int sectionId, int? teacherId) async {
    await widget.teachers.assignHomeroom(
      sectionId: sectionId,
      teacherId: teacherId,
    );
    setState(() => _homeroom[sectionId] = teacherId);
  }

  Future<void> _setView(String v) async {
    setState(() => _view = v);
    await widget.academic.setClassesView(v);
  }

  void _toast(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: color,
        content: Text(text),
      ),
    );
  }

  Future<void> _addGrade() async {
    final r = await showDialog<_GradeDraft>(
      context: context,
      builder: (_) => _GradeDialog(
        madrasa: _madrasa,
        initialCapacity: _defaultCapacity,
        teachers: _teacherList,
      ),
    );
    if (r == null) return;

    final gradeId = await widget.academic.addGrade(name: r.name);

    // **یو ټولګی پرته له بخشه بې‌ګټې دی** — هېڅ شاګرد پکې نه
    // ثبتېږي. نو لږ تر لږه یو جوړېږي؛ که کارن اجزا نه وي غوښتي،
    // هغه یو **بې‌نومه** دی، یعنې «ټوله درجه».
    if (r.parts.isEmpty) {
      await widget.academic.addSection(
        gradeId: gradeId,
        name: '',
        capacity: r.capacity,
        headTeacherId: r.headTeacherId,
      );
    } else {
      for (final part in r.parts) {
        await widget.academic.addSection(
          gradeId: gradeId,
          name: part,
          capacity: r.capacity,
          headTeacherId: r.headTeacherId,
        );
      }
    }
    await _load();
  }

  /// **د ټولګي/درجې بشپړ سمون — نه یوازې نوم.**
  ///
  /// مخکې يې یوازې نوم غوښت. خو کله چې یو ټولګی جوړ شي، هغه درې
  /// پرېکړې لري: نوم، ظرفیت او اجزا. که یوازې نوم د سمون وړ و،
  /// نورې دوه به یوازې د جوړولو پر مهال یو ځل ټاکل کېدې — او یو
  /// غلط ظرفیت به تل غلط پاتې و.
  Future<void> _editGrade(GradeWithSections g) async {
    final current = g.sections.isEmpty ? null : g.sections.first;
    final r = await showDialog<_GradeDraft>(
      context: context,
      builder: (_) => _GradeDialog(
        madrasa: _madrasa,
        initialCapacity: current?.capacity ?? _defaultCapacity,
        teachers: _teacherList,
        existing: g,
      ),
    );
    if (r == null) return;

    if (r.name != g.grade.name) {
      await widget.academic.renameGrade(g.grade.id, r.name);
    }

    // ظرفیت او سرپرست پر ټولو اجزاوو پلې کېږي.
    for (final sec in g.sections) {
      await widget.academic.updateSection(
        id: sec.sectionId,
        capacity: r.capacity,
        headTeacherId: r.headTeacherId,
        clearHeadTeacher: r.headTeacherId == null,
      );
    }

    // **د اجزاوو شمېر بدلون.** یوازې زیاتول کېږي؛ کمول به هغه
    // اجزا ړنګولې چې شاګردان پکې دي — او هغه پرېکړه باید په
    // څرګنده وشي، نه د یوې شمېرې د بدلولو په څنګ کې.
    final want = r.parts;
    if (want.isNotEmpty) {
      final have = {
        for (final x in g.sections) x.isWhole ? 'الف' : x.sectionName,
      };
      for (final part in want) {
        if (have.contains(part)) continue;
        await widget.academic.addSection(
          gradeId: g.grade.id,
          name: part,
          capacity: r.capacity,
          headTeacherId: r.headTeacherId,
        );
      }
    }
    await _load();
  }

  Future<void> _deleteGrade(GradeWithSections g) async {
    final ok = await _confirm(
      context,
      title: '«${g.grade.name}» ړنګ شي؟',
      body: 'د دې ټولګي ټول بخشونه هم ړنګېږي. که پکې شاګردان وي، '
          'ړنګېدی نه شي.',
    );
    if (ok != true) return;
    final err = await widget.academic.deleteGrade(g.grade.id);
    if (!mounted) return;
    if (err != null) {
      _toast(err, AppColors.warning);
      return;
    }
    await _load();
  }

  Future<void> _addSection(GradeWithSections g) async {
    // راتلونکی نوم پخپله وړاندیزېږي — الف، ب، ج…
    const alphabet = ['الف', 'ب', 'ج', 'د', 'هـ', 'و', 'ز'];

    // د بې‌نومه جز نومول پخپله په ذخیره کې کېږي — دلته يې یوازې
    // د نوم د وړاندیز لپاره حساب کوو.
    final used = {
      for (final x in g.sections) x.isWhole ? 'الف' : x.sectionName,
    };
    final next = alphabet.firstWhere(
      (a) => !used.contains(a),
      orElse: () => '${g.sections.length + 1}',
    );

    final result = await showDialog<({String name, int capacity})>(
      context: context,
      builder: (_) => _SectionDialog(
        title: 'نوی جز — ${g.grade.name}',
        initialName: next,
        initialCapacity: _defaultCapacity,
      ),
    );
    if (result == null) return;
    await widget.academic.addSection(
      gradeId: g.grade.id,
      name: result.name,
      capacity: result.capacity,
    );
    await _load();
  }

  Future<void> _editSection(SectionOption s) async {
    final result = await showDialog<({String name, int capacity})>(
      context: context,
      builder: (_) => _SectionDialog(
        title: 'د جز سمون — ${s.label}',
        initialName: s.sectionName,
        initialCapacity: s.capacity,
        minCapacity: s.enrolledCount,
      ),
    );
    if (result == null) return;
    await widget.academic.updateSection(
      id: s.sectionId,
      name: result.name,
      capacity: result.capacity,
    );
    await _load();
  }

  Future<void> _deleteSection(SectionOption s) async {
    final ok = await _confirm(
      context,
      title: '«${s.label}» ړنګ شي؟',
      body: 'که پکې شاګردان وي، ړنګېدی نه شي.',
    );
    if (ok != true) return;
    final err = await widget.academic.deleteSection(s.sectionId);
    if (!mounted) return;
    if (err != null) {
      _toast(err, AppColors.warning);
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

    final allSections = [for (final g in _grades) ...g.sections];
    final totalSeats = allSections.fold<int>(0, (a, x) => a + x.capacity);
    final taken = allSections.fold<int>(0, (a, x) => a + x.enrolledCount);

    return Column(
      children: [
        // ── پورتنۍ کرښه ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: Row(
            children: [
              Text(
                'د زده‌کړې کال ${locale.num(_yearLabel)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 12),
              Pill(
                icon: Icons.meeting_room_rounded,
                color: AppColors.modClasses,
                text: _madrasa
                    ? '${locale.num(_grades.length)} درجې'
                    : '${locale.num(allSections.length)} بخشونه',
              ),
              const SizedBox(width: 8),
              Pill(
                icon: Icons.event_seat_rounded,
                color: taken >= totalSeats
                    ? AppColors.danger
                    : AppColors.success,
                text:
                    '${locale.num(taken)} له ${locale.num(totalSeats)} ځایونو',
              ),
              const Spacer(),
              SegmentedChoice<String>(
                value: _view,
                color: AppColors.modClasses,
                options: [
                  (
                    value: 'rows',
                    label: s.viewRows,
                    icon: Icons.view_agenda_rounded,
                  ),
                  (
                    value: 'grid',
                    label: s.viewGrid,
                    icon: Icons.grid_view_rounded,
                  ),
                ],
                onChanged: _setView,
              ),
              if (widget.canEdit) ...[
                const SizedBox(width: 10),
                // **«تلواله ظرفیت» تڼۍ لرې شوه.** ظرفیت هغه ځای
                // ټاکل کېږي چې ټولګی پکې جوړېږي — یو پټ عمومي
                // تنظیم چې بل ځای اغېز کوي، تل حیرانوونکی و.
                FilledButton.icon(
                  onPressed: _addGrade,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: Text(_madrasa ? 'نوې درجه' : 'نوی ټولګی'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modClasses,
                  ),
                ),
              ],
            ],
          ),
        ),

        Expanded(
          child: _grades.isEmpty
              ? EmptyState(
                  icon: Icons.meeting_room_rounded,
                  text: 'لا هېڅ ټولګی نه دی جوړ شوی.',
                  action: widget.canEdit
                      ? FilledButton.icon(
                          onPressed: _addGrade,
                          icon: const Icon(Icons.add_rounded, size: 17),
                          label: Text(_madrasa ? 'نوې درجه' : 'نوی ټولګی'),
                        )
                      : null,
                )
              // **`AnimatedSwitcher` دلته د ښکلا لپاره نه دی.** د بڼې
              // بدلون د ټولې پاڼې جوړښت بدلوي؛ پرته له نرم تېرېدو،
              // سترګه به ورک شوې وه چې څه پیښ شول.
              : AnimatedSwitcher(
                  duration: AppMotion.normal,
                  switchInCurve: AppMotion.standard,
                  child: _view == 'grid'
                      ? _GridView(
                          key: const ValueKey('grid'),
                          grades: _grades,
                          locale: locale,
                          madrasa: _madrasa,
                          canEdit: widget.canEdit,
                          onRename: _editGrade,
                          onDeleteGrade: _deleteGrade,
                          onAddSection: _addSection,
                          onEditSection: _editSection,
                        )
                      : _RowsView(
                          key: const ValueKey('rows'),
                          grades: _grades,
                          locale: locale,
                          teachers: _teacherList,
                          homeroom: _homeroom,
                          canEdit: widget.canEdit,
                          onAssign: _assign,
                          onRename: _editGrade,
                          onDeleteGrade: _deleteGrade,
                          onAddSection: _addSection,
                          onEditSection: _editSection,
                          onDeleteSection: _deleteSection,
                        ),
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  کتاري بڼه — هر ټولګی یو کتار، هر بخش یو کارت
// ═══════════════════════════════════════════════════════════

class _RowsView extends StatelessWidget {
  final List<GradeWithSections> grades;
  final AppLocale locale;
  final List<Teacher> teachers;
  final Map<int, int?> homeroom;
  final bool canEdit;
  final void Function(int, int?) onAssign;
  final ValueChanged<GradeWithSections> onRename;
  final ValueChanged<GradeWithSections> onDeleteGrade;
  final ValueChanged<GradeWithSections> onAddSection;
  final ValueChanged<SectionOption> onEditSection;
  final ValueChanged<SectionOption> onDeleteSection;

  const _RowsView({
    super.key,
    required this.grades,
    required this.locale,
    required this.teachers,
    required this.homeroom,
    required this.canEdit,
    required this.onAssign,
    required this.onRename,
    required this.onDeleteGrade,
    required this.onAddSection,
    required this.onEditSection,
    required this.onDeleteSection,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
      children: [
        for (var i = 0; i < grades.length; i++)
          FadeSlideIn.staggered(
            index: i,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        grades[i].grade.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${locale.num(grades[i].enrolled)} / '
                        '${locale.num(grades[i].capacity)}',
                        style: AppTheme.tabular(
                          TextStyle(fontSize: 11.5, color: p.faint),
                        ),
                      ),
                      if (canEdit) ...[
                        const SizedBox(width: 4),
                        _MiniButton(
                          icon: Icons.edit_rounded,
                          tooltip: 'نوم بدلول',
                          onTap: () => onRename(grades[i]),
                        ),
                        _MiniButton(
                          icon: Icons.add_rounded,
                          tooltip: 'نوی بخش',
                          onTap: () => onAddSection(grades[i]),
                        ),
                        _MiniButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'ړنګول',
                          color: AppColors.danger,
                          onTap: () => onDeleteGrade(grades[i]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (grades[i].sections.isEmpty)
                    Text(
                      'بخش نشته.',
                      style: TextStyle(fontSize: 12, color: p.faint),
                    )
                  else
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final sec in grades[i].sections)
                          _SectionCard(
                            option: sec,
                            locale: locale,
                            teachers: teachers,
                            headTeacherId: homeroom[sec.sectionId],
                            canEdit: canEdit,
                            onAssign: (id) => onAssign(sec.sectionId, id),
                            onEdit: () => onEditSection(sec),
                            onDelete: () => onDeleteSection(sec),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ګریډ بڼه — څو ټولګي په یوه کتار کې
// ═══════════════════════════════════════════════════════════

class _GridView extends StatelessWidget {
  final List<GradeWithSections> grades;
  final AppLocale locale;
  final bool madrasa;
  final bool canEdit;
  final ValueChanged<GradeWithSections> onRename;
  final ValueChanged<GradeWithSections> onDeleteGrade;
  final ValueChanged<GradeWithSections> onAddSection;
  final ValueChanged<SectionOption> onEditSection;

  const _GridView({
    super.key,
    required this.grades,
    required this.locale,
    required this.madrasa,
    required this.canEdit,
    required this.onRename,
    required this.onDeleteGrade,
    required this.onAddSection,
    required this.onEditSection,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 30),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 250,
        mainAxisExtent: 152,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: grades.length,
      itemBuilder: (context, i) => FadeSlideIn.staggered(
        index: i,
        child: _GradeTile(
          data: grades[i],
          locale: locale,
          madrasa: madrasa,
          canEdit: canEdit,
          onRename: () => onRename(grades[i]),
          onDelete: () => onDeleteGrade(grades[i]),
          onAddSection: () => onAddSection(grades[i]),
          onEditSection: onEditSection,
        ),
      ),
    );
  }
}

class _GradeTile extends StatefulWidget {
  final GradeWithSections data;
  final AppLocale locale;
  final bool madrasa;
  final bool canEdit;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onAddSection;
  final ValueChanged<SectionOption> onEditSection;

  const _GradeTile({
    required this.data,
    required this.locale,
    required this.madrasa,
    required this.canEdit,
    required this.onRename,
    required this.onDelete,
    required this.onAddSection,
    required this.onEditSection,
  });

  @override
  State<_GradeTile> createState() => _GradeTileState();
}

class _GradeTileState extends State<_GradeTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final d = widget.data;
    final ratio = d.capacity == 0 ? 0.0 : d.enrolled / d.capacity;
    final color = ratio >= 1
        ? AppColors.danger
        : ratio >= 0.85
        ? AppColors.warning
        : AppColors.success;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: _hover ? color : p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.modClasses.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    widget.locale.num(d.grade.level),
                    style: AppTheme.tabular(
                      const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.modClasses,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    d.grade.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),

            // بخشونه — د یوه نظر لپاره وړې نښې.
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                // **یوه بشپړه درجه د «جز» نښه نه ښیي.**
                //
                // یوه نښه چې تل یوازې یوه وي، څه نه وايي — یوازې
                // پوښتنه راولي: «دا جز څه دی؟». نو کله چې درجه
                // نه وي وېشل شوې، یوازې د «+» تڼۍ پاتې کېږي.
                for (final sec in d.sections)
                  if (!(d.sections.length == 1 && sec.isWhole))
                  Tooltip(
                    message:
                        '${sec.partLabel} — '
                        '${widget.locale.num(sec.enrolledCount)}/'
                        '${widget.locale.num(sec.capacity)}',
                    child: GestureDetector(
                      onTap: widget.canEdit
                          ? () => widget.onEditSection(sec)
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: sec.isFull
                              ? AppColors.danger.withValues(alpha: 0.12)
                              : p.surfaceAlt,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          sec.partLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: sec.isFull ? AppColors.danger : p.muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                if (widget.canEdit)
                  GestureDetector(
                    onTap: widget.onAddSection,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: p.line),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        size: 13,
                        color: p.faint,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Text(
                  '${widget.locale.num(d.enrolled)} / '
                  '${widget.locale.num(d.capacity)}',
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const Spacer(),
                if (widget.canEdit)
                  AnimatedOpacity(
                    duration: AppMotion.fast,
                    opacity: _hover ? 1 : 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniButton(
                          icon: Icons.edit_rounded,
                          tooltip: 'نوم بدلول',
                          onTap: widget.onRename,
                        ),
                        _MiniButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'ړنګول',
                          color: AppColors.danger,
                          onTap: widget.onDelete,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                duration: AppMotion.slow,
                curve: AppMotion.emphasized,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 5,
                  backgroundColor: p.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ګډ ټوټې
// ═══════════════════════════════════════════════════════════

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color? color;
  final VoidCallback onTap;

  const _MiniButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 15, color: color ?? p.faint),
        ),
      ),
    );
  }
}

class _SectionCard extends StatefulWidget {
  final SectionOption option;
  final AppLocale locale;
  final List<Teacher> teachers;
  final int? headTeacherId;
  final bool canEdit;
  final ValueChanged<int?> onAssign;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SectionCard({
    required this.option,
    required this.locale,
    required this.teachers,
    required this.headTeacherId,
    required this.canEdit,
    required this.onAssign,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_SectionCard> createState() => _SectionCardState();
}

class _SectionCardState extends State<_SectionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final option = widget.option;
    final locale = widget.locale;
    final ratio = option.capacity == 0
        ? 0.0
        : option.enrolledCount / option.capacity;
    final color = ratio >= 1
        ? AppColors.danger
        : ratio >= 0.85
        ? AppColors.warning
        : AppColors.success;

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        width: 268,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: AppColors.modClasses.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    option.partLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.modClasses,
                    ),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                ),
                if (widget.canEdit)
                  AnimatedOpacity(
                    duration: AppMotion.fast,
                    opacity: _hover ? 1 : 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MiniButton(
                          icon: Icons.edit_rounded,
                          tooltip: 'سمون',
                          onTap: widget.onEdit,
                        ),
                        _MiniButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'ړنګول',
                          color: AppColors.danger,
                          onTap: widget.onDelete,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Text(
                  '${locale.num(option.enrolledCount)} / '
                  '${locale.num(option.capacity)}',
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  option.isFull ? 'ډک' : '${locale.num(option.freeSeats)} خالي',
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                duration: AppMotion.slow,
                curve: AppMotion.emphasized,
                builder: (context, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  backgroundColor: p.surfaceAlt,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<int?>(
              initialValue: widget.headTeacherId,
              isExpanded: true,
              isDense: true,
              decoration: const InputDecoration(
                labelText: 'مشر استاد',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('نه دی ټاکل شوی'),
                ),
                for (final t in widget.teachers)
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(t.fullName, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: widget.canEdit ? widget.onAssign : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ډیالوګونه
// ═══════════════════════════════════════════════════════════

/// د یوه نوي ټولګي/درجې مسوده.
class _GradeDraft {
  final String name;
  final int capacity;

  /// تش = یو بې‌نومه جز، یعنې ټوله درجه یوه ده.
  final List<String> parts;

  /// اختیاري — د ټولګي سرپرست استاد.
  final int? headTeacherId;

  const _GradeDraft({
    required this.name,
    required this.capacity,
    required this.parts,
    this.headTeacherId,
  });
}

/// **د نوي ټولګي/درجې ډیالوګ — نوم، ظرفیت او اجزا، ټول یو ځای.**
///
/// مخکې يې یوازې نوم غوښت او بیا يې پخپله یو «الف» بخش جوړاوه. دا
/// دوه ستونزې لرلې: مدرسې «الف» نه غواړي، او ظرفیت به يې له یوه پټ
/// عمومي تنظیمه اخیست چې کارن يې نه لیده. اوس درې واړه پرېکړې
/// همدلته دي، چېرې چې جوړېږي.
class _GradeDialog extends StatefulWidget {
  final bool madrasa;
  final int initialCapacity;
  final List<Teacher> teachers;

  /// که ورکړل شي، ډیالوګ د سمون بڼه اخلي.
  final GradeWithSections? existing;

  const _GradeDialog({
    required this.madrasa,
    required this.initialCapacity,
    this.teachers = const [],
    this.existing,
  });

  @override
  State<_GradeDialog> createState() => _GradeDialogState();
}

class _GradeDialogState extends State<_GradeDialog> {
  static const _alphabet = ['الف', 'ب', 'ج', 'د', 'هـ', 'و'];

  late final _name = TextEditingController(
    text: widget.existing?.grade.name ?? '',
  );
  late final _cap = TextEditingController(text: '${widget.initialCapacity}');

  late bool _split = (widget.existing?.sections.length ?? 0) > 1;
  late int _partCount = (widget.existing?.sections.length ?? 2).clamp(2, 6);
  int? _headTeacherId;
  String? _error;

  @override
  void initState() {
    super.initState();
    final secs = widget.existing?.sections ?? const [];
    for (final x in secs) {
      final id = x.headTeacherId;
      if (id != null) {
        _headTeacherId = id;
        break;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _cap.dispose();
    super.dispose();
  }

  List<String> get _parts =>
      _split ? _alphabet.take(_partCount).toList() : const [];

  void _submit() {
    final name = _name.text.trim();
    final cap = int.tryParse(Numerals.toLatin(_cap.text)) ?? 0;
    if (name.isEmpty) {
      setState(() => _error = 'نوم اړین دی.');
      return;
    }
    if (cap <= 0) {
      setState(() => _error = 'ظرفیت باید له صفره لوړ وي.');
      return;
    }
    Navigator.pop(
      context,
      _GradeDraft(
        name: name,
        capacity: cap,
        parts: _parts,
        headTeacherId: _headTeacherId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final unit = widget.madrasa ? 'درجه' : 'ټولګی';

    return AlertDialog(
      title: Text(
        widget.existing != null
            ? 'د $unit سمون'
            : (widget.madrasa ? 'نوې درجه' : 'نوی ټولګی'),
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'د $unit نوم',
                hintText: widget.madrasa ? 'درجه اولی' : 'اووم',
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _cap,
              decoration: InputDecoration(
                labelText: '${s.capacity} (د هر جز)',
                isDense: true,
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
            if (widget.teachers.isNotEmpty) ...[
              const SizedBox(height: 14),
              DropdownButtonFormField<int?>(
                initialValue: _headTeacherId,
                isExpanded: true,
                isDense: true,
                decoration: const InputDecoration(
                  labelText: 'سرپرست استاد (اختیاري)',
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
                onChanged: (v) => setState(() => _headTeacherId = v),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              'اجزا',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: p.muted,
              ),
            ),
            const SizedBox(height: 7),
            SegmentedChoice<bool>(
              value: _split,
              color: AppColors.modClasses,
              options: [
                (
                  value: false,
                  label: 'یو $unit',
                  icon: Icons.crop_square_rounded,
                ),
                (
                  value: true,
                  label: 'په اجزاوو ووېشه',
                  icon: Icons.grid_view_rounded,
                ),
              ],
              onChanged: (v) => setState(() => _split = v),
            ),
            AnimatedSize(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              alignment: Alignment.topCenter,
              child: !_split
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Row(
                        children: [
                          Text(
                            'څو اجزا؟',
                            style: TextStyle(fontSize: 12.5, color: p.inkSoft),
                          ),
                          const SizedBox(width: 12),
                          for (var n = 2; n <= 6; n++) ...[
                            _PartChip(
                              label: locale.num(n),
                              selected: _partCount == n,
                              onTap: () => setState(() => _partCount = n),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Text(
              _parts.isEmpty
                  ? 'یوه بشپړه $unit — بې اجزاوو.'
                  : (widget.existing == null
                        ? 'جوړېږي: ${_parts.join('، ')}'
                        : 'اجزا: ${_parts.join('، ')} — نوي يې '
                              'زیاتېږي، زاړه نه ړنګېږي.'),
              style: TextStyle(fontSize: 11.5, color: p.muted),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(s.save)),
      ],
    );
  }
}

class _PartChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PartChip({
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
        width: 34,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modClasses
              : p.surfaceAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: selected ? AppColors.modClasses : p.line),
        ),
        child: Text(
          label,
          style: AppTheme.tabular(
            TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : p.inkSoft,
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionDialog extends StatefulWidget {
  final String title;
  final String initialName;
  final int initialCapacity;
  final int minCapacity;

  const _SectionDialog({
    required this.title,
    required this.initialName,
    required this.initialCapacity,
    this.minCapacity = 0,
  });

  @override
  State<_SectionDialog> createState() => _SectionDialogState();
}

class _SectionDialogState extends State<_SectionDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _cap = TextEditingController(text: '${widget.initialCapacity}');
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _cap.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    final cap = int.tryParse(Numerals.toLatin(_cap.text)) ?? 0;
    if (name.isEmpty) {
      setState(() => _error = 'نوم اړین دی.');
      return;
    }
    // **ظرفیت له اوسنیو شاګردانو کم نه شي.** که شوی وای، بخش به
    // سمدستي «ډک څخه ډېر» شوی و او د داخلې ویزارډ به يې پټ کړ.
    if (cap < widget.minCapacity) {
      setState(
        () => _error =
            'ظرفیت له اوسنیو ${widget.minCapacity} شاګردانو کم نه شي.',
      );
      return;
    }
    Navigator.pop(context, (name: name, capacity: cap));
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'د جز نوم',
                isDense: true,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _cap,
              decoration: InputDecoration(
                labelText: s.capacity,
                isDense: true,
                errorText: _error,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(s.save)),
      ],
    );
  }
}

Future<bool?> _confirm(
  BuildContext context, {
  required String title,
  required String body,
}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      ),
      content: Text(body),
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
}
