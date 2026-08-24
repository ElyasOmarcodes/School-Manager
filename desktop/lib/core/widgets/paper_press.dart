import 'package:flutter/material.dart';

/// **د کلیک نرم ځواب.**
///
/// کله چې کارن هر ځای کېکاږي، د هماغه ټکي شاوخوا یوه ډېره نرمه
/// رڼا راښکاره کېږي، لږ غځېږي او ورکېږي — لکه اوبه چې پرې څاڅکی
/// ولوېږي.
///
/// **پرده پخپله هېڅکله نه خوځېږي.**
///
/// لومړۍ هڅه مې د ټولې پردې یوه وړه اندازه‌بدلونه وه — چې د «نرمې
/// پاڼې» احساس ورکړي. هغه یوه ریښتینې تېروتنه وه: کله چې د پردې
/// ټول محتوا د هر کلیک سره وخوځېږي، سترګه او د بدن د انډول حس سره
/// ټکر کوي — هماغه څه چې د موټر په ناستې کې زړه بدوالی راولي. یو
/// افکټ چې کارونکی ناروغ کړي، هېڅ ښکلا يې نه پخلا کوي.
///
/// نو اوس یوازې **رڼا** بدلېږي، هېڅ شی خپل ځای نه پرېږدي. د یوه
/// ثابت انځور پر سر د رڼا بدلون سترګې نه ستړې کوي، ځکه چې مغز يې
/// د حرکت په توګه نه لولي.
class PaperSurface extends StatefulWidget {
  final Widget child;

  /// د رڼا وروستۍ کچه — د پکسلونو په کچه.
  final double radius;

  const PaperSurface({super.key, required this.child, this.radius = 58});

  @override
  State<PaperSurface> createState() => _PaperSurfaceState();
}

class _PaperSurfaceState extends State<PaperSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // یو ځل ځغلي او ورکېږي — نه دا چې تر پرېښودو پورې ولاړ وي.
    // یوه اوږده ژوندۍ نښه به د لیکلو پر مهال ستړې کوونکې وه.
    duration: const Duration(milliseconds: 420),
  );

  Offset? _point;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(PointerDownEvent e) {
    setState(() => _point = e.localPosition);
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }

    final dark = Theme.of(context).brightness == Brightness.dark;

    return Listener(
      // پاڼه پخپله هېڅ کلیک نه اخلي؛ یوازې يې ویني.
      behavior: HitTestBehavior.translucent,
      onPointerDown: _down,
      child: Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _c,
                builder: (context, _) {
                  final t = _c.value;
                  final at = _point;
                  // په ارام حالت کې هېڅ نه رسمېږي — نه لګښت، نه د
                  // عکس ازموینو کې بدلون.
                  if (t <= 0 || t >= 1 || at == null) {
                    return const SizedBox.shrink();
                  }
                  return CustomPaint(
                    painter: _GlowPainter(
                      at: at,
                      t: t,
                      radius: widget.radius,
                      dark: dark,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// یوه نرمه رڼا چې غځېږي او ورکېږي.
class _GlowPainter extends CustomPainter {
  final Offset at;
  final double t;
  final double radius;
  final bool dark;

  const _GlowPainter({
    required this.at,
    required this.t,
    required this.radius,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // **غځېدل ژر، ورکېدل ورو.** دا هغه بڼه ده چې طبیعي ښکاري —
    // یو ځواب چې سمدستي راځي او په ارامۍ ولاړېږي.
    final grow = Curves.easeOutCubic.transform(t.clamp(0.0, 1.0));
    final fade = 1 - Curves.easeInCubic.transform(t.clamp(0.0, 1.0));
    final r = radius * (0.35 + 0.65 * grow);

    // ډېره سپکه ده — احساس شي، ونه لیدل شي.
    final peak = dark ? 0.085 : 0.055;
    final color = (dark ? Colors.white : Colors.black).withValues(
      alpha: peak * fade,
    );

    canvas.drawCircle(
      at,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
          stops: const [0, 1],
        ).createShader(Rect.fromCircle(center: at, radius: r)),
    );
  }

  @override
  bool shouldRepaint(_GlowPainter old) =>
      old.t != t || old.at != at || old.dark != dark;
}
