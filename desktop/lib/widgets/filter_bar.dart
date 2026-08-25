import 'package:flutter/material.dart';

import '../core/l10n/strings.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_motion.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/numerals.dart';
import '../core/widgets/panel.dart';

/// ═══════════════════════════════════════════════════════════
///  **د فلټرونو معیاري بڼه — د ټول پروګرام لپاره یوه قاعده.**
///
///  مخکې هره پاڼه خپله لاره وه: ځینې فلټرونه پورته ښکاره، ځینې د
///  «فلټرونه» تڼۍ لاندې پټ — او دا وېش هېڅ قاعده نه لرله. کارن چې
///  یو ځل يې زده کړل، په بله پاڼه کې بېرته لټون ته اړ و. دا **د
///  کارونې د یووالي** ماتېدنه ده، نه یوازې د ښکلا.
///
///  **قاعده چې اوس هرځای پلې کېږي:**
///
///    ۱. پورتنۍ کرښه تل درې څیزه لري — نه لږ، نه ډېر:
///       • **لټون** — هغه څه چې ۸۰٪ وخت کارېږي.
///       • **یو یا دوه بنسټیز فلټر** (ټولګی/درجه) — د دې پاڼې
///         هغه ویش چې پرته له هغه لیست معنا نه لري.
///       • **«پرمختللي فلټرونه»** تڼۍ — له خپل شمېر سره.
///
///    ۲. **نور ټول** فلټرونه — ولایت، جنس، حالت، سکونت، نېټه —
///       د تڼۍ لاندې دي. هېڅ یو ترې بهر نه پاتې کېږي.
///
///    ۳. تڼۍ پر خپل ځان **شمېر** وړي، نو کارن پوهېږي ولې لیست
///       لنډ دی — پرته له دې چې تخته پرانیزي.
/// ═══════════════════════════════════════════════════════════

/// **د لیست پورتنۍ کرښه.**
class FilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final String searchHint;
  final double searchWidth;

  /// بنسټیز فلټرونه چې تل ښکاره وي — یو یا دوه، نه ډېر.
  final List<Widget> primary;

  /// د پرمختللو فلټرونو فعال شمېر. صفر = تڼۍ ساده ښکاري.
  final int activeCount;
  final bool open;

  /// که تش وي، «پرمختللي فلټرونه» تڼۍ نه ښکاري — ځینې لیستونه
  /// ریښتیا پرمختللي فلټرونه نه لري.
  final VoidCallback? onToggle;

  /// د پایلو شمېر — «۸۴۲ شاګردان».
  final String? countLabel;

  /// وروستۍ تڼۍ — «نوی شاګرد»، «اکسپورټ»…
  final List<Widget> actions;

  const FilterBar({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.searchHint,
    this.searchWidth = 300,
    this.primary = const [],
    this.activeCount = 0,
    this.open = false,
    this.onToggle,
    this.countLabel,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    // **د پردې له پلنوالي سره ځان جوړوي.**
    //
    // یوه ثابته کرښه دوه ستونزې لري: پر تنګه پرده توکي یو پر بل
    // ورختل کېږي یا پټېږي، او پر پراخه پرده بې‌ځایه دوه کرښې نیسي.
    // نو دلته لومړی حساب کوو چې څومره ځای شته — او یوازې هغه وخت
    // دوهمې کرښې ته ځو چې ریښتیا پکار وي.
    return LayoutBuilder(
      builder: (context, c) {
        // د یوه بنسټیز فلټر اټکلي پلنوالی + فاصله.
        const primaryWidth = 190.0 + 8;
        const advancedWidth = 190.0 + 8;
        const actionWidth = 150.0 + 9;

        final needed =
            searchWidth +
            primary.length * primaryWidth +
            (onToggle == null ? 0 : advancedWidth) +
            (countLabel == null ? 0 : 130) +
            actions.length * actionWidth;

        final tight = needed > c.maxWidth;

        // لټون هم راټولېږي، خو له یوې کچې ښکته نه — یو تنګ لټون
        // له هېڅ لټونه بدتر دی.
        final searchW = tight
            ? (searchWidth * 0.62).clamp(190.0, searchWidth)
            : searchWidth;

        final head = <Widget>[
          SizedBox(width: searchW, child: _search(context)),
          for (final w in primary) ...[const SizedBox(width: 8), w],
          if (onToggle != null) ...[
            const SizedBox(width: 8),
            AdvancedFiltersButton(
              open: open,
              count: activeCount,
              onTap: onToggle!,
            ),
          ],
        ];

        final tail = <Widget>[
          if (countLabel != null) ...[
            Flexible(
              child: Text(
                countLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.end,
                style: TextStyle(fontSize: 12.5, color: p.muted),
              ),
            ),
            const SizedBox(width: 14),
          ],
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 9),
            actions[i],
          ],
        ];

        // **دوهمه کرښه یوازې کله چې ریښتیا پکار وي.**
        final twoLines = needed > c.maxWidth * 1.18;

        if (!twoLines) {
          return Row(
            children: [...head, const Spacer(), ...tail],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [...head, const Spacer()]),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: tail,
            ),
          ],
        );
      },
    );
  }

  Widget _search(BuildContext context) => TextField(
    controller: searchController,
    onChanged: onSearchChanged,
    decoration: InputDecoration(
      hintText: searchHint,
      prefixIcon: const Icon(Icons.search_rounded, size: 19),
      // د لټون پاکولو تڼۍ یوازې هغه وخت چې څه لیکل شوي وي.
      suffixIcon: searchController.text.isEmpty
          ? null
          : IconButton(
              tooltip: '',
              icon: const Icon(Icons.close_rounded, size: 16),
              onPressed: () {
                searchController.clear();
                onSearchChanged('');
              },
            ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
    ),
  );
}

