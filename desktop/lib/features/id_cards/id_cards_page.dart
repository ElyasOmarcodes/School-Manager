import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/student_repository.dart';
import 'id_card.dart';
import 'id_card_pdf.dart';

/// د آی‌ډي کارتونو پاڼه — ټاکل، کتنه، چاپ.
///
/// بهیر: بخش وټاکه ← کارتونه راڅرګند شي ← هغه ټاک چې چاپ يې غواړې
/// ← «چاپ کړه» ووهه. PDF د سیسټم د چاپ پاڼې ته ځي، نو مدیر يې
/// مخکې له چاپه لیدلی شي.
class IdCardsPage extends StatefulWidget {
  final StudentRepository students;
  final AcademicRepository academic;
  final String schoolName;

  const IdCardsPage({
    super.key,
    required this.students,
    required this.academic,
    required this.schoolName,
  });

  @override
  State<IdCardsPage> createState() => _IdCardsPageState();
}

class _IdCardsPageState extends State<IdCardsPage> {
  List<SectionOption> _sections = const [];
  int? _sectionId;
  String _yearLabel = '';

  List<StudentRow> _rows = const [];
  final Set<int> _selected = {};
  bool _loading = true;
  bool _printing = false;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final year = await widget.academic.currentYear();
    final sections = await widget.academic.sections();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _yearLabel = year?.label ?? '';
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final page = await widget.students.list(
      filter: StudentFilter(sectionId: _sectionId),
      limit: 200,
    );
    if (!mounted) return;
    setState(() {
      _rows = page.items;
      // د بخش په بدلون سره پخوانی انتخاب پاکېږي — که نه، مدیر به
      // نه پوهېده چې د بل بخش شاګردان لا هم ټاکل شوي دي.
      _selected
        ..clear()
        ..addAll(page.items.map((r) => r.student.id));
      _loading = false;
    });
  }

  List<CardData> get _cards => _rows
      .where((r) => _selected.contains(r.student.id))
      .map(
        (r) => CardData.forStudent(
          student: r.student,
          schoolName: widget.schoolName,
          className: r.className,
          yearLabel: _yearLabel,
        ),
      )
      .toList();

  /// هغو شاګردانو ته کلي ورکوي چې نه يې لري، بیا لیست تازه کوي.
  Future<void> _generateKeys() async {
    setState(() => _generating = true);
    final n = await widget.students.backfillQrSecrets();
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    setState(() => _generating = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 420,
        backgroundColor: AppColors.success,
        content: Text(
          'د ${S.of(context).locale.num(n)} شاګردانو کارت کلي جوړ شول.',
        ),
      ),
    );
  }

  Future<void> _print() async {
    final cards = _cards;
    if (cards.isEmpty) return;
    setState(() => _printing = true);
    final locale = S.of(context).locale;
    try {
      final bytes = await IdCardPdf.build(cards: cards, locale: locale);
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final missingKey = _rows
        .where(
          (r) => _selected.contains(r.student.id) && r.student.qrSecret == null,
        )
        .length;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                SizedBox(
                  width: 220,
                  child: DropdownButtonFormField<int?>(
                    initialValue: _sectionId,
                    isDense: true,
                    decoration: const InputDecoration(
                      labelText: 'بخش',
                      isDense: true,
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('ټول بخشونه'),
                      ),
                      for (final sec in _sections)
                        DropdownMenuItem(
                          value: sec.sectionId,
                          child: Text(sec.label),
                        ),
                    ],
                    onChanged: (v) {
                      setState(() => _sectionId = v);
                      _load();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _rows.isEmpty
                      ? null
                      : () => setState(() {
                          if (_selected.length == _rows.length) {
                            _selected.clear();
                          } else {
                            _selected
                              ..clear()
                              ..addAll(_rows.map((r) => r.student.id));
                          }
                        }),
                  child: Text(
                    _selected.length == _rows.length && _rows.isNotEmpty
                        ? 'هېڅ مه ټاکه'
                        : 'ټول وټاکه',
                  ),
                ),
                const Spacer(),
                Text(
                  '${locale.num(_selected.length)} کارتونه · '
                  '${locale.num((_selected.length / IdCardPdf.perPage).ceil())} پاڼې',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
                const SizedBox(width: 14),
                FilledButton.icon(
                  onPressed: _selected.isEmpty || _printing ? null : _print,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                  icon: _printing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print_rounded, size: 17),
                  label: const Text('چاپ کړه'),
                ),
              ],
            ),
          ),

          if (missingKey > 0) ...[
            const SizedBox(height: 14),
            _Warn(
              text:
                  '${locale.num(missingKey)} شاګردان د QR پټ کلي پرته دي — '
                  'د هغوی کارت به QR ونه لري او سکینر به يې ونه پېژني.',
              actionLabel: 'کلي جوړ کړه',
              onAction: _generating ? null : _generateKeys,
            ),
          ],

          const SizedBox(height: 18),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _rows.isEmpty
                ? const _Empty(text: 'په دې بخش کې هېڅ شاګرد نشته.')
                : SingleChildScrollView(
                    child: Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (var i = 0; i < _rows.length; i++)
                          FadeSlideIn.staggered(
                            index: i,
                            offsetY: 8,
                            child: _SelectableCard(
                              selected: _selected.contains(_rows[i].student.id),
                              onTap: () => setState(() {
                                final id = _rows[i].student.id;
                                if (!_selected.remove(id)) _selected.add(id);
                              }),
                              child: IdCardView(
                                width: 300,
                                locale: locale,
                                data: CardData.forStudent(
                                  student: _rows[i].student,
                                  schoolName: widget.schoolName,
                                  className: _rows[i].className,
                                  yearLabel: _yearLabel,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SelectableCard extends StatelessWidget {
  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  const _SelectableCard({
    required this.selected,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Opacity(opacity: selected ? 1 : 0.45, child: child),
            PositionedDirectional(
              top: 8,
              start: 8,
              child: AnimatedOpacity(
                duration: AppMotion.fast,
                opacity: selected ? 1 : 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Warn extends StatelessWidget {
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _Warn({required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 17,
            color: AppColors.warning,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.7,
                color: AppColors.warning,
              ),
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onAction,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.qr_code_2_rounded, size: 40, color: p.faint),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(fontSize: 13, color: p.muted)),
        ],
      ),
    );
  }
}
