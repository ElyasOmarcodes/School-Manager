import 'dart:convert';

import 'package:flutter/material.dart';

/// **د کارت یوه برخه** — یوه ساحه، یو انځور، یا یو ثابت متن.
///
/// **ولې یو ثابت لیست، نه یو آزاد جوړښت؟** ځکه چې هره برخه باید د
/// یوه ریښتیني ارزښت سره تړلې وي — نوم، نمبر، QR. یو بشپړ آزاد
/// ډیزاینر به یوازې انځورونه جوړول، نه کارتونه. نو ډولونه پېژندل
/// شوي دي، خو **ځای، اندازه، رنګ او ښکارېدل يې ټول آزاد دي**.
enum CardFieldKind {
  schoolName,
  logo,
  photo,
  fullName,
  fatherName,
  idNo,
  className,
  jobTitle,
  year,
  expiry,
  phone,
  qr,
  text,
  box;

  String get label => switch (this) {
    CardFieldKind.schoolName => 'د ښوونځي نوم',
    CardFieldKind.logo => 'لوګو',
    CardFieldKind.photo => 'انځور',
    CardFieldKind.fullName => 'بشپړ نوم',
    CardFieldKind.fatherName => 'د پلار نوم',
    CardFieldKind.idNo => 'نمبر',
    CardFieldKind.className => 'ټولګی',
    CardFieldKind.jobTitle => 'دنده',
    CardFieldKind.year => 'درسي کال',
    CardFieldKind.expiry => 'د پای نېټه',
    CardFieldKind.phone => 'تلیفون',
    CardFieldKind.qr => 'QR کوډ',
    CardFieldKind.text => 'ثابت متن',
    CardFieldKind.box => 'رنګه څلورضلعی',
  };

  IconData get icon => switch (this) {
    CardFieldKind.schoolName => Icons.account_balance_rounded,
    CardFieldKind.logo => Icons.image_rounded,
    CardFieldKind.photo => Icons.person_rounded,
    CardFieldKind.fullName => Icons.badge_rounded,
    CardFieldKind.fatherName => Icons.family_restroom_rounded,
    CardFieldKind.idNo => Icons.tag_rounded,
    CardFieldKind.className => Icons.meeting_room_rounded,
    CardFieldKind.jobTitle => Icons.work_rounded,
    CardFieldKind.year => Icons.calendar_today_rounded,
    CardFieldKind.expiry => Icons.event_busy_rounded,
    CardFieldKind.phone => Icons.phone_rounded,
    CardFieldKind.qr => Icons.qr_code_2_rounded,
    CardFieldKind.text => Icons.title_rounded,
    CardFieldKind.box => Icons.rectangle_rounded,
  };

  /// انځور، QR او څلورضلعی اندازه لري؛ متن يې له فونټه اخلي.
  bool get isBox =>
      this == CardFieldKind.photo ||
      this == CardFieldKind.qr ||
      this == CardFieldKind.logo ||
      this == CardFieldKind.box;
}

/// یوه برخه پر کارت — ځای يې د کارت په سلنه کې دی، نه په پکسلونو.
///
/// **ولې سلنه؟** ځکه چې هماغه ډیزاین باید په پرده کې (۳۴۰px)، په
/// چاپ کې (۸۵.۶mm) او په یوه لوی مخکتنه کې یو شان ښکاره شي. که
/// پکسلونه ساتل کېدل، هر اندازه به يې بېل جوړښت غوښت.
class CardField {
  final CardFieldKind kind;

  /// ۰..۱ — د کارت له ښي پیله (RTL).
  final double x;
  final double y;

  /// **پلنوالی — او `0` یعنې «نه دی ټاکل شوی».**
  ///
  /// د متن لپاره «نه دی ټاکل شوی» یعنې تر کیڼې څنډې پورې غځېږي؛
  /// یو ټاکلی ارزښت يې بندوي، چې اوږد نوم د QR پر سر رانه شي.
  /// د بکس لپاره «نه دی ټاکل شوی» یوه معقوله تلواله اخلي — یو
  /// نالیدونکی بکس له یوه غلط بکسه بدتر دی.
  final double w;
  final double h;

  /// د متن اندازه، **د کارت د لوړوالي په سلنه کې**.
  final double fontScale;
  final bool bold;
  final int color;
  final String align;
  final String? text;
  final bool visible;

