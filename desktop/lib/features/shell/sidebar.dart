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

    final tile = _NavTile(
      item: widget.item,
      active: _ownsRoute,
      expanded: widget.expanded,
      showChevron: widget.item.hasChildren && widget.expanded,
      chevronOpen: _showChildren,
      onTap: () {
        // ټول شوی + فرعي توکي = منو. پر مور لار تګ دلته نه کوو،
        // ځکه چې منو کې لومړی توکی همغه مور پاڼه ده.
        if (widget.item.hasChildren && !widget.expanded) {
          _showCollapsedMenu(
            context,
            item: widget.item,
            currentRoute: widget.currentRoute,
            onNavigate: widget.onNavigate,
          );
          return;
        }
        if (widget.item.hasChildren && widget.expanded) {
          setState(() => _open = !_ownsRoute || !_open);
          // پر مور توکي کېکاږل لومړي فرعي توکي ته هم بیایي —
          // که نه، کارن به دوه ځله کېکاږلو ته اړ و.
          if (!_ownsRoute) widget.onNavigate(children.first.route);
          return;
        }
        widget.onNavigate(widget.item.route);
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        AnimatedSize(
          duration: AppMotion.normal,
          curve: AppMotion.standard,
          alignment: Alignment.topCenter,
          child: _showChildren
              ? _SubList(
                  items: children,
                  color: widget.item.color,
                  currentRoute: widget.currentRoute,
                  onNavigate: widget.onNavigate,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// **د ټول شوي سایډبار فرعي منو.**
///
/// کله چې سایډبار یوازې نښانونه ښیي، فرعي توکي هلته ځای نه لري —
/// خو پټېدل يې هم سم نه دي: هغه چې سایډبار يې د ځای د سپمولو لپاره
/// ټول کړی و، د ازموینو تنظیماتو یا د کارت ډیزاینر ته يې لار نه
/// لرله. اوس پر نښان یو کلیک دا منو راولي.
///
/// **ولې `showMenu` نه `PopupMenuButton`؟** ځکه چې د توکي کاشۍ خپله
/// یو `GestureDetector` لري. که يې یو `PopupMenuButton` راتاو کړی
/// وای، کلیک به تل کاشۍ اخیسته او منو به هېڅکله نه وه راغلې.
Future<void> _showCollapsedMenu(
  BuildContext context, {
  required NavItem item,
  required String currentRoute,
  required ValueChanged<String> onNavigate,
}) async {
  final s = S.of(context);
  final p = context.palette;
  final c = item.color;

  final box = context.findRenderObject() as RenderBox?;
  final overlay =
      Navigator.of(context).overlay?.context.findRenderObject() as RenderBox?;
  if (box == null || overlay == null) return;

  // منو د کاشۍ څنګ ته راځي، نه پر سر — نو نښان لا هم ښکاري او کارن
  // پوهېږي چې دا د کوم توکي فرعي لیست دی.
  final origin = box.localToGlobal(Offset.zero, ancestor: overlay);
  final rect = RelativeRect.fromLTRB(
    origin.dx + box.size.width,
    origin.dy,
    overlay.size.width - origin.dx - box.size.width,
    0,
  );

  final picked = await showMenu<String>(
    context: context,
    position: rect,
    // د اپ خپل سطح او څنډه — نه د متریال تلواله، چې منو د پاڼې
    // له پاتې برخې سره یو ډول ښکاره شي.
    color: p.surface,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black.withValues(alpha: 0.16),
    elevation: 10,
    constraints: const BoxConstraints(minWidth: 178, maxWidth: 260),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: p.line),
    ),
    items: [
      PopupMenuItem<String>(
        enabled: false,
        height: 32,
        child: Text(
          item.label(s),
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: p.faint,
          ),
        ),
      ),
      const PopupMenuDivider(),
      for (final sub in item.children)
        PopupMenuItem<String>(
          value: sub.route,
          height: 38,
          child: Row(
            children: [
              Icon(
                sub.icon,
                size: 15,
                color: currentRoute == sub.route ? c : p.muted,
              ),
              const SizedBox(width: 10),
              Text(
                sub.label(s),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: currentRoute == sub.route
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: currentRoute == sub.route ? c : p.inkSoft,
                ),
              ),
            ],
          ),
        ),
    ],
  );

  if (picked != null) onNavigate(picked);
}

