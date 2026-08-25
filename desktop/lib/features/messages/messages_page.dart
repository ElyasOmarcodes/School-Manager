import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../data/repositories/notification_repository.dart';
import '../../data/repositories/student_repository.dart' show Paged;
import '../../widgets/data_table_view.dart';
import '../auth/auth_service.dart';

/// د پیغامونو پاڼه — د غیرحاضرۍ خبرتیا، تاریخچه، او کینډۍ.
///
/// **دا پاڼه ولې د حاضرۍ سره نه ده یو ځای؟** ځکه چې د حاضرۍ پاڼه
/// د دروازې د کارکوونکي ده — هغه یوازې سکین کوي. دا پاڼه د مدیر
/// ده. دوه بېل خلک، دوه بېلې پاڼې.
class MessagesPage extends StatefulWidget {
  final MessageRepository messages;
  final AttendanceRepository attendance;
  final NotificationRepository notifications;
  final Session session;
  final String schoolName;

  /// د ازموینې لپاره — چې «نن» ثابته وي.
  final DateTime Function()? clock;

  const MessagesPage({
    super.key,
    required this.messages,
    required this.attendance,
    required this.notifications,
    required this.session,
    required this.schoolName,
    this.clock,
  });

  @override
  State<MessagesPage> createState() => _MessagesPageState();
}

typedef _Absentee = ({Student student, String? className, int monthlyAbsences});

class _MessagesPageState extends State<MessagesPage> {
  int _tab = 0;
  late DateTime _date = dateOnly((widget.clock ?? DateTime.now)());

  bool _loading = true;
  List<_Absentee> _absentees = const [];
  final Set<int> _selected = {};

  String _templateKey = 'absence';
  List<MessageTemplate> _templates = const [];

  Paged<MessageRow> _log = const Paged([], 0);
  MessageStats _stats = const MessageStats();
  Deliverability _reach = const Deliverability();
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    await widget.messages.ensureDefaultTemplates();

    final absentees = await widget.attendance.absentees(
      _date,
      onlyUnnotified: true,
    );
    final templates = await widget.messages.templates();
    final log = await widget.messages.list(limit: 60);
    final stats = await widget.messages.stats();

