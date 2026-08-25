import 'package:flutter/material.dart';

/// د موبایل اپ رنګ، فونټ او انیمیشن.
///
/// **د تکرار په اړه یو ټکی:** دا پالېټ د ډیسکټاپ له
/// `desktop/lib/core/theme/app_colors.dart` سره یو دی. لا مې د یوه
/// ګډ پیکج (`packages/core_ui`) په بڼه نه دی راایستلی، ځکه چې
/// ډیسکټاپ پر `window_manager` او `file_selector` تکیه کوي — هغه د
/// اندروید build ماتوي. کله چې څلورم پړاو د API کلاینټ راولي (چې
/// دواړو ته پکار دی)، هغه مهال ګډ پیکج جوړېږي او دا فایل ورکېږي.
class M {
  const M._();

  static const Color primary = Color(0xFF5B4BE8);
  static const Color primaryLight = Color(0xFF8A7DFF);
  static const Color accent = Color(0xFFFFB020);

  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFF43F5E);
  static const Color info = Color(0xFF0EA5E9);

  static const List<Color> gradIndigo = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> gradEmerald = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> gradRose = [Color(0xFFF43F5E), Color(0xFFE11D48)];
  static const List<Color> gradAmber = [Color(0xFFF59E0B), Color(0xFFD97706)];

  static const String fontFamily = 'Vazirmatn';
  static const double radius = 14;
  static const double radiusLg = 20;

  static const Duration fast = Duration(milliseconds: 160);
  static const Duration normal = Duration(milliseconds: 220);
  static const Curve ease = Cubic(0.22, 0.61, 0.36, 1.0);
}

@immutable
class MPalette extends ThemeExtension<MPalette> {
  final Color ground;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color faint;
  final Color line;

  const MPalette({
    required this.ground,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.faint,
    required this.line,
  });

  static const MPalette light = MPalette(
    ground: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F3F9),
    ink: Color(0xFF141726),
    inkSoft: Color(0xFF3D4257),
    muted: Color(0xFF6B7189),
    faint: Color(0xFF9AA0B4),
    line: Color(0xFFE3E6EF),
  );

  static const MPalette dark = MPalette(
    ground: Color(0xFF0E1017),
    surface: Color(0xFF161A24),
    surfaceAlt: Color(0xFF1D222E),
    ink: Color(0xFFECEEF5),
    inkSoft: Color(0xFFC5CADB),
    muted: Color(0xFF8E95AB),
    faint: Color(0xFF636A80),
    line: Color(0xFF262C3A),
  );

  @override
  MPalette copyWith({
    Color? ground,
    Color? surface,
    Color? surfaceAlt,
    Color? ink,
    Color? inkSoft,
    Color? muted,
    Color? faint,
    Color? line,
  }) => MPalette(
    ground: ground ?? this.ground,
    surface: surface ?? this.surface,
    surfaceAlt: surfaceAlt ?? this.surfaceAlt,
    ink: ink ?? this.ink,
    inkSoft: inkSoft ?? this.inkSoft,
    muted: muted ?? this.muted,
    faint: faint ?? this.faint,
    line: line ?? this.line,
  );

  @override
  MPalette lerp(ThemeExtension<MPalette>? other, double t) {
    if (other is! MPalette) return this;
    return MPalette(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      line: Color.lerp(line, other.line, t)!,
    );
  }
}

extension MPaletteX on BuildContext {
  MPalette get pal => Theme.of(this).extension<MPalette>()!;
}

ThemeData buildMobileTheme(Brightness b) {
  final p = b == Brightness.dark ? MPalette.dark : MPalette.light;
  final isDark = b == Brightness.dark;

  return ThemeData(
    useMaterial3: true,
    brightness: b,
    fontFamily: M.fontFamily,
    scaffoldBackgroundColor: p.ground,
    extensions: [p],
    colorScheme: ColorScheme.fromSeed(seedColor: M.primary, brightness: b)
        .copyWith(
          primary: isDark ? M.primaryLight : M.primary,
          secondary: M.accent,
          error: M.danger,
          surface: p.surface,
        ),
    dividerTheme: DividerThemeData(color: p.line, thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(M.radius),
        borderSide: BorderSide(color: p.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(M.radius),
        borderSide: BorderSide(color: p.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(M.radius),
        borderSide: BorderSide(
          color: isDark ? M.primaryLight : M.primary,
          width: 1.6,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: M.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(M.radius),
        ),
        // د ډیسکټاپ په څېر: `styleFrom` د ټیم فونټ نه میراثوي، نو
        // په ډاګه يې ورکوو — که نه، پښتو متن چوکاټونه ښیي.
        textStyle: const TextStyle(
          fontFamily: M.fontFamily,
          fontWeight: FontWeight.w700,
          fontSize: 15,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.inkSoft,
        minimumSize: const Size.fromHeight(50),
        side: BorderSide(color: p.line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(M.radius),
        ),
        textStyle: const TextStyle(
          fontFamily: M.fontFamily,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: p.surface,
      indicatorColor: M.primary.withValues(alpha: 0.13),
      surfaceTintColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(
          fontFamily: M.fontFamily,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: p.inkSoft,
        ),
      ),
    ),
  );
}
