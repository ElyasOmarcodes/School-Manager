import 'package:flutter/material.dart';

import '../core/design.dart';
import '../core/strings.dart';
import 'pairing_page.dart';

/// د نمونې ډیټا — تر هغې چې د ښوونځي سرور (څلورم پړاو) جوړ شي.
///
/// دا په قصد جلا ساتل شوې چې د API کلاینټ راتلو سره یوازې دا فایل
/// بدل شي، نه پردې.
class DemoData {
  const DemoData._();

  static const int total = 842;
  static const int present = 795;
  static const int absent = 47;
  static const int pendingLeave = 5;

  static const List<({String name, String klass, String status})> absentees = [
    (name: 'احمد ولي', klass: '۱۰ — الف', status: 'درې ورځې پرله‌پسې'),
    (name: 'کریم الله', klass: '۸ — ب', status: 'نن'),
    (name: 'زرغونه نوري', klass: '۹ — الف', status: 'نن'),
    (name: 'بلال خان', klass: '۱۱ — ب', status: 'دوه ورځې'),
    (name: 'مرسل احمدي', klass: '۷ — الف', status: 'نن'),
  ];

  static const List<({String name, String klass, int attendance})> children = [
    (name: 'احمد ولي', klass: '۱۰ — الف', attendance: 94),
    (name: 'زرغونه ولي', klass: '۷ — ب', attendance: 98),
  ];
}

class HomeShell extends StatefulWidget {
  final AppRole role;
  final bool demo;
  final VoidCallback onDisconnect;

  const HomeShell({
    super.key,
    required this.role,
    required this.demo,
    required this.onDisconnect,
  });

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final isManager = widget.role == AppRole.manager;

    final destinations = isManager
        ? <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_rounded),
              label: t.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_busy_rounded),
              label: t.absentToday,
            ),
            NavigationDestination(
              icon: const Icon(Icons.event_available_rounded),
              label: t.pendingLeave,
            ),
            NavigationDestination(
              icon: const Icon(Icons.more_horiz_rounded),
              label: t.more,
            ),
          ]
        : <NavigationDestination>[
            NavigationDestination(
              icon: const Icon(Icons.home_rounded),
              label: t.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.fact_check_rounded),
              label: t.attendance,
            ),
            NavigationDestination(
              icon: const Icon(Icons.payments_rounded),
              label: t.fees,
            ),
            NavigationDestination(
              icon: const Icon(Icons.forum_rounded),
              label: t.messages,
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.pal.surface,
        surfaceTintColor: Colors.transparent,
        title: Text(
          isManager ? 'د نور لیسه' : t.myChildren,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        actions: [
          if (widget.demo)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: M.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'نمونه',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: M.warning,
                    ),
                  ),
                ),
              ),
            ),
          IconButton(
            onPressed: widget.onDisconnect,
            icon: const Icon(Icons.logout_rounded, size: 20),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: M.normal,
        switchInCurve: M.ease,
        child: KeyedSubtree(
          key: ValueKey('$_tab-${widget.role}'),
          child: _page(isManager),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: destinations,
      ),
    );
  }

  Widget _page(bool isManager) {
    if (_tab == 0) {
      return isManager ? const _ManagerHome() : const _ParentHome();
    }
    if (isManager && _tab == 1) return const _AbsenteesPage();
    return const _Placeholder();
  }
}

// ═══════════════════════════════════════════════════════════
//  د مدیر کور
// ═══════════════════════════════════════════════════════════

