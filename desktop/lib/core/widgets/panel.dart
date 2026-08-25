import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// یو سپین کارت له سرلیک سره — د پاڼو ګډ چوکاټ.
class Panel extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final List<Widget> actions;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const Panel({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.actions = const [],
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = color ?? AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 15, 18, 13),
              child: Row(
                children: [
                  if (icon != null) ...[
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: c.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Icon(icon, size: 16, color: c),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title!,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.ink,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: TextStyle(fontSize: 11.5, color: p.muted),
                          ),
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
            ),
            Divider(height: 1, color: p.line),
          ],
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

/// یوه رنګینه نښه — «۱۲ بخشونه»، «۳ ژوندي».
class Pill extends StatelessWidget {
  final IconData? icon;
  final Color color;
  final String text;
  final bool filled;

  const Pill({
    super.key,
    this.icon,
    required this.color,
    required this.text,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color : color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: filled ? Colors.white : color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

/// د تش حالت پیغام — د هرې پاڼې لپاره یو شان.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? hint;
  final Widget? action;

  const EmptyState({
    super.key,
    required this.icon,
    required this.text,
    this.hint,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 54),
      child: Column(
        children: [
          Icon(icon, size: 38, color: p.faint),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: p.muted,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 5),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: p.faint),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}

/// د دوو یا درېیو حالتونو ترمنځ ټاکنه — «کتار / ګریډ»، «فردي / ډله ایز».
class SegmentedChoice<T> extends StatelessWidget {
  final List<({T value, String label, IconData? icon})> options;
  final T value;
  final ValueChanged<T> onChanged;
  final Color color;

  const SegmentedChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final o in options)
            GestureDetector(
              onTap: () => onChanged(o.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: o.value == value ? p.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: o.value == value
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 5,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (o.icon != null) ...[
                      Icon(
                        o.icon,
                        size: 14,
                        color: o.value == value ? color : p.muted,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      o.label,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: o.value == value
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: o.value == value ? color : p.muted,
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
