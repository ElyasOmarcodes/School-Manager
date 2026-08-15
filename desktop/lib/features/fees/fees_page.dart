import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/fee_repository.dart';
import '../../data/repositories/student_repository.dart' show Paged;
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

/// د فیس پاڼه — بلونه، تادیې، او پوروړي.
class FeesPage extends StatefulWidget {
  final FeeRepository fees;
  final AcademicRepository academic;
  final Session session;

  const FeesPage({
    super.key,
    required this.fees,
    required this.academic,
    required this.session,
  });

  @override
  State<FeesPage> createState() => _FeesPageState();
}

class _FeesPageState extends State<FeesPage> {
  static const int _pageSize = 50;

  int _tab = 0;
  bool _loading = true;
  int _offset = 0;

  List<String> _periods = const [];
  String? _period;
  String? _status;
  String _query = '';

  Paged<InvoiceRow> _page = const Paged([], 0);
  CollectionSummary _summary = const CollectionSummary();
  List<({Student student, String? className, int balance, int months})>
  _defaulters = const [];
  List<FeeType> _types = const [];

  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    await widget.fees.seedDefaultTypes();
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final periods = await widget.fees.periods();
    _period ??= periods.isEmpty ? null : periods.first;

    final page = await widget.fees.list(
      period: _period,
      status: _status,
      query: _query,
      limit: _pageSize,
      offset: _offset,
    );
    final summary = await widget.fees.summary(period: _period);
    final defaulters = await widget.fees.defaulters();
    final types = await widget.fees.types(activeOnly: false);

