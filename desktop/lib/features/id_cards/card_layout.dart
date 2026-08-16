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

/// د یوه کارت بشپړ ډیزاین.
class CardLayout {
  final int background;
  final int bandColor;

  /// د پورتنۍ رنګه کرښې لوړوالی — ۰ يې پټوي.
  final double bandHeight;
  final double cornerRadius;
  final List<CardField> fields;

  const CardLayout({
    this.background = 0xFFFFFFFF,
    this.bandColor = 0xFF4C5FD5,
    this.bandHeight = 0.22,
    this.cornerRadius = 0.07,
    this.fields = const [],
  });

  CardLayout copyWith({
    int? background,
    int? bandColor,
    double? bandHeight,
    double? cornerRadius,
    List<CardField>? fields,
  }) => CardLayout(
    background: background ?? this.background,
    bandColor: bandColor ?? this.bandColor,
    bandHeight: bandHeight ?? this.bandHeight,
    cornerRadius: cornerRadius ?? this.cornerRadius,
    fields: fields ?? this.fields,
  );

  String encode() => jsonEncode({
    'bg': background,
    'band': bandColor,
    'bandH': bandHeight,
    'radius': cornerRadius,
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
        bandHeight: (j['bandH'] as num?)?.toDouble() ?? 0.22,
        cornerRadius: (j['radius'] as num?)?.toDouble() ?? 0.07,
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

  /// `student` | `teacher` | `staff`
  final String audience;
  final CardLayout layout;

  const BuiltInTemplate({
    required this.key,
    required this.name,
    required this.audience,
    required this.layout,
  });
}

/// **درې ډلې، هره یوه خپله بڼه.**
///
/// **ولې بېلې؟** ځکه چې د دروازې ساتونکی باید له یوه متره وپېژني
/// چې دا د استاد کارت دی که د شاګرد. که درې واړه یو رنګ وو، هغه
/// به يې لوستلو ته اړ و — او د سهار په ګڼه ګوڼه کې هېڅوک نه لولي.
const int _studentInk = 0xFF1B1F2A;
const int _white = 0xFFFFFFFF;

List<BuiltInTemplate> builtInTemplates(String audience) => switch (audience) {
  'teacher' => const [
    BuiltInTemplate(
      key: 'teacher-emerald',
      name: 'شنه کرښه',
      audience: 'teacher',
      layout: CardLayout(
        background: 0xFFFFFFFF,
        bandColor: 0xFF0E9F6E,
        bandHeight: 0.26,
        fields: [
          CardField(
            kind: CardFieldKind.schoolName,
            x: 0.05,
            y: 0.06,
            fontScale: 0.1,
            bold: true,
            color: _white,
          ),
          CardField(
            kind: CardFieldKind.text,
            text: 'د استاد کارت',
            x: 0.05,
            y: 0.17,
            fontScale: 0.07,
            color: 0xCCFFFFFF,
          ),
          CardField(
            kind: CardFieldKind.photo,
            x: 0.05,
            y: 0.33,
            w: 0.2,
            h: 0.46,
          ),
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.29,
            y: 0.34,
            w: 0.44,
            fontScale: 0.11,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.jobTitle,
            x: 0.29,
            y: 0.47,
            w: 0.44,
            fontScale: 0.075,
            color: 0xFF0E9F6E,
          ),
          CardField(
            kind: CardFieldKind.idNo,
            x: 0.29,
            y: 0.59,
            w: 0.44,
            fontScale: 0.075,
            color: 0xFF667085,
          ),
          CardField(
            kind: CardFieldKind.expiry,
            x: 0.29,
            y: 0.71,
            w: 0.44,
            fontScale: 0.065,
            color: 0xFF98A2B3,
          ),
          CardField(
            kind: CardFieldKind.qr,
            x: 0.76,
            y: 0.42,
            w: 0.19,
            h: 0.42,
          ),
        ],
      ),
    ),
    BuiltInTemplate(
      key: 'teacher-slate',
      name: 'تیاره',
      audience: 'teacher',
      layout: CardLayout(
        background: 0xFF15202B,
        bandColor: 0xFF0E9F6E,
        bandHeight: 0.06,
        fields: [
          CardField(
            kind: CardFieldKind.schoolName,
            x: 0.05,
            y: 0.13,
            fontScale: 0.085,
            bold: true,
            color: _white,
          ),
          CardField(
            kind: CardFieldKind.photo,
            x: 0.05,
            y: 0.3,
            w: 0.21,
            h: 0.5,
          ),
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.3,
            y: 0.33,
            w: 0.44,
            fontScale: 0.12,
            bold: true,
            color: _white,
          ),
          CardField(
            kind: CardFieldKind.jobTitle,
            x: 0.3,
            y: 0.48,
            w: 0.44,
            fontScale: 0.075,
            color: 0xFF34D399,
          ),
          CardField(
            kind: CardFieldKind.idNo,
            x: 0.3,
            y: 0.6,
            w: 0.44,
            fontScale: 0.07,
            color: 0xFF94A3B8,
          ),
          CardField(
            kind: CardFieldKind.expiry,
            x: 0.3,
            y: 0.72,
            w: 0.44,
            fontScale: 0.062,
            color: 0xFF64748B,
          ),
          CardField(
            kind: CardFieldKind.qr,
            x: 0.77,
            y: 0.4,
            w: 0.18,
            h: 0.4,
          ),
        ],
      ),
    ),
  ],
  'staff' => const [
    BuiltInTemplate(
      key: 'staff-amber',
      name: 'نارنجي کرښه',
      audience: 'staff',
      layout: CardLayout(
        background: 0xFFFFFFFF,
        bandColor: 0xFFD97706,
        bandHeight: 0.26,
        fields: [
          CardField(
            kind: CardFieldKind.schoolName,
            x: 0.05,
            y: 0.06,
            fontScale: 0.1,
            bold: true,
            color: _white,
          ),
          CardField(
            kind: CardFieldKind.text,
            text: 'د کارمند کارت',
            x: 0.05,
            y: 0.17,
            fontScale: 0.07,
            color: 0xCCFFFFFF,
          ),
          CardField(
            kind: CardFieldKind.photo,
            x: 0.05,
            y: 0.33,
            w: 0.2,
            h: 0.46,
          ),
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.29,
            y: 0.34,
            w: 0.44,
            fontScale: 0.11,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.jobTitle,
            x: 0.29,
            y: 0.47,
            w: 0.44,
            fontScale: 0.075,
            color: 0xFFD97706,
          ),
          CardField(
            kind: CardFieldKind.idNo,
            x: 0.29,
            y: 0.59,
            w: 0.44,
            fontScale: 0.075,
            color: 0xFF667085,
          ),
          CardField(
            kind: CardFieldKind.expiry,
            x: 0.29,
            y: 0.71,
            w: 0.44,
            fontScale: 0.065,
            color: 0xFF98A2B3,
          ),
          CardField(
            kind: CardFieldKind.qr,
            x: 0.76,
            y: 0.42,
            w: 0.19,
            h: 0.42,
          ),
        ],
      ),
    ),
  ],
  _ => const [
    BuiltInTemplate(
      key: 'student-indigo',
      name: 'نیلي کرښه',
      audience: 'student',
      layout: CardLayout(
        background: 0xFFFFFFFF,
        bandColor: 0xFF4C5FD5,
        bandHeight: 0.26,
        fields: [
          CardField(
            kind: CardFieldKind.schoolName,
            x: 0.05,
            y: 0.06,
            fontScale: 0.1,
            bold: true,
            color: _white,
          ),
          CardField(
            kind: CardFieldKind.text,
            text: 'د شاګرد کارت',
            x: 0.05,
            y: 0.17,
            fontScale: 0.07,
            color: 0xCCFFFFFF,
          ),
          CardField(
            kind: CardFieldKind.photo,
            x: 0.05,
            y: 0.33,
            w: 0.2,
            h: 0.46,
          ),
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.29,
            y: 0.33,
            w: 0.44,
            fontScale: 0.11,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.fatherName,
            x: 0.29,
            y: 0.45,
            w: 0.44,
            fontScale: 0.07,
            color: 0xFF667085,
          ),
          CardField(
            kind: CardFieldKind.className,
            x: 0.29,
            y: 0.56,
            w: 0.44,
            fontScale: 0.075,
            color: 0xFF4C5FD5,
          ),
          CardField(
            kind: CardFieldKind.idNo,
            x: 0.29,
            y: 0.68,
            w: 0.44,
            fontScale: 0.075,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.expiry,
            x: 0.29,
            y: 0.8,
            w: 0.44,
            fontScale: 0.062,
            color: 0xFF98A2B3,
          ),
          CardField(
            kind: CardFieldKind.qr,
            x: 0.76,
            y: 0.42,
            w: 0.19,
            h: 0.42,
          ),
        ],
      ),
    ),
    BuiltInTemplate(
      key: 'student-sky',
      name: 'اسماني څنډه',
      audience: 'student',
      layout: CardLayout(
        background: 0xFFF8FAFC,
        bandColor: 0xFF0284C7,
        bandHeight: 0.0,
        fields: [
          CardField(
            kind: CardFieldKind.box,
            x: 0.0,
            y: 0.0,
            w: 0.075,
            h: 1.0,
            color: 0xFF0284C7,
          ),
          CardField(
            kind: CardFieldKind.schoolName,
            x: 0.12,
            y: 0.08,
            fontScale: 0.09,
            bold: true,
            color: 0xFF0C4A6E,
          ),
          CardField(
            kind: CardFieldKind.photo,
            x: 0.12,
            y: 0.28,
            w: 0.19,
            h: 0.45,
          ),
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.35,
            y: 0.3,
            w: 0.38,
            fontScale: 0.105,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.className,
            x: 0.35,
            y: 0.44,
            w: 0.38,
            fontScale: 0.07,
            color: 0xFF0284C7,
          ),
          CardField(
            kind: CardFieldKind.idNo,
            x: 0.35,
            y: 0.56,
            w: 0.38,
            fontScale: 0.07,
            color: 0xFF475569,
          ),
          CardField(
            kind: CardFieldKind.expiry,
            x: 0.35,
            y: 0.68,
            w: 0.38,
            fontScale: 0.06,
            color: 0xFF94A3B8,
          ),
          CardField(
            kind: CardFieldKind.qr,
            x: 0.76,
            y: 0.3,
            w: 0.18,
            h: 0.4,
          ),
        ],
      ),
    ),
    BuiltInTemplate(
      key: 'student-minimal',
      name: 'ساده',
      audience: 'student',
      layout: CardLayout(
        background: 0xFFFFFFFF,
        bandColor: 0xFF1B1F2A,
        bandHeight: 0.0,
        fields: [
          CardField(
            kind: CardFieldKind.schoolName,
            x: 0.06,
            y: 0.09,
            fontScale: 0.075,
            color: 0xFF667085,
          ),
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.06,
            y: 0.26,
            w: 0.6,
            fontScale: 0.14,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.className,
            x: 0.06,
            y: 0.45,
            w: 0.6,
            fontScale: 0.07,
            color: 0xFF667085,
          ),
          CardField(
            kind: CardFieldKind.idNo,
            x: 0.06,
            y: 0.62,
            w: 0.6,
            fontScale: 0.095,
            bold: true,
            color: _studentInk,
          ),
          CardField(
            kind: CardFieldKind.expiry,
            x: 0.06,
            y: 0.8,
            w: 0.6,
            fontScale: 0.06,
            color: 0xFF98A2B3,
          ),
          CardField(
            kind: CardFieldKind.qr,
            x: 0.72,
            y: 0.28,
            w: 0.22,
            h: 0.49,
          ),
        ],
      ),
    ),
  ],
};

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
