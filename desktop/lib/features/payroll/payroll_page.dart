import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/payroll_repository.dart';
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

/// د معاشونو پاڼه — دورې او د هرې دورې کرښې.
class PayrollPage extends StatefulWidget {
  final PayrollRepository payroll;
  final Session session;

  const PayrollPage({
    super.key,
    required this.payroll,
    required this.session,
  });

  @override
  State<PayrollPage> createState() => _PayrollPageState();
}

class _PayrollPageState extends State<PayrollPage> {
  bool _loading = true;
  List<PayrollRunRow> _runs = const [];
  PayrollRunRow? _open;
  List<PayrollItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final runs = await widget.payroll.runs();

    List<PayrollItem> items = const [];
    PayrollRunRow? open;
    if (_open != null) {
      open = runs.where((r) => r.run.id == _open!.run.id).firstOrNull;
      if (open != null) items = await widget.payroll.items(open.run.id);
    }

    if (!mounted) return;
    setState(() {
      _runs = runs;
      _open = open;
      _items = items;
      _loading = false;
    });
  }

  Future<void> _openRun(PayrollRunRow row) async {
    final items = await widget.payroll.items(row.run.id);
    if (!mounted) return;
    setState(() {
      _open = row;
      _items = items;
    });
  }

  Future<void> _newRun() async {
    final now = DateTime.now();
    final suggestion =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    final period = await showDialog<String>(
      context: context,
      builder: (_) => _PeriodDialog(initial: suggestion),
    );
    if (period == null || !mounted) return;

    final id = await widget.payroll.createRun(
      period: period,
      byUserId: widget.session.userId,
    );
    await _load();
    if (!mounted) return;

    final row = _runs.where((r) => r.run.id == id).firstOrNull;
    if (row != null) await _openRun(row);
  }

  Future<void> _editItem(PayrollItem item) async {
    final draft = await showDialog<_ItemDraft>(
      context: context,
      builder: (_) => _ItemDialog(item: item),
    );
    if (draft == null) return;

    await widget.payroll.updateItem(
      itemId: item.id,
      allowances: draft.allowances,
      deductions: draft.deductions,
      absenceDeduction: draft.absenceDeduction,
      absentDays: draft.absentDays,
      note: draft.note,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      switchInCurve: AppMotion.standard,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      child: KeyedSubtree(
        key: ValueKey(_open?.run.id ?? 0),
        child: _open == null ? _buildRuns() : _buildItems(_open!),
      ),
    );
  }

  // ── دورې ────────────────────────────────────────────────

  Widget _buildRuns() {
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
                Text(
                  'د معاشونو دورې',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _newRun,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('نوې دوره'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modPayroll,
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
            child: DataTableView<PayrollRunRow>(
              loading: _loading,
              rows: _runs,
              emptyIcon: Icons.account_balance_wallet_rounded,
              emptyTitle: 'لا هېڅ دوره نه ده جوړه شوې',
              emptyHint:
                  '«نوې دوره» کېکاږئ — د ټولو فعالو استادانو او '
                  'کارمندانو کرښې پخپله جوړېږي.',
              onRowTap: _openRun,
              columns: [
                TableColumn(
                  title: 'دوره',
                  flex: 2,
                  cell: (context, r) => Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: AppColors.modPayroll.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 17,
                          color: AppColors.modPayroll,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        locale.num(r.run.period),
                        style: AppTheme.tabular(
                          TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                TableColumn(
                  title: 'کارکوونکي',
                  width: 110,
                  cell: (context, r) => Text(
                    locale.num(r.summary.headcount),
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12.5, color: p.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'اصلي معاش',
                  width: 130,
                  cell: (context, r) => Text(
                    locale.grouped(r.summary.baseTotal),
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12.5, color: p.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'کسرونه',
                  width: 118,
                  cell: (context, r) => Text(
                    r.summary.deductionTotal == 0
                        ? '—'
                        : locale.grouped(r.summary.deductionTotal),
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 12.5,
                        color: r.summary.deductionTotal == 0
                            ? p.faint
                            : AppColors.danger,
                      ),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'خالص',
                  width: 138,
                  cell: (context, r) => Text(
                    locale.grouped(r.summary.netTotal),
                    style: AppTheme.tabular(
                      const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.modPayroll,
                      ),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'حالت',
                  width: 116,
                  cell: (context, r) => StatusChip(
                    label: switch (r.run.status) {
                      'paid' => 'ورکړل شوی',
                      'approved' => 'تصویب شوی',
                      _ => 'مسوده',
                    },
                    color: switch (r.run.status) {
                      'paid' => AppColors.success,
                      'approved' => AppColors.modAttendance,
                      _ => AppColors.warning,
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── کرښې ────────────────────────────────────────────────

  Widget _buildItems(PayrollRunRow row) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final s = row.summary;
    final draft = row.run.status == 'draft';

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                IconButton(
                  onPressed: () => setState(() => _open = null),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  tooltip: 'بېرته',
                ),
                const SizedBox(width: 6),
                Text(
                  'د ${locale.num(row.run.period)} معاشونه',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const SizedBox(width: 12),
                StatusChip(
                  label: switch (row.run.status) {
                    'paid' => 'ورکړل شوی',
                    'approved' => 'تصویب شوی',
                    _ => 'مسوده',
                  },
                  color: switch (row.run.status) {
                    'paid' => AppColors.success,
                    'approved' => AppColors.modAttendance,
                    _ => AppColors.warning,
                  },
                ),
                const Spacer(),
                if (draft)
                  FilledButton.icon(
                    onPressed: () async {
                      await widget.payroll.approve(
                        row.run.id,
                        byUserId: widget.session.userId,
                      );
                      await _load();
                    },
                    icon: const Icon(Icons.verified_rounded, size: 17),
                    label: const Text('تصویب کړه'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.modAttendance,
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                if (row.run.status == 'approved')
                  FilledButton.icon(
                    onPressed: () async {
                      await widget.payroll.markPaid(row.run.id);
                      await _load();
                    },
                    icon: const Icon(Icons.payments_rounded, size: 17),
                    label: const Text('ورکړل شوی نښه کړه'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.success,
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
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: p.line),
            ),
            child: Row(
              children: [
                _Metric(
                  label: 'اصلي',
                  value: locale.grouped(s.baseTotal),
                  color: p.ink,
                ),
                _Sep(),
                _Metric(
                  label: 'اضافي',
                  value: locale.grouped(s.allowanceTotal),
                  color: AppColors.success,
                ),
                _Sep(),
                _Metric(
                  label: 'کسرونه',
                  value: locale.grouped(s.deductionTotal),
                  color: AppColors.danger,
                ),
                _Sep(),
                _Metric(
                  label: 'خالص ورکړه',
                  value: '${locale.grouped(s.netTotal)} افغانۍ',
                  color: AppColors.modPayroll,
                ),
                const Spacer(),
                if (s.paidCount > 0)
                  Text(
                    '${locale.num(s.paidCount)} له '
                    '${locale.num(s.headcount)} څخه ورکړل شوي',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: DataTableView<PayrollItem>(
              loading: _loading,
              rows: _items,
              emptyIcon: Icons.person_off_rounded,
              emptyTitle: 'هېڅ کارکوونکی نشته',
              emptyHint: 'لومړی استادان یا کارمندان ثبت کړئ.',
              onRowTap: draft ? _editItem : null,
              columns: [
                TableColumn(
                  title: 'کارکوونکی',
                  flex: 3,
                  cell: (context, i) => Row(
                    children: [
                      AvatarCell(
                        name: i.employeeName,
                        color: i.employeeKind == 'teacher'
                            ? AppColors.modTeachers
                            : AppColors.modStaff,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              i.employeeName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: p.ink,
                              ),
                            ),
                            Text(
                              i.jobTitle ??
                                  (i.employeeKind == 'teacher'
                                      ? 'استاد'
                                      : 'کارمند'),
                              style: TextStyle(
                                fontSize: 11.5,
                                color: p.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                TableColumn(
                  title: 'اصلي',
                  width: 110,
                  cell: (context, i) => Text(
                    locale.grouped(i.baseSalary),
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12.5, color: p.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'اضافي',
                  width: 100,
                  cell: (context, i) => Text(
                    i.allowances == 0 ? '—' : locale.grouped(i.allowances),
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 12.5,
                        color: i.allowances == 0
                            ? p.faint
                            : AppColors.success,
                      ),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'کسرونه',
                  width: 132,
                  cell: (context, i) {
                    final total = i.deductions + i.absenceDeduction;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          total == 0 ? '—' : locale.grouped(total),
                          style: AppTheme.tabular(
                            TextStyle(
                              fontSize: 12.5,
                              color: total == 0 ? p.faint : AppColors.danger,
                            ),
                          ),
                        ),
                        if (i.absentDays > 0)
                          Text(
                            '${locale.num(i.absentDays)} ورځې غیرحاضر',
                            style: TextStyle(fontSize: 10.5, color: p.faint),
                          ),
                      ],
                    );
                  },
                ),
                TableColumn(
                  title: 'خالص',
                  width: 128,
                  cell: (context, i) => Text(
                    locale.grouped(i.netPay),
                    style: AppTheme.tabular(
                      const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.modPayroll,
                      ),
                    ),
                  ),
                ),
                TableColumn(
                  title: '',
                  width: 56,
                  cell: (context, i) => i.paidAt != null
                      ? const Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: AppColors.success,
                        )
                      : draft
                      ? Icon(Icons.edit_rounded, size: 16, color: p.muted)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          if (draft) ...[
            const SizedBox(height: 12),
            Text(
              'پر یوه کرښه کلیک وکړئ چې اضافي یا کسرونه ورته ولیکئ. '
              'خالص معاش پخپله شمېرل کېږي.',
              style: TextStyle(fontSize: 11.5, color: p.faint),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Metric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.tabular(
            TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11.5, color: p.muted)),
      ],
    );
  }
}

class _Sep extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 32,
    margin: const EdgeInsets.symmetric(horizontal: 20),
    color: context.palette.line,
  );
}

class _PeriodDialog extends StatefulWidget {
  final String initial;
  const _PeriodDialog({required this.initial});

  @override
  State<_PeriodDialog> createState() => _PeriodDialogState();
}

class _PeriodDialogState extends State<_PeriodDialog> {
  late final _c = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: const Text(
        'نوې د معاشونو دوره',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 380,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _c,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'دوره',
                hintText: '۱۴۰۵-۰۵',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'د ټولو فعالو استادانو او کارمندانو کرښې پخپله جوړېږي. '
              'معاش يې هماغه وخت کاپي کېږي — که وروسته بدل شي، دا '
              'دوره نه بدلېږي.',
              style: TextStyle(fontSize: 11.5, height: 1.7, color: p.muted),
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
          onPressed: _c.text.trim().isEmpty
              ? null
              : () => Navigator.pop(context, Numerals.toLatin(_c.text.trim())),
          child: const Text('جوړ کړه'),
        ),
      ],
    );
  }
}

class _ItemDraft {
  final int allowances;
  final int deductions;
  final int absenceDeduction;
  final int absentDays;
  final String? note;

  const _ItemDraft({
    required this.allowances,
    required this.deductions,
    required this.absenceDeduction,
    required this.absentDays,
    this.note,
  });
}

class _ItemDialog extends StatefulWidget {
  final PayrollItem item;
  const _ItemDialog({required this.item});

  @override
  State<_ItemDialog> createState() => _ItemDialogState();
}

class _ItemDialogState extends State<_ItemDialog> {
  late final _allow = TextEditingController(
    text: '${widget.item.allowances}',
  );
  late final _deduct = TextEditingController(
    text: '${widget.item.deductions}',
  );
  late final _absence = TextEditingController(
    text: '${widget.item.absenceDeduction}',
  );
  late final _days = TextEditingController(text: '${widget.item.absentDays}');
  late final _note = TextEditingController(text: widget.item.note ?? '');

  int _n(TextEditingController c) =>
      int.tryParse(Numerals.toLatin(c.text.trim())) ?? 0;

  int get _net {
    final v =
        widget.item.baseSalary +
        _n(_allow) -
        _n(_deduct) -
        _n(_absence);
    return v < 0 ? 0 : v;
  }

  @override
  void dispose() {
    _allow.dispose();
    _deduct.dispose();
    _absence.dispose();
    _days.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Text(
        widget.item.employeeName,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 13,
              ),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  Text(
                    'اصلي معاش',
                    style: TextStyle(fontSize: 12.5, color: p.muted),
                  ),
                  const Spacer(),
                  Text(
                    locale.grouped(widget.item.baseSalary),
                    style: AppTheme.tabular(
                      TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _num(_allow, 'اضافي')),
                const SizedBox(width: 12),
                Expanded(child: _num(_deduct, 'کسرونه')),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _num(_absence, 'د غیرحاضرۍ کسر')),
                const SizedBox(width: 12),
                Expanded(child: _num(_days, 'د غیرحاضرۍ ورځې', afghani: false)),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _note,
              decoration: const InputDecoration(labelText: 'یادښت'),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.modPayroll.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Row(
                children: [
                  const Text(
                    'خالص معاش',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.modPayroll,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${locale.grouped(_net)} افغانۍ',
                    style: AppTheme.tabular(
                      const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.modPayroll,
                      ),
                    ),
                  ),
                ],
              ),
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
          onPressed: () => Navigator.pop(
            context,
            _ItemDraft(
              allowances: _n(_allow),
              deductions: _n(_deduct),
              absenceDeduction: _n(_absence),
              absentDays: _n(_days),
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.modPayroll,
          ),
          child: const Text('وساتـه'),
        ),
      ],
    );
  }

  Widget _num(TextEditingController c, String label, {bool afghani = true}) =>
      TextField(
        controller: c,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
        ],
        decoration: InputDecoration(
          labelText: label,
          suffixText: afghani ? 'افغانۍ' : null,
        ),
      );
}
