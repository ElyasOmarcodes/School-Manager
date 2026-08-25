import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../auth/auth_service.dart';

/// د یوې کرښې حالت — درې خانې او د دوی کنټرولرونه.
class _Draft {
  final TextEditingController first;
  final TextEditingController father;
  int? sectionId;

  _Draft({String firstName = '', String fatherName = '', this.sectionId})
    : first = TextEditingController(text: firstName),
      father = TextEditingController(text: fatherName);

  bool get isEmpty =>
      first.text.trim().isEmpty && father.text.trim().isEmpty;
  bool get isReady =>
      first.text.trim().isNotEmpty && father.text.trim().isNotEmpty;

  void dispose() {
    first.dispose();
    father.dispose();
  }
}

/// **ډله ایزه نوم لیکنه** — درې خانې، بس.
///
/// د کال په پیل کې دوه سوه کسان په یوه ورځ راځي. که هر یو ته بشپړ
/// ویزارډ ډکېده، مدیر به تر ماښامه شل کسه ثبت کړي وای — او هغه به
/// هم د پلار د کار او د تذکرې د نمبر په لټه کې پاتې و.
///
/// دلته یوازې هغه څه اخلو چې **همدا اوس معلوم دي**: نوم، د پلار
/// نوم، درجه. پاتې يې د پروفایل له لارې بشپړېږي — او د شاګردانو په
/// پاڼه کې «نیمګړی پروفایل» فلټر همدا لیست راباسي، نو هېڅوک نه
/// هېرېږي.
class BulkEnrollPage extends StatefulWidget {
  final StudentRepository students;
  final AcademicRepository academic;
  final Session session;
  final VoidCallback onDone;

  const BulkEnrollPage({
    super.key,
    required this.students,
    required this.academic,
    required this.session,
    required this.onDone,
  });

  @override
  State<BulkEnrollPage> createState() => _BulkEnrollPageState();
}

class _BulkEnrollPageState extends State<BulkEnrollPage> {
  static const int _initialRows = 8;

