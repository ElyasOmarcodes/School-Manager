import 'package:flutter/material.dart';

import '../data/afghanistan.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';

/// یوه لیکنې خانه چې د لیکلو پر مهال وړاندیزونه ښیي.
///
/// **دا ولې د `DropdownButton` پر ځای؟** ځکه چې ۳۴ ولایتونه او د یوه
/// ولایت تر ۳۰ پورې ولسوالۍ په یوه اوږده لیسټ کې لټول له لیکلو ډېر
/// وخت نیسي. کارن «مرغ» لیکي او «بالا مرغاب» راځي — درې توري د
/// دېرشو ځله ښکته-پورته کولو ځای نیسي.
///
/// **او ولې آزاده لیکنه هم منل کېږي؟** ځکه چې د افغانستان د
/// ولسوالیو نومونه په املا کې توپیر لري، او ځینې نوې ولسوالۍ جوړې
/// شوې دي. یو تړلی لیسټ به کارن مجبور کړ چې غلط ځای وټاکي.
class TypeAheadField extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;
  final IconData? icon;
  final bool enabled;
  final String? hint;

  /// که تش وي، `null` راګرځوي — نه خالي متن. د ډیټابیس لپاره توپیر لري.
  const TypeAheadField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.enabled = true,
    this.hint,
  });

  @override
  State<TypeAheadField> createState() => _TypeAheadFieldState();
}

class _TypeAheadFieldState extends State<TypeAheadField> {
  late final TextEditingController _c = TextEditingController(
    text: widget.value ?? '',
  );
  final _focus = FocusNode();
  final _link = LayerLink();
  OverlayEntry? _overlay;
  List<String> _matches = const [];

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (_focus.hasFocus) {
        _refresh(_c.text);
      } else {
        // د تمرکز له وتلو سره پټېږي — خو یوه شېبه وروسته، چې د
        // وړاندیز پر مخ کېکاږل ونه لوېږي.
        Future.delayed(AppMotion.fast, _hide);
        widget.onChanged(_c.text.trim().isEmpty ? null : _c.text.trim());
      }
    });
  }

  @override
  void didUpdateWidget(TypeAheadField old) {
    super.didUpdateWidget(old);
    if (widget.value != old.value && widget.value != _c.text) {
      _c.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _hide();
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _refresh(String q) {
    _matches = suggestFrom(widget.options, q);
    if (_matches.isEmpty) {
      _hide();
    } else {
      _show();
      _overlay?.markNeedsBuild();
    }
  }

  void _show() {
    if (_overlay != null) return;
    final box = context.findRenderObject() as RenderBox?;
    final width = box?.size.width ?? 260;

    _overlay = OverlayEntry(
      builder: (ctx) {
        final p = ctx.palette;
        return Positioned(
          width: width,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            offset: const Offset(0, 54),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(10),
              color: p.surface,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 232),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  children: [
                    for (final m in _matches)
                      InkWell(
                        onTap: () {
                          _c.text = m;
                          widget.onChanged(m);
                          _hide();
                          _focus.unfocus();
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          child: Text(
                            m,
                            style: TextStyle(fontSize: 13, color: p.ink),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context).insert(_overlay!);
  }

  void _hide() {
    _overlay?.remove();
    _overlay = null;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: TextField(
        controller: _c,
        focusNode: _focus,
        enabled: widget.enabled,
        onChanged: _refresh,
        decoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hint,
          isDense: true,
          prefixIcon: widget.icon == null ? null : Icon(widget.icon, size: 17),
          suffixIcon: (_c.text.isEmpty || !widget.enabled)
              ? null
              : IconButton(
                  icon: const Icon(Icons.close_rounded, size: 15),
                  onPressed: () {
                    _c.clear();
                    widget.onChanged(null);
                    _hide();
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }
}
