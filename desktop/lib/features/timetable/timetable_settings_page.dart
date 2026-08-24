import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/timetable_repository.dart';

/// **د مهالویش تنظیمات** — د ورځې جوړښت.
///
/// **ولې دلته او نه په عمومي تنظیماتو کې؟** ځکه چې دا شمېرې د
/// مهالویش د جدول بڼه ټاکي: څو ستنې، څو دقیقې، چېرې تفریح. هغه
/// څوک چې مهالویش جوړوي، همدلته يې پکار دي — نه دا چې بلې پاڼې
/// ته ولاړ شي، شمېره بدله کړي، او بېرته راشي چې وګوري څه شو.
class TimetableSettingsPage extends StatefulWidget {
  final TimetableRepository timetable;
  final AcademicRepository academic;
  final bool canEdit;

  /// کله چې ساعتونه له سره جوړ شي — جدول باید بیا ولوستل شي.
  final VoidCallback? onChanged;

  const TimetableSettingsPage({
    super.key,
    required this.timetable,
    required this.academic,
    this.canEdit = true,
    this.onChanged,
  });

  @override
  State<TimetableSettingsPage> createState() => _TimetableSettingsPageState();
}

class _TimetableSettingsPageState extends State<TimetableSettingsPage> {
  bool _loading = true;
  bool _busy = false;
  School? _school;

  String _dayStart = '07:00';
  int _periods = 6;
  int _minutes = 45;
  int _breakAfter = 4;
  int _breakMinutes = 15;
  int _breaksPerDay = 1;

  /// **ټول یو شان که هر یو خپل؟**
  bool _uniform = true;

  /// د هر ساعت خپله اوږدوالی — یوازې کله چې `_uniform == false`.
  List<int> _perPeriod = const [];

  List<TimeSlot> _slots = const [];

  /// هغه څه چې په ډیټابیس کې دي — د «ونه ساتل شو» د پېژندلو لپاره.
  String? _savedSignature;

  String get _signature =>
      '$_dayStart/$_periods/$_minutes/$_breakAfter/$_breakMinutes/'
      '$_breaksPerDay/$_uniform/${_perPeriod.join(",")}';

  /// هغه لیست چې ذخیرې او مخکتنې ته ځي — که «ټول یو شان» وي، تش.
  List<int>? get _lengths => _uniform ? null : _padded;

  /// د ساعتونو شمېر ته برابر شوی لیست — که کارن ساعتونه زیات کړي،
  /// نوي هغه د ګډې اندازې په څېر پیلېږي، نه صفر.
  List<int> get _padded => [
    for (var i = 0; i < _periods; i++)
      i < _perPeriod.length && _perPeriod[i] > 0 ? _perPeriod[i] : _minutes,
  ];

  bool get _dirty => _savedSignature != _signature;

  String get _dayEnd => TimetableRepository.computeDayEnd(
    dayStart: _dayStart,
    periodsPerDay: _periods,
    periodMinutes: _minutes,
    breakAfterPeriods: _breakAfter,
    breakMinutes: _breakMinutes,
    breaksPerDay: _breaksPerDay,
    perPeriodMinutes: _lengths,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final school = await widget.academic.school();
    final slots = await widget.timetable.slots();
    if (!mounted) return;
    setState(() {
      _school = school;
      _slots = slots;
      if (school != null) {
        _dayStart = school.dayStart;
        _periods = school.periodsPerDay;
        _minutes = school.periodMinutes;
        _breakAfter = school.breakAfterPeriods;
        _breakMinutes = school.breakMinutes;
        _breaksPerDay = school.breaksPerDay;
        final csv = school.periodMinutesCsv;
        final parsed = csv == null || csv.trim().isEmpty
            ? const <int>[]
            : csv
                  .split(',')
                  .map((e) => int.tryParse(e.trim()) ?? 0)
                  .toList();
        _uniform = parsed.isEmpty;
        _perPeriod = parsed;
      }
      _savedSignature = _signature;
      _loading = false;
    });
  }

