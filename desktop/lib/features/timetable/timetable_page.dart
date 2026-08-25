import 'dart:async';

import 'package:drift/drift.dart' show TableUpdateQuery;
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../data/repositories/timetable_repository.dart';
import 'timetable_pdf.dart';

/// د مهالویش پاڼه — د یوه بخش اونیز جدول.
///
/// **د خانو رنګ ولې د مضمون له نامه راځي؟** ځکه چې یو استاد باید
/// په یوه نظر وویني چې «د شنبې دویم ساعت ریاضي دی». که ټولې خانې
/// یو رنګ وای، هغه به يې لوستلو ته اړ و — او د اتو ساعتونو په پنځو
/// ورځو کې څلوېښت خانې دي.
/// **د خانو رنګونه څه معنا لري؟**
///
/// دا پوښتنه پخپله یوه نیوکه وه: پخوانی رنګ د کتاب د نامه له
/// `hashCode` څخه راته — یعنې **هېڅ معنا يې نه لرله**. یوازې دومره
/// چې «یو شان کتاب تل یو شان رنګ». دا د ښکلا لپاره بس وه، خو
/// سترګې يې څه نه ورزده کول.
///
/// اوس رنګ **یوه پوښتنه ځوابوي**، او کارن ټاکي چې کومه:
///
///   • **سختوالی** (تلواله) — سور = سخت، نارنجي = منځنی،
///     شنه = اسان. دا هغه څه ښیي چې «ځیرک ترتیب» يې کوي: سخت
///     کتابونه سهار. که سره پر ښي (سهار) ډله شوي وي، ترتیب سم دی؛
///     که ګډوډ وي، څه خطا ده.
///   • **فن** — د یوه فن ټول کتابونه یو رنګ. په یوه نظر ښیي چې
///     یوه درجه څو ځله «صرف» لري او څو ځله «فقه».
///   • **دیني/عصري** — د مدرسې لپاره: ورځ څومره دیني او څومره
///     عصري ده.
enum CellColorMode { difficulty, fan, kind, teacher }

/// د تنظیم د متن او د ګڼې تر منځ اړونه.
CellColorMode colorModeOf(String? key) => switch (key) {
  'fan' => CellColorMode.fan,
  'kind' => CellColorMode.kind,
  'teacher' => CellColorMode.teacher,
  _ => CellColorMode.difficulty,
};

String colorModeKey(CellColorMode m) => switch (m) {
  CellColorMode.fan => 'fan',
  CellColorMode.kind => 'kind',
  CellColorMode.teacher => 'teacher',
  CellColorMode.difficulty => 'difficulty',
};

const List<({CellColorMode value, String label, String hint})>
colorModeOptions = [
  (
    value: CellColorMode.difficulty,
    label: 'سختوالی',
    hint: 'سور = سخت، نارنجي = منځنی، شنه = اسان. '
        'ښیي چې ځیرک ترتیب سم کار کړی که نه.',
  ),
  (
    value: CellColorMode.fan,
    label: 'فن',
    hint: 'د یوه فن ټول کتابونه یو رنګ — د تکرار لیدو لپاره.',
  ),
  (
    value: CellColorMode.kind,
    label: 'دیني/عصري',
    hint: 'ورځ څومره دیني او څومره عصري ده.',
  ),
  (
    value: CellColorMode.teacher,
    label: 'استاد',
    hint: 'د یوه استاد ټول درسونه یو رنګ — د بار د لیدو لپاره.',
  ),
];

/// د فن رنګونه — د نامه له مخې ثابت. **د فن، نه د کتاب**: نو د
/// «صرف» ټول کتابونه یو رنګ اخلي.
const List<Color> _fanPalette = [
  AppColors.modStudents,
  AppColors.modAttendance,
  AppColors.modLeave,
  AppColors.modClasses,
  AppColors.modExams,
  AppColors.modTeachers,
  AppColors.modIdCards,
  AppColors.modReports,
];

Color cellColor(TimetableCell c, CellColorMode mode) => switch (mode) {
  CellColorMode.difficulty => switch (c.difficulty) {
    'hard' => AppColors.danger,
    'easy' => AppColors.success,
    _ => AppColors.warning,
  },
  CellColorMode.fan =>
    _fanPalette[c.subjectName.hashCode.abs() % _fanPalette.length],
  CellColorMode.kind => c.isReligious
      ? AppColors.modHifz
      : AppColors.modTimetable,
  // **د استاد رنګ** — د هغه د id له مخې ثابت. یو استاد چې ډېر
  // ساعتونه لري، رنګ يې پر جدول ښکاره ډله جوړوي — دا هغه څه دي
  // چې «څوک ډېر بوخت دی؟» ژر ځوابوي.
  CellColorMode.teacher => c.entry.teacherId == null
      ? AppColors.warning
      : _fanPalette[c.entry.teacherId!.abs() % _fanPalette.length],
};

class TimetablePage extends StatefulWidget {
  final TimetableRepository timetable;
  final AcademicRepository academic;
  final TeacherRepository teachers;

  /// د تنظیماتو پاڼې ته لار — د ډول او رنګ ټاکنه هلته ده.
  final VoidCallback? onOpenSettings;

  const TimetablePage({
    super.key,
    required this.timetable,
    required this.academic,
    required this.teachers,
    this.onOpenSettings,
  });

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  bool _loading = true;
  List<SectionOption> _sections = const [];
  SectionOption? _section;

  TimetableGrid? _grid;
  List<Subject> _subjects = const [];
  List<Teacher> _teachers = const [];
  List<TimetableConflict> _conflicts = const [];

  /// رنګ کومه پوښتنه ځوابوي — له تنظیماتو راځي.
  CellColorMode _colorMode = CellColorMode.difficulty;

  bool _exporting = false;
  String _schoolName = '';

  /// **ژوندی تازه کول.**
  ///
  /// یو مهالویش د استادانو، کتابونو او ساعتونو پر سر ولاړ دی. که
  /// یو استاد نوم بدل کړي یا یو کتاب ړنګ شي، جدول باید پخپله سم
  /// شي — نه دا چې کارن يې د پاڼې له بیا پرانیستلو وروسته وویني.
  ///
  /// drift پخپله د اړوندو جدولونو بدلونونه خبروي، نو دلته یوازې
  /// غوږ نیسو.
  StreamSubscription<void>? _watch;

