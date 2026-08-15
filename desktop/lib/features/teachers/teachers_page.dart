import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/typeahead_field.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/student_repository.dart' show Paged;
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/user_repository.dart' show Perm;
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';
import 'teacher_profile_page.dart' show teacherStatusColor, teacherStatusLabel;

/// د استادانو لیست — د شاګردانو له لیسته په جوړښت کې یو شان.
///
/// **ولې یو شان؟** ځکه چې مدیر ورځ لسګونه ځله له یوه لیسته بل ته
/// ځي. که د استادانو فلټرونه بل ځای کې وو یا بله بڼه يې لرله، هر
/// ځل به يې له سره لټول — او دا هغه ورو والی دی چې نه ښکاري خو
/// ورځ ډېر وخت وخوري.
class TeachersPage extends StatefulWidget {
  final TeacherRepository repo;
  final Session session;
  final AcademicRepository? academic;

  /// د یوه استاد پروفایل پرانیستل — که `null` وي، کرښه نه پرانیستل کېږي.
  final ValueChanged<int>? onOpenTeacher;

  const TeachersPage({
    super.key,
    required this.repo,
    required this.session,
    this.academic,
    this.onOpenTeacher,
  });

  @override
  State<TeachersPage> createState() => _TeachersPageState();
}

class _TeachersPageState extends State<TeachersPage> {
  static const int _pageSize = 50;

  final _search = TextEditingController();
  Timer? _debounce;

  TeacherFilter _filter = const TeacherFilter();
  int _offset = 0;
  bool _loading = true;
  bool _showFilters = false;
  Paged<TeacherRow> _page = const Paged([], 0);

  List<String> _specializations = const [];
  List<String> _qualifications = const [];
  List<Subject> _subjects = const [];

