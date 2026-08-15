import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/staff_repository.dart';
import '../../data/repositories/student_repository.dart' show Paged;
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

/// د کارمندانو پاڼه — هغه چې استادان نه دي.
///
/// **ولې له استادانو جلا؟** ځکه چې د سرایدار، محاسب او ساتونکي
/// ریکارډ بېل شیان لري: هغوی ټولګی نه لري، مضمون نه لري، او د
/// مهالویش سره تړاو نه لري. که یو جدول وای، نیمې خانې به تل تشې
/// وې او لټون به يې ګډ کاوه.
class StaffPage extends StatefulWidget {
  final StaffRepository repo;
  final Session session;

  const StaffPage({super.key, required this.repo, required this.session});

  @override
  State<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends State<StaffPage> {
  static const int _pageSize = 50;

  StaffFilter _filter = const StaffFilter();
  int _offset = 0;
  bool _loading = true;
  Paged<StaffRow> _page = const Paged([], 0);
  List<DepartmentPayroll> _payroll = const [];
  ({int staffTotal, int teacherTotal, int headcount})? _wages;

  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
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
    final payroll = await widget.repo.payrollByDepartment();
    final wages = await widget.repo.monthlyWageBill();

    if (!mounted) return;
    setState(() {
      _page = page;
      _payroll = payroll;
      _wages = wages;
      _loading = false;
    });
  }

