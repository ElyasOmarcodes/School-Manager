import 'dart:async';

import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/calendars.dart';
import '../../core/utils/qr_token.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/card_repository.dart';
import '../../data/repositories/user_repository.dart' show Perm;
import '../../widgets/data_table_view.dart' show AvatarCell;
import '../auth/auth_service.dart';
import 'card_canvas.dart';
import 'card_layout.dart';
import 'card_pdf.dart';

/// **د آی‌ډي کارتونو پاڼه** — د یوې ډلې لپاره.
///
/// درې ډلې درې لارې لري (شاګردان، استادان، کارمندان)، خو یوه پاڼه.
/// **ولې؟** ځکه چې کار يې یو دی: وټاکه، وګوره، چاپ کړه. که درې
/// پاڼې وې، د یوه فلټر زیاتول به درې ځله کېده.
class CardsPage extends StatefulWidget {
  final CardRepository cards;
  final AcademicRepository academic;
  final Session session;
  final String schoolName;

  /// `student` | `teacher` | `staff`
  final String audience;

  /// د کینډۍ ډیزاینر ته تګ.
  final void Function(CardTemplate? template)? onDesign;

  final DateTime Function() clock;

  const CardsPage({
    super.key,
    required this.cards,
    required this.academic,
    required this.session,
    required this.schoolName,
    required this.audience,
    this.onDesign,
    this.clock = DateTime.now,
  });

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final _search = TextEditingController();
  Timer? _debounce;

  List<CardHolder> _holders = const [];
  List<SectionOption> _sections = const [];
  List<CardTemplate> _templates = const [];
  CardTemplate? _active;
  School? _school;
  String _yearLabel = '';

  final Set<int> _selected = {};
  bool _loading = true;
  bool _printing = false;

  String _query = '';
  int? _sectionId;
  String? _state;

  /// `grid` (لوی کارتونه) | `list`
  String _view = 'grid';

  bool get _canEdit =>
      widget.session.permissions.can('id_cards', Perm.edit);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void didUpdateWidget(CardsPage old) {
    super.didUpdateWidget(old);
    if (old.audience != widget.audience) {
      _selected.clear();
      _sectionId = null;
      _state = null;
      _boot();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _boot() async {
    final year = await widget.academic.currentYear();
    final sections = await widget.academic.sections();
    final school = await widget.academic.school();
    if (!mounted) return;
    setState(() {
      _sections = sections;
      _school = school;
      _yearLabel = year?.label ?? '';
    });
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final holders = await widget.cards.holders(
      audience: widget.audience,
      now: widget.clock(),
      query: _query,
      groupId: _sectionId,
      state: _state,
    );
    final templates = await widget.cards.templates(widget.audience);
    final active = await widget.cards.active(widget.audience);
    if (!mounted) return;
    setState(() {
      _holders = holders;
      _templates = templates;
      _active = active;
      _selected.retainWhere((id) => holders.any((h) => h.id == id));
      _loading = false;
    });
  }

  void _onSearch(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      if (!mounted) return;
      setState(() => _query = v);
      _load();
    });
  }

  /// هغه ډیزاین چې اوس کارېږي — که هېڅ ونه ټاکل شي، تلواله.
  CardLayout get _layout => _active == null
      ? builtInCardTemplates(widget.audience).first.layout
      : CardLayout.decode(_active!.layoutJson);

  double get _aspect => _active == null
      ? cr80WidthMm / cr80HeightMm
      : _active!.widthMm / _active!.heightMm;

