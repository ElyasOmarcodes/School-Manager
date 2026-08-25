import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/exam_repository.dart';

/// **د ازموینو د پاڼو ګډه فلټر کرښه.**
///
/// د نمرو ثبت او د پایلو کتنه دواړه هماغه پوښتنه لري: «کوم ټولګی،
/// کوم مضمون؟» نو یوه کرښه دواړو ته — که دوه جلا جوړې شوې وای، یوه
/// به ژر له بلې سره توپیر پیدا کړ او کارن به ګیج شو.
///
/// توپیر يې یوازې دا دی چې د پایلو په حالت کې «ټول» هم شته.
class ExamFilterBar extends StatelessWidget {
  final List<Grade> grades;
  final List<Subject> subjects;
  final ResultFilter filter;
  final ValueChanged<ResultFilter> onChanged;

  /// ایا «ټول» اختیار شته؟ د نمرو د ثبت پر مهال نه — یوه نمره یوه
  /// ټاکلې خانه ته ځي.
  final bool allowAll;

  /// د ترتیب او پایلې فلټرونه — یوازې د پایلو په پاڼه کې.
  final bool showSortAndOutcome;

  final bool madrasa;
  final List<Widget> trailing;

  const ExamFilterBar({
    super.key,
    required this.grades,
    required this.subjects,
    required this.filter,
    required this.onChanged,
    this.allowAll = false,
    this.showSortAndOutcome = false,
    this.madrasa = false,
    this.trailing = const [],
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    // **دا هغه ټکی دی چې د دواړو «ټول» مخه نیسي.**
    // که ټولګی «ټول» وي، د مضمون «ټول» بند دی — او برعکس.
    final gradeAllBlocked = allowAll && filter.subjectId == null;
    final subjectAllBlocked = allowAll && filter.gradeId == null;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 12),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: DropdownButtonFormField<int?>(
              initialValue: filter.gradeId,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: madrasa ? 'درجه' : s.grade,
                isDense: true,
              ),
              items: [
                if (allowAll)
                  DropdownMenuItem(
                    value: null,
                    enabled: !gradeAllBlocked,
                    child: Text(
                      s.all,
                      style: TextStyle(
                        color: gradeAllBlocked ? p.faint : null,
                      ),
                    ),
                  ),
                for (final g in grades)
                  DropdownMenuItem(value: g.id, child: Text(g.name)),
              ],
              onChanged: (v) => onChanged(
                v == null
                    ? filter.copyWith(
                        allGrades: true,
                        fallbackSubjectId: subjects.firstOrNull?.id,
                      )
                    : filter.copyWith(gradeId: v),
              ),
            ),
          ),
          SizedBox(
            width: 220,
            child: DropdownButtonFormField<int?>(
              initialValue: filter.subjectId,
              isDense: true,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: s.subjects,
                isDense: true,
              ),
              items: [
                if (allowAll)
                  DropdownMenuItem(
                    value: null,
                    enabled: !subjectAllBlocked,
                    child: Text(
                      s.all,
                      style: TextStyle(
                        color: subjectAllBlocked ? p.faint : null,
                      ),
                    ),
                  ),
                for (final sub in subjects)
                  DropdownMenuItem(
                    value: sub.id,
                    child: Text(sub.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (v) => onChanged(
                v == null
                    ? filter.copyWith(
                        allSubjects: true,
                        fallbackGradeId: grades.firstOrNull?.id,
                      )
                    : filter.copyWith(subjectId: v),
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              onChanged: (v) => onChanged(filter.copyWith(query: v)),
              decoration: InputDecoration(
                hintText: '${s.search}…',
                isDense: true,
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
              ),
            ),
          ),
          if (showSortAndOutcome) ...[
            _Choice(
              label: s.sortByMarks,
              value: filter.sort,
              options: {
                'rank': s.sortByMarks,
                'name': s.sortByName,
                'roll': 'د حاضرۍ نمبر',
              },
              onChanged: (v) => onChanged(filter.copyWith(sort: v)),
              icon: Icons.sort_rounded,
            ),
            _Choice(
              label: s.all,
              value: filter.outcome,
              options: {
                'all': s.all,
                'passed': s.passed,
                'failed': s.failed,
                'absent': s.absent,
              },
              onChanged: (v) => onChanged(filter.copyWith(outcome: v)),
              icon: Icons.filter_alt_rounded,
              colorFor: (v) => switch (v) {
                'passed' => AppColors.success,
                'failed' => AppColors.danger,
                'absent' => AppColors.warning,
                _ => AppColors.primary,
              },
            ),
          ],
          ...trailing,
        ],
      ),
    );
  }
}

