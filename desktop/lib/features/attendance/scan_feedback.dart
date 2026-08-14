import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/repositories/attendance_repository.dart';

/// د یوې پایلې رنګ، نښه او متن — یو ځای ټاکل شوي.
///
/// دواړه لویه پرده او د وروستیو لیست همدا کاروي، نو د یوې پایلې
/// رنګ په دواړو ځایونو کې یو دی.
class ScanVisual {
  final Color color;
  final IconData icon;
  final String label;
  final String name;
  final String detail;

  const ScanVisual({
    required this.color,
    required this.icon,
    required this.label,
    required this.name,
    this.detail = '',
  });

  static ScanVisual of(CheckInResult r) => switch (r) {
    CheckInOk(:final student, :final status) => ScanVisual(
      color: status == 'present'
          ? AppColors.success
          : status == 'late'
          ? AppColors.warning
          : AppColors.danger,
      icon: status == 'present'
          ? Icons.check_circle_rounded
          : status == 'late'
          ? Icons.schedule_rounded
          : Icons.running_with_errors_rounded,
      label: switch (status) {
        'present' => 'حاضر',
        'late' => 'ناوخته راغی',
        _ => 'ډېر ناوخته — غیرحاضر ګڼل شو',
      },
      name: _name(student),
      detail: student.admissionNo,
    ),

    CheckInOnLeave(:final student) => ScanVisual(
      color: AppColors.info,
      icon: Icons.event_available_rounded,
      label: 'رخصت — اجازه لري',
      name: _name(student),
      detail: student.admissionNo,
    ),

    CheckInCheckedOut(:final student) => ScanVisual(
      color: AppColors.modStaff,
      icon: Icons.logout_rounded,
      label: 'د وتلو وخت ثبت شو',
      name: _name(student),
      detail: student.admissionNo,
    ),

    CheckInAlreadyDone(:final student) => ScanVisual(
      color: AppColors.modSettings,
      icon: Icons.done_all_rounded,
      label: 'مخکې ثبت شوی',
      name: _name(student),
      detail: student.admissionNo,
    ),

    CheckInRevokedCard(:final student) => ScanVisual(
      color: AppColors.danger,
      icon: Icons.credit_card_off_rounded,
      label: 'دا کارت باطل شوی — نوی کارت ورکړئ',
      name: _name(student),
      detail: student.admissionNo,
    ),

    CheckInInvalidCard() => const ScanVisual(
      color: AppColors.danger,
      icon: Icons.gpp_bad_rounded,
      label: 'جعلي یا خراب کارت',
      name: 'نه دی پېژندل شوی',
    ),

    CheckInUnknown(:final input) => ScanVisual(
      color: AppColors.danger,
      icon: Icons.person_search_rounded,
      label: 'دا نمبر هېڅ شاګرد ته نه ورګرځي',
      name: input,
    ),
  };

  static String _name(dynamic s) => [
    s.firstName as String,
    if (s.lastName != null && (s.lastName as String).isNotEmpty)
      s.lastName as String,
  ].join(' ');
}

/// د سکین لویه پایله — کارکوونکی يې له یوه متره ګوري.
///
/// انیمیشن دلته کار کوي: هره نوې پایله د رنګ له څپې سره راځي، نو
/// کارکوونکی پوهېږي چې سکین ونیول شو — حتی که هماغه شاګرد دوه ځله
/// سکین شي او متن بدل نه شي.
class ScanFeedback extends StatelessWidget {
  final CheckInResult? result;
  final AppLocale locale;

  const ScanFeedback({super.key, required this.result, required this.locale});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    if (result == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.nfc_rounded, size: 54, color: p.faint),
            const SizedBox(height: 14),
            Text(
              'د لومړي کارت په تمه…',
              style: TextStyle(fontSize: 14, color: p.muted),
            ),
          ],
        ),
      );
    }

    final v = ScanVisual.of(result!);

    return AnimatedSwitcher(
      duration: AppMotion.normal,
      switchInCurve: AppMotion.standard,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(
          scale: Tween(begin: 0.96, end: 1.0).animate(anim),
          child: child,
        ),
      ),
      child: Container(
        // کلید د پایلې پر هویت ولاړ دی، نه یوازې پر متن — چې د یوه
        // شاګرد دوه‌ځلی سکین هم انیمیشن راولي.
        key: ValueKey('${v.name}/${v.label}/${identityHashCode(result)}'),
        width: double.infinity,
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: v.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: v.color.withValues(alpha: 0.35)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: v.color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: v.color.withValues(alpha: 0.34),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(v.icon, size: 38, color: Colors.white),
            ),
            const SizedBox(height: 18),
            Text(
              v.name,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: p.ink,
              ),
            ),
            if (v.detail.isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                locale.num(v.detail),
                style: AppTheme.tabular(
                  TextStyle(fontSize: 13, color: p.muted),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: v.color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                v.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
