import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/repositories/leave_repository.dart';
import '../../data/repositories/student_repository.dart' show Paged;
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

/// د اجازت‌نامو پاڼه — تصویب او ردول.
///
/// **دا ولې د حاضرۍ سره تړلې ده؟** کله چې یوه اجازه منل کېږي، هغه
/// ورځې چې مخکې «غیرحاضر» ثبت شوې وې، «رخصت» ته اوړي. نو د میاشتې
/// رپوټ سم پاتې کېږي، او والدینو ته د غیرحاضرۍ غلط پیغام نه ځي.
class LeavePage extends StatefulWidget {
  final LeaveRepository repo;
  final Session session;

  const LeavePage({super.key, required this.repo, required this.session});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  static const int _pageSize = 50;

  String? _status = 'pending';
  int _offset = 0;
  bool _loading = true;
  Paged<LeaveRow> _page = const Paged([], 0);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final page = await widget.repo.list(
      status: _status,
      limit: _pageSize,
      offset: _offset,
    );
    if (!mounted) return;
    setState(() {
      _page = page;
      _loading = false;
    });
  }

  Future<void> _decide(LeaveRow row, bool approve) async {
    await widget.repo.decide(
      leaveId: row.request.id,
      approve: approve,
      byUserId: widget.session.userId,
      byUserName: widget.session.username,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: approve ? AppColors.success : AppColors.modSettings,
        content: Text(
          approve
              ? 'اجازه ومنل شوه — د هغو ورځو حاضري «رخصت» ته واوښته.'
              : 'اجازه رد شوه.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                for (final tab in const [
                  (null, 'ټولې'),
                  ('pending', 'د تمې په حال'),
                  ('approved', 'منل شوې'),
                  ('rejected', 'رد شوې'),
                ]) ...[
                  _Tab(
                    label: tab.$2,
                    selected: _status == tab.$1,
                    onTap: () {
                      setState(() {
                        _status = tab.$1;
                        _offset = 0;
                      });
                      _load();
                    },
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                Text(
                  '${locale.grouped(_page.total)} غوښتنې',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DataTableView<LeaveRow>(
              loading: _loading,
              rows: _page.items,
              emptyIcon: Icons.event_available_rounded,
              emptyTitle: _status == 'pending'
                  ? 'هېڅ غوښتنه د تمې په حال کې نشته'
                  : 'هېڅ غوښتنه نشته',
              emptyHint: 'د ریسیپشن یا د والدینو له اپ څخه راځي.',
              columns: [
                TableColumn(
                  title: 'شاګرد',
                  flex: 3,
                  cell: (context, r) => Row(
                    children: [
                      AvatarCell(
                        name: r.student.firstName,
                        color: AppColors.modLeave,
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
                  title: 'لامل',
                  flex: 2,
                  cell: (context, r) => Text(switch (r.request.reasonType) {
                    'sick' => 'ناروغي',
                    'family' => 'کورنۍ چاره',
                    'travel' => 'سفر',
                    'official' => 'رسمي',
                    _ => 'بل',
                  }, style: TextStyle(fontSize: 12.5, color: p.inkSoft)),
                ),
                TableColumn(
                  title: 'موده',
                  flex: 2,
                  cell: (context, r) => Text(
                    '${locale.num(_d(r.request.fromDate))} → '
                    '${locale.num(_d(r.request.toDate))}'
                    '  (${locale.num(r.days)} ورځې)',
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12, color: p.inkSoft),
                    ),
                  ),
                ),
                TableColumn(
                  title: 'حالت',
                  width: 104,
                  cell: (context, r) => StatusChip(
                    label: switch (r.request.status) {
                      'pending' => 'د تمې په حال',
                      'approved' => 'منل شوې',
                      'rejected' => 'رد شوې',
                      _ => 'لغوه',
                    },
                    color: switch (r.request.status) {
                      'pending' => AppColors.warning,
                      'approved' => AppColors.success,
                      _ => AppColors.danger,
                    },
                  ),
                ),
                TableColumn(
                  title: '',
                  width: 168,
                  cell: (context, r) => r.request.status != 'pending'
                      ? const SizedBox.shrink()
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FilledButton(
                              onPressed: () => _decide(r, true),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.success,
                                minimumSize: const Size(0, 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              child: const Text('ومنه'),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(
                              onPressed: () => _decide(r, false),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(0, 32),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                              ),
                              child: const Text('رد'),
                            ),
                          ],
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

  String _d(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
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
              ? AppColors.modLeave.withValues(alpha: 0.11)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: selected ? AppColors.modLeave : p.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modLeave : p.inkSoft,
          ),
        ),
      ),
    );
  }
}