    if (!mounted) return;
    setState(() {
      _periods = periods;
      _page = page;
      _summary = summary;
      _defaulters = defaulters;
      _types = types;
      _loading = false;
    });
  }

  Future<void> _generate() async {
    final year = await widget.academic.currentYear();
    if (year == null || !mounted) return;

    final draft = await showDialog<_GenerateDraft>(
      context: context,
      builder: (_) => _GenerateDialog(types: _types),
    );
    if (draft == null || !mounted) return;

    final r = await widget.fees.generate(
      feeTypeId: draft.feeTypeId,
      period: draft.period,
      dueDate: draft.dueDate,
      academicYearId: year.id,
      byUserId: widget.session.userId,
    );
    if (!mounted) return;
    setState(() => _period = draft.period);
    await _load();
    if (!mounted) return;

    final locale = S.of(context).locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 520,
        backgroundColor: r.created > 0 ? AppColors.success : AppColors.warning,
        content: Text(
          r.created == 0
              ? 'دې دورې لپاره بلونه لا مخکې جوړ شوي — '
                    '${locale.num(r.skipped)} پرېښودل شول.'
              : '${locale.num(r.created)} بلونه جوړ شول'
                    '${r.skipped == 0 ? '' : '، ${locale.num(r.skipped)} مخکې شته وو'}.',
        ),
      ),
    );
  }

  Future<void> _collect(InvoiceRow row) async {
    final receiptNo = await widget.fees.nextReceiptNo();
    if (!mounted) return;

    final result = await showDialog<_PayDraft>(
      context: context,
      builder: (_) => _PayDialog(row: row, receiptNo: receiptNo),
    );
    if (result == null || !mounted) return;

    if (result.waive) {
      await widget.fees.waive(
        row.invoice.id,
        reason: result.note,
        byUserId: widget.session.userId,
      );
    } else {
      if (result.discount != row.invoice.discount) {
        await widget.fees.setDiscount(
          invoiceId: row.invoice.id,
          discount: result.discount,
          reason: result.note,
        );
      }
      if (result.amount > 0) {
        await widget.fees.pay(
          invoiceId: row.invoice.id,
          amount: result.amount,
          method: result.method,
          receiptNo: receiptNo,
          byUserId: widget.session.userId,
          note: result.note,
        );
      }
    }
    if (!mounted) return;
    await _load();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: AppColors.success,
        content: Text(
          result.waive
              ? 'بل وبښل شو.'
              : 'تادیه ثبت شوه — رسید ${S.of(context).locale.num(receiptNo)}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                for (final t in const [
                  (0, 'بلونه او تادیې'),
                  (1, 'پوروړي'),
                  (2, 'د فیس ډولونه'),
                ]) ...[
                  _Tab(
                    label: t.$2,
                    selected: _tab == t.$1,
                    onTap: () => setState(() => _tab = t.$1),
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text('د دورې بلونه جوړ کړه'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modFees,
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
          _SummaryBar(summary: _summary),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.standard,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  0 => _buildInvoices(p),
                  1 => _buildDefaulters(p),
                  _ => _buildTypes(p),
                },
              ),
            ),
          ),
          if (_tab == 0) ...[
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
        ],
      ),
    );
  }

  // ── بلونه ───────────────────────────────────────────────

  Widget _buildInvoices(AppPalette p) {
    final locale = S.of(context).locale;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SizedBox(
              width: 260,
              child: TextField(
                controller: _search,
                onChanged: (v) {
                  setState(() {
                    _query = v;
                    _offset = 0;
                  });
                  _load();
                },
                decoration: const InputDecoration(
                  hintText: 'نوم یا د داخلې نمبر…',
                  prefixIcon: Icon(Icons.search_rounded, size: 19),
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _Dropdown<String?>(
              icon: Icons.calendar_month_rounded,
              color: AppColors.modFees,
              label: _period == null ? 'دوره' : locale.num(_period!),
              items: [null, ..._periods],
              labelOf: (v) => v == null ? 'ټولې دورې' : locale.num(v),
              onPicked: (v) {
                setState(() {
                  _period = v;
                  _offset = 0;
                });
                _load();
              },
            ),
            const SizedBox(width: 10),
            _Dropdown<String?>(
              icon: Icons.filter_list_rounded,
              color: AppColors.modAttendance,
              label: switch (_status) {
                'unpaid' => 'نه‌ورکړل شوي',
                'partial' => 'نیمګړي',
                'paid' => 'ورکړل شوي',
                'waived' => 'بښل شوي',
                _ => 'ټول حالتونه',
              },
              items: const [null, 'unpaid', 'partial', 'paid', 'waived'],
              labelOf: (v) => switch (v) {
                'unpaid' => 'نه‌ورکړل شوي',
                'partial' => 'نیمګړي',
                'paid' => 'ورکړل شوي',
                'waived' => 'بښل شوي',
                _ => 'ټول حالتونه',
              },
              onPicked: (v) {
                setState(() {
                  _status = v;
                  _offset = 0;
                });
                _load();
              },
            ),
          ],
        ),
        const SizedBox(height: 14),
        Expanded(
          child: DataTableView<InvoiceRow>(
            loading: _loading,
            rows: _page.items,
            emptyIcon: Icons.receipt_long_rounded,
            emptyTitle: 'هېڅ بل نشته',
            emptyHint: '«د دورې بلونه جوړ کړه» کېکاږئ.',
            columns: [
              TableColumn(
                title: 'شاګرد',
                flex: 3,
                cell: (context, r) => Row(
                  children: [
                    AvatarCell(
                      name: r.student.firstName,
                      color: AppColors.modFees,
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            [
                              r.student.firstName,
                              if (r.student.lastName?.isNotEmpty ?? false)
                                r.student.lastName,
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
                            r.className ?? '—',
                            style: TextStyle(fontSize: 11.5, color: p.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              TableColumn(
                title: 'فیس',
                flex: 2,
                cell: (context, r) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      r.feeName,
                      style: TextStyle(fontSize: 12.5, color: p.inkSoft),
                    ),
                    Text(
                      locale.num(r.invoice.period),
                      style: AppTheme.tabular(
                        TextStyle(fontSize: 11, color: p.faint),
                      ),
                    ),
                  ],
                ),
              ),
              TableColumn(
                title: 'اندازه',
                width: 112,
                cell: (context, r) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      locale.grouped(r.payable),
                      style: AppTheme.tabular(
                        TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: p.ink,
                        ),
                      ),
                    ),
                    if (r.invoice.discount > 0)
                      Text(
                        'تخفیف ${locale.grouped(r.invoice.discount)}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.success,
                        ),
                      ),
                  ],
                ),
              ),
              TableColumn(
                title: 'ورکړل شوی',
                width: 104,
                cell: (context, r) => Text(
                  locale.grouped(r.paid),
                  style: AppTheme.tabular(
                    TextStyle(fontSize: 12.5, color: p.inkSoft),
                  ),
                ),
              ),
              TableColumn(
                title: 'پاتې',
                width: 104,
                cell: (context, r) => Text(
                  r.isSettled ? '—' : locale.grouped(r.balance),
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: r.isSettled
                          ? p.faint
                          : (r.isOverdue
                                ? AppColors.danger
                                : AppColors.warning),
                    ),
                  ),
                ),
              ),
              TableColumn(
                title: 'حالت',
                width: 116,
                cell: (context, r) => StatusChip(
                  label: switch (r.invoice.status) {
                    'paid' => 'ورکړل شوی',
                    'partial' => 'نیمګړی',
                    'waived' => 'بښل شوی',
                    _ => r.isOverdue ? 'وخت تېر' : 'نه دی ورکړل',
                  },
                  color: switch (r.invoice.status) {
                    'paid' => AppColors.success,
                    'partial' => AppColors.warning,
                    'waived' => AppColors.modLeave,
                    _ => r.isOverdue ? AppColors.danger : AppColors.modUsers,
                  },
                ),
              ),
              TableColumn(
                title: '',
                width: 108,
                cell: (context, r) => r.isSettled
                    ? const SizedBox.shrink()
                    : FilledButton(
                        onPressed: () => _collect(r),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.modFees,
                          minimumSize: const Size(0, 32),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          textStyle: const TextStyle(
                            fontFamily: AppTheme.fontFamily,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('تادیه'),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── پوروړي ──────────────────────────────────────────────

  Widget _buildDefaulters(AppPalette p) {
    final locale = S.of(context).locale;

    return DataTableView<
      ({Student student, String? className, int balance, int months})
    >(
      loading: _loading,
      rows: _defaulters,
      emptyIcon: Icons.verified_rounded,
      emptyTitle: 'هېڅ پوروړی نشته',
      emptyHint: 'ټولو کورونو خپل فیس ورکړی.',
      columns: [
        TableColumn(
          title: 'شاګرد',
          flex: 3,
          cell: (context, r) => Row(
            children: [
              AvatarCell(
                name: r.student.firstName,
                color: AppColors.danger,
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      [
                        r.student.firstName,
                        if (r.student.lastName?.isNotEmpty ?? false)
                          r.student.lastName,
                      ].join(' '),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      '${r.className ?? '—'}  •  '
                      'د پلار نوم: ${r.student.fatherName}',
                      style: TextStyle(fontSize: 11.5, color: p.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        TableColumn(
          title: 'څو دورې',
          width: 110,
          cell: (context, r) => StatusChip(
            label: '${locale.num(r.months)} دورې',
            color: r.months >= 3 ? AppColors.danger : AppColors.warning,
          ),
        ),
        TableColumn(
          title: 'پاتې پور',
          width: 150,
          cell: (context, r) => Text(
            '${locale.grouped(r.balance)} افغانۍ',
            style: AppTheme.tabular(
              const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: AppColors.danger,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── ډولونه ──────────────────────────────────────────────

  Widget _buildTypes(AppPalette p) {
    final locale = S.of(context).locale;

    return ListView.separated(
      itemCount: _types.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final t = _types[i];
        return FadeSlideIn(
          delay: AppMotion.staggerFor(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: p.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.modFees.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.payments_rounded,
                    size: 17,
                    color: AppColors.modFees,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.name,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: t.isActive ? p.ink : p.faint,
                        ),
                      ),
                      Text(
                        switch (t.frequency) {
                          'monthly' => 'هره میاشت',
                          'term' => 'هر سمستر',
                          'annual' => 'کلنی',
                          _ => 'یو ځلي',
                        },
                        style: TextStyle(fontSize: 11.5, color: p.muted),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${locale.grouped(t.amount)} افغانۍ',
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: t.isActive ? AppColors.modFees : p.faint,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Switch(
                  value: t.isActive,
                  onChanged: (v) async {
                    await widget.fees.setTypeActive(t.id, v);
                    await _load();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _SummaryBar extends StatelessWidget {
  final CollectionSummary summary;
  const _SummaryBar({required this.summary});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      child: Row(
        children: [
          _Metric(
            label: 'د ورکړې وړ',
            value: locale.grouped(summary.payable),
            color: AppColors.modFees,
          ),
          _Divider(),
          _Metric(
            label: 'راټول شوی',
            value: locale.grouped(summary.collected),
            color: AppColors.success,
          ),
          _Divider(),
          _Metric(
            label: 'پاتې',
            value: locale.grouped(summary.outstanding),
            color: summary.outstanding > 0
                ? AppColors.danger
                : AppColors.success,
          ),
          _Divider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '٪${locale.num(summary.percent.round())}',
                      style: AppTheme.tabular(
                        TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: p.ink,
                        ),
                      ),
                    ),
                    const SizedBox(width: 9),
                    Text(
                      'راټول شوی',
                      style: TextStyle(fontSize: 11.5, color: p.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: 0,
                      end: (summary.percent / 100).clamp(0, 1),
                    ),
                    duration: AppMotion.counter,
                    curve: AppMotion.standard,
                    builder: (_, v, _) => LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      backgroundColor: p.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.success,
                      ),
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
            TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11.5, color: p.muted)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 34,
    margin: const EdgeInsets.symmetric(horizontal: 22),
    color: context.palette.line,
  );
}

// ═══════════════════════════════════════════════════════════

class _GenerateDraft {
  final int feeTypeId;
  final String period;
  final DateTime dueDate;
  const _GenerateDraft({
    required this.feeTypeId,
    required this.period,
    required this.dueDate,
  });
}

class _GenerateDialog extends StatefulWidget {
  final List<FeeType> types;
  const _GenerateDialog({required this.types});

  @override
  State<_GenerateDialog> createState() => _GenerateDialogState();
}

class _GenerateDialogState extends State<_GenerateDialog> {
  late int? _typeId = widget.types
      .where((t) => t.isActive)
      .firstOrNull
      ?.id;
  late final _period = TextEditingController(
    text:
        '${DateTime.now().year}-'
        '${DateTime.now().month.toString().padLeft(2, '0')}',
  );
  DateTime _due = DateTime.now().add(const Duration(days: 14));

  @override
  void dispose() {
    _period.dispose();
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
      title: const Text(
        'د دورې بلونه',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              initialValue: _typeId,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'د فیس ډول'),
              items: [
                for (final t in widget.types.where((t) => t.isActive))
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(
                      '${t.name} — ${locale.grouped(t.amount)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _typeId = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _period,
              decoration: const InputDecoration(
                labelText: 'دوره',
                hintText: '۱۴۰۵-۰۵',
              ),
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _due,
                  firstDate: DateTime.now().subtract(
                    const Duration(days: 90),
                  ),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => _due = d);
              },
              icon: const Icon(Icons.event_rounded, size: 17),
              label: Text(
                'د ورکړې وروستۍ نېټه: '
                '${locale.num(_due.toIso8601String().substring(0, 10))}',
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'بلونه د ټولو فعالو شاګردانو لپاره جوړېږي. که یوه دوره '
              'مخکې جوړه شوې وي، دوه‌ځلي بلونه نه جوړېږي.',
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
          onPressed: _typeId == null || _period.text.trim().isEmpty
              ? null
              : () => Navigator.pop(
                  context,
                  _GenerateDraft(
                    feeTypeId: _typeId!,
                    period: Numerals.toLatin(_period.text.trim()),
                    dueDate: _due,
                  ),
                ),
          child: const Text('جوړ کړه'),
        ),
      ],
    );
  }
}

class _PayDraft {
  final int amount;
  final int discount;
  final String method;
  final String? note;
  final bool waive;

  const _PayDraft({
    required this.amount,
    required this.discount,
    required this.method,
    this.note,
    this.waive = false,
  });
}

class _PayDialog extends StatefulWidget {
  final InvoiceRow row;
  final String receiptNo;

  const _PayDialog({required this.row, required this.receiptNo});

  @override
  State<_PayDialog> createState() => _PayDialogState();
}

class _PayDialogState extends State<_PayDialog> {
  late final _amount = TextEditingController(
    text: '${widget.row.balance}',
  );
  late final _discount = TextEditingController(
    text: '${widget.row.invoice.discount}',
  );
  final _note = TextEditingController();
  String _method = 'cash';

  @override
  void dispose() {
    _amount.dispose();
    _discount.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final r = widget.row;

    return AlertDialog(
      backgroundColor: p.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              'تادیه — ${r.student.firstName}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.modFees.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Text(
              locale.num(widget.receiptNo),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.modFees,
              ),
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: Column(
                children: [
                  _Line('بل', locale.grouped(r.invoice.amount)),
                  _Line('ورکړل شوی', locale.grouped(r.paid)),
                  _Line(
                    'پاتې',
                    locale.grouped(r.balance),
                    bold: true,
                    color: AppColors.danger,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amount,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'د تادیې اندازه',
                      suffixText: 'افغانۍ',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _discount,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹]')),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'تخفیف',
                      suffixText: 'افغانۍ',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _method,
              decoration: const InputDecoration(labelText: 'لاره'),
              items: const [
                DropdownMenuItem(
                  value: 'cash',
                  child: Text('نغدي', style: TextStyle(fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'bank',
                  child: Text('بانک', style: TextStyle(fontSize: 13)),
                ),
                DropdownMenuItem(
                  value: 'mobile',
                  child: Text(
                    'موبایل پیسې',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _method = v ?? 'cash'),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _note,
              decoration: const InputDecoration(
                labelText: 'یادښت (یا د تخفیف لامل)',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(
            context,
            _PayDraft(
              amount: 0,
              discount: 0,
              method: _method,
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
              waive: true,
            ),
          ),
          style: TextButton.styleFrom(foregroundColor: AppColors.modLeave),
          child: const Text('وبښه'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(
            context,
            _PayDraft(
              amount: int.tryParse(Numerals.toLatin(_amount.text)) ?? 0,
              discount: int.tryParse(Numerals.toLatin(_discount.text)) ?? 0,
              method: _method,
              note: _note.text.trim().isEmpty ? null : _note.text.trim(),
            ),
          ),
          style: FilledButton.styleFrom(backgroundColor: AppColors.modFees),
          child: const Text('ثبت کړه'),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? color;

  const _Line(this.label, this.value, {this.bold = false, this.color});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold ? p.ink : p.muted,
              ),
            ),
          ),
          Text(
            value,
            style: AppTheme.tabular(
              TextStyle(
                fontSize: bold ? 14 : 12.5,
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: color ?? p.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modFees.withValues(alpha: 0.11)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: selected ? AppColors.modFees : p.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modFees : p.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final List<T> items;
  final String Function(T) labelOf;
  final ValueChanged<T> onPicked;

  const _Dropdown({
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
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 9),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
            const SizedBox(width: 7),
            Icon(Icons.expand_more_rounded, size: 16, color: p.muted),
          ],
        ),
      ),
    );
  }
}