  const CardField({
    required this.kind,
    required this.x,
    required this.y,
    this.w = 0,
    this.h = 0,
    this.fontScale = 0.075,
    this.bold = false,
    this.color = 0xFF1B1F2A,
    this.align = 'start',
    this.text,
    this.visible = true,
  });

  CardField copyWith({
    double? x,
    double? y,
    double? w,
    double? h,
    double? fontScale,
    bool? bold,
    int? color,
    String? align,
    String? text,
    bool? visible,
  }) => CardField(
    kind: kind,
    x: x ?? this.x,
    y: y ?? this.y,
    w: w ?? this.w,
    h: h ?? this.h,
    fontScale: fontScale ?? this.fontScale,
    bold: bold ?? this.bold,
    color: color ?? this.color,
    align: align ?? this.align,
    text: text ?? this.text,
    visible: visible ?? this.visible,
  );

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    'x': x,
    'y': y,
    'w': w,
    'h': h,
    'fs': fontScale,
    'b': bold,
    'c': color,
    'a': align,
    if (text != null) 't': text,
    'v': visible,
  };

  static CardField fromJson(Map<String, Object?> j) => CardField(
    kind: CardFieldKind.values.firstWhere(
      (k) => k.name == j['kind'],
      orElse: () => CardFieldKind.text,
    ),
    x: (j['x'] as num?)?.toDouble() ?? 0,
    y: (j['y'] as num?)?.toDouble() ?? 0,
    w: (j['w'] as num?)?.toDouble() ?? 0,
    h: (j['h'] as num?)?.toDouble() ?? 0,
    fontScale: (j['fs'] as num?)?.toDouble() ?? 0.075,
    bold: j['b'] as bool? ?? false,
    color: (j['c'] as num?)?.toInt() ?? 0xFF1B1F2A,
    align: j['a'] as String? ?? 'start',
    text: j['t'] as String?,
    visible: j['v'] as bool? ?? true,
  );
}

/// **د یوې ساحې پلنوالی** — د متن او بکس دواړو لپاره، یو ځای.
///
/// **ولې یو ځای؟** ځکه چې پرده، ډیزاینر او چاپ درې واړه يې کاروي.
/// که هر یوه خپله حساب کاوه، یوه ورځ به يې توپیر کړی و — او مخکتنه
/// به له چاپه بېله شوې وه.
double fieldWidth(CardField f, double cardWidth) {
  if (f.w > 0) return f.w * cardWidth;
  if (f.kind.isBox) return 0.2 * cardWidth;
  return (1 - f.x) * cardWidth - 0.04 * cardWidth;
}

/// د یوې ساحې لوړوالی — یوازې بکسونه يې لري.
double fieldHeight(CardField f, double cardHeight) =>
    (f.h > 0 ? f.h : 0.2) * cardHeight;

/// د یوې ساحې اغېزناک پلنوالی، د کارت په نسبت (۰..۱).
///
/// د اندازې د بدلولو لپاره پکار دی: یوه ساحه چې `w == 0` وي، خپل
/// پلنوالی له ځایه اخلي — نو د کش کولو پیل باید هماغه شمېره وي، نه
/// یو صفر چې ساحه به يې سمدستي وړه کړې وه.
double fieldRatioW(CardField f) =>
    f.w > 0 ? f.w : (f.kind.isBox ? 0.2 : 0.2);

double fieldRatioH(CardField f) => f.h > 0 ? f.h : 0.2;

/// د پورتنۍ کرښې ځای — پاس، ښکته، یا کیڼ/ښي څنډه.
enum BandSide {
  top,
  bottom,
  side,
  none;

  String get label => switch (this) {
    BandSide.top => 'پاس',
    BandSide.bottom => 'ښکته',
    BandSide.side => 'څنډه',
    BandSide.none => 'نشته',
  };
}

/// د یوه کارت بشپړ ډیزاین.
class CardLayout {
  final int background;
  final int bandColor;

  /// د رنګه کرښې پنډوالی — ۰ يې پټوي.
  final double bandHeight;

  /// کرښه چېرې ده. **دا هغه څه دي چې دوه ډیزاینونه ریښتیا سره
  /// بېلوي** — نه یوازې رنګ. یو کارت چې کرښه يې ښکته وي، له هغه
  /// سره چې پاس يې لري، د یوه متره توپیر لري.
  final BandSide bandSide;

  /// دویم رنګ — د ګرادیانت لپاره. که `null` وي، یو رنګ.
  final int? bandColor2;

