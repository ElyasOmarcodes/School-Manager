import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/design.dart';
import '../core/session_store.dart';
import '../core/strings.dart';
import 'widgets.dart';

/// د مدیر اپ.
///
/// **د پروژې اصلي غوښتنه دلته ژوندۍ ده:** کله چې یو شاګرد غیرحاضر
/// وي، دلته یوه خبرتیا راځي چې «… غیرحاضر دی، ایا غواړې والدینو ته
/// پیغام ولېږې؟» — او یوه تڼۍ ورسره ده چې ټولو یا یوه ته يې لېږي.
class ManagerHome extends StatefulWidget {
  final SchoolSession session;
  final ApiClient api;
  final VoidCallback onDisconnect;

  const ManagerHome({
    super.key,
    required this.session,
    required this.api,
    required this.onDisconnect,
  });

  @override
  State<ManagerHome> createState() => _ManagerHomeState();
}

class _ManagerHomeState extends State<ManagerHome> {
  int _tab = 0;

  bool _loading = true;
  String? _error;

  ManagerSummary? _summary;
  List<NotificationInfo> _notifications = const [];
  List<AbsenteeInfo> _absentees = const [];
  List<LeaveInfo> _leave = const [];
  final Set<int> _selected = {};
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final summary = await widget.api.summary();
      final notifications = await widget.api.notifications();
      final absentees = await widget.api.absentees();
      final leave = await widget.api.leaveRequests();

      if (!mounted) return;
      setState(() {
        _summary = summary;
        _notifications = notifications;
        _absentees = absentees;
        _leave = leave;
        _loading = false;
        _selected
          ..clear()
          ..addAll(absentees.map((a) => a.studentId));
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
      if (e.isUnauthorized) widget.onDisconnect();
    }
  }