  Future<void> _add() async {
    final nextNo = await widget.repo.nextEmployeeNo();
    if (!mounted) return;

    final draft = await showDialog<StaffMembersCompanion>(
      context: context,
      builder: (_) => _AddStaffDialog(employeeNo: nextNo),
    );
    if (draft == null) return;

    await widget.repo.add(
      staff: draft,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        backgroundColor: AppColors.success,
        content: Text('کارمند ثبت شو.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _search,
                    onChanged: (v) {
                      setState(() {
                        _filter = _filter.copyWith(query: v);
                        _offset = 0;
                      });
                      _load();
                    },
                    decoration: const InputDecoration(
                      hintText: 'نوم، نمبر یا دنده…',
                      prefixIcon: Icon(Icons.search_rounded, size: 19),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _DeptFilter(
                  selected: _filter.department,
                  onPicked: (d) {
                    setState(() {
                      _filter = d == null
                          ? _filter.copyWith(clearDepartment: true)
                          : _filter.copyWith(department: d);
                      _offset = 0;
                    });
                    _load();
                  },
                ),
                const Spacer(),
                if (_wages != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.modPayroll.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 16,
                          color: AppColors.modPayroll,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          'میاشتنی معاش: '
                          '${locale.grouped(_wages!.staffTotal + _wages!.teacherTotal)} '
                          'افغانۍ',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.modPayroll,
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _add,
                  icon: const Icon(Icons.person_add_rounded, size: 18),
                  label: const Text('نوی کارمند'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modStaff,
                    minimumSize: const Size(0, 42),
                    padding: const EdgeInsets.symmetric(horizontal: 18),
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
          const SizedBox(height: 18),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(flex: 5, child: _buildTable(p, locale)),
                const SizedBox(width: 18),
                SizedBox(width: 290, child: _buildPayroll(p, locale)),
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

  Widget _buildTable(AppPalette p, AppLocale locale) {
    return DataTableView<StaffRow>(
      loading: _loading,
      rows: _page.items,
      emptyIcon: Icons.badge_rounded,
      emptyTitle: 'لا هېڅ کارمند نه دی ثبت شوی',
      emptyHint: 'سرایدار، محاسب، ساتونکی — هغه چې استادان نه دي.',
      columns: [
        TableColumn(
          title: 'کارمند',
          flex: 3,
          cell: (context, r) => Row(
            children: [
              AvatarCell(
                name: r.staff.fullName,
                color: AppColors.modStaff,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.staff.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      locale.num(r.staff.employeeNo),
                      style: AppTheme.tabular(
                        TextStyle(fontSize: 11, color: p.faint),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableColumn(
          title: 'دنده',
          flex: 2,
          cell: (context, r) => Text(
            r.staff.jobTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12.5, color: p.inkSoft),
          ),
        ),
        TableColumn(
          title: 'څانګه',
          width: 120,
          cell: (context, r) => StatusChip(
            label: r.staff.department ?? 'بل',
            color: AppColors.modStaff,
          ),
        ),
        TableColumn(
          title: 'تلیفون',
          width: 130,
          cell: (context, r) => Text(
            r.staff.phone == null ? '—' : locale.num(r.staff.phone!),
            style: AppTheme.tabular(
              TextStyle(fontSize: 12, color: p.inkSoft),
            ),
          ),
        ),
        TableColumn(
          title: 'معاش',
          width: 118,
          cell: (context, r) => Text(
            r.staff.monthlySalary == null
                ? '—'
                : locale.grouped(r.staff.monthlySalary!),
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
          ),
        ),
        TableColumn(
          title: '',
          width: 56,
          cell: (context, r) => IconButton(
            tooltip: 'ړنګول',
            onPressed: () async {
              await widget.repo.softDelete(
                r.staff.id,
                byUserId: widget.session.userId,
                byUserName: widget.session.username,
              );
              await _load();
            },
            icon: Icon(
              Icons.delete_outline_rounded,
              size: 17,
              color: p.muted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayroll(AppPalette p, AppLocale locale) {
    final max = _payroll.isEmpty
        ? 1
        : _payroll.map((e) => e.monthlyTotal).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'د څانګو معاشونه',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'یوازې فعال کارمندان — استادان دلته نه شمېرل کېږي.',
            style: TextStyle(fontSize: 11.5, height: 1.7, color: p.muted),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _payroll.isEmpty
                ? Center(
                    child: Text(
                      '—',
                      style: TextStyle(fontSize: 13, color: p.faint),
                    ),
                  )
                : ListView.separated(
                    itemCount: _payroll.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, i) {
                      final d = _payroll[i];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  d.department,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: p.ink,
                                  ),
                                ),
                              ),
                              Text(
                                '${locale.num(d.headcount)} تنه',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: p.muted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(
                                begin: 0,
                                end: max == 0 ? 0 : d.monthlyTotal / max,
                              ),
                              duration: AppMotion.counter,
                              curve: AppMotion.standard,
                              builder: (_, v, __) => LinearProgressIndicator(
                                value: v,
                                minHeight: 6,
                                backgroundColor: p.surfaceAlt,
                                valueColor: const AlwaysStoppedAnimation(
                                  AppColors.modPayroll,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${locale.grouped(d.monthlyTotal)} افغانۍ',
                            style: AppTheme.tabular(
                              TextStyle(fontSize: 11.5, color: p.faint),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          if (_wages != null) ...[
            Divider(color: p.line, height: 26),
            _WageRow(
              label: 'استادان',
              value: locale.grouped(_wages!.teacherTotal),
            ),
            const SizedBox(height: 7),
            _WageRow(
              label: 'کارمندان',
              value: locale.grouped(_wages!.staffTotal),
            ),
            const SizedBox(height: 7),
            _WageRow(
              label: 'ټول',
              value: locale.grouped(
                _wages!.teacherTotal + _wages!.staffTotal,
              ),
              bold: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _WageRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _WageRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold ? p.ink : p.muted,
            ),
          ),
        ),
        Text(
          value,
          style: AppTheme.tabular(
            TextStyle(
              fontSize: bold ? 13 : 12,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: bold ? AppColors.modPayroll : p.inkSoft,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeptFilter extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onPicked;

  const _DeptFilter({required this.selected, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<String?>(
      tooltip: '',
      onSelected: onPicked,
      itemBuilder: (_) => [
        const PopupMenuItem(
          value: null,
          child: Text('ټولې څانګې', style: TextStyle(fontSize: 13)),
        ),
        for (final d in staffDepartments)
          PopupMenuItem(
            value: d,
            child: Text(d, style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.filter_list_rounded, size: 16, color: p.muted),
            const SizedBox(width: 9),
            Text(
              selected ?? 'ټولې څانګې',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _AddStaffDialog extends StatefulWidget {
  final String employeeNo;
  const _AddStaffDialog({required this.employeeNo});

  @override
  State<_AddStaffDialog> createState() => _AddStaffDialogState();
}

class _AddStaffDialogState extends State<_AddStaffDialog> {
  final _name = TextEditingController();
  final _job = TextEditingController();
  final _phone = TextEditingController();
  final _salary = TextEditingController();

  String _department = staffDepartments.first;
  String _gender = 'male';

  @override
  void dispose() {
    _name.dispose();
    _job.dispose();
    _phone.dispose();
    _salary.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final ready = _name.text.trim().isNotEmpty && _job.text.trim().isNotEmpty;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Row(
        children: [
          const Text(
            'نوی کارمند',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.modStaff.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              locale.num(widget.employeeNo),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.modStaff,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _name,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'بشپړ نوم *'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _job,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'دنده *',
                hintText: 'لکه محاسب، سرایدار، ساتونکی',
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _department,
                    decoration: const InputDecoration(labelText: 'څانګه'),
                    items: [
                      for (final d in staffDepartments)
                        DropdownMenuItem(
                          value: d,
                          child: Text(
                            d,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    onChanged: (v) =>
                        setState(() => _department = v ?? staffDepartments.first),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: const InputDecoration(labelText: 'جنس'),
                    items: const [
                      DropdownMenuItem(
                        value: 'male',
                        child: Text('نارینه', style: TextStyle(fontSize: 13)),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text('ښځینه', style: TextStyle(fontSize: 13)),
                      ),
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
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'تلیفون'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _salary,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'میاشتنی معاش',
                      suffixText: 'افغانۍ',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: !ready
              ? null
              : () => Navigator.pop(
                  context,
                  StaffMembersCompanion.insert(
                    employeeNo: widget.employeeNo,
                    fullName: _name.text.trim(),
                    jobTitle: _job.text.trim(),
                    gender: _gender,
                    department: Value(_department),
                    phone: Value(
                      _phone.text.trim().isEmpty
                          ? null
                          : Numerals.toLatin(_phone.text.trim()),
                    ),
                    monthlySalary: Value(
                      int.tryParse(Numerals.toLatin(_salary.text.trim())),
                    ),
                  ),
                ),
          child: const Text('ثبت کړه'),
        ),
      ],
    );
  }
}
