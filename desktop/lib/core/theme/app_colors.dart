import 'package:flutter/material.dart';

/// د رنګونو بشپړ سیسټم — روښانه او تیاره دواړه حالتونه.
///
/// د رنګ فلسفه: تعلیمي سافټویر باید ژوندی وي، خو نه ستړی کوونکی.
/// نو ځمکه (background) ارامه ساتو او رنګ د هر ماډل په نښه او
/// د KPI کارتونو کې کاروو — دا هغه څه دي چې سترګې پرې لار مومي.
class AppColors {
  const AppColors._();

  // ── برانډ ───────────────────────────────────────────────
  static const Color primary = Color(0xFF5B4BE8); // بنفش-نیلي
  static const Color primaryDark = Color(0xFF4436C7);
  static const Color primaryLight = Color(0xFF8A7DFF);
  static const Color accent = Color(0xFFFFB020); // طلایي

  // ── معنايي (semantic) ───────────────────────────────────
  static const Color success = Color(0xFF10B981); // حاضر
  static const Color warning = Color(0xFFF59E0B); // ناوخته
  static const Color danger = Color(0xFFF43F5E); // غیرحاضر
  static const Color info = Color(0xFF0EA5E9); // رخصت

  // ── د ماډلونو رنګونه ────────────────────────────────────
  // هر ماډل خپل رنګ لري چې مدیر يې په یوه نظر وپېژني.
  static const Color modStudents = Color(0xFF5B4BE8);
  static const Color modAttendance = Color(0xFF10B981);
  static const Color modLeave = Color(0xFF0EA5E9);
  static const Color modTeachers = Color(0xFFEC4899);
  static const Color modStaff = Color(0xFF8B5CF6);
  static const Color modClasses = Color(0xFFF97316);
  static const Color modSubjects = Color(0xFFB45309);
  static const Color modTimetable = Color(0xFF06B6D4);
  static const Color modExams = Color(0xFFEF4444);
  static const Color modReports = Color(0xFF14B8A6);
  static const Color modFees = Color(0xFF22C55E);
  static const Color modPayroll = Color(0xFF84CC16);
  static const Color modLibrary = Color(0xFFA855F7);
  static const Color modTransport = Color(0xFFEAB308);
  static const Color modHostel = Color(0xFF6366F1);
  static const Color modInventory = Color(0xFF78716C);
  static const Color modHealth = Color(0xFFF43F5E);
  static const Color modDiscipline = Color(0xFFDC2626);
  static const Color modHifz = Color(0xFF059669);
  static const Color modMessages = Color(0xFF3B82F6);
  static const Color modCalendar = Color(0xFFD946EF);
  static const Color modIdCards = Color(0xFF0891B2);
  static const Color modUsers = Color(0xFF7C3AED);
  static const Color modSettings = Color(0xFF64748B);
  static const Color modAudit = Color(0xFF475569);

  // ── روښانه حالت ─────────────────────────────────────────
  static const AppScheme light = AppScheme(
    ground: Color(0xFFF6F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F3F9),
    ink: Color(0xFF141726),
    inkSoft: Color(0xFF3D4257),
    muted: Color(0xFF6B7189),
    faint: Color(0xFF9AA0B4),
    line: Color(0xFFE3E6EF),
    lineStrong: Color(0xFFCDD2E1),
  );

  // ── تیاره حالت ──────────────────────────────────────────
  static const AppScheme dark = AppScheme(
    ground: Color(0xFF0E1017),
    surface: Color(0xFF161A24),
    surfaceAlt: Color(0xFF1D222E),
    ink: Color(0xFFECEEF5),
    inkSoft: Color(0xFFC5CADB),
    muted: Color(0xFF8E95AB),
    faint: Color(0xFF636A80),
    line: Color(0xFF262C3A),
    lineStrong: Color(0xFF394154),
  );

  static AppScheme of(Brightness b) => b == Brightness.dark ? dark : light;

  /// د KPI کارتونو ګرادیانټونه.
  static const List<Color> gradIndigo = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> gradEmerald = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> gradRose = [Color(0xFFF43F5E), Color(0xFFE11D48)];
  static const List<Color> gradAmber = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> gradSky = [Color(0xFF0EA5E9), Color(0xFF0284C7)];
}

class AppScheme {
  final Color ground;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color faint;
  final Color line;
  final Color lineStrong;

  const AppScheme({
    required this.ground,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.faint,
    required this.line,
    required this.lineStrong,
  });
}

/// د `Theme.of(context)` له لارې لاسرسی — چې هر ویجیټ ته
/// د رنګونو بشپړ سیټ پرته له import ورسېږي.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  final Color ground;
  final Color surface;
  final Color surfaceAlt;
  final Color ink;
  final Color inkSoft;
  final Color muted;
  final Color faint;
  final Color line;
  final Color lineStrong;

  const AppPalette({
    required this.ground,
    required this.surface,
    required this.surfaceAlt,
    required this.ink,
    required this.inkSoft,
    required this.muted,
    required this.faint,
    required this.line,
    required this.lineStrong,
  });

  factory AppPalette.from(Brightness b) {
    final s = AppColors.of(b);
    return AppPalette(
      ground: s.ground,
      surface: s.surface,
      surfaceAlt: s.surfaceAlt,
      ink: s.ink,
      inkSoft: s.inkSoft,
      muted: s.muted,
      faint: s.faint,
      line: s.line,
      lineStrong: s.lineStrong,
    );
  }

  @override
  AppPalette copyWith({
    Color? ground,
    Color? surface,
    Color? surfaceAlt,
    Color? ink,
    Color? inkSoft,
    Color? muted,
    Color? faint,
    Color? line,
    Color? lineStrong,
  }) {
    return AppPalette(
      ground: ground ?? this.ground,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      ink: ink ?? this.ink,
      inkSoft: inkSoft ?? this.inkSoft,
      muted: muted ?? this.muted,
      faint: faint ?? this.faint,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      ground: Color.lerp(ground, other.ground, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      inkSoft: Color.lerp(inkSoft, other.inkSoft, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      faint: Color.lerp(faint, other.faint, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
    );
  }
}

extension PaletteX on BuildContext {
  AppPalette get palette => Theme.of(this).extension<AppPalette>()!;
}
