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
import '../auth/auth_service.dart';

/// د نمرو د لیکلو پرده.
///
/// **دا پرده د یوه ټایپ کوونکي لپاره جوړه شوې، نه د یوه کلیک
/// کوونکي.** استاد څلوېښت نمرې لري چې ولیکي. نو:
///   • هره کرښه یوه خانه ده، Enter راتلونکې ته ټوپ وهي
///   • د موږک ته اړتیا نشته
///   • «غیرحاضر» یوه تڼۍ ده، نه یوه چک‌باکس چې لټول پکار وي
class MarkSheetView extends StatefulWidget {
  final ExamRepository exams;
  final Exam exam;
  final List<SectionOption> sections;
  final Session session;
  final VoidCallback onBack;

  const MarkSheetView({
    super.key,
    required this.exams,
    required this.exam,
    required this.sections,
    required this.session,
    required this.onBack,
  });

  @override
  State<MarkSheetView> createState() => _MarkSheetViewState();
}

class _MarkSheetViewState extends State<MarkSheetView> {
  SectionOption? _section;
  ExamSubjectRow? _subject;
  List<ExamSubjectRow> _subjects = const [];
  List<MarkEntry> _sheet = const [];

  final Map<int, TextEditingController> _controllers = {};
  final Map<int, FocusNode> _focus = {};
  final Set<int> _absent = {};

  bool _loading = true;
  bool _saving = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();
    _section = widget.sections.isEmpty ? null : widget.sections.first;
    _loadSubjects();
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

  Future<void> _loadSubjects() async {
    final s = _section;
    if (s == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() => _loading = true);

    final subjects = await widget.exams.subjectsOf(
      widget.exam.id,
      gradeId: s.gradeId,
    );
    if (!mounted) return;
    setState(() {
      _subjects = subjects;
      _subject = subjects.isEmpty ? null : subjects.first;
    });
    await _loadSheet();
  }