class _ManagerHome extends StatelessWidget {
  const _ManagerHome();

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final l = LocaleScope.of(context).locale;
    final p = context.pal;
    final pct = (DemoData.present / DemoData.total * 100).round();

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          children: [
            Expanded(
              child: _Stat(
                label: t.presentToday,
                value: '${num_(DemoData.present, l)}  (${num_(pct, l)}%)',
                gradient: M.gradEmerald,
                icon: Icons.check_circle_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Stat(
                label: t.absentToday,
                value: num_(DemoData.absent, l),
                gradient: M.gradRose,
                icon: Icons.cancel_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // دا هغه تڼۍ ده چې د پلان زړه ده: مدیر يې وهي او د ټولو
        // غیرحاضرو والدینو ته پیغام ځي.
        _ActionCard(
          icon: Icons.campaign_rounded,
          color: M.primary,
          title: t.notifyParents,
          subtitle:
              '${num_(DemoData.absent, l)} کورنۍ د نن غیرحاضرۍ خبر ته سترګې په لار دي',
          onTap: () => _showNotifySheet(context),
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.event_available_rounded,
          color: M.info,
          title: t.pendingLeave,
          subtitle:
              '${num_(DemoData.pendingLeave, l)} غوښتنې ستاسو تصویب ته انتظار باسي',
          onTap: () {},
        ),

        const SizedBox(height: 22),
        Text(
          t.absentToday,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: p.ink,
          ),
        ),
        const SizedBox(height: 10),
        for (final a in DemoData.absentees)
          _PersonTile(
            name: a.name,
            subtitle: '${a.klass} · ${a.status}',
            color: M.danger,
          ),
      ],
    );
  }

  void _showNotifySheet(BuildContext context) {
    final l = LocaleScope.of(context).locale;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final p = context.pal;
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'والدینو ته پیغام',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: p.ink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'د ${num_(DemoData.absent, l)} غیرحاضرو شاګردانو والدینو ته '
                'د غیرحاضرۍ خبر لېږل کېږي.',
                style: TextStyle(fontSize: 13, height: 1.8, color: p.muted),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text('ټولو ته واستوه'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('انتخابي — لیست وګوره'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د والدینو کور
// ═══════════════════════════════════════════════════════════

class _ParentHome extends StatelessWidget {
  const _ParentHome();

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final l = LocaleScope.of(context).locale;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        for (final c in DemoData.children) ...[
          _ChildCard(name: c.name, klass: c.klass, attendance: c.attendance),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 10),
        _ActionCard(
          icon: Icons.event_available_rounded,
          color: M.info,
          title: t.requestLeave,
          subtitle: 'د ناروغۍ یا کورنۍ چارې لپاره اجازه وغواړئ',
          onTap: () {},
        ),
        const SizedBox(height: 12),
        _ActionCard(
          icon: Icons.payments_rounded,
          color: M.success,
          title: t.fees,
          subtitle: 'د ${num_(2, l)} ماشومانو فیس تر نېټې پورې ورکړل شوی',
          onTap: () {},
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ټوټې
// ═══════════════════════════════════════════════════════════

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradient;
  final IconData icon;

  const _Stat({
    required this.label,
    required this.value,
    required this.gradient,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(M.radiusLg),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.28),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 19),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(M.radius),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(M.radius),
          border: Border.all(color: p.line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, height: 1.6, color: p.muted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_left_rounded, size: 20, color: p.faint),
          ],
        ),
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final String name;
  final String klass;
  final int attendance;

  const _ChildCard({
    required this.name,
    required this.klass,
    required this.attendance,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    final l = LocaleScope.of(context).locale;
    final good = attendance >= 90;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(M.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: M.primary.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.characters.first,
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: M.primary,
                  ),
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    Text(
                      klass,
                      style: TextStyle(fontSize: 12.5, color: p.muted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (good ? M.success : M.warning).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${num_(attendance, l)}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: good ? M.success : M.warning,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: attendance / 100,
              minHeight: 7,
              backgroundColor: p.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(good ? M.success : M.warning),
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final String name;
  final String subtitle;
  final Color color;

  const _PersonTile({
    required this.name,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            alignment: Alignment.center,
            child: Text(
              name.characters.first,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: p.ink,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 11.5, color: p.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AbsenteesPage extends StatelessWidget {
  const _AbsenteesPage();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        for (final a in DemoData.absentees)
          _PersonTile(
            name: a.name,
            subtitle: '${a.klass} · ${a.status}',
            color: M.danger,
          ),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder();

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, size: 42, color: p.faint),
            const SizedBox(height: 14),
            Text(
              T.of(context).comingInPhase4,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, height: 1.9, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}