  /// **د ټکر خانې — د چټکې کتنې لپاره یوه ټولګه.**
  ///
  /// یو ټکر یعنې یو استاد په یوه ورځ او یوه ساعت کې دوه ځایه دی.
  /// نو کلي «استاد-ورځ-ساعت» دی، او هره خانه چې همدې کلي ته ورته
  /// وي، ټکر لري.
  Set<String> get _clashKeys => {
    for (final c in _conflicts) '${c.teacherId}-${c.dayOfWeek}-${c.slotId}',
  };

  static String clashKeyOf(TimetableCell c) =>
      '${c.entry.teacherId}-${c.entry.dayOfWeek}-${c.entry.slotId}';

  bool _dailyClash(TimetableCell? c) =>
      c != null &&
      c.entry.teacherId != null &&
      _clashKeys.contains(clashKeyOf(c));

  /// `weekly` (مکتب) یا `daily` (مدرسه).
  String _mode = 'weekly';
  DailyGrid? _daily;

  bool get _isDaily => _mode == 'daily';

  /// کوم ځیرک بدیل ښکاري — د ‹ › تڼیو لپاره.
  ///
  /// `null` یعنې جدول په لاس جوړ شوی، نه په ځیرک ترتیب. ‹ › یوازې
  /// وروسته له لومړي ځیرک ترتیبه معنا لري.
  int? _variant;
  int _clashes = 0;
  bool _arranging = false;

  /// **د انډو/ریډو ډېران — بشپړ انځورونه، نه جلا بدلونونه.**
  ///
  /// یو ځیرک ترتیب په یوه کلیک کې څلوېښت خانې بدلوي. که هر بدلون
  /// جلا ساتل کېده، انډو به څلوېښت ځله وهلو ته اړ و — او هغه هغه
  /// څه نه دي چې کارن يې غواړي.
  final List<List<PlannedCell>> _undo = [];
  final List<List<PlannedCell>> _redo = [];

  /// څومره انځورونه ساتو. له دې زیات یوازې حافظه خوري — هېڅوک
  /// شل ځله بېرته نه ځي.
  static const int _historyLimit = 20;