  Future<void> _loadSheet() async {
    final s = _section;
    final sub = _subject;
    if (s == null || sub == null) {
      setState(() {
        _sheet = const [];
        _loading = false;
      });
      return;
    }
    setState(() => _loading = true);

    final sheet = await widget.exams.markSheet(
      examSubjectId: sub.examSubject.id,
      sectionId: s.sectionId,
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

    for (final e in sheet) {
      _controllers[e.student.id] = TextEditingController(
        text: e.obtained == null ? '' : _fmt(e.obtained!),
      );
      _focus[e.student.id] = FocusNode();
      if (e.isAbsent) _absent.add(e.student.id);
    }

    setState(() {
      _sheet = sheet;
      _loading = false;
      _dirty = false;
    });
  }

  Future<void> _save() async {
    final sub = _subject;
    if (sub == null || _saving) return;
    setState(() => _saving = true);

    final data = <int, ({double? obtained, bool isAbsent})>{};
    for (final e in _sheet) {
      final id = e.student.id;
      final raw = _controllers[id]?.text.trim() ?? '';
      final absent = _absent.contains(id);
      // تش خانې هېڅ نه لیکي — استاد ښايي نیمه ورځ کار وکړي او
      // پاتې سبا. که تش صفر شو، هغه به يې ناکام ښودل.
      if (raw.isEmpty && !absent) continue;

      data[id] = (
        obtained: absent ? null : double.tryParse(Numerals.toLatin(raw)),
        isAbsent: absent,
      );
    }

    final n = await widget.exams.saveMarks(
      examSubjectId: sub.examSubject.id,
      byStudent: data,
      byUserId: widget.session.userId,
    );
    if (!mounted) return;
    setState(() {
      _saving = false;
      _dirty = false;
    });

    final locale = S.of(context).locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        backgroundColor: AppColors.success,
        content: Text('${locale.num(n)} نمرې وساتل شوې.'),
      ),
    );
    await _loadSheet();
  }

  void _focusNext(int index) {
    if (index + 1 < _sheet.length) {
      _focus[_sheet[index + 1].student.id]?.requestFocus();
    } else {
      FocusScope.of(context).unfocus();
    }
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final full = _subject?.examSubject.fullMark ?? 100;
    final filled = _controllers.values
        .where((c) => c.text.trim().isNotEmpty)
        .length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  tooltip: 'بېرته',
                ),
                const SizedBox(width: 6),
                Text(
                  widget.exam.name,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const Spacer(),
                Text(
                  '${locale.num(filled + _absent.length)} / '
                  '${locale.num(_sheet.length)} ډکې',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
                const SizedBox(width: 14),
                FilledButton.icon(
                  onPressed: _saving || _sheet.isEmpty ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.save_rounded, size: 17),
                  label: Text(_dirty ? 'وساتـه *' : 'وساتـه'),
                  style: FilledButton.styleFrom(
                    backgroundColor: _dirty
                        ? AppColors.modExams
                        : AppColors.success,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(height: 16),

          // ټولګی او مضمون.
          Row(
            children: [
              _Picker<SectionOption>(
                icon: Icons.meeting_room_rounded,
                color: AppColors.modClasses,
                label: _section?.label ?? 'ټولګی',
                items: widget.sections,
                labelOf: (s) => s.label,
                onPicked: (s) {
                  setState(() => _section = s);
                  _loadSubjects();
                },
              ),
              const SizedBox(width: 10),
              _Picker<ExamSubjectRow>(
                icon: Icons.menu_book_rounded,
                color: AppColors.modExams,
                label: _subject?.subjectName ?? 'مضمون',
                items: _subjects,
                labelOf: (s) => s.subjectName,
                onPicked: (s) {
                  setState(() => _subject = s);
                  _loadSheet();
                },
              ),
              const SizedBox(width: 14),
              if (_subject != null)
                Text(
                  'بشپړه: ${locale.num(full)}  •  '
                  'د کامیابۍ حد: '
                  '${locale.num(_subject!.examSubject.passMark)}',
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _subjects.isEmpty
                ? Center(
                    child: Text(
                      'دې ټولګي ته هېڅ مضمون نه دی ټاکل شوی.',
                      style: TextStyle(fontSize: 13, color: p.muted),
                    ),
                  )
                : _buildSheet(full),
          ),
        ],
      ),
    );
  }

  Widget _buildSheet(int full) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 42,
            color: p.surfaceAlt,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(
                    'ګ.نو',
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ),
                Expanded(
                  child: Text(
                    'شاګرد',
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ),
                SizedBox(
                  width: 130,
                  child: Text(
                    'نمره',
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ),
                SizedBox(
                  width: 110,
                  child: Text(
                    'غیرحاضر',
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _sheet.length,
              itemBuilder: (context, i) {
                final e = _sheet[i];
                final id = e.student.id;
                final absent = _absent.contains(id);

                return Container(
                  height: 52,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: i.isEven ? Colors.transparent : p.surfaceAlt,
                    border: Border(top: BorderSide(color: p.line)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 48,
                        child: Text(
                          e.rollNo == null ? '—' : locale.num(e.rollNo!),
                          style: AppTheme.tabular(
                            TextStyle(fontSize: 12.5, color: p.muted),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          [
                            e.student.firstName,
                            if (e.student.lastName?.isNotEmpty ?? false)
                              e.student.lastName,
                          ].join(' '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: absent ? p.faint : p.ink,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 130,
                        child: TextField(
                          controller: _controllers[id],
                          focusNode: _focus[id],
                          enabled: !absent,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          onChanged: (_) {
                            if (!_dirty) setState(() => _dirty = true);
                          },
                          onSubmitted: (_) => _focusNext(i),
                          inputFormatters: [
                            // ختیځې شمېرې هم منل کېږي — د ساتلو پر
                            // مهال لاتیني کېږي.
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9۰-۹.]'),
                            ),
                          ],
                          style: AppTheme.tabular(
                            const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: locale.num(full),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 9,
                              horizontal: 8,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 110,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: _AbsentToggle(
                            on: absent,
                            onTap: () => setState(() {
                              if (!_absent.remove(id)) {
                                _absent.add(id);
                                _controllers[id]?.clear();
                              }
                              _dirty = true;
                            }),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AbsentToggle extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;
  const _AbsentToggle({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.instant,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: on
              ? AppColors.danger.withValues(alpha: 0.13)
              : p.surfaceAlt,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: on ? AppColors.danger : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              on ? Icons.person_off_rounded : Icons.person_rounded,
              size: 14,
              color: on ? AppColors.danger : p.faint,
            ),
            const SizedBox(width: 7),
            Text(
              on ? 'غیرحاضر' : 'حاضر',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? AppColors.danger : p.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Picker<T> extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;

  const _Picker({
    required this.icon,
    required this.color,
    required this.label,
    required this.items,
    required this.labelOf,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<T>(
      tooltip: '',
      onSelected: onPicked,
      itemBuilder: (_) => [
        for (final i in items)
          PopupMenuItem(
            value: i,
            child: Text(labelOf(i), style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more_rounded, size: 16, color: p.muted),
          ],
        ),
      ),
    );
  }
}
