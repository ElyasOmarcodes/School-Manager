import 'package:flutter/material.dart';

import '../../core/data/afghanistan.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/typeahead_field.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/leave_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../auth/auth_service.dart';

/// «د اجازت نامې جوړول» — فردي یا ډله ایز.
///
/// **ولې دلته هم هماغه فلټرونه دي؟** ځکه چې د اجازې غوښتونکي یوه
/// ډله وي چې یو ګډ خاصیت لري: «د پکتیا شاګردان»، «د درجه ثالثه
/// لیلیه». که فلټر نه وای، مدیر به يې له اته سوو نومونو څخه یو یو
/// ټاکل — او دا هغه کار دی چې هېڅوک يې نه کوي.
class LeaveCreatePage extends StatefulWidget {
  final StudentRepository students;
  final AcademicRepository academic;
  final LeaveRepository leave;
  final Session session;
  final VoidCallback onDone;

  /// د ازموینې لپاره — چې «نن» ثابته وي.
  final DateTime Function() clock;

  const LeaveCreatePage({
    super.key,
    required this.students,
    required this.academic,
    required this.leave,
    required this.session,
    required this.onDone,
    this.clock = DateTime.now,
  });

  @override
  State<LeaveCreatePage> createState() => _LeaveCreatePageState();
}

class _LeaveCreatePageState extends State<LeaveCreatePage> {
  StudentFilter _filter = const StudentFilter();
  List<StudentRow> _rows = const [];
  List<Grade> _grades = const [];
  final Set<int> _selected = {};
  bool _loading = true;
  bool _saving = false;
  bool _madrasa = false;

  String _reasonType = 'family';
  final _reason = TextEditingController();
  late DateTime _from = widget.clock();
  late DateTime _to = widget.clock();

  /// **مدیر خپله جوړوي، نو خپله يې تصویبوي.** که «په تمه» پاتې وای،
  /// هغه به يې په بله پاڼه کې بیا منلو ته اړ و — یو بې‌ګټې دوهم ګام.
  bool _autoApprove = true;