  /// **ساتل د ساعتونو له سره جوړولو معنا لري** — نو مخکې پوښتنه.
  Future<void> _save() async {
    final dropped = await _confirmIfLossy();
    if (dropped == null || !mounted) return;

    setState(() => _busy = true);
    final lost = await widget.timetable.rebuildSlots(
      dayStart: _dayStart,
      periodsPerDay: _periods,
      periodMinutes: _minutes,
      breakAfterPeriods: _breakAfter,
      breakMinutes: _breakMinutes,
      breaksPerDay: _breaksPerDay,
      perPeriodMinutes: _lengths,
    );

    final school = _school;
    if (school != null) {
      await (widget.academic.db.update(
        widget.academic.db.schools,
      )..where((s) => s.id.equals(school.id))).write(
        SchoolsCompanion(
          dayStart: Value(_dayStart),
          dayEnd: Value(_dayEnd),
          periodsPerDay: Value(_periods),
          periodMinutes: Value(_minutes),
          breakAfterPeriods: Value(_breakAfter),
          breakMinutes: Value(_breakMinutes),
          breaksPerDay: Value(_breaksPerDay),
          periodMinutesCsv: Value(_uniform ? null : _padded.join(',')),
        ),
      );
    }

    if (!mounted) return;
    setState(() => _busy = false);
    await _load();
    widget.onChanged?.call();
    if (!mounted) return;

    final locale = S.of(context).locale;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 540,
        backgroundColor: lost > 0 ? AppColors.warning : AppColors.success,
        content: Text(
          lost > 0
              ? 'ساعتونه له سره جوړ شول — ${locale.num(lost)} درسونه '
                    'ځای نه لري، نو ړنګ شول.'
              : 'ساعتونه له سره جوړ شول. ټول درسونه خپل ځای کې پاتې دي.',
        ),
      ),
    );
  }

  /// که نوی جوړښت له زاړه لنډ وي، مخکې خبرداری.
  Future<bool?> _confirmIfLossy() async {
    final oldTeaching = _slots.where((s) => !s.isBreak).length;
    if (_periods >= oldTeaching) return true;

    final locale = S.of(context).locale;
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ځینې درسونه به ړنګ شي'),
        content: Text(
          'اوس ${locale.num(oldTeaching)} درسي ساعتونه شته، نوی جوړښت '
          '${locale.num(_periods)} لري. هغه درسونه چې د '
          '${locale.num(_periods)} څخه وروسته دي، ځای نه لري او '
          'ړنګېږي.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context, null),
            child: Text(S.of(context).cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('دوام ورکړه'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickStart() async {
    final parts = _dayStart.split(':');
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: int.tryParse(parts.first) ?? 7,
        minute: parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      ),
    );
    if (picked == null || !mounted) return;
    setState(
      () => _dayStart =
          '${picked.hour.toString().padLeft(2, '0')}:'
          '${picked.minute.toString().padLeft(2, '0')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: [
            FadeSlideIn(
              child: Panel(
                title: 'د ورځې جوړښت',
                icon: Icons.schedule_rounded,
                color: AppColors.modTimetable,
                subtitle:
                    'دا شمېرې د جدول ستنې جوړوي. بدلون يې ساعتونه له '
                    'سره جوړوي — درسونه خپل ځایونه ساتي.',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Field(
                      label: 'د درس پیل',
                      hint: 'لومړی ساعت له کوم وخته پیلېږي',
                      child: OutlinedButton.icon(
                        onPressed: widget.canEdit ? _pickStart : null,
                        icon: const Icon(Icons.access_time_rounded, size: 17),
                        label: Text(locale.num(_dayStart)),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(132, 42),
                        ),
                      ),
                    ),
                    _Field(
                      label: 'د ورځې ساعتونه',
                      hint: 'څو درسي ساعته په یوه ورځ کې',
                      child: _Stepper(
                        value: _periods,
                        min: 1,
                        max: 12,
                        enabled: widget.canEdit,
                        onChanged: (v) => setState(() => _periods = v),
                      ),
                    ),
                    _Field(
                      label: 'د ساعتونو اوږدوالی',
                      hint: _uniform
                          ? 'ټول ساعتونه یو شان دي'
                          : 'هر ساعت خپله اندازه لري',
                      child: SegmentedChoice<bool>(
                        value: _uniform,
                        color: AppColors.modTimetable,
                        options: const [
                          (value: true, label: 'ټول یو شان', icon: null),
                          (value: false, label: 'هر یو خپل', icon: null),
                        ],
                        onChanged: widget.canEdit
                            ? (v) => setState(() {
                                // له «خپل» ته تګ اوسنۍ ګډه اندازه
                                // د پیل ټکي په توګه اخلي — نه صفر،
                                // چې کارن يې له سره ولیکي.
                                if (!v && _perPeriod.length != _periods) {
                                  _perPeriod = _padded;
                                }
                                _uniform = v;
                              })
                            : (_) {},
                      ),
                    ),
                    if (_uniform)
                      _Field(
                        label: 'د یوه ساعت دقیقې',
                        child: _Stepper(
                          value: _minutes,
                          min: 20,
                          max: 90,
                          step: 5,
                          enabled: widget.canEdit,
                          onChanged: (v) => setState(() => _minutes = v),
                        ),
                      )
                    else
                      _PerPeriodEditor(
                        lengths: _padded,
                        enabled: widget.canEdit,
                        onChanged: (i, v) => setState(() {
                          final next = _padded;
                          next[i] = v;
                          _perPeriod = next;
                        }),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            FadeSlideIn.staggered(
              index: 1,
              child: Panel(
                title: 'تفریح',
                icon: Icons.free_breakfast_rounded,
                color: AppColors.warning,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Field(
                      label: 'له څو ساعتونو وروسته',
                      hint: 'د هرو دومره ساعتونو وروسته یوه تفریح',
                      child: _Stepper(
                        value: _breakAfter,
                        min: 1,
                        max: 8,
                        enabled: widget.canEdit,
                        onChanged: (v) => setState(() => _breakAfter = v),
                      ),
                    ),
                    _Field(
                      label: 'د تفریح دقیقې',
                      child: _Stepper(
                        value: _breakMinutes,
                        min: 5,
                        max: 60,
                        step: 5,
                        enabled: widget.canEdit,
                        onChanged: (v) => setState(() => _breakMinutes = v),
                      ),
                    ),
                    _Field(
                      label: 'په ورځ کې تفریحې',
                      hint:
                          'له دې شمېرې زیاتې نه ورکول کېږي، که څه هم '
                          'ځای يې راشي',
                      child: _Stepper(
                        value: _breaksPerDay,
                        min: 0,
                        max: 4,
                        enabled: widget.canEdit,
                        onChanged: (v) => setState(() => _breaksPerDay = v),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // **مخکتنه** — د ساتلو دمخه ښکاري چې څه به جوړ شي.
            FadeSlideIn.staggered(
              index: 2,
              child: Panel(
                title: 'مخکتنه',
                icon: Icons.visibility_rounded,
                subtitle:
                    'ورځ ${locale.num(_dayStart)} پیلېږي او '
                    '${locale.num(_dayEnd)} پای ته رسېږي.',
                child: _Preview(
                  dayStart: _dayStart,
                  periods: _periods,
                  minutes: _minutes,
                  breakAfter: _breakAfter,
                  breakMinutes: _breakMinutes,
                  breaksPerDay: _breaksPerDay,
                  perPeriod: _lengths,
                ),
              ),
            ),
          ],
        ),

        // **د ساتلو کرښه یوازې کله ښکاري چې څه بدل شوي وي.**
        // یوه تل-ښکاره تڼۍ کارن ته نه وايي چې څه بدل شوي دي.
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSlide(
            duration: AppMotion.normal,
            curve: AppMotion.emphasized,
            offset: _dirty ? Offset.zero : const Offset(0, 1.4),
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 18),
              decoration: BoxDecoration(
                color: p.surface,
                border: Border(top: BorderSide(color: p.line)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_note_rounded,
                    size: 19,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'بدلونونه لا نه دي ساتل شوي',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: p.inkSoft,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: _busy ? null : _load,
                    child: const Text('بېرته'),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _busy || !widget.canEdit ? null : _save,
                    icon: const Icon(Icons.check_rounded, size: 17),
                    label: Text(s.save),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.modTimetable,
                      minimumSize: const Size(0, 42),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _Field extends StatelessWidget {
  final String label;
  final String? hint;
  final Widget child;

  const _Field({required this.label, required this.child, this.hint});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
                  ),
                ),
                if (hint != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    hint!,
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                ],
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// یوه شمېره چې د − او + په تڼیو بدلېږي.
///
/// **ولې نه یوه لیکنې خانه؟** ځکه چې دا شمېرې کوچنۍ حدود لري او د
/// لیکنې خانه هر ډول متن مني — «۴۵ دقیقې»، «څلوېښت»، یا تشه. یوه
/// خانه چې غلط ارزښت ونه مني، له یوې خانې غوره ده چې غلط ارزښت
/// ومني او بیا يې رد کړي.
class _Stepper extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final int step;
  final bool enabled;
  final ValueChanged<int> onChanged;

  const _Stepper({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.step = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    Widget btn(IconData icon, int delta) {
      final next = value + delta;
      final ok = enabled && next >= min && next <= max;
      return IconButton(
        onPressed: ok ? () => onChanged(next) : null,
        visualDensity: VisualDensity.compact,
        icon: Icon(icon, size: 18, color: ok ? p.inkSoft : p.faint),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: p.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.remove_rounded, -step),
          SizedBox(
            width: 46,
            child: Text(
              locale.num(value),
              textAlign: TextAlign.center,
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
            ),
          ),
          btn(Icons.add_rounded, step),
        ],
      ),
    );
  }
}

/// **د هر ساعت خپله اندازه** — یو کتار پر هر درسي ساعت.
///
/// دا هغه وخت ښکاري چې کارن «هر یو خپل» غوره کړي. هر کتار یوه
/// شمېره لري چې یوازې همغه ساعت اوړوي؛ نور ساعتونه پر خپل حال
/// پاتې کېږي. دا ځکه اړینه ده چې ډېرې مدرسې لومړی ساعت اوږد
/// (مثلاً ۶۰ دقیقې د سبق لپاره) او پاتې لنډ (۴۵ دقیقې) لري.
class _PerPeriodEditor extends StatelessWidget {
  final List<int> lengths;
  final bool enabled;
  final void Function(int index, int minutes) onChanged;

  const _PerPeriodEditor({
    required this.lengths,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    final total = lengths.fold<int>(0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        for (var i = 0; i < lengths.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 4, 4),
            decoration: BoxDecoration(
              color: p.surfaceAlt.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: p.line),
            ),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.modTimetable.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    locale.num(i + 1),
                    style: AppTheme.tabular(
                      const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.modTimetable,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${locale.num(i + 1)}م ساعت',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                    ),
                  ),
                ),
                Text(
                  'دقیقې',
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
                const SizedBox(width: 8),
                _Stepper(
                  value: lengths[i],
                  min: 20,
                  max: 90,
                  step: 5,
                  enabled: enabled,
                  onChanged: (v) => onChanged(i, v),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            'د درسونو ټول وخت ${locale.num(total)} دقیقې '
            '(پرته له تفریح).',
            style: TextStyle(fontSize: 11.5, color: p.muted),
          ),
        ),
      ],
    );
  }
}

/// د ورځې د ساعتونو مخکتنه — د ساتلو دمخه.
class _Preview extends StatelessWidget {
  final String dayStart;
  final int periods;
  final int minutes;
  final int breakAfter;
  final int breakMinutes;
  final int breaksPerDay;
  final List<int>? perPeriod;

  const _Preview({
    required this.dayStart,
    required this.periods,
    required this.minutes,
    required this.breakAfter,
    required this.breakMinutes,
    required this.breaksPerDay,
    this.perPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    final parts = dayStart.split(':');
    var m =
        (int.tryParse(parts.first) ?? 7) * 60 +
        (parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0);

    String fmt(int v) =>
        '${((v ~/ 60) % 24).toString().padLeft(2, '0')}:'
        '${(v % 60).toString().padLeft(2, '0')}';

    final items = <({String name, String from, String to, bool isBreak})>[];
    var breaksUsed = 0;
    for (var i = 1; i <= periods; i++) {
      final len = TimetableRepository.minutesFor(
        index: i - 1,
        uniform: minutes,
        perPeriod: perPeriod,
      );
      items.add((
        name: '${locale.num(i)} ساعت',
        from: fmt(m),
        to: fmt(m + len),
        isBreak: false,
      ));
      m += len;
      if (breakAfter > 0 &&
          i % breakAfter == 0 &&
          i != periods &&
          breaksUsed < breaksPerDay) {
        breaksUsed++;
        items.add((
          name: 'تفریح',
          from: fmt(m),
          to: fmt(m + breakMinutes),
          isBreak: true,
        ));
        m += breakMinutes;
      }
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final it in items)
          Container(
            width: 118,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              color: it.isBreak
                  ? AppColors.warning.withValues(alpha: 0.09)
                  : p.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: it.isBreak
                    ? AppColors.warning.withValues(alpha: 0.35)
                    : p.line,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  it.name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: it.isBreak ? AppColors.warning : p.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${locale.num(it.from)} – ${locale.num(it.to)}',
                  style: AppTheme.tabular(
                    TextStyle(fontSize: 11, color: p.muted),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