  final double cornerRadius;

  // ── د شالید انځور ───────────────────────────────────────
  //
  // **ولې انځور، نه یوازې رنګ؟** ځکه چې یو ښوونځی خپل نښان، یوه
  // نقشه، یا یوه اسلامي بڼه پر کارت غواړي. یو رنګ يې نه شي ورکولی.

  /// د انځور مسیر — که `null` وي، یوازې رنګ.
  final String? backgroundImage;

  /// `cover` | `contain` | `fill`
  final String backgroundFit;

  /// د انځور روڼوالی — ۰..۱.
  final double backgroundOpacity;

  /// **د انځور پر سر یو رنګه پرده.**
  ///
  /// پرته له دې، یو روښانه انځور به متن نالوستونکی کړ. دا هغه لار
  /// ده چې ډیزاینر پرې انځور ساتي خو متن لوستونکی پرېږدي.
  final int overlayColor;
  final double overlayOpacity;

  final List<CardField> fields;

  const CardLayout({
    this.background = 0xFFFFFFFF,
    this.bandColor = 0xFF4C5FD5,
    this.bandColor2,
    this.bandHeight = 0.22,
    this.bandSide = BandSide.top,
    this.cornerRadius = 0.07,
    this.backgroundImage,
    this.backgroundFit = 'cover',
    this.backgroundOpacity = 1.0,
    this.overlayColor = 0xFF000000,
    this.overlayOpacity = 0.0,
    this.fields = const [],
  });

  CardLayout copyWith({
    int? background,
    int? bandColor,
    int? bandColor2,
    double? bandHeight,
    BandSide? bandSide,
    double? cornerRadius,
    String? backgroundImage,
    String? backgroundFit,
    double? backgroundOpacity,
    int? overlayColor,
    double? overlayOpacity,
    List<CardField>? fields,
    bool clearBackgroundImage = false,
    bool clearBandColor2 = false,
  }) => CardLayout(
    background: background ?? this.background,
    bandColor: bandColor ?? this.bandColor,
    bandColor2: clearBandColor2 ? null : (bandColor2 ?? this.bandColor2),
    bandHeight: bandHeight ?? this.bandHeight,
    bandSide: bandSide ?? this.bandSide,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    backgroundImage: clearBackgroundImage
        ? null
        : (backgroundImage ?? this.backgroundImage),
    backgroundFit: backgroundFit ?? this.backgroundFit,
    backgroundOpacity: backgroundOpacity ?? this.backgroundOpacity,
    overlayColor: overlayColor ?? this.overlayColor,
    overlayOpacity: overlayOpacity ?? this.overlayOpacity,
    fields: fields ?? this.fields,
  );

  String encode() => jsonEncode({
    'bg': background,
    'band': bandColor,
    if (bandColor2 != null) 'band2': bandColor2,
    'bandH': bandHeight,
    'bandSide': bandSide.name,
    'radius': cornerRadius,
    if (backgroundImage != null) 'img': backgroundImage,
    'imgFit': backgroundFit,
    'imgOpacity': backgroundOpacity,
    'overlay': overlayColor,
    'overlayOpacity': overlayOpacity,
    'fields': [for (final f in fields) f.toJson()],
  });

  /// **خراب JSON یو تش کارت جوړوي، نه یوه ماته پاڼه.**
  ///
  /// یو ډیزاین چې له بل کمپیوټره راغلی وي، ښايي د یوې زړې نسخې
  /// وي. که دلته استثنا غورځېده، ټوله پاڼه به سره شوې وه — او
  /// مدیر به نه پوهېده چې کوم کارت يې خراب دی.
  static CardLayout decode(String? source) {
    if (source == null || source.trim().isEmpty) return const CardLayout();
    try {
      final j = jsonDecode(source) as Map<String, Object?>;
      return CardLayout(
        background: (j['bg'] as num?)?.toInt() ?? 0xFFFFFFFF,
        bandColor: (j['band'] as num?)?.toInt() ?? 0xFF4C5FD5,
        bandColor2: (j['band2'] as num?)?.toInt(),
        bandHeight: (j['bandH'] as num?)?.toDouble() ?? 0.22,
        bandSide: BandSide.values.firstWhere(
          (b) => b.name == j['bandSide'],
          orElse: () => BandSide.top,
        ),
        cornerRadius: (j['radius'] as num?)?.toDouble() ?? 0.07,
        backgroundImage: j['img'] as String?,
        backgroundFit: j['imgFit'] as String? ?? 'cover',
        backgroundOpacity: (j['imgOpacity'] as num?)?.toDouble() ?? 1.0,
        overlayColor: (j['overlay'] as num?)?.toInt() ?? 0xFF000000,
        overlayOpacity: (j['overlayOpacity'] as num?)?.toDouble() ?? 0.0,
        fields: [
          for (final f in (j['fields'] as List? ?? const []))
            CardField.fromJson(f as Map<String, Object?>),
        ],
      );
    } on Object {
      return const CardLayout();
    }
  }
}