  /// **دا هغه تڼۍ ده چې ټوله پروژه ورته جوړه شوې.**
  Future<void> _notify({List<int>? ids}) async {
    if (_sending) return;
    setState(() => _sending = true);
    try {
      final r = await widget.api.notifyParents(
        studentIds: ids ?? _selected.toList(),
      );
      if (!mounted) return;
      await _load();
      if (!mounted) return;

      final t = T.of(context);
      _toast(
        r.failed == 0
            ? '${num_(r.sent, t.locale)} پیغامونه ولېږل شول.'
            : '${num_(r.sent, t.locale)} ولېږل شو، '
                  '${num_(r.failed, t.locale)} ناکام — په کمپیوټر کې '
                  'لامل وګورئ.',
        r.failed == 0 ? M.success : M.warning,
      );
    } on ApiException catch (e) {
      if (mounted) _toast(e.message, M.danger);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _decide(LeaveInfo l, bool approve) async {
    try {
      await widget.api.decideLeave(l.id, approve: approve);
      if (!mounted) return;
      await _load();
      if (!mounted) return;
      _toast(
        approve ? 'اجازه ومنل شوه.' : 'اجازه رد شوه.',
        approve ? M.success : M.warning,
      );
    } on ApiException catch (e) {
      if (mounted) _toast(e.message, M.danger);
    }
  }

  void _toast(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        content: Text(text, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = context.pal;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.session.school.isEmpty ? t.appName : widget.session.school,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'تازه کړه',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, size: 21),
          ),
          IconButton(
            tooltip: 'اړیکه پرې کړه',
            onPressed: widget.onDisconnect,
            icon: const Icon(Icons.logout_rounded, size: 19),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _error != null && _summary == null
            ? ErrorState(message: _error!, onRetry: _load)
            : AnimatedSwitcher(
                duration: M.fast,
                child: KeyedSubtree(
                  key: ValueKey(_tab),
                  child: switch (_tab) {
                    0 => _buildHome(),
                    1 => _buildAbsentees(),
                    2 => _buildLeave(),
                    _ => _buildMore(),
                  },
                ),
              ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_rounded),
            label: t.home,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: (_summary?.unnotifiedAbsent ?? 0) > 0,
              label: Text(num_(_summary?.unnotifiedAbsent ?? 0, t.locale)),
              child: const Icon(Icons.event_busy_rounded),
            ),
            label: t.absentToday,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: (_summary?.pendingLeave ?? 0) > 0,
              label: Text(num_(_summary?.pendingLeave ?? 0, t.locale)),
              child: const Icon(Icons.event_available_rounded),
            ),
            label: t.pendingLeave,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_rounded),
            label: t.more,
          ),
        ],
      ),
    );
  }

  // ── کور ─────────────────────────────────────────────────

  Widget _buildHome() {
    final t = T.of(context);
    final p = context.pal;
    final s = _summary;

    if (_loading && s == null) return const LoadingState();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: t.presentToday,
                value: s?.present ?? 0,
                sub: '٪${num_(s?.presentPercent ?? 0, t.locale)}',
                gradient: M.gradEmerald,
                icon: Icons.how_to_reg_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: t.absentToday,
                value: s?.absent ?? 0,
                sub: 'له ${num_(s?.total ?? 0, t.locale)} تنو',
                gradient: M.gradRose,
                icon: Icons.person_off_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: 'ناوخته',
                value: s?.late ?? 0,
                gradient: M.gradAmber,
                icon: Icons.schedule_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: 'رخصت',
                value: s?.onLeave ?? 0,
                gradient: M.gradIndigo,
                icon: Icons.beach_access_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),

        Text(
          'خبرتیاوې',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: p.ink,
          ),
        ),
        const SizedBox(height: 10),

        if (_notifications.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'نوې خبرتیا نشته',
            hint: 'کله چې څوک غیرحاضر شي، دلته به ښکاره شي.',
          )
        else
          for (final n in _notifications) _notificationCard(n),
      ],
    );
  }

  Widget _notificationCard(NotificationInfo n) {
    final t = T.of(context);
    final p = context.pal;
    final actionable = n.isAbsenceDigest && !n.acted;
    final color = switch (n.kind) {
      'absence_digest' => M.danger,
      'leave_request' => M.info,
      _ => M.primary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(M.radiusLg),
        border: Border.all(
          color: n.read ? p.line : color.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  n.isAbsenceDigest
                      ? Icons.person_off_rounded
                      : Icons.event_available_rounded,
                  size: 17,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  n.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
              ),
              if (!n.read)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            n.body,
            style: TextStyle(fontSize: 13, height: 1.8, color: p.inkSoft),
          ),
          if (actionable) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _sending
                        ? null
                        : () async {
                            await widget.api.markNotificationRead(n.id);
                            await _notify(
                              ids: (n.payload?['studentIds'] as List?)
                                  ?.cast<num>()
                                  .map((e) => e.toInt())
                                  .toList(),
                            );
                          },
                    icon: _sending
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 17),
                    label: Text(
                      _sending ? 'لېږل کېږي…' : t.notifyParents,
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      minimumSize: const Size.fromHeight(46),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () => setState(() => _tab = 1),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(56, 46),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: const Text('وګوره'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── نن غیرحاضر ──────────────────────────────────────────

  Widget _buildAbsentees() {
    final t = T.of(context);
    final p = context.pal;

    if (_loading && _absentees.isEmpty) return const LoadingState();
    if (_absentees.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          EmptyState(
            icon: Icons.mark_email_read_rounded,
            title: 'هېڅوک نه دی پاتې',
            hint:
                'یا نن څوک غیرحاضر نه دی، یا ټولو والدینو ته پیغام '
                'تللی دی.',
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: _absentees.length,
            itemBuilder: (context, i) {
              final a = _absentees[i];
              final on = _selected.contains(a.studentId);
              return GestureDetector(
                onTap: () => setState(() {
                  if (!_selected.remove(a.studentId)) {
                    _selected.add(a.studentId);
                  }
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(M.radius),
                    border: Border.all(color: on ? M.primary : p.line),
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: M.fast,
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: on ? M.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(7),
                          border: Border.all(
                            color: on ? M.primary : p.line,
                            width: 1.7,
                          ),
                        ),
                        child: on
                            ? const Icon(
                                Icons.check_rounded,
                                size: 15,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              a.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: p.ink,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              a.className ?? '—',
                              style: TextStyle(fontSize: 12, color: p.muted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              (a.monthlyAbsences >= 3 ? M.danger : M.warning)
                                  .withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${num_(a.monthlyAbsences, t.locale)} ورځې',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: a.monthlyAbsences >= 3
                                ? M.danger
                                : M.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(top: BorderSide(color: p.line)),
          ),
          child: FilledButton.icon(
            onPressed: _selected.isEmpty || _sending ? null : () => _notify(),
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(
              _sending
                  ? 'لېږل کېږي…'
                  : '${num_(_selected.length, t.locale)} کورونو ته ولېږه',
            ),
          ),
        ),
      ],
    );
  }

  // ── اجازې ───────────────────────────────────────────────

  Widget _buildLeave() {
    final t = T.of(context);
    final p = context.pal;

    if (_loading && _leave.isEmpty) return const LoadingState();
    if (_leave.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          EmptyState(
            icon: Icons.event_available_rounded,
            title: 'هېڅ غوښتنه د تمې په حال کې نشته',
            hint: 'د والدینو له اپ یا له ریسیپشن څخه راځي.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _leave.length,
      itemBuilder: (context, i) {
        final l = _leave[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(M.radiusLg),
            border: Border.all(color: p.line),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.student,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                  ),
                  if (l.via == 'parent_app')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: M.info.withValues(alpha: 0.13),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'د والدینو له اپ',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: M.info,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l.className ?? '—',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.date_range_rounded, size: 15, color: p.muted),
                  const SizedBox(width: 8),
                  Text(
                    '${num_(l.fromDate, t.locale)} → '
                    '${num_(l.toDate, t.locale)}'
                    '  (${num_(l.days, t.locale)} ورځې)',
                    style: TextStyle(fontSize: 12.5, color: p.inkSoft),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 15, color: p.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        switch (l.reasonType) {
                          'sick' => 'ناروغي',
                          'family' => 'کورنۍ چاره',
                          'travel' => 'سفر',
                          'official' => 'رسمي',
                          _ => 'بل',
                        },
                        if (l.reasonText?.isNotEmpty ?? false) l.reasonText!,
                      ].join(' — '),
                      style: TextStyle(fontSize: 12.5, color: p.inkSoft),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () => _decide(l, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: M.success,
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text('ومنه'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _decide(l, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: const Text('رد'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── نور ─────────────────────────────────────────────────

  Widget _buildMore() {
    final p = context.pal;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfoCard(
          rows: [
            ('ښوونځی', widget.session.school),
            ('رول', 'مدیر'),
            ('دا وسیله', widget.session.deviceName),
            ('سرور', widget.session.baseUrl),
          ],
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: widget.onDisconnect,
          icon: const Icon(Icons.link_off_rounded, size: 18),
          label: const Text('له ښوونځي څخه اړیکه پرې کړه'),
          style: OutlinedButton.styleFrom(foregroundColor: M.danger),
        ),
        const SizedBox(height: 12),
        Text(
          'اړیکه پرې کول یوازې دا تلیفون بېلوي — د ښوونځي معلومات '
          'خوندي پاتې کېږي. بیا تړلو لپاره له مدیر څخه نوی کوډ وغواړئ.',
          style: TextStyle(fontSize: 11.5, height: 1.7, color: p.faint),
        ),
      ],
    );
  }
}
