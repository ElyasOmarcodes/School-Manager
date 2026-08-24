import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../attendance/live_attendance.dart';
import '../attendance/live_badge.dart';

/// د ډاشبورډ خلاصه — هغه څلور شمېرې چې مدیر سهار لومړی ګوري.
class DashboardStats {
  final int totalStudents;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final double feesCollectedPercent;
  final List<double> weeklyAttendance; // ۰..۱۰۰
  final List<String> weekdayLabels;
  final List<AttentionItem> attention;

  const DashboardStats({
    required this.totalStudents,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.feesCollectedPercent,
    required this.weeklyAttendance,
    required this.weekdayLabels,
    required this.attention,
  });

  double get presentPercent =>
      totalStudents == 0 ? 0 : (presentToday / totalStudents) * 100;

  /// د لومړي ران لپاره — کله چې لا هېڅ ډیټا نشته.
  static const DashboardStats empty = DashboardStats(
    totalStudents: 0,
    presentToday: 0,
    absentToday: 0,
    lateToday: 0,
    feesCollectedPercent: 0,
    weeklyAttendance: [0, 0, 0, 0, 0, 0],
    weekdayLabels: ['ش', 'ی', 'د', 'س', 'چ', 'پ'],
    attention: [],
  );
}

/// **د ډاشبورډ یو کلیک — چېرته ځي.**
///
/// ډاشبورډ یوازې د شمېرو یوه تخته نه ده؛ د پاڼو یوه دروازه ده. کله
/// چې مدیر «نن غیرحاضر ۴۷» ویني، بله پوښتنه يې تل یوه ده: **کوم
/// څلوېښت اووه؟** که کلیک کار ونه کړي، هغه بیا سایډبار، بیا ناسته،
/// بیا فلټر — درې ګامه چې ځواب يې مخې ته پروت و.
class DashboardLink {
  final String route;

  /// د حاضرۍ لیست کوم حالت ښکاره کړي — `present` | `absent` |
  /// `late` | `leave`.
  final String? status;

  /// مستقیم یو شاګرد پرانیزي — د «پاملرنې لیست» کرښې يې کاروي.
  final int? studentId;

  const DashboardLink(this.route, {this.status, this.studentId});
}

class AttentionItem {
  final String text;
  final Color color;
  final IconData icon;

  /// پر دې کرښه کلیک چېرته بیایي. `null` = یوازې د لوستلو لپاره.
  final DashboardLink? link;

  const AttentionItem(this.text, this.color, this.icon, {this.link});
}

class DashboardPage extends StatelessWidget {
  final DashboardStats stats;

  /// **هر توکی تعاملي دی.** که `null` وي، ډاشبورډ یوازې لوستل کېږي
  /// (د عکسونو او ازموینو لپاره).
  final ValueChanged<DashboardLink>? onOpen;

  const DashboardPage({super.key, required this.stats, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // **د ژوندۍ حاضرۍ کرښه** — یوازې هغه وخت ښکاري چې یوه
          // ناسته روانه وي. که تل ښکارېده، سترګه به ورسره روږدې
          // شوې وه او د اړتیا پر وخت به يې نه لیده.
          const _LiveStrip(),
          FadeSlideIn(
            child: _KpiRow(stats: stats, s: s, onOpen: onOpen),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 900;
              final chart = FadeSlideIn(
                delay: AppMotion.staggerFor(4),
                child: _ChartCard(stats: stats, s: s, onOpen: onOpen),
              );
              final list = FadeSlideIn(
                delay: AppMotion.staggerFor(5),
                child: _AttentionCard(stats: stats, s: s, onOpen: onOpen),
              );
              if (narrow) {
                return Column(
                  children: [chart, const SizedBox(height: 16), list],
                );
              }
              // `IntrinsicHeight` دواړه پینلونه یو لوړوالی ورکوي.
              // پرته له دې، `CrossAxisAlignment.stretch` د سکرول پاڼې
              // دننه بې‌پایه لوړوالی غواړي او رینډر ماتېږي.
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 3, child: chart),
                    const SizedBox(width: 16),
                    Expanded(flex: 2, child: list),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          FadeSlideIn(
            delay: AppMotion.staggerFor(6),
            child: _QuickActions(s: s, onOpen: onOpen),
          ),
        ],
      ),
    );
  }
}

