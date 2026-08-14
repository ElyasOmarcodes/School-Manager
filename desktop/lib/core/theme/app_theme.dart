import 'package:flutter/material.dart';

import 'app_colors.dart';

/// د پروګرام بشپړ ټیم — روښانه او تیاره.
///
/// فونټ: Vazirmatn — د پښتو، دري او عربي لپاره روښانه او پرمختللی،
/// او لاتیني توري يې هم سم دي نو د یوه فونټ سره ټول UI پوښل کېږي.
///
/// **مهم:** فونټ له پروګرام سره بسته شوی (`pubspec.yaml`)، نه له
/// انټرنټه راښکل کېږي. که د `google_fonts` له لارې وای، په هغه
/// ښوونځي کې چې انټرنټ نه لري، متن به بل فونټ ته لوېدلی و.
class AppTheme {
  const AppTheme._();

  static const String fontFamily = 'Vazirmatn';

  static const double radiusSm = 8;
  static const double radius = 12;
  static const double radiusLg = 18;

  static TextTheme _text(Brightness b) {
    final p = AppPalette.from(b);
    final base = ThemeData(brightness: b).textTheme.apply(
          fontFamily: fontFamily,
        );
    return base.apply(bodyColor: p.ink, displayColor: p.ink).copyWith(
          displaySmall: base.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: p.ink,
          ),
          headlineMedium: base.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
            color: p.ink,
          ),
          titleLarge: base.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: p.ink,
          ),
          titleMedium: base.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: p.ink,
          ),
          bodyMedium: base.bodyMedium?.copyWith(
            height: 1.7,
            color: p.inkSoft,
          ),
          bodySmall: base.bodySmall?.copyWith(
            height: 1.6,
            color: p.muted,
          ),
          labelSmall: base.labelSmall?.copyWith(
            letterSpacing: 0.4,
            color: p.muted,
          ),
        );
  }

  /// د شمېرو لپاره — چې په جدولونو کې ستنې سمې ولاړې وي.
  static TextStyle tabular(TextStyle? s) => (s ?? const TextStyle()).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      );

  static ThemeData build(Brightness brightness) {
    final p = AppPalette.from(brightness);
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: p.ground,
      canvasColor: p.surface,
      extensions: [p],
      textTheme: _text(brightness),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: brightness,
      ).copyWith(
        primary: isDark ? AppColors.primaryLight : AppColors.primary,
        secondary: AppColors.accent,
        error: AppColors.danger,
        surface: p.surface,
      ),
      dividerTheme: DividerThemeData(
        color: p.line,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardTheme(
        color: p.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: p.line),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surfaceAlt,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: p.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(color: p.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: BorderSide(
            color: isDark ? AppColors.primaryLight : AppColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusSm),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        hintStyle: TextStyle(color: p.faint),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
          // `fontFamily` دلته باید په ډاګه ولیکل شي. د `styleFrom`
          // له لارې ورکړل شوی TextStyle د ټیم فونټ نه میراثوي، نو
          // پرته له دې د تڼیو پښتو متن چوکاټونه ښیي.
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.inkSoft,
          side: BorderSide(color: p.lineStrong),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        waitDuration: const Duration(milliseconds: 450),
        decoration: BoxDecoration(
          color: isDark ? p.surfaceAlt : p.ink,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          color: isDark ? p.ink : Colors.white,
          fontSize: 12,
        ),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(p.lineStrong),
        radius: const Radius.circular(8),
        thickness: const WidgetStatePropertyAll(8),
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