// ═══════════════════════════════════════════════════════════
//  تلوالې کینډۍ
// ═══════════════════════════════════════════════════════════

/// د یوې کینډۍ پېژندنه — نوم، اوریدونکي او ډیزاین.
class BuiltInTemplate {
  final String key;
  final String name;

  /// د بڼې لنډه تشریح — چې کارن پوه شي څه توپیر لري، نه یوازې نوم.
  final String hint;

  /// `student` | `teacher` | `staff`
  final String audience;
  final CardLayout layout;

  /// **هره کینډۍ خپله اندازه لري.** یو عمودي ډیزاین په افقي کارت
  /// کې معنا نه لري — نو اندازه د ډیزاین برخه ده، نه یوه جلا ټاکنه
  /// چې کارن يې وروسته پخپله برابروي.
  final double widthMm;
  final double heightMm;

  const BuiltInTemplate({
    required this.key,
    required this.name,
    required this.audience,
    required this.layout,
    this.hint = '',
    this.widthMm = cr80WidthMm,
    this.heightMm = cr80HeightMm,
  });

  bool get isPortrait => heightMm > widthMm;
}

/// **درې ډلې، او هره یوه څو ریښتیني بېلې بڼې.**
///
/// **ولې «ریښتیني بېلې»؟** ځکه چې د یوه رنګ بدلول ډیزاین نه دی.
/// دلته د هرې کینډۍ **جوړښت** بېل دی: چېرې انځور دی، چېرې کرښه ده،
/// افقي ده که عمودي، QR لوی دی که کوچنی، متن ښي خوا دی که منځ.
/// یو مدیر چې دوه يې څنګ په څنګ وویني، باید له یوه متره توپیر
/// وپېژني — نه دا چې دوه رنګه ولولي.
const int _ink = 0xFF1B1F2A;
const int _white = 0xFFFFFFFF;
const int _muted = 0xFF667085;

/// ── جوړښت ۱: پورتنۍ کرښه، انځور ښي، متن منځ، QR کیڼ ──────────
CardLayout _bandTop({
  required int band,
  required String caption,
  required bool student,
  int background = 0xFFFFFFFF,
}) => CardLayout(
  background: background,
  bandColor: band,
  bandHeight: 0.26,
  fields: [
    const CardField(
      kind: CardFieldKind.schoolName,
      x: 0.05,
      y: 0.055,
      w: 0.9,
      fontScale: 0.1,
      bold: true,
      color: _white,
    ),
    CardField(
      kind: CardFieldKind.text,
      text: caption,
      x: 0.05,
      y: 0.165,
      w: 0.9,
      fontScale: 0.068,
      color: 0xCCFFFFFF,
    ),
    const CardField(
      kind: CardFieldKind.photo,
      x: 0.05,
      y: 0.33,
      w: 0.2,
      h: 0.46,
    ),
    const CardField(
      kind: CardFieldKind.fullName,
      x: 0.29,
      y: 0.34,
      w: 0.44,
      fontScale: 0.11,
      bold: true,
      color: _ink,
    ),
    CardField(
      kind: student ? CardFieldKind.className : CardFieldKind.jobTitle,
      x: 0.29,
      y: 0.47,
      w: 0.44,
      fontScale: 0.075,
      color: band,
    ),
    const CardField(
      kind: CardFieldKind.idNo,
      x: 0.29,
      y: 0.59,
      w: 0.44,
      fontScale: 0.075,
      color: _muted,
    ),
    const CardField(
      kind: CardFieldKind.expiry,
      x: 0.29,
      y: 0.71,
      w: 0.44,
      fontScale: 0.062,
      color: 0xFF98A2B3,
    ),
    const CardField(
      kind: CardFieldKind.qr,
      x: 0.76,
      y: 0.42,
      w: 0.19,
      h: 0.42,
    ),
  ],
);