  bool get _canEdit => widget.session.permissions.can('teachers', Perm.edit);
  bool get _canDelete =>
      widget.session.permissions.can('teachers', Perm.delete);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final specs = await widget.repo.specializations();
    final quals = await widget.repo.qualifications();
    final subjects = await widget.academic?.subjects() ?? const <Subject>[];
    if (!mounted) return;
    setState(() {
      _specializations = specs;
      _qualifications = quals;
      _subjects = subjects;
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final page = await widget.repo.list(
      filter: _filter,
      limit: _pageSize,
      offset: _offset,
    );
    if (!mounted) return;
    setState(() {
      _page = page;
      _loading = false;
    });
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      _setFilter(_filter.copyWith(query: v));
    });
  }

  void _setFilter(TeacherFilter next) {
    setState(() {
      _filter = next;
      _offset = 0;
    });
    _load();
  }

  Future<void> _addTeacher() async {
    final employeeNo = await widget.repo.nextEmployeeNo();
    if (!mounted) return;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => TeacherFormDialog(
        employeeNo: employeeNo,
        onSave: (companion) async {
          await widget.repo.add(
            teacher: companion,
            byUserId: widget.session.userId,
            byUserName: widget.session.username,
          );
        },
      ),
    );

    if (created == true) {
      setState(() => _offset = 0);
      await _boot();
    }
  }

  Future<void> _editTeacher(Teacher t) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => TeacherFormDialog(
        employeeNo: t.employeeNo,
        existing: t,
        onSave: (companion) async {
          await widget.repo.update(
            id: t.id,
            patch: companion,
            byUserId: widget.session.userId,
            byUserName: widget.session.username,
          );
        },
      ),
    );
    if (saved == true) await _boot();
  }

  /// **ړنګول د تایید غوښتنه کوي، او وايي څه به پېښ شي.**
  ///
  /// یو استاد ښايي د دوو بخشونو مشر وي او په مهالویش کې ۲۴ ساعته
  /// ولري. که یوازې «ډاډه یاست؟» ښودل کېده، مدیر به نه پوهېده چې
  /// د «هو» له وهلو وروسته به هغه بخشونه بې‌مشره شي.
  Future<void> _deleteTeacher(TeacherRow row) async {
    final s = S.of(context);
    final t = row.teacher;

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${t.fullName} ړنګ کړم؟'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'استاد پټېږي — ریکارډ يې نه ورکېږي، نو پخوانی مهالویش '
              'او حاضري خوندي پاتې کېږي.',
            ),
            if (row.homeroomOf.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.report_problem_rounded,
                      size: 17,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'د «${row.homeroomOf}» مشري به بې‌خاونده شي.',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(s.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(s.delete),
          ),
        ],
      ),
    );

    if (ok != true) return;
    await widget.repo.softDelete(
      t.id,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    await _boot();
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                SizedBox(
                  width: 320,
                  child: TextField(
                    controller: _search,
                    onChanged: _onSearch,
                    decoration: const InputDecoration(
                      hintText: 'نوم، نمبر، تلیفون یا تخصص…',
                      prefixIcon: Icon(Icons.search_rounded, size: 19),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilterChipMenu(
                  label: 'ټول جنس',
                  options: const {'male': 'نارینه', 'female': 'ښځینه'},
                  value: _filter.gender,
                  onChanged: (v) => _setFilter(
                    v == null
                        ? _filter.copyWith(clearGender: true)
                        : _filter.copyWith(gender: v),
                  ),
                ),
                const SizedBox(width: 8),
                FilterChipMenu(
                  label: 'ټول حالتونه',
                  options: const {
                    'active': 'فعال',
                    'on_leave': 'په رخصتۍ',
                    'resigned': 'استعفا',
                    'terminated': 'ګوښه شوی',
                  },
                  // «فعال» تلواله ده، خو بیا هم په چیپ کې ښکاري — نو
                  // کارن پوهېږي چې ولې استعفا کړي نه ښکاري.
                  value: _filter.status,
                  onChanged: (v) => _setFilter(
                    v == null
                        ? _filter.copyWith(clearStatus: true)
                        : _filter.copyWith(status: v),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterToggle(
                  open: _showFilters,
                  count: _filter.activeCount,
                  onTap: () => setState(() => _showFilters = !_showFilters),
                ),
                const Spacer(),
                Text(
                  '${locale.grouped(_page.total)} ${s.teachers}',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: context.palette.muted,
                  ),
                ),
                const SizedBox(width: 14),
                FilledButton.icon(
                  onPressed: widget.session.permissions.can(
                        'teachers',
                        Perm.create,
                      )
                      ? _addTeacher
                      : null,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.person_add_rounded, size: 17),
                  label: const Text('نوی استاد'),
                ),
              ],
            ),
          ),

          AnimatedSize(
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: _showFilters
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _FilterPanel(
                      filter: _filter,
                      specializations: _specializations,
                      qualifications: _qualifications,
                      subjects: _subjects,
                      onChanged: _setFilter,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: DataTableView<TeacherRow>(
              loading: _loading,
              rows: _page.items,
              onRowTap: widget.onOpenTeacher == null
                  ? null
                  : (r) => widget.onOpenTeacher!(r.teacher.id),
              emptyIcon: Icons.person_rounded,
              emptyTitle: _filter.query.isEmpty && _filter.activeCount == 0
                  ? 'لا هېڅ استاد نه دی ثبت شوی'
                  : 'هېڅ پایله ونه موندل شوه',
              emptyHint: _filter.query.isEmpty && _filter.activeCount == 0
                  ? 'د «نوی استاد» تڼۍ ووهئ.'
                  : 'د لټون کلمه بدله کړئ یا فلټرونه لرې کړئ.',
              columns: [
                TableColumn(
                  title: 'نمبر',
                  width: 84,
                  cell: (context, r) => Text(
                    locale.num(r.teacher.employeeNo),
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12.5, color: context.palette.muted),
                    ),
                  ),
                ),
                TableColumn(
                  title: s.fullName,
                  flex: 3,
                  cell: (context, r) => Row(
                    children: [
                      AvatarCell(
                        name: r.teacher.fullName,
                        color: AppColors.modTeachers,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r.teacher.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            if (r.teacher.specialization != null)
                              Text(
                                r.teacher.specialization!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: context.palette.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TableColumn(
                  title: 'د ټولګي مشري',
                  flex: 2,
                  cell: (context, r) => Text(
                    r.homeroomOf.isEmpty ? '—' : r.homeroomOf,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.palette.inkSoft,
                    ),
                  ),
                ),
                TableColumn(
                  title: s.phone,
                  flex: 2,
                  cell: (context, r) => Text(
                    r.teacher.phone == null
                        ? '—'
                        : locale.num(r.teacher.phone!),
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12.5, color: context.palette.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'حالت',
                  width: 96,
                  cell: (context, r) => StatusChip(
                    label: teacherStatusLabel(r.teacher.status),
                    color: teacherStatusColor(r.teacher.status),
                  ),
                ),
                TableColumn(
                  title: '',
                  width: 128,
                  cell: (context, r) => _RowActions(
                    onOpen: widget.onOpenTeacher == null
                        ? null
                        : () => widget.onOpenTeacher!(r.teacher.id),
                    onEdit: _canEdit ? () => _editTeacher(r.teacher) : null,
                    onDelete: _canDelete ? () => _deleteTeacher(r) : null,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PagerBar(
            offset: _offset,
            limit: _pageSize,
            total: _page.total,
            onOffsetChanged: (v) {
              setState(() => _offset = v);
              _load();
            },
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د کرښې تڼۍ
// ═══════════════════════════════════════════════════════════

/// **درې تڼۍ چې یوازې د موږک تر لاندې ښکاري.**
///
/// که تل ښکاره وې، د ۵۰ کرښو جدول به ۱۵۰ تڼۍ لرلې — او د ړنګولو
/// تڼۍ به د سکرول پر مهال په تصادف کې کېښودل شوه.
class _RowActions extends StatefulWidget {
  final VoidCallback? onOpen;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _RowActions({this.onOpen, this.onEdit, this.onDelete});

  @override
  State<_RowActions> createState() => _RowActionsState();
}

class _RowActionsState extends State<_RowActions> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedOpacity(
        duration: AppMotion.fast,
        opacity: _hover ? 1 : 0.35,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (widget.onOpen != null)
              _MiniButton(
                icon: Icons.person_search_rounded,
                tooltip: 'پروفایل',
                color: AppColors.modTeachers,
                onTap: widget.onOpen!,
              ),
            if (widget.onEdit != null)
              _MiniButton(
                icon: Icons.edit_rounded,
                tooltip: s.edit,
                color: AppColors.primary,
                onTap: widget.onEdit!,
              ),
            if (widget.onDelete != null)
              _MiniButton(
                icon: Icons.delete_outline_rounded,
                tooltip: s.delete,
                color: AppColors.danger,
                onTap: widget.onDelete!,
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  const _MiniButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onTap,
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(5),
        constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
        icon: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د فلټرونو تخته
// ═══════════════════════════════════════════════════════════

class _FilterPanel extends StatelessWidget {
  final TeacherFilter filter;
  final List<String> specializations;
  final List<String> qualifications;
  final List<Subject> subjects;
  final ValueChanged<TeacherFilter> onChanged;

  const _FilterPanel({
    required this.filter,
    required this.specializations,
    required this.qualifications,
    required this.subjects,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Panel(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 190,
                child: TypeAheadField(
                  label: 'تخصص',
                  icon: Icons.psychology_rounded,
                  value: filter.specialization,
                  options: specializations,
                  onChanged: (v) => onChanged(
                    v == null
                        ? filter.copyWith(clearSpecialization: true)
                        : filter.copyWith(specialization: v),
                  ),
                ),
              ),
              SizedBox(
                width: 190,
                child: TypeAheadField(
                  label: 'تحصیل',
                  icon: Icons.school_rounded,
                  value: filter.qualification,
                  options: qualifications,
                  onChanged: (v) => onChanged(
                    v == null
                        ? filter.copyWith(clearQualification: true)
                        : filter.copyWith(qualification: v),
                  ),
                ),
              ),
              if (subjects.isNotEmpty)
                SizedBox(
                  width: 190,
                  child: DropdownButtonFormField<int?>(
                    initialValue: filter.subjectId,
                    isDense: true,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'مضمون ورکوي',
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: null, child: Text(s.all)),
                      for (final sub in subjects)
                        DropdownMenuItem(value: sub.id, child: Text(sub.name)),
                    ],
                    onChanged: (v) => onChanged(
                      v == null
                          ? filter.copyWith(clearSubject: true)
                          : filter.copyWith(subjectId: v),
                    ),
                  ),
                ),
              SegmentedChoice<bool?>(
                value: filter.homeroom,
                options: [
                  (value: null, label: s.all, icon: null),
                  (
                    value: true,
                    label: 'مشر استاد',
                    icon: Icons.meeting_room_rounded,
                  ),
                  (value: false, label: 'بې‌مشرۍ', icon: null),
                ],
                onChanged: (v) => onChanged(
                  v == null
                      ? filter.copyWith(clearHomeroom: true)
                      : filter.copyWith(homeroom: v),
                ),
              ),
              SegmentedChoice<String>(
                value: filter.sort,
                color: AppColors.modTeachers,
                options: const [
                  (value: 'name', label: 'په نوم', icon: null),
                  (value: 'salary', label: 'په معاش', icon: null),
                  (value: 'hired', label: 'د دندې پیل', icon: null),
                ],
                onChanged: (v) => onChanged(filter.copyWith(sort: v)),
              ),
              IconButton(
                tooltip: filter.descending ? 'له لوړ ښکته' : 'له ټیټ پورته',
                onPressed: () =>
                    onChanged(filter.copyWith(descending: !filter.descending)),
                icon: Icon(
                  filter.descending
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 18,
                ),
              ),
            ],
          ),
          if (filter.activeCount > 0) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  '${s.locale.num(filter.activeCount)} فلټرونه فعال دي',
                  style: TextStyle(fontSize: 12, color: p.muted),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => onChanged(
                    TeacherFilter(query: filter.query, sort: filter.sort),
                  ),
                  icon: const Icon(Icons.clear_all_rounded, size: 16),
                  label: Text(s.clearFilters),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _FilterToggle extends StatelessWidget {
  final bool open;
  final int count;
  final VoidCallback onTap;

  const _FilterToggle({
    required this.open,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final active = count > 0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: active || open
              ? AppColors.primary.withValues(alpha: 0.09)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: active || open
                ? AppColors.primary.withValues(alpha: 0.4)
                : p.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 16,
              color: active || open ? AppColors.primary : p.muted,
            ),
            const SizedBox(width: 6),
            Text(
              s.filters,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active || open ? AppColors.primary : p.inkSoft,
              ),
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  s.locale.num(count),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// د یوه فلټر چیپ چې منو پرانیزي — د شاګردانو له پاڼې سره یو شان.
class FilterChipMenu extends StatelessWidget {
  final String label;
  final Map<String, String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  const FilterChipMenu({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final active = value != null;

    return PopupMenuButton<String?>(
      tooltip: '',
      onSelected: onChanged,
      itemBuilder: (_) => [
        PopupMenuItem<String?>(value: null, child: Text(label)),
        const PopupMenuDivider(),
        for (final e in options.entries)
          PopupMenuItem<String?>(value: e.key, child: Text(e.value)),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
        decoration: BoxDecoration(
          color: active ? AppColors.primary.withValues(alpha: 0.09) : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: active ? AppColors.primary.withValues(alpha: 0.4) : p.line,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              active ? (options[value] ?? label) : label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: active ? AppColors.primary : p.inkSoft,
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.expand_more_rounded,
              size: 16,
              color: active ? AppColors.primary : p.muted,
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د استاد فورمه — نوی او سمون دواړه
// ═══════════════════════════════════════════════════════════

/// **یوه فورمه، دوه کارونه.**
///
/// د «نوي» او د «سمون» لپاره دوه جلا ډیالوګونه لیکل معنا دا ده چې
/// هر نوی ساحه دوه ځایه اضافه شي — او یو ځای به تل هېر شو.
class TeacherFormDialog extends StatefulWidget {
  final String employeeNo;
  final Teacher? existing;
  final Future<void> Function(TeachersCompanion) onSave;

  const TeacherFormDialog({
    super.key,
    required this.employeeNo,
    required this.onSave,
    this.existing,
  });

  @override
  State<TeacherFormDialog> createState() => _TeacherFormDialogState();
}

class _TeacherFormDialogState extends State<TeacherFormDialog> {
  late final _name = TextEditingController(text: widget.existing?.fullName);
  late final _father = TextEditingController(text: widget.existing?.fatherName);
  late final _phone = TextEditingController(text: widget.existing?.phone);
  late final _email = TextEditingController(text: widget.existing?.email);
  late final _address = TextEditingController(text: widget.existing?.address);
  late final _spec = TextEditingController(
    text: widget.existing?.specialization,
  );
  late final _qual = TextEditingController(
    text: widget.existing?.qualification,
  );
  late final _salary = TextEditingController(
    text: widget.existing?.monthlySalary?.toString(),
  );
  late String _gender = widget.existing?.gender ?? 'male';
  late String _status = widget.existing?.status ?? 'active';
  bool _saving = false;

  bool get _editing => widget.existing != null;

  @override
  void dispose() {
    for (final c in [
      _name,
      _father,
      _phone,
      _email,
      _address,
      _spec,
      _qual,
      _salary,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _trim(TextEditingController c) {
    final v = c.text.trim();
    return v.isEmpty ? null : v;
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // شمېرې تل لاتیني ساتو — معاش او تلیفون دواړه.
    final phone = Numerals.toLatin(_phone.text.trim());
    final salary = int.tryParse(Numerals.toLatin(_salary.text.trim()));

    if (_editing) {
      // **سمون کې `TeachersCompanion` کارېږي، نه `.insert`.** د
      // `insert` بڼه هره نه-ورکړل شوې ساحه اړینه ګڼي، نو د یوه
      // ساحې سمون به يې نور ټول له سره غوښتي وو.
      await widget.onSave(
        TeachersCompanion(
          fullName: Value(_name.text.trim()),
          fatherName: Value(_trim(_father)),
          gender: Value(_gender),
          phone: Value(phone.isEmpty ? null : phone),
          email: Value(_trim(_email)),
          address: Value(_trim(_address)),
          specialization: Value(_trim(_spec)),
          qualification: Value(_trim(_qual)),
          monthlySalary: Value(salary),
          status: Value(_status),
        ),
      );
    } else {
      await widget.onSave(
        TeachersCompanion.insert(
          employeeNo: widget.employeeNo,
          fullName: _name.text.trim(),
          fatherName: Value(_trim(_father)),
          gender: _gender,
          phone: Value(phone.isEmpty ? null : phone),
          email: Value(_trim(_email)),
          address: Value(_trim(_address)),
          specialization: Value(_trim(_spec)),
          qualification: Value(_trim(_qual)),
          monthlySalary: Value(salary),
          status: Value(_status),
          hiredOn: Value(DateTime.now()),
        ),
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final valid = _name.text.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Row(
        children: [
          Text(_editing ? 'د استاد سمون' : 'نوی استاد'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.modTeachers.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              locale.num(widget.employeeNo),
              style: AppTheme.tabular(
                const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.modTeachers,
                ),
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'بشپړ نوم *'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _father,
                      decoration: const InputDecoration(
                        labelText: 'د پلار نوم',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _gender,
                      decoration: const InputDecoration(labelText: 'جنس'),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('نارینه')),
                        DropdownMenuItem(value: 'female', child: Text('ښځینه')),
                      ],
                      onChanged: (v) => setState(() => _gender = v ?? 'male'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _phone,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(labelText: 'تلیفون'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _email,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'برېښنالیک',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _address,
                decoration: const InputDecoration(labelText: 'پته'),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _spec,
                      decoration: const InputDecoration(labelText: 'تخصص'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _qual,
                      decoration: const InputDecoration(labelText: 'تحصیل'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _salary,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'میاشتنی معاش',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _status,
                      decoration: const InputDecoration(labelText: 'حالت'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('فعال')),
                        DropdownMenuItem(
                          value: 'on_leave',
                          child: Text('په رخصتۍ'),
                        ),
                        DropdownMenuItem(
                          value: 'resigned',
                          child: Text('استعفا'),
                        ),
                        DropdownMenuItem(
                          value: 'terminated',
                          child: Text('ګوښه شوی'),
                        ),
                      ],
                      onChanged: (v) => setState(() => _status = v ?? 'active'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        OutlinedButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: Text(S.of(context).cancel),
        ),
        FilledButton(
          onPressed: !valid || _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(S.of(context).save),
        ),
      ],
    );
  }
}
