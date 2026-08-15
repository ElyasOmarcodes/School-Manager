import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/design.dart';
import '../core/session_store.dart';
import '../core/strings.dart';
import 'widgets.dart';

/// د والدینو اپ.
///
/// **دا اپ څه وايي؟** یو پلار چې لیک لوست نه شي کولی هم باید په یوه
/// نظر پوه شي چې «زما زوی نن حاضر و که نه». نو د میاشتې کلیز د
/// رنګونو په بڼه دی — شین حاضر، سور غیرحاضر، ژېړ ناوخته.
class ParentHome extends StatefulWidget {
  final SchoolSession session;
  final ApiClient api;
  final VoidCallback onDisconnect;

  const ParentHome({
    super.key,
    required this.session,
    required this.api,
    required this.onDisconnect,
  });

  @override
  State<ParentHome> createState() => _ParentHomeState();
}

class _ParentHomeState extends State<ParentHome> {
  int _tab = 0;
  bool _loading = true;
  String? _error;

  List<ChildInfo> _children = const [];
  int _childIndex = 0;
  ChildAttendance? _attendance;
  List<ExamResultInfo> _results = const [];
  List<ParentMessage> _messages = const [];

  /// د دویم ټب دننه: حاضري که نمرې.
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  ChildInfo? get _child =>
      _children.isEmpty ? null : _children[_childIndex.clamp(0, _children.length - 1)];

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final children = await widget.api.children();
      final messages = await widget.api.messages();
      ChildAttendance? att;
      var results = <ExamResultInfo>[];
      if (children.isNotEmpty) {
        final id = children[_childIndex.clamp(0, children.length - 1)].id;
        att = await widget.api.childAttendance(id);
        results = await widget.api.childResults(id);
      }

