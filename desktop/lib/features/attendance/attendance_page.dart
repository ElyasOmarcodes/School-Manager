import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/tone.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_session_repository.dart';
import '../../data/repositories/holiday_repository.dart';
import '../../data/repositories/staff_attendance_repository.dart';
import '../auth/auth_service.dart';
import 'camera_scan.dart';
import 'manual_roster.dart';
import 'personnel_roster.dart';
import 'scan_feedback.dart';

/// د حاضرۍ پاڼه — د دروازې پرده.
///
/// **د ډیزاین اصل:** دا پرده د یوه کارکوونکي مخې ته ده چې په ۵
/// دقیقو کې ۳۰۰ شاګردان تېروي. نو:
///   - د متن خانه **تل** فوکس ساتي — USB سکینر ځان کیبورډ ښیي او
///     متن + Enter لیکي. که فوکس ورک شي، سکین ضایع کېږي.
///   - پایله **لویه او رنګینه** ده — کارکوونکی له یوه متره ګوري.
///   - QR، د ګوتې نښه او لاسي آی‌ډي **یوې خانې** ته ځي، نو د حالت
///     بدلولو ته اړتیا نشته — د ګوتو لوستونکی هم کیبورډ ښیي.
class AttendancePage extends StatefulWidget {
  final AttendanceRepository attendance;
  final AcademicRepository academic;
  final Session session;

  /// کومې ناستې لپاره حاضري اخیستل کېږي. `null` = د ورځې عمومي.
  final AttendanceSession? attendanceSession;
  final AttendanceSessionRepository? sessions;

  /// د استادانو/کارمندانو حاضري — که ناسته يې هدف وي، دا کارېږي.
  final StaffAttendanceRepository? staff;

  /// بېرته د ناستو لیست ته — که له لیست څخه راغلی وي.
  final VoidCallback? onBack;

  /// د ازموینې لپاره — چې «نن» ثابته وي.
  final DateTime Function() clock;

  /// له ډاشبورډه مستقیم لیست ته — `scan` | `camera` | `list`.
  final String initialTab;

  /// لیست له کوم حالت سره پیل شي — `present` | `absent` | `late`.
  final String? initialRosterStatus;

  /// **د رخصتیو کلیز** — که نن رسمي رخصتي وي، پاڼه يې لومړی وايي.
  final HolidayRepository? holidays;

  const AttendancePage({
    super.key,
    required this.attendance,
    required this.academic,
    required this.session,
    this.attendanceSession,
    this.sessions,
    this.staff,
    this.onBack,
    this.clock = DateTime.now,
    this.initialTab = 'scan',
    this.initialRosterStatus,
    this.holidays,
  });

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final _input = TextEditingController();
  final _focus = FocusNode();

  AttendanceRules _rules = const AttendanceRules();
  DaySummary? _summary;
  ScanVisual? _last;
  final List<ScanVisual> _recent = [];
  bool _busy = false;
  bool _locking = false;

  /// `scan` | `camera` | `list` — د ننوتلو درې لارې.
  ///
  /// **درې لارې ولې؟** یو ښوونځی USB سکینر لري، بل نه لري. یو
  /// شاګرد کارت هېر کړی، بل ناروغ دی. هره لار یو ریښتینی حالت حل
  /// کوي — او د ګوتې نښه څلورمه نه ده، ځکه چې لوستونکی يې هم
  /// کیبورډ ښیي، نو هماغې خانې ته ځي.
  late String _tab = widget.initialTab;

  /// **د تلوالې ناستې حاضري د صفر لاندې ثبتېږي** — نه د هغې د
  /// کرښې id لاندې. `storageId` همدا پرېکړه یو ځای ساتي.
  int get _sessionId => widget.attendanceSession?.storageId ?? 0;