/// یوه وړه ټاکنه — د پاپ‌اپ په بڼه، چې د کرښې ځای ونه نیسي.
class _Choice extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;
  final IconData icon;
  final Color Function(String)? colorFor;

  const _Choice({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    required this.icon,
    this.colorFor,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = colorFor?.call(value) ?? AppColors.primary;
    final isDefault = value == options.keys.first;

    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: onChanged,
      itemBuilder: (_) => [
        for (final e in options.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          color: isDefault ? p.surface : c.withValues(alpha: 0.09),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: isDefault ? p.line : c.withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: isDefault ? p.muted : c),
            const SizedBox(width: 7),
            Text(
              options[value] ?? label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isDefault ? FontWeight.w500 : FontWeight.w700,
                color: isDefault ? p.inkSoft : c,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.expand_more_rounded,
              size: 15,
              color: isDefault ? p.muted : c,
            ),
          ],
        ),
      ),
    );
  }
}

/// د اکسپورټ تڼۍ — CSV او چاپ.
///
/// **ولې دواړه؟** CSV هغه وخت پکار دی چې پایلې ایکسل ته ولاړې شي
/// (د معارف ریاست ته لېږل)؛ چاپ هغه وخت چې پر دیوال ونښلوي.
class ExportButton extends StatelessWidget {
  final VoidCallback? onCsv;
  final VoidCallback? onPrint;
  final VoidCallback? onPdf;

  const ExportButton({super.key, this.onCsv, this.onPrint, this.onPdf});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return PopupMenuButton<String>(
      tooltip: '',
      onSelected: (v) => switch (v) {
        'csv' => onCsv?.call(),
        'pdf' => onPdf?.call(),
        _ => onPrint?.call(),
      },
      itemBuilder: (_) => [
        if (onCsv != null)
          const PopupMenuItem(
            value: 'csv',
            child: Row(
              children: [
                Icon(Icons.table_view_rounded, size: 17),
                SizedBox(width: 10),
                Text('CSV — ایکسل ته'),
              ],
            ),
          ),
        if (onPdf != null)
          const PopupMenuItem(
            value: 'pdf',
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, size: 17),
                SizedBox(width: 10),
                Text('PDF فایل'),
              ],
            ),
          ),
        if (onPrint != null)
          const PopupMenuItem(
            value: 'print',
            child: Row(
              children: [
                Icon(Icons.print_rounded, size: 17),
                SizedBox(width: 10),
                Text('چاپ'),
              ],
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.ios_share_rounded, size: 15, color: p.muted),
            const SizedBox(width: 7),
            Text(
              s.export,
              style: TextStyle(fontSize: 12.5, color: p.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

/// د نمرې رنګ — د سلنې له مخې. یو ځای، چې ټولې پاڼې يې یو شان وښيي.
Color markColor(double percent) {
  if (percent >= 80) return AppColors.success;
  if (percent >= 60) return AppColors.modReports;
  if (percent >= 40) return AppColors.warning;
  return AppColors.danger;
}

/// «۴۵ / ۱۰۰» — د ختیځو شمېرو سره.
String markText(double? obtained, int full, AppLocale locale) {
  if (obtained == null) return '—';
  final v = obtained == obtained.roundToDouble()
      ? obtained.round().toString()
      : obtained.toStringAsFixed(1);
  return '${locale.num(v)} / ${locale.num(full)}';
}