/// ── جوړښت ۲: د ښي څنډې پټه، پرته له پورتنۍ کرښې ─────────────
CardLayout _sideStripe({
  required int band,
  required bool student,
}) => CardLayout(
  background: 0xFFF8FAFC,
  bandColor: band,
  bandHeight: 0.075,
  bandSide: BandSide.side,
  cornerRadius: 0.05,
  fields: [
    CardField(
      kind: CardFieldKind.schoolName,
      x: 0.12,
      y: 0.09,
      w: 0.6,
      fontScale: 0.088,
      bold: true,
      color: band,
    ),
    const CardField(
      kind: CardFieldKind.photo,
      x: 0.12,
      y: 0.29,
      w: 0.19,
      h: 0.45,
    ),
    const CardField(
      kind: CardFieldKind.fullName,
      x: 0.34,
      y: 0.31,
      w: 0.42,
      fontScale: 0.1,
      bold: true,
      color: _ink,
    ),
    CardField(
      kind: student ? CardFieldKind.className : CardFieldKind.jobTitle,
      x: 0.35,
      y: 0.45,
      w: 0.38,
      fontScale: 0.068,
      color: band,
    ),
    const CardField(
      kind: CardFieldKind.idNo,
      x: 0.35,
      y: 0.57,
      w: 0.38,
      fontScale: 0.068,
      color: 0xFF475569,
    ),
    const CardField(
      kind: CardFieldKind.expiry,
      x: 0.35,
      y: 0.69,
      w: 0.38,
      fontScale: 0.058,
      color: 0xFF94A3B8,
    ),
    const CardField(
      kind: CardFieldKind.qr,
      x: 0.78,
      y: 0.3,
      w: 0.17,
      h: 0.38,
    ),
  ],
);

/// ── جوړښت ۳: عمودي — انځور پاس منځ، هرڅه منځ‌ته ──────────────
///
/// **دا هغه بڼه ده چې لاسبند ته ځي.** د غاړې کارت عمودي دی، نو
/// افقي ډیزاین پکې ۹۰ درجې کوږ ښکاري.
CardLayout _portrait({
  required int band,
  required String caption,
  required bool student,
}) => CardLayout(
  background: 0xFFFFFFFF,
  bandColor: band,
  bandHeight: 0.2,
  cornerRadius: 0.045,
  fields: [
    const CardField(
      kind: CardFieldKind.schoolName,
      x: 0.08,
      y: 0.045,
      w: 0.84,
      fontScale: 0.045,
      bold: true,
      color: _white,
      align: 'center',
    ),
    CardField(
      kind: CardFieldKind.text,
      text: caption,
      x: 0.08,
      y: 0.105,
      w: 0.84,
      fontScale: 0.033,
      color: 0xCCFFFFFF,
      align: 'center',
    ),
    const CardField(
      kind: CardFieldKind.photo,
      x: 0.3,
      y: 0.235,
      w: 0.4,
      h: 0.26,
    ),
    const CardField(
      kind: CardFieldKind.fullName,
      x: 0.06,
      y: 0.53,
      w: 0.88,
      fontScale: 0.055,
      bold: true,
      color: _ink,
      align: 'center',
    ),
    CardField(
      kind: student ? CardFieldKind.className : CardFieldKind.jobTitle,
      x: 0.06,
      y: 0.595,
      w: 0.88,
      fontScale: 0.036,
      color: band,
      align: 'center',
    ),
    const CardField(
      kind: CardFieldKind.idNo,
      x: 0.06,
      y: 0.65,
      w: 0.88,
      fontScale: 0.036,
      color: _muted,
      align: 'center',
    ),
    const CardField(
      kind: CardFieldKind.qr,
      x: 0.33,
      y: 0.71,
      w: 0.34,
      h: 0.21,
    ),
    const CardField(
      kind: CardFieldKind.expiry,
      x: 0.06,
      y: 0.94,
      w: 0.88,
      fontScale: 0.03,
      color: 0xFF98A2B3,
      align: 'center',
    ),
  ],
);

