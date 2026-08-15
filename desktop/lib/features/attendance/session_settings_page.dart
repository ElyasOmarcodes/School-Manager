import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/attendance_session_repository.dart';
import 'sessions_page.dart';

/// «د حاضریانو تنظیمات» — د ټولو ناستو لیست، هره یوه د سمون وړ.
///
/// دا هماغه پاڼه ده چې «د نوې حاضري جوړول» هم پکې کېږي؛ توپیر يې
/// یوازې دا دی چې د جوړولو پاڼه سمدستي فورمه پرانیزي.
class SessionSettingsPage extends StatefulWidget {
  final AttendanceSessionRepository sessions;
  final AcademicRepository academic;
  final DateTime Function() clock;

  /// که سم وي، پاڼه سمدستي د نوې ناستې فورمه پرانیزي.
  final bool startWithNew;
  final bool canEdit;

  const SessionSettingsPage({
    super.key,
    required this.sessions,
    required this.academic,
    this.clock = DateTime.now,
    this.startWithNew = false,
    this.canEdit = true,
  });

  @override
  State<SessionSettingsPage> createState() => _SessionSettingsPageState();
}

class _SessionSettingsPageState extends State<SessionSettingsPage> {
  List<({AttendanceSession session, SessionStatus status})> _items = const [];
  List<SectionOption> _sections = const [];
  List<Grade> _grades = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load().then((_) {
      if (widget.startWithNew && mounted) _openForm();
    });
  }

  @override
  void didUpdateWidget(SessionSettingsPage old) {
    super.didUpdateWidget(old);
    // له «تنظیمات» څخه «نوې جوړول» ته تګ — هماغه پاڼه ده، نو باید
    // فورمه پخپله پرانیستل شي.
    if (widget.startWithNew && !old.startWithNew) _openForm();
  }

  Future<void> _load() async {
    await widget.sessions.seedDefault();
    final list = await widget.sessions.list();
    final sections = await widget.academic.sections();
    final grades = await widget.academic.grades();
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
      _sections = sections;
      _grades = grades;
      _loading = false;
    });
  }

  Future<void> _openForm({AttendanceSession? existing}) async {
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => SessionFormDialog(
        sessions: widget.sessions,
        sections: _sections,
        grades: _grades,
        existing: existing,
      ),
    );
    if (saved == true) await _load();
  }

  Future<void> _delete(AttendanceSession s) async {
    if (s.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 460,
          backgroundColor: AppColors.warning,
          content: Text(
            'تلواله ناسته ړنګېدی نه شي — یو ښوونځی تل یوې ته اړتیا لري. '
            'خو بنده يې کولی شئ.',
          ),
        ),
      );
      return;
    }

    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('«${s.name}» ړنګه شي؟'),
        content: const Text(
          'د تېرو ورځو حاضري پاتې کېږي — یوازې دا ناسته له لیسټه پټېږي.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(S.of(ctx).cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(ctx).delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await widget.sessions.remove(s.id, at: widget.clock());
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final p = context.palette;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
          child: Row(
            children: [
              Text(
                s.sessionSettings,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'هره ناسته خپل هدف، خپل وخت او خپل قواعد لري.',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ),
              if (widget.canEdit)
                FilledButton.icon(
                  onPressed: () => _openForm(),
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
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 28),
            itemCount: _items.length,
            itemBuilder: (context, i) => FadeSlideIn.staggered(
              index: i,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SessionCard(
                  session: _items[i].session,
                  status: _items[i].status,
                  actions: widget.canEdit
                      ? [
                          Switch(
                            value: _items[i].session.isActive,
                            onChanged: (v) async {
                              await widget.sessions.update(
                                id: _items[i].session.id,
                                isActive: v,
                              );
                              await _load();
                            },
                          ),
                          IconButton(
                            tooltip: s.edit,
                            onPressed: () =>
                                _openForm(existing: _items[i].session),
                            icon: const Icon(Icons.edit_rounded, size: 17),
                          ),
                          IconButton(
                            tooltip: s.delete,
                            onPressed: () => _delete(_items[i].session),
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                            ),
                            color: AppColors.danger,
                          ),
                        ]
                      : const [],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د ناستې فورمه
// ═══════════════════════════════════════════════════════════

class SessionFormDialog extends StatefulWidget {
  final AttendanceSessionRepository sessions;
  final List<SectionOption> sections;
  final List<Grade> grades;
  final AttendanceSession? existing;

  const SessionFormDialog({
    super.key,
    required this.sessions,
    required this.sections,
    required this.grades,
    this.existing,
  });

  @override
  State<SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<SessionFormDialog> {
  late final _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late String _target = widget.existing?.target ?? 'all';
  late int? _sectionId = widget.existing?.sectionId;
  late int? _gradeId = widget.existing?.gradeId;
  late TimeOfDay _start = _parse(widget.existing?.startTime ?? '07:00');
  late TimeOfDay _end = _parse(widget.existing?.endTime ?? '08:30');
  late final Set<int> _days = (widget.existing?.days ?? '6,7,1,2,3')
      .split(',')
      .map((e) => int.tryParse(e.trim()))
      .whereType<int>()
      .toSet();
  late final _late = TextEditingController(
    text: widget.existing?.lateAfterMinutes?.toString() ?? '',
  );
  late final _absent = TextEditingController(
    text: widget.existing?.absentAfterMinutes?.toString() ?? '',
  );
  bool _busy = false;

  static TimeOfDay _parse(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(
      hour: int.tryParse(p.first) ?? 7,
      minute: p.length > 1 ? (int.tryParse(p[1]) ?? 0) : 0,
    );
  }

  static String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    _name.dispose();
    _late.dispose();
    _absent.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty || _days.isEmpty) return;
    setState(() => _busy = true);

    final late = int.tryParse(Numerals.toLatin(_late.text));
    final absent = int.tryParse(Numerals.toLatin(_absent.text));
    final days = (_days.toList()..sort()).join(',');

    if (widget.existing == null) {
      await widget.sessions.create(
        name: name,
        target: _target,
        sectionId: _sectionId,
        gradeId: _gradeId,
        startTime: _fmt(_start),
        endTime: _fmt(_end),
        days: days,
        lateAfterMinutes: late,
        absentAfterMinutes: absent,
      );
    } else {
      await widget.sessions.update(
        id: widget.existing!.id,
        name: name,
        target: _target,
        sectionId: _sectionId,
        gradeId: _gradeId,
        startTime: _fmt(_start),
        endTime: _fmt(_end),
        days: days,
        lateAfterMinutes: late,
        absentAfterMinutes: absent,
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;

    return AlertDialog(
      title: Text(
        widget.existing == null ? s.newSession : 'د ناستې سمون',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _name,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'د ناستې نوم',
                  hintText: 'د لیلیه شاګردانو د شپې حاضري',
                  isDense: true,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'څوک يې هدف دی؟',
                style: TextStyle(fontSize: 11.5, color: p.faint),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final t in const [
                    'all',
                    'day',
                    'boarding',
                    'grade',
                    'section',
                  ])
                    ChoiceChip(
                      label: Text(
                        targetLabel(t, s),
                        style: const TextStyle(fontSize: 12),
                      ),
                      selected: _target == t,
                      onSelected: (_) => setState(() => _target = t),
                    ),
                ],
              ),

              if (_target == 'grade') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _gradeId,
                  isDense: true,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: s.grade,
                    isDense: true,
                  ),
                  items: [
                    for (final g in widget.grades)
                      DropdownMenuItem(value: g.id, child: Text(g.name)),
                  ],
                  onChanged: (v) => setState(() => _gradeId = v),
                ),
              ],
              if (_target == 'section') ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<int?>(
                  initialValue: _sectionId,
                  isDense: true,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: s.section,
                    isDense: true,
                  ),
                  items: [
                    for (final sec in widget.sections)
                      DropdownMenuItem(
                        value: sec.sectionId,
                        child: Text(sec.label),
                      ),
                  ],
                  onChanged: (v) => setState(() => _sectionId = v),
                ),
              ],

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'له',
                      time: _fmt(_start),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TimeButton(
                      label: 'تر',
                      time: _fmt(_end),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                // د نیمې شپې تېرېدونکې کړکۍ عادي ده — «۲۲:۳۰ تر ۰۰:۳۰».
                _fmt(_end).compareTo(_fmt(_start)) < 0
                    ? 'دا کړکۍ نیمه شپه تېروي — سمه ده.'
                    : 'له دې کړکۍ بهر سکینر د دې ناستې لپاره نه کار کوي.',
                style: TextStyle(fontSize: 11, color: p.faint),
              ),

              const SizedBox(height: 18),
              Text(
                'د اونۍ ورځې',
                style: TextStyle(fontSize: 11.5, color: p.faint),
              ),
              const SizedBox(height: 7),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in const {
                    6: 'شنبه',
                    7: 'یکشنبه',
                    1: 'دوشنبه',
                    2: 'سه‌شنبه',
                    3: 'چهارشنبه',
                    4: 'پنجشنبه',
                    5: 'جمعه',
                  }.entries)
                    FilterChip(
                      label: Text(
                        e.value,
                        style: const TextStyle(fontSize: 11.5),
                      ),
                      selected: _days.contains(e.key),
                      onSelected: (on) => setState(() {
                        if (on) {
                          _days.add(e.key);
                        } else {
                          _days.remove(e.key);
                        }
                      }),
                    ),
                ],
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _late,
                      decoration: const InputDecoration(
                        labelText: 'ناوخته وروسته (دقیقې)',
                        hintText: 'د ښوونځي عام قاعده',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _absent,
                      decoration: const InputDecoration(
                        labelText: 'غیرحاضر وروسته (دقیقې)',
                        hintText: 'د ښوونځي عام قاعده',
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'که تش پرېږدئ، د ښوونځي عام قواعد کارېږي — '
                '${locale.num('نو یو ځای بدلون بس دی')}.',
                style: TextStyle(fontSize: 11, color: p.faint),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context, false),
          child: Text(s.cancel),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.modAttendance,
          ),
          child: Text(s.save),
        ),
      ],
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String label;
  final String time;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return OutlinedButton(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        alignment: AlignmentDirectional.centerStart,
      ),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: p.muted),
          const SizedBox(width: 9),
          Text(label, style: TextStyle(fontSize: 11.5, color: p.faint)),
          const Spacer(),
          Text(
            locale.num(time),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
          ),
        ],
      ),
    );
  }
}