/// **د فرعي توکو لیست** — یوه ریل او پرې یو ښویېدونکی نښان.
///
/// **ولې ریل؟** ځکه چې فرعي توکي یوه ډله ده، نه څو خپلواک تڼۍ. یوه
/// دوامداره کرښه دا ډله سترګو ته یو شی ښیي، او پر هغې باندې یو
/// نښان چې له یوه توکي بل ته **ښویېږي** — نه دا چې یو ځای ورک او
/// بل ځای پیدا شي.
///
/// د ښویېدو ګټه یوازې ښکلا نه ده: کله چې نښان حرکت وکړي، سترګه يې
/// تعقیبوي او کارن پوهېږي چې **له کومه کوم ته** لاړ — هغه څه چې د
/// ناڅاپي بدلون سره ورک وي.
class _SubList extends StatelessWidget {
  final List<NavSubItem> items;
  final Color color;
  final String currentRoute;
  final ValueChanged<String> onNavigate;

  /// د یوې کرښې لوړوالی — نښان پرې حسابېږي، نو ثابت دی.
  static const double rowHeight = 34;

  const _SubList({
    required this.items,
    required this.color,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final index = items.indexWhere((c) => c.route == currentRoute);

    return Padding(
      // پیل (RTL کې ښي) لور کې د مور توکي د نښان لاندې ودرېږي —
      // نو ریل د هغه له عمودي کرښې سره برابر وي.
      padding: const EdgeInsetsDirectional.fromSTEB(26, 3, 14, 7),
      child: Stack(
        children: [
          // ── ریل ─────────────────────────────────────────
          PositionedDirectional(
            start: 0,
            top: 4,
            bottom: 4,
            child: Container(
              width: 2,
              decoration: BoxDecoration(
                color: p.line,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),

          // ── ښویېدونکی نښان ──────────────────────────────
          //
          // یوازې هغه وخت ښکاري چې یو فرعي توکی واقعاً فعال وي —
          // که مور لار پرانیستې وي خو فرعي یو هم نه، یو ګنګس نښان
          // به پر ریل ولاړ و.
          if (index >= 0)
            AnimatedPositionedDirectional(
              duration: AppMotion.normal,
              curve: AppMotion.emphasized,
              start: -1,
              top: index * rowHeight + 8,
              child: Container(
                width: 4,
                height: rowHeight - 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 7,
                    ),
                  ],
                ),
              ),
            ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final c in items)
                _SubTile(
                  sub: c,
                  color: color,
                  active: currentRoute == c.route,
                  onTap: () => onNavigate(c.route),
                ),
            ],
          ),
        ],
      ),
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
    final active = widget.active;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          height: _SubList.rowHeight,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              curve: AppMotion.standard,
              margin: const EdgeInsetsDirectional.only(start: 12),
              padding: const EdgeInsetsDirectional.fromSTEB(11, 6, 12, 6),
              decoration: BoxDecoration(
                // فعال توکی یو نرم ګرادیانت اخلي چې د ریل په لور
                // پای ته رسېږي — نو د نښان سره تړلی ښکاري، نه یو
                // خپلواک رنګین څلورضلعی.
                gradient: active
                    ? LinearGradient(
                        begin: AlignmentDirectional.centerStart,
                        end: AlignmentDirectional.centerEnd,
                        colors: [
                          c.withValues(alpha: 0.14),
                          c.withValues(alpha: 0.02),
                        ],
                      )
                    : null,
                color: active
                    ? null
                    : (_hover ? p.surfaceAlt : Colors.transparent),
                borderRadius: const BorderRadiusDirectional.horizontal(
                  start: Radius.circular(3),
                  end: Radius.circular(9),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // د هوور پر مهال لږ ښي خوا ته ښویېږي — یو کوچنی
                  // ژوندی ځواب چې «دا کېکاږل کېږي» وايي.
                  AnimatedSlide(
                    duration: AppMotion.fast,
                    curve: AppMotion.standard,
                    offset: Offset(_hover && !active ? 0.10 : 0, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          widget.sub.icon,
                          size: 14.5,
                          color: active ? c : (_hover ? p.inkSoft : p.muted),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          widget.sub.label(s),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: active
                                ? c
                                : (_hover ? p.inkSoft : p.muted),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
