import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/widgets/panel.dart';
import '../../data/db/database.dart';
import '../../data/repositories/card_repository.dart';
import 'card_canvas.dart';
import 'card_layout.dart';

/// **د کارت ډیزاینر.**
///
/// **ولې یو بشپړ ډیزاینر او نه څو ټاکنې؟** ځکه چې هر ښوونځی خپله
/// بڼه غواړي — یو لوګو مخکې غواړي، بل نوم؛ یو د حفظ درجه ښیي، بل
/// د والدینو تلیفون. یو ثابت ډیزاین به هر ښوونځی نوې نسخې ته اړ
/// کړ. نو **ځای، اندازه، رنګ، فونټ او ښکارېدل ټول آزاد دي** — خو
/// ساحې پېژندل شوې دي، نو هره یوه یو ریښتیني ارزښت ته تړلې پاتې
/// کېږي.
class CardDesignerPage extends StatefulWidget {
  final CardRepository cards;
  final String audience;
  final String schoolName;

  /// کومه کینډۍ سمېږي — `null` یعنې نوې له تلوالې څخه.
  final CardTemplate? template;

  final VoidCallback? onBack;
  final VoidCallback? onSaved;
  final bool canEdit;

  const CardDesignerPage({
    super.key,
    required this.cards,
    required this.audience,
    required this.schoolName,
    this.template,
    this.onBack,
    this.onSaved,
    this.canEdit = true,
  });

  @override
  State<CardDesignerPage> createState() => _CardDesignerPageState();
}

class _CardDesignerPageState extends State<CardDesignerPage> {
  late CardLayout _layout;
  late final TextEditingController _name;
  late double _widthMm;
  late double _heightMm;
  int? _selected;
  bool _saving = false;

  /// **د انډو ډېران** — هر بدلون یو بشپړ ډیزاین ساتي.
  final List<CardLayout> _undo = [];
  final List<CardLayout> _redo = [];

  @override
  void initState() {
    super.initState();
    final t = widget.template;
    final fallback = builtInTemplates(widget.audience).first;
    _layout = t == null ? fallback.layout : CardLayout.decode(t.layoutJson);
    _name = TextEditingController(text: t?.name ?? fallback.name);
    _widthMm = t?.widthMm ?? cr80WidthMm;
    _heightMm = t?.heightMm ?? cr80HeightMm;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  double get _aspect => _widthMm / _heightMm;

  void _mutate(CardLayout next) {
    setState(() {
      _undo.add(_layout);
      if (_undo.length > 40) _undo.removeAt(0);
      _redo.clear();
      _layout = next;
    });
  }

  void _updateField(int index, CardField f) {
    final fields = [..._layout.fields];
    fields[index] = f;
    _mutate(_layout.copyWith(fields: fields));
  }

  void _addField(CardFieldKind kind) {
    _mutate(
      _layout.copyWith(
        fields: [
          ..._layout.fields,
          CardField(
            kind: kind,
            x: 0.35,
            y: 0.45,
            // متن تر کیڼې څنډې پورې غځېږي؛ بکس خپله اندازه لري.
            w: kind.isBox ? 0.18 : 0,
            h: kind.isBox ? 0.3 : 0,
            text: kind == CardFieldKind.text ? 'نوی متن' : null,
          ),
        ],
      ),
    );
    setState(() => _selected = _layout.fields.length - 1);
  }

  void _removeField(int index) {
    final fields = [..._layout.fields]..removeAt(index);
    _mutate(_layout.copyWith(fields: fields));
    setState(() => _selected = null);
  }

  void _applyTemplate(BuiltInTemplate t) {
    _mutate(t.layout);
    setState(() {
      _selected = null;
      _name.text = t.name;
    });
  }

  Future<void> _save({bool activate = false}) async {
    setState(() => _saving = true);
    await widget.cards.saveTemplate(
      id: widget.template?.id,
      name: _name.text.trim().isEmpty ? 'بې‌نومه' : _name.text.trim(),
      audience: widget.audience,
      layoutJson: _layout.encode(),
      widthMm: _widthMm,
      heightMm: _heightMm,
      orientation: _widthMm >= _heightMm ? 'landscape' : 'portrait',
      activate: activate,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    widget.onSaved?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 480,
        backgroundColor: AppColors.success,
        content: Text(
          activate
              ? 'ډیزاین وساتل شو او اوس کارېږي.'
              : 'ډیزاین وساتل شو.',
        ),
      ),
    );
  }