  final List<_Draft> _rows = [];
  List<SectionOption> _sections = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  /// د ټولو کرښو ګډ ټولګی — یوه ډله معمولاً یوه درجه ده.
  int? _defaultSection;
  String _gender = 'male';
  String _residency = 'day';

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _initialRows; i++) {
      _rows.add(_addRow());
    }
    _load();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  _Draft _addRow() {
    final d = _Draft(sectionId: _defaultSection);
    // **دا هغه ټوټه ده چې ټوله پاڼه کار کوي.** کله چې کارن په
    // وروستۍ کرښه کې څه ولیکي، سمدستي یوه نوې کرښه ورزیاتېږي —
    // نو هېڅکله د «کرښه زیاته کړه» تڼۍ ته اړتیا نه لري او لاسونه
    // يې له کیبورډه نه لرې کېږي.
    void grow() {
      if (_rows.isEmpty || _rows.last != d) return;
      if (d.isEmpty) return;
      setState(() => _rows.add(_addRow()));
    }

    d.first.addListener(grow);
    d.father.addListener(grow);
    return d;
  }

  Future<void> _load() async {
    final sections = await widget.academic.sections();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _loading = false;
    });
  }

  void _setDefaultSection(int? id) {
    setState(() {
      _defaultSection = id;
      // یوازې هغه کرښې چې لا تشې دي — که د یوې کرښې ټولګی په لاس
      // بدل شوی وي، هغه نه لمسوو.
      for (final r in _rows) {
        if (r.isEmpty) r.sectionId = id;
      }
    });
  }

  Future<void> _save() async {
    final ready = _rows.where((r) => r.isReady).toList();
    if (ready.isEmpty) {
      setState(() => _error = 'لږ تر لږه یوه بشپړه کرښه پکار ده.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final year = await widget.academic.currentYear();
      if (year == null) throw StateError('د زده‌کړې کال نشته');

      final made = await widget.students.bulkAdmit(
        rows: [
          for (final r in ready)
            (
              firstName: r.first.text,
              fatherName: r.father.text,
              sectionId: r.sectionId ?? _defaultSection,
            ),
        ],
        academicYearId: year.id,
        yearPrefix: _prefix(year.label),
        byUserId: widget.session.userId,
        byUserName: widget.session.username,
        defaultGender: _gender,
        defaultResidency: _residency,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 460,
          backgroundColor: AppColors.success,
          content: Text(
            '${S.of(context).locale.num(made)} شاګردان ثبت شول. '
            'پروفایلونه يې لا نیمګړي دي.',
          ),
        ),
      );
      widget.onDone();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = 'ثبت ونه شو: $e';
      });
    }
  }

  static String _prefix(String label) {
    final d = Numerals.toLatin(label).replaceAll(RegExp(r'[^0-9]'), '');
    return d.isEmpty ? '0000' : d;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final ready = _rows.where((r) => r.isReady).length;

    return Column(
      children: [
        // ── ګډ تنظیمات ────────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 14),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 250,
                child: DropdownButtonFormField<int?>(
                  initialValue: _defaultSection,
                  isDense: true,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'د ټولو لپاره درجه/ټولګی',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('—')),
                    for (final sec in _sections)
                      DropdownMenuItem(
                        value: sec.sectionId,
                        child: Text(
                          sec.label,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: _setDefaultSection,
                ),
              ),
              const SizedBox(width: 14),
              SegmentedChoice<String>(
                value: _gender,
                options: const [
                  (value: 'male', label: 'هلکان', icon: null),
                  (value: 'female', label: 'نجونې', icon: null),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(width: 10),
              SegmentedChoice<String>(
                value: _residency,
                color: AppColors.modHostel,
                options: [
                  (
                    value: 'day',
                    label: s.dayScholar,
                    icon: Icons.wb_sunny_rounded,
                  ),
                  (
                    value: 'boarding',
                    label: s.boarder,
                    icon: Icons.night_shelter_rounded,
                  ),
                ],
                onChanged: (v) => setState(() => _residency = v),
              ),
              const Spacer(),
              Pill(
                color: ready == 0 ? p.faint : AppColors.success,
                icon: Icons.playlist_add_check_rounded,
                text: '${locale.num(ready)} بشپړې کرښې',
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _saving || ready == 0 ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded, size: 17),
                label: Text('${locale.num(ready)} کسان ثبت کړه'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.modStudents,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ),

        if (_error != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 11),
            color: AppColors.danger.withValues(alpha: 0.1),
            child: Text(
              _error!,
              style: const TextStyle(fontSize: 12.5, color: AppColors.danger),
            ),
          ),

        // ── د کرښو سرلیک ──────────────────────────────────
        Container(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
          child: Row(
            children: [
              SizedBox(
                width: 42,
                child: Text('#', style: _headStyle(p)),
              ),
              Expanded(flex: 3, child: Text('نوم', style: _headStyle(p))),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text('د پلار نوم', style: _headStyle(p)),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Text('درجه — صنف', style: _headStyle(p)),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
        Divider(height: 1, color: p.line),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 20),
            itemCount: _rows.length + 1,
            itemBuilder: (context, i) {
              if (i == _rows.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _rows.add(_addRow())),
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text('کرښه زیاته کړه'),
                    ),
                  ),
                );
              }
              return _RowEditor(
                index: i,
                draft: _rows[i],
                sections: _sections,
                locale: locale,
                onRemove: _rows.length <= 1
                    ? null
                    : () => setState(() {
                        _rows.removeAt(i).dispose();
                      }),
                onChanged: () => setState(() {}),
              );
            },
          ),
        ),
      ],
    );
  }

  static TextStyle _headStyle(AppPalette p) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: p.faint,
  );
}

class _RowEditor extends StatelessWidget {
  final int index;
  final _Draft draft;
  final List<SectionOption> sections;
  final AppLocale locale;
  final VoidCallback? onRemove;
  final VoidCallback onChanged;

  const _RowEditor({
    required this.index,
    required this.draft,
    required this.sections,
    required this.locale,
    required this.onRemove,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ready = draft.isReady;
    // نیمګړې کرښه — یوه خانه ډکه، بله تشه. دا هغه حالت دی چې کارن
    // يې باید وویني، نه دا چې په خاموشۍ سره پرېښودل شي.
    final partial = !draft.isEmpty && !ready;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: ready
                    ? AppColors.success.withValues(alpha: 0.14)
                    : partial
                    ? AppColors.warning.withValues(alpha: 0.14)
                    : p.surfaceAlt,
                borderRadius: BorderRadius.circular(7),
              ),
              alignment: Alignment.center,
              child: Text(
                locale.num(index + 1),
                style: AppTheme.tabular(
                  TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: ready
                        ? AppColors.success
                        : partial
                        ? AppColors.warning
                        : p.faint,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: TextField(
              controller: draft.first,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'احمد',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextField(
              controller: draft.father,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'محمود',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<int?>(
              initialValue: draft.sectionId,
              isDense: true,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 11,
                ),
              ),
              items: [
                const DropdownMenuItem(value: null, child: Text('—')),
                for (final sec in sections)
                  DropdownMenuItem(
                    value: sec.sectionId,
                    child: Text(sec.label, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) {
                draft.sectionId = v;
                onChanged();
              },
            ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              tooltip: 'کرښه ړنګه کړه',
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline_rounded, size: 17),
              color: p.faint,
            ),
          ),
        ],
      ),
    );
  }
}
