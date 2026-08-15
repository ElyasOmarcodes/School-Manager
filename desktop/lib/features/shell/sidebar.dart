import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/theme/app_motion.dart';
import 'nav_items.dart';

/// د ټولېدو وړ رنګین سایډبار.
///
/// دوه حالته: پراخ (۲۵۶px) او ټول شوی (۷۶px، یوازې نښې).
/// فعال توکی د روانې نښې (sliding indicator) په انیمیشن سره ځي —
/// چې سترګه ورپسې لار ومومي، نه چې ناڅاپه ټوپ وکړي.
class Sidebar extends StatelessWidget {
  final String currentRoute;
  final Permissions permissions;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<String> onNavigate;
  final String schoolName;

  const Sidebar({
    super.key,
    required this.currentRoute,
    required this.permissions,
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
              padding: const EdgeInsets.symmetric(vertical: 6),
              children: [
                for (final g in groups) ...[
                  if (g.title(s).isNotEmpty)
                    _GroupLabel(text: g.title(s), expanded: expanded),
                  for (final item in g.items)
                    if (item.visibleTo(permissions))
                      _NavBranch(
                        item: item,
                        currentRoute: currentRoute,
                        expanded: expanded,
                        onNavigate: onNavigate,
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
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
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
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 21,
            ),
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
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
              padding: const EdgeInsets.fromLTRB(22, 9, 22, 9),
              child: Container(height: 1, color: p.line),
            ),
    );
  }
}

/// یو توکی له خپلو فرعي توکو سره.
///
/// **د پرانیستلو انیمیشن ولې دومره مهم دی؟** ځکه چې فرعي لیست د
/// لاندې توکي ځای نیسي — که ناڅاپه ښکاره شي، سترګه به هغه توکي ورک
/// کړ چې لټاوه يې. `AnimatedSize` لاندېني توکي په نرمۍ سره ښکته
/// ښویوي، نو د حرکت لار څرګنده وي.
class _NavBranch extends StatefulWidget {
  final NavItem item;
  final String currentRoute;
  final bool expanded;
  final ValueChanged<String> onNavigate;

  const _NavBranch({
    required this.item,
    required this.currentRoute,
    required this.expanded,
    required this.onNavigate,
  });

  @override
  State<_NavBranch> createState() => _NavBranchState();
}

class _NavBranchState extends State<_NavBranch> {
  /// په لاس پرانیستل — د اوسنۍ لارې خودکار پرانیستل ترې جلا دي.
  bool _open = false;

  bool get _ownsRoute => widget.item.owns(widget.currentRoute);

  /// فرعي لیست هغه وخت ښکاري چې یا کارن پرانیستی وي، یا اوسنۍ
  /// لار د همدې څانګې وي — نو د بلې پاڼې څخه راستنېدل يې نه بندوي.
  bool get _showChildren =>
      widget.expanded && widget.item.hasChildren && (_open || _ownsRoute);

  @override
  void didUpdateWidget(_NavBranch old) {
    super.didUpdateWidget(old);
    // بله څانګه چې فعاله شي، دا پخپله بندېږي — چې سایډبار اوږد نه شي.
    if (!_ownsRoute && _open) _open = false;
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.item.children;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavTile(
          item: widget.item,
          active: _ownsRoute,
          expanded: widget.expanded,
          showChevron: widget.item.hasChildren && widget.expanded,
          chevronOpen: _showChildren,
          onTap: () {
            if (widget.item.hasChildren && widget.expanded) {
              setState(() => _open = !_ownsRoute || !_open);
              // پر مور توکي کېکاږل لومړي فرعي توکي ته هم بیایي —
              // که نه، کارن به دوه ځله کېکاږلو ته اړ و.
              if (!_ownsRoute) widget.onNavigate(children.first.route);
              return;
            }
            widget.onNavigate(widget.item.route);
          },
        ),
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: _showChildren
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final c in children)
                      _SubTile(
                        sub: c,
                        color: widget.item.color,
                        active: widget.currentRoute == c.route,
                        onTap: () => widget.onNavigate(c.route),
                      ),
                    const SizedBox(height: 3),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// یو فرعي توکی — **له مور توکي کوچنی**، چې کچه يې په یوه نظر معلومه شي.
class _SubTile extends StatefulWidget {
  final NavSubItem sub;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _SubTile({
    required this.sub,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  State<_SubTile> createState() => _SubTileState();
}

class _SubTileState extends State<_SubTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final c = widget.color;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          // د ښي خوا زیات فاصله (RTL کې) — چې د مور توکي لاندې
          // ښکاره ښکاري، نه د هغه په څنګ کې.
          margin: const EdgeInsetsDirectional.fromSTEB(10, 1, 26, 1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: widget.active
                ? c.withValues(alpha: 0.10)
                : _hover
                ? p.surfaceAlt
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // د څانګې کرښه — د بصري تړاو لپاره.
              Container(
                width: 2,
                height: 16,
                margin: const EdgeInsetsDirectional.only(end: 9),
                decoration: BoxDecoration(
                  color: widget.active ? c : p.line,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              Icon(
                widget.sub.icon,
                size: 14,
                color: widget.active ? c : p.muted,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.sub.label(s),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: widget.active
                        ? FontWeight.w700
                        : FontWeight.w500,
                    color: widget.active ? c : p.muted,
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

class _NavTile extends StatefulWidget {
  final NavItem item;
  final bool active;
  final bool expanded;
  final VoidCallback onTap;
  final bool showChevron;
  final bool chevronOpen;

  const _NavTile({
    required this.item,
    required this.active,
    required this.expanded,
    required this.onTap,
    this.showChevron = false,
    this.chevronOpen = false,
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
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
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
                width: 27,
                height: 27,
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
                if (widget.showChevron)
                  AnimatedRotation(
                    duration: AppMotion.normal,
                    curve: AppMotion.standard,
                    // پرانیستی = ښکته، بند = د متن د پیل خوا ته.
                    // `AnimatedRotation` د RTL سره پخپله نه اوړي، نو
                    // د لوري له مخې يې خپله ټاکو.
                    turns: widget.chevronOpen
                        ? 0
                        : (Directionality.of(context) == TextDirection.rtl
                              ? 0.25
                              : -0.25),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 16,
                      color: active ? c : p.faint,
                    ),
                  )
                else
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedRotation(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              turns: expanded ? 0 : 0.5,
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: p.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