  bool get _canApprove =>
      widget.session.permissions.can('leave', Perm.edit);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final page = await widget.students.list(filter: _filter, limit: 500);
    final grades = await widget.academic.grades();
    final madrasa = await widget.academic.isMadrasa();
    if (!mounted) return;
    setState(() {
      _rows = page.items;
      _grades = grades;
      _madrasa = madrasa;
      _loading = false;
    });
  }

  void _setFilter(StudentFilter f) {
    setState(() => _filter = f);
    _load();
  }

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
        // د پای نېټه له پیل څخه مخکې کېدی نه شي — که وه، اجازه به
        // صفر ورځې لرلې او د حاضرۍ سمون به هېڅ نه کاوه.
        if (_to.isBefore(_from)) _to = _from;
      } else {
        _to = picked.isBefore(_from) ? _from : picked;
      }
    });
  }

  Future<void> _save() async {
    if (_selected.isEmpty) return;
    setState(() => _saving = true);

    final n = await widget.leave.requestBulk(
      studentIds: _selected.toList(),
      reasonType: _reasonType,
      reasonText: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
      fromDate: _from,
      toDate: _to,
      requestedByUserId: widget.session.userId,
      byUserName: widget.session.username,
      autoApprove: _autoApprove && _canApprove,
      now: widget.clock(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: AppColors.success,
        content: Text(
          'د ${S.of(context).locale.num(n)} کسانو اجازه '
          '${_autoApprove && _canApprove ? 'جوړه او تصویب شوه' : 'ثبت شوه'}.',
        ),
      ),
    );
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final days = _to.difference(_from).inDays + 1;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── کیڼ: د شاګردانو ټاکنه ─────────────────────────
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _FilterBar(
                filter: _filter,
                grades: _grades,
                madrasa: _madrasa,
                onChanged: _setFilter,
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
                child: Row(
                  children: [
                    Checkbox(
                      value: _rows.isNotEmpty &&
                          _selected.length == _rows.length,
                      tristate: true,
                      onChanged: (v) => setState(() {
                        if (_selected.length == _rows.length) {
                          _selected.clear();
                        } else {
                          _selected
                            ..clear()
                            ..addAll(_rows.map((r) => r.student.id));
                        }
                      }),
                    ),
                    Text(
                      'ټول — ${locale.num(_rows.length)} کسان',
                      style: TextStyle(fontSize: 12.5, color: p.muted),
                    ),
                    const Spacer(),
                    if (_selected.isNotEmpty)
                      Pill(
                        color: AppColors.modLeave,
                        icon: Icons.check_circle_rounded,
                        text: '${locale.num(_selected.length)} ټاکل شوي',
                      ),
                  ],
                ),
              ),
              Divider(height: 1, color: p.line),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _rows.isEmpty
                    ? const EmptyState(
                        icon: Icons.person_search_rounded,
                        text: 'د دې فلټر سره هېڅ شاګرد ونه موندل شو.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
                        itemCount: _rows.length,
                        itemBuilder: (context, i) {
                          final r = _rows[i];
                          final on = _selected.contains(r.student.id);
                          return _StudentTile(
                            row: r,
                            selected: on,
                            onTap: () => setState(() {
                              if (on) {
                                _selected.remove(r.student.id);
                              } else {
                                _selected.add(r.student.id);
                              }
                            }),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),

        Container(width: 1, color: p.line),

        // ── ښي: د اجازې تفصیل ────────────────────────────
        SizedBox(
          width: 360,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                s.newLeave,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selected.length <= 1
                    ? 'یو کس ټاکل شوی — فردي اجازه.'
                    : '${locale.num(_selected.length)} کسان ټاکل شوي — '
                          'ډله ایزه اجازه.',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
              const SizedBox(height: 18),

              DropdownButtonFormField<String>(
                initialValue: _reasonType,
                isDense: true,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'د اجازې ډول',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: 'sick', child: Text('ناروغي')),
                  DropdownMenuItem(value: 'family', child: Text('کورنۍ چاره')),
                  DropdownMenuItem(value: 'travel', child: Text('سفر')),
                  DropdownMenuItem(value: 'official', child: Text('رسمي')),
                  DropdownMenuItem(value: 'other', child: Text('بل')),
                ],
                onChanged: (v) => setState(() => _reasonType = v ?? 'other'),
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _reason,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'تفصیل (اختیاري)',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _DateButton(
                      label: 'له',
                      date: _from,
                      onTap: () => _pickDate(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DateButton(
                      label: 'تر',
                      date: _to,
                      onTap: () => _pickDate(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Pill(
                  color: AppColors.modLeave,
                  icon: Icons.event_rounded,
                  text: '${locale.num(days)} ورځې',
                ),
              ),
              const SizedBox(height: 16),

              if (_canApprove)
                CheckboxListTile(
                  value: _autoApprove,
                  onChanged: (v) => setState(() => _autoApprove = v ?? false),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                    'سمدستي تصویب کړه',
                    style: TextStyle(fontSize: 13),
                  ),
                  subtitle: Text(
                    'د هغو ورځو غیرحاضري «رخصت» ته اوړي.',
                    style: TextStyle(fontSize: 11, color: p.faint),
                  ),
                ),

              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _selected.isEmpty || _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_rounded, size: 17),
                label: Text(
                  _selected.isEmpty
                      ? 'شاګردان وټاکئ'
                      : 'د ${locale.num(_selected.length)} کسانو اجازه جوړه کړه',
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.modLeave,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: widget.onDone,
                child: Text(s.cancel),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _FilterBar extends StatelessWidget {
  final StudentFilter filter;
  final List<Grade> grades;
  final bool madrasa;
  final ValueChanged<StudentFilter> onChanged;

  const _FilterBar({
    required this.filter,
    required this.grades,
    required this.madrasa,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
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
            width: 210,
            child: TextField(
              onChanged: (v) => onChanged(filter.copyWith(query: v)),
              decoration: InputDecoration(
                hintText: '${s.search}…',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
              ),
            ),
          ),
          if (grades.isNotEmpty)
            SizedBox(
              width: 180,
              child: DropdownButtonFormField<int?>(
                initialValue: filter.gradeId,
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
                onChanged: (v) => onChanged(
                  v == null
                      ? filter.copyWith(clearGrade: true)
                      : filter.copyWith(gradeId: v),
                ),
              ),
            ),
          SizedBox(
            width: 180,
            child: TypeAheadField(
              label: s.province,
              icon: Icons.map_rounded,
              value: filter.province,
              options: provinceNames,
              onChanged: (v) => onChanged(
                v == null
                    ? filter.copyWith(clearProvince: true)
                    : filter.copyWith(province: v, clearDistrict: true),
              ),
            ),
          ),
          SizedBox(
            width: 180,
            child: TypeAheadField(
              label: s.district,
              icon: Icons.place_rounded,
              enabled: filter.province != null,
              value: filter.district,
              options: districtsOf(filter.province),
              onChanged: (v) => onChanged(
                v == null
                    ? filter.copyWith(clearDistrict: true)
                    : filter.copyWith(district: v),
              ),
            ),
          ),
          SegmentedChoice<String?>(
            value: filter.residency,
            options: [
              (value: null, label: s.all, icon: null),
              (
                value: 'day',
                label: s.dayScholar,
                icon: Icons.wb_sunny_rounded,
              ),
              (
                value: 'boarding',
                label: s.boarder,
                icon: Icons.night_shelter_rounded,
              ),
            ],
            onChanged: (v) => onChanged(
              v == null
                  ? filter.copyWith(clearResidency: true)
                  : filter.copyWith(residency: v),
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentTile extends StatelessWidget {
  final StudentRow row;
  final bool selected;
  final VoidCallback onTap;

  const _StudentTile({
    required this.row,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modLeave.withValues(alpha: 0.09)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: selected
                ? AppColors.modLeave.withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Checkbox(
              value: selected,
              onChanged: (_) => onTap(),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    row.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    'ولد ${row.student.fatherName}  ·  ${row.className}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ],
              ),
            ),
            if (row.student.residency == 'boarding')
              const Padding(
                padding: EdgeInsetsDirectional.only(end: 8),
                child: Icon(
                  Icons.night_shelter_rounded,
                  size: 15,
                  color: AppColors.modHostel,
                ),
              ),
            Text(
              locale.num(row.student.admissionNo),
              style: AppTheme.tabular(
                TextStyle(fontSize: 11.5, color: p.faint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontSize: 10.5, color: p.faint)),
            const SizedBox(height: 2),
            Text(
              locale.num(
                '${date.year}-${date.month.toString().padLeft(2, '0')}'
                '-${date.day.toString().padLeft(2, '0')}',
              ),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 13,
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