  CardValues _valuesFor(CardHolder h) => CardValues(
    schoolName: widget.schoolName,
    fullName: h.fullName,
    fatherName: h.fatherName,
    idNo: h.idNo,
    className: widget.audience == 'student' ? h.subtitle : '',
    jobTitle: widget.audience == 'student' ? '' : h.subtitle,
    yearLabel: _yearLabel,
    phone: h.phone,
    photoPath: h.photoPath,
    logoPath: _school?.logoPath,
    expiresOn: h.expiresOn,
    // پرته له پټ کلي، QR جوړول د یوه جعلي کارت جوړول دي — سکینر
    // به يې رد کړ او هېڅوک به پوه نه شو ولې.
    qrPayload: h.qrSecret == null || h.qrSecret!.isEmpty
        ? ''
        : QrToken.encode(
            admissionNo: h.idNo,
            cardVersion: h.cardVersion,
            schoolKey: h.qrSecret!,
          ),
  );

  /// **چاپ — او همدلته د پای نېټه ثبتېږي.**
  ///
  /// کارت د چاپ پر مهال زېږېږي. که نېټه د داخلې پر مهال ثبتېده، هر
  /// شاګرد به «کارت» لاره، حتی هغه چې هېڅکله يې کارت نه دی لیدلی.
  Future<void> _print() async {
    final chosen = _holders.where((h) => _selected.contains(h.id)).toList();
    if (chosen.isEmpty) return;

    setState(() => _printing = true);
    final locale = S.of(context).locale;
    final expiry = await widget.cards.defaultExpiry(widget.clock());

    try {
      await widget.cards.issue(
        audience: widget.audience,
        ids: [for (final h in chosen) h.id],
        expiresOn: expiry,
      );
      // نېټه اوس په ډیټابیس کې ده — نو کارت هم باید هماغه وښیي.
      final withExpiry = [
        for (final h in chosen)
          CardValues(
            schoolName: widget.schoolName,
            fullName: h.fullName,
            fatherName: h.fatherName,
            idNo: h.idNo,
            className: widget.audience == 'student' ? h.subtitle : '',
            jobTitle: widget.audience == 'student' ? '' : h.subtitle,
            yearLabel: _yearLabel,
            phone: h.phone,
            photoPath: h.photoPath,
            logoPath: _school?.logoPath,
            expiresOn: expiry,
            qrPayload: _valuesFor(h).qrPayload,
          ),
      ];

      final bytes = await CardPdf.build(
        cards: withExpiry,
        layout: _layout,
        locale: locale,
        widthMm: _active?.widthMm ?? cr80WidthMm,
        heightMm: _active?.heightMm ?? cr80HeightMm,
      );
      await Printing.layoutPdf(onLayout: (_) async => bytes);
    } finally {
      if (mounted) setState(() => _printing = false);
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final now = widget.clock();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 260,
                  child: TextField(
                    controller: _search,
                    onChanged: _onSearch,
                    decoration: InputDecoration(
                      hintText: '${s.search} — نوم یا نمبر',
                      prefixIcon: const Icon(Icons.search_rounded, size: 18),
                      isDense: true,
                    ),
                  ),
                ),
                if (widget.audience == 'student' && _sections.isNotEmpty)
                  SizedBox(
                    width: 176,
                    child: DropdownButtonFormField<int?>(
                      initialValue: _sectionId,
                      isDense: true,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: s.classes,
                        isDense: true,
                      ),
                      items: [
                        DropdownMenuItem(value: null, child: Text(s.all)),
                        for (final sec in _sections)
                          DropdownMenuItem(
                            value: sec.sectionId,
                            child: Text('${sec.gradeName} — ${sec.sectionName}'),
                          ),
                      ],
                      onChanged: (v) {
                        setState(() => _sectionId = v);
                        _load();
                      },
                    ),
                  ),
                SegmentedChoice<String?>(
                  value: _state,
                  color: AppColors.modIdCards,
                  options: [
                    (value: null, label: s.all, icon: null),
                    (
                      value: 'none',
                      label: 'کارت نه لري',
                      icon: Icons.credit_card_off_rounded,
                    ),
                    (
                      value: 'expired',
                      label: 'باطل',
                      icon: Icons.event_busy_rounded,
                    ),
                    (
                      value: 'soon',
                      label: 'نژدې پای',
                      icon: Icons.timelapse_rounded,
                    ),
                    (
                      value: 'valid',
                      label: 'روان',
                      icon: Icons.verified_rounded,
                    ),
                  ],
                  onChanged: (v) {
                    setState(() => _state = v);
                    _load();
                  },
                ),
                SegmentedChoice<String>(
                  value: _view,
                  options: const [
                    (
                      value: 'grid',
                      label: 'کارتونه',
                      icon: Icons.grid_view_rounded,
                    ),
                    (
                      value: 'list',
                      label: 'لیست',
                      icon: Icons.view_list_rounded,
                    ),
                  ],
                  onChanged: (v) => setState(() => _view = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── د ډیزاین کرښه ─────────────────────────────────
          FadeSlideIn.staggered(
            index: 1,
            child: Row(
              children: [
                Icon(Icons.palette_rounded, size: 17, color: p.muted),
                const SizedBox(width: 9),
                Text(
                  'ډیزاین: ',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
                Text(
                  _active?.name ?? builtInCardTemplates(widget.audience).first.name,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const SizedBox(width: 10),
                for (final t in _templates.take(4))
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 6),
                    child: _TemplateChip(
                      template: t,
                      active: t.id == _active?.id,
                      onTap: _canEdit
                          ? () async {
                              await widget.cards.activate(
                                t.id,
                                widget.audience,
                              );
                              await _load();
                            }
                          : null,
                      onEdit: widget.onDesign == null
                          ? null
                          : () => widget.onDesign!(t),
                    ),
                  ),
                if (widget.onDesign != null)
                  OutlinedButton.icon(
                    onPressed: () => widget.onDesign!(null),
                    icon: const Icon(Icons.brush_rounded, size: 16),
                    label: const Text('نوی ډیزاین'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 36),
                    ),
                  ),

                const Spacer(),
                Text(
                  '${locale.num(_selected.length)} له '
                  '${locale.num(_holders.length)} ټاکل شوي',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: _holders.isEmpty
                      ? null
                      : () => setState(() {
                          if (_selected.length == _holders.length) {
                            _selected.clear();
                          } else {
                            _selected
                              ..clear()
                              ..addAll(_holders.map((h) => h.id));
                          }
                        }),
                  child: Text(
                    _selected.length == _holders.length && _holders.isNotEmpty
                        ? 'هېڅ مه ټاکه'
                        : 'ټول وټاکه',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _selected.isEmpty || _printing ? null : _print,
                  icon: _printing
                      ? const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.print_rounded, size: 17),
                  label: const Text('چاپ'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.modIdCards,
                    minimumSize: const Size(0, 42),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _holders.isEmpty
                ? const EmptyState(
                    icon: Icons.badge_rounded,
                    text: 'هېڅ کس ونه موندل شو.',
                  )
                : _view == 'grid'
                ? _grid(now, locale)
                : _list(now, locale),
          ),
        ],
      ),
    );
  }

  Widget _grid(DateTime now, AppLocale locale) {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final h in _holders)
            _Selectable(
              selected: _selected.contains(h.id),
              state: h.stateAt(now),
              onTap: () => setState(() {
                if (!_selected.remove(h.id)) _selected.add(h.id);
              }),
              child: CardCanvas(
                layout: _layout,
                values: _valuesFor(h),
                locale: locale,
                width: 306,
                aspect: _aspect,
              ),
            ),
        ],
      ),
    );
  }

  Widget _list(DateTime now, AppLocale locale) {
    final p = context.palette;

    return ListView.builder(
      itemCount: _holders.length,
      itemBuilder: (context, i) {
        final h = _holders[i];
        final state = h.stateAt(now);
        final selected = _selected.contains(h.id);

        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: GestureDetector(
            onTap: () => setState(() {
              if (!_selected.remove(h.id)) _selected.add(h.id);
            }),
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsetsDirectional.fromSTEB(6, 8, 14, 8),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.modIdCards.withValues(alpha: 0.08)
                    : p.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: selected
                      ? AppColors.modIdCards.withValues(alpha: 0.4)
                      : p.line,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    value: selected,
                    onChanged: (_) => setState(() {
                      if (!_selected.remove(h.id)) _selected.add(h.id);
                    }),
                    visualDensity: VisualDensity.compact,
                  ),
                  AvatarCell(
                    name: h.fullName,
                    photoPath: h.photoPath,
                    color: switch (widget.audience) {
                      'teacher' => AppColors.modTeachers,
                      'staff' => AppColors.modStaff,
                      _ => AppColors.modStudents,
                    },
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    flex: 3,
                    child: Text(
                      h.fullName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      locale.num(h.idNo),
                      style: AppTheme.tabular(
                        TextStyle(fontSize: 12, color: p.muted),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      h.subtitle.isEmpty ? '—' : h.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: p.inkSoft),
                    ),
                  ),
                  if (!h.hasKey)
                    const Padding(
                      padding: EdgeInsetsDirectional.only(end: 8),
                      child: Tooltip(
                        message: 'پټ کلید نشته — QR به کار ونه کړي',
                        child: Icon(
                          Icons.key_off_rounded,
                          size: 15,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: 128,
                    child: Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: _StatePill(state: state, expiresOn: h.expiresOn),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════

/// د کارت د حال نښه — د لیست او د شبکې دواړو لپاره.
class _StatePill extends StatelessWidget {
  final String state;
  final DateTime? expiresOn;

  const _StatePill({required this.state, this.expiresOn});

  static ({String label, Color color, IconData icon}) styleOf(String state) =>
      switch (state) {
        'valid' => (
          label: 'روان',
          color: AppColors.success,
          icon: Icons.verified_rounded,
        ),
        'soon' => (
          label: 'نژدې پای',
          color: AppColors.warning,
          icon: Icons.timelapse_rounded,
        ),
        'expired' => (
          label: 'باطل',
          color: AppColors.danger,
          icon: Icons.event_busy_rounded,
        ),
        _ => (
          label: 'کارت نه لري',
          color: AppColors.modSettings,
          icon: Icons.credit_card_off_rounded,
        ),
      };

  @override
  Widget build(BuildContext context) {
    final st = styleOf(state);

    return Tooltip(
      message: expiresOn == null
          ? 'لا نه دی چاپ شوی'
          : 'تر ${context.cal.short(expiresOn!)} پورې',
      child: Pill(color: st.color, icon: st.icon, text: st.label),
    );
  }
}

/// یو کارت چې ټاکل کېږي — د حال نښه يې پر سر ده.
class _Selectable extends StatelessWidget {
  final bool selected;
  final String state;
  final VoidCallback onTap;
  final Widget child;

  const _Selectable({
    required this.selected,
    required this.state,
    required this.onTap,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final st = _StatePill.styleOf(state);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radius),
            border: Border.all(
              color: selected ? AppColors.modIdCards : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              child,
              const SizedBox(height: 7),
              // **`min` — که نه، کرښه به ټوله پلنوالی نیوله** او
              // هر کارت به یو بشپړ کتار خوړلی و.
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedOpacity(
                    duration: AppMotion.fast,
                    opacity: selected ? 1 : 0.35,
                    child: Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color: selected
                          ? AppColors.modIdCards
                          : context.palette.faint,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Pill(color: st.color, icon: st.icon, text: st.label),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TemplateChip extends StatelessWidget {
  final CardTemplate template;
  final bool active;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const _TemplateChip({
    required this.template,
    required this.active,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final layout = CardLayout.decode(template.layoutJson);

    return GestureDetector(
      onTap: onTap,
      onDoubleTap: onEdit,
      child: Tooltip(
        message: '${template.name} — دوه ځله کلیک يې سموي',
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: active
                ? AppColors.modIdCards.withValues(alpha: 0.1)
                : p.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: active ? AppColors.modIdCards : p.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: Color(layout.bandColor),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                template.name,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? AppColors.modIdCards : p.inkSoft,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
