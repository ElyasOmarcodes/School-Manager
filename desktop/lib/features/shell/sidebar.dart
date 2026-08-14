import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import 'nav_items.dart';

/// د ټولېدو وړ رنګین سایډبار.
///
/// دوه حالته: پراخ (۲۵۶px) او ټول شوی (۷۶px، یوازې نښې).
/// فعال توکی د روانې نښې (sliding indicator) په انیمیشن سره ځي —
/// چې سترګه ورپسې لار ومومي، نه چې ناڅاپه ټوپ وکړي.
class Sidebar extends StatelessWidget {
  final String currentRoute;
  final String role;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onNavigate;
  final String schoolName;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.role,
    required this.expanded,
    required this.onToggle,
    required this.onNavigate,
    required this.schoolName,
  });

  static const double widthExpanded = 256;
  static const double widthCollapsed = 76;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final groups = buildNav();

    return AnimatedContainer(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      width: expanded ? widthExpanded : widthCollapsed,
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(
          // RTL کې دا د ښي خوا کرښه ده — Flutter پخپله اړوي.
          left: BorderSide(color: p.line),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Brand(expanded: expanded, schoolName: schoolName),
          Divider(height: 1, color: p.line),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                for (final g in groups) ...[
                  if (g.title(s).isNotEmpty)
                    _GroupLabel(text: g.title(s), expanded: expanded),
                  for (final item in g.items)
                    if (item.visibleTo(role))
                      _NavTile(
                        item: item,
                        active: currentRoute == item.route,
                        expanded: expanded,
                        onTap: () => onNavigate(item.route),
                      ),
                  const SizedBox(height: 6),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: p.line),
          _CollapseButton(expanded: expanded, onToggle: onToggle),
        ],
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  final bool expanded;
  final String schoolName;
  const _Brand({required this.expanded, required this.schoolName});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: AppColors.gradIndigo,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: Colors.white, size: 21),
          ),
          if (expanded) ...[
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    schoolName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  Text(
                    S.of(context).appName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: p.faint),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  final bool expanded;
  const _GroupLabel({required this.text, required this.expanded});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AnimatedSwitcher(
      duration: AppMotion.fast,
      child: expanded
          ? Padding(
              key: const ValueKey('label'),
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 7),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: p.faint,
                ),
              ),
            )
          : Padding(
              key: const ValueKey('rule'),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
              child: Container(height: 1, color: p.line),
            ),
    );
  }
}

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;

  const _NavTile({
    required this.item,
    required this.active,
    required this.expanded,
    required this.onTap,
  });

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final c = widget.item.color;
    final active = widget.active;

    final tile = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            // فعال توکی د خپل ماډل په رنګ کې نرم شالید اخلي.
            color: active
                ? c.withValues(alpha: 0.12)
                : _hover
                    ? p.surfaceAlt
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: widget.expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              // رنګینه نښه — دا هغه څه دي چې ډاشبورډ ژوندی ښکاري.
              AnimatedContainer(
                duration: AppMotion.fast,
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: active ? c : c.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.item.icon,
                  size: 17,
                  color: active ? Colors.white : c,
                ),
              ),
              if (widget.expanded) ...[
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    widget.item.label(s),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? c : p.inkSoft,
                    ),
                  ),
                ),
                // د فعال توکي وړه نښه په څنډه کې.
                AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: active ? 1 : 0,
                  child: Container(
                    width: 3,
                    height: 18,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    // ټول شوي حالت کې نوم یوازې په tooltip کې ښکاري.
    return widget.expanded
        ? tile
        : Tooltip(message: widget.item.label(s), child: tile);
  }
}

class _CollapseButton extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  const _CollapseButton({required this.expanded, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              turns: expanded ? 0 : 0.5,
              child:
                  Icon(Icons.chevron_right_rounded, size: 20, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}