/// ── جوړښت ۴: انځور نیم کارت نیسي، متن پرې ─────────────────────
///
/// د انځور پر سر یوه تیاره پرده — نو متن لوستل کېږي، خو مخ لا هم
/// د کارت اصلي برخه ده.
CardLayout _photoHero({required int band, required bool student}) =>
    CardLayout(
      background: 0xFF15202B,
      bandColor: band,
      bandHeight: 0.055,
      bandSide: BandSide.bottom,
      cornerRadius: 0.06,
      fields: [
        const CardField(
          kind: CardFieldKind.photo,
          x: 0.0,
          y: 0.0,
          w: 0.42,
          h: 1.0,
        ),
        CardField(
          kind: CardFieldKind.schoolName,
          x: 0.46,
          y: 0.1,
          w: 0.48,
          fontScale: 0.072,
          bold: true,
          color: band,
        ),
        const CardField(
          kind: CardFieldKind.fullName,
          x: 0.46,
          y: 0.26,
          w: 0.48,
          fontScale: 0.115,
          bold: true,
          color: _white,
        ),
        CardField(
          kind: student ? CardFieldKind.className : CardFieldKind.jobTitle,
          x: 0.46,
          y: 0.41,
          w: 0.48,
          fontScale: 0.068,
          color: 0xFF94A3B8,
        ),
        const CardField(
          kind: CardFieldKind.idNo,
          x: 0.46,
          y: 0.52,
          w: 0.28,
          fontScale: 0.075,
          bold: true,
          color: _white,
        ),
        const CardField(
          kind: CardFieldKind.expiry,
          x: 0.46,
          y: 0.64,
          w: 0.28,
          fontScale: 0.055,
          color: 0xFF64748B,
        ),
        const CardField(
          kind: CardFieldKind.qr,
          x: 0.76,
          y: 0.5,
          w: 0.18,
          h: 0.36,
          color: 0xFF15202B,
        ),
      ],
    );

/// ── جوړښت ۵: ساده — هېڅ ښکلا، یوازې لوی متن او لوی QR ────────
CardLayout _minimal({required int band, required bool student}) => CardLayout(
  background: 0xFFFFFFFF,
  bandColor: band,
  bandHeight: 0.0,
  bandSide: BandSide.none,
  cornerRadius: 0.06,
  fields: [
    const CardField(
      kind: CardFieldKind.schoolName,
      x: 0.06,
      y: 0.09,
      w: 0.6,
      fontScale: 0.072,
      color: _muted,
    ),
    const CardField(
      kind: CardFieldKind.fullName,
      x: 0.06,
      y: 0.26,
      w: 0.6,
      fontScale: 0.14,
      bold: true,
      color: _ink,
    ),
    CardField(
      kind: student ? CardFieldKind.className : CardFieldKind.jobTitle,
      x: 0.06,
      y: 0.46,
      w: 0.6,
      fontScale: 0.068,
      color: band,
    ),
    const CardField(
      kind: CardFieldKind.idNo,
      x: 0.06,
      y: 0.62,
      w: 0.6,
      fontScale: 0.095,
      bold: true,
      color: _ink,
    ),
    const CardField(
      kind: CardFieldKind.expiry,
      x: 0.06,
      y: 0.8,
      w: 0.6,
      fontScale: 0.058,
      color: 0xFF98A2B3,
    ),
    const CardField(
      kind: CardFieldKind.qr,
      x: 0.7,
      y: 0.26,
      w: 0.24,
      h: 0.49,
    ),
  ],
);

/// ── جوړښت ۶: ګرادیانت شالید، سپین متن، QR کیڼ ښکته ───────────
CardLayout _gradient({
  required int from,
  required int to,
  required bool student,
}) => CardLayout(
  background: from,
  bandColor: from,
  bandColor2: to,
  bandHeight: 1.0,
  cornerRadius: 0.07,
  fields: [
    const CardField(
      kind: CardFieldKind.schoolName,
      x: 0.06,
      y: 0.08,
      w: 0.55,
      fontScale: 0.085,
      bold: true,
      color: _white,
    ),
    const CardField(
      kind: CardFieldKind.photo,
      x: 0.72,
      y: 0.08,
      w: 0.22,
      h: 0.5,
    ),
    const CardField(
      kind: CardFieldKind.fullName,
      x: 0.06,
      y: 0.36,
      w: 0.6,
      fontScale: 0.12,
      bold: true,
      color: _white,
    ),
    CardField(
      kind: student ? CardFieldKind.className : CardFieldKind.jobTitle,
      x: 0.06,
      y: 0.52,
      w: 0.6,
      fontScale: 0.068,
      color: 0xCCFFFFFF,
    ),
    const CardField(
      kind: CardFieldKind.idNo,
      x: 0.06,
      y: 0.64,
      w: 0.4,
      fontScale: 0.08,
      bold: true,
      color: _white,
    ),
    const CardField(
      kind: CardFieldKind.expiry,
      x: 0.06,
      y: 0.79,
      w: 0.4,
      fontScale: 0.055,
      color: 0x99FFFFFF,
    ),
    const CardField(
      kind: CardFieldKind.qr,
      x: 0.72,
      y: 0.63,
      w: 0.22,
      h: 0.28,
      color: 0xFF1B1F2A,
    ),
  ],
);