  /// **دا ناسته د کارمندانو ده؟**
  ///
  /// همدا یوه پوښتنه ټوله پاڼه اړوي: لیست د استادانو شي، سکین د
  /// کارمند نمبر ولټوي، او لنډیز له بل جدوله راشي. د شاګردانو او
  /// د استادانو ناستې هېڅکله سره نه ګډېږي، ځکه چې دا پرېکړه د
  /// ناستې پر هدف ولاړه ده — نه پر هغه څه چې کارن سکین کوي.
  bool get _personnel =>
      widget.staff != null && (widget.attendanceSession?.isPersonnel ?? false);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  /// نن رسمي رخصتي ده؟ — که وي، هغه کرښه.
  Holiday? _holiday;

  /// څو تنه د رخصتۍ له امله پخپله «رخصت» ثبت شول.
  int _autoLeave = 0;

  Future<void> _boot() async {
    final rules = await widget.attendance.rules();
    final holiday = await widget.holidays?.on(widget.clock());

    // **د رخصتۍ پر ورځ، ځواب پخپله معلوم دی.**
    var auto = 0;
    if (holiday != null && !_personnel && widget.sessions != null) {
      auto = await widget.sessions!.markHolidayLeave(
        date: widget.clock(),
        session: widget.attendanceSession,
        byUserId: widget.session.userId,
      );
    }

    if (!mounted) return;
    setState(() {
      _rules = rules;
      _holiday = holiday;
      _autoLeave = auto;
    });
    await _refresh();
    if (mounted) _focus.requestFocus();
  }

  Future<void> _refresh() async {
    if (_personnel) {
      final r = await widget.staff!.summary(
        date: widget.clock(),
        sessionId: _sessionId,
        kind: widget.attendanceSession?.personnelKind,
      );
      final rows = await widget.staff!.roster(
        date: widget.clock(),
        sessionId: _sessionId,
        kind: widget.attendanceSession?.personnelKind,
      );
      var late = 0;
      var leave = 0;
      var absent = 0;
      for (final e in rows) {
        switch (e.status) {
          case 'late':
            late++;
          case 'leave':
            leave++;
          case 'absent':
            absent++;
        }
      }
      if (!mounted) return;
      setState(
        () => _summary = DaySummary(
          total: r.target,
          present: r.present - late,
          late: late,
          onLeave: leave,
          absent: absent,
          locked: false,
        ),
      );
      return;
    }
    final s = await widget.attendance.summary(
      widget.clock(),
      sessionId: _sessionId,
    );
    if (!mounted) return;
    setState(() => _summary = s);
  }

  /// د یوه استاد/کارمند سکین — د شاګرد له لارې جلا، خو له همدې خانې.
  Future<ScanVisual> _submitPersonnel(String raw) async {
    final person = await widget.staff!.findByInput(raw);
    if (person == null) {
      return ScanVisual(
        color: AppColors.danger,
        icon: Icons.person_search_rounded,
        label: 'دا نمبر هېڅ استاد یا کارمند ته نه ورګرځي',
        name: raw,
      );
    }
    final kind = widget.attendanceSession?.personnelKind;
    if (kind != null && kind != person.kind) {
      return ScanVisual.noSession(person.fullName);
    }
    final status = await widget.staff!.checkIn(
      person: person,
      now: widget.clock(),
      rules: _rules,
      sessionId: _sessionId,
      byUserId: widget.session.userId,
    );
    return ScanVisual.personnel(
      name: person.fullName,
      employeeNo: person.employeeNo,
      kind: person.kind,
      status: status,
    );
  }

