import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/repositories/student_repository.dart';
import '../../widgets/data_table_view.dart';

class StudentsPage extends StatefulWidget {
  final StudentRepository repo;
  final VoidCallback? onAddStudent;

  const StudentsPage({super.key, required this.repo, this.onAddStudent});

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

  @override
  void initState() {
    super.initState();
    _load();
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
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DataTableView<StudentRow>(
              loading: _loading,
              rows: _page.items,
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

  const _Toolbar({
    required this.controller,
    required this.onSearchChanged,
    required this.filter,
    required this.onFilterChanged,
    required this.onAdd,
    required this.total,
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