/// **«پرمختللي فلټرونه» تڼۍ.**
///
/// خپل شمېر پر ځان وړي. پرته له دې، کارن چې یو فلټر پرېښی وي او
/// تخته يې بنده کړې وي، به نه پوهېده ولې لیست دومره لنډ دی.
class AdvancedFiltersButton extends StatelessWidget {
  final bool open;
  final int count;
  final VoidCallback onTap;

  const AdvancedFiltersButton({
    super.key,
    required this.open,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final active = count > 0;
    final lit = active || open;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: lit
                ? AppColors.primary.withValues(alpha: 0.09)
                : p.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            border: Border.all(
              color: lit
                  ? AppColors.primary.withValues(alpha: 0.4)
                  : p.line,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.tune_rounded,
                size: 16,
                color: lit ? AppColors.primary : p.muted,
              ),
              const SizedBox(width: 6),
              Text(
                s.advancedFilters,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: lit ? AppColors.primary : p.inkSoft,
                ),
              ),
              if (active) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Text(
                    s.locale.num(count),
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              AnimatedRotation(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                turns: open ? 0.5 : 0,
                child: Icon(
                  Icons.expand_more_rounded,
                  size: 15,
                  color: lit ? AppColors.primary : p.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// **د پرمختللو فلټرونو تخته.**
///
/// پرانیستل او بندول يې نرم دي — جدول ښکته ښویېږي، نه چې ټوپ ووهي.
class FilterSheet extends StatelessWidget {
  final bool open;

  /// هر فلټر یوه [FilterField] کې راځي، چې پلنوالی يې یو شان وي.
  final List<Widget> children;

  final int activeCount;
  final VoidCallback onClear;

  const FilterSheet({
    super.key,
    required this.open,
    required this.children,
    required this.activeCount,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return AnimatedSize(
      duration: AppMotion.normal,
      curve: AppMotion.standard,
      alignment: Alignment.topCenter,
      child: !open
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Panel(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.start,
                      children: children,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          activeCount == 0
                              ? 'هېڅ فلټر فعال نه دی'
                              : '${s.locale.num(activeCount)} فلټرونه فعال دي',
                          style: TextStyle(fontSize: 12, color: p.muted),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: activeCount == 0 ? null : onClear,
                          icon: const Icon(Icons.clear_all_rounded, size: 16),
                          label: Text(s.clearFilters),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// **یو فلټر له سرلیک سره.**
///
/// **ولې سرلیک؟** ځکه چې د یوې تختې دننه لس کنټرولونه پرته له
/// نومه یو معما دي — «ټول» څه ته وايي؟ ټول ولایتونه؟ ټول جنسونه؟
class FilterField extends StatelessWidget {
  final String label;
  final Widget child;
  final double width;

  const FilterField({
    super.key,
    required this.label,
    required this.child,
    this.width = 208,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, bottom: 6),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: p.muted,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// د «ټول» ځانګړې نښه — `null` نه کارېږي، ځکه چې `PopupMenuButton`
/// یوه `null` پایله له «بنده شوه» سره یو شان ګڼي.
const Object _clearAll = Object();

/// **یو بنسټیز فلټر چې پر پورتنۍ کرښه ولاړ وي** — یوه وړه منو.
///
/// یوازې د هغو فلټرونو لپاره چې د لیست بنسټیز ویش دی (ټولګی،
/// درجه). نور ټول تختې ته ځي.
class QuickFilter<T> extends StatelessWidget {
  /// کله چې هېڅ نه وي ټاکل شوی — «ټول ټولګي».
  final String label;
  final T? value;
  final List<({T value, String label})> options;
  final ValueChanged<T?> onChanged;
  final IconData? icon;
  final double maxWidth;

  /// ټوله شته پلنوالی ونیسي — د تختې دننه، چې کرښې برابرې شي.
  final bool expand;

  /// بند دی — لکه ولسوالۍ مخکې له دې چې ولایت وټاکل شي.
  final bool dimmed;

  const QuickFilter({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.icon,
    this.maxWidth = 190,
    this.expand = false,
    this.dimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final active = value != null;
    final current = active
        ? options
              .where((o) => o.value == value)
              .map((o) => o.label)
              .firstOrNull
        : null;

    if (dimmed) return _shell(context, current, dim: true);

    // **«ټول» یوه ځانګړې نښه ده، نه `null`.**
    //
    // دا یوه ریښتینې ګټله وه: `PopupMenuButton` د `null` پایله له
    // «کارن منو بنده کړه» سره یو شان ګڼي، نو `onSelected` هېڅکله
    // د «ټول» لپاره نه بلل کېده — او فلټر به یو ځل چې ټاکل شو،
    // بېرته نه پاکېده. اوس «ټول» خپله نښه لري، او یوازې د حقیقي
    // بندېدو پر مهال `null` راځي.
    return PopupMenuButton<Object>(
      tooltip: '',
      position: PopupMenuPosition.under,
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      elevation: 10,
      constraints: BoxConstraints(minWidth: 170, maxWidth: maxWidth + 90),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.line),
      ),
      onSelected: (picked) =>
          onChanged(picked == _clearAll ? null : picked as T),
      itemBuilder: (_) => [
        PopupMenuItem<Object>(
          value: _clearAll,
          height: 38,
          child: Row(
            children: [
              Icon(
                Icons.clear_all_rounded,
                size: 15,
                color: value == null ? AppColors.primary : p.muted,
              ),
              const SizedBox(width: 9),
              Text(
                label,
                style: TextStyle(
                  fontWeight: value == null
                      ? FontWeight.w700
                      : FontWeight.w500,
                  color: value == null ? AppColors.primary : p.inkSoft,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        for (final o in options)
          PopupMenuItem<Object>(
            value: o.value as Object,
            height: 38,
            child: Text(
              o.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: o.value == value
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: o.value == value ? AppColors.primary : p.inkSoft,
              ),
            ),
          ),
      ],
      child: _shell(context, current),
    );
  }

  Widget _shell(BuildContext context, String? current, {bool dim = false}) {
    final p = context.palette;
    final active = value != null && !dim;
    final ink = dim
        ? p.faint
        : (active ? AppColors.primary : p.inkSoft);

    return Container(
      width: expand ? maxWidth : null,
      constraints: expand ? null : BoxConstraints(maxWidth: maxWidth),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: active
            ? AppColors.primary.withValues(alpha: 0.09)
            : (dim ? p.surfaceAlt : p.surface),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: active ? AppColors.primary.withValues(alpha: 0.4) : p.line,
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: dim ? p.faint : (active ? AppColors.primary : p.muted)),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              current ?? label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                color: ink,
              ),
            ),
          ),
          if (expand) const Spacer(),
          const SizedBox(width: 5),
          Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: dim ? p.faint : (active ? AppColors.primary : p.muted),
          ),
        ],
      ),
    );
  }
}

/// **د تختې دننه یو فلټر — هماغه بڼه چې پورتنۍ کرښه يې لري.**
///
/// **ولې ټول یو شکل؟** ځکه چې مخکې درې بڼې ګډې وې: پر پورتنۍ کرښه
/// منو-چیپونه، په تخته کې د فورمې ډراپ‌ډاونونه، او څنګ ته يې
/// «سېګمنټ» تڼۍ. درې واړه یو کار کاوه — یو ارزښت ټاکل — خو درې
/// بېلې بڼې يې لرلې. کارن چې یو ځل زده کړي، باید هرځای هماغه
/// وپېژني. اوس **هر فلټر یو منو دی**، هر یو له خپل سرلیک سره.
class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<({T value, String label})> options;
  final ValueChanged<T?> onChanged;
  final String? allLabel;
  final bool enabled;
  final double width;
  final IconData? icon;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.allLabel,
    this.enabled = true,
    this.width = 208,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return FilterField(
      label: label,
      width: width,
      child: QuickFilter<T>(
        label: allLabel ?? s.all,
        value: value,
        options: options,
        onChanged: enabled ? onChanged : (_) {},
        icon: icon,
        maxWidth: width,
        expand: true,
        dimmed: !enabled,
      ),
    );
  }
}
