import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import '../auth/auth_service.dart';
import 'exam_filters.dart';

/// **د نمرو د ثبت پاڼه — یو مضمون، یو ټولګی، یو لیست.**
///
/// **د پخوانۍ پاڼې ستونزه:** استاد باید لومړی ازموینه غوره کړي، بیا
/// مضمون، بیا بخش، بیا یو ټب بدل کړي — څلور پرېکړې مخکې له دې چې
/// یوه نمره ولیکي. دلته دوه بس دي: ټولګی او مضمون. پاتې يې پخپله
/// راځي.
class MarkEntryPage extends StatefulWidget {
  final Exam exam;
  final ExamRepository exams;
  final AcademicRepository academic;
  final Session session;
  final VoidCallback onBack;
  final void Function(String csv, String name)? onExport;

  const MarkEntryPage({
    super.key,
    required this.exam,
    required this.exams,
    required this.academic,
    required this.session,
    required this.onBack,
    this.onExport,
  });

  @override
  State<MarkEntryPage> createState() => _MarkEntryPageState();
}

class _MarkEntryPageState extends State<MarkEntryPage> {
  List<Grade> _grades = const [];
  List<Subject> _subjects = const [];
  List<ExamSubjectRow> _examSubjects = const [];
  List<MarkEntry> _rows = const [];
  ExamSubject? _current;
  bool _madrasa = false;
  bool _loading = true;
  bool _saving = false;

  ResultFilter _filter = const ResultFilter();

  /// د هر شاګرد لیکل شوې نمره — تر ثبت مخکې دلته ساتل کېږي.
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, bool> _absent = {};
  final Map<int, FocusNode> _focus = {};

