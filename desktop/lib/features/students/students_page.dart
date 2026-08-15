import 'dart:async';

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
import '../../data/repositories/student_repository.dart';
import '../../widgets/data_table_view.dart';

class StudentsPage extends StatefulWidget {
  final StudentRepository repo;
  final AcademicRepository? academic;
  final VoidCallback? onAddStudent;
  final ValueChanged<int>? onOpenStudent;

  const StudentsPage({
    super.key,
    required this.repo,
    this.academic,
    this.onAddStudent,
    this.onOpenStudent,
  });

  @override
  State<StudentsPage> createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  static const int _pageSize = 50;

  final _searchController = TextEditingController();
  Timer? _debounce;

  StudentFilter _filter = const StudentFilter();
  int _offset = 0;
  bool _loading = true;
  Paged<StudentRow> _page = const Paged([], 0);

  /// د پرمختللو فلټرونو تخته — د اړتیا پر مهال خلاصېږي، چې پورتنۍ
  /// کرښه ساده پاتې شي.
  bool _showFilters = false;
  List<Grade> _grades = const [];
  bool _madrasa = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadGrades();
  }

  Future<void> _loadGrades() async {
    final a = widget.academic;
    if (a == null) return;
    final grades = await a.grades();
    final madrasa = await a.isMadrasa();
    if (!mounted) return;
    setState(() {
      _grades = grades;
      _madrasa = madrasa;
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
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

  /// د لټون هره تڼۍ ډیټابیس ته نه ځي — ۲۵۰ms انتظار کوي.
  /// له دې پرته د «احمد» لیکل پنځه پوښتنې جوړوي.
  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _filter = _filter.copyWith(query: value);
        _offset = 0;
      });
      _load();
    });
  }

  void _setFilter(StudentFilter next) {
    setState(() {
      _filter = next;
      _offset = 0;
    });
    _load();
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
            child: _Toolbar(
              controller: _searchController,
              onSearchChanged: _onSearchChanged,
              filter: _filter,
              onFilterChanged: _setFilter,
              onAdd: widget.onAddStudent,
              total: _page.total,
              filtersOpen: _showFilters,
              onToggleFilters: () =>
                  setState(() => _showFilters = !_showFilters),
            ),
          ),
          // د تختې پرانیستل/بندول په نرمۍ سره — جدول ښکته ښویېږي،
          // نه چې ټوپ ووهي.
          AnimatedSize(
            duration: AppMotion.normal,
            curve: AppMotion.standard,
            alignment: Alignment.topCenter,
            child: _showFilters
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _FilterPanel(
                      filter: _filter,
                      grades: _grades,
                      madrasa: _madrasa,
                      onChanged: _setFilter,
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DataTableView<StudentRow>(
              loading: _loading,
              rows: _page.items,
              onRowTap: widget.onOpenStudent == null
                  ? null
                  : (r) => widget.onOpenStudent!(r.student.id),
              emptyIcon: Icons.school_rounded,
              emptyTitle: _filter.query.isEmpty
                  ? 'لا هېڅ شاګرد نه دی ثبت شوی'
                  : 'هېڅ پایله ونه موندل شوه',
              emptyHint: _filter.query.isEmpty
                  ? 'د «نوی شاګرد» تڼۍ ووهئ چې لومړی شاګرد ثبت کړئ.'
                  : 'د لټون کلمه بدله کړئ یا سرغړاوی لرې کړئ.',
              columns: [
                TableColumn(
                  title: '#',
                  width: 78,
                  cell: (context, r) => Text(
                    locale.num(r.student.admissionNo.split('-').last),
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
                        name: r.fullName,
                        color: r.student.gender == 'female'
                            ? AppColors.modTeachers
                            : AppColors.modStudents,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              r.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: context.palette.ink,
                              ),
                            ),
                            Text(
                              'ولد ${r.student.fatherName}',
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
                  title: s.classes,
                  flex: 2,
                  cell: (context, r) => Text(
                    r.className,
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
                    r.student.phone == null
                        ? '—'
                        : locale.num(r.student.phone!),
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12.5, color: context.palette.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'حالت',
                  width: 92,
                  cell: (context, r) => StatusChip(
                    label: _statusLabel(r.student.status),
                    color: _statusColor(r.student.status),
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

  String _statusLabel(String status) => switch (status) {
    'active' => 'فعال',
    'graduated' => 'فارغ',
    'transferred' => 'لېږدېدلی',
    'dropped' => 'پرېښی',
    'suspended' => 'ځنډول شوی',
    _ => status,
  };

  Color _statusColor(String status) => switch (status) {
    'active' => AppColors.success,
    'graduated' => AppColors.info,
    'suspended' => AppColors.danger,
    _ => AppColors.warning,
  };
}

// ═══════════════════════════════════════════════════════════
//  پورتنۍ کرښه — لټون، سرغړاوی، نوی شاګرد
// ═══════════════════════════════════════════════════════════

class _Toolbar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final StudentFilter filter;
  final ValueChanged<StudentFilter> onFilterChanged;
  final VoidCallback? onAdd;
  final int total;
  final bool filtersOpen;
  final VoidCallback onToggleFilters;

  const _Toolbar({
    required this.controller,
    required this.onSearchChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.onAdd,
    required this.total,
    required this.filtersOpen,
    required this.onToggleFilters,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Row(
      children: [
        SizedBox(
          width: 320,
          child: TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: const InputDecoration(
              hintText: 'نوم، د پلار نوم، آی‌ډي یا تلیفون…',
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
        _FilterChip(
          label: 'ټول جنس',
          selected: filter.gender == null,
          options: const {'male': 'زلمي', 'female': 'نجونې'},
          value: filter.gender,
          onChanged: (v) => onFilterChanged(
            v == null
                ? filter.copyWith(clearGender: true)
                : filter.copyWith(gender: v),
          ),
        ),
        const SizedBox(width: 8),
        _FilterChip(
          label: 'ټول حالتونه',
          selected: filter.status == null,
          options: const {
            'active': 'فعال',
            'graduated': 'فارغ',
            'transferred': 'لېږدېدلی',
            'suspended': 'ځنډول شوی',
          },
          value: filter.status,
          onChanged: (v) => onFilterChanged(
            v == null
                ? filter.copyWith(clearStatus: true)
                : filter.copyWith(status: v),
          ),
        ),
        const SizedBox(width: 8),

        // **د پرمختللو فلټرونو تڼۍ خپل شمېر وړي.** پرته له دې،
        // کارن به تختې ته اړ و چې وګوري ولې لیست دومره لنډ دی.
        _FilterToggle(
          open: filtersOpen,
          count: filter.activeCount,
          onTap: onToggleFilters,
        ),
        const Spacer(),
        Text(
          '${s.locale.grouped(total)} ${s.students}',
          style: TextStyle(fontSize: 12.5, color: p.muted),
        ),
        const SizedBox(width: 14),
        FilledButton.icon(
          onPressed: onAdd,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          icon: const Icon(Icons.person_add_rounded, size: 17),
          label: const Text('نوی شاګرد'),
        ),
      ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1,
                ),
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

/// د پرمختللو فلټرونو تخته.
///
/// **ولې دومره فلټرونه؟** ځکه چې د اته سوو شاګردانو په لیست کې د
/// یوه موندل د نوم په لیکلو کېږي — خو د یوې **ډلې** موندل نه.
/// «د پکتیا د زرمت هغه لیلیه شاګردان چې پروفایل يې نیمګړی دی» —
/// دا هغه پوښتنه ده چې مدیر يې ورځ کوي، او پرته له دې فلټرونو،
/// ځواب يې د اته سوو کرښو په لاسي کتلو کې و.
class _FilterPanel extends StatelessWidget {
  final StudentFilter filter;
  final List<Grade> grades;
  final bool madrasa;
  final ValueChanged<StudentFilter> onChanged;

  const _FilterPanel({
    required this.filter,
    required this.grades,
    required this.madrasa,
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
              if (grades.isNotEmpty)
                SizedBox(
                  width: 200,
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
                width: 200,
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
                width: 200,
                child: TypeAheadField(
                  label: s.district,
                  icon: Icons.place_rounded,
                  // ولسوالۍ د ولایت پرته معنا نه لري — نو تر هغې بنده ده.
                  enabled: filter.province != null,
                  hint: filter.province == null ? 'لومړی ولایت وټاکئ' : null,
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
              SegmentedChoice<bool>(
                value: filter.onlyIncomplete,
                color: AppColors.warning,
                options: [
                  (value: false, label: 'ټول پروفایلونه', icon: null),
                  (
                    value: true,
                    label: s.incompleteProfile,
                    icon: Icons.report_problem_rounded,
                  ),
                ],
                onChanged: (v) => onChanged(filter.copyWith(onlyIncomplete: v)),
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
                    const StudentFilter().copyWith(query: filter.query),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Map<String, String> options;
  final String? value;
  final ValueChanged<String?> onChanged;

  const _FilterChip({
    required this.label,
    required this.selected,
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
              active ? options[value]! : label,
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