  Future<void> _submit(String raw) async {
    if (_busy || raw.trim().isEmpty) return;
    setState(() => _busy = true);

    final ScanVisual visual;
    if (_personnel) {
      visual = await _submitPersonnel(raw);
      await Tone.play(
        visual.color == AppColors.success
            ? Tone.accept
            : visual.color == AppColors.warning
            ? Tone.warn
            : Tone.error,
      );
    } else {
      final result = await widget.attendance.checkIn(
        input: raw,
        now: widget.clock(),
        byUserId: widget.session.userId,
        withRules: _rules,
        sessionId: _sessionId,
      );

      // **غږ — ځکه چې شاګرد سکرین ته نه ګوري.**
      // هغه کارت وهي او ژر تېرېږي. که یوازې رنګ بدل شي، د غلط کارت
      // خاوند به سبا «غیرحاضر» ولیدل او نه به پوهېده ولې.
      await Tone.play(switch (result) {
        CheckInOk() => Tone.accept,
        CheckInCheckedOut() => Tone.accept,
        CheckInOnLeave() || CheckInAlreadyDone() => Tone.warn,
        _ => Tone.error,
      });
      visual = ScanVisual.of(result);
    }

    if (!mounted) return;
    setState(() {
      _last = visual;
      _recent.insert(0, visual);
      if (_recent.length > 8) _recent.removeLast();
      _busy = false;
      _input.clear();
    });

    await _refresh();
    // فوکس بېرته خانې ته — راتلونکی سکین باید ضایع نه شي.
    if (mounted) _focus.requestFocus();
  }