  bool get _dirty => _controllers.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focus.values) {
      f.dispose();
    }
    super.dispose();
  }

  Future<void> _boot() async {
    final grades = await widget.academic.grades();
    final madrasa = await widget.academic.isMadrasa();
    final examSubjects = await widget.exams.subjectsOf(widget.exam.id);

    if (!mounted) return;
    // **لومړی ټولګی او لومړی مضمون پخپله ټاکل کېږي.** یوه تشه پاڼه
    // چې «څه وټاکه» وايي، یو بې‌ګټې ګام دی — استاد تل له لومړي
    // ټولګي پیل کوي.
    final firstGrade = examSubjects.isEmpty
        ? grades.firstOrNull?.id
        : examSubjects.first.examSubject.gradeId;

    setState(() {
      _grades = grades;
      _madrasa = madrasa;
      _examSubjects = examSubjects;
      _filter = ResultFilter(gradeId: firstGrade);
    });
    await _loadSubjects();
  }

  /// د ټاکل شوي ټولګي هغه مضامین چې **په دې ازموینه کې دي**.
  ///
  /// نه ټول مضامین — که ټول ښودل کېدل، استاد به یو داسې مضمون ټاکه
  /// چې ازموینه يې نه لري او نمره به يې هېڅ ځای ته نه تله.
  Future<void> _loadSubjects() async {
    final gradeId = _filter.gradeId;
    if (gradeId == null) return;

    final ids = _examSubjects
        .where((e) => e.examSubject.gradeId == gradeId)
        .map((e) => e.examSubject.subjectId)
        .toSet();
    final all = await widget.academic.subjects(gradeId: gradeId);
    final mine = all.where((s) => ids.contains(s.id)).toList();

    if (!mounted) return;
    setState(() {
      _subjects = mine;
      _filter = _filter.copyWith(
        subjectId: mine.any((s) => s.id == _filter.subjectId)
            ? _filter.subjectId
            : mine.firstOrNull?.id,
      );
    });
    await _load();
  }

  Future<void> _load() async {
    final gradeId = _filter.gradeId;
    final subjectId = _filter.subjectId;
    if (gradeId == null || subjectId == null) {
      setState(() {
        _rows = const [];
        _current = null;
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);
    final es = await widget.exams.examSubjectFor(
      examId: widget.exam.id,
      gradeId: gradeId,
      subjectId: subjectId,
    );
    final rows = await widget.exams.markSheetForGrade(
      examId: widget.exam.id,
      gradeId: gradeId,
      subjectId: subjectId,
      query: _filter.query,
    );

    if (!mounted) return;
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final f in _focus.values) {
      f.dispose();
    }
    _controllers.clear();
    _focus.clear();
    _absent.clear();

    for (final r in rows) {
      _controllers[r.student.id] = TextEditingController(
        text: r.obtained == null
            ? ''
            : (r.obtained! == r.obtained!.roundToDouble()
                  ? r.obtained!.round().toString()
                  : r.obtained!.toString()),
      );
      _focus[r.student.id] = FocusNode();
      _absent[r.student.id] = r.isAbsent;
    }

    setState(() {
      _current = es;
      _rows = rows;
      _loading = false;
    });
  }

  Future<void> _save() async {
    final es = _current;
    if (es == null) return;
    setState(() => _saving = true);

    final payload = <int, ({double? obtained, bool isAbsent})>{};
    for (final r in _rows) {
      final text = Numerals.toLatin(_controllers[r.student.id]!.text.trim());
      final absent = _absent[r.student.id] ?? false;
      // تشې خانې نه ثبتېږي — «لا نه ده لیکل شوې» له «صفر» بېله ده.
      if (text.isEmpty && !absent) continue;
      payload[r.student.id] = (
        obtained: absent ? null : double.tryParse(text),
        isAbsent: absent,
      );
    }

    final n = await widget.exams.saveMarks(
      examSubjectId: es.id,
      byStudent: payload,
      byUserId: widget.session.userId,
    );

    if (!mounted) return;
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        backgroundColor: AppColors.success,
        content: Text('${S.of(context).locale.num(n)} نمرې ثبت شوې.'),
      ),
    );
    await _load();
  }

  void _exportCsv() {
    final locale = S.of(context).locale;
    final subject = _subjects
        .where((s) => s.id == _filter.subjectId)
        .firstOrNull;
    final csv = Csv.build(
      columns: const [
        'د حاضرۍ نمبر',
        'د داخلې نمبر',
        'نوم',
        'د پلار نوم',
        'نمره',
      ],
      rows: [
        for (final r in _rows)
          [
            r.rollNo?.toString() ?? '',
            r.student.admissionNo,
            [
              r.student.firstName,
              if (r.student.lastName?.isNotEmpty ?? false) r.student.lastName!,
            ].join(' '),
            r.student.fatherName,
            _absent[r.student.id] == true
                ? 'غیرحاضر'
                : _controllers[r.student.id]!.text,
          ],
      ],
    );
    widget.onExport?.call(
      csv,
      '${widget.exam.name}-${subject?.name ?? ''}.csv',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        content: Text('${locale.num(_rows.length)} کرښې اکسپورټ شوې.'),
      ),
    );
  }

  /// Enter → راتلونکې خانه. استاد لاس له کیبورډه نه اخلي.
  void _nextField(int index) {
    if (index + 1 >= _rows.length) return;
    _focus[_rows[index + 1].student.id]?.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final full = _current?.fullMark ?? 100;

    final written = _rows
        .where(
          (r) =>
              (_absent[r.student.id] ?? false) ||
              _controllers[r.student.id]!.text.trim().isNotEmpty,
        )
        .length;

    return Column(
      children: [
        // ── سرلیک ─────────────────────────────────────────
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
                    '${s.enterMarks}  ·  بشپړه نمره ${locale.num(full)}',
                    style: TextStyle(fontSize: 12, color: p.muted),
                  ),
                ],
              ),
              const Spacer(),
              Pill(
                color: written == _rows.length && _rows.isNotEmpty
                    ? AppColors.success
                    : AppColors.warning,
                icon: Icons.edit_note_rounded,
                text:
                    '${locale.num(written)} له ${locale.num(_rows.length)} لیکل شوې',
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saving || !_dirty ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded, size: 17),
                label: Text(s.save),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.modExams,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        ExamFilterBar(
          grades: _grades,
          subjects: _subjects,
          filter: _filter,
          madrasa: _madrasa,
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

        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _current == null
              ? EmptyState(
                  icon: Icons.assignment_rounded,
                  text: 'دې ټولګي ته په دې ازموینه کې مضمون نه دی ټاکل شوی.',
                  hint: 'له «${s.examSettings}» څخه يې زیات کړئ.',
                )
              : _rows.isEmpty
              ? const EmptyState(
                  icon: Icons.groups_rounded,
                  text: 'هېڅ شاګرد ونه موندل شو.',
                )
              : Column(
                  children: [
                    _HeaderRow(),
                    Divider(height: 1, color: p.line),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
                        itemCount: _rows.length,
                        itemBuilder: (context, i) => _MarkRow(
                          index: i,
                          entry: _rows[i],
                          fullMark: full,
                          controller: _controllers[_rows[i].student.id]!,
                          focus: _focus[_rows[i].student.id]!,
                          absent: _absent[_rows[i].student.id] ?? false,
                          onAbsent: (v) => setState(
                            () => _absent[_rows[i].student.id] = v,
                          ),
                          onSubmit: () => _nextField(i),
                          onChanged: () => setState(() {}),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final style = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.4,
      color: p.faint,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Row(
        children: [
          SizedBox(width: 44, child: Text('#', style: style)),
          Expanded(flex: 4, child: Text('نوم', style: style)),
          Expanded(flex: 2, child: Text('بخش · د داخلې نمبر', style: style)),
          SizedBox(width: 140, child: Text('نمره', style: style)),
          SizedBox(width: 110, child: Text('غیرحاضر', style: style)),
        ],
      ),
    );
  }
}

class _MarkRow extends StatelessWidget {
  final int index;
  final MarkEntry entry;
  final int fullMark;
  final TextEditingController controller;
  final FocusNode focus;
  final bool absent;
  final ValueChanged<bool> onAbsent;
  final VoidCallback onSubmit;
  final VoidCallback onChanged;

  const _MarkRow({
    required this.index,
    required this.entry,
    required this.fullMark,
    required this.controller,
    required this.focus,
    required this.absent,
    required this.onAbsent,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    final raw = double.tryParse(Numerals.toLatin(controller.text.trim()));
    // **د بشپړې نمرې تر پورته خبرداری همدلته ښکاري**، نه یوازې د
    // ثبت پر مهال. یو استاد چې «۹۵۰» ولیکي باید سمدستي وویني.
    final over = raw != null && raw > fullMark;
    final percent = raw == null || fullMark == 0 ? null : raw / fullMark * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            child: Text(
              locale.num(entry.rollNo ?? index + 1),
              style: AppTheme.tabular(
                TextStyle(fontSize: 11.5, color: p.faint),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  [
                    entry.student.firstName,
                    if (entry.student.lastName?.isNotEmpty ?? false)
                      entry.student.lastName,
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
                  'ولد ${entry.student.fatherName}',
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
              [
                if (entry.className != null) entry.className!,
                locale.num(entry.student.admissionNo),
              ].join('  ·  '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.tabular(
                TextStyle(fontSize: 11.5, color: p.muted),
              ),
            ),
          ),
          SizedBox(
            width: 140,
            child: TextField(
              controller: controller,
              focusNode: focus,
              enabled: !absent,
              textAlign: TextAlign.center,
              onChanged: (_) => onChanged(),
              onSubmitted: (_) => onSubmit(),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹.]')),
              ],
              decoration: InputDecoration(
                isDense: true,
                hintText: absent ? '—' : locale.num(fullMark),
                errorText: over ? 'له ${locale.num(fullMark)} ډېره' : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
              ),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: over
                      ? AppColors.danger
                      : (percent == null ? p.ink : markColor(percent)),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 110,
            child: Row(
              children: [
                Checkbox(
                  value: absent,
                  onChanged: (v) => onAbsent(v ?? false),
                  visualDensity: VisualDensity.compact,
                ),
                if (percent != null && !absent)
                  AnimatedOpacity(
                    duration: AppMotion.fast,
                    opacity: 1,
                    child: Text(
                      '${locale.num(percent.round())}٪',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: markColor(percent),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
