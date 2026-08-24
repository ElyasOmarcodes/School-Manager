import 'package:flutter/material.dart';

/// **ټوله پرده یوه نرمه پاڼه ده.**
///
/// کله چې کارن هر ځای کېکاږي، هغه ټکی لږ ښکته ننوځي — بیا په نرمۍ
/// سره بېرته خپل حالت ته راځي، لکه یوه نرمه پاڼه چې ګوته پرې
/// کېږدې.
///
/// **ولې یو عمومي افکټ او نه پر هره تڼۍ باندې؟**
/// ځکه چې «نرمه پاڼه» یوه **د پردې** ځانګړتیا ده، نه د تڼۍ. که پر
/// هره تڼۍ جلا لګول کېده، دوه ستونزې راتلې:
///   ۱. هر نوی ویجیټ به يې بیا لګولو ته اړ و — او یو هېر شوی به
///      «سخت» ښکارېده، چې له نورو سره يې توپیر سترګو ته کېده.
///   ۲. د جدول یوه کرښه، یو کارت، یو خالي ځای — دا ټول به بې‌ځوابه
///      وو، حال دا چې پاڼه خو یوه ده.
///
/// نو دلته د پردې پر سر یو **ژورت** رسمېږي: د کېکاږلو په ټکي کې
/// یوه نرمه تیاره حلقه (سیوری) او تر لاندې يې یوه رڼا (منعکس شوې
/// رڼا) — هماغه دوه څه چې سترګه پرې «ژور» او «راپورته» بېلوي. له
/// هغې سره ټوله پاڼه د هماغه ټکي په لور یوه ذره ټیټېږي.
///
/// **د حرکت کچه قصداً وړه ده** (۰.۶٪ اندازه). یو ښکاره «ټوپ» به د
/// ورځې په سلګونو کلیکونو کې ستړی کوونکی و — دا باید احساس شي، نه
/// ولیدل شي.
class PaperSurface extends StatefulWidget {
  final Widget child;

  /// د ژورت وسعت — د پکسلونو په کچه.
  final double radius;

  /// څومره ټیټېږي (۱ = ۱۰۰٪). تلواله ۰.۰۰۶ ده.
  final double depth;

  const PaperSurface({
    super.key,
    required this.child,
    this.radius = 132,
    this.depth = 0.006,
  });

  @override
  State<PaperSurface> createState() => _PaperSurfaceState();
}

class _PaperSurfaceState extends State<PaperSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    // **ښکته تګ ګړندی، راختل ورو.** ریښتیني نرم شیان همداسې کوي:
    // د فشار لاندې سمدستي ټیټېږي، خو بېرته راختل يې وخت نیسي.
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 340),
  );

  late final Animation<double> _t = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeOutCubic,
  );

  Offset? _point;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _down(PointerDownEvent e) {
    // یوازې لومړی ګوته/کلیک — د څو ګوتو ټکر ژورت نه دوه‌ځلی کوي.
    if (_c.status == AnimationStatus.forward) return;
    setState(() => _point = e.localPosition);
    _c.forward();
  }

  void _up([PointerEvent? _]) {
    if (!mounted) return;
    _c.reverse();
  }

  @override
  Widget build(BuildContext context) {
    // د حرکت کمولو غوښتنه (د سیسټم لاسرسي تنظیم) درناوی کېږي —
    // ځینې کارن له حرکته سرخوږی مومي.
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return widget.child;
    }

    final dark = Theme.of(context).brightness == Brightness.dark;

    return Listener(
      // **`translucent`** — پاڼه پخپله هېڅ کلیک نه اخلي؛ یوازې يې
      // ویني. که `opaque` وای، د لاندې هره تڼۍ به مړه شوې وه.
      behavior: HitTestBehavior.translucent,
      onPointerDown: _down,
      onPointerUp: _up,
      onPointerCancel: _up,
      child: AnimatedBuilder(
        animation: _t,
        child: widget.child,
        builder: (context, child) {
          final t = _t.value;
          final at = _point;
          // په ارام حالت کې هېڅ اضافي پرت نه رسمېږي — نو نه د
          // کارکردګۍ لګښت شته، نه د عکس ازموینو کې بدلون.
          if (t <= 0.001 || at == null) return child!;

          return LayoutBuilder(
            builder: (context, box) {
              final w = box.maxWidth;
              final h = box.maxHeight;
              // د ټیټېدو محور هماغه ټکی دی چې ګوته پرې ده — نو پاڼه
              // د خپل منځه نه، بلکې **د فشار له ځایه** ننوځي.
              final align = Alignment(
                w == 0 ? 0 : (at.dx / w) * 2 - 1,
                h == 0 ? 0 : (at.dy / h) * 2 - 1,
              );

              return Stack(
                children: [
                  Transform.scale(
                    scale: 1 - widget.depth * t,
                    alignment: align,
                    child: child,
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _DentPainter(
                          at: at,
                          t: t,
                          radius: widget.radius,
                          dark: dark,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// د ژورت رسمول — یو سیوری پاس، یوه رڼا ښکته.
///
/// **دا ولې د ژورت احساس ورکوي؟** ځکه چې سترګه ژوروالی له رڼا څخه
/// اټکل کوي. که رڼا له پاسه راځي (لکه هره خونه)، نو یوه ژوره کندې
/// پورتنۍ څنډه **تیاره** وي او لاندنۍ يې **روښانه**. همدا دوه
/// نرمې دايرې بس دي — هېڅ شېډر ته اړتیا نشته.
class _DentPainter extends CustomPainter {
  final Offset at;
  final double t;
  final double radius;
  final bool dark;

  const _DentPainter({
    required this.at,
    required this.t,
    required this.radius,
    required this.dark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final r = radius * (0.72 + 0.28 * t);

    // په تیاره بڼه کې سیوری لږ کمزوری او رڼا لږ پیاوړې ده — که نه،
    // پر تیاره شالید به سیوری بیخي نه ښکارېده.
    final shadowA = (dark ? 0.10 : 0.055) * t;
    final lightA = (dark ? 0.055 : 0.14) * t;

    void blob(Offset center, Color color) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
            stops: const [0, 1],
          ).createShader(Rect.fromCircle(center: center, radius: r)),
      );
    }

    blob(at.translate(0, -r * 0.10), Colors.black.withValues(alpha: shadowA));
    blob(at.translate(0, r * 0.16), Colors.white.withValues(alpha: lightA));
  }

  @override
  bool shouldRepaint(_DentPainter old) =>
      old.t != t || old.at != at || old.dark != dark;
}