/// د هرې ډلې کینډۍ. **د هرې ډلې خپل رنګ او خپل بېل جوړښتونه.**
List<BuiltInTemplate> builtInCardTemplates(String audience) {
  final student = audience == 'student';
  final (band, caption, second) = switch (audience) {
    'teacher' => (0xFF0E9F6E, 'د استاد کارت', 0xFF047857),
    'staff' => (0xFFD97706, 'د کارمند کارت', 0xFFB45309),
    _ => (0xFF4C5FD5, 'د شاګرد کارت', 0xFF7C3AED),
  };
  final prefix = audience == 'teacher'
      ? 'teacher'
      : (audience == 'staff' ? 'staff' : 'student');

  return [
    BuiltInTemplate(
      key: '$prefix-band',
      name: 'پورتنۍ کرښه',
      hint: 'انځور ښي، متن منځ، QR کیڼ',
      audience: audience,
      layout: _bandTop(band: band, caption: caption, student: student),
    ),
    BuiltInTemplate(
      key: '$prefix-stripe',
      name: 'څنډه',
      hint: 'د ښي څنډې پټه، پرته له پورتنۍ کرښې',
      audience: audience,
      layout: _sideStripe(band: band, student: student),
    ),
    BuiltInTemplate(
      key: '$prefix-photo',
      name: 'انځور مخکې',
      hint: 'انځور نیم کارت نیسي، تیاره شالید',
      audience: audience,
      layout: _photoHero(band: band, student: student),
    ),
    BuiltInTemplate(
      key: '$prefix-gradient',
      name: 'ګرادیانت',
      hint: 'رنګین شالید، سپین متن',
      audience: audience,
      layout: _gradient(from: band, to: second, student: student),
    ),
    BuiltInTemplate(
      key: '$prefix-minimal',
      name: 'ساده',
      hint: 'هېڅ ښکلا — لوی نوم، لوی QR',
      audience: audience,
      layout: _minimal(band: band, student: student),
    ),
    BuiltInTemplate(
      key: '$prefix-portrait',
      name: 'عمودي',
      hint: 'د غاړې لاسبند لپاره — هرڅه منځ‌ته',
      audience: audience,
      layout: _portrait(band: band, caption: caption, student: student),
      widthMm: cr80HeightMm,
      heightMm: cr80WidthMm,
    ),
  ];
}


/// **د معیاري کارت اندازه — CR80.**
///
/// دا هماغه د بانک د کارت اندازه ده، نو معیاري کارت‌ساتونکي،
/// لاسبندونه او پرنټرونه ورسره کار کوي.
const double cr80WidthMm = 85.6;
const double cr80HeightMm = 54.0;

/// **چاپ هېڅکله له معیاري اندازې کوچنی نه شي.**
///
/// یو ډیزاینر ښايي «۶۰ × ۴۰» ولیکي چې په یوه پاڼه کې زیات کارتونه
/// ځای شي. خو هغه کارت به په هېڅ کارت‌ساتونکي کې نه ځایېده او QR
/// به يې د سکینر لپاره ډېر کوچنی و. نو د چاپ پر مهال اندازه تل
/// لږ تر لږه CR80 ته پورته کېږي — **نسبت ساتل کېږي**، نو ډیزاین
/// نه ماتېږي، یوازې لوی شي.
({double width, double height}) printSize({
  required double widthMm,
  required double heightMm,
}) {
  if (widthMm <= 0 || heightMm <= 0) {
    return (width: cr80WidthMm, height: cr80HeightMm);
  }
  final scale = [
    cr80WidthMm / widthMm,
    cr80HeightMm / heightMm,
    1.0,
  ].reduce((a, b) => a > b ? a : b);
  return (width: widthMm * scale, height: heightMm * scale);
}
