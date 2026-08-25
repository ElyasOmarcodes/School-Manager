import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import 'live_attendance.dart';

/// **د ژوندۍ حاضرۍ نښه** — د پرې‌ټاکل شوي وخت خبر.
///
/// کله چې د یوې ناستې کړکۍ پرانیستل شي، دا نښه په پورتنۍ کرښه او
/// پر ډاشبورډ راښکاره کېږي. یوه نرمه ټکنده ټکی لري — نه ځکه چې
/// ښکلی دی، بلکې ځکه چې مدیر ښايي بله پاڼه ګوري او باید سترګه يې
/// ورشي.
class LiveBadge extends StatefulWidget {
  /// کوچنۍ بڼه — د پورتنۍ کرښې لپاره، پرته له شمېرو.
  final bool compact;
  final VoidCallback? onTap;

  const LiveBadge({super.key, this.compact = false, this.onTap});

  @override
  State<LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = LiveAttendanceScope.maybeOf(context);
    final s = S.of(context);
    final locale = s.locale;

    // که هېڅ ناسته روانه نه وي، نښه هېڅ ځای نه نیسي.
    if (live == null || !live.isLive) return const SizedBox.shrink();

    final sessions = live.live;
    final totals = live.totals;
    final label = sessions.length == 1
        ? sessions.first.name
        : '${locale.num(sessions.length)} ناستې';

    return Tooltip(
      message: [
        for (final x in sessions)
          '${x.name} — ${locale.num(x.startTime)}–${locale.num(x.endTime)}',
      ].join('\n'),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppMotion.normal,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 13,
            vertical: widget.compact ? 6 : 9,
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FadeTransition(
                opacity: Tween(begin: 0.35, end: 1.0).animate(_pulse),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.compact ? s.live : label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
              if (!widget.compact && totals.target > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${locale.num(totals.marked)}/${locale.num(totals.target)}',
                  style: AppTheme.tabular(
                    TextStyle(
                      fontSize: 11.5,
                      color: AppColors.success.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