      if (!mounted) return;
      setState(() {
        _children = children;
        _messages = messages;
        _attendance = att;
        _results = results;
        _loading = false;
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

  Future<void> _pickChild(int i) async {
    setState(() {
      _childIndex = i;
      _attendance = null;
      _results = const [];
    });
    try {
      final att = await widget.api.childAttendance(_children[i].id);
      final res = await widget.api.childResults(_children[i].id);
      if (mounted) {
        setState(() {
          _attendance = att;
          _results = res;
        });
      }
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
    final unread = _messages.where((m) => !m.read).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.session.school.isEmpty ? t.myChildren : widget.session.school,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded, size: 21),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _error != null && _children.isEmpty
            ? ErrorState(message: _error!, onRetry: _load)
            : AnimatedSwitcher(
                duration: M.fast,
                child: KeyedSubtree(
                  key: ValueKey(_tab),
                  child: switch (_tab) {
                    0 => _buildChildren(),
                    1 => _buildAttendance(),
                    2 => _buildMessages(),
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
            icon: const Icon(Icons.fact_check_rounded),
            label: t.attendance,
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: unread > 0,
              label: Text(num_(unread, t.locale)),
              child: const Icon(Icons.forum_rounded),
            ),
            label: t.messages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.more_horiz_rounded),
            label: t.more,
          ),
        ],
      ),
    );
  }

  // ── ماشومان ─────────────────────────────────────────────

  Widget _buildChildren() {
    final t = T.of(context);
    final p = context.pal;

    if (_loading && _children.isEmpty) return const LoadingState();
    if (_children.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          EmptyState(
            icon: Icons.child_care_rounded,
            title: 'هېڅ شاګرد ستاسو نوم ته نه دی تړل شوی',
            hint: 'له ښوونځي څخه وغواړئ چې ستاسو نوم د شاګرد سرپرست وټاکي.',
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final (i, c) in _children.indexed) ...[
          GestureDetector(
            onTap: () {
              _pickChild(i);
              setState(() => _tab = 1);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(M.radiusLg),
                border: Border.all(color: p.line),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: M.gradIndigo,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: Text(
                            c.name.characters.first,
                            style: const TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: p.ink,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${c.className ?? '—'}  •  '
                              '${num_(c.admissionNo, t.locale)}',
                              style: TextStyle(fontSize: 12, color: p.muted),
                            ),
                          ],
                        ),
                      ),
                      _Ring(percent: c.attendancePercent),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _Mini(
                        label: 'حاضر',
                        value: c.monthPresent,
                        color: M.success,
                      ),
                      _Mini(
                        label: 'غیرحاضر',
                        value: c.monthAbsent,
                        color: M.danger,
                      ),
                      _Mini(
                        label: 'رخصت',
                        value: c.monthLeave,
                        color: M.info,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 6),
        FilledButton.icon(
          onPressed: _children.isEmpty ? null : _openLeaveSheet,
          icon: const Icon(Icons.edit_calendar_rounded, size: 18),
          label: Text(t.requestLeave),
        ),
      ],
    );
  }

  // ── حاضري ───────────────────────────────────────────────

  Widget _buildAttendance() {
    final t = T.of(context);
    final p = context.pal;
    final child = _child;

    if (child == null) {
      return const EmptyState(
        icon: Icons.fact_check_rounded,
        title: 'لومړی یو شاګرد وټاکئ',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_children.length > 1)
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _children.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final on = i == _childIndex;
                return GestureDetector(
                  onTap: () => _pickChild(i),
                  child: AnimatedContainer(
                    duration: M.fast,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on
                          ? M.primary.withValues(alpha: 0.13)
                          : p.surfaceAlt,
                      borderRadius: BorderRadius.circular(M.radius),
                      border: Border.all(
                        color: on ? M.primary : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      _children[i].name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                        color: on ? M.primary : p.inkSoft,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        if (_children.length > 1) const SizedBox(height: 18),

        // حاضري که نمرې — یو ټب، دوه انځورونه.
        Row(
          children: [
            Expanded(
              child: _Segment(
                label: t.attendance,
                on: !_showResults,
                onTap: () => setState(() => _showResults = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Segment(
                label: t.results,
                on: _showResults,
                badge: _results.length,
                onTap: () => setState(() => _showResults = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        if (_showResults)
          ..._buildResults()
        else if (_attendance == null)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: LoadingState(),
          )
        else ...[
          Text(
            '${child.name} — ${num_(_attendance!.month, t.locale)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 16),
          _MonthGrid(attendance: _attendance!),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 14,
            runSpacing: 10,
            children: [
              _Legend(color: M.success, label: 'حاضر'),
              _Legend(color: M.warning, label: 'ناوخته'),
              _Legend(color: M.danger, label: 'غیرحاضر'),
              _Legend(color: M.info, label: 'رخصت'),
            ],
          ),
        ],
      ],
    );
  }

  // ── نمرې ────────────────────────────────────────────────

  List<Widget> _buildResults() {
    if (_results.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.assignment_rounded,
          title: 'لا هېڅ پایله نه ده خپره شوې',
          hint:
              'کله چې ښوونځی د ازموینې نمرې خپرې کړي، دلته به ښکاره شي.',
        ),
      ];
    }
    return [for (final r in _results) _ResultCard(result: r)];
  }

  // ── پیغامونه ────────────────────────────────────────────

  Widget _buildMessages() {
    final t = T.of(context);
    final p = context.pal;

    if (_loading && _messages.isEmpty) return const LoadingState();
    if (_messages.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          EmptyState(
            icon: Icons.forum_rounded,
            title: 'هېڅ پیغام نشته',
            hint: 'کله چې ښوونځی درته څه ولیکي، دلته به ښکاره شي.',
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, i) {
        final m = _messages[i];
        return GestureDetector(
          onTap: m.read
              ? null
              : () async {
                  await widget.api.markMessagesRead([m.id]);
                  await _load();
                },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(M.radiusLg),
              border: Border.all(
                color: m.read ? p.line : M.primary.withValues(alpha: 0.35),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      switch (m.kind) {
                        'absence' => Icons.person_off_rounded,
                        'fee' => Icons.payments_rounded,
                        _ => Icons.campaign_rounded,
                      },
                      size: 16,
                      color: m.read ? p.muted : M.primary,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      switch (m.kind) {
                        'absence' => 'د غیرحاضرۍ خبرتیا',
                        'leave' => 'د رخصتۍ ځواب',
                        'fee' => 'د فیس یادونه',
                        _ => 'اعلان',
                      },
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: m.read ? p.muted : M.primary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      num_(_stamp(m.createdAt), t.locale),
                      style: TextStyle(fontSize: 11, color: p.faint),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Text(
                  m.body,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.85,
                    color: p.inkSoft,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── نور ─────────────────────────────────────────────────

  Widget _buildMore() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        InfoCard(
          rows: [
            ('ښوونځی', widget.session.school),
            ('سرپرست', widget.session.guardianName ?? '—'),
            ('دا وسیله', widget.session.deviceName),
            ('سرور', widget.session.baseUrl),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _children.isEmpty ? null : _openLeaveSheet,
          icon: const Icon(Icons.edit_calendar_rounded, size: 18),
          label: Text(T.of(context).requestLeave),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: widget.onDisconnect,
          icon: const Icon(Icons.link_off_rounded, size: 18),
          label: const Text('اړیکه پرې کړه'),
          style: OutlinedButton.styleFrom(foregroundColor: M.danger),
        ),
      ],
    );
  }

  // ── د اجازې غوښتنه ──────────────────────────────────────

  void _openLeaveSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.pal.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _LeaveSheet(
        children: _children,
        initialIndex: _childIndex,
        onSubmit: (studentId, reason, text, from, to) async {
          try {
            await widget.api.requestLeave(
              studentId: studentId,
              reasonType: reason,
              reasonText: text,
              fromDate: from,
              toDate: to,
            );
            if (!mounted) return;
            _toast('غوښتنه ولېږل شوه — د ښوونځي د ځواب په تمه.', M.success);
            await _load();
          } on ApiException catch (e) {
            if (mounted) _toast(e.message, M.danger);
          }
        },
      ),
    );
  }

  static String _stamp(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════

/// د میاشتې کلیز — هره ورځ یو رنګ.
class _MonthGrid extends StatelessWidget {
  final ChildAttendance attendance;
  const _MonthGrid({required this.attendance});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final t = T.of(context);
    final parts = attendance.month.split('-');
    final year = int.tryParse(parts.first) ?? DateTime.now().year;
    final month = parts.length > 1
        ? (int.tryParse(parts[1]) ?? DateTime.now().month)
        : DateTime.now().month;
    final days = DateTime(year, month + 1, 0).day;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var d = 1; d <= days; d++)
          Builder(
            builder: (context) {
              final key =
                  '$year-${month.toString().padLeft(2, '0')}'
                  '-${d.toString().padLeft(2, '0')}';
              final status = attendance.byDate[key];
              final color = switch (status) {
                'present' => M.success,
                'late' => M.warning,
                'absent' => M.danger,
                'leave' => M.info,
                _ => null,
              };

              return Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color?.withValues(alpha: 0.14) ?? p.surfaceAlt,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: color?.withValues(alpha: 0.4) ?? Colors.transparent,
                  ),
                ),
                child: Text(
                  num_(d, t.locale),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: color == null
                        ? FontWeight.w500
                        : FontWeight.w700,
                    color: color ?? p.faint,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.55)),
        ),
      ),
      const SizedBox(width: 7),
      Text(
        label,
        style: TextStyle(fontSize: 12, color: context.pal.inkSoft),
      ),
    ],
  );
}

class _Ring extends StatelessWidget {
  final int percent;
  const _Ring({required this.percent});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final color = percent >= 90
        ? M.success
        : percent >= 75
        ? M.warning
        : M.danger;

    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: percent / 100),
            duration: const Duration(milliseconds: 700),
            curve: M.ease,
            builder: (_, v, _) => SizedBox(
              width: 46,
              height: 46,
              child: CircularProgressIndicator(
                value: v,
                strokeWidth: 4,
                backgroundColor: color.withValues(alpha: 0.14),
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          Text(
            num_(percent, t.locale),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Mini extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _Mini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            num_(value, t.locale),
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(fontSize: 11.5, color: context.pal.muted),
          ),
        ],
      ),
    );
  }
}

