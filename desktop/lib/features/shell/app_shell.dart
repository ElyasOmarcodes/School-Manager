import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../auth/auth_service.dart';
import '../dashboard/dashboard_page.dart';
import 'nav_items.dart';
import 'sidebar.dart';

/// د پروګرام اصلي چوکاټ — سایډبار، پورتنۍ کرښه، او د منځ پاڼه.
class AppShell extends StatefulWidget {
  final Session session;
  final String schoolName;
  final DashboardStats stats;
  final VoidCallback onSignOut;
  final ValueChanged<ThemeMode> onThemeChanged;
  final ThemeMode themeMode;

  const AppShell({
    super.key,
    required this.session,
    required this.schoolName,
    required this.stats,
    required this.onSignOut,
    required this.onThemeChanged,
    required this.themeMode,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _route = '/dashboard';
  bool _expanded = true;

  NavItem? get _currentItem {
    for (final g in buildNav()) {
      for (final i in g.items) {
        if (i.route == _route) return i;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Scaffold(
      backgroundColor: p.ground,
      body: Row(
        children: [
          Sidebar(
            currentRoute: _route,
            role: widget.session.role,
            expanded: _expanded,
            schoolName: widget.schoolName,
            onToggle: () => setState(() => _expanded = !_expanded),
            onNavigate: (r) => setState(() => _route = r),
          ),
          Expanded(
            child: Column(
              children: [
                _TopBar(
                  item: _currentItem,
                  session: widget.session,
                  themeMode: widget.themeMode,
                  onThemeChanged: widget.onThemeChanged,
                  onSignOut: widget.onSignOut,
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppMotion.normal,
                    switchInCurve: AppMotion.standard,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween(
                          begin: const Offset(0, 0.014),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_route),
                      child: _buildPage(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    if (_route == '/dashboard') {
      return DashboardPage(stats: widget.stats);
    }
    // پاتې ماډلونه په راتلونکو پړاوونو کې جوړېږي — خو سایډبار
    // اوس هم ټول ښیي، چې د پرمختګ لار څرګنده وي.
    return _ComingSoon(item: _currentItem);
  }
}

class _TopBar extends StatelessWidget {
  final NavItem? item;
  final Session session;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeChanged;
  final VoidCallback onSignOut;

  const _TopBar({
    required this.item,
    required this.session,
    required this.themeMode,
    required this.onThemeChanged,
    required this.onSignOut,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final scope = LocaleScope.of(context);

    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          if (item != null) ...[
            Icon(item!.icon, size: 18, color: item!.color),
            const SizedBox(width: 9),
            Text(
              item!.label(s),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
          ],
          const Spacer(),

          // ژبه
          PopupMenuButton<AppLocale>(
            tooltip: '',
            onSelected: scope.setLocale,
            itemBuilder: (_) => [
              for (final l in AppLocale.values)
                PopupMenuItem(value: l, child: Text(l.label)),
            ],
            child: _IconSlot(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.language_rounded, size: 17, color: p.muted),
                  const SizedBox(width: 5),
                  Text(
                    scope.locale.label,
                    style: TextStyle(fontSize: 12, color: p.inkSoft),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // تیاره / روښانه
          Tooltip(
            message: themeMode == ThemeMode.dark ? 'روښانه' : 'تیاره',
            child: InkWell(
              borderRadius: BorderRadius.circular(9),
              onTap: () => onThemeChanged(
                themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
              ),
              child: _IconSlot(
                child: Icon(
                  themeMode == ThemeMode.dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  size: 17,
                  color: p.muted,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: p.line),
          const SizedBox(width: 12),

          // کارن
          PopupMenuButton<String>(
            tooltip: '',
            onSelected: (v) {
              if (v == 'signout') onSignOut();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'signout',
                child: Row(
                  children: [
                    const Icon(Icons.logout_rounded, size: 16),
                    const SizedBox(width: 9),
                    Text(s.signOut),
                  ],
                ),
              ),
            ],
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                  child: Text(
                    session.fullName.characters.first,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 9),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.fullName,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      session.role,
                      style: TextStyle(fontSize: 10.5, color: p.faint),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IconSlot extends StatelessWidget {
  final Widget child;
  const _IconSlot({required this.child});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: child,
      );
}

class _ComingSoon extends StatelessWidget {
  final NavItem? item;
  const _ComingSoon({required this.item});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);
    final c = item?.color ?? AppColors.primary;

    return Center(
      child: FadeSlideIn(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(17),
              ),
              child:
                  Icon(item?.icon ?? Icons.widgets_rounded, size: 29, color: c),
            ),
            const SizedBox(height: 18),
            Text(
              item?.label(s) ?? '',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'دا ماډل په راتلونکي پړاو کې جوړېږي.',
              style: TextStyle(fontSize: 13, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}
