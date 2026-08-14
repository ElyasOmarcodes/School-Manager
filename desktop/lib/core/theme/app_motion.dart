import 'package:flutter/material.dart';

/// د انیمیشن ټوکنونه — یو ځای ټاکل شوي چې ټول پروګرام یو حس ولري.
///
/// اصل: انیمیشن باید *څه ښيي*، نه لوبه وکړي. هېڅ یوه تر ۴۰۰ms اوږده نه ده،
/// او هېڅ یوه ټوپ (bounce) نه لري — ځکه چې مدیر ورځې سلګونه ځله دا پاڼې ګوري.
class AppMotion {
  const AppMotion._();

  // ── وختونه ──────────────────────────────────────────────
  static const Duration instant = Duration(milliseconds: 90);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);
  static const Duration counter = Duration(milliseconds: 700);

  // ── منحنۍ ───────────────────────────────────────────────
  /// د معیاري حرکت منحنی — ګړندی پیل، نرم درېدل.
  static const Curve standard = Cubic(0.22, 0.61, 0.36, 1.0);

  /// د ننوتلو لپاره (ماډال، توسټ).
  static const Curve enter = Curves.easeOutCubic;

  /// د وتلو لپاره — ګړندی، چې کارن ونه ځنډېږي.
  static const Curve exit = Curves.easeInCubic;

  /// د پرمختګ کرښو او چارټونو لپاره.
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1.0);

  // ── د کرښو پرله‌پسې ځنډ (stagger) ───────────────────────
  static const Duration staggerStep = Duration(milliseconds: 28);

  static Duration staggerFor(int index, {int max = 12}) =>
      staggerStep * (index > max ? max : index);
}

/// یو ویجیټ چې ماشوم يې په نرمۍ سره راښکاره کوي — د لیستونو،
/// کارتونو او پاڼو د ننوتلو لپاره.
///
/// که د کارن سیسټم `prefers-reduced-motion` ولري، انیمیشن پرېږدي
/// او ماشوم سمدستي ښیي.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final double offsetY;
  final Duration duration;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offsetY = 10,
    this.duration = AppMotion.normal,
  });

  /// د لیست د یوې کرښې لپاره — ځنډ له index څخه حسابېږي.
  factory FadeSlideIn.staggered({
    Key? key,
    required int index,
    required Widget child,
    double offsetY = 10,
  }) {
    return FadeSlideIn(
      key: key,
      delay: AppMotion.staggerFor(index),
      offsetY: offsetY,
      child: child,
    );
  }

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // د لاسرسي درناوی: که کارن انیمیشن نه غواړي، سمدستي ښکاره کړه.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    final curved = CurvedAnimation(parent: _c, curve: AppMotion.standard);
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value,
          child: Transform.translate(
            offset: Offset(0, widget.offsetY * (1 - curved.value)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// شمېره چې له صفر څخه تر خپلې وروستۍ ارزښت پورې شمېرل کېږي —
/// د ډاشبورډ د KPI کارتونو لپاره.
class CountUpText extends StatelessWidget {
  final num value;
  final TextStyle? style;
  final String suffix;
  final String Function(num)? format;

  const CountUpText({
    super.key,
    required this.value,
    this.style,
    this.suffix = '',
    this.format,
  });

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return Text('${format?.call(value) ?? value.round()}$suffix',
          style: style);
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: AppMotion.counter,
      curve: AppMotion.emphasized,
      builder: (context, v, _) => Text(
        '${format?.call(v) ?? v.round()}$suffix',
        style: style,
      ),
    );
  }
}