  /// نمونه ارزښتونه — د مخکتنې لپاره، نه د یوه ریښتیني کس.
  CardValues get _sample => CardValues(
    schoolName: widget.schoolName,
    fullName: switch (widget.audience) {
      'teacher' => 'استاد محمد نعیم',
      'staff' => 'عبدالغفار محاسب',
      _ => 'احمد ولي کریمي',
    },
    fatherName: 'عبدالرحمن',
    idNo: switch (widget.audience) {
      'teacher' => 'T-0001',
      'staff' => 'S-0001',
      _ => '1405-0042',
    },
    className: 'لسم — الف',
    jobTitle: switch (widget.audience) {
      'teacher' => 'د ریاضي استاد',
      'staff' => 'محاسب',
      _ => '',
    },
    yearLabel: '1405',
    phone: '0700123456',
    expiresOn: DateTime(2026, 12, 21),
    qrPayload: 'SM1.1405-0042.1.preview',
  );

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Column(
      children: [
        _Toolbar(
          name: _name,
          saving: _saving,
          canEdit: widget.canEdit,
          canUndo: _undo.isNotEmpty,
          canRedo: _redo.isNotEmpty,
          onBack: widget.onBack,
          onUndo: _undo.isEmpty
              ? null
              : () => setState(() {
                  _redo.add(_layout);
                  _layout = _undo.removeLast();
                  _selected = null;
                }),
          onRedo: _redo.isEmpty
              ? null
              : () => setState(() {
                  _undo.add(_layout);
                  _layout = _redo.removeLast();
                  _selected = null;
                }),
          onSave: () => _save(),
          onSaveAndUse: () => _save(activate: true),
        ),
        Divider(height: 1, color: p.line),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── کیڼ: ساحې او کینډۍ ───────────────────────
              SizedBox(
                width: 258,
                child: _LeftPanel(
                  layout: _layout,
                  audience: widget.audience,
                  selected: _selected,
                  canEdit: widget.canEdit,
                  onSelect: (i) => setState(() => _selected = i),
                  onToggle: (i) => _updateField(
                    i,
                    _layout.fields[i].copyWith(
                      visible: !_layout.fields[i].visible,
                    ),
                  ),
                  onRemove: _removeField,
                  onAdd: _addField,
                  onTemplate: _applyTemplate,
                ),
              ),
              VerticalDivider(width: 1, color: p.line),

              // ── منځ: تخته ────────────────────────────────
              Expanded(
                child: Container(
                  color: p.surfaceAlt,
                  child: Center(
                    child: _Board(
                      layout: _layout,
                      values: _sample,
                      locale: s.locale,
                      aspect: _aspect,
                      selected: _selected,
                      canEdit: widget.canEdit,
                      onSelect: (i) => setState(() => _selected = i),
                      onMove: (i, dx, dy) {
                        final f = _layout.fields[i];
                        _updateField(
                          i,
                          f.copyWith(
                            x: (f.x + dx).clamp(0.0, 0.95),
                            y: (f.y + dy).clamp(0.0, 0.95),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              VerticalDivider(width: 1, color: p.line),

              // ── ښي: ځانګړتیاوې ───────────────────────────
              SizedBox(
                width: 272,
                child: _RightPanel(
                  layout: _layout,
                  selected: _selected,
                  widthMm: _widthMm,
                  heightMm: _heightMm,
                  canEdit: widget.canEdit,
                  onLayout: _mutate,
                  onField: _updateField,
                  onSize: (w, h) => setState(() {
                    _widthMm = w;
                    _heightMm = h;
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════

class _Toolbar extends StatelessWidget {
  final TextEditingController name;
  final bool saving;
  final bool canEdit;
  final bool canUndo;
  final bool canRedo;
  final VoidCallback? onBack;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback onSave;
  final VoidCallback onSaveAndUse;

  const _Toolbar({
    required this.name,
    required this.saving,
    required this.canEdit,
    required this.canUndo,
    required this.canRedo,
    required this.onSave,
    required this.onSaveAndUse,
    this.onBack,
    this.onUndo,
    this.onRedo,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 20, 12),
      color: p.surface,
      child: Row(
        children: [
          if (onBack != null)
            IconButton(
              tooltip: 'بېرته',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_forward_rounded, size: 19),
            ),
          SizedBox(
            width: 236,
            child: TextField(
              controller: name,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'د ډیزاین نوم',
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 14),
          IconButton(
            tooltip: 'بېرته (انډو)',
            onPressed: onUndo,
            icon: Icon(
              Icons.undo_rounded,
              size: 19,
              color: canUndo ? p.inkSoft : p.faint,
            ),
          ),
          IconButton(
            tooltip: 'بیا (ریډو)',
            onPressed: onRedo,
            icon: Icon(
              Icons.redo_rounded,
              size: 19,
              color: canRedo ? p.inkSoft : p.faint,
            ),
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: saving || !canEdit ? null : onSave,
            style: OutlinedButton.styleFrom(minimumSize: const Size(0, 42)),
            child: Text(s.save),
          ),
          const SizedBox(width: 10),
          FilledButton.icon(
            onPressed: saving || !canEdit ? null : onSaveAndUse,
            icon: const Icon(Icons.check_circle_rounded, size: 17),
            label: const Text('وساته او وکاروه'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.modIdCards,
              minimumSize: const Size(0, 42),
            ),
          ),
        ],
      ),
    );
  }
}

/// د ساحو لیست او د کینډیو ټاکنه.
class _LeftPanel extends StatelessWidget {
  final CardLayout layout;
  final String audience;
  final int? selected;
  final bool canEdit;
  final ValueChanged<int> onSelect;
  final ValueChanged<int> onToggle;
  final ValueChanged<int> onRemove;
  final ValueChanged<CardFieldKind> onAdd;
  final ValueChanged<BuiltInTemplate> onTemplate;

  const _LeftPanel({
    required this.layout,
    required this.audience,
    required this.selected,
    required this.canEdit,
    required this.onSelect,
    required this.onToggle,
    required this.onRemove,
    required this.onAdd,
    required this.onTemplate,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final templates = builtInTemplates(audience);

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        const _Head(text: 'کینډۍ'),
        for (final t in templates)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OutlinedButton.icon(
              onPressed: canEdit ? () => onTemplate(t) : null,
              icon: Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(
                  color: Color(t.layout.bandColor),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              label: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(t.name),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 40),
                alignment: AlignmentDirectional.centerStart,
              ),
            ),
          ),

        const SizedBox(height: 18),
        const _Head(text: 'ساحې'),
        for (var i = 0; i < layout.fields.length; i++)
          _FieldRow(
            field: layout.fields[i],
            selected: selected == i,
            canEdit: canEdit,
            onTap: () => onSelect(i),
            onToggle: () => onToggle(i),
            onRemove: () => onRemove(i),
          ),

        const SizedBox(height: 12),
        PopupMenuButton<CardFieldKind>(
          enabled: canEdit,
          tooltip: '',
          onSelected: onAdd,
          itemBuilder: (_) => [
            for (final k in CardFieldKind.values)
              PopupMenuItem(
                value: k,
                child: Row(
                  children: [
                    Icon(k.icon, size: 16, color: p.muted),
                    const SizedBox(width: 10),
                    Text(k.label),
                  ],
                ),
              ),
          ],
          child: Container(
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.modIdCards.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppColors.modIdCards.withValues(alpha: 0.35),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 17, color: AppColors.modIdCards),
                SizedBox(width: 8),
                Text(
                  'ساحه زیاته کړه',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.modIdCards,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Head extends StatelessWidget {
  final String text;
  const _Head({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 11.5,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
        color: context.palette.faint,
      ),
    ),
  );
}

class _FieldRow extends StatelessWidget {
  final CardField field;
  final bool selected;
  final bool canEdit;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onRemove;

  const _FieldRow({
    required this.field,
    required this.selected,
    required this.canEdit,
    required this.onTap,
    required this.onToggle,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsetsDirectional.fromSTEB(10, 4, 4, 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modIdCards.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Row(
          children: [
            Icon(
              field.kind.icon,
              size: 15,
              color: field.visible ? p.inkSoft : p.faint,
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                field.kind == CardFieldKind.text
                    ? (field.text ?? field.kind.label)
                    : field.kind.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: field.visible ? p.ink : p.faint,
                ),
              ),
            ),
            IconButton(
              tooltip: field.visible ? 'پټ کړه' : 'ښکاره کړه',
              onPressed: canEdit ? onToggle : null,
              visualDensity: VisualDensity.compact,
              icon: Icon(
                field.visible
                    ? Icons.visibility_rounded
                    : Icons.visibility_off_rounded,
                size: 15,
                color: p.muted,
              ),
            ),
            IconButton(
              tooltip: 'لرې کړه',
              onPressed: canEdit ? onRemove : null,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.close_rounded,
                size: 15,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// **د ډیزاین تخته** — ساحې د موږک په کش کولو خوځېږي.
class _Board extends StatelessWidget {
  final CardLayout layout;
  final CardValues values;
  final AppLocale locale;
  final double aspect;
  final int? selected;
  final bool canEdit;
  final ValueChanged<int> onSelect;
  final void Function(int index, double dx, double dy) onMove;

  const _Board({
    required this.layout,
    required this.values,
    required this.locale,
    required this.aspect,
    required this.selected,
    required this.canEdit,
    required this.onSelect,
    required this.onMove,
  });

  @override
  Widget build(BuildContext context) {
    const w = 520.0;
    final h = w / aspect;

    return SizedBox(
      width: w,
      height: h,
      child: Stack(
        children: [
          CardCanvas(
            layout: layout,
            values: values,
            locale: locale,
            width: w,
            aspect: aspect,
            selectedIndex: selected,
            showGuides: true,
          ),
          // **د نیولو ساحې پر کارت باندې دي، نه دننه.** که د کش
          // کولو منطق د `CardCanvas` دننه و، چاپ او لیست به هم هغه
          // وړی و — او یو کارت به په لیست کې خوځېدلی و.
          for (var i = 0; i < layout.fields.length; i++)
            if (layout.fields[i].visible)
              _Handle(
                field: layout.fields[i],
                cardWidth: w,
                cardHeight: h,
                selected: selected == i,
                enabled: canEdit,
                onTap: () => onSelect(i),
                onDrag: (dx, dy) {
                  onSelect(i);
                  onMove(i, -dx / w, dy / h);
                },
              ),
        ],
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  final CardField field;
  final double cardWidth;
  final double cardHeight;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final void Function(double dx, double dy) onDrag;

  const _Handle({
    required this.field,
    required this.cardWidth,
    required this.cardHeight,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.onDrag,
  });

  @override
  Widget build(BuildContext context) {
    final w = fieldWidth(field, cardWidth);
    final h = field.kind.isBox
        ? fieldHeight(field, cardHeight)
        : field.fontScale * cardHeight * 1.4;

    return Positioned(
      right: field.x * cardWidth,
      top: field.y * cardHeight,
      width: w,
      height: h,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.move : MouseCursor.defer,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          onPanUpdate: enabled
              ? (d) => onDrag(d.delta.dx, d.delta.dy)
              : null,
          child: selected
              ? DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.modIdCards, width: 2),
                  ),
                )
              : const SizedBox.expand(),
        ),
      ),
    );
  }
}

/// د ټاکل شوې ساحې ځانګړتیاوې، او د کارت اندازه.
class _RightPanel extends StatelessWidget {
  final CardLayout layout;
  final int? selected;
  final double widthMm;
  final double heightMm;
  final bool canEdit;
  final ValueChanged<CardLayout> onLayout;
  final void Function(int index, CardField f) onField;
  final void Function(double w, double h) onSize;

  const _RightPanel({
    required this.layout,
    required this.selected,
    required this.widthMm,
    required this.heightMm,
    required this.canEdit,
    required this.onLayout,
    required this.onField,
    required this.onSize,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    final i = selected;
    final f = i == null || i >= layout.fields.length ? null : layout.fields[i];

    final print = printSize(widthMm: widthMm, heightMm: heightMm);
    final clamped =
        (print.width - widthMm).abs() > 0.05 ||
        (print.height - heightMm).abs() > 0.05;

    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
      children: [
        const _Head(text: 'د کارت اندازه'),
        Row(
          children: [
            Expanded(
              child: _Num(
                label: 'پلنوالی mm',
                value: widthMm,
                enabled: canEdit,
                onChanged: (v) => onSize(v, heightMm),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _Num(
                label: 'لوړوالی mm',
                value: heightMm,
                enabled: canEdit,
                onChanged: (v) => onSize(widthMm, v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final preset in const [
              ('CR80', cr80WidthMm, cr80HeightMm),
              ('عمودي', cr80HeightMm, cr80WidthMm),
              ('لوی', 105.0, 74.0),
            ])
              OutlinedButton(
                onPressed: canEdit
                    ? () => onSize(preset.$2, preset.$3)
                    : null,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 11),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 11.5,
                  ),
                ),
                child: Text(preset.$1),
              ),
          ],
        ),

        // **د چاپ تضمین** — که اندازه له معیار کوچنۍ وي، چاپ يې
        // پورته کوي. دا دلته ویل کېږي، نه یوازې په کوډ کې پلې
        // کېږي، چې ډیزاینر حیران نه شي چې ولې چاپ لوی راووت.
        if (clamped) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.info,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'دا له معیاري کارت (CR80) کوچنی دی. د چاپ پر مهال '
                    'به ${locale.num(print.width.toStringAsFixed(1))} × '
                    '${locale.num(print.height.toStringAsFixed(1))}mm '
                    'شي — نسبت يې نه ماتېږي.',
                    style: TextStyle(
                      fontSize: 11.5,
                      height: 1.6,
                      color: p.inkSoft,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        const _Head(text: 'شالید'),
        _ColorRow(
          label: 'د کارت رنګ',
          value: layout.background,
          enabled: canEdit,
          onChanged: (c) => onLayout(layout.copyWith(background: c)),
        ),
        _ColorRow(
          label: 'د کرښې رنګ',
          value: layout.bandColor,
          enabled: canEdit,
          onChanged: (c) => onLayout(layout.copyWith(bandColor: c)),
        ),
        _Slider(
          label: 'د کرښې لوړوالی',
          value: layout.bandHeight,
          max: 0.5,
          enabled: canEdit,
          onChanged: (v) => onLayout(layout.copyWith(bandHeight: v)),
        ),
        _Slider(
          label: 'د څنډو ګردوالی',
          value: layout.cornerRadius,
          max: 0.2,
          enabled: canEdit,
          onChanged: (v) => onLayout(layout.copyWith(cornerRadius: v)),
        ),

        const SizedBox(height: 20),
        const _Head(text: 'ټاکل شوې ساحه'),
        if (f == null || i == null)
          Text(
            'یوه ساحه وټاکئ — یا پر کارت باندې يې کلیک کړئ، یا له '
            'کیڼ لیسته.',
            style: TextStyle(fontSize: 12, height: 1.7, color: p.muted),
          )
        else ...[
          Row(
            children: [
              Icon(f.kind.icon, size: 16, color: AppColors.modIdCards),
              const SizedBox(width: 8),
              Text(
                f.kind.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (f.kind == CardFieldKind.text)
            TextFormField(
              key: ValueKey('text-$i'),
              initialValue: f.text,
              enabled: canEdit,
              decoration: const InputDecoration(
                labelText: 'متن',
                isDense: true,
              ),
              onChanged: (v) => onField(i, f.copyWith(text: v)),
            ),
          _Slider(
            label: 'له ښي',
            value: f.x,
            max: 0.95,
            enabled: canEdit,
            onChanged: (v) => onField(i, f.copyWith(x: v)),
          ),
          _Slider(
            label: 'له پاسه',
            value: f.y,
            max: 0.95,
            enabled: canEdit,
            onChanged: (v) => onField(i, f.copyWith(y: v)),
          ),
          if (f.kind.isBox) ...[
            _Slider(
              label: 'پلنوالی',
              value: f.w,
              max: 1.0,
              enabled: canEdit,
              onChanged: (v) => onField(i, f.copyWith(w: v)),
            ),
            _Slider(
              label: 'لوړوالی',
              value: f.h,
              max: 1.0,
              enabled: canEdit,
              onChanged: (v) => onField(i, f.copyWith(h: v)),
            ),
          ] else ...[
            _Slider(
              label: 'د متن اندازه',
              value: f.fontScale,
              max: 0.25,
              enabled: canEdit,
              onChanged: (v) => onField(i, f.copyWith(fontScale: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: f.bold,
              onChanged: canEdit
                  ? (v) => onField(i, f.copyWith(bold: v))
                  : null,
              title: const Text('ډبل', style: TextStyle(fontSize: 12.5)),
            ),
            SegmentedChoice<String>(
              value: f.align,
              options: const [
                (value: 'start', label: 'ښي', icon: null),
                (value: 'center', label: 'منځ', icon: null),
                (value: 'end', label: 'کيڼ', icon: null),
              ],
              onChanged: (v) => onField(i, f.copyWith(align: v)),
            ),
          ],
          const SizedBox(height: 10),
          _ColorRow(
            label: 'رنګ',
            value: f.color,
            enabled: canEdit,
            onChanged: (c) => onField(i, f.copyWith(color: c)),
          ),
        ],
      ],
    );
  }
}

class _Num extends StatelessWidget {
  final String label;
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _Num({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey('$label-$value'),
      initialValue: value.toStringAsFixed(1),
      enabled: enabled,
      textDirection: TextDirection.ltr,
      decoration: InputDecoration(labelText: label, isDense: true),
      onFieldSubmitted: (v) {
        final n = double.tryParse(Numerals.toLatin(v));
        // صفر یا منفي اندازه یو کارت نه دی — نو رد کېږي، خو تېروتنه
        // نه ښیي: کارن يې پخپله ویني چې بدلون ونه شو.
        if (n != null && n > 0) onChanged(n);
      },
    );
  }
}

class _Slider extends StatelessWidget {
  final String label;
  final double value;
  final double max;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const _Slider({
    required this.label,
    required this.value,
    required this.max,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(label, style: TextStyle(fontSize: 11.5, color: p.muted)),
              const Spacer(),
              Text(
                locale.num((value * 100).round()),
                style: AppTheme.tabular(
                  TextStyle(fontSize: 11, color: p.faint),
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: SliderComponentShape.noOverlay,
            ),
            child: Slider(
              value: value.clamp(0.0, max),
              max: max,
              activeColor: AppColors.modIdCards,
              onChanged: enabled ? onChanged : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorRow extends StatelessWidget {
  final String label;
  final int value;
  final bool enabled;
  final ValueChanged<int> onChanged;

  /// یوه کوچنۍ پالېټ — یو بشپړ رنګ‌ټاکونکی دلته زیات دی، او د
  /// ښوونځي کارت هېڅکله ۱۶ میلیونه رنګه نه غواړي.
  static const List<int> _swatches = [
    0xFFFFFFFF,
    0xFFF8FAFC,
    0xFF1B1F2A,
    0xFF15202B,
    0xFF4C5FD5,
    0xFF0284C7,
    0xFF0E9F6E,
    0xFFD97706,
    0xFFDC2626,
    0xFF7C3AED,
    0xFF667085,
    0xFF98A2B3,
  ];

  const _ColorRow({
    required this.label,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, color: p.muted)),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in _swatches)
                GestureDetector(
                  onTap: enabled ? () => onChanged(c) : null,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color(c),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: c == value ? AppColors.modIdCards : p.line,
                        width: c == value ? 2.4 : 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
