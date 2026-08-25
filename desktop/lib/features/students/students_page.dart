import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/data/afghanistan.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../widgets/data_table_view.dart';
import '../../widgets/filter_bar.dart';

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
            child: FilterBar(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
              searchHint: 'نوم، د پلار نوم، آی‌ډي یا تلیفون…',
              searchWidth: 320,
              primary: [
                if (_grades.isNotEmpty)
                  QuickFilter<int>(
                    label: _madrasa ? 'ټولې درجې' : 'ټول ټولګي',
                    icon: Icons.class_rounded,
                    value: _filter.gradeId,
                    options: [
                      for (final g in _grades) (value: g.id, label: g.name),
                    ],
                    onChanged: (v) => _setFilter(
                      v == null
                          ? _filter.copyWith(clearGrade: true)
                          : _filter.copyWith(gradeId: v),
                    ),
                  ),
              ],
              activeCount: _filter.advancedCount,
              open: _showFilters,
              onToggle: () => setState(() => _showFilters = !_showFilters),
              countLabel: '${locale.grouped(_page.total)} ${s.students}',
              actions: [
                FilledButton.icon(
                  onPressed: widget.onAddStudent,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: const Icon(Icons.person_add_rounded, size: 17),
                  label: const Text('نوی شاګرد'),
                ),
              ],
            ),
          ),
          FilterSheet(
            open: _showFilters,
            activeCount: _filter.advancedCount,
            onClear: () => _setFilter(
              StudentFilter(query: _filter.query, gradeId: _filter.gradeId),
            ),
            children: [
              FilterDropdown<String>(
                label: 'جنس',
                allLabel: 'ټول جنس',
                value: _filter.gender,
                options: const [
                  (value: 'male', label: 'زلمي'),
                  (value: 'female', label: 'نجونې'),
                ],
                onChanged: (v) => _setFilter(
                  v == null
                      ? _filter.copyWith(clearGender: true)
                      : _filter.copyWith(gender: v),
                ),
              ),
              FilterDropdown<String>(
                label: 'حالت',
                allLabel: 'ټول حالتونه',
                value: _filter.status,
                options: const [
                  (value: 'active', label: 'فعال'),
                  (value: 'graduated', label: 'فارغ'),
                  (value: 'transferred', label: 'لېږدېدلی'),
                  (value: 'dropped', label: 'پرېښی'),
                  (value: 'suspended', label: 'ځنډول شوی'),
                ],
                onChanged: (v) => _setFilter(
                  v == null
                      ? _filter.copyWith(clearStatus: true)
                      : _filter.copyWith(status: v),
                ),
              ),
              FilterDropdown<String>(
                label: s.province,
                allLabel: 'ټول ولایتونه',
                icon: Icons.map_rounded,
                value: _filter.province,
                options: [
                  for (final x in provinceNames) (value: x, label: x),
                ],
                onChanged: (v) => _setFilter(
                  v == null
                      ? _filter.copyWith(clearProvince: true)
                      : _filter.copyWith(province: v, clearDistrict: true),
                ),
              ),
              FilterDropdown<String>(
                label: s.district,
                // ولسوالۍ د ولایت پرته معنا نه لري — نو تر هغې بنده ده.
                allLabel: _filter.province == null
                    ? 'لومړی ولایت وټاکئ'
                    : 'ټولې ولسوالۍ',
                icon: Icons.place_rounded,
                enabled: _filter.province != null,
                value: _filter.district,
                options: [
                  for (final x in districtsOf(_filter.province))
                    (value: x, label: x),
                ],
                onChanged: (v) => _setFilter(
                  v == null
                      ? _filter.copyWith(clearDistrict: true)
                      : _filter.copyWith(district: v),
                ),
              ),
              FilterDropdown<String>(
                label: 'سکونت',
                allLabel: 'ورځني او لیلیه',
                icon: Icons.night_shelter_rounded,
                value: _filter.residency,
                options: [
                  (value: 'day', label: s.dayScholar),
                  (value: 'boarding', label: s.boarder),
                ],
                onChanged: (v) => _setFilter(
                  v == null
                      ? _filter.copyWith(clearResidency: true)
                      : _filter.copyWith(residency: v),
                ),
              ),
              FilterDropdown<bool>(
                label: 'پروفایل',
                allLabel: 'ټول پروفایلونه',
                icon: Icons.badge_rounded,
                value: _filter.onlyIncomplete ? true : null,
                options: [(value: true, label: s.incompleteProfile)],
                onChanged: (v) =>
                    _setFilter(_filter.copyWith(onlyIncomplete: v ?? false)),
              ),
            ],
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
                        photoPath: r.student.photoPath,
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