  @override
  void dispose() {
    _watch?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await widget.academic.seedDefaultSubjects();
    await widget.timetable.seedDefaultSlots();

    final sections = await widget.academic.sections();
    final school = await widget.academic.school();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _section = sections.isEmpty ? null : sections.first;
      _mode = school?.timetableMode ?? 'weekly';
      _colorMode = colorModeOf(school?.timetableColorBy);
      _schoolName = school?.name ?? '';
    });
    _listen();
    await _load();
  }

  /// د ټکرونو بشپړ لیست — څوک، کومه ورځ، کوم ساعت، کومې درجې.
  Future<void> _showConflicts() async {
    final locale = S.of(context).locale;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 19,
              color: AppColors.danger,
            ),
            const SizedBox(width: 9),
            Text(
              '${locale.num(_conflicts.length)} ټکرونه',
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'هر کرښه یو استاد دی چې په یوه وخت کې دوه ځایه '
                  'ټاکل شوی دی.',
                  style: TextStyle(
                    fontSize: 12,
                    color: ctx.palette.muted,
                  ),
                ),
                const SizedBox(height: 12),
                for (final c in _conflicts)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.danger,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.teacherName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '${locale.num(c.slotName)} · '
                                '${c.sections.join('  ↔  ')}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: ctx.palette.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(S.of(ctx).close),
          ),
        ],
      ),
    );
  }

  /// د اړوندو جدولونو پر هر بدلون، جدول له سره لوستل کېږي.
  void _listen() {
    _watch?.cancel();
    final db = widget.academic.db;
    _watch = db
        .tableUpdates(
          TableUpdateQuery.onAllTables([
            db.timetableEntries,
            db.timeSlots,
            db.subjects,
            db.teachers,
            db.sections,
            db.grades,
          ]),
        )
        .listen((_) {
          if (mounted && !_arranging) _load();
        });
  }

  Future<void> _exportPdf() async {
    setState(() => _exporting = true);
    try {
      final locale = S.of(context).locale;
      final bytes = _isDaily
          ? await buildDailyTimetablePdf(
              grid: _daily!,
              schoolName: _schoolName,
              locale: locale,
            )
          : await buildWeeklyTimetablePdf(
              grid: _grid!,
              schoolName: _schoolName,
              sectionLabel: _section?.label ?? '',
              locale: locale,
              dayName: weekdayNamePs,
            );
      await printTimetable(bytes);
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final teachers = await widget.teachers.activeTeachers();

    if (_isDaily) {
      // د مدرسې حالت: یو جدول، ټولې درجې. د مضمونونو لیست دلته
      // ټول دی، ځکه چې هر کتار خپله درجه ده — د خانې ډیالوګ يې
      // بیا د هغه کتار له مخې تنګوي.
      final daily = await widget.timetable.dailyGrid();
      final subjects = await widget.academic.subjects();
      // **ټکرونه دلته هم شمېرل کېږي.** مخکې يې دلته پرېښودل — او
      // د مدرسې جدول (چې ټولې درجې یو ځای ښیي) هماغه ځای دی چې یو
      // استاد په دوو درجو کې ښکاري. یعنې هغه ځای چې ټکر ترې پیدا
      // کېږي، هماغه یو و چې خبر يې نه ورکاوه.
      final conflicts = await widget.timetable.conflicts();
      if (!mounted) return;
      setState(() {
        _daily = daily;
        _subjects = subjects;
        _teachers = teachers;
        _conflicts = conflicts;
        _loading = false;
      });
      return;
    }

    final s = _section;
    if (s == null) {
      setState(() => _loading = false);
      return;
    }

    final grid = await widget.timetable.grid(sectionId: s.sectionId);
    final subjects = await widget.academic.subjects(gradeId: s.gradeId);
    final conflicts = await widget.timetable.conflicts();

    if (!mounted) return;
    setState(() {
      _grid = grid;
      _subjects = subjects;
      _teachers = teachers;
      _conflicts = conflicts;
      _loading = false;
    });
  }

  /// د مدرسې د یوې خانې سمون — کتار یوه درجه ده، نه یوه ورځ.
  Future<void> _editDailyCell(int sectionId, TimeSlot slot) async {
    final existing = _daily?.at(sectionId, slot.id);
    final row = _sections.where((x) => x.sectionId == sectionId).firstOrNull;

    // یوازې د هماغې درجې مضمونونه — یوه درجه د بلې کتابونه نه لري.
    final subjects = row == null
        ? _subjects
        : await widget.academic.subjects(gradeId: row.gradeId);
    if (!mounted) return;

    final result = await showDialog<_CellEdit>(
      context: context,
      builder: (_) => _CellDialog(
        day: everyDay,
        slot: slot,
        subjects: subjects,
        teachers: _teachers,
        current: existing,
      ),
    );
    if (result == null || !mounted) return;

    if (result.clear) {
      await widget.timetable.clearEntry(
        sectionId: sectionId,
        dayOfWeek: everyDay,
        slotId: slot.id,
      );
      await _load();
      return;
    }

    final outcome = await widget.timetable.setEntry(
      sectionId: sectionId,
      dayOfWeek: everyDay,
      slotId: slot.id,
      subjectId: result.subjectId!,
      teacherId: result.teacherId,
      room: result.room,
    );
    if (!mounted) return;

    switch (outcome) {
      case SetEntryOk():
        await _load();
      case SetEntryTeacherBusy(
        teacherName: final t,
        otherSection: final other,
      ):
        _warn('$t پر همدې ساعت په «$other» کې بوخت دی.');
      case SetEntryRoomBusy(room: final r, otherSection: final other):
        _warn('خونه «$r» پر همدې ساعت «$other» نیولې ده.');
    }
  }

  Future<void> _editCell(int day, TimeSlot slot) async {
    final s = _section;
    if (s == null) return;

    final existing = _grid?.at(day, slot.id);
    final result = await showDialog<_CellEdit>(
      context: context,
      builder: (_) => _CellDialog(
        day: day,
        slot: slot,
        subjects: _subjects,
        teachers: _teachers,
        current: existing,
      ),
    );
    if (result == null || !mounted) return;

    if (result.clear) {
      await widget.timetable.clearEntry(
        sectionId: s.sectionId,
        dayOfWeek: day,
        slotId: slot.id,
      );
      await _load();
      return;
    }

    final outcome = await widget.timetable.setEntry(
      sectionId: s.sectionId,
      dayOfWeek: day,
      slotId: slot.id,
      subjectId: result.subjectId!,
      teacherId: result.teacherId,
      room: result.room,
    );
    if (!mounted) return;

    switch (outcome) {
      case SetEntryOk():
        await _load();
      case SetEntryTeacherBusy(
        teacherName: final t,
        otherSection: final other,
      ):
        _warn('$t پر همدې وخت په «$other» کې بوخت دی.');
      case SetEntryRoomBusy(room: final r, otherSection: final other):
        _warn('خونه «$r» پر همدې وخت «$other» نیولې ده.');
    }
  }

  // ── انډو / ریډو ───────────────────────────────────────

  /// د بدلون دمخه اوسنی حال ساتي.
  Future<void> _remember() async {
    final snap = await widget.timetable.snapshot(daily: _isDaily);
    _undo.add(snap);
    if (_undo.length > _historyLimit) _undo.removeAt(0);
    // یو نوی بدلون د «مخکې تګ» تاریخچه بې‌معنا کوي.
    _redo.clear();
  }

  Future<void> _undoLast() async {
    if (_undo.isEmpty) return;
    final current = await widget.timetable.snapshot(daily: _isDaily);
    final target = _undo.removeLast();
    _redo.add(current);
    await widget.timetable.restore(target, daily: _isDaily);
    if (!mounted) return;
    setState(() => _variant = null);
    await _load();
  }

  Future<void> _redoLast() async {
    if (_redo.isEmpty) return;
    final current = await widget.timetable.snapshot(daily: _isDaily);
    final target = _redo.removeLast();
    _undo.add(current);
    await widget.timetable.restore(target, daily: _isDaily);
    if (!mounted) return;
    setState(() => _variant = null);
    await _load();
  }

  // ── ځیرک ترتیب ────────────────────────────────────────

  /// یو ځیرک ترتیب جوړوي او پلې کوي.
  ///
  /// **ولې سمدستي پلې کېږي، نه یوه مخکتنه؟** ځکه چې یوه مخکتنه
  /// د جدول دویمه بڼه ده — کارن به يې له ریښتیني سره پرتله کوله.
  /// دلته ریښتینی جدول بدلېږي او انډو تل لاس‌رسي دی، نو د لیدلو
  /// او د بېرته تګ ترمنځ یوه تڼۍ فاصله ده.
  /// **ځیرک ترتیب — وړاندیزونه، نه یو حکم.**
  ///
  /// پروګرام ډېر بدیلونه ازمویي، ټول يې پاک (بې‌ټکره) جوړوي، بیا
  /// يې د کیفیت له مخې ترتیبوي او **غوره څو** کارن ته ښیي. پرېکړه
  /// د کارن ده — ځکه چې «غوره» یوازې ریاضي نه ده: ښايي دوه پلانونه
  /// دواړه پاک وي، خو یو يې د مدرسې له عادت سره سم وي.
  Future<void> _smartArrange(int variant) async {
    if (_arranging) return;
    setState(() => _arranging = true);

    final list = await widget.timetable.proposals(
      daily: _isDaily,
      sectionId: _isDaily ? null : _section?.sectionId,
    );

    if (!mounted) {
      return;
    }
    setState(() => _arranging = false);

    if (list.isEmpty) {
      _toast('هېڅ ترتیب ونه شو — لومړی کتابونه ثبت کړئ.', AppColors.warning);
      return;
    }

    final picked = await showDialog<ArrangementPlan>(
      context: context,
      builder: (_) => _ProposalDialog(plans: list),
    );
    if (picked == null) return;

    await _remember();
    await widget.timetable.applyPlan(picked);
    if (!mounted) return;
    setState(() {
      _variant = picked.variant;
      _clashes = picked.teacherClashes;
    });
    await _load();
    if (!mounted) return;

    final locale = S.of(context).locale;
    _toast(
      '${locale.num(picked.placed)} خانې ډکې شوې · '
      '${locale.num(picked.difficultyScore.round())}٪ د سختوالي ترتیب · '
      '${picked.teacherClashes == 0 ? 'هېڅ ټکر نشته' : '${locale.num(picked.teacherClashes)} ټکرونه'}',
      picked.isClean ? AppColors.success : AppColors.warning,
    );
  }

  void _toast(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 560,
        backgroundColor: color,
        content: Text(text),
      ),
    );
  }

  // ── کش کول ────────────────────────────────────────────

  /// یوه خانه بلې ته لېږدوي.
  Future<void> _moveCell({
    required int sectionId,
    required int fromDay,
    required int fromSlotId,
    required int toDay,
    required int toSlotId,
    int? toSectionId,
  }) async {
    await _remember();
    final r = await widget.timetable.moveEntry(
      sectionId: sectionId,
      fromDay: fromDay,
      fromSlotId: fromSlotId,
      toDay: toDay,
      toSlotId: toSlotId,
      toSectionId: toSectionId,
    );
    if (!mounted) return;

    if (r == MoveResult.crossSection) {
      // انځور بېرته اخلو — هېڅ بدلون نه دی شوی، نو په تاریخچه کې
      // يې ځای نه دی.
      _undo.removeLast();
      _warn(
        'یو درس له یوه ټولګي بل ته نه لېږدېږي — د هرې درجې خپل '
        'کتابونه دي.',
      );
      return;
    }
    if (r == MoveResult.emptySource) {
      _undo.removeLast();
      return;
    }

    setState(() => _variant = null);
    await _load();
  }

  void _warn(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 520,
        backgroundColor: AppColors.danger,
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final grid = _grid;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                if (!_isDaily) ...[
                  _SectionPicker(
                    sections: _sections,
                    selected: _section,
                    onPicked: (s) {
                      setState(() => _section = s);
                      _load();
                    },
                  ),
                  const SizedBox(width: 14),
                ],
                if (_isDaily && _daily != null)
                  Text(
                    '${locale.num(_daily!.filled)} له '
                    '${locale.num(_daily!.capacity)} خانو ډکې  ·  '
                    'یو ترتیب چې هره ورځ تکرارېږي',
                    style: TextStyle(fontSize: 12.5, color: p.muted),
                  )
                else if (grid != null)
                  Text(
                    '${locale.num(grid.filled)} له '
                    '${locale.num(grid.capacity)} خانو ډکې',
                    style: TextStyle(fontSize: 12.5, color: p.muted),
                  ),
                const SizedBox(width: 14),
                // **د ډول او د رنګ ټاکنه تنظیماتو ته ولاړه.**
                //
                // دا دواړه هره ورځ نه بدلېږي — یو ښوونځی یو ځل
                // ټاکي چې «مدرسه» دی او رنګ يې څه ښیي. یو تنظیم چې
                // پر کاري پاڼه ولاړ وي، هره ورځ ځای نیسي او یوازې
                // د غلطې کېکاږنې خطر زیاتوي.
                _SettingsHint(
                  text: _isDaily ? 'درجې (مدرسه)' : 'اونیز (مکتب)',
                  onTap: widget.onOpenSettings,
                ),
                const Spacer(),
                _SmartBar(
                  variant: _variant,
                  busy: _arranging,
                  canUndo: _undo.isNotEmpty,
                  canRedo: _redo.isNotEmpty,
                  clashes: _clashes,
                  onArrange: () => _smartArrange(_variant ?? 0),
                  onPrev: null,
                  onNext: null,
                  onUndo: _undo.isEmpty ? null : _undoLast,
                  onRedo: _redo.isEmpty ? null : _redoLast,
                ),
                const SizedBox(width: 12),
                // **د ټکرونو ژوندۍ شمېره — تل ښکاره.**
                //
                // مخکې یوازې هغه وخت راتله چې ټکر شتون درلود. خو
                // «هېڅ نه ښکاري» دوه شیان معنا کولی شي: یا ټکر نشته،
                // یا پروګرام يې نه ګوري. کارن باید دا دوه سره وپېژني
                // — نو زیری هم لیکل کېږي، نه یوازې خبرداری.
                _ClashBadge(
                  conflicts: _conflicts,
                  onTap: _conflicts.isEmpty ? null : _showConflicts,
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: _exporting ? null : _exportPdf,
                  icon: _exporting
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf_rounded, size: 16),
                  label: const Text('PDF'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 18),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _sections.isEmpty
                ? Center(
                    child: Text(
                      'لومړی ټولګي جوړ کړئ.',
                      style: TextStyle(fontSize: 13, color: p.muted),
                    ),
                  )
                : _isDaily
                ? (_daily == null
                      ? const SizedBox.shrink()
                      : _buildDaily(_daily!))
                : (grid == null
                      ? const SizedBox.shrink()
                      : _buildGrid(grid)),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(TimetableGrid grid) {
    final p = context.palette;

    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: p.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            // سرلیک — د ورځو نومونه.
            Container(
              color: p.surfaceAlt,
              child: Row(
                children: [
                  const SizedBox(width: 118),
                  for (final day in grid.days)
                    Expanded(
                      child: Container(
                        height: 44,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: p.line),
                          ),
                        ),
                        child: Text(
                          weekdayNamePs(day),
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: p.inkSoft,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            for (final slot in grid.slots)
              _SlotRow(
                slot: slot,
                days: grid.days,
                grid: grid,
                clashes: _clashKeys,
                colorMode: _colorMode,
                sectionId: _section?.sectionId,
                onTap: slot.isBreak ? null : _editCell,
                onDrop: slot.isBreak
                    ? null
                    : (from, day) => _moveCell(
                        sectionId: from.sectionId,
                        fromDay: from.dayOfWeek,
                        fromSlotId: from.slotId,
                        toDay: day,
                        toSlotId: slot.id,
                      ),
              ),
          ],
        ),
      ),
    );
  }

  /// **د مدرسې جدول** — کتارونه درجې دي، ستنې ساعتونه (له تفریح سره).
  ///
  /// دلته تفریح یوه **ستنه** ده، نه یو کتار — ځکه چې د ټولو درجو
  /// تفریح په یوه وخت کې ده، نو یوه نرۍ ستنه بس ده او د هرې درجې
  /// د ورځې ټول ترتیب په یوه کتار کې لیدل کېږي.
  Widget _buildDaily(DailyGrid daily) {
    final p = context.palette;
    final locale = S.of(context).locale;

    if (daily.rows.isEmpty) {
      return Center(
        child: Text(
          'لومړی درجې جوړې کړئ.',
          style: TextStyle(fontSize: 13, color: p.muted),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(color: p.line),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // سرلیک — د ساعتونو نومونه او وختونه.
              Container(
                color: p.surfaceAlt,
                child: Row(
                  children: [
                    const SizedBox(width: 150),
                    for (final slot in daily.slots)
                      Container(
                        width: slot.isBreak ? 62 : 150,
                        height: 50,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: slot.isBreak
                              ? AppColors.warning.withValues(alpha: 0.07)
                              : null,
                          border: Border(right: BorderSide(color: p.line)),
                        ),
                        // د تفریح ستنه نرۍ ده — یوازې نوم پکې ځایېږي.
                        // وخت يې په tooltip کې دی.
                        child: slot.isBreak
                            ? Tooltip(
                                message:
                                    '${locale.num(slot.startTime)}–'
                                    '${locale.num(slot.endTime)}',
                                child: Text(
                                  locale.num(slot.name),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.warning,
                                  ),
                                ),
                              )
                            : Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    locale.num(slot.name),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: p.inkSoft,
                                    ),
                                  ),
                                  Text(
                                    '${locale.num(slot.startTime)}–'
                                    '${locale.num(slot.endTime)}',
                                    style: AppTheme.tabular(
                                      TextStyle(fontSize: 9.5, color: p.faint),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                  ],
                ),
              ),
              for (final row in daily.rows)
                Container(
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: p.line)),
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          alignment: AlignmentDirectional.centerStart,
                          decoration: BoxDecoration(
                            color: p.surfaceAlt,
                            border: Border(left: BorderSide(color: p.line)),
                          ),
                          child: Text(
                            row.label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: p.ink,
                            ),
                          ),
                        ),
                        for (final slot in daily.slots)
                          SizedBox(
                            width: slot.isBreak ? 62 : 150,
                            child: slot.isBreak
                                ? Container(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.05,
                                    ),
                                  )
                                : _Cell(
                                    cell: daily.at(row.sectionId, slot.id),
                                    colorMode: _colorMode,
                                    conflict: _dailyClash(
                                      daily.at(row.sectionId, slot.id),
                                    ),
                                    onTap: () => _editDailyCell(
                                      row.sectionId,
                                      slot,
                                    ),
                                    // **کش کول یوازې د یوه کتار
                                    // دننه.** د درجه ثانیه قدوري
                                    // په درجه رابعه کې معنا نه
                                    // لري — `sectionId` پخپله
                                    // دا رد پلې کوي.
                                    drag: daily.at(row.sectionId, slot.id) ==
                                            null
                                        ? null
                                        : CellDrag(
                                            sectionId: row.sectionId,
                                            dayOfWeek: everyDay,
                                            slotId: slot.id,
                                          ),
                                    onDrop: (from) => _moveCell(
                                      sectionId: from.sectionId,
                                      fromDay: everyDay,
                                      fromSlotId: from.slotId,
                                      toDay: everyDay,
                                      toSlotId: slot.id,
                                      toSectionId: row.sectionId,
                                    ),
                                  ),
                          ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _SlotRow extends StatelessWidget {
  final TimeSlot slot;
  final List<int> days;
  final TimetableGrid grid;
  final int? sectionId;
  final void Function(int day, TimeSlot slot)? onTap;
  final void Function(CellDrag from, int day)? onDrop;

  /// «استاد-ورځ-ساعت» کلي چې ټکر لري.
  final Set<String> clashes;

  final CellColorMode colorMode;

  const _SlotRow({
    required this.slot,
    required this.days,
    required this.grid,
    this.sectionId,
    this.onTap,
    this.onDrop,
    this.clashes = const {},
    this.colorMode = CellColorMode.difficulty,
  });

  bool _hasClash(TimetableCell? c) =>
      c != null &&
      c.entry.teacherId != null &&
      clashes.contains(_TimetablePageState.clashKeyOf(c));

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    if (slot.isBreak) {
      return Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.07),
          border: Border(top: BorderSide(color: p.line)),
        ),
        child: Text(
          '${locale.num(slot.name)}  •  ${locale.num(slot.startTime)}–'
          '${locale.num(slot.endTime)}',
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.warning,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: p.line)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 118,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                border: Border(left: BorderSide(color: p.line)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    locale.num(slot.name),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    '${locale.num(slot.startTime)}–${locale.num(slot.endTime)}',
                    style: AppTheme.tabular(
                      TextStyle(fontSize: 10.5, color: p.faint),
                    ),
                  ),
                ],
              ),
            ),
            for (final day in days)
              Expanded(
                child: _Cell(
                  cell: grid.at(day, slot.id),
                  colorMode: colorMode,
                  conflict: _hasClash(grid.at(day, slot.id)),
                  onTap: onTap == null ? null : () => onTap!(day, slot),
                  drag: sectionId == null || grid.at(day, slot.id) == null
                      ? null
                      : CellDrag(
                          sectionId: sectionId!,
                          dayOfWeek: day,
                          slotId: slot.id,
                        ),
                  onDrop: onDrop == null ? null : (f) => onDrop!(f, day),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// د یوې خانې پېژندنه چې د کش کولو پر مهال وړل کېږي.
class CellDrag {
  final int sectionId;
  final int dayOfWeek;
  final int slotId;

  const CellDrag({
    required this.sectionId,
    required this.dayOfWeek,
    required this.slotId,
  });
}

class _Cell extends StatefulWidget {
  final TimetableCell? cell;
  final VoidCallback? onTap;

  /// که `null` وي، دا خانه نه کش کېږي (تشه ده یا جدول بند دی).
  final CellDrag? drag;

  /// کله چې بله خانه دلته پرېښودل شي.
  final void Function(CellDrag from)? onDrop;

  /// **دا خانه له بلې سره ټکر لري** — یو استاد په یوه وخت کې دوه
  /// ځایه دی.
  final bool conflict;

  /// رنګ څه ښیي.
  final CellColorMode colorMode;

  const _Cell({
    this.cell,
    this.onTap,
    this.drag,
    this.onDrop,
    this.conflict = false,
    this.colorMode = CellColorMode.difficulty,
  });

  @override
  State<_Cell> createState() => _CellState();
}

class _CellState extends State<_Cell>
    with SingleTickerProviderStateMixin {
  bool _hover = false;
  bool _over = false;

  /// **د ټکر چشمک.**
  ///
  /// یوه ثابته سره څنډه هم کار ورکوي، خو سترګه ورسره روږدې کېږي —
  /// دوه دقیقې وروسته یې نه ویني. یو ډېر نرم، ورو تنفس (۱٫۶ ثانیې)
  /// ژوندی پاتې کېږي پرته له دې چې ځوروونکی شي. **چټک ټوپ نه** —
  /// هغه هماغه شی دی چې د پردې خوځښت يې کوي: سترګه ستړې کوي.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.conflict) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_Cell old) {
    super.didUpdateWidget(old);
    if (widget.conflict && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.conflict && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = widget.conflict
        ? AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_pulse.value);
              return Stack(
                children: [
                  child!,
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.danger.withValues(
                            alpha: 0.06 + 0.10 * t,
                          ),
                          border: Border.all(
                            color: AppColors.danger.withValues(
                              alpha: 0.30 + 0.45 * t,
                            ),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // **په کونج کې یوه وړه خبرداري نښه.** رنګ یوازې
                  // هغه چا ته وايي چې پوهېږي رنګ څه معنا لري؛ نښه
                  // هر چا ته وايي.
                  PositionedDirectional(
                    top: 3,
                    start: 3,
                    child: IgnorePointer(
                      child: Tooltip(
                        message: 'ټکر — دا استاد په دې وخت کې بل '
                            'ځای هم ټاکل شوی دی.',
                        child: Icon(
                          Icons.warning_amber_rounded,
                          size: 13,
                          color: AppColors.danger.withValues(
                            alpha: 0.65 + 0.35 * t,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
            child: _body(context),
          )
        : _body(context);
    if (widget.onDrop == null) return body;

    // **`DragTarget` بهر دی او `Draggable` دننه.** برعکس يې کار نه
    // کاوه: یوه خانه چې پخپله کش کېږي، باید د بلې د پرېښودو ځای
    // هم وي — او د Flutter کش کول د ونې له پاسه راځي.
    return DragTarget<CellDrag>(
      onWillAcceptWithDetails: (d) {
        // **له یوه بخشه بل ته نه** — دا هغه قاعده ده چې د یوې
        // درجې کتابونه بلې ته تلو ته نه پرېږدي. رد يې دلته ښکاري
        // (خانه نه روښانېږي)، نو کارن مخکې له پرېښودو پوهېږي.
        final ok = widget.drag == null
            ? true
            : d.data.sectionId == widget.drag!.sectionId;
        if (ok) setState(() => _over = true);
        return ok;
      },
      onLeave: (_) => setState(() => _over = false),
      onAcceptWithDetails: (d) {
        setState(() => _over = false);
        widget.onDrop!(d.data);
      },
      builder: (context, _, _) => body,
    );
  }

  Widget _body(BuildContext context) {
    final p = context.palette;
    final cell = widget.cell;

    final inner = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: widget.drag != null
          ? SystemMouseCursors.grab
          : (widget.onTap == null
                ? MouseCursor.defer
                : SystemMouseCursors.click),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.instant,
          curve: AppMotion.standard,
          // درې کرښې: مضمون، استاد، خونه. ۵۸ پکسله يې نه نیول —
          // د خونې کرښه به بهر پاتې شوه.
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          decoration: BoxDecoration(
            color: _over
                // د پرېښودو ځای روښانېږي — کارن مخکې له پرېښودو
                // پوهېږي چې کومه خانه به ونیول شي.
                ? AppColors.modTimetable.withValues(alpha: 0.22)
                : cell == null
                ? (_hover ? p.surfaceAlt : Colors.transparent)
                : cellColor(
                    cell,
                    widget.colorMode,
                  ).withValues(alpha: _hover ? 0.20 : 0.13),
            border: Border(
              right: BorderSide(color: p.line),
            ),
          ),
          foregroundDecoration: _over
              ? BoxDecoration(
                  border: Border.all(color: AppColors.modTimetable, width: 2),
                )
              : null,
          child: cell == null
              ? Center(
                  child: AnimatedOpacity(
                    duration: AppMotion.instant,
                    opacity: _hover ? 1 : 0,
                    child: Icon(Icons.add_rounded, size: 17, color: p.faint),
                  ),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // **لومړۍ کرښه: د کتاب نوم.** فن یوه کورنۍ ده؛
                    // کتاب هغه څیز دی چې شاګرد يې راوړي او استاد
                    // يې لولي. درې درجې چې «فقه» ولري، یو شان
                    // ښکارېدې — خو «قدوري» او «هدایه» نه.
                    Text(
                      cell.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: cellColor(cell, widget.colorMode),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // **دویمه کرښه: استاد** — لږ کوچنی فونټ، چې
                    // کتاب لومړیتوب وساتي.
                    Text(
                      cell.teacherName ?? 'استاد نه دی ټاکل شوی',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: cell.teacherName == null
                            ? AppColors.warning
                            : p.muted,
                      ),
                    ),
                    if (cell.entry.room != null)
                      Text(
                        S.of(context).locale.num(cell.entry.room!),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, color: p.faint),
                      ),
                  ],
                ),
        ),
      ),
    );

    final drag = widget.drag;
    if (drag == null) return inner;

    return Draggable<CellDrag>(
      data: drag,
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _Ghost(cell: cell!, color: cellColor(cell, widget.colorMode)),
      childWhenDragging: Opacity(opacity: 0.3, child: inner),
      child: inner,
    );
  }
}

/// هغه کارت چې د کش کولو پر مهال د موږک تر لاندې راځي.
/// **د ټکرونو ژوندۍ نښه.**
///
/// شنه = پاک جدول. سره = دومره ټکرونه، او پر کلیک يې لیست راځي.
class _ClashBadge extends StatelessWidget {
  final List<TimetableConflict> conflicts;
  final VoidCallback? onTap;

  const _ClashBadge({required this.conflicts, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final clean = conflicts.isEmpty;
    final c = clean ? AppColors.success : AppColors.danger;

    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: c.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                clean
                    ? Icons.check_circle_rounded
                    : Icons.warning_amber_rounded,
                size: 16,
                color: c,
              ),
              const SizedBox(width: 8),
              Text(
                clean
                    ? 'هېڅ ټکر نشته'
                    : '${locale.num(conflicts.length)} ټکرونه',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
              if (!clean) ...[
                const SizedBox(width: 6),
                Icon(Icons.chevron_left_rounded, size: 16, color: c),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Ghost extends StatelessWidget {
  final TimetableCell cell;
  final Color color;

  const _Ghost({required this.cell, required this.color});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          cell.subjectName,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// **د ځیرک ترتیب کرښه** — جوړول، بدیلونه، انډو/ریډو.
class _SmartBar extends StatelessWidget {
  final int? variant;
  final bool busy;
  final bool canUndo;
  final bool canRedo;
  final int clashes;
  final VoidCallback onArrange;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;

  const _SmartBar({
    required this.variant,
    required this.busy,
    required this.canUndo,
    required this.canRedo,
    required this.clashes,
    required this.onArrange,
    this.onPrev,
    this.onNext,
    this.onUndo,
    this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'بېرته (انډو)',
          onPressed: busy ? null : onUndo,
          icon: Icon(
            Icons.undo_rounded,
            size: 19,
            color: canUndo ? p.inkSoft : p.faint,
          ),
        ),
        IconButton(
          tooltip: 'بیا (ریډو)',
          onPressed: busy ? null : onRedo,
          icon: Icon(
            Icons.redo_rounded,
            size: 19,
            color: canRedo ? p.inkSoft : p.faint,
          ),
        ),
        const SizedBox(width: 6),

        // **بدیلونه یوازې وروسته له لومړي ترتیبه ښکاري.** مخکې
        // له هغه ‹ › هېڅ معنا نه لري — کوم بدیل؟
        if (variant != null)
          Container(
            margin: const EdgeInsetsDirectional.only(end: 8),
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(color: p.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'پخوانی بدیل',
                  onPressed: busy ? null : onPrev,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: onPrev == null ? p.faint : p.inkSoft,
                  ),
                ),
                Tooltip(
                  message: clashes > 0
                      ? '${locale.num(clashes)} د استاد ټکرونه'
                      : 'هېڅ ټکر نشته',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: clashes > 0
                              ? AppColors.warning
                              : AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'بدیل ${locale.num(variant! + 1)}',
                        style: AppTheme.tabular(
                          TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: p.inkSoft,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'راتلونکی بدیل',
                  onPressed: busy ? null : onNext,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.chevron_left_rounded,
                    size: 20,
                    color: onNext == null ? p.faint : p.inkSoft,
                  ),
                ),
              ],
            ),
          ),

        FilledButton.icon(
          onPressed: busy ? null : onArrange,
          icon: busy
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.auto_fix_high_rounded, size: 17),
          label: Text(variant == null ? 'ځیرک ترتیب' : 'بیا وټاکه'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.modTimetable,
            minimumSize: const Size(0, 42),
            padding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _CellEdit {
  final int? subjectId;
  final int? teacherId;
  final String? room;
  final bool clear;

  const _CellEdit({this.subjectId, this.teacherId, this.room})
    : clear = false;
  const _CellEdit.clear()
    : subjectId = null,
      teacherId = null,
      room = null,
      clear = true;
}

class _CellDialog extends StatefulWidget {
  final int day;
  final TimeSlot slot;
  final List<Subject> subjects;
  final List<Teacher> teachers;
  final TimetableCell? current;

  const _CellDialog({
    required this.day,
    required this.slot,
    required this.subjects,
    required this.teachers,
    this.current,
  });

  @override
  State<_CellDialog> createState() => _CellDialogState();
}

class _CellDialogState extends State<_CellDialog> {
  late int? _subjectId = widget.current?.entry.subjectId;
  late int? _teacherId = widget.current?.entry.teacherId;
  late final _room = TextEditingController(
    text: widget.current?.entry.room ?? '',
  );

  @override
  void dispose() {
    _room.dispose();
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
        '${weekdayNamePs(widget.day)} — ${locale.num(widget.slot.name)}'
        '  (${locale.num(widget.slot.startTime)})',
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Label('مضمون'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _subjectId,
              isExpanded: true,
              items: [
                for (final s in widget.subjects)
                  DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name, style: const TextStyle(fontSize: 13)),
                  ),
              ],
              onChanged: (v) => setState(() => _subjectId = v),
            ),
            const SizedBox(height: 16),
            const _Label('استاد'),
            const SizedBox(height: 8),
            DropdownButtonFormField<int?>(
              initialValue: _teacherId,
              isExpanded: true,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text(
                    'نه دی ټاکل شوی',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
                for (final t in widget.teachers)
                  DropdownMenuItem(
                    value: t.id,
                    child: Text(
                      t.fullName,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
              ],
              onChanged: (v) => setState(() => _teacherId = v),
            ),
            const SizedBox(height: 16),
            const _Label('خونه (اختیاري)'),
            const SizedBox(height: 8),
            TextField(
              controller: _room,
              decoration: const InputDecoration(hintText: 'لکه ۱۰۱'),
            ),
          ],
        ),
      ),
      actions: [
        if (widget.current != null)
          TextButton(
            onPressed: () => Navigator.pop(context, const _CellEdit.clear()),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('پاک کړه'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('بندول'),
        ),
        FilledButton(
          onPressed: _subjectId == null
              ? null
              : () => Navigator.pop(
                  context,
                  _CellEdit(
                    subjectId: _subjectId,
                    teacherId: _teacherId,
                    room: _room.text,
                  ),
                ),
          child: const Text('وساتـه'),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: context.palette.muted,
    ),
  );
}

class _SectionPicker extends StatelessWidget {
  final List<SectionOption> sections;
  final SectionOption? selected;
  final ValueChanged<SectionOption> onPicked;

  const _SectionPicker({
    required this.sections,
    required this.selected,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<SectionOption>(
      tooltip: '',
      onSelected: onPicked,
      itemBuilder: (_) => [
        for (final s in sections)
          PopupMenuItem(
            value: s,
            child: Text(s.label, style: const TextStyle(fontSize: 13)),
          ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.meeting_room_rounded,
              size: 17,
              color: AppColors.modTimetable,
            ),
            const SizedBox(width: 9),
            Text(
              selected?.label ?? 'ټولګی وټاکئ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.expand_more_rounded, size: 17, color: p.muted),
          ],
        ),
      ),
    );
  }
}


// ═══════════════════════════════════════════════════════════
//  د ځیرک ترتیب وړاندیزونه
// ═══════════════════════════════════════════════════════════

/// **پروګرام حساب کوي، کارن ټاکي.**
///
/// هر وړاندیز خپلې شمېرې پر ځان وړي، نو انتخاب یو اټکل نه دی:
/// څو خانې ډکې شوې، د سختوالي ترتیب څومره سم دی، څو خانې لا
/// استاد نه لري، او — تر ټولو مهم — څو ټکرونه پکې دي.
class _ProposalDialog extends StatefulWidget {
  final List<ArrangementPlan> plans;
  const _ProposalDialog({required this.plans});

  @override
  State<_ProposalDialog> createState() => _ProposalDialogState();
}

class _ProposalDialogState extends State<_ProposalDialog> {
  int _picked = 0;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final allClean = widget.plans.every((x) => x.isClean);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(
            Icons.auto_fix_high_rounded,
            size: 19,
            color: AppColors.modTimetable,
          ),
          const SizedBox(width: 9),
          const Text(
            'ځیرک ترتیب',
            style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            '${locale.num(widget.plans.length)} وړاندیزونه',
            style: TextStyle(fontSize: 12, color: p.muted),
          ),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                allClean
                    ? 'ټول لاندې وړاندیزونه بې‌ټکره دي — یو استاد په '
                          'هېڅ یوه کې دوه ځایه نه دی. یو غوره کړئ.'
                    : 'هېڅ بشپړ پاک ترتیب ونه موندل شو — د استادانو '
                          'شمېر لږ دی. غوره پاتې دا دي.',
                style: TextStyle(fontSize: 12, color: p.muted),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < widget.plans.length; i++)
                _ProposalRow(
                  index: i,
                  plan: widget.plans[i],
                  selected: _picked == i,
                  onTap: () => setState(() => _picked = i),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton.icon(
          onPressed: () => Navigator.pop(context, widget.plans[_picked]),
          icon: const Icon(Icons.check_rounded, size: 17),
          label: const Text('دا ترتیب پلی کړه'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.modTimetable,
          ),
        ),
      ],
    );
  }
}

class _ProposalRow extends StatelessWidget {
  final int index;
  final ArrangementPlan plan;
  final bool selected;
  final VoidCallback onTap;

  const _ProposalRow({
    required this.index,
    required this.plan,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    const c = AppColors.modTimetable;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(13, 11, 13, 11),
        decoration: BoxDecoration(
          color: selected ? c.withValues(alpha: 0.09) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: selected ? c.withValues(alpha: 0.5) : p.line,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: selected ? c : p.faint,
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        'وړاندیز ${locale.num(index + 1)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: p.ink,
                        ),
                      ),
                      if (index == 0) ...[
                        const SizedBox(width: 8),
                        const Pill(color: AppColors.success, text: 'غوره'),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      _Metric(
                        icon: plan.teacherClashes == 0
                            ? Icons.check_circle_rounded
                            : Icons.warning_amber_rounded,
                        color: plan.teacherClashes == 0
                            ? AppColors.success
                            : AppColors.danger,
                        text: plan.teacherClashes == 0
                            ? 'بې ټکره'
                            : '${locale.num(plan.teacherClashes)} ټکرونه',
                      ),
                      _Metric(
                        icon: Icons.trending_up_rounded,
                        color: plan.difficultyScore >= 75
                            ? AppColors.success
                            : AppColors.warning,
                        text: 'سخت→سهار '
                            '${locale.num(plan.difficultyScore.round())}٪',
                      ),
                      _Metric(
                        icon: Icons.grid_on_rounded,
                        color: p.muted,
                        text: '${locale.num(plan.placed)} خانې '
                            '(${locale.num(plan.fillPercent.round())}٪)',
                      ),
                      if (plan.unstaffed > 0)
                        _Metric(
                          icon: Icons.person_off_rounded,
                          color: AppColors.warning,
                          text: '${locale.num(plan.unstaffed)} بې‌استاده',
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _Metric({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: color),
      const SizedBox(width: 5),
      Text(
        text,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}


/// یوه وړه نښه چې تنظیماتو ته بیایي — هغه تنظیم چې دلته اغېز
/// کوي، خو دلته نه ټاکل کېږي.
class _SettingsHint extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const _SettingsHint({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(color: p.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.table_rows_rounded, size: 15, color: p.muted),
              const SizedBox(width: 7),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: p.inkSoft,
                ),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 7),
                Icon(Icons.tune_rounded, size: 14, color: p.faint),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
