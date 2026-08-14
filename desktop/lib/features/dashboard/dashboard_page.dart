import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';

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

class AttentionItem {
  final String text;
  final Color color;
  final IconData icon;
  const AttentionItem(this.text, this.color, this.icon);
}

class DashboardPage extends StatelessWidget {
  final DashboardStats stats;
  const DashboardPage({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: _KpiRow(stats: stats, s: s),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final narrow = c.maxWidth < 900;
              final chart = FadeSlideIn(
                delay: AppMotion.staggerFor(4),
                child: _ChartCard(stats: stats, s: s),
              );
              final list = FadeSlideIn(
                delay: AppMotion.staggerFor(5),
                child: _AttentionCard(stats: stats, s: s),
              );
              if (narrow) {
                return Column(
                  children: [chart, const SizedBox(height: 16), list],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: chart),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: list),
                ],
              );
            },
          ),
        ],
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
  const _KpiRow({required this.stats, required this.s});

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _KpiCard(
        label: s.totalStudents,
        value: stats.totalStudents,
        icon: Icons.school_rounded,
        gradient: AppColors.gradIndigo,
        index: 0,
      ),
      _KpiCard(
        label: s.presentToday,
        value: stats.presentToday,
        suffix: stats.totalStudents > 0
            ? '  (${stats.presentPercent.round()}%)'
            : '',
        icon: Icons.check_circle_rounded,
        gradient: AppColors.gradEmerald,
        index: 1,
      ),
      _KpiCard(
        label: s.absentToday,
        value: stats.absentToday,
        icon: Icons.cancel_rounded,
        gradient: AppColors.gradRose,
        index: 2,
      ),
      _KpiCard(
        label: s.feesCollected,
        value: stats.feesCollectedPercent.round(),
        suffix: '%',
        icon: Icons.payments_rounded,
        gradient: AppColors.gradAmber,
        index: 3,
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
          children: [
            for (final card in cards) SizedBox(width: w, child: card),
          ],
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

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.index,
    this.suffix = '',
  });

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
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
              color:
                  widget.gradient.first.withValues(alpha: _hover ? 0.34 : 0.20),
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
              ],
            ),
            const SizedBox(height: 14),
            CountUpText(
              value: widget.value,
              suffix: widget.suffix,
              style: AppTheme.tabular(const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.15,
              )),
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
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د اونۍ حاضري — چارټ
// ═══════════════════════════════════════════════════════════

class _ChartCard extends StatelessWidget {
  final DashboardStats stats;
  final S s;
  const _ChartCard({required this.stats, required this.s});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final hasData = stats.weeklyAttendance.any((v) => v > 0);

    return _Panel(
      title: s.weeklyAttendance,
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
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 25,
                        reservedSize: 36,
                        getTitlesWidget: (v, _) => Text(
                          '${v.round()}%',
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
                              colors: stats.weeklyAttendance[i] >= 90
                                  ? AppColors.gradEmerald
                                  : stats.weeklyAttendance[i] >= 75
                                      ? AppColors.gradIndigo
                                      : AppColors.gradAmber,
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

class _AttentionCard extends StatelessWidget {
  final DashboardStats stats;
  final S s;
  const _AttentionCard({required this.stats, required this.s});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return _Panel(
      title: s.needsAttention,
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: stats.attention[i].color
                                  .withValues(alpha: 0.13),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              stats.attention[i].icon,
                              size: 15,
                              color: stats.attention[i].color,
                            ),
                          ),
                          const SizedBox(width: 11),
                          Expanded(
                            child: Text(
                              stats.attention[i].text,
                              style:
                                  TextStyle(fontSize: 12.8, color: p.inkSoft),
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

// ═══════════════════════════════════════════════════════════
//  ګډ ټوټې
// ═══════════════════════════════════════════════════════════

class _Panel extends StatelessWidget {
  final String title;
  final Widget child;
  const _Panel({required this.title, required this.child});

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
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: p.ink,
            ),
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
