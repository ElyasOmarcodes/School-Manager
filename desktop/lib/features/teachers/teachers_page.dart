import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/student_repository.dart' show Paged;
import '../../data/repositories/teacher_repository.dart';
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

class TeachersPage extends StatefulWidget {
  final TeacherRepository repo;
  final Session session;

  const TeachersPage({super.key, required this.repo, required this.session});

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
  Paged<TeacherRow> _page = const Paged([], 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
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

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() {
        _filter = _filter.copyWith(query: v);
        _offset = 0;
      });
      _load();
    });
  }

  Future<void> _addTeacher() async {
    final employeeNo = await widget.repo.nextEmployeeNo();
    if (!mounted) return;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => _AddTeacherDialog(
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
      await _load();
    }
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
                  onPressed: _addTeacher,
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
          const SizedBox(height: 16),
          Expanded(
            child: DataTableView<TeacherRow>(
              loading: _loading,
              rows: _page.items,
              emptyIcon: Icons.person_rounded,
              emptyTitle: 'لا هېڅ استاد نه دی ثبت شوی',
              emptyHint: 'د «نوی استاد» تڼۍ ووهئ.',
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
                    label: switch (r.teacher.status) {
                      'active' => 'فعال',
                      'on_leave' => 'په رخصتۍ',
                      'resigned' => 'استعفا',
                      _ => 'ګوښه شوی',
                    },
                    color: switch (r.teacher.status) {
                      'active' => AppColors.success,
                      'on_leave' => AppColors.warning,
                      _ => AppColors.danger,
                    },
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
//  د نوي استاد ډیالوګ
// ═══════════════════════════════════════════════════════════

class _AddTeacherDialog extends StatefulWidget {
  final String employeeNo;
  final Future<void> Function(TeachersCompanion) onSave;

  const _AddTeacherDialog({required this.employeeNo, required this.onSave});

  @override
  State<_AddTeacherDialog> createState() => _AddTeacherDialogState();
}

class _AddTeacherDialogState extends State<_AddTeacherDialog> {
  final _name = TextEditingController();
  final _father = TextEditingController();
  final _phone = TextEditingController();
  final _spec = TextEditingController();
  final _qual = TextEditingController();
  final _salary = TextEditingController();
  String _gender = 'male';
  bool _saving = false;

  @override
  void dispose() {
    for (final c in [_name, _father, _phone, _spec, _qual, _salary]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    // شمېرې تل لاتیني ساتو — معاش او تلیفون دواړه.
    final phone = Numerals.toLatin(_phone.text.trim());
    final salary = int.tryParse(Numerals.toLatin(_salary.text.trim()));

    await widget.onSave(
      TeachersCompanion.insert(
        employeeNo: widget.employeeNo,
        fullName: _name.text.trim(),
        fatherName: Value(
          _father.text.trim().isEmpty ? null : _father.text.trim(),
        ),
        gender: _gender,
        phone: Value(phone.isEmpty ? null : phone),
        specialization: Value(
          _spec.text.trim().isEmpty ? null : _spec.text.trim(),
        ),
        qualification: Value(
          _qual.text.trim().isEmpty ? null : _qual.text.trim(),
        ),
        monthlySalary: Value(salary),
        hiredOn: Value(DateTime.now()),
      ),
    );
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
          const Text('نوی استاد'),
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
        width: 460,
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
                      controller: _spec,
                      decoration: const InputDecoration(labelText: 'تخصص'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _qual,
                      decoration: const InputDecoration(labelText: 'تحصیل'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _salary,
                      textDirection: TextDirection.ltr,
                      decoration: const InputDecoration(
                        labelText: 'میاشتنی معاش',
                      ),
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