  Future<void> _lockDay() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ورځ بنده کړم؟'),
        content: const Text(
          'هغه شاګردان چې نن نه دي ثبت شوي، غیرحاضر ګڼل کېږي. '
          'د اجازې لرونکي به «رخصت» پاتې شي.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('بنده کړه'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _locking = true);
    final n = await widget.attendance.lockDay(
      date: widget.clock(),
      byUserId: widget.session.userId,
      sessionId: _sessionId,
    );
    if (!mounted) return;
    await _refresh();
    if (!mounted) return;
    setState(() => _locking = false);

    final locale = S.of(context).locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 460,
        backgroundColor: n > 0 ? AppColors.danger : AppColors.success,
        content: Text(
          n > 0
              ? 'ورځ بنده شوه — ${locale.num(n)} غیرحاضران. '
                    'د مدیر اپ ته خبرتیا ځي.'
              : 'ورځ بنده شوه — هېڅ غیرحاضر نشته.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    final s = S.of(context);
    final session = widget.attendanceSession;
    final live =
        session == null ||
        AttendanceSessionRepository.isLiveAt(session, widget.clock());

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // **که نن رسمي رخصتي وي، لومړۍ خبره همدا ده.**
          //
          // پرته له دې، مدیر به درې سوه نومونه ولیدل او فکر يې کاوه
          // چې څوک نه دي راغلي — بیا به یې ټول «غیرحاضر» نښه کړي
          // وای، او د میاشتې رپوټ به يې خراب شوی و.
          if (_holiday != null)
            _HolidayBanner(holiday: _holiday!, autoMarked: _autoLeave),
          // ── د ناستې سرلیک ─────────────────────────────────
          Row(
            children: [
              if (widget.onBack != null)
                IconButton(
                  tooltip: 'بېرته',
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_forward_rounded, size: 19),
                ),
              Text(
                session?.name ?? 'د ورځې حاضري',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 10),
              if (session != null)
                Pill(
                  color: live ? AppColors.success : p.faint,
                  filled: live,
                  icon: live ? Icons.sensors_rounded : Icons.schedule_rounded,
                  text: live
                      ? s.live
                      : '${locale.num(session.startTime)}–'
                            '${locale.num(session.endTime)}',
                ),
              const Spacer(),
              SegmentedChoice<String>(
                value: _tab,
                color: AppColors.modAttendance,
                options: const [
                  (
                    value: 'scan',
                    label: 'سکینر',
                    icon: Icons.qr_code_scanner_rounded,
                  ),
                  (
                    value: 'camera',
                    label: 'کیمره',
                    icon: Icons.photo_camera_rounded,
                  ),
                  (value: 'list', label: 'لیست', icon: Icons.checklist_rounded),
                ],
                onChanged: (v) {
                  setState(() => _tab = v);
                  if (v == 'scan') _focus.requestFocus();
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          FadeSlideIn(
            child: _SummaryRow(summary: _summary, locale: locale),
          ),
          const SizedBox(height: 18),

          // **د رخصتۍ پر ورځ سکینر بند دی.** یو سکین به یو
          // «حاضر» ثبت کړ چې د ورځې له حقیقته سره ټکر لري — او
          // بیا به د میاشتې رپوټ خراب شوی و. لیست خلاص پاتې کېږي،
          // ځکه چې استثنا شونې ده.
          if (_holiday != null && _tab != 'list')
            Expanded(
              child: EmptyState(
                icon: Icons.event_busy_rounded,
                text: 'نن رخصتي ده — سکینر بند دی',
                hint: 'که یو څوک راغلی وي، «لیست» ټب کې يې په لاس '
                    'بدل کړئ.',
                action: FilledButton.icon(
                  onPressed: () => setState(() => _tab = 'list'),
                  icon: const Icon(Icons.checklist_rounded, size: 17),
                  label: const Text('لیست ته لاړ شه'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modLeave,
                  ),
                ),
              ),
            )
          else if (_tab == 'list')
            Expanded(
              child: _personnel
                  ? PersonnelRoster(
                      staff: widget.staff!,
                      session: session,
                      user: widget.session,
                      clock: widget.clock,
                      onChanged: _refresh,
                    )
                  : widget.sessions == null
                  ? const EmptyState(
                      icon: Icons.checklist_rounded,
                      text: 'لاسي لیست شتون نه لري.',
                    )
                  : ManualRoster(
                      sessions: widget.sessions!,
                      attendance: widget.attendance,
                      academic: widget.academic,
                      session: session,
                      user: widget.session,
                      clock: widget.clock,
                      onChanged: _refresh,
                      initialStatus: widget.initialRosterStatus,
                    ),
            )
          else if (_tab == 'camera')
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: p.line),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.photo_camera_rounded,
                                size: 19,
                                color: AppColors.modAttendance,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                'کارت د کیمرې مخې ته ونیسئ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink,
                                ),
                              ),
                              const Spacer(),
                              _RuleHint(rules: _rules, locale: locale),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Expanded(
                            child: Center(
                              child: CameraScanPanel(onCode: _submit),
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 132,
                            child: ScanFeedback(visual: _last, locale: locale),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _recentPanel(p, locale)),
                ],
              ),
            )
          else
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── د سکین برخه ─────────────────────────────
                  Expanded(
                    flex: 3,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        border: Border.all(color: p.line),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 19,
                                color: AppColors.modAttendance,
                              ),
                              const SizedBox(width: 9),
                              Text(
                                _personnel
                                    ? 'د استاد/کارمند کارت سکین کړئ یا '
                                          'د کارمند نمبر ولیکئ'
                                    : 'کارت سکین کړئ، ګوته کېږدئ، یا '
                                          'آی‌ډي نمبر ولیکئ',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: p.ink,
                                ),
                              ),
                              const Spacer(),
                              _RuleHint(rules: _rules, locale: locale),
                            ],
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _input,
                            focusNode: _focus,
                            autofocus: true,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            enabled: !_busy,
                            onSubmitted: _submit,
                            inputFormatters: [
                              // نوې کرښه د USB سکینر له خوا راځي —
                              // هغه پخپله Enter لیکي.
                              FilteringTextInputFormatter.deny(RegExp(r'\n')),
                            ],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                            decoration: InputDecoration(
                              hintText: _personnel ? 'T-001' : '1405-0001',
                              hintStyle: TextStyle(
                                fontSize: 20,
                                color: p.faint,
                                letterSpacing: 1.5,
                              ),
                              prefixIcon: const Icon(Icons.badge_rounded),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Expanded(
                            child: ScanFeedback(visual: _last, locale: locale),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: _recentPanel(p, locale)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// د وروستیو سکینونو تخته — سکینر او کیمره دواړه يې کاروي.
  Widget _recentPanel(AppPalette p, AppLocale locale) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'وروستي',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
              const Spacer(),
              // **د کارمندانو ناسته «ورځ بندول» نه لري** — هغه د
              // شاګردانو جدول ته لیکي، نو دلته به يې غلط ریکارډ
              // جوړ کړ.
              if (!_personnel)
                OutlinedButton.icon(
                  onPressed: _locking ? null : _lockDay,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  icon: const Icon(Icons.lock_clock_rounded, size: 15),
                  label: const Text('ورځ بنده کړه'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _recent.isEmpty
                ? Center(
                    child: Text(
                      'لا هېڅ سکین نه دی شوی.',
                      style: TextStyle(fontSize: 12.5, color: p.muted),
                    ),
                  )
                : ListView.separated(
                    itemCount: _recent.length,
                    separatorBuilder: (_, _) =>
                        Divider(height: 13, color: p.line),
                    itemBuilder: (context, i) =>
                        _RecentRow(visual: _recent[i], locale: locale),
                  ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _SummaryRow extends StatelessWidget {
  final DaySummary? summary;
  final AppLocale locale;

  const _SummaryRow({required this.summary, required this.locale});

  @override
  Widget build(BuildContext context) {
    final s = summary;
    final items = <(String, int, Color, IconData)>[
      ('حاضر', s?.present ?? 0, AppColors.success, Icons.check_circle_rounded),
      ('ناوخته', s?.late ?? 0, AppColors.warning, Icons.schedule_rounded),
      ('رخصت', s?.onLeave ?? 0, AppColors.info, Icons.event_available_rounded),
      ('غیرحاضر', s?.absent ?? 0, AppColors.danger, Icons.cancel_rounded),
      (
        'نه دي ثبت شوي',
        s?.unmarked ?? 0,
        AppColors.modSettings,
        Icons.help_outline_rounded,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          Expanded(
            child: _Stat(
              label: items[i].$1,
              value: items[i].$2,
              color: items[i].$3,
              icon: items[i].$4,
              locale: locale,
            ),
          ),
          if (i < items.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final AppLocale locale;

  const _Stat({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    required this.locale,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: color),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CountUpText(
                  value: value,
                  format: (v) => locale.num(v.round()),
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1.2,
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RuleHint extends StatelessWidget {
  final AttendanceRules rules;
  final AppLocale locale;

  const _RuleHint({required this.rules, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Text(
      'پیل ${locale.num(rules.dayStart)} · '
      'ناوخته له ${locale.num(rules.lateAfterMinutes)} دقیقو وروسته',
      style: TextStyle(fontSize: 11.5, color: p.muted),
    );
  }
}

class _RecentRow extends StatelessWidget {
  final ScanVisual visual;
  final AppLocale locale;

  const _RecentRow({required this.visual, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final v = visual;

    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: v.color.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(v.icon, size: 15, color: v.color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                v.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: p.ink,
                ),
              ),
              Text(v.label, style: TextStyle(fontSize: 11, color: v.color)),
            ],
          ),
        ),
      ],
    );
  }
}


/// **د رسمي رخصتۍ کرښه** — د حاضرۍ پر سر.
class _HolidayBanner extends StatelessWidget {
  final Holiday holiday;
  final int autoMarked;
  const _HolidayBanner({required this.holiday, this.autoMarked = 0});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    final days = holiday.toDate.difference(holiday.fromDate).inDays + 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 13),
      decoration: BoxDecoration(
        color: AppColors.modLeave.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.modLeave.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 19,
            color: AppColors.modLeave,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'نن رسمي رخصتي ده — ${holiday.name}',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.modLeave,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  [
                    if (days > 1) '${locale.num(days)} ورځې رخصتي.',
                    if (autoMarked > 0)
                      '${locale.num(autoMarked)} شاګردان پخپله «رخصت» '
                          'ثبت شول.'
                    else
                      'ټول شاګردان رخصت ګڼل کېږي.',
                    'که څوک راغلی وي، په لیست کې يې بدل کړئ.',
                  ].join(' '),
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