/// د رخصتۍ د غوښتنې پرده.
class _LeaveSheet extends StatefulWidget {
  final List<ChildInfo> children;
  final int initialIndex;
  final Future<void> Function(
    int studentId,
    String reason,
    String? text,
    DateTime from,
    DateTime to,
  )
  onSubmit;

  const _LeaveSheet({
    required this.children,
    required this.initialIndex,
    required this.onSubmit,
  });

  @override
  State<_LeaveSheet> createState() => _LeaveSheetState();
}

class _LeaveSheetState extends State<_LeaveSheet> {
  late int _index = widget.initialIndex.clamp(0, widget.children.length - 1);
  String _reason = 'sick';
  final _note = TextEditingController();
  late DateTime _from = DateTime.now();
  late DateTime _to = DateTime.now();
  bool _busy = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickRange() async {
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 120)),
      initialDateRange: DateTimeRange(start: _from, end: _to),
    );
    if (r != null) {
      setState(() {
        _from = r.start;
        _to = r.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = context.pal;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 22,
        bottom: MediaQuery.of(context).viewInsets.bottom + 22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.requestLeave,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: p.ink,
            ),
          ),
          const SizedBox(height: 18),

          if (widget.children.length > 1) ...[
            Wrap(
              spacing: 8,
              children: [
                for (final (i, c) in widget.children.indexed)
                  ChoiceChip(
                    label: Text(c.name),
                    selected: i == _index,
                    onSelected: (_) => setState(() => _index = i),
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in const [
                ('sick', 'ناروغي'),
                ('family', 'کورنۍ چاره'),
                ('travel', 'سفر'),
                ('other', 'بل'),
              ])
                ChoiceChip(
                  label: Text(r.$2),
                  selected: _reason == r.$1,
                  onSelected: (_) => setState(() => _reason = r.$1),
                ),
            ],
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: _pickRange,
            icon: const Icon(Icons.date_range_rounded, size: 18),
            label: Text(
              '${num_(_iso(_from), t.locale)} → ${num_(_iso(_to), t.locale)}',
            ),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _note,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'لنډ توضیح (اختیاري)',
            ),
          ),
          const SizedBox(height: 18),

          FilledButton(
            onPressed: _busy
                ? null
                : () async {
                    setState(() => _busy = true);
                    await widget.onSubmit(
                      widget.children[_index].id,
                      _reason,
                      _note.text.trim().isEmpty ? null : _note.text.trim(),
                      _from,
                      _to,
                    );
                    if (context.mounted) Navigator.pop(context);
                  },
            child: _busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      color: Colors.white,
                    ),
                  )
                : const Text('غوښتنه ولېږه'),
          ),
        ],
      ),
    );
  }

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}

