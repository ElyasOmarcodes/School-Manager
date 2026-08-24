import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/repositories/report_repository.dart';

/// **د یوه راپور جدول** — سرلیک، شمېرې، کرښې او ټولټال.
///
/// **ولې یو ګډ ویجیټ؟** ځکه چې ټول راپورونه یوه بڼه لري
/// (`ReportTable`). که هره پاڼه خپل جدول رسماوه، د یوه بدلون
/// (لکه د ټولټال کرښې) لپاره به څو ځایه سمون پکار و — او یو ځای
/// به تل هېر شوی و.
class ReportTableView extends StatelessWidget {
  final ReportTable table;
  final Color accent;

  const ReportTableView({
    super.key,
    required this.table,
    this.accent = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (table.highlights.isNotEmpty) ...[
            FadeSlideIn(
              child: Row(
                children: [
                  for (final (i, h) in table.highlights.indexed) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(child: _Highlight(h: h, accent: accent)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          Text(
            table.subtitle,
            style: TextStyle(fontSize: 12, color: p.muted),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: p.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    color: p.surfaceAlt,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        for (final (i, c) in table.columns.indexed)
                          Expanded(
                            flex: i == 0 ? 3 : 1,
                            child: Text(
                              c,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: p.muted,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: table.rows.length,
                      itemBuilder: (context, r) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: r.isOdd
                              ? p.surfaceAlt.withValues(alpha: 0.5)
                              : null,
                          border: Border(top: BorderSide(color: p.line)),
                        ),
                        child: Row(
                          children: [
                            for (final (i, c) in table.rows[r].indexed)
                              Expanded(
                                flex: i == 0 ? 3 : 1,
                                child: Text(
                                  locale.num(c),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: i == 0
                                      ? TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w600,
                                          color: p.ink,
                                        )
                                      : AppTheme.tabular(
                                          TextStyle(
                                            fontSize: 12.5,
                                            color: p.inkSoft,
                                          ),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (table.totals.isNotEmpty)
                    Container(
                      color: p.surfaceAlt,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 13,
                      ),
                      child: Row(
                        children: [
                          for (final (i, c) in table.totals.indexed)
                            Expanded(
                              flex: i == 0 ? 3 : 1,
                              child: Text(
                                locale.num(c),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.tabular(
                                  TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: p.ink,
                                  ),
                                ),
                              ),
                            ),
                        ],
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

class _Highlight extends StatelessWidget {
  final ({String label, String value, bool warn}) h;
  final Color accent;

  const _Highlight({required this.h, required this.accent});

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;
    final c = h.warn ? AppColors.warning : accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(
          color: h.warn ? c.withValues(alpha: 0.35) : p.line,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(h.label, style: TextStyle(fontSize: 11.5, color: p.muted)),
          const SizedBox(height: 4),
          Text(
            locale.num(h.value),
            style: AppTheme.tabular(
              TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: h.warn ? c : p.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