    if (!mounted) return;
    setState(() {
      _absentees = absentees;
      _templates = templates;
      _log = log;
      _stats = stats;
      _loading = false;
      // د تلواله انتخاب: **ټول**. مدیر ډېر ځله ټولو ته لېږي، نو
      // هغه ته یو کلیک بس دی؛ که یو کس غواړي، نور له سره لرې کوي.
      _selected
        ..clear()
        ..addAll(absentees.map((a) => a.student.id));
    });
    await _refreshReach();
  }

  /// د انتخاب هر بدلون سره د لاسرسي انځور بیا شمېرل کېږي.
  Future<void> _refreshReach() async {
    final reach = await widget.messages.deliverability(
      _selected.toList(),
      _date,
    );
    if (!mounted) return;
    setState(() => _reach = reach);
  }

  void _toggle(int studentId) {
    setState(() {
      if (!_selected.remove(studentId)) _selected.add(studentId);
    });
    _refreshReach();
  }

  Future<void> _send() async {
    if (_selected.isEmpty || _sending) return;
    setState(() => _sending = true);

    final result = await widget.messages.notifyAbsentees(
      date: _date,
      studentIds: _selected.toList(),
      templateKey: _templateKey,
      byUserId: widget.session.userId,
      schoolName: widget.schoolName,
    );
    await widget.notifications.syncAbsenceDigest(
      date: _date,
      schoolName: widget.schoolName,
    );

    if (!mounted) return;
    setState(() => _sending = false);
    await _load();
    if (!mounted) return;

    final locale = S.of(context).locale;
    final failed = result.failed > 0;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 520,
        backgroundColor: failed ? AppColors.warning : AppColors.success,
        content: Text(
          failed
              ? '${locale.num(result.sent)} ولېږل شو، '
                    '${locale.num(result.failed)} ناکام — «تاریخچه» کې لامل وګورئ.'
              : '${locale.num(result.sent)} پیغامونه والدینو ته ولېږل شول.',
        ),
      ),
    );
  }

  Future<void> _retry() async {
    final r = await widget.messages.retryFailed();
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    final locale = S.of(context).locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: r.sent > 0 ? AppColors.success : AppColors.danger,
        content: Text(
          '${locale.num(r.sent)} بریالي، ${locale.num(r.failed)} بیا ناکام.',
        ),
      ),
    );
  }

  String get _previewBody {
    final tpl = _templates.where((t) => t.templateKey == _templateKey);
    final body = tpl.isEmpty
        ? builtInTemplates.firstWhere((t) => t.key == _templateKey).body
        : tpl.first.body;

    final sample = _absentees.where((a) => _selected.contains(a.student.id));
    if (sample.isEmpty) return body;

    final a = sample.first;
    return renderTemplate(body, {
      'student': [
        a.student.firstName,
        if (a.student.lastName?.isNotEmpty ?? false) a.student.lastName,
      ].join(' '),
      'guardian': 'سرپرست',
      'class': a.className ?? '—',
      'date': _iso(_date),
      'school': widget.schoolName,
      'count': '${a.monthlyAbsences}',
    });
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
                  (0, 'د غیرحاضرۍ خبرتیا'),
                  (1, 'د لېږلو تاریخچه'),
                  (2, 'کینډۍ'),
                ]) ...[
                  _Tab(
                    label: t.$2,
                    selected: _tab == t.$1,
                    onTap: () => setState(() => _tab = t.$1),
                  ),
                  const SizedBox(width: 8),
                ],
                const Spacer(),
                _StatPill(
                  label: 'رسېدلي',
                  value: _stats.delivered,
                  color: AppColors.success,
                ),
                const SizedBox(width: 8),
                _StatPill(
                  label: 'ناکام',
                  value: _stats.failed,
                  color: AppColors.danger,
                  onTap: _stats.failed == 0 ? null : _retry,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
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
                  0 => _buildCompose(p),
                  1 => _buildLog(),
                  _ => _buildTemplates(p),
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── ۱: خبرتیا ───────────────────────────────────────────

  Widget _buildCompose(AppPalette p) {
    final locale = S.of(context).locale;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── د غیرحاضرو لیست ──────────────────────────────
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    'د ${locale.num(_iso(_date))} غیرحاضران',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(width: 10),
                  _DayNudge(
                    icon: Icons.chevron_right_rounded,
                    onTap: () {
                      setState(
                        () => _date = _date.subtract(const Duration(days: 1)),
                      );
                      _load();
                    },
                  ),
                  _DayNudge(
                    icon: Icons.chevron_left_rounded,
                    enabled: _date.isBefore(
                      dateOnly((widget.clock ?? DateTime.now)()),
                    ),
                    onTap: () {
                      setState(
                        () => _date = _date.add(const Duration(days: 1)),
                      );
                      _load();
                    },
                  ),
                  const Spacer(),
                  if (_absentees.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          if (_selected.length == _absentees.length) {
                            _selected.clear();
                          } else {
                            _selected
                              ..clear()
                              ..addAll(_absentees.map((a) => a.student.id));
                          }
                        });
                        _refreshReach();
                      },
                      child: Text(
                        _selected.length == _absentees.length
                            ? 'هېڅ مه ټاکه'
                            : 'ټول وټاکه',
                        style: const TextStyle(fontSize: 12.5),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: DataTableView<_Absentee>(
                  loading: _loading,
                  rows: _absentees,
                  emptyIcon: Icons.mark_email_read_rounded,
                  emptyTitle: 'هېڅوک نه دی پاتې',
                  emptyHint:
                      'یا نن څوک غیرحاضر نه دی، یا ټولو والدینو ته '
                      'پیغام تللی. د «تاریخچه» ټب کې يې وګورئ.',
                  onRowTap: (a) => _toggle(a.student.id),
                  columns: [
                    TableColumn(
                      title: '',
                      width: 44,
                      cell: (context, a) => _Check(
                        on: _selected.contains(a.student.id),
                        onTap: () => _toggle(a.student.id),
                      ),
                    ),
                    TableColumn(
                      title: 'شاګرد',
                      flex: 3,
                      cell: (context, a) => Row(
                        children: [
                          AvatarCell(
                            name: a.student.firstName,
                            color: AppColors.modMessages,
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  [
                                    a.student.firstName,
                                    if (a.student.lastName?.isNotEmpty ?? false)
                                      a.student.lastName,
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
                                  a.className ?? '—',
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
                      title: 'د میاشتې غیرحاضري',
                      width: 150,
                      // درې یا ډېرې ورځې = سور. مدیر باید په یوه
                      // نظر وویني چې کوم کور ته زنګ وهل پکار دي.
                      cell: (context, a) => StatusChip(
                        label: '${locale.num(a.monthlyAbsences)} ورځې',
                        color: a.monthlyAbsences >= 3
                            ? AppColors.danger
                            : a.monthlyAbsences == 2
                            ? AppColors.warning
                            : AppColors.modAttendance,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),

        // ── د پیغام چمتووالی ─────────────────────────────
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'کینډۍ',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _templates.where(
                      (t) => t.templateKey.startsWith('absence'),
                    ))
                      _Chip(
                        label: t.title,
                        selected: _templateKey == t.templateKey,
                        onTap: () =>
                            setState(() => _templateKey = t.templateKey),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'د پیغام بېلګه',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxHeight: 190),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: p.surfaceAlt,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    border: Border.all(color: p.line),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _previewBody,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.85,
                        color: p.inkSoft,
                      ),
                    ),
                  ),
                ),
                const Spacer(),

                // **مخکې له لېږلو ریښتیا.** مدیر باید پوه شي چې څو
                // کورونه واقعاً لاسرسي وړ دي — نه دا چې وروسته د
                // ناکامۍ لیست وویني.
                Row(
                  children: [
                    Text(
                      'لاسرسی',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: p.muted,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${locale.num(_selected.length)} کورونه ټاکل شوي',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.modMessages,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                _ReachRow(
                  icon: Icons.phone_iphone_rounded,
                  label: 'د اپ له لارې',
                  value: _reach.viaApp,
                  color: AppColors.success,
                ),
                _ReachRow(
                  icon: Icons.sms_rounded,
                  label: 'د SMS له لارې',
                  value: _reach.viaSms,
                  color: AppColors.modAttendance,
                ),
                _ReachRow(
                  icon: Icons.link_off_rounded,
                  label: 'لار نشته — نه اپ، نه شمېره',
                  value: _reach.unreachable,
                  color: AppColors.danger,
                ),
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: _selected.isEmpty || _sending ? null : _send,
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
                    _sending ? 'لېږل کېږي…' : 'والدینو ته ولېږه',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modMessages,
                    minimumSize: const Size.fromHeight(46),
                    textStyle: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'پیغام هغه کورونو ته ځي چې اپ يې تړلی، او هغو ته '
                  'چې د SMS دروازه تنظیم شوې وي. ناکام پیغامونه '
                  'له منځه نه ځي — په «تاریخچه» کې بیا هڅه کولی شئ.',
                  style: TextStyle(fontSize: 11.5, height: 1.7, color: p.faint),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── ۲: تاریخچه ──────────────────────────────────────────

  Widget _buildLog() {
    final p = context.palette;
    final locale = S.of(context).locale;

    return DataTableView<MessageRow>(
      loading: _loading,
      rows: _log.items,
      emptyIcon: Icons.forum_rounded,
      emptyTitle: 'لا هېڅ پیغام نه دی تللی',
      emptyHint: 'کله چې د غیرحاضرۍ خبرتیا ولېږئ، دلته به ښکاره شي.',
      columns: [
        TableColumn(
          title: 'شاګرد',
          flex: 3,
          cell: (context, r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.studentName ?? '—',
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
        TableColumn(
          title: 'چا ته',
          flex: 2,
          cell: (context, r) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                r.message.toName ?? '—',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: p.inkSoft),
              ),
              if (r.message.toPhone != null)
                Text(
                  locale.num(r.message.toPhone!),
                  style: AppTheme.tabular(
                    TextStyle(fontSize: 11, color: p.faint),
                  ),
                ),
            ],
          ),
        ),
        TableColumn(
          title: 'کانال',
          width: 92,
          cell: (context, r) => Row(
            children: [
              Icon(
                r.message.channel == 'sms'
                    ? Icons.sms_rounded
                    : Icons.phone_iphone_rounded,
                size: 15,
                color: p.muted,
              ),
              const SizedBox(width: 6),
              Text(
                r.message.channel == 'sms' ? 'SMS' : 'اپ',
                style: TextStyle(fontSize: 12, color: p.inkSoft),
              ),
            ],
          ),
        ),
        TableColumn(
          title: 'حالت',
          width: 190,
          cell: (context, r) => Row(
            children: [
              StatusChip(
                label: switch (r.message.status) {
                  'sent' => 'ولېږل شو',
                  'read' => 'ولوستل شو',
                  'failed' => 'ناکام',
                  _ => 'په قطار کې',
                },
                color: switch (r.message.status) {
                  'read' => AppColors.success,
                  'sent' => AppColors.modAttendance,
                  'failed' => AppColors.danger,
                  _ => AppColors.warning,
                },
              ),
              if (r.message.error != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    r.message.error!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.danger),
                  ),
                ),
              ],
            ],
          ),
        ),
        TableColumn(
          title: 'کله',
          width: 118,
          cell: (context, r) => Text(
            locale.num(_stamp(r.message.createdAt)),
            style: AppTheme.tabular(TextStyle(fontSize: 12, color: p.muted)),
          ),
        ),
      ],
    );
  }

  // ── ۳: کینډۍ ────────────────────────────────────────────

  Widget _buildTemplates(AppPalette p) {
    return ListView.separated(
      itemCount: _templates.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final t = _templates[i];
        return FadeSlideIn(
          delay: AppMotion.staggerFor(i),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(AppTheme.radius),
              border: Border.all(color: p.line),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_rounded,
                      size: 16,
                      color: AppColors.modMessages,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      t.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t.templateKey,
                        style: TextStyle(
                          fontSize: 10.5,
                          color: p.faint,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _TemplateEditor(
                  initial: t.body,
                  onSave: (v) async {
                    await widget.messages.saveTemplateBody(t.templateKey, v);
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

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';

  static String _stamp(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}'
      '  ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════
//  کوچني توکي
// ═══════════════════════════════════════════════════════════

class _TemplateEditor extends StatefulWidget {
  final String initial;
  final Future<void> Function(String) onSave;

  const _TemplateEditor({required this.initial, required this.onSave});

  @override
  State<_TemplateEditor> createState() => _TemplateEditorState();
}

class _TemplateEditorState extends State<_TemplateEditor> {
  late final TextEditingController _c = TextEditingController(
    text: widget.initial,
  );
  bool _dirty = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _c,
          maxLines: null,
          minLines: 3,
          onChanged: (_) => setState(() => _dirty = true),
          style: TextStyle(fontSize: 13, height: 1.8, color: p.inkSoft),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'ځای‌نیوونکي: {student} {guardian} {class} {date} '
                '{school} {count}',
                style: TextStyle(fontSize: 11, color: p.faint),
              ),
            ),
            AnimatedOpacity(
              duration: AppMotion.fast,
              opacity: _dirty ? 1 : 0.35,
              child: FilledButton(
                onPressed: !_dirty
                    ? null
                    : () async {
                        await widget.onSave(_c.text);
                        if (mounted) setState(() => _dirty = false);
                      },
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('وساتـه'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Check extends StatelessWidget {
  final bool on;
  final VoidCallback onTap;
  const _Check({required this.on, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.instant,
        curve: AppMotion.standard,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: on ? AppColors.modMessages : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: on ? AppColors.modMessages : p.line,
            width: 1.6,
          ),
        ),
        child: on
            ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
            : null,
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
              ? AppColors.modMessages.withValues(alpha: 0.11)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: selected ? AppColors.modMessages : p.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modMessages : p.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
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
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modMessages.withValues(alpha: 0.13)
              : p.surfaceAlt,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AppColors.modMessages : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modMessages : p.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final VoidCallback? onTap;

  const _StatPill({
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locale.num(value),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(Icons.refresh_rounded, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }
}

class _DayNudge extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _DayNudge({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      borderRadius: BorderRadius.circular(7),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? p.muted : p.line,
        ),
      ),
    );
  }
}

class _ReachRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _ReachRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final off = value == 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, size: 15, color: off ? p.faint : color),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: off ? p.faint : p.inkSoft,
              ),
            ),
          ),
          Text(
            locale.num(value),
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: off ? p.faint : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
