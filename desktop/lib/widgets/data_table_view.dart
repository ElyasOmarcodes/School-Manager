import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/numerals.dart';

/// د یوې ستنې تعریف.
class TableColumn<T> {
  final String title;

  /// د پراخېدو وزن. که `width` ورکړل شي، دا نه کارېږي.
  final int flex;
  final double? width;
  final Alignment align;
  final Widget Function(BuildContext, T) cell;

  const TableColumn({
    required this.title,
    required this.cell,
    this.flex = 1,
    this.width,
    this.align = Alignment.centerRight,
  });
}

/// د پروګرام معیاري جدول.
///
/// دا یو ځل جوړېږي او ټول ماډلونه يې کاروي — شاګردان، استادان،
/// فیس، کتابتون. نو د جدول چلند په ټول پروګرام کې یو شان دی:
/// ټینګ سرلیک، د کرښو پرله‌پسې ښکارېدل، د تشې پاڼې پیغام، او
/// د بارېدو skeleton.
class DataTableView<T> extends StatelessWidget {
  final List<TableColumn<T>> columns;
  final List<T> rows;
  final bool loading;
  final String? emptyTitle;
  final String? emptyHint;
  final IconData emptyIcon;
  final void Function(T)? onRowTap;
  final int skeletonRows;

  const DataTableView({
    super.key,
    required this.columns,
    required this.rows,
    this.loading = false,
    this.emptyTitle,
    this.emptyHint,
    this.emptyIcon = Icons.inbox_rounded,
    this.onRowTap,
    this.skeletonRows = 8,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _HeaderRow(columns: columns),
          Divider(height: 1, color: p.line),
          Expanded(
            child: loading
                ? _Skeleton(columns: columns, count: skeletonRows)
                : rows.isEmpty
                    ? _Empty(
                        icon: emptyIcon,
                        title: emptyTitle ?? '',
                        hint: emptyHint,
                      )
                    : ListView.separated(
                        itemCount: rows.length,
                        separatorBuilder: (_, __) =>
                            Divider(height: 1, color: p.line),
                        itemBuilder: (context, i) => FadeSlideIn.staggered(
                          index: i,
                          offsetY: 4,
                          child: _BodyRow(
                            columns: columns,
                            row: rows[i],
                            onTap: onRowTap,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow<T> extends StatelessWidget {
  final List<TableColumn<T>> columns;
  const _HeaderRow({required this.columns});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      color: p.surfaceAlt,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      child: Row(
        children: [
          for (final c in columns)
            _Cell(
              column: c,
              child: Text(
                c.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: p.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BodyRow<T> extends StatefulWidget {
  final List<TableColumn<T>> columns;
  final T row;
  final void Function(T)? onTap;

  const _BodyRow({required this.columns, required this.row, this.onTap});

  @override
  State<_BodyRow<T>> createState() => _BodyRowState<T>();
}

class _BodyRowState<T> extends State<_BodyRow<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return MouseRegion(
      cursor:
          widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap == null ? null : () => widget.onTap!(widget.row),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: AppMotion.instant,
          color: _hover ? p.surfaceAlt : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              for (final c in widget.columns)
                _Cell(column: c, child: c.cell(context, widget.row)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cell<T> extends StatelessWidget {
  final TableColumn<T> column;
  final Widget child;
  const _Cell({required this.column, required this.child});

  @override
  Widget build(BuildContext context) {
    final inner = Align(alignment: column.align, child: child);
    if (column.width != null) {
      return SizedBox(width: column.width, child: inner);
    }
    return Expanded(flex: column.flex, child: inner);
  }
}

class _Empty extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;
  const _Empty({required this.icon, required this.title, this.hint});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, size: 24, color: p.faint),
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: p.inkSoft,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 5),
            Text(hint!, style: TextStyle(fontSize: 12.5, color: p.muted)),
          ],
        ],
      ),
    );
  }
}

/// د بارېدو پر مهال — د تش پرده پر ځای د کرښو سیوری ښیي، چې
/// کارن پوه شي څه راځي.
class _Skeleton<T> extends StatefulWidget {
  final List<TableColumn<T>> columns;
  final int count;
  const _Skeleton({required this.columns, required this.count});

  @override
  State<_Skeleton<T>> createState() => _SkeletonState<T>();
}

class _SkeletonState<T> extends State<_Skeleton<T>>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ListView.separated(
      itemCount: widget.count,
      separatorBuilder: (_, __) => Divider(height: 1, color: p.line),
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Row(
            children: [
              for (final c in widget.columns)
                _Cell(
                  column: c,
                  child: FractionallySizedBox(
                    widthFactor: 0.62,
                    child: Container(
                      height: 11,
                      decoration: BoxDecoration(
                        color: Color.lerp(
                          p.surfaceAlt,
                          p.line,
                          _c.value,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
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
//  د جدولونو ګډ ټوټې
// ═══════════════════════════════════════════════════════════

/// د حالت نښه — «فعال»، «غیرحاضر»، «رخصت».
class StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// د شاګرد/استاد کوچنی عکس — که عکس نه وي، د نوم لومړی توری.
class AvatarCell extends StatelessWidget {
  final String name;
  final Color color;
  final double size;

  const AvatarCell({
    super.key,
    required this.name,
    this.color = AppColors.primary,
    this.size = 32,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(size / 3.2),
      ),
      alignment: Alignment.center,
      child: Text(
        name.trim().isEmpty ? '?' : name.trim().characters.first,
        style: TextStyle(
          fontSize: size * 0.42,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// د پاڼو کنټرول — «۱–۵۰ له ۸۴۲ څخه».
class PagerBar extends StatelessWidget {
  final int offset;
  final int limit;
  final int total;
  final ValueChanged<int> onOffsetChanged;

  const PagerBar({
    super.key,
    required this.offset,
    required this.limit,
    required this.total,
    required this.onOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final from = total == 0 ? 0 : offset + 1;
    final to = (offset + limit) > total ? total : offset + limit;
    final canPrev = offset > 0;
    final canNext = to < total;

    return Row(
      children: [
        Text(
          '${locale.num(from)}–${locale.num(to)} '
          '${locale == AppLocale.en ? 'of' : 'له'} ${locale.grouped(total)}',
          style: TextStyle(fontSize: 12.5, color: p.muted),
        ),
        const Spacer(),
        _PagerButton(
          icon: Icons.chevron_right_rounded,
          enabled: canPrev,
          onTap: () => onOffsetChanged((offset - limit).clamp(0, total)),
        ),
        const SizedBox(width: 6),
        _PagerButton(
          icon: Icons.chevron_left_rounded,
          enabled: canNext,
          onTap: () => onOffsetChanged(offset + limit),
        ),
      ],
    );
  }
}

class _PagerButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PagerButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: p.line),
          borderRadius: BorderRadius.circular(8),
          color: p.surface,
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? p.inkSoft : p.faint.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}
