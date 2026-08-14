import 'package:flutter/material.dart';

import '../core/design.dart';
import '../core/strings.dart';

/// د یوې شمېرې کارت — د ډاشبورډ پورتنۍ کرښه.
class StatTile extends StatelessWidget {
  final String label;
  final int value;
  final String? sub;
  final List<Color> gradient;
  final IconData icon;

  const StatTile({
    super.key,
    required this.label,
    required this.value,
    required this.gradient,
    required this.icon,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(M.radiusLg),
        boxShadow: [
          BoxShadow(
            color: gradient.first.withValues(alpha: 0.26),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(icon, size: 17, color: Colors.white.withValues(alpha: 0.9)),
              const Spacer(),
              if (sub != null)
                Text(
                  sub!,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            num_(value, t.locale),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? hint;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 46, horizontal: 24),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: p.surfaceAlt,
              borderRadius: BorderRadius.circular(19),
            ),
            child: Icon(icon, size: 28, color: p.faint),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: p.inkSoft,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 7),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, height: 1.75, color: p.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(strokeWidth: 2.4));
}

/// د ناکامۍ پرده — تل یوه «بیا هڅه وکړه» تڼۍ لري.
class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        Container(
          width: 62,
          height: 62,
          decoration: BoxDecoration(
            color: M.danger.withValues(alpha: 0.11),
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Icon(
            Icons.wifi_off_rounded,
            size: 28,
            color: M.danger,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, height: 1.85, color: p.inkSoft),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, size: 18),
          label: const Text('بیا هڅه وکړه'),
        ),
      ],
    );
  }
}

class InfoCard extends StatelessWidget {
  final List<(String, String)> rows;
  const InfoCard({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(M.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 86,
                    child: Text(
                      r.$1,
                      style: TextStyle(fontSize: 12.5, color: p.muted),
                    ),
                  ),
                  Expanded(
                    child: SelectableText(
                      r.$2.isEmpty ? '—' : r.$2,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