/// د یوې خپرې شوې ازموینې کارت.
class _ResultCard extends StatefulWidget {
  final ExamResultInfo result;
  const _ResultCard({required this.result});

  @override
  State<_ResultCard> createState() => _ResultCardState();
}

class _ResultCardState extends State<_ResultCard> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final t = T.of(context);
    final r = widget.result;
    final color = r.passed ? M.success : M.danger;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(M.radiusLg),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      r.grade,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          r.exam,
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: p.ink,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${num_(r.date, t.locale)}  •  '
                          'مقام ${num_(r.rank, t.locale)} '
                          'له ${num_(r.outOf, t.locale)} څخه',
                          style: TextStyle(fontSize: 11.5, color: p.muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '٪${num_(r.percent, t.locale)}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: color,
                        ),
                      ),
                      Text(
                        r.gradeLabel,
                        style: TextStyle(fontSize: 11, color: p.muted),
                      ),
                    ],
                  ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _open ? 0.5 : 0,
                    duration: M.fast,
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: p.faint,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: M.normal,
            curve: M.ease,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    color: p.surfaceAlt,
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                    child: Column(
                      children: [
                        for (final s in r.subjects)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Row(
                              children: [
                                Icon(
                                  s.passed
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  size: 15,
                                  color: s.passed ? M.success : M.danger,
                                ),
                                const SizedBox(width: 9),
                                Expanded(
                                  child: Text(
                                    s.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                ),
                                Text(
                                  s.absent
                                      ? 'غیرحاضر'
                                      : '${num_(_n(s.obtained ?? 0), t.locale)}'
                                            ' / ${num_(s.full, t.locale)}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: s.absent
                                        ? M.danger
                                        : (s.passed ? p.ink : M.danger),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 8),
                        Divider(color: p.line, height: 1),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'مجموعه',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink,
                                ),
                              ),
                            ),
                            Text(
                              '${num_(_n(r.obtained), t.locale)} / '
                              '${num_(r.full, t.locale)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  static String _n(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);
}

/// د دوو حالتونو ټاکونکی — حاضري / نمرې.
class _Segment extends StatelessWidget {
  final String label;
  final bool on;
  final int badge;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.on,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final t = T.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: M.fast,
        curve: M.ease,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? M.primary.withValues(alpha: 0.13) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(M.radius),
          border: Border.all(color: on ? M.primary : Colors.transparent),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: on ? FontWeight.w700 : FontWeight.w500,
                color: on ? M.primary : p.inkSoft,
              ),
            ),
            if (badge > 0) ...[
              const SizedBox(width: 7),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: (on ? M.primary : p.muted).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  num_(badge, t.locale),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: on ? M.primary : p.muted,
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
