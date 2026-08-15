import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/attendance_session_repository.dart';

/// «حاضري اخیستل» — د موجودو ناستو لیست.
///
/// **ولې لومړی لیست، بیا سکینر؟** ځکه چې یو ښوونځی یوه حاضري نه
/// لري. مدرسه سهار د ټولو حاضري اخلي، بیا د شپې ۸:۰۰ بجې یوازې د
/// لیلیه شاګردانو. که سکینر مستقیم پرانیستل شوی وای، د شپې سکین
/// به د سهار ریکارډ بدل کړ.
class SessionsPage extends StatefulWidget {
  final AttendanceSessionRepository sessions;
  final DateTime Function() clock;

  /// یوه ناسته پرانیستل — `null` یعنې د ورځې عمومي حاضري.
  final void Function(AttendanceSession?) onOpen;
  final VoidCallback? onCreate;

  const SessionsPage({
    super.key,
    required this.sessions,
    required this.onOpen,
    this.onCreate,
    this.clock = DateTime.now,
  });

  @override
  State<SessionsPage> createState() => _SessionsPageState();
}

class _SessionsPageState extends State<SessionsPage> {
  List<({AttendanceSession session, SessionStatus status})> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // که هېڅ ناسته نه وي، تلواله جوړېږي — پرته له دې به پاڼه تشه
    // وه او کارن به نه پوهېده چې له کوم ځایه پیل وکړي.
    await widget.sessions.seedDefault();
    final list = await widget.sessions.list();
    final now = widget.clock();
    final items = <({AttendanceSession session, SessionStatus status})>[];
    for (final s in list) {
      items.add((
        session: s,
        status: await widget.sessions.status(session: s, now: now),
      ));
    }
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final liveCount = _items.where((i) => i.status.isLive).length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: Row(
            children: [
              Text(
                s.attendanceTaking,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 12),
              if (liveCount > 0)
                Pill(
                  color: AppColors.success,
                  filled: true,
                  icon: Icons.sensors_rounded,
                  text: '${locale.num(liveCount)} ${s.live}',
                ),
              const Spacer(),
              if (widget.onCreate != null)
                FilledButton.icon(
                  onPressed: widget.onCreate,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: Text(s.newSession),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modAttendance,
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: _items.isEmpty
              ? const EmptyState(
                  icon: Icons.fact_check_rounded,
                  text: 'لا هېڅ د حاضرۍ ناسته نه ده جوړه شوې.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
                  itemCount: _items.length,
                  itemBuilder: (context, i) => FadeSlideIn.staggered(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SessionCard(
                        session: _items[i].session,
                        status: _items[i].status,
                        onTap: () => widget.onOpen(
                          _items[i].session.isDefault
                              ? _items[i].session
                              : _items[i].session,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

/// د یوې ناستې کارت — نوم، هدف، وخت او د نن پرمختګ.
class SessionCard extends StatefulWidget {
  final AttendanceSession session;
  final SessionStatus status;
  final VoidCallback? onTap;
  final List<Widget> actions;

  const SessionCard({
    super.key,
    required this.session,
    required this.status,
    this.onTap,
    this.actions = const [],
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final st = widget.status;
    final sess = widget.session;
    final c = st.isLive ? AppColors.success : AppColors.modAttendance;

    return MouseRegion(
      cursor: widget.onTap == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: _hover ? c.withValues(alpha: 0.5) : p.line,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: c.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(_targetIcon(sess.target), size: 19, color: c),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Text(
                              sess.name,
                              style: TextStyle(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: p.ink,
                              ),
                            ),
                            const SizedBox(width: 9),
                            if (st.isLive)
                              const Pill(
                                color: AppColors.success,
                                filled: true,
                                icon: Icons.sensors_rounded,
                                text: 'اوس روان دی',
                              )
                            else if (!sess.isActive)
                              Pill(color: p.faint, text: 'بند'),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${targetLabel(sess.target, s)}  ·  '
                          '${locale.num(sess.startTime)}–'
                          '${locale.num(sess.endTime)}  ·  '
                          '${_daysLabel(sess.days, locale)}',
                          style: TextStyle(fontSize: 12, color: p.muted),
                        ),
                      ],
                    ),
                  ),
                  ...widget.actions,
                  if (widget.onTap != null && widget.actions.isEmpty)
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 22,
                      color: _hover ? c : p.faint,
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Text(
                    '${locale.num(st.markedCount)} له '
                    '${locale.num(st.targetCount)} څخه ثبت شوي',
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 12, color: p.muted),
                    ),
                  ),
                  const Spacer(),
                  Pill(
                    color: AppColors.success,
                    text: '${s.present}: ${locale.num(st.presentCount)}',
                  ),
                  const SizedBox(width: 6),
                  Pill(
                    color: st.pending > 0 ? AppColors.warning : p.faint,
                    text: '${s.unmarked}: ${locale.num(st.pending)}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: st.progress.clamp(0.0, 1.0)),
                  duration: AppMotion.slow,
                  curve: AppMotion.emphasized,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 5,
                    backgroundColor: p.surfaceAlt,
                    valueColor: AlwaysStoppedAnimation(c),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _targetIcon(String target) => switch (target) {
    'boarding' => Icons.night_shelter_rounded,
    'day' => Icons.wb_sunny_rounded,
    'section' => Icons.meeting_room_rounded,
    'grade' => Icons.school_rounded,
    _ => Icons.groups_rounded,
  };
}

String targetLabel(String target, S s) => switch (target) {
  'day' => s.dayScholar,
  'boarding' => s.boarder,
  'section' => 'یو بخش',
  'grade' => 'یوه درجه',
  _ => 'ټول شاګردان',
};

/// «6,7,1,2,3» → «شنبه، یکشنبه، دوشنبه…» — خو لنډ.
String _daysLabel(String days, AppLocale locale) {
  const names = {
    1: 'دوشنبه',
    2: 'سه‌شنبه',
    3: 'چهارشنبه',
    4: 'پنجشنبه',
    5: 'جمعه',
    6: 'شنبه',
    7: 'یکشنبه',
  };
  final list = days
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .toList();
  if (list.length >= 7) return 'هره ورځ';
  if (list.isEmpty) return '—';
  return list.map((d) => names[d] ?? '$d').join('، ');
}