/// د ژوندۍ حاضرۍ کرښه — نښه او د پرمختګ کرښه.
class _LiveStrip extends StatelessWidget {
  const _LiveStrip();

  @override
  Widget build(BuildContext context) {
    final live = LiveAttendanceScope.maybeOf(context);
    if (live == null || !live.isLive) return const SizedBox.shrink();

    final p = context.palette;
    final totals = live.totals;
    final ratio = totals.target == 0 ? 0.0 : totals.marked / totals.target;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const LiveBadge(),
            const SizedBox(width: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
                  duration: AppMotion.slow,
                  curve: AppMotion.emphasized,
                  builder: (context, v, _) => LinearProgressIndicator(
                    value: v,
                    minHeight: 6,
                    backgroundColor: p.surfaceAlt,
                    valueColor: const AlwaysStoppedAnimation(
                      AppColors.success,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'سکینر روان دی — پر هره پاڼه کار کوي.',
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ژر لاسرسی — هغه څلور کارونه چې مدیر ورځې څو ځله کوي
// ═══════════════════════════════════════════════════════════

class _QuickActions extends StatelessWidget {
  final S s;
  final ValueChanged<DashboardLink>? onOpen;
  const _QuickActions({required this.s, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final actions = <(String, IconData, Color, DashboardLink)>[
      (
        s.takeAttendance,
        Icons.fact_check_rounded,
        AppColors.modAttendance,
        const DashboardLink('/attendance'),
      ),
      (
        s.addStudent,
        Icons.person_add_rounded,
        AppColors.modStudents,
        const DashboardLink('/students/enroll'),
      ),
      (
        s.notifyParents,
        Icons.campaign_rounded,
        AppColors.modMessages,
        const DashboardLink('/messages'),
      ),
      (
        s.idCards,
        Icons.qr_code_2_rounded,
        AppColors.modIdCards,
        const DashboardLink('/id-cards'),
      ),
    ];

    return _Panel(
      title: s.quickActions,
      child: LayoutBuilder(
        builder: (context, c) {
          final perRow = c.maxWidth < 620 ? 2 : 4;
          const gap = 12.0;
          final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final (label, icon, color, link) in actions)
                SizedBox(
                  width: w,
                  child: _ActionTile(
                    label: label,
                    icon: icon,
                    color: color,
                    onTap: onOpen == null ? null : () => onOpen!(link),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _ActionTile({
    required this.label,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
        decoration: BoxDecoration(
          color: _hover ? widget.color.withValues(alpha: 0.09) : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: _hover ? widget.color.withValues(alpha: 0.45) : p.line,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(widget.icon, size: 17, color: widget.color),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                widget.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: p.inkSoft,
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

// ═══════════════════════════════════════════════════════════
//  KPI کارتونه — ګرادیانټ، رنګین، له شمېرلو انیمیشن سره
// ═══════════════════════════════════════════════════════════

class _KpiRow extends StatelessWidget {
  final DashboardStats stats;
  final S s;
  final ValueChanged<DashboardLink>? onOpen;
  const _KpiRow({required this.stats, required this.s, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final cards = <Widget>[
      _KpiCard(
        label: s.totalStudents,
        value: stats.totalStudents,
        locale: locale,
        icon: Icons.school_rounded,
        gradient: AppColors.gradIndigo,
        index: 0,
        // ټول شاګردان → د شاګردانو لیست.
        onTap: onOpen == null
            ? null
            : () => onOpen!(const DashboardLink('/students')),
      ),
      _KpiCard(
        label: s.presentToday,
        value: stats.presentToday,
        locale: locale,
        suffix: stats.totalStudents > 0
            ? '  (${locale.num(stats.presentPercent.round())}%)'
            : '',
        icon: Icons.check_circle_rounded,
        gradient: AppColors.gradEmerald,
        index: 1,
        // نن حاضر → د نننۍ حاضرۍ لیست، پر «حاضر» فلټر شوی.
        onTap: onOpen == null
            ? null
            : () => onOpen!(
                const DashboardLink('/attendance/today', status: 'present'),
              ),
      ),
      _KpiCard(
        label: s.absentToday,
        value: stats.absentToday,
        locale: locale,
        icon: Icons.cancel_rounded,
        gradient: AppColors.gradRose,
        index: 2,
        onTap: onOpen == null
            ? null
            : () => onOpen!(
                const DashboardLink('/attendance/today', status: 'absent'),
              ),
      ),
      _KpiCard(
        label: s.feesCollected,
        value: stats.feesCollectedPercent.round(),
        locale: locale,
        suffix: '%',
        icon: Icons.payments_rounded,
        gradient: AppColors.gradAmber,
        index: 3,
        onTap: onOpen == null
            ? null
            : () => onOpen!(const DashboardLink('/fees')),
      ),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final perRow = c.maxWidth < 620 ? 2 : 4;
        const gap = 16.0;
        final w = (c.maxWidth - gap * (perRow - 1)) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final card in cards) SizedBox(width: w, child: card)],
        );
      },
    );
  }
}

class _KpiCard extends StatefulWidget {
  final String label;
  final num value;
  final String suffix;
  final IconData icon;
  final List<Color> gradient;
  final int index;
  final AppLocale locale;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.index,
    required this.locale,
    this.suffix = '',
    this.onTap,
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap == null
          ? MouseCursor.defer
          : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        transform: Matrix4.translationValues(0, _hover ? -3 : 0, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: widget.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: widget.gradient.first.withValues(
                alpha: _hover ? 0.34 : 0.20,
              ),
              blurRadius: _hover ? 22 : 14,
              offset: Offset(0, _hover ? 9 : 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(widget.icon, color: Colors.white, size: 18),
                ),
                const Spacer(),
                // **د کلیک وړتیا باید ښکاره وي.** یوه غشۍ چې د موس
                // پر راتګ روښانه شي، ټول کارت یوه تڼۍ ښیي — پرته له
                // دې، کارن هېڅکله نه ازمویي چې پرې کېکاږي.
                if (widget.onTap != null)
                  AnimatedOpacity(
                    duration: AppMotion.fast,
                    opacity: _hover ? 1 : 0.45,
                    child: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_back_rounded
                          : Icons.arrow_forward_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            CountUpText(
              value: widget.value,
              suffix: widget.suffix,
              format: (v) => widget.locale.num(v.round()),
              style: AppTheme.tabular(
                const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د اونۍ حاضري — چارټ
// ═══════════════════════════════════════════════════════════

class _ChartCard extends StatelessWidget {
  final DashboardStats stats;
  final S s;
  final ValueChanged<DashboardLink>? onOpen;
  const _ChartCard({required this.stats, required this.s, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasData = stats.weeklyAttendance.any((v) => v > 0);

    return _Panel(
      title: s.weeklyAttendance,
      // د اونۍ کرښه یوه پوښتنه پیدا کوي — «کومه ورځ ولې ښکته وه؟»
      // — او ځواب يې د حاضرۍ رپوټ کې دی.
      onOpen: onOpen == null
          ? null
          : () => onOpen!(const DashboardLink('/reports')),
      child: SizedBox(
        height: 240,
        child: hasData
            ? BarChart(
                BarChartData(
                  maxY: 100,
                  minY: 0,
                  alignment: BarChartAlignment.spaceAround,
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: p.line, strokeWidth: 1),
                  ),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          '${S.of(context).locale.num(v.round())}%',
                          style: TextStyle(fontSize: 10, color: p.faint),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 28,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= stats.weekdayLabels.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              stats.weekdayLabels[i],
                              style: TextStyle(fontSize: 11, color: p.muted),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < stats.weeklyAttendance.length; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: stats.weeklyAttendance[i],
                            width: 22,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                            gradient: LinearGradient(
                              // رنګ معنا لري، نه ښکلا: شین = ښه (۹۰٪+)،
                              // نارنجي = پاملرنه (۷۵–۸۹٪)، سور = ستونزه.
                              colors: stats.weeklyAttendance[i] >= 90
                                  ? AppColors.gradEmerald
                                  : stats.weeklyAttendance[i] >= 75
                                  ? AppColors.gradAmber
                                  : AppColors.gradRose,
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                duration: AppMotion.slow,
                curve: AppMotion.emphasized,
              )
            : _EmptyState(
                icon: Icons.bar_chart_rounded,
                text: S.of(context).locale == AppLocale.en
                    ? 'No attendance recorded yet'
                    : 'لا حاضري نه ده ثبت شوې',
              ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د پاملرنې لیست
// ═══════════════════════════════════════════════════════════

/// د پاملرنې یوه کرښه — پر کلیک هماغه شاګرد پرانیزي.
class _AttentionRow extends StatefulWidget {
  final AttentionItem item;
  final VoidCallback? onTap;
  const _AttentionRow({required this.item, this.onTap});

  @override
  State<_AttentionRow> createState() => _AttentionRowState();
}

class _AttentionRowState extends State<_AttentionRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final tappable = widget.onTap != null;

    return MouseRegion(
      cursor: tappable ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: _hover && tappable ? p.surfaceAlt : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: widget.item.color.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  widget.item.icon,
                  size: 15,
                  color: widget.item.color,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  widget.item.text,
                  style: TextStyle(fontSize: 12.8, color: p.inkSoft),
                ),
              ),
              if (tappable)
                AnimatedOpacity(
                  duration: AppMotion.fast,
                  opacity: _hover ? 1 : 0,
                  child: Icon(
                    Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left_rounded
                        : Icons.chevron_right_rounded,
                    size: 17,
                    color: p.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AttentionCard extends StatelessWidget {
  final DashboardStats stats;
  final S s;
  final ValueChanged<DashboardLink>? onOpen;
  const _AttentionCard({required this.stats, required this.s, this.onOpen});

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: s.needsAttention,
      onOpen: onOpen == null
          ? null
          : () => onOpen!(const DashboardLink('/reports')),
      child: stats.attention.isEmpty
          ? const SizedBox(
              height: 240,
              child: _EmptyState(
                icon: Icons.check_circle_outline_rounded,
                text: 'هر څه سم دي',
              ),
            )
          : Column(
              children: [
                for (var i = 0; i < stats.attention.length; i++)
                  FadeSlideIn.staggered(
                    index: i,
                    offsetY: 6,
                    child: _AttentionRow(
                      item: stats.attention[i],
                      onTap:
                          onOpen == null || stats.attention[i].link == null
                          ? null
                          : () => onOpen!(stats.attention[i].link!),
                    ),
                  ),
              ],
            ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  ګډ ټوټې
// ═══════════════════════════════════════════════════════════

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;

  /// د پینل سرلیک پخپله یوه لار شي — د «ټول وګوره» تڼۍ يې ښیي.
  final VoidCallback? onOpen;

  const _Panel({required this.title, required this.child, this.onOpen});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
              const Spacer(),
              if (onOpen != null)
                TextButton.icon(
                  onPressed: onOpen,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                  ),
                  icon: const Icon(Icons.open_in_new_rounded, size: 14),
                  label: const Text(
                    'ټول وګوره',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  const _EmptyState({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 34, color: p.faint),
          const SizedBox(height: 10),
          Text(text, style: TextStyle(fontSize: 12.5, color: p.muted)),
        ],
      ),
    );
  }
}
